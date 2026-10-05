# 🇵🇪 WoW Perú — Companion (v1.0.2)

**Versión:** 1.0.2 (WotLK Hardened Edition)  
**Autor:** DarckRovert (Ingame: `Elnazzareno`) & WoW Perú Team  
**Servidor Destino:** [WoW Perú](https://wow-peru.lat/) — Reino Andino  
**Entorno de Ejecución:** World of Warcraft 3.3.5a (Build 12340) | Lua 5.1 puro  
**Repositorio Oficial:** [DarckRovert/WoWPeru_Companion](https://github.com/DarckRovert/WoWPeru_Companion)

---

[![WoW Client](https://img.shields.io/badge/WoW%20Client-3.3.5a%20(Build%2012340)-blue.svg)](https://wow-peru.lat/)
[![Servidor](https://img.shields.io/badge/Servidor-WoW%20Perú-gold.svg)](https://wow-peru.lat/)
[![Version](https://img.shields.io/badge/version-1.0.2-brightgreen.svg)](https://github.com/DarckRovert/WoWPeru_Companion/releases)
[![Build Status](https://img.shields.io/badge/CI-Passing-success.svg)](https://github.com/DarckRovert/WoWPeru_Companion/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 🌟 ¿Qué es WoWPeru_Companion?

**WoWPeru_Companion** es el **hub social meta-ligero** (~5 KB en disco, < 100 KB de memoria RAM) del ecosistema oficial de addons de **WoW Perú**. Funciona como el puente de telemetría y reconocimiento mutuo entre los jugadores del Reino Andino dentro de grupos de mazmorra y bandas de raid.

A diferencia de los sistemas pesados, `WoWPeru_Companion` opera 100% en el lado del cliente sin sobrecargar el servidor Eluna, permitiendo que los miembros de un grupo descubran al instante qué herramientas del servidor tienen instaladas sus compañeros, en qué modo de juego compiten (Normal, Hardcore o Ironman) y celebrando automáticamente en el chat de grupo cada vez que un miembro sube de nivel en el Pase de Batalla estacional.

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
  - 🏆 **`WoWPeru_BattlePass`**: Pase de Batalla Estacional.
  - ⚔️ **`WoWPeru_GameModes`**: Selector y validador de Hardcore/Ironman.
  - 🛡️ **`WoWPeru_RaidSuite`**: Plataforma táctica de combate y loot.
  - 👗 **`WowPeruVisualShop`**: Catálogo cosmético de alas, auras y títulos.
  - 🤝 **`WoWPeru_Companion`**: Hub de telemetría social.

### 2. 🛡️ Detección Resiliente de Modos de Juego (Cabina-Ready)
- Consulta la base local de `WoWPeru_GameModes_CharDB`.
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

---

## 📂 Estructura del Repositorio

```
WoWPeru_Companion/
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
├── ECOSYSTEM_REGISTRY.md        # Ficha técnica oficial del ecosistema WoW Perú
├── INSTALL.md                   # Guía de instalación y solución de problemas
├── LICENSE                      # Licencia MIT
├── README.md                    # Documento maestro informativo
├── SECURITY.md                  # Políticas de seguridad e integridad de red
└── WoWPeru_Companion.toc        # Metadatos del cliente WoW 3.3.5a
```

---

## 🔧 Compatibilidad y Requisitos

- **Cliente WoW:** 3.3.5a (Build 12340).
- **Motor Lua:** Lua 5.1 puro (sin sintaxis ni APIs de Cataclysm/MoP/Retail).
- **Servidor:** AzerothCore / TrinityCore con soporte para WoW Perú - Reino Andino.
- **Addons Opcionales (Sinérgicos):**
  - [WoWPeru_BattlePass](https://github.com/DarckRovert/WoWPeru_BattlePass)
  - [WoWPeru_GameModes](https://github.com/DarckRovert/WoWPeru_GameModes)
  - [WoWPeru_RaidSuite](https://github.com/DarckRovert/WoWPeru_RaidSuite)
  - [WowPeruVisualShop](https://github.com/DarckRovert/WowPeruVisualShop)

---

## 🛡️ Licencia

Distribuido bajo la Licencia **MIT**. Consulta [`LICENSE`](LICENSE) para más información.

**Desarrollado con dedicación para la comunidad de [WoW Perú](https://wow-peru.lat/) — Reino Andino.**
