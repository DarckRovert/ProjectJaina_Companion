--[[
    ProjectJaina_Companion — Core.lua
    Motor central del hub social de Project Jaina.

    Funcionalidades:
    1. Detecta qué addons Project Jaina tiene activo cada miembro del grupo vía P2P (WP_COMP).
    2. Anuncia en el canal de grupo cuando un jugador sube de nivel en el BattlePass.
    3. Muestra el badge de modo de juego (Hardcore/Ironman/Normal) del jugador local.
    4. Resiliencia contra reseteo de WTF en cabinas de internet mediante escaneo de auras.

    RESTRICCIONES 3.3.5a:
    - RegisterAddonMessagePrefix es defensivo.
    - Sin C_Timer.After: usa OnUpdate con elapsed.
    - SetTexture de color usa WHITE8X8 + SetVertexColor.
    - Zero heap thrashing: reuso de timers, sin CreateFrame dinámico en cada evento.
]]

-- ================================================================
-- SYSTEM HOTFIX: FrameXML / ChatFrame CHANNEL_NOTICE Nil Guard
-- Protege contra crash en ChatFrame.lua:2802 si el servidor envía notices no definidas en GlobalStrings
-- ================================================================
if not _G.CHAT_NOT_IN_LFG_NOTICE then
    _G.CHAT_NOT_IN_LFG_NOTICE = "|Hchannel:%d|h[%s]|h Debes unirte a la cola de Buscar grupo para poder participar en este canal."
end
if not _G.CHAT_NOT_IN_LFG_NOTICE_BN then
    _G.CHAT_NOT_IN_LFG_NOTICE_BN = "|Hchannel:CHANNEL:%d|h[%s]|h Debes unirte a la cola de Buscar grupo para poder participar en este canal."
end

local _Orig_ChatFrame_MessageEventHandler = _G.ChatFrame_MessageEventHandler
if _Orig_ChatFrame_MessageEventHandler then
    _G.ChatFrame_MessageEventHandler = function(self, event, ...)
        if event == "CHAT_MSG_CHANNEL_NOTICE" or event == "CHAT_MSG_CHANNEL_NOTICE_USER" then
            local noticeType = ...
            if noticeType then
                local bnKey = "CHAT_" .. tostring(noticeType) .. "_NOTICE_BN"
                local stdKey = "CHAT_" .. tostring(noticeType) .. "_NOTICE"
                if not _G[bnKey] and not _G[stdKey] then
                    _G[stdKey] = "|Hchannel:%d|h[%s]|h [" .. tostring(noticeType) .. "]"
                end
            end
        end
        return _Orig_ChatFrame_MessageEventHandler(self, event, ...)
    end
end

ProjectJaina_Companion = ProjectJaina_Companion or {}
local C = ProjectJaina_Companion

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
        f:AddMessage("|cFFD4AF37[Project Jaina]|r " .. tostring(msg))
    end
end

local function IsAddonLoaded(name)
    if not name or not _G.IsAddOnLoaded then return false end
    local loaded = _G.IsAddOnLoaded(name)
    return (loaded and true) or false
end

local function GetLocalGameMode()
    if ProjectJaina_GameModes_CharDB
       and ProjectJaina_GameModes_CharDB.hasSelectedMode
       and ProjectJaina_GameModes_CharDB.selectedMode then
        return ProjectJaina_GameModes_CharDB.selectedMode
    end

    -- Fallback resiliente a cabinas de internet (WTF reseteado): Escanear auras del servidor
    for i = 1, 40 do
        local auraName = UnitAura("player", i)
        if not auraName then break end
        local lower = auraName:lower()
        if lower:find("hardcore") then
            if ProjectJaina_GameModes_CharDB then
                ProjectJaina_GameModes_CharDB.hasSelectedMode = true
                ProjectJaina_GameModes_CharDB.selectedMode = "HARDCORE"
            end
            return "HARDCORE"
        elseif lower:find("ironman") then
            if ProjectJaina_GameModes_CharDB then
                ProjectJaina_GameModes_CharDB.hasSelectedMode = true
                ProjectJaina_GameModes_CharDB.selectedMode = "IRONMAN"
            end
            return "IRONMAN"
        end
    end
    return "NORMAL"
end

-- ================================================================
-- DETECCIÓN UNIFICADA DE CANAL DE GRUPO (PVE + PVP BATTLEGROUNDS)
-- ================================================================
local function GetGroupChannel()
    if IsInInstance then
        local inInstance, instanceType = IsInInstance()
        if inInstance and instanceType == "pvp" then
            return "BATTLEGROUND"
        end
    end
    if GetNumRaidMembers and GetNumRaidMembers() > 0 then
        return "RAID"
    elseif GetNumPartyMembers and GetNumPartyMembers() > 0 then
        return "PARTY"
    end
    return nil
end

-- ================================================================
-- ANUNCIO AL GRUPO (LIMPIO DE CÓDIGOS DE COLOR |c)
-- ================================================================
local function AnnounceToGroup(msg)
    local ch = C.Config.AnnounceChannel
    if not ch or ch == "" or ch == "OFF" or ch == "NONE" then return end
    if (ch == "GROUP" or ch == "PARTY") then
        local target = GetGroupChannel()
        if target then
            SendChatMessage(msg, target)
        end
    elseif ch == "SAY" then
        SendChatMessage(msg, "SAY")
    end
end

-- ================================================================
-- LIMPIEZA DE MIEMBROS DESCONECTADOS / GRUPO DISUELTO
-- ================================================================
local function PruneGroupStatus()
    local targetChannel = GetGroupChannel()
    if not targetChannel then
        for k in pairs(groupAddonStatus) do
            groupAddonStatus[k] = nil
        end
        return
    end

    local currentMembers = {}
    local myName = UnitName("player")
    if myName then currentMembers[myName] = true end

    if targetChannel == "RAID" or targetChannel == "BATTLEGROUND" then
        local count = GetNumRaidMembers()
        for i = 1, count do
            local name = UnitName("raid" .. i)
            if name then currentMembers[name] = true end
        end
    elseif targetChannel == "PARTY" then
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
    local targetChannel = GetGroupChannel()
    if not targetChannel then return end

    local payload = BuildMyAddonPayload()
    if #payload > 200 then return end  -- guardia estricta de 255 bytes

    if RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(C.Config.AddonPrefix)
    end

    SendAddonMessage(C.Config.AddonPrefix, payload, targetChannel)
end

-- ================================================================
-- SECCIÓN 2: RECEPCIÓN DE STATUS Y PROTOCOLO P2P BIDIRECCIONAL
-- ================================================================
local responseJitterTimer = 0
local responseJitterTarget = 0
local responsePending = false

local function ParseAddonMessage(sender, message)
    if not sender or sender == "" or not message then return end
    local myName = UnitName("player")
    local baseSender = sender:match("^[^-]+") or sender
    if baseSender == myName or sender == myName then return end

    -- 1. Solicitud de escaneo P2P proveniente de un compañero de grupo/banda
    if message == "WP_SCAN_REQ" then
        -- Responder con jitter defensivo aleatorio para evitar colisiones en bandas de 25/40
        responseJitterTimer = 0
        responseJitterTarget = 0.05 + (math.random(1, 30) / 100)
        responsePending = true
        return
    end

    -- 2. Recepción de estado de un compañero
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

local function RequestGroupScan()
    local targetChannel = GetGroupChannel()
    if not targetChannel then
        CPrint("No estás en un grupo o banda para escanear.")
        return
    end

    if RegisterAddonMessagePrefix then
        RegisterAddonMessagePrefix(C.Config.AddonPrefix)
    end

    -- Primero transmitimos nuestro estado
    BroadcastStatus()

    -- Solicitamos a todos los clientes del grupo responder con el suyo
    SendAddonMessage(C.Config.AddonPrefix, "WP_SCAN_REQ", targetChannel)
    CPrint("Escaneando addons del grupo (solicitud P2P enviada)...")
end

-- ================================================================
-- SECCIÓN 3: DETECCIÓN DE LEVEL-UP EN BATTLEPASS (LOGIN SEGURO)
-- ================================================================
local function CheckBattlePassLevelUp()
    if not Jaina_BattlePass then return end
    local bp = Jaina_BattlePass
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
-- FORMATO CANÓNICO DE MODOS DE JUEGO (NORMAL, HC, IM, RETO X1)
-- ================================================================
local function FormatModeBadge(mode, short)
    if not mode or mode == "NORMAL" or mode == "NONE" then
        return short and "" or " |cFF888888[NORMAL]|r"
    elseif mode == "HARDCORE" then
        return short and " |cFFFF3333[HC]|r" or " |cFFFF3333[HARDCORE]|r"
    elseif mode == "IRONMAN" then
        return short and " |cFFFF9900[IM]|r" or " |cFFFF9900[IRONMAN]|r"
    elseif mode == "SLOW_X1" or mode == "X1" then
        return short and " |cFFFFD100[X1]|r" or " |cFFFFD100[RETO X1]|r"
    end
    return short and string.format(" |cFF00CCFF[%s]|r", tostring(mode)) or string.format(" |cFF00CCFF[%s]|r", tostring(mode))
end

-- ================================================================
-- SECCIÓN 4: INTERFAZ DE COMANDO /companion
-- ================================================================
local function PrintGroupStatus()
    PruneGroupStatus()

    local targetChannel = GetGroupChannel()
    if not targetChannel then
        local myMode = GetLocalGameMode()
        CPrint("No estas en un grupo o banda actualmente.")
        CPrint("Tu modo activo:" .. FormatModeBadge(myMode, false))
        return
    end

    CPrint("--- Estado del Ecosistema Project Jaina en el grupo ---")

    -- Mostrar primero al jugador local
    local myName = UnitName("player") or "Jugador"
    local myMode = GetLocalGameMode()
    local myModeStr = FormatModeBadge(myMode, true)

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
            local modeStr = FormatModeBadge(data.mode, true)
            local listStr = (#addonNames > 0) and table.concat(addonNames, ", ") or "(solo Companion)"
            CPrint(string.format("  %s%s: %s", name, modeStr, listStr))
        end
    end

    if count == 0 then
        CPrint("  No hay datos de companeros aun. (Usa /companion scan para solicitar)")
    end
end

-- ================================================================
-- CENTRO DE CONTROL: MENÚ DESPLEGABLE NATIVO DEL ECOSISTEMA
-- ================================================================
local hubDropDown = CreateFrame("Frame", "ProjectJainaHubDropDown", UIParent, "UIDropDownMenuTemplate")

local function ExecuteOrWarn(slashKey, fallbackKey, moduleName)
    if SlashCmdList and SlashCmdList[slashKey] then
        SlashCmdList[slashKey]("")
    elseif fallbackKey and SlashCmdList and SlashCmdList[fallbackKey] then
        SlashCmdList[fallbackKey]("")
    elseif moduleName == "MultiBot" and MultiBot and MultiBot.ToggleMainUIVisibility then
        MultiBot.ToggleMainUIVisibility()
    else
        CPrint(string.format("|cFFFF4444El modulo %s no esta activo o instalado.|r", moduleName))
    end
end

local function OpenHubMenu(anchor)
    local menuList = {
        { text = "|cFFD4AF37Project Jaina|r - Centro de Control", isTitle = true, notCheckable = true },
        { text = "|cFFFFD100Pase de Batalla|r (/bp)", notCheckable = true, func = function()
            ExecuteOrWarn("WOWPERUBP", "BP", "BattlePass")
        end },
        { text = "|cFFFFD100Guardarropa (Transfiguración)|r (/armario)", notCheckable = true, func = function()
            ExecuteOrWarn("WP_WARDROBEV2", "ARMARIO", "Guardarropa")
        end },
        { text = "|cFFFFD100Modos de Juego|r (/modos)", notCheckable = true, func = function()
            ExecuteOrWarn("WOWPERU_MODES", "MODOS", "Modos de Juego")
        end },
        { text = "|cFFFFD100Suite Gráfica HD|r (/graficos)", notCheckable = true, func = function()
            ExecuteOrWarn("WOWPERU_GRAPHICS", nil, "Graficos HD")
        end },
        { text = "|cFF00FFCCGestor de Bots con IA|r (/bots)", notCheckable = true, func = function()
            ExecuteOrWarn("CHATTER", nil, "Chatter LLM")
        end },
        { text = "|cFFFFD100Playerbots (MultiBot)|r (/multibot)", notCheckable = true, func = function()
            ExecuteOrWarn("MULTIBOT", "ACECONSOLE_MULTIBOT", "MultiBot")
        end },
        { text = "|cFFFFD100Tienda de Visuales|r (/tienda)", notCheckable = true, func = function()
            ExecuteOrWarn("WOWPERU_VISUAL", nil, "Tienda Visual")
        end },
        { text = "|cFFFFD100LoreHUD (Subtítulos 3D)|r (/lorehud)", notCheckable = true, func = function()
            ExecuteOrWarn("LOREHUD", nil, "LoreHUD")
        end },
        { text = " ", notCheckable = true, disabled = true },
        { text = "Herramientas de Grupo", hasArrow = true, notCheckable = true,
          menuList = {
              { text = "Solicitar Escaneo P2P", notCheckable = true, func = RequestGroupScan },
              { text = "Imprimir Estado de Companeros", notCheckable = true, func = PrintGroupStatus },
          }
        },
        { text = " ", notCheckable = true, disabled = true },
        { text = "|cFF888888Cerrar|r", notCheckable = true, func = function() end },
    }
    EasyMenu(menuList, hubDropDown, anchor or "cursor", 0, 0, "MENU")
end

SLASH_WPCOMP1 = "/companion"
SLASH_WPCOMP2 = "/wpcomp"
SLASH_WPCOMP3 = "/hub"
SLASH_WPCOMP4 = "/menu"
SlashCmdList["WPCOMP"] = function(msg)
    local cmd, arg = (msg or ""):lower():match("^(%S+)%s*(%S*)$")
    cmd = cmd or ""

    if cmd == "menu" or cmd == "hub" or cmd == "" then
        OpenHubMenu("cursor")
    elseif cmd == "scan" then
        RequestGroupScan()
    elseif cmd == "status" then
        PrintGroupStatus()
    elseif cmd == "debug" then
        C.Config.Debug = not C.Config.Debug
        if ProjectJainaCompanion_DB then ProjectJainaCompanion_DB.Debug = C.Config.Debug end
        CPrint("Debug: " .. (C.Config.Debug and "ON" or "OFF"))
    elseif cmd == "channel" then
        if arg == "group" or arg == "party" or arg == "say" then
            C.Config.AnnounceChannel = arg:upper()
            if ProjectJainaCompanion_DB then ProjectJainaCompanion_DB.AnnounceChannel = C.Config.AnnounceChannel end
            CPrint("Canal de anuncios configurado en: " .. C.Config.AnnounceChannel)
        elseif arg == "off" or arg == "none" then
            C.Config.AnnounceChannel = ""
            if ProjectJainaCompanion_DB then ProjectJainaCompanion_DB.AnnounceChannel = "" end
            CPrint("Anuncios desactivados.")
        else
            local cur = (C.Config.AnnounceChannel ~= "") and C.Config.AnnounceChannel or "OFF"
            CPrint("Canal actual: " .. cur)
            CPrint("Uso: /companion channel [group|party|say|off]")
        end
    else
        CPrint("Uso: /companion [status|scan|channel|debug]")
        CPrint("Comandos Cross-Faction: /comerciar y /invitar [Nombre]")
    end
end

-- ================================================================
-- UTILIDADES CROSS-FACTION (Alianza <-> Horda)
-- Permite comerciar e invitar entre facciones opuestas de forma limpia
-- sin modificar UnitPopupMenus de Blizzard (CERO TAINT).
-- ================================================================
SLASH_WPCOMERCIAR1 = "/comerciar"
SLASH_WPCOMERCIAR2 = "/comercio"
SlashCmdList["WPCOMERCIAR"] = function()
    if not UnitExists("target") then
        CPrint("Selecciona a un jugador y escribe |cFFD4AF37/comerciar|r")
        return
    end
    InitiateTrade("target")
end

SLASH_WPINVITAR1 = "/invitar"
SlashCmdList["WPINVITAR"] = function(nombre)
    if nombre and nombre ~= "" then
        InviteUnit(nombre)
        return
    end
    if UnitExists("target") and UnitIsPlayer("target") then
        InviteUnit(UnitName("target"))
        return
    end
    CPrint("Escribe |cFFD4AF37/invitar Nombre|r, o selecciona a un jugador primero.")
end

-- ================================================================
-- BOTÓN DE MINIMAPA OFICIAL CON EL LOGO DE WOW PERÚ
-- ================================================================
local minimapBtn = nil
local DEFAULT_COMPANION_ANGLE = 165
local MINIMAP_RADIUS = 80

local function UpdateMinimapBtnPosition(button, angle)
    local rad = math.rad(angle)
    local x = math.cos(rad) * MINIMAP_RADIUS
    local y = math.sin(rad) * MINIMAP_RADIUS
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function CreateMinimapButton()
    if minimapBtn then return minimapBtn end
    local btn = CreateFrame("Button", "ProjectJaina_CompanionMinimapBtn", Minimap)
    btn:SetSize(31, 31)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:EnableMouse(true)
    btn:SetMovable(true)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:RegisterForDrag("LeftButton", "RightButton")
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", btn, "CENTER", 0, 0)
    icon:SetTexture("Interface\\AddOns\\Jaina_Companion\\Textures\\jaina_icon.tga")

    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetSize(52, 52)
    border:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    local wasDragged = false
    local function OnDragUpdate(self)
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        px, py = px / scale, py / scale

        local angle = math.deg(math.atan2(py - my, px - mx))
        if angle < 0 then angle = angle + 360 end

        ProjectJaina_Companion_DB = ProjectJaina_Companion_DB or ProjectJainaCompanion_DB or {}
            ProjectJainaCompanion_DB = ProjectJaina_Companion_DB
        ProjectJainaCompanion_DB.minimapAngle = angle

        UpdateMinimapBtnPosition(self, angle)
        wasDragged = true
    end

    btn:SetScript("OnDragStart", function(self)
        wasDragged = false
        self:LockHighlight()
        self:SetScript("OnUpdate", OnDragUpdate)
    end)

    btn:SetScript("OnDragStop", function(self)
        self:UnlockHighlight()
        self:SetScript("OnUpdate", nil)
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("|cFFD4AF37Project Jaina Companion|r", 1, 1, 1)
        GameTooltip:AddLine("Centro de Control del Ecosistema", 0.8, 0.8, 0.8)
        GameTooltip:AddLine("|cFF888888Desarrollo: DarckRovert (Elnazzareno)|r", 0.7, 0.7, 0.7)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFFFFD100Click Izquierdo:|r Abrir Menú Central de Project Jaina", 0.2, 1, 0.2)
        GameTooltip:AddLine("|cFFFFD100Click Derecho:|r Imprimir estado de compañeros P2P", 0.2, 0.8, 1)
        GameTooltip:AddLine("|cFF888888Arrastrar para reposicionar|r", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    btn:SetScript("OnClick", function(self, button)
        if wasDragged then
            wasDragged = false
            return
        end
        if button == "RightButton" then
            PrintGroupStatus()
        else
            OpenHubMenu("cursor")
        end
    end)

    local savedAngle = (ProjectJainaCompanion_DB and ProjectJainaCompanion_DB.minimapAngle) or DEFAULT_COMPANION_ANGLE
    UpdateMinimapBtnPosition(btn, savedAngle)

    minimapBtn = btn
    return btn
end

-- ================================================================
-- EVENTO FRAME PRINCIPAL (ZERO HEAP ALLOCATION)
-- ================================================================
local eventFrame = CreateFrame("Frame", "ProjectJainaCompanion_Frame")
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

    -- Despacho con jitter para respuesta a solicitud WP_SCAN_REQ
    if responsePending then
        responseJitterTimer = responseJitterTimer + elapsed
        if responseJitterTimer >= responseJitterTarget then
            responsePending = false
            responseJitterTimer = 0
            BroadcastStatus()
        end
    end
end)

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == "ProjectJaina_Companion" or name == "ProjectJaina_Companion" then
            addonLoaded = true
            -- Cargar DB persistente
            ProjectJaina_Companion_DB = ProjectJaina_Companion_DB or ProjectJainaCompanion_DB or {}
            ProjectJainaCompanion_DB = ProjectJaina_Companion_DB
            if ProjectJainaCompanion_DB.AnnounceChannel ~= nil then
                C.Config.AnnounceChannel = ProjectJainaCompanion_DB.AnnounceChannel
            end
            if ProjectJainaCompanion_DB.Debug ~= nil then
                C.Config.Debug = ProjectJainaCompanion_DB.Debug
            end
            CreateMinimapButton()
            CPrint("v" .. C.Config.Version .. " cargado. Usa /companion")
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        if RegisterAddonMessagePrefix then
            RegisterAddonMessagePrefix(C.Config.AddonPrefix)
        end
        -- Inicializar nivel base de BattlePass si ya completó sync
        if Jaina_BattlePass and Jaina_BattlePass.Data and Jaina_BattlePass.Data.hasSyncedOnce then
            lastBPLevel = Jaina_BattlePass.Data.level or 0
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

        -- Escuchar confirmación autoritativa de modo de juego para actualizar grupo de inmediato
        if prefix == "WP_GAMEMODE" and message then
            local mode = message:match("^STATUS:(.+)$") or message:match("^ACK:(.+)$")
            if mode then
                if ProjectJaina_GameModes_CharDB then
                    if mode == "NONE" then
                        ProjectJaina_GameModes_CharDB.hasSelectedMode = false
                        ProjectJaina_GameModes_CharDB.selectedMode = nil
                    else
                        ProjectJaina_GameModes_CharDB.hasSelectedMode = true
                        ProjectJaina_GameModes_CharDB.selectedMode = mode
                    end
                end
                BroadcastStatus()
            end
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
