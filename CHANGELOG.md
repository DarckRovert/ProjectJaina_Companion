# 📋 Registro de Cambios — ProjectJaina_Companion

Todos los cambios notables de este proyecto están documentados en este archivo siguiendo el estándar [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/).

---

## [2.2.0] — 2026-10-24
### Telemetría de Clanes de Bots y Venganza de Hermandad ("Ojo por Ojo")
- **Telemetría de Vendettas (`/pjc vendettas` / `/vendetta`):** Incorporada consulta de estado de cacerías de sangre de cofradías de bots contra el jugador tras matar a un bot en PvP de mundo abierto.
- **Soporte de Atajos Oficiales:** Añadidos `/companion` y `/vendetta` a la lista de comandos slash nativos.
- **Documentación de Cofradías Autónomas:** Visualización de las 6 hermandades de bots (<La Cofradía de la Espada Negra>, <Los Centinelas de la Aurora>, <Pacto de Sangre de Kalimdor>, <El Sindicato de Trinquete>, <Custodios de los Arcanos>, <Hijos del Invierno>) y sus reglas militares de cierre (1 muerte o 15 minutos).

---

## [2.1.0] — 2026-10-24
### Foco Táctico de Escuadrón, Recuperación de Wipe y Expansión de Barra Táctica
- **Foco Táctico de Escuadrón (`+focus,attack` / Calavera):** Añadido botón y comando `/pjc focus` / `/botbar focus` que marca el objetivo actual con calavera (Icono de Banda 8) y ordena a todos los bots concentrar fuego y asistencia táctica.
- **Recuperación y Sincronización de Wipe en Mazmorras (`.rdf revive`):** Añadido botón y atajos `/pjc revive` / `/pjc sync` para reanimar y teletransportar al escuadrón caído o desfasado directo a la posición del líder.
- **Expansión de Barra Táctica:** Rediseño responsivo de 7 a 9 botones (318px de ancho) con tooltips descriptivos de alta fidelidad.
- **Keybindings Nativos (`Bindings.xml`):** Registrados atajos de teclado oficiales en la interfaz de Blizzard para `Bots: Concentrar Fuego` y `Bots: Reanimar / Sincronizar Escuadrón`.
- **Soporte de Atajo Rápido:** Incorporado `/pjc` a la lista oficial de comandos de consola del AddOn.

---

## [2.0.1] — 2026-10-24
### Corrección de Protocolo P2P y Registro de Ecosistema
- **Registro de Ecosistema (`Config.lua`):** Incorporado `ProjectJaina_Store` a `C.Config.EcosystemAddons` con clave `store`, nombre `ProjectJaina_Store` y label `Tienda`, garantizando su sincronización y broadcast entre compañeros.
- **Protocolo de Red P2P (`Core.lua`):** Aislamiento estricto del analizador de paquetes `OnAddonMessage` para ignorar secuencias ajenas de formato `STATUS:NONE:1:1` de `ProjectJaina_GameModes`, previniendo colisiones de red e interpretaciones erróneas de estado.

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
