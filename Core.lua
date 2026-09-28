--[[
    WoWPeru_Companion — Core.lua
    Motor central del hub social de WoW Perú.

    Funcionalidades:
    1. Detecta qué addons WoW Perú tiene activo cada miembro del grupo vía P2P (WP_COMP).
    2. Anuncia en el canal de grupo cuando un jugador sube de nivel en el BattlePass.
    3. Muestra el badge de modo de juego (Hardcore/Ironman/Normal) del jugador local.
    4. Resiliencia contra reseteo de WTF en cabinas de internet mediante escaneo de auras.

    RESTRICCIONES 3.3.5a:
    - RegisterAddonMessagePrefix es defensivo.
    - Sin C_Timer.After: usa OnUpdate con elapsed.
    - SetTexture de color usa WHITE8X8 + SetVertexColor.
    - Zero heap thrashing: reuso de timers, sin CreateFrame dinámico en cada evento.
]]

WoWPeru_Companion = WoWPeru_Companion or {}
local C = WoWPeru_Companion

-- ================================================================
-- ESTADO EN MEMORIA
-- ================================================================
local groupAddonStatus = {}   -- [playerName] = { addons = {...}, mode = "...", time = GetTime() }
local lastBPLevel      = 0   -- nivel propio en BattlePass
local addonLoaded      = false

-- Timers defensivos (reutilizados en el OnUpdate principal)
local tickElapsed            = 0
local TICK_INTERVAL          = 5
local rosterTimer            = 0
local rosterDebounceActive   = false

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
            if WoWPeru_GameModes_CharDB then
                WoWPeru_GameModes_CharDB.hasSelectedMode = true
                WoWPeru_GameModes_CharDB.selectedMode = "HARDCORE"
            end
            return "HARDCORE"
        elseif lower:find("ironman") then
            if WoWPeru_GameModes_CharDB then
                WoWPeru_GameModes_CharDB.hasSelectedMode = true
                WoWPeru_GameModes_CharDB.selectedMode = "IRONMAN"
            end
            return "IRONMAN"
        end
    end
    return "NORMAL"
end

-- ================================================================
-- ANUNCIO AL GRUPO (LIMPIO DE CÓDIGOS DE COLOR |c)
-- ================================================================
local function AnnounceToGroup(msg)
    local ch = C.Config.AnnounceChannel
    if not ch or ch == "" or ch == "OFF" or ch == "NONE" then return end
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
-- LIMPIEZA DE MIEMBROS DESCONECTADOS / GRUPO DISUELTO
-- ================================================================
local function PruneGroupStatus()
    local inRaid = (GetNumRaidMembers and GetNumRaidMembers() > 0)
    local inParty = (GetNumPartyMembers and GetNumPartyMembers() > 0)
    if not inRaid and not inParty then
        for k in pairs(groupAddonStatus) do
            groupAddonStatus[k] = nil
        end
        return
    end

    local currentMembers = {}
    local myName = UnitName("player")
    if myName then currentMembers[myName] = true end

    if inRaid then
        local count = GetNumRaidMembers()
        for i = 1, count do
            local name = UnitName("raid" .. i)
            if name then currentMembers[name] = true end
        end
    elseif inParty then
        local count = GetNumPartyMembers()
        for i = 1, count do
            local name = UnitName("party" .. i)
            if name then currentMembers[name] = true end
        end
    end

    for sender in pairs(groupAddonStatus) do
        local baseName = sender:match("^[^-]+") or sender
        if not currentMembers[sender] and not currentMembers[baseName] then
            groupAddonStatus[sender] = nil
        end
    end
end

-- ================================================================
-- SECCIÓN 1: BROADCAST DE ADDONS ACTIVOS
-- ================================================================
local function BuildMyAddonPayload()
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
    if #payload > 200 then return end  -- guardia estricta de 255 bytes

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
    if not sender or sender == "" or not message then return end

    -- Formato esperado: "WP_ADDONS:<addon1>,<addon2>|<MODE>"
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
-- SECCIÓN 3: DETECCIÓN DE LEVEL-UP EN BATTLEPASS (LOGIN SEGURO)
-- ================================================================
local function CheckBattlePassLevelUp()
    if not WoWPeru_BattlePass then return end
    local bp = WoWPeru_BattlePass
    if not bp.Data then return end

    -- Blindaje: Si el BattlePass aún no completa su sincronización inicial con el servidor, no evaluar
    if not bp.Data.hasSyncedOnce then
        return
    end

    local newLevel = bp.Data.level or 0
    if lastBPLevel == 0 then
        -- Primer registro tras sincronización exitosa: no emitir anuncio de login
        lastBPLevel = newLevel
        return
    end

    if newLevel > lastBPLevel then
        local playerName = UnitName("player") or "Desconocido"
        local msg = string.format(
            "[BattlePass] %s alcanzo el Nivel %d del Pase de Batalla! (/bp)",
            playerName, newLevel
        )
        AnnounceToGroup(msg)
        lastBPLevel = newLevel
    end
end

-- ================================================================
-- SECCIÓN 4: INTERFAZ DE COMANDO /companion
-- ================================================================
local function PrintGroupStatus()
    PruneGroupStatus()

    local inRaid = (GetNumRaidMembers and GetNumRaidMembers() > 0)
    local inParty = (GetNumPartyMembers and GetNumPartyMembers() > 0)

    if not inRaid and not inParty then
        local myMode = GetLocalGameMode()
        local modeStr = ""
        if myMode == "HARDCORE" then modeStr = " |cFFFF3333[HARDCORE]|r"
        elseif myMode == "IRONMAN" then modeStr = " |cFFFF9900[IRONMAN]|r"
        else modeStr = " |cFF888888[NORMAL]|r"
        end
        CPrint("No estas en un grupo o banda actualmente.")
        CPrint("Tu modo activo:" .. modeStr)
        return
    end

    CPrint("--- Estado del Ecosistema WoW Peru en el grupo ---")

    -- Mostrar primero al jugador local
    local myName = UnitName("player") or "Jugador"
    local myMode = GetLocalGameMode()
    local myModeStr = ""
    if myMode == "HARDCORE" then myModeStr = " |cFFFF3333[HC]|r"
    elseif myMode == "IRONMAN" then myModeStr = " |cFFFF9900[IM]|r"
    end

    local myActive = {}
    for _, entry in ipairs(C.Config.EcosystemAddons) do
        if IsAddonLoaded(entry.name) then
            table.insert(myActive, entry.label)
        end
    end
    table.sort(myActive)
    local myList = (#myActive > 0) and table.concat(myActive, ", ") or "(solo Companion)"
    CPrint(string.format("  %s%s (Tu): %s", myName, myModeStr, myList))

    -- Mostrar compañeros
    local count = 0
    for name, data in pairs(groupAddonStatus) do
        local baseName = name:match("^[^-]+") or name
        if baseName ~= myName and name ~= myName then
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
    end

    if count == 0 then
        CPrint("  No hay datos de companeros aun. (Usa /companion scan para solicitar)")
    end
end

SLASH_WPCOMP1 = "/companion"
SLASH_WPCOMP2 = "/wpcomp"
SlashCmdList["WPCOMP"] = function(msg)
    local cmd, arg = (msg or ""):lower():match("^(%S+)%s*(%S*)$")
    cmd = cmd or ""

    if cmd == "scan" then
        BroadcastStatus()
        CPrint("Escaneando addons del grupo...")
    elseif cmd == "status" or cmd == "" then
        PrintGroupStatus()
    elseif cmd == "debug" then
        C.Config.Debug = not C.Config.Debug
        if WoWPeruCompanion_DB then WoWPeruCompanion_DB.Debug = C.Config.Debug end
        CPrint("Debug: " .. (C.Config.Debug and "ON" or "OFF"))
    elseif cmd == "channel" then
        if arg == "group" or arg == "party" or arg == "say" then
            C.Config.AnnounceChannel = arg:upper()
            if WoWPeruCompanion_DB then WoWPeruCompanion_DB.AnnounceChannel = C.Config.AnnounceChannel end
            CPrint("Canal de anuncios configurado en: " .. C.Config.AnnounceChannel)
        elseif arg == "off" or arg == "none" then
            C.Config.AnnounceChannel = ""
            if WoWPeruCompanion_DB then WoWPeruCompanion_DB.AnnounceChannel = "" end
            CPrint("Anuncios desactivados.")
        else
            local cur = (C.Config.AnnounceChannel ~= "") and C.Config.AnnounceChannel or "OFF"
            CPrint("Canal actual: " .. cur)
            CPrint("Uso: /companion channel [group|party|say|off]")
        end
    else
        CPrint("Uso: /companion [status|scan|channel|debug]")
    end
end

-- ================================================================
-- EVENTO FRAME PRINCIPAL (ZERO HEAP ALLOCATION)
-- ================================================================
local eventFrame = CreateFrame("Frame", "WoWPeruCompanion_Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")
eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")

eventFrame:SetScript("OnUpdate", function(self, elapsed)
    if not addonLoaded then return end

    -- Ticker liviano para revisar BattlePass level-up (cada 5 seg)
    tickElapsed = tickElapsed + elapsed
    if tickElapsed >= TICK_INTERVAL then
        tickElapsed = 0
        CheckBattlePassLevelUp()
    end

    -- Debounce de Roster Update (Zero heap allocation, cero fugas de frames)
    if rosterDebounceActive then
        rosterTimer = rosterTimer + elapsed
        if rosterTimer >= 2.0 then
            rosterDebounceActive = false
            rosterTimer = 0
            PruneGroupStatus()
            BroadcastStatus()
        end
    end
end)

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == "WoWPeru_Companion" then
            addonLoaded = true
            -- Cargar DB persistente
            WoWPeruCompanion_DB = WoWPeruCompanion_DB or {}
            if WoWPeruCompanion_DB.AnnounceChannel ~= nil then
                C.Config.AnnounceChannel = WoWPeruCompanion_DB.AnnounceChannel
            end
            if WoWPeruCompanion_DB.Debug ~= nil then
                C.Config.Debug = WoWPeruCompanion_DB.Debug
            end
            CPrint("v" .. C.Config.Version .. " cargado. Usa /companion")
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        if RegisterAddonMessagePrefix then
            RegisterAddonMessagePrefix(C.Config.AddonPrefix)
        end
        -- Inicializar nivel base de BattlePass si ya completó sync
        if WoWPeru_BattlePass and WoWPeru_BattlePass.Data and WoWPeru_BattlePass.Data.hasSyncedOnce then
            lastBPLevel = WoWPeru_BattlePass.Data.level or 0
        else
            lastBPLevel = 0
        end
        -- Anunciar status si entra al mundo en grupo
        BroadcastStatus()

    elseif event == "CHAT_MSG_ADDON" then
        local prefix, message, channel, sender = ...
        if prefix == C.Config.AddonPrefix then
            ParseAddonMessage(sender, message)
        end

        -- Escuchar paquetes de BattlePass para sincronizar inmediato tras XP real
        if prefix == "WP_BP" and message then
            local opcode = message:match("^([^:]+)")
            if opcode == "BP_RES_XP" then
                -- Acelerar ticker para comprobar inmediatamente tras procesar el levelup
                tickElapsed = TICK_INTERVAL - 0.1
            end
        end

    elseif event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then
        PruneGroupStatus()
        -- Resetear el timer de debounce para no spamear en formaciones masivas de raid
        rosterTimer = 0
        rosterDebounceActive = true
    end
end)
