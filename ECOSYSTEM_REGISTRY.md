# 🌐 Registro de Ecosistema — WoWPeru_Companion

Ficha técnica oficial de registro en la infraestructura multi-addon de **WoW Perú - Reino Andino**.

---

## 1. Identidad del Addon en el Ecosistema

| Campo | Valor |
|---|---|
| **Nombre Técnico** | `WoWPeru_Companion` |
| **Carpeta Local** | `WoWPeru_Companion` |
| **Versión Actual** | `1.0.3` |
| **Clasificación** | Cliente / Social |
| **Licencia Formal** | MIT |
| **Repositorio GitHub** | [WoWPeru_Companion](https://github.com/DarckRovert/WoWPeru_Companion) |
| **Entorno de Juego** | World of Warcraft 3.3.5a (Build 12340) / AzerothCore |

---

## 2. Red y Mensajería de Addon

| Propiedad | Valor |
|---|---|
| **Prefijo Oficial** | `WP_COMP` |
| **Canales de Red** | `PARTY`, `RAID` |
| **OpCodes Manejados** | `WP_ADDONS:<lista>|<MODO>` |
| **Prefijos Escuchados** | `WP_BP` (OpCodes: `BP_RES_XP`, `BP_RES_SYNC`) |
| **Presupuesto Máximo** | < 120 bytes (Límite protocolo: 255 bytes) |
| **Transporte Seguro** | Cero saturación; broadcast filtrado por retardo de 2s |

---

## 3. Persistencia de Datos

| Variable Global | Tipo | Ámbito | Propósito |
|---|---|---|---|
| `WoWPeruCompanion_DB` | Tabla Lua (`SavedVariables`) | Por Cuenta | Guarda preferencias del usuario (canal de anuncio, depuración) |

---

## 4. Matriz de Integración del Ecosistema

| Sistema Coexistente | Modo de Interacción | Flujo de Datos |
|---|---|---|
| **`WoWPeru_BattlePass`** | Lectura Pasiva / Event Hook | Lee `WoWPeru_BattlePass.Data.level` y escucha `WP_BP` para felicitar al jugador en chat de grupo al subir nivel. |
| **`WoWPeru_GameModes`** | Lectura de Estado / Auras | Lee `WoWPeru_GameModes_CharDB.selectedMode` con fallback a `UnitAura` ("hardcore", "ironman"). |
| **`WoWPeru_RaidSuite`** | Detección P2P | Detecta estado cargado y sincroniza presencia en el grupo. |
| **`WowPeruVisualShop`** | Detección P2P | Detecta estado cargado y sincroniza presencia en el grupo. |
| **`WoWPeru_LoreHUD`** | Detección P2P | Detecta HUD cinematográfico y eventos de interacción con LoreBots. |
| **`WoWPeru_Carbonite`** | Detección P2P | Detecta suite satelital HD de cartografía y navegación. |
| **`Talented`** | Detección P2P | Detección de presencia del simulador y gestor de talentos en el cliente. |
| **`Cross-Faction Core`** | Comandos Slash Nativos | `/comerciar` e `/invitar` comunican con el Core de AzerothCore sin alterar FrameXML. |

---

## 5. Garantías de Rendimiento

- **Tiempo de Cuadro:** < 0.01 ms por frame.
- **Memoria en Tiempo de Ejecución:** < 95 KB de memoria Lua.
- **Compatibilidad de Hardware:** 100% verificado para PCs de cabina con procesadores Dual-Core y gráficos integrados Intel HD.

---

## 🏛️ Directorio Maestro del Ecosistema WoW Perú (17 Repositorios)

### A. Módulos Oficiales del Cliente (`Client\Interface\AddOns\`)

| # | Repositorio GitHub | Carpeta Local | Versión | Tipo / Licencia | Propósito en el Ecosistema |
|:---:|---|---|:---:|:---:|---|
| 01 | [WoWPeru_AbbreviatedStatus](https://github.com/DarckRovert/WoWPeru_AbbreviatedStatus) | `AbbreviatedStatus` | 1.2.1 | MIT / Fork | Abreviación compacta y formateo legible de salud y maná sin división por cero. |
| 02 | [WoWPeru_BattlePass](https://github.com/DarckRovert/WoWPeru_BattlePass) | `WoWPeru_BattlePass` | 2.0.0 | MIT | Pase de Batalla estacional de 50 niveles con backend Eluna y bitmask de progreso. |
| 03 | [WoWPeru_Carbonite](https://github.com/DarckRovert/WoWPeru_Carbonite) | `WoWPeru_Carbonite` | 3.3.4-WP | Other / EULA | Suite satelital HD de cartografía, navegación multi-zona y misiones. |
| 04 | [WoWPeru_Companion](https://github.com/DarckRovert/WoWPeru_Companion) | `WoWPeru_Companion` | 1.0.3 | MIT | Hub social ligero, cross-faction (/comerciar, /invitar) y telemetría de grupo. |
| 05 | [WoWPeru_DragonflightUI](https://github.com/DarckRovert/WoWPeru_DragonflightUI) | `cDF` | 1.0.0 | MIT / BSD | Re-implementación visual moderna estilo Dragonflight 10.x para cliente 3.3.5a. |
| 06 | [WoWPeru_GameModes](https://github.com/DarckRovert/WoWPeru_GameModes) | `WoWPeru_GameModes` | 1.0.0 | MIT | Selector cinemático de modos (Normal, Hardcore, Ironman) con verificación Eluna. |
| 07 | [WoWPeru_GMGenie](https://github.com/DarckRovert/WoWPeru_GMGenie) | `GMGenie` | 1.3.1 | GPL-3.0 | Suite administrativa integral para Game Masters adaptada a AzerothCore. |
| 08 | [WoWPeru_IntiObjGPS](https://github.com/DarckRovert/WoWPeru_IntiObjGPS) | `IntiObjGPS` | 1.0.0 | MIT | Editor por lotes de coordenadas GPS de GameObjects para Staff y constructores. |
| 09 | [WoWPeru_LoreHUD](https://github.com/DarckRovert/WoWPeru_LoreHUD) | `LoreHUD` | 1.0.0 | MIT | Subtítulos cinemáticos inmersivos y telemetría narrativa para LoreBots. |
| 10 | [WoWPeru_PrideTrace](https://github.com/DarckRovert/WoWPeru_PrideTrace) | `WowPeruPrideTrace` | 1.0.0 | MIT | Diagnóstico de latencia de input, framerate y telemetría en vuelo. |
| 11 | [WoWPeru_RaidSuite](https://github.com/DarckRovert/WoWPeru_RaidSuite) | `WoWPeru_RaidSuite` | 11.2.1 | MIT / Comm. | Asistente de combate y combate táctico multiclase evolucionado de Sequito. |
| 12 | [WoWPeru_Talented](https://github.com/DarckRovert/WoWPeru_Talented) | `Talented` | 2.4.8 | GPL-2.0 / BSD | Editor integral de árboles de talentos, calculadoras de mascotas y glifos. |
| 13 | [WoWPeru_TBCBalance](https://github.com/DarckRovert/WoWPeru_TBCBalance) | `IntiTBCBalance` | 1.0.0 | MIT | Monitor privado de balance y composición de bandas TBC para Game Masters. |
| 14 | [WoWPeru_Wardrobe](https://github.com/DarckRovert/WoWPeru_Wardrobe) | `WoWPeru_Wardrobe` | 1.0.0 | MIT | Guardarropa, catálogo cosmético y transfiguración con backend Eluna (60_WardrobeSystem.lua). |
| 15 | [WowPeruVisualShop](https://github.com/DarckRovert/WowPeruVisualShop) | `WowPeruVisualShop` | 1.0.1 | MIT | Tienda oficial de efectos visuales, auras y alas con backend Eluna (59_SpellVisualCatalog.lua). |

### B. Suites Comunitarias Monorepositorio Pre-instaladas (`WoW_Peru_Lab\AddOns\`)

| # | Repositorio GitHub | Carpeta Local | Versión | Tipo / Licencia | Propósito en el Ecosistema |
|:---:|---|---|:---:|:---:|---|
| 16 | [WoWPeru_DBM](https://github.com/DarckRovert/WoWPeru_DBM) | `WoWPeru_DBM` | 4.52-WP | CC BY-NC-SA 3.0 | Suite unificada de 13 módulos Deadly Boss Mods para todas las raids y mazmorras WotLK. |
| 17 | [WoWPeru_GearScore](https://github.com/DarckRovert/WoWPeru_GearScore) | `WoWPeru_GearScore` | 3.1.16-WP | MIT / Comm. | Monorepositorio unificado de GearScore (3.1.16) y BonusScanner (5.3) sin dependencias rotas. |

---

## 📜 Principios de Gobernanza y Convivencia Arquitectónica

1. **Inmunidad a Taint:** Prohibido modificar o enganchar `UnitPopupMenus` de Blizzard para garantizar la estabilidad de menús contextuales y addons de curación (`HealBot`, `Grid`).
2. **Empirismo y Cero Suposiciones:** Todo cambio de protocolo o base de datos debe ser validado con inspección en disco y pruebas de red activas.
3. **Codificación Canónica:** Todo archivo de texto debe persistirse en **UTF-8 sin BOM** con saltos de línea estrictos **LF**.
4. **Preservación de Binarios:** Todos los assets multimedia (`.tga`, `.blp`, `.mp3`, `.ogg`, `.wav`, `.ttf`, `.m2`) se encuentran blindados mediante `.gitattributes` para evitar corrupción en transferencias Git.

