# 🌐 Registro de Ecosistema — WoWPeru_Companion

## Prefijo de Red

| Prefijo | Canal | OpCodes |
|---|---|---|
| `WP_COMP` | `RAID` / `PARTY` | `WP_ADDONS:<labels>|<MODE>` |

**Formato payload:** `WP_ADDONS:BattlePass,RaidSuite|HARDCORE`
**Longitud máxima:** < 120 bytes (muy por debajo del límite de 255 bytes de 3.3.5a)

## SavedVariables

| Variable | Tipo | Propósito |
|---|---|---|
| `WoWPeruCompanion_DB` | Tabla global | Configuración persistente del addon |

## Dependencias del Ecosistema

| Addon | Tipo de dependencia | Cómo se usa |
|---|---|---|
| `WoWPeru_BattlePass` | Opcional (lectura) | Lee `WoWPeru_BattlePass.Data.level` para detectar level-up |
| `WoWPeru_GameModes` | Opcional (lectura) | Lee `WoWPeru_GameModes_CharDB.selectedMode` para badge de modo |
| `WoWPeru_RaidSuite` | Opcional (detección) | Solo detecta si está cargado via `IsAddOnLoaded` |
| `WowPeruVisualShop` | Opcional (detección) | Solo detecta si está cargado via `IsAddOnLoaded` |

## Compatibilidad

- WoW 3.3.5a (Build 12340) | Lua 5.1 puro
- `RegisterAddonMessagePrefix` llamado defensivamente
- Sin uso de `C_Timer`, `SetColorTexture` ni APIs de Retail/MoP
