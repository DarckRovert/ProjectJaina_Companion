# ❄️ Project Jaina — Companion (v1.0.3)

**Versión:** 1.0.3 (WotLK Hardened Edition)  
**Autor:** DarckRovert (Ingame: `Elnazzareno`) & Antigravity (Mythos 5)  
**Servidor Destino:** [Project Jaina](https://darckrovert.github.io/ProjectJaina_Web/) — Project Jaina  
**Entorno de Ejecución:** World of Warcraft 3.3.5a (Build 12340) | Lua 5.1 puro  
**Repositorio Oficial:** [DarckRovert/ProjectJaina_Companion](https://github.com/DarckRovert/ProjectJaina_Companion)

---

[![WoW Client](https://img.shields.io/badge/WoW%20Client-3.3.5a%20(Build%2012340)-blue.svg)](https://darckrovert.github.io/ProjectJaina_Web/)
[![Servidor](https://img.shields.io/badge/Servidor-Project%20Jaina-00ccff.svg)](https://darckrovert.github.io/ProjectJaina_Web/)
[![Version](https://img.shields.io/badge/version-1.0.3-brightgreen.svg)](https://github.com/DarckRovert/ProjectJaina_Companion/releases)
[![Build Status](https://img.shields.io/badge/CI-Passing-success.svg)](https://github.com/DarckRovert/ProjectJaina_Companion/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 🌟 ¿Qué es ProjectJaina_Companion?

**ProjectJaina_Companion** es el **hub social meta-ligero** (~5 KB en disco, < 100 KB de memoria RAM) del ecosistema oficial de addons de **Project Jaina**. Funciona como el puente de telemetría y reconocimiento mutuo entre los jugadores del Project Jaina dentro de grupos de mazmorra y bandas de raid.

A diferencia de los sistemas pesados, `ProjectJaina_Companion` opera 100% en el lado del cliente sin sobrecargar el servidor Eluna, permitiendo que los miembros de un grupo descubran al instante qué herramientas del servidor tienen instaladas sus compañeros, en qué modo de juego compiten (Normal, Hardcore o Ironman) y celebrando automáticamente en el chat de grupo cada vez que un miembro sube de nivel en el Pase de Batalla estacional.

```
┌────────────────────────────────────────────────────────────────────────┐
│                   ARQUITECTURA DE TELEMETRÍA SOCIAL                    │
├────────────────────────┬──────────────────────┬────────────────────────┤
│ 🛰️ AUTO-DISCOVERY      │ 🛡️ BADGE DE MODO     │ 📢 ANUNCIADOR BP       │
│ Detección P2P vía      │ Normal, Hardcore,    │ Notifica level-ups de  │
│ canal CHAT_MSG_ADDON   │ Ironman con fallback │ BattlePass al grupo    │
│ (Prefijo: WP_COMP)     │ por auras en cabinas │ sin spam de filtros    │
└────────────────────────┴──────────────────────┴────────────────────────┘
```

---

## 🚀 Funcionalidades Principales

### 1. 🔍 Auto-Discovery de Addons en Grupo y Banda
- Al unirse a un grupo (`PARTY_MEMBERS_CHANGED` / `RAID_ROSTER_UPDATE`), emite un broadcast asíncrono con retardo anti-concurrencia de 2 segundos.
- Detecta en tiempo real la presencia de:
  - 🏆 **`ProjectJaina_BattlePass`**: Pase de Batalla Estacional.
  - ⚔️ **`ProjectJaina_GameModes`**: Selector y validador de Hardcore/Ironman.
  - 🛡️ **`ProjectJaina_RaidSuite`**: Plataforma táctica de combate y loot.
  - 👗 **`ProjectJaina_VisualShop`**: Catálogo cosmético de alas, auras y títulos.
  - 🤝 **`ProjectJaina_Companion`**: Hub de telemetría social.

### 2. 🛡️ Detección Resiliente de Modos de Juego (Cabina-Ready)
- Consulta la base local de `ProjectJaina_GameModes_CharDB`.
- **Mecanismo Fallback de Supervivencia:** Si la máquina de la cabina de internet reinicia la carpeta `WTF/` (congeladores como Deep Freeze), el addon escanea las auras activas del jugador (`UnitAura`) para identificar buffs de `"hardcore"` o `"ironman"`, garantizando que el badge nunca desaparezca ni muestre datos erróneos.

### 3. 📢 Anunciador de Hitos de Pase de Batalla
- Monitorea los eventos de red `BP_RES_XP` y `BP_RES_SYNC` del prefijo `WP_BP`.
- Al alcanzar un nuevo nivel, anuncia automáticamente en el canal de grupo (`PARTY` o `RAID`) la felicitación comunitaria.
- **Sanitización de Chat:** Los mensajes enviados vía `SendChatMessage` están completamente libres de códigos de escape `|c`, evitando que el filtro anti-spam del cliente 3.3.5a o del emulador bloquee la difusión.

### 4. ⚡ Rendimiento Cero-Impacto (Low-End PC)
- **Zero GC Pressure:** Reutiliza tablas internas de sesión sin instanciar tablas temporales repetitivas en cada tick.
- **Ticker Defensivo:** Ticker espaciado de 5 segundos con delta time (`elapsed`), eliminando el consumo innecesario de ciclos de CPU en equipos antiguos.

---

## 🌐 Protocolo de Red (`WP_COMP`)

La comunicación entre clientes opera de manera transparente usando el canal interno de addons de World of Warcraft:

| Parámetro | Especificación |
|---|---|
| **Prefijo de Red** | `WP_COMP` (registrado defensivamente) |
| **Canales de Difusión** | `PARTY` / `RAID` |
| **Formato del Payload** | `WP_ADDONS:<ListaSeparadaPorComas>|<MODO>` |
| **Ejemplo de Payload** | `WP_ADDONS:BattlePass,RaidSuite,VisualShop|HARDCORE` |
| **Presupuesto de Red** | Promedio: 48 bytes \| Límite: < 120 bytes (Presupuesto máximo 3.3.5a: 255 bytes) |

---

## ⌨️ Comandos Disponibles

| Comando | Alias | Descripción |
|---|---|---|
| `/companion` | `/wpcomp`, `/companion status` | Despliega en el chat local el resumen de addons y modos de los miembros del grupo. |
| `/companion scan` | `/wpcomp scan` | Fuerza un broadcast manual inmediato y solicita telemetría a los compañeros. |
| `/companion channel <chan>` | `/wpcomp channel` | Configura el canal de felicitación de BattlePass (`group`, `party`, `say`, `off`). |
| `/companion debug` | `/wpcomp debug` | Activa o desactiva la salida de depuración en tiempo real en la consola de chat. |
| `/comerciar` | `/comercio` | Inicia comercio seguro con el objetivo seleccionado (incluso entre Alianza y Horda). |
| `/invitar <Nombre>` | — | Invita a grupo a un jugador de cualquier facción sin contaminar la UI de Blizzard (CERO TAINT). |

---

## 📂 Estructura del Repositorio

```
ProjectJaina_Companion/
├── .github/
│   └── workflows/
│       └── ci.yml               # Pipeline de integración continua GitHub Actions
├── Tests/
│   └── validate_companion.py    # Suite de auditoría sintáctica y compatibilidad 3.3.5a
├── .gitignore                   # Exclusiones de Git
├── AGENTS.md                    # Reglas operativas para Agentes de IA y desarrolladores
├── API.md                       # Especificación técnica de integración y hooks
├── CHANGELOG.md                 # Historial detallado de cambios y versiones
├── Config.lua                   # Configuración del ecosistema, canales y colores
├── Core.lua                     # Motor de red, eventos, comandos y ticker
├── ECOSYSTEM_REGISTRY.md        # Ficha técnica oficial del ecosistema Project Jaina
├── INSTALL.md                   # Guía de instalación y solución de problemas
├── LICENSE                      # Licencia MIT
├── README.md                    # Documento maestro informativo
├── SECURITY.md                  # Políticas de seguridad e integridad de red
└── ProjectJaina_Companion.toc        # Metadatos del cliente WoW 3.3.5a
```

---

## 🔧 Compatibilidad y Requisitos

- **Cliente WoW:** 3.3.5a (Build 12340).
- **Motor Lua:** Lua 5.1 puro (sin sintaxis ni APIs de Cataclysm/MoP/Retail).
- **Servidor:** AzerothCore / TrinityCore con soporte para Project Jaina - Project Jaina.
- **Addons Opcionales (Sinérgicos):**
  - [ProjectJaina_BattlePass](https://github.com/DarckRovert/ProjectJaina_BattlePass)
  - [ProjectJaina_GameModes](https://github.com/DarckRovert/ProjectJaina_GameModes)
  - [ProjectJaina_RaidSuite](https://github.com/DarckRovert/ProjectJaina_RaidSuite)
  - [ProjectJaina_VisualShop](https://github.com/DarckRovert/ProjectJaina_VisualShop)

---

## 🛡️ Licencia

Distribuido bajo la Licencia **MIT**. Consulta [`LICENSE`](LICENSE) para más información.

**Desarrollado con dedicación para la comunidad de [Project Jaina](https://darckrovert.github.io/ProjectJaina_Web/) — Project Jaina.**
