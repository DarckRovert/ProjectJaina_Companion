--[[
    WoWPeru_Companion — Core.lua
    Motor central del hub social de WoW Perú.

    Funcionalidades:
    1. Detecta qué addons WoW Perú tiene activo cada miembro del grupo.
    2. Anuncia en el canal GROUP cuando un jugador sube de nivel en el BattlePass.
    3. Muestra el badge de modo de juego (Hardcore/Normal) del jugador local.

    RESTRICCIONES 3.3.5a:
    - RegisterAddonMessagePrefix es defensivo.
    - Sin C_Timer.After: usa OnUpdate con elapsed.
    - SetTexture de color usa WHITE8X8 + SetVertexColor.
]]

WoWPeru_Companion = WoWPeru_Companion or {}
local C = WoWPeru_Companion

-- ================================================================
-- ESTADO
-- ================================================================
local groupAddonStatus = {}   -- [playerName] = { addons = {...}, mode = "..." }
local lastBPLevel      = 0   -- nivel propio en BattlePass (para detectar subida)
local addonLoaded      = false

-- ================================================================
-- UTILIDADES
-- ================================================================
local function CPrint(msg)
    local f = DEFAULT_CHAT_FRAME or ChatFrame1
    if f and f.AddMessage then
        f:AddMessage("|cFFD4AF37[WoW Peru]|r " .. tostring(msg))
    end
end

local function IsAddonLoaded(name)
    if not name or not _G.IsAddOnLoaded then return false end
    local loaded = _G.IsAddOnLoaded(name)
    return (loaded and true) or false
end

local function GetLocalGameMode()
    if WoWPeru_GameModes_CharDB
       and WoWPeru_GameModes_CharDB.hasSelectedMode
       and WoWPeru_GameModes_CharDB.selectedMode then
        return WoWPeru_GameModes_CharDB.selectedMode
    end
    -- Fallback resiliente a cabinas de internet (WTF reseteado): Escanear auras del servidor
    for i = 1, 40 do
        local auraName = UnitAura("player", i)
        if not auraName then break end
        local lower = auraName:lower()
        if lower:find("hardcore") then
            return "HARDCORE"
        elseif lower:find("ironman") then
            return "IRONMAN"
        end
    end
    return "NORMAL"
end

-- ================================================================
-- ANUNCIO AL GRUPO
-- ================================================================
local function AnnounceToGroup(msg)
    local ch = C.Config.AnnounceChannel
    if not ch or ch == "" then return end
    local inRaid = (GetNumRaidMembers and GetNumRaidMembers() > 0)
    local inParty = (GetNumPartyMembers and GetNumPartyMembers() > 0)
    if (ch == "GROUP" or ch == "PARTY") then
        if inRaid then
            SendChatMessage(msg, "RAID")
        elseif inParty then
            SendChatMessage(msg, "PARTY")
        end
    elseif ch == "SAY" then
        SendChatMessage(msg, "SAY")
    end
end

-- ================================================================
-- SECCIÓN 1: BROADCAST DE ADDONS ACTIVOS
-- ================================================================
local function BuildMyAddonPayload()
    -- Construye una cadena compacta con los addons activos
    -- Formato: "WP_ADDONS:<addon1>,<addon2>" — siempre < 100 bytes
    local active = {}
    for _, entry in ipairs(C.Config.EcosystemAddons) do
        if IsAddonLoaded(entry.name) then
            table.insert(active, entry.label)
        end
    end
    local mode = GetLocalGameMode()
    return string.format("WP_ADDONS:%s|%s", table.concat(active, ","), mode)
end

local function BroadcastStatus()
    local playerName = UnitName("player")
    if not playerName or playerName == "" then return end
    local inRaid = (GetNumRaidMembers and GetNumRaidMembers() > 0)
    local inParty = (GetNumPartyMembers and GetNumPartyMembers() > 0)
    if not inRaid and not inParty then return end

    local payload = BuildMyAddonPayload()
    if #payload > 200 then return end  -- guardia de 255 bytes
    if RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(C.Config.AddonPrefix)
    end
    if inRaid then
        SendAddonMessage(C.Config.AddonPrefix, payload, "RAID")
    elseif inParty then
        SendAddonMessage(C.Config.AddonPrefix, payload, "PARTY")
    end
end

-- ================================================================
-- SECCIÓN 2: RECEPCIÓN DE STATUS DE COMPAÑEROS
-- ================================================================
local function ParseAddonMessage(sender, message)
    -- "WP_ADDONS:<addon1>,<addon2>|<MODE>"
    local addonList, mode = message:match("^WP_ADDONS:([^|]*)|(.+)$")
    if not addonList then return end

    local addons = {}
    for label in addonList:gmatch("[^,]+") do
        addons[label] = true
    end

    groupAddonStatus[sender] = {
        addons = addons,
        mode   = mode or "NORMAL",
        time   = GetTime(),
    }
end

-- ================================================================
-- SECCIÓN 3: DETECCIÓN DE LEVEL-UP EN BATTLEPASS
-- ================================================================
local function CheckBattlePassLevelUp()
    if not WoWPeru_BattlePass then return end
    local bp = WoWPeru_BattlePass
    if not bp.Data then return end

    local newLevel = bp.Data.level or 0
    if newLevel > lastBPLevel and lastBPLevel > 0 then
        -- Subida de nivel detectada
        local playerName = UnitName("player") or "Desconocido"
        local msg = string.format(
            "[BattlePass] %s alcanzo el Nivel %d del Pase de Batalla! (/bp)",
            playerName, newLevel
        )
        AnnounceToGroup(msg)
    end
    lastBPLevel = newLevel
end

-- ================================================================
-- SECCIÓN 4: COMANDO /companion
-- ================================================================
local function PrintGroupStatus()
    CPrint("--- Estado del Ecosistema WoW Peru en el grupo ---")
    local count = 0
    for name, data in pairs(groupAddonStatus) do
        count = count + 1
        local addonNames = {}
        for label in pairs(data.addons) do
            table.insert(addonNames, label)
        end
        table.sort(addonNames)
        local modeStr = ""
        if data.mode == "HARDCORE" then modeStr = " |cFFFF3333[HC]|r"
        elseif data.mode == "IRONMAN" then modeStr = " |cFFFF9900[IM]|r"
        end
        local listStr = (#addonNames > 0) and table.concat(addonNames, ", ") or "(solo Companion)"
        CPrint(string.format("  %s%s: %s", name, modeStr, listStr))
    end
    if count == 0 then
        CPrint("  No hay datos de companeros aun. (Usa /companion scan)")
    end
end

SLASH_WPCOMP1 = "/companion"
SLASH_WPCOMP2 = "/wpcomp"
SlashCmdList["WPCOMP"] = function(msg)
    local cmd = (msg or ""):lower():match("%S+") or ""
    if cmd == "scan" then
        BroadcastStatus()
        CPrint("Escaneando addons del grupo...")
    elseif cmd == "status" or cmd == "" then
        PrintGroupStatus()
    elseif cmd == "debug" then
        C.Config.Debug = not C.Config.Debug
        CPrint("Debug: " .. (C.Config.Debug and "ON" or "OFF"))
    else
        CPrint("Uso: /companion [status|scan|debug]")
    end
end

-- ================================================================
-- EVENTO FRAME PRINCIPAL
-- ================================================================
local eventFrame = CreateFrame("Frame", "WoWPeruCompanion_Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")
eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")

-- Ticker liviano para revisar BattlePass level-up (cada 5 seg)
local tickElapsed = 0
local TICK_INTERVAL = 5

eventFrame:SetScript("OnUpdate", function(self, elapsed)
    if not addonLoaded then return end
    tickElapsed = tickElapsed + elapsed
    if tickElapsed >= TICK_INTERVAL then
        tickElapsed = 0
        CheckBattlePassLevelUp()
    end
end)

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == "WoWPeru_Companion" then
            addonLoaded = true
            -- Cargar DB
            WoWPeruCompanion_DB = WoWPeruCompanion_DB or {}
            CPrint("v" .. C.Config.Version .. " cargado. Usa /companion")
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        if RegisterAddonMessagePrefix then
            RegisterAddonMessagePrefix(C.Config.AddonPrefix)
        end
        -- Inicializar nivel base de BattlePass
        if WoWPeru_BattlePass and WoWPeru_BattlePass.Data then
            lastBPLevel = WoWPeru_BattlePass.Data.level or 0
        end
        -- Si ya está en grupo al loguear/reload, anunciar status
        BroadcastStatus()

    elseif event == "CHAT_MSG_ADDON" then
        local prefix, message, channel, sender = ...
        if prefix == C.Config.AddonPrefix then
            ParseAddonMessage(sender, message)
        end
        -- Escuchar BattlePass XP packets para detectar level-up
        if prefix == "WP_BP" and message then
            local opcode = message:match("^([^:]+)")
            if opcode == "BP_RES_XP" or opcode == "BP_RES_SYNC" then
                -- Dar un tick para que BattlePass procese primero
                tickElapsed = TICK_INTERVAL - 0.1
            end
        end

    elseif event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then
        -- Al unirse al grupo, broadcast propio y solicitar los demás
        local elapsed_delay = 0
        local delayFrame = CreateFrame("Frame")
        delayFrame:SetScript("OnUpdate", function(df, dt)
            elapsed_delay = elapsed_delay + dt
            if elapsed_delay >= 2 then
                df:SetScript("OnUpdate", nil)
                BroadcastStatus()
            end
        end)
    end
end)
