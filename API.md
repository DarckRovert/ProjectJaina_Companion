# 💻 Especificación de API y Red — ProjectJaina_Companion

Documento técnico de arquitectura de software y protocolo de red para desarrolladores y addons integrados en el ecosistema **Project Jaina**.

---

## 1. Namespace Global

El addon expone un único namespace global en el entorno Lua del cliente:

```lua
ProjectJaina_Companion = {
    Config = {
        Version          = "1.0.1",
        AnnounceChannel  = "GROUP",   -- "GROUP" | "PARTY" | "SAY" | ""
        Debug            = false,
        EcosystemAddons  = { ... },
        AddonPrefix      = "WP_COMP",
    }
}
```

---

## 2. Protocolo de Telemetría P2P (`JAINA_COMP` / `WP_COMP`)

### Prefijos Registrados
- **Primario:** `JAINA_COMP` (Legacy retrocompatible: `WP_COMP`, con deduplicación anti-eco de `0.30s`).
- **Registro:** Se realiza defensivamente mediante `RegisterAddonMessagePrefix`.

### Formato de Paquete Saliente (Broadcast y Fragmentación <= 220B)
Los paquetes viajan a través de los canales protegidos `RAID` o `PARTY` invocando `SendAddonMessage`:

**Estructura Estándar (`<= 220 bytes`):**
```
JAINA_ADDONS:<addon_label_1>,<addon_label_2>,...|<GAME_MODE>
```

**Estructura Fragmentada (`> 220 bytes`):**
```
JAINA_ADDONS_P:<idx>/<total>:<chunk>|<GAME_MODE>
```

**Parámetros:**
- `addon_label_n`: Etiquetas de addons detectados localmente (`LoreHUD`, `BattlePass`, `Companion`, `GameModes`, `RaidSuite`, `VisualShop`, `Polyglot`, `MemoryGuard`, etc.).
- `GAME_MODE`: Modalidad normalizada mediante `NormalizeGameMode` (`NORMAL`, `HARDCORE`, `IRONMAN`, `DIE_AND_RISE`, `SLOW_X1`).

**Ejemplos de Payload:**
- Jugador con todo el ecosistema en Hardcore:
  ```
  WP_ADDONS:BattlePass,Companion,GameModes,LoreHUD,RaidSuite,VisualShop|HARDCORE
  ```
  *Longitud:* 77 bytes (Consumo de buffer: 30% del límite de 255 bytes).
- Jugador únicamente con Companion en Reto x1:
  ```
  WP_ADDONS:Companion|SLOW_X1
  ```
  *Longitud:* 27 bytes.

---

## 3. Escucha de Eventos de Otros Addons

`ProjectJaina_Companion` escucha pasivamente los prefijos de red de otros sistemas para enriquecer la experiencia social sin generar acoplamiento directo:

### Prefijo `WP_BP` (ProjectJaina_BattlePass)
- Escucha paquetes entrantes `BP_RES_XP` y `BP_RES_SYNC`.
- Acelera el ticker de sincronización interno (`tickElapsed = TICK_INTERVAL - 0.1`) para garantizar que la felicitación comunitaria se lance inmediatamente después de que el BattlePass termine de procesar la respuesta del servidor Eluna.

---

## 4. Consulta Externa de Estado

Otros addons pueden consultar si `ProjectJaina_Companion` está activo o inspeccionar su configuración mediante comprobaciones estándar:

```lua
if _G.ProjectJaina_Companion then
    local comp = _G.ProjectJaina_Companion
    local version = comp.Config and comp.Config.Version
    -- Companion está activo en el cliente
end
```

---

## 5. Persistencia (`SavedVariables`)

- **Variable Global:** `Project JainaCompanion_DB`
- Se inicializa en el evento `ADDON_LOADED` al confirmarse la carga de `ProjectJaina_Companion`.
- Almacena personalizaciones del jugador (preferencias de canal de anuncio, toggle de depuración).
