--[[
    ProjectJaina_Companion — Config.lua
    Configuración y constantes del hub social.
    Compatible: WoW 3.3.5a (Build 12340) | Lua 5.1
]]

ProjectJaina_Companion = ProjectJaina_Companion or {}
local C = ProjectJaina_Companion

C.Config = {
    Version         = "1.0.3",
    AnnounceChannel = "GROUP",   -- GROUP | PARTY | SAY | OFF ("")
    Debug           = false,

    -- Addons del ecosistema a detectar
    EcosystemAddons = {
        { name = "LoreHUD",             label = "LoreHUD",    color = "FF69B4FF" },
        { name = "Carbonite",           label = "Carbonite",  color = "FF00E5FF" },
        { name = "Jaina_BattlePass",  label = "BattlePass", color = "FFD4AF37" },
        { name = "ProjectJaina_Companion",   label = "Companion",  color = "FFAB47BC" },
        { name = "ProjectJaina_GameModes",   label = "GameModes",  color = "FF4FC3F7" },
        { name = "ProjectJaina_RaidSuite",   label = "RaidSuite",  color = "FF81C784" },
        { name = "ProjectJaina_VisualShop",   label = "VisualShop", color = "FFCE93D8" },
        { name = "Talented",            label = "Talented",   color = "FFF57C00" },
        { name = "ProjectJaina_Wardrobe",    label = "Wardrobe",   color = "FFE6C280" },
    },

    -- Prefijo de red
    AddonPrefix = "WP_COMP",
}
