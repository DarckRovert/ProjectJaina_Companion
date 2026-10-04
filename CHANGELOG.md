# 📋 Registro de Cambios (Changelog) — WoWPeru_Companion

Todas las modificaciones notables de este proyecto están documentadas en este archivo siguiendo [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/) y respetando [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.2] - 2026-10-04

### 🌐 Sincronización P2P y Mitigación de Colisiones (Fix #1)
- **Handshake P2P Bidireccional (`Core.lua`):**
  - Implementado protocolo de descubrimiento bidireccional mediante `WP_SCAN_REQ` y respuesta `WP_SCAN_RES`.
  - Agregado jitter aleatorio anti-colisión en la respuesta para evitar ráfagas simultáneas de paquetes de chat de addon cuando varios clientes ingresan al grupo/banda al mismo tiempo.
  - Sincronización reactiva inmediata con `WoWPeru_GameModes` eliminando condiciones de carrera en cabinas de internet.

---

## [1.0.1] - 2026-09-28

### 🛡️ Blindaje y Compatibilidad WotLK 3.3.5a (Build 12340)
- **Corrección de Eventos Retail:** Reemplazado el evento inexistente `GROUP_ROSTER_UPDATE` (introducido en MoP 5.0.4) por los eventos nativos de WotLK 3.3.5a: `RAID_ROSTER_UPDATE` y `PARTY_MEMBERS_CHANGED`.
- **Detección Defensiva de Grupos:** Reemplazadas las llamadas a `IsInRaid()` e `IsInGroup()` (incompatibles en 3.3.5a sin polyfills) por chequeos seguros directos contra `GetNumRaidMembers() > 0` y `GetNumPartyMembers() > 0`.
- **Resiliencia de Cabinas de Internet (WTF Reset Safe):** Implementado un escaneo de emergencia en `GetLocalGameMode()` mediante `UnitAura("player", i)` buscando auras activas de `"hardcore"` o `"ironman"`. Esto asegura que los jugadores en cabinas con congeladores de disco (Deep Freeze) mantengan su badge correcto incluso si la carpeta `WTF/` se borra al reiniciar.
- **Sanitización de Chat en Difusiones:** Eliminados los códigos de formato de color (`|cFF...|r`) en los mensajes emitidos por `SendChatMessage`, evitando que se rendericen como texto plano sucio o sean descartados por filtros anti-spam del servidor.
- **Defensiva de Registro de Prefijos:** Asegurado el chequeo previo `if RegisterAddonMessagePrefix then` para compatibilidad universal con diferentes versiones de ejecutables 3.3.5a.

### 🧪 Automatización y Calidad
- **Suite de Pruebas Automatizada:** Añadido `Tests/validate_companion.py` para validar la existencia física de archivos listados en el `.toc`, el balance sintáctico exacto de Lua 5.1 (`depth balance = 0`) y la ausencia de APIs prohibidas de Retail.
- **Pipeline CI/CD:** Añadido workflow de GitHub Actions `.github/workflows/ci.yml` ejecutando validación sobre Python 3.11 en cada push a `main`.
- **Control de Versiones:** Añadido `.gitignore` oficial para entornos de desarrollo WoW WotLK.

---

## [1.0.0] - 2026-09-28

### 🎉 Lanzamiento Inicial
- **Hub Social Meta-Ligero:** Addon cliente de telemetría de ~5 KB para el ecosistema WoW Perú.
- **Auto-Discovery P2P:** Detección automática de addons activos entre miembros del grupo mediante mensajes de addon `CHAT_MSG_ADDON` con prefijo `WP_COMP`.
- **Badge de Modo de Juego:** Detección de modalidades Hardcore, Ironman y Normal con lectura de `WoWPeru_GameModes_CharDB`.
- **Anunciador de BattlePass:** Detección comunitaria de subida de nivel de Pase de Batalla estacional vía hooks al prefijo `WP_BP` (`BP_RES_XP`, `BP_RES_SYNC`).
- **Comandos Slash:** Implementación de `/companion`, `/wpcomp`, `/companion scan` y `/companion debug`.
- **Ticker Liviano:** Ticker de 5 segundos con acumulador `elapsed` para no generar impacto en la tasa de cuadros (60 FPS en hardware legacy).
