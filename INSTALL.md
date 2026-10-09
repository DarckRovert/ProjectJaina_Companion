# 📦 Guía de Instalación — ProjectJaina_Companion

Instrucciones oficiales para instalar y verificar **ProjectJaina_Companion** en el cliente **World of Warcraft 3.3.5a (Build 12340)** del servidor **Project Jaina - Project Jaina**.

---

## 📥 Requisitos Previos

1. **Cliente WoW 3.3.5a (Build 12340):** Asegúrate de contar con una instalación limpia o estándar de Wrath of the Lich King.
2. **Acceso al Directorio del Juego:** Ubicación habitual en `d:\Project Jaina\Client\` o donde tengas alojado tu ejecutable `Wow.exe`.

---

## 🚀 Proceso de Instalación

### Método 1: Clonado vía Git (Recomendado para Desarrolladores)

Abre tu terminal en la carpeta de AddOns:

```bash
cd "d:\Project Jaina\Client\Interface\AddOns\"
git clone https://github.com/DarckRovert/ProjectJaina_Companion.git
```

Asegúrate de que la carpeta resultante se llame exactamente `ProjectJaina_Companion`.

### Método 2: Descarga Manual (.ZIP)

1. Descarga la última versión desde [Releases en GitHub](https://github.com/DarckRovert/ProjectJaina_Companion/releases).
2. Extrae el contenido en la ruta:
   ```
   World of Warcraft/Interface/AddOns/
   ```
3. Verifica que la ruta final de los archivos sea:
   ```
   Interface/AddOns/ProjectJaina_Companion/ProjectJaina_Companion.toc
   Interface/AddOns/ProjectJaina_Companion/Config.lua
   Interface/AddOns/ProjectJaina_Companion/Core.lua
   ```

> [!WARNING]
> **Estructura de Directorios:** Si los archivos quedan anidados en `Interface\AddOns\ProjectJaina_Companion\ProjectJaina_Companion\`, el cliente de WoW 3.3.5a no reconocerá el addon en la pantalla de selección de personajes.

---

## ⚙️ Activación en el Cliente

1. Inicia `Wow.exe` e ingresa a tu cuenta.
2. En la pantalla de selección de personajes, haz clic en el botón **Accesorios** (o **AddOns**) ubicado en la esquina inferior izquierda.
3. Asegúrate de marcar la casilla **"Cargar accesorios desactualizados"** (Load out of date AddOns).
4. Verifica que `Project Jaina - Companion` aparezca en la lista con su casilla marcada.
5. Entra al juego con cualquier personaje.

---

## ✅ Verificación Dentro del Juego

Una vez dentro del mundo:

1. Deberías ver un mensaje en el chat general:
   ```
   [Project Jaina] v1.0.1 cargado. Usa /companion
   ```
2. Ejecuta en el chat:
   ```
   /companion
   ```
3. Si estás en grupo con otros jugadores que tengan addons del ecosistema Project Jaina, ejecuta:
   ```
   /companion scan
   ```
   Verás la lista detallada de los addons activos de tus compañeros y su modalidad de juego.

---

## ❓ Solución de Problemas Frecuentes

### 1. El comando `/companion` no responde
- Verifica que el addon esté habilitado en el menú de AddOns de la pantalla de personajes.
- Comprueba que la carpeta se llame exactamente `ProjectJaina_Companion` (sin sufijos como `-main` o `-master`).

### 2. No se ven los addons de mis compañeros
- Los compañeros deben tener al menos un addon del ecosistema Project Jaina y estar en el mismo grupo o banda (`PARTY` o `RAID`).
- Ejecuta `/companion scan` para solicitar una actualización forzada.
