# 🌐 Registro de Ecosistema — WoWPeru_Companion

Ficha técnica oficial de registro en la infraestructura multi-addon de **WoW Perú - Reino Andino**.

---

## 1. Identidad del Addon

| Campo | Valor |
|---|---|
| **Nombre Técnico** | `WoWPeru_Companion` |
| **Título en Cliente** | `|cFFD4AF37WoW Perú|r - Companion` |
| **Versión** | `1.0.3` |
| **Tipo de Sistema** | Hub Social Meta-Ligero & Cross-Faction (Client-Side Only) |
| **Repositorio GitHub** | [DarckRovert/WoWPeru_Companion](https://github.com/DarckRovert/WoWPeru_Companion) |
| **Directorio de Instalación** | `Interface\AddOns\WoWPeru_Companion\` |

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
