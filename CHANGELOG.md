# 📋 Registro de Cambios — ProjectJaina_Companion

Todos los cambios notables de este proyecto están documentados en este archivo siguiendo el estándar [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/).

---

## [2.0.0] — 2026-10-14
### Barra de Control Táctico de Playerbots, Menú de Reclutamiento y Keybindings Nativos
- **Barra Flotante Táctica:** Incorporada barra móvil con botones directos: Seguir (Follow), Alto (Stay), Atacar (Attack), Auto-Pull de Tanque (Pull), Pasivo (Passive), Reclutar Bot (Recruit) y Reequipar (Regear).
- **Menú Contextual de Roles:** Acceso directo para reclutar por rol (Tanque, Sanador, DPS) y formaciones de banda (Grupo 5-man, Banda 10-man, Banda 25-man) con teletransporte automático del maestro.
- **Keybindings Nativos (Bindings.xml):** Registro formal en la interfaz de atajos de teclado de Blizzard para todas las órdenes tácticas con CERO TAINT.
- **Comandos de Consola:** Añadidos atajos de barra `/jainabot`, `/jainacompanion` y `/botbar`.
- **Integración con Ecosistema:** Integrada opción directa de alternar la barra táctica desde el menú `/companion`.

---

## [1.0.1] — 2026-10-10
### Estabilización de Ecosistema y Gobernanza Oficial (Project Jaina)
- **Normalización de UI y Gráficos:** Erradicación de tormentas de paquetes en entrada a grupo/banda mediante jitter pseudo-aleatorio (0.1s - 0.4s), supresión de eco y protección contra desincronización en Deep Freeze.
- **Homologación Documental:** Incorporación y actualización formal de `GOVERNANCE.md`, `LICENSE`, `NOTICE.md` y `SECURITY.md`.
- **Licencia Canónica:** Consolidación de licencia MIT 2026 bajo titularidad de DarckRovert & Project Jaina Team.
- **Validación de Runtime:** Verificado al 100% con compilador sintáctico `lua52_compiler.exe -p` con 0 errores y 0 warnings.

---

## [1.0.0] — 2026-10-04
### Lanzamiento Inicial — Ecosistema Project Jaina WotLK 3.3.5a
- Implementación de la arquitectura base para Project Jaina Companion.
- Registro de comandos slash: `/companion, /pjc`.
- Persistencia de configuración en `ProjectJaina_CompanionDB`.
- Compatibilidad certificada con cliente WotLK 3.3.5a (Build 12340) y directiva `Interface: 30300`.
