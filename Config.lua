--[[
    ProjectJaina_Companion — Config.lua
    Configuración y constantes del hub social.
    Compatible: WoW 3.3.5a (Build 12340) | Lua 5.1
]]

ProjectJaina_Companion = ProjectJaina_Companion or {}
local C = ProjectJaina_Companion

C.Config = {
    Version         = "2.0.0",
    AnnounceChannel = "GROUP",   -- GROUP | PARTY | SAY | OFF ("")
    Debug           = false,

    -- Addons del ecosistema a detectar
    EcosystemAddons = {
        { name = "ProjectJaina_LoreHUD",        label = "LoreHUD",        color = "FF69B4FF" },
        { name = "Carbonite",                   label = "Carbonite",      color = "FF00E5FF" },
        { name = "ProjectJaina_BattlePass",     label = "BattlePass",     color = "FFD4AF37" },
        { name = "ProjectJaina_Companion",      label = "Companion",      color = "FFAB47BC" },
        { name = "ProjectJaina_GameModes",      label = "GameModes",      color = "FF4FC3F7" },
        { name = "ProjectJaina_MultiBot",       label = "MultiBot",       color = "FF00FFCC" },
        { name = "ProjectJaina_RaidSuite",      label = "RaidSuite",      color = "FF81C784" },
        { name = "ProjectJaina_Store",          label = "Tienda",         color = "FFFFD100" },
        { name = "ProjectJaina_VisualShop",     label = "VisualShop",     color = "FFCE93D8" },
        { name = "ProjectJaina_Talented",       label = "Talented",       color = "FFF57C00" },
        { name = "ProjectJaina_Wardrobe",       label = "Wardrobe",       color = "FFE6C280" },
        { name = "ProjectJaina_Voice",          label = "Voz 3D",         color = "FF00CCFF" },
        { name = "ProjectJaina_DragonflightUI", label = "DragonflightUI", color = "FFE040FB" },
        { name = "ProjectJaina_Graphics",       label = "Graficos HD",    color = "FF80D8FF" },
        { name = "Chatter_Companion",           label = "Chatter LLM",    color = "FF00FFCC" },
        { name = "ProjectJaina_GMGenie",        label = "JainaGM Staff",  color = "FF00CCFF" },
    },

    -- Prefijo de red soberano
    AddonPrefix = "JAINA_COMP",
    LegacyPrefix = "WP_COMP",
}
