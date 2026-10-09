# 🤖 Reglas de Contexto y Memoria para Agentes de IA — ProjectJaina_Companion

> **Documento Maestro de Arquitectura y Memoria Operativa**  
> **Ámbito:** `d:\Project Jaina\Client\Interface\AddOns\ProjectJaina_Companion\`  
> **Líder del Proyecto:** DarckRovert (Ingame: `Elnazzareno`)  
> **Servidor Destino:** [Project Jaina](https://darckrovert.github.io/ProjectJaina_Web/) — Project Jaina  
> **Entorno de Ejecución:** World of Warcraft 3.3.5a (Build 12340) | Lua 5.1 puro  
> **Versión de Reglas:** 1.0.1 (Septiembre 2026)

---

## 1. Mapeo del Ecosistema de Addons

Este addon convive con los **5 sistemas oficiales** de Project Jaina:

| Addon / Sistema | Prefijo de Red | Función |
| :--- | :--- | :--- |
| **`ProjectJaina_Companion`** | `WP_COMP` | Hub social meta-ligero. Telemetría de grupo, badges de modo y anuncios de BattlePass. |
| **`ProjectJaina_BattlePass`** | `WP_BP` | Pase de Batalla Estacional (50 niveles). |
| **`ProjectJaina_GameModes`** | `WP_GAMEMODE` | Selector de modos de juego (Normal, Hardcore, Ironman). |
| **`ProjectJaina_RaidSuite`** | `WP_BP` (EcoBridge) / `Jaina` | Suite táctica de combate, loot y raids. |
| **`ProjectJaina_VisualShop`** | `WP_VISUAL` | Catálogo visual de alas, auras y títulos sincronizado. |

---

## 2. Leyes Inviolables de Arquitectura

Todo agente de IA o desarrollador debe cumplir obligatoriamente los siguientes principios:

### Ley I: Empirismo Estricto (Cero Suposiciones)
1. Antes de modificar cualquier archivo, es **obligatorio** inspeccionar el archivo localmente con `view_file` o `grep_search`.
2. Prohibido asumir que existen funciones de clientes modernos (MoP, Legion, Retail) o librerías externas.

### Ley II: Restricciones Inmutables de WoW 3.3.5a (Build 12340)
1. **Motor Lua:** Lua 5.1 puro. Sin operadores ni funciones de Lua 5.2+.
2. **Texturas Sólidas:** No existe `Texture:SetColorTexture()`. Usar siempre:
   ```lua
   tex:SetTexture("Interface\\Buttons\\WHITE8X8")
   tex:SetVertexColor(r, g, b, a)
   ```
3. **Registro de Prefijos:** `RegisterAddonMessagePrefix` debe invocarse de forma defensiva:
   ```lua
   if RegisterAddonMessagePrefix then
       RegisterAddonMessagePrefix("WP_COMP")
   end
   ```
4. **Eventos de Grupo:** `GROUP_ROSTER_UPDATE` NO EXISTE en 3.3.5a. Usar `RAID_ROSTER_UPDATE` y `PARTY_MEMBERS_CHANGED`.
5. **Detección de Grupo:** No usar `IsInRaid()` ni `IsInGroup()`. Usar `(GetNumRaidMembers() > 0)` y `(GetNumPartyMembers() > 0)`.

### Ley III: Presupuesto de Red y Límite de 255 Bytes
1. Prohibido emitir payloads superiores a 200 bytes por `SendAddonMessage`.
2. El formato `WP_ADDONS:<lista>|<MODO>` debe mantenerse compacto.

### Ley IV: Rendimiento para Cabinas de Internet (Low-End PC)
1. **Sin Creación de Tablas en Tickers:** Reutilizar estructuras para evitar trabajo al recolector de basura (GC).
2. **Intervalo Ticker:** Mantener el ticker defensivo en 5 segundos (`tickElapsed >= 5`).
3. **Resiliencia ante Limpieza de WTF:** Siempre contar con fallback de escaneo de auras de servidor (`UnitAura`) para identificar modos Hardcore/Ironman si se borra la carpeta `WTF/`.

---

## 3. Checklist Pre-Commit

1. `python Tests/validate_companion.py`: 100% aprobado.
2. Cero fugas de APIs de Retail o eventos post-WotLK.
3. Payload de red de `WP_COMP` inferior a 120 bytes.
4. Mensajes de `SendChatMessage` limpios de secuencias `|c`.
