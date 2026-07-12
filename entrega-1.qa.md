# Informe QA — Entrega 1 (Documentación técnica) · Proyecto "Tutti"

> **Revisor:** QA · **Fecha:** 2026-05-31
> **Alcance revisado:** `README.md` y `prompts.v2.md` frente a los requisitos de la **Entrega 1 – Documentación técnica** descritos en `.lidr/41-🧑🏻‍💻-Instrucciones-Proyecto-Final.md` (y la referencia de plantilla de `.lidr/42-👁️‍🗨️Ejemplo-proyecto-final.md`).
> **Veredicto global:** ✅ **APTO con subsanaciones**. La documentación cumple en estructura y profundidad lo exigido para la Entrega 1. Quedan **incidencias bloqueantes administrativas** (datos de identificación/URLs pendientes y nombre del fichero de prompts) y **discrepancias de coherencia** entre `README.md` y `prompts.v2.md` que conviene resolver antes de abrir el PR oficial.

---

## 1. Resumen ejecutivo

La Entrega 1 pide **documentación técnica**: rellenar la plantilla `README.md` (ficha, producto, arquitectura, modelo de datos, API, historias, tickets, PRs) y documentar los **prompts clave** en `prompts.md` (hasta 3 por sección, con nota de cómo se guió al asistente).

Ambos documentos están **muy por encima del mínimo** en calidad y aplican correctamente las técnicas del máster (PRD con Non-goals, INVEST + Gherkin, MoSCoW, User Story Mapping, Mermaid como diagrams-as-code, 3FN, DDD por capas, MCP solo-lectura). El recorte de alcance del MVP a un único flujo E2E demostrable está bien justificado y alineado con las instrucciones (~30 h, URL pública).

Los problemas detectados son **acotados y subsanables**:

- **Bloqueantes (administrativos):** campos de identificación pendientes (nombre, URLs), y el fichero se llama `prompts.v2.md` cuando la plataforma y la propia plantilla esperan `prompts.md`.
- **Discrepancias de coherencia:** el framework de test E2E difiere entre los dos documentos (Flutter `integration_test` vs. Playwright); el "ticket spike" que el prompt dice haber pedido no existe como tal en el README.
- **Mejoras menores:** algunos tickets Must-Have sin desarrollar, notas de plantilla sin limpiar, riesgo de render de los saltos de línea en Mermaid.

---

## 2. Checklist de cumplimiento — Entrega 1

| # | Requisito (instrucciones) | Ubicación | Estado | Nota |
|---|---|---|---|---|
| R1 | **Ficha del proyecto** (nombre, proyecto, descripción, URLs) | README §0 | ⚠️ Parcial | Estructura completa; nombre y URLs **pendientes** (ver §4-B1). |
| R2 | **Descripción general del producto** (objetivo, características, UX, instalación) | README §1 | ✅ | Objetivo, valor por perfil, flujo E2E y Non-goals (roadmap) muy completos. |
| R3 | **Arquitectura del sistema** (diagrama + componentes + infra + seguridad + tests) | README §2 | ✅ | Dos diagramas Mermaid, justificación honesta con sacrificios, sección de seguridad y de tests. |
| R4 | **Modelo de datos** (diagrama + entidades) | README §3 | ✅ | ER en Mermaid, 9 entidades, cardinalidades N:M explícitas, enums. |
| R5 | **Especificación de la API** | README §4 | ✅ | Tabla de endpoints con matriz de auth + 3 ejemplos request/response + códigos de error. |
| R6 | **Historias de usuario** (3–5 Must + 1–2 Should, con criterios y trazabilidad) | README §5 | ✅ | 6 Must (HU-01..06) + 2 Should (HU-07/08), Gherkin + trazabilidad a tickets. Supera el mínimo. |
| R7 | **Tickets de trabajo** (criterios técnicos + trazabilidad + estimación) | README §6 | ✅ | Tickets de núcleo desarrollados; resto en tabla. Story points y etiquetas. |
| R8 | **Pull requests** | README §7 | ⚠️ Parcial | Estrategia descrita; enlace del PR-1 pendiente (esperado hasta abrir el PR). |
| R9 | **Registro de prompts** (`prompts.md`, ≤3 por sección + nota de guía) | `prompts.v2.md` | ⚠️ Parcial | Contenido excelente; **nombre de fichero incorrecto** (ver §4-B2). |
| R10 | **Rama `feature-entrega1-[iniciales]`** | README §0.5 menciona `feature-entrega1-AFE` | ✅ (a verificar) | Coincide con el formato exigido (iniciales AFE). Verificar que la rama exista en el repo. |

**Cumplimiento documental: 8/10 completos, 4 parciales subsanables. Ningún requisito ausente.**

> Nota administrativa (no documental): la fecha límite de la Entrega 1 según las instrucciones (`.lidr/41`, "Documentación técnica: Miércoles 27 de Mayo de 2026") es **anterior a la fecha de esta revisión (2026-05-31)**. Si aún no se ha enviado el formulario, conviene priorizar las subsanaciones bloqueantes y, si procede, gestionar la situación con el TA.

---

## 3. Discrepancias detectadas

### D1 — Framework de test E2E inconsistente entre documentos ⚠️ (coherencia)
- `README.md` §2.6 y **TK-19** definen el E2E como **`integration_test` de Flutter**.
- `prompts.v2.md` §6 (Prompt 6.2) describe el E2E con **Playwright** sobre la web de Flutter, con `getByRole/getByLabel/getByTestId`.

Son dos enfoques distintos. Un evaluador que lea ambos verá una contradicción sobre la herramienta de E2E. **Hay que elegir uno y unificar.** (El material del máster, módulo 11, recomienda Playwright; pero para Flutter Web el `integration_test` nativo también es válido. Decisión técnica del autor, pero debe ser única.)

### D2 — El "ticket spike" del prompt no existe como tal en el README ⚠️ (trazabilidad)
- `prompts.v2.md` §5 (Prompt 5.3) afirma: *"Incluye un ticket de tipo **spike** para investigar el render MusicXML con OpenSheetMusicDisplay"*.
- En `README.md`, el riesgo del visor está en **TK-10**, etiquetado *"Riesgo: Alto"* pero **no tipado como spike**, y no hay un ticket de investigación separado.

El prompt describe un artefacto (ticket spike) que el README no materializa. Discrepancia entre lo narrado y lo entregado.

### D3 — Nombre del fichero de prompts ⚠️ (bloqueante administrativo)
- Las instrucciones y la plantilla esperan **`prompts.md`**. El árbol de ficheros del propio README (§2.3) y la sección §7 (PR-1) referencian **`prompts.md`**.
- El fichero real es **`prompts.v2.md`**. La plataforma/TA buscará `prompts.md`.

### D4 — Secciones de `prompts.v2.md` no mapean 1:1 con las del README (menor)
`prompts.v2.md` agrupa "Historias y tickets" en una sola sección (§5) y añade §6 Testing y §7 Frontend, que **no son secciones del README**. Las instrucciones piden prompts *"para cada sección (producto, arquitectura, modelo de datos, API, etc.)"*. No es un incumplimiento (de hecho aporta valor), pero conviene una nota que aclare la correspondencia para que el evaluador no eche en falta "prompts de la sección de tickets" como bloque propio.

### D5 — Endpoint sin historia/ticket de respaldo (menor)
`PUT /api/me` (actualizar perfil: instrumento, nivel) aparece en la tabla de API (§4) pero **ninguna HU ni ticket** lo cubre explícitamente (HU-01 menciona el perfil de forma tangencial). Falta trazabilidad para ese endpoint.

---

## 4. Subsanaciones sugeridas

> Clasificadas en **bloqueantes** (impiden una entrega limpia) y **recomendadas** (elevan calidad/coherencia). Cada una con propuesta concreta.

### A) Bloqueantes — antes de abrir el PR de Entrega 1

**B1 · Rellenar los campos de identificación de la ficha (§0).**
- §0.1 Nombre completo: sustituir `_[Pendiente: ... AFE]_` por el nombre real.
- §0.5 URL del repositorio: añadir la URL del repo `AI4Devs-finalproject` (aunque el código aún no esté, el repo y la rama deben existir para la Entrega 1).
- §0.4 URL del proyecto: aceptable dejar "se publicará en la Entrega final" (no exigible ahora), pero conviene dejarlo explícito como N/A en Entrega 1 en vez de "Pendiente".

**B2 · Renombrar `prompts.v2.md` → `prompts.md`.**
- Renombrar el fichero (o crear `prompts.md` con este contenido). Si se quiere conservar histórico, dejar `prompts.v2.md` como copia, pero **el fichero canónico debe ser `prompts.md`**.
- Verificar que el árbol de ficheros del README (§2.3) y la referencia del PR-1 (§7) sigan apuntando a `prompts.md` (ya lo hacen).

**B3 · Resolver la discrepancia D1 (E2E).**
- Decidir framework único y reflejarlo idéntico en `README.md` §2.6 + TK-19 **y** `prompts.v2.md` §6. Recomendación: si el visor crítico vive en Flutter Web, Playwright (recomendado por el módulo 11) encaja; si se prefiere el stack nativo, usar `integration_test`. Lo importante es que **ambos documentos digan lo mismo**.

### B) Recomendadas — mejoran calidad y coherencia

**M1 · Materializar el ticket spike (D2).**
- Añadir un **TK-20 [Spike] Investigar render MusicXML con OpenSheetMusicDisplay en Flutter Web** (timeboxed, p. ej. 1 día), trazado a HU-04, y dejar TK-10 como la implementación posterior. Alternativamente, retipar TK-10 como `Spike + Implementación`. Esto alinea README ↔ prompts y refleja la gestión de riesgo que el propio prompt presume.

**M2 · Desarrollar los tickets Must-Have de HU-01 (login).**
- TK-01 y TK-02 (autenticación, núcleo del flujo E2E) están solo en la tabla resumen. Al ser **Must-Have y base de todo el flujo**, conviene desarrollarlos con criterios de aceptación técnicos como el resto del núcleo (coherencia con TK-03..TK-15).

**M3 · Añadir trazabilidad del endpoint `PUT /api/me` (D5).**
- Opción simple: ampliar HU-01 (o crear una micro-HU "editar mi perfil") y referenciar un ticket (p. ej. TK-02 extendido). Así no quedan endpoints huérfanos en la API.

**M4 · Nota de mapeo de secciones en `prompts.md` (D4).**
- Añadir una línea al inicio aclarando que las secciones de prompts agrupan/expanden las del README (p. ej.: "§5 cubre Historias **y** Tickets del README; §6–§7 documentan prompts de fases de código —testing y frontend— que se ejecutarán en Entregas 2–3"). Evita que el evaluador busque correspondencia 1:1.

**M5 · Limpiar notas de plantilla.**
- README línea 3: la nota *"Si prefieres otro nombre, cámbialo aquí…"* es texto de andamiaje; eliminarla para una entrega pulida.
- Revisar que las notas *"[Pendiente …]"* restantes correspondan realmente a artefactos de Entregas 2/3 (instalación, URL pública, CI/CD) y no a obligaciones de la Entrega 1.

**M6 · Validar el render de los diagramas Mermaid en GitHub.**
- Las etiquetas de nodo usan `\n` para salto de línea (p. ej. `"UI Flutter\n(Material 3, responsive)"`). En GitHub, el salto de línea fiable en Mermaid es `<br/>`; `\n` puede renderizarse literal según versión. **Acción:** validar los 3 diagramas en `mermaid.live` y en la **vista previa de GitHub** (no solo en el editor local) y, si `\n` no rompe línea, sustituir por `<br/>`. (El propio `prompts.v2.md` §2.2 menciona validar en mermaid.live: dejar constancia de que se hizo.)

**M7 · Coherencia de la "Visión/roadmap" entre documentos.**
- README §1.2 lista funcionalidades fuera de MVP (Modo Directo, IoT, Play-Along, Bolsa de Sustitutos). `prompts.v2.md` 1.2 las cita igual. ✅ Coinciden. Mantener esta coherencia si se editan.

---

## 5. Aspectos destacables (lo que está muy bien)

- **Recorte de alcance MVP** explícito y justificado (Non-goals + roadmap), exactamente lo que pide el módulo de planificación para que un agente no infiera límites.
- **Trazabilidad bidireccional** HU ↔ TK presente y consistente en el núcleo.
- **Criterios de aceptación en Gherkin** con happy path + error + edge case (HU-03 es ejemplar: incluye token caducado y `403` por rol).
- **API documentada como contrato** alineado con OpenAPI/FastAPI, con matriz de autorización por endpoint y códigos de error.
- **Modelo de datos** normalizado, con tablas de unión explícitas para los N:M y `UK` compuestas correctas (`memberships`, `attendances`).
- **`prompts.v2.md`** demuestra uso real de técnicas (metaprompting, IA como crítico de alcance, MCP solo-lectura, auditoría de seguridad de la propia IA, WCAG 2.2 AA), que es justo el espíritu del "Registro del uso de IA" exigido.

---

## 6. Conclusión

La Entrega 1 está **sustancialmente completa y bien construida**. No falta ningún artefacto documental exigido y la calidad supera el mínimo. Para una entrega limpia, **subsanar lo bloqueante** (B1 datos de ficha, B2 renombrar a `prompts.md`, B3 unificar el framework E2E) y, si el tiempo lo permite, aplicar M1–M3 para cerrar las discrepancias de trazabilidad. El resto son pulidos.

| Prioridad | Acciones |
|---|---|
| 🔴 Bloqueante | B1 (ficha), B2 (`prompts.md`), B3 (E2E único) |
| 🟠 Recomendado | M1 (spike), M2 (TK-01/02), M3 (`PUT /api/me`) |
| 🟡 Pulido | M4 (mapeo), M5 (limpiar plantilla), M6 (Mermaid `<br/>`) |

**Recomendación final:** APTO para entregar una vez aplicadas las 3 subsanaciones bloqueantes.
