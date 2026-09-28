--[[
    WoWPeru_Companion — Config.lua
    Configuración y constantes del hub social.
    Compatible: WoW 3.3.5a (Build 12340) | Lua 5.1
]]

WoWPeru_Companion = WoWPeru_Companion or {}
local C = WoWPeru_Companion

C.Config = {
    Version         = "1.0.0",
    AnnounceChannel = "GROUP",   -- GROUP | PARTY | SAY | ninguno ("")
    ShowMinimapBadge = true,
    Debug           = false,

    -- Addons del ecosistema a detectar
    EcosystemAddons = {
        { name = "WoWPeru_BattlePass",  label = "BattlePass", color = "FFD4AF37" },
        { name = "WoWPeru_Companion",   label = "Companion",  color = "FFAB47BC" },
        { name = "WoWPeru_GameModes",   label = "GameModes",  color = "FF4FC3F7" },
        { name = "WoWPeru_RaidSuite",   label = "RaidSuite",  color = "FF81C784" },
        { name = "WowPeruVisualShop",   label = "VisualShop", color = "FFCE93D8" },
    },

    -- Prefijo de red
    AddonPrefix = "WP_COMP",
}
