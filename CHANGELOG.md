# 📋 Changelog — WoWPeru_Companion

## [1.0.0] - 2026-09-28

### 🎉 Lanzamiento Oficial

Hub social ligero del ecosistema WoW Perú. Primer addon del tipo "meta-social" de WoW Perú.

### ✨ Funcionalidades
- **Detección de addons activos** en el grupo via `CHAT_MSG_ADDON` (prefijo `WP_COMP`)
- **Badge de modo de juego** (`HARDCORE`/`IRONMAN`/`Normal`) para cada jugador del grupo
- **Anuncio de level-up** en el canal GROUP cuando el personaje local sube de nivel en BattlePass
- **Ticker defensivo** cada 5 segundos (OnUpdate + elapsed acumulado) para evitar spam de API
- **Comandos:** `/companion`, `/companion scan`, `/companion debug`
- **Broadcast automático** al unirse al grupo (`GROUP_ROSTER_UPDATE`) con delay de 2s anti-race
