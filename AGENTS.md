# 🤖 Reglas de Agente IA — WoWPeru_Companion

> **Ámbito:** `d:\WoW Peru\Client\Interface\AddOns\WoWPeru_Companion\`
> **Versión:** 1.0.0

## Propósito del Addon

Hub social de 5 KB. **NO tiene lógica de servidor Eluna.** Todo es lado cliente.

## Restricciones Críticas

1. **NO añadir lógica de juego:** Este addon es solo social/informativo. No debe afectar la jugabilidad.
2. **Ticker OnUpdate:** El intervalo es de 5s. No reducirlo por debajo de 3s (CPU en cabinas de internet).
3. **Sin disco:** No añadir llamadas a la base de datos ni `CharDBExecute`.
4. **Prefix WP_COMP:** Reservado exclusivamente para este addon. No reutilizarlo en otros sistemas.
5. **Dependency guard:** Todo acceso a APIs de otros addons debe ir precedido de verificación de existencia:
   ```lua
   if WoWPeru_BattlePass and WoWPeru_BattlePass.Data then ... end
   ```

## Archivos del Addon

| Archivo | Propósito |
|---|---|
| `Config.lua` | Constantes, lista de addons del ecosistema, configuración de anuncio |
| `Core.lua` | Motor: broadcast, detección, anuncio de level-up, comandos slash |

## API Pública (lectura)

- `WoWPeru_Companion.Config` — Configuración editable por el jugador
- `WoWPeru_Companion` — Namespace global del addon
