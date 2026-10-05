# 📜 Aviso Legal y Atribución — WoWPeru_Companion

Este repositorio forma parte del ecosistema oficial de **WoW Perú - Reino Andino**.
Contiene el hub social meta-ligero, sincronización de modos de juego y comandos cross-faction para World of Warcraft 3.3.5a (Build 12340).

---

## 1. Autoría y Desarrollo Oficial
* **Desarrollador Principal:** DarckRovert (Ingame: `Elnazzareno`) & WoW Perú Team
* **Ecosistema:** [WoW Perú — Reino Andino](https://wow-peru.lat/)
* **Repositorio Oficial:** [DarckRovert/WoWPeru_Companion](https://github.com/DarckRovert/WoWPeru_Companion)

---

## 2. Inmunidad a Taint y Filosofía Cross-Faction
* **Comandos Nativos:** `/comerciar` y `/invitar` interactúan con las funciones nativas `InitiateTrade` e `InviteUnit`.
* **Aislamiento Total de FrameXML:** Este módulo **NO modifica ni engancha (hook)** la tabla global `UnitPopupMenus` de Blizzard. Esto garantiza inmunidad absoluta contra errores de interfaz bloqueada (taint) en menús contextuales, asignación de focos y addons de curación (`HealBot`, `Grid`).
* **Compatibilidad de Servidor:** Diseñado para servidores AzerothCore con `AllowTwoSide.Interaction.Group = 1`.

---

## 3. Cumplimiento de Políticas de Interfaz
En estricto cumplimiento de la Política de Interfaz de Usuario Personalizada de Blizzard (Blizzard Custom UI Policy):
1. Este software es de distribución libre y sin fines comerciales.
2. Toda la telemetría se restringe a canales locales de grupo/banda (`PARTY`, `RAID`) bajo el prefijo `WP_COMP`.
