# 🛡️ Política de Seguridad — Wanos_Companion

La seguridad, estabilidad del cliente y protección contra trampas e inyecciones de datos son prioridades fundamentales en el ecosistema **Project Jaina**.

---

## 1. Alcance de Seguridad

`Wanos_Companion` es un addon **estrictamente de cliente** (`Client-Only`). No ejecuta scripts en el servidor ni tiene acceso a comandos privilegiados del servidor Eluna (`CharDBExecute`, `AuthDBExecute`).

---

## 2. Medidas de Protección Implementadas

### A. Prevención de Desbordamiento de Buffer (Buffer Overflow)
- **Límite de Red de WoW 3.3.5a:** Cualquier payload enviado por `SendAddonMessage` que exceda los 255 bytes provoca desconexión silenciosa o corrupción de datos.
- **Guardia de Tamaño:** `Wanos_Companion` aplica un guardia estricto antes de cualquier transmisión:
  ```lua
  if #payload > 200 then return end
  ```
- El tamaño promedio de los payloads es de ~50 bytes, muy por debajo de la zona de riesgo.

### B. Inmunidad a Inyección en Chat
- **Limpieza de Códigos de Escape:** El cliente WoW 3.3.5a puede desformatear el chat o activar filtros automáticos si los mensajes contienen códigos de color `|c` mal formados o cadenas binarias.
- Todos los anuncios públicos enviados por `SendChatMessage` utilizan exclusivamente texto plano sin códigos de formato.

### C. Protección contra Denegación de Servicio en Cliente (DoS / CPU Thrashing)
- No se realizan comprobaciones ni llamadas de red en cada frame (`OnUpdate` sin acumulador).
- Se utiliza un acumulador de tiempo delta con un intervalo de **5 segundos**, garantizando que el uso de ciclos de CPU sea indistinguible de cero (0.01% de frame time).

---

## 3. Reporte de Vulnerabilidades

Si descubres una vulnerabilidad, fallo de seguridad o riesgo de exploit en este addon:

1. **NO** abras un issue público en GitHub.
2. Envía un reporte privado al equipo de desarrollo:
   - **Líder de Proyecto:** DarckRovert (`darckrovert@gmail.com`)
   - **Discord Oficial:** Servidor de [Project Jaina](https://projectjaina.com/)
3. Incluye:
   - Pasos detallados para reproducir el fallo.
   - Versión exacta del cliente (`3.3.5a Build 12340`).
   - Addons coexistentes involucrados.
