--[[
    WoWPeru_Companion — Config.lua
    Configuración y constantes del hub social.
    Compatible: WoW 3.3.5a (Build 12340) | Lua 5.1
]]

WoWPeru_Companion = WoWPeru_Companion or {}
local C = WoWPeru_Companion

C.Config = {
    Version         = "1.0.2",
    AnnounceChannel = "GROUP",   -- GROUP | PARTY | SAY | OFF ("")
    Debug           = false,

    -- Addons del ecosistema a detectar
    EcosystemAddons = {
        { name = "LoreHUD",             label = "LoreHUD",    color = "FF69B4FF" },
        { name = "Carbonite",           label = "Carbonite",  color = "FF00E5FF" },
        { name = "WoWPeru_BattlePass",  label = "BattlePass", color = "FFD4AF37" },
        { name = "WoWPeru_Companion",   label = "Companion",  color = "FFAB47BC" },
        { name = "WoWPeru_GameModes",   label = "GameModes",  color = "FF4FC3F7" },
        { name = "WoWPeru_RaidSuite",   label = "RaidSuite",  color = "FF81C784" },
        { name = "WowPeruVisualShop",   label = "VisualShop", color = "FFCE93D8" },
    },

    -- Prefijo de red
    AddonPrefix = "WP_COMP",
}
