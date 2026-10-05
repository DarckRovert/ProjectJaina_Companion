# 💻 Especificación de API y Red — WoWPeru_Companion

Documento técnico de arquitectura de software y protocolo de red para desarrolladores y addons integrados en el ecosistema **WoW Perú**.

---

## 1. Namespace Global

El addon expone un único namespace global en el entorno Lua del cliente:

```lua
WoWPeru_Companion = {
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

## 2. Protocolo de Telemetría P2P (`WP_COMP`)

### Prefijo Registrado
- **Prefijo:** `WP_COMP`
- **Registro:** Se realiza defensivamente mediante:
  ```lua
  if RegisterAddonMessagePrefix then
      RegisterAddonMessagePrefix("WP_COMP")
  end
  ```

### Formato de Paquete Saliente (Broadcast)
Los paquetes viajan a través de los canales protegidos `RAID` o `PARTY` invocando:
```lua
SendAddonMessage("WP_COMP", payload, channel)
```

**Estructura del Payload:**
```
WP_ADDONS:<addon_label_1>,<addon_label_2>,...|<GAME_MODE>
```

**Parámetros:**
- `addon_label_n`: Etiquetas de addons detectados localmente (`LoreHUD`, `BattlePass`, `Companion`, `GameModes`, `RaidSuite`, `VisualShop`).
- `GAME_MODE`: Modalidad del jugador (`NORMAL`, `HARDCORE`, `IRONMAN`, `SLOW_X1`).

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

`WoWPeru_Companion` escucha pasivamente los prefijos de red de otros sistemas para enriquecer la experiencia social sin generar acoplamiento directo:

### Prefijo `WP_BP` (WoWPeru_BattlePass)
- Escucha paquetes entrantes `BP_RES_XP` y `BP_RES_SYNC`.
- Acelera el ticker de sincronización interno (`tickElapsed = TICK_INTERVAL - 0.1`) para garantizar que la felicitación comunitaria se lance inmediatamente después de que el BattlePass termine de procesar la respuesta del servidor Eluna.

---

## 4. Consulta Externa de Estado

Otros addons pueden consultar si `WoWPeru_Companion` está activo o inspeccionar su configuración mediante comprobaciones estándar:

```lua
if _G.WoWPeru_Companion then
    local comp = _G.WoWPeru_Companion
    local version = comp.Config and comp.Config.Version
    -- Companion está activo en el cliente
end
```

---

## 5. Persistencia (`SavedVariables`)

- **Variable Global:** `WoWPeruCompanion_DB`
- Se inicializa en el evento `ADDON_LOADED` al confirmarse la carga de `WoWPeru_Companion`.
- Almacena personalizaciones del jugador (preferencias de canal de anuncio, toggle de depuración).
