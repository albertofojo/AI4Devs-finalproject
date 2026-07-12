# Prompts — Tutti

Registro de los **prompts más relevantes** utilizados con asistentes de IA (Claude Code como herramienta principal, con apoyo puntual de Cursor) durante la concepción, diseño y documentación del proyecto. Para cada sección del `README.md` se incluyen hasta 3 prompts clave, una breve nota de cómo se guió al asistente y qué técnica del máster se aplicó.

> **Criterio de trabajo.** Los prompts no buscan que la IA "lo haga todo": buscan aplicar las técnicas vistas en el máster (PRD como especificación, INVEST + BDD/Gherkin, User Story Mapping, Diagramas como Código con Mermaid, normalización 3FN, DDD/arquitectura hexagonal, MCP servers contra la BBDD, Playwright para E2E) y dejar que el criterio humano revise, corrija y cierre cada artefacto. Cada borrador generado se revisó manualmente antes de incorporarlo a la documentación.

---

## 0. Configuración del entorno de IA (harness)

Antes de generar artefactos, se preparó el "harness" del proyecto: ficheros de instrucciones persistentes y servidores MCP, para que el agente trabaje con contexto real en lugar de adivinar.

**Prompt 0.1 — Crear el `CLAUDE.md` / `AGENTS.md` del proyecto**
> "Vamos a arrancar un proyecto nuevo. Quiero que generes un `CLAUDE.md` (y un `AGENTS.md` equivalente para agentes que no leen `CLAUDE.md`) corto y específico, sin secciones genéricas de relleno. Debe fijar: stack (Flutter para web/móvil, backend Python con FastAPI, Postgres en Supabase, Auth y Storage de Supabase, OpenSheetMusicDisplay para render MusicXML), convención de carpetas feature-first en el front y por capas en el back, comandos exactos de build y test, versiones de dependencias, y la lista de ficheros/áreas que el agente NO debe tocar sin permiso. Recuerda: los ficheros human-curated mejoran resultados; los rellenos de relleno los empeoran, así que sé conciso."

**Prompt 0.2 — Conectar la base de datos por MCP (metaprompting)**
> "Actúa como experto en el flujo de trabajo Claude Code + MCP. Antes de darte la orden final, hazme las preguntas que necesites para configurar correctamente el servidor MCP de Supabase/Postgres contra mi base de datos de desarrollo, en modo solo-lectura por seguridad. Cuando tengas todo claro, dame el comando `claude mcp add` exacto y una primera consulta de verificación que liste las tablas del esquema `public` y su número de filas, para confirmar que el loop agente↔BBDD funciona."

**Nota de guía:** se aplicó el concepto de *harness engineering* del módulo de frontend y el patrón "MCP como flujo nativo del developer" del módulo de bases de datos. El MCP se configuró **siempre en modo solo-lectura** contra entornos con datos, como exige el material. El prompt 0.2 es metaprompting: se pide a la IA que primero pregunte y luego construya el comando.

---

## 1. Producto (PRD)

**Prompt 1.1 — Generar el PRD como especificación, con fases y Non-goals**
> "Actúa como senior product manager con experiencia en productos SaaS colaborativos. A partir del contexto de producto que te paso en `.ai-context/project-context.md`, genera un PRD que sirva a la vez como documento de alineación humana y como especificación ejecutable para un agente de coding. Inclúyelo todo: objetivos, stakeholders, historias de usuario en formato 'Como [rol], quiero [acción], para [beneficio]', características y funcionalidades, requisitos técnicos, métricas de éxito (KPIs), riesgos, y —muy importante— una sección **Non-goals / Fuera de alcance** explícita, porque un agente no infiere los límites implícitos. Estructura el alcance en **fases secuenciales** donde cada fase tenga dependencias claras, resultados verificables y alcance acotado."

**Prompt 1.2 — Recorte crítico del MVP (la IA como crítico, no como redactor)**
> "El contexto describe un producto enorme (inventario con IoT, modo directo, play-along, bolsa de sustitutos…). Para un proyecto con ~30 horas de dedicación y que debe desplegarse en una URL pública, eso es inabarcable. Quiero que actúes como crítico de alcance, no como redactor complaciente: propón UN único flujo end-to-end que aporte valor completo por sí mismo y sea demostrable, justifica por qué dejas el resto fuera, y conviértelo en un roadmap por fases. Señálame de forma explícita qué funcionalidades son riesgo técnico para el plazo y cuáles no podrían demostrarse en una web desplegada."

**Prompt 1.3 — One-Pager para fijar el foco**
> "Condensa el PRD en un 'One-Pager': problema, usuarios objetivo, propuesta de valor, el flujo E2E prioritario (director crea grupo → invita músicos → programa ensayo con un Setlist de partituras → los músicos confirman asistencia y abren la partitura), métricas de éxito y Non-goals. Que quepa en una pantalla y sirva como brújula del proyecto."

**Nota de guía:** se siguió el enfoque del módulo de planificación: el **PRD como input para agentes** (fases con dependencias, criterios verificables y Non-goals explícitos) y el formato **One-Pager** ágil. Se forzó a la IA a ejercer de crítica del alcance; las decisiones de recorte se tomaron con criterio propio tras su análisis.

---

## 2. Arquitectura

**Prompt 2.1 — Resolver el conflicto plataforma vs. despliegue, con trade-offs**
> "Hay una tensión a resolver antes de fijar arquitectura: el contexto pide app móvil/tablet offline-first, pero la entrega exige una URL pública con backend, frontend y BD desplegados. Compárame las opciones reales para tener Postgres relacional gratuito junto a servicios gestionados (Supabase vs Neon vs Firebase Data Connect), por coste, madurez y esfuerzo de integración. No me des solo tu recomendación: dame ventajas e inconvenientes de cada una. Asumo Flutter en el front (compila a web) y Python en el back."

**Prompt 2.2 — Diagramas como Código (Mermaid) para arquitectura e infraestructura**
> "Genera dos diagramas en **Mermaid** (formato diagrams-as-code, que se renderiza nativo en GitHub) para el README: (1) un diagrama de arquitectura en tres capas — cliente Flutter (con OpenSheetMusicDisplay vía JS interop en web), backend FastAPI, y Supabase (Postgres + Auth + Storage) — mostrando el flujo de datos y la verificación del JWT en el backend; (2) un diagrama de infraestructura/despliegue (GitHub Actions → build Flutter web a Hosting + API a Render/Cloud Run → Supabase). Acompáñalos de una justificación honesta del patrón con beneficios y sacrificios. Después dame los enlaces para validarlos en mermaid.live."

**Prompt 2.3 — Disciplina arquitectónica del backend (DDD + capas, AI-friendly)**
> "Quiero que el backend sea fácil de mantener tanto para mí como para un agente que itere sobre él. Propón la organización aplicando los principios del módulo de backend: lenguaje ubicuo del dominio musical (Grupo, Membresía, Setlist, Ensayo, Asistencia), separación por capas `router → service → repository` para empezar (sin sobre-ingeniería hexagonal en un MVP), entidades con comportamiento en vez de anémicas, y dependencias hacia abstracciones (DIP) para que los tests no necesiten mockear el framework. Indícame qué fronteras (bounded contexts) definirías y por qué facilitan que el agente trabaje sobre un módulo sin romper otro."

**Nota de guía:** se aplicaron dos técnicas del máster: **Diagramas como Código con Mermaid** (versionables, renderizables en GitHub y "el formato que mejor generan los asistentes") y la **disciplina arquitectónica como disciplina de contexto** del módulo de backend (DDD, SOLID/DIP, empezar en capas y refactorizar a hexagonal solo si el dominio lo pide).

---

## 3. Modelo de datos

**Prompt 3.1 — Diseño relacional normalizado a 3FN**
> "Eres experto en bases de datos relacionales. A partir del flujo MVP, diseña el modelo de datos para Postgres, normalizado hasta 3FN: usuarios (con `id` alineado al de Supabase Auth para no duplicar identidad), grupos, membresías (tabla de unión usuario↔grupo con rol y estado), invitaciones por email con token y caducidad, partituras (metadatos + referencia al fichero en Storage), setlists, la relación ordenada setlist↔partitura, ensayos con setlist opcional, y asistencia (tabla de unión usuario↔ensayo con estado). Usa tablas de unión explícitas donde haya relaciones N:M, márcame las cardinalidades y propón los índices iniciales en las columnas de `JOIN`/`WHERE` más frecuentes. Como uso Python, exprésalo con modelos SQLModel/SQLAlchemy y migraciones Alembic (no Prisma), pero aplica los mismos principios del módulo."

**Prompt 3.2 — Diagrama entidad-relación en Mermaid**
> "Convierte ese esquema en un diagrama ER en **Mermaid** (`erDiagram`) con claves primarias, foráneas, enumerados clave (rol, estado de invitación, estado de asistencia, formato de partitura) y restricciones de unicidad. Añade una tabla descriptiva por entidad y un párrafo que resuma las relaciones N:M para justificar las tablas de unión."

**Prompt 3.3 — Revisión del esquema y seguridad por MCP**
> "Con el MCP de Supabase conectado en solo-lectura, introspecciona el esquema real y dime: ¿hay alguna tabla que viole la 3FN o alguna FK que falte? Para las tablas que expongan datos de un grupo, propón políticas de **Row Level Security** usando el patrón `(select auth.uid())` y el índice correspondiente sobre la columna de usuario, tal y como recomienda el material para no degradar el rendimiento. Antes de proponer cualquier migración destructiva, avísame del riesgo y dame el patrón Expand-Contract para aplicarla sin pérdida de datos."

**Nota de guía:** se siguieron las buenas prácticas de BBDD del máster: **normalización (1FN→3FN)**, **índices sobre columnas de join/filtro**, **RLS con el patrón `(select auth.uid())`**, y **revisión humana obligatoria de migraciones destructivas** (Expand-Contract). El diagrama se hizo con Mermaid `erDiagram`. La introspección se hace vía **MCP en modo solo-lectura**, nunca escribiendo en datos reales.

---

## 4. API

**Prompt 4.1 — Especificación REST alineada con OpenAPI**
> "Define la especificación de la API REST del MVP en FastAPI, de forma que coincida con la documentación OpenAPI que FastAPI generará automáticamente en `/docs` (para que documento y código no se desincronicen). Quiero una tabla con método, ruta, descripción y nivel de autorización (autenticado / miembro del grupo / administrador) para cada endpoint del recorrido completo: perfil, grupos, invitaciones, partituras, setlists, ensayos y asistencia. Después desarrolla tres ejemplos completos —crear grupo, programar ensayo con setlist asociado y confirmar asistencia— con request, response y códigos de estado, incluidos los de error."

**Prompt 4.2 — Modelo de autorización por rol y pertenencia (con desconfianza de seguridad)**
> "Documenta cómo se aplica la seguridad endpoint a endpoint: el backend verifica la firma del JWT de Supabase y comprueba pertenencia al grupo y rol antes de cualquier acción sensible (solo admin invita o crea ensayos; solo miembro sube partituras o ve el detalle del grupo). Aplica el principio del módulo de frontend de **desconfiar por defecto de la seguridad generada por IA**: revísate a ti mismo y dime explícitamente, para cada endpoint, qué asume sobre el usuario autenticado, qué entra por params/body/headers y qué valida el servidor. Refleja la matriz de permisos en la tabla de endpoints y enumera los códigos 401/403/404/409 con un ejemplo de cada uno."

**Nota de guía:** la API se especificó para que case con la **documentación OpenAPI automática de FastAPI**, manteniendo trazabilidad documento↔código (idea del demo "de ticket a PR" del módulo de backend). La autorización se documentó pidiendo a la IA que **auditara sus propias asunciones de seguridad**, siguiendo la advertencia del módulo de frontend sobre el alto índice de vulnerabilidades en código generado sin revisión.

---

## 5. Historias de usuario y tickets

**Prompt 5.1 — User Story Mapping del flujo E2E**
> "Antes de redactar historias sueltas, hazme un **User Story Map** (técnica de Jeff Patton) del flujo principal: el 'backbone' de actividades del usuario en orden cronológico (registrarse → crear/entrar a un grupo → gestionar partituras → preparar un ensayo → confirmar asistencia → estudiar la partitura) y, bajo cada actividad, las historias candidatas ordenadas por prioridad. Marca con una línea de corte qué historias entran en el MVP y cuáles quedan para versiones posteriores."

**Prompt 5.2 — Historias con INVEST y criterios de aceptación en BDD/Gherkin**
> "Actúa como Product Owner senior. A partir del story map, redacta las historias de usuario Must-Have y Should-Have (priorización MoSCoW). Cada historia debe: cumplir los criterios **INVEST**, seguir el formato 'Como [rol], quiero [acción], para [beneficio]', e incluir 3–5 criterios de aceptación en **formato BDD Given/When/Then (Gherkin)** que cubran happy path, un caso de error y un edge case. Al terminar, evalúa cada historia contra INVEST y avísame de cuál falla algún criterio y por qué."

**Prompt 5.3 — Desglose en tickets con trazabilidad y estimación**
> "Descompón las historias en tickets de trabajo siguiendo la anatomía del módulo: título claro, descripción (propósito + detalles), criterios de aceptación técnicos, prioridad, estimación en story points, etiquetas (backend/frontend/infra/QA) y enlace a su historia de origen para trazabilidad bidireccional. Desarrolla en detalle los tickets de las historias del núcleo del flujo y deja el resto en una tabla resumen. Incluye un ticket de tipo **spike** para investigar el render MusicXML con OpenSheetMusicDisplay en Flutter web (es el mayor riesgo técnico) y tickets transversales de CI/CD y del test E2E del flujo principal."

**Nota de guía:** se aplicó el ciclo completo del módulo de gestión de producto: **User Story Mapping** para no caer en un "backlog plano", **INVEST** como checklist de calidad, **criterios de aceptación en Gherkin** (que conectan directamente con los tests automatizados), **MoSCoW** para priorizar y la **anatomía de ticket** con trazabilidad. El riesgo del visor MusicXML se aisló en un ticket **spike**, como recomienda el material.

---

## 6. Estrategia de testing (BDD y E2E)

**Prompt 6.1 — De los criterios Gherkin a la estrategia de pruebas**
> "Partiendo de que los criterios de aceptación ya están en formato Given/When/Then, define la estrategia de testing del proyecto en tres niveles: unitarios (lógica de negocio del backend con pytest), integración (endpoints FastAPI contra un Postgres de test, idealmente con un contenedor efímero para paridad con producción) y al menos un **E2E** del flujo principal. Explica qué cubre cada nivel y por qué los criterios BDD que ya escribimos se pueden traducir casi directamente a tests."

**Prompt 6.2 — Generar el test E2E con Playwright y selectores accesibles**
> "Genera el test E2E del flujo principal con **Playwright** sobre la versión web de Flutter. Descríbelo primero en Given/When/Then y luego impleméntalo usando **queries accesibles** (`getByRole`, `getByLabel`, `getByTestId`), nunca selectores de clase frágiles. El recorrido: login → crear grupo → invitar a un músico → subir una partitura → crear un Setlist → programar un ensayo con ese Setlist → confirmar asistencia → abrir la partitura en el visor. Ejecútalo y arréglalo hasta que pase tres veces seguidas sin flakiness, y activa el trace para depurar fallos en CI."

**Nota de guía:** se siguió el módulo de testing: la pirámide unitario/integración/E2E, la traducción directa de **criterios Gherkin a tests**, **Playwright** como framework E2E recomendado con **selectores accesibles**, y el patrón de pedir al agente que **ejecute el test hasta que pase de forma estable**. Para integración se contempló un Postgres efímero (estilo Testcontainers) por paridad con producción.

---

## 7. Frontend (diseño a código)

**Prompt 7.1 — Contexto antes que pregunta, e iteración incremental**
> "Vamos a construir las pantallas del flujo en Flutter. Te paso primero el contexto (el `CLAUDE.md`, los tokens de diseño y los modelos de datos) para que no inventes. No me generes 'toda la app': empezamos incrementalmente por la pantalla de detalle de ensayo, que muestra los datos del ensayo, el Setlist asociado y un selector de asistencia (Confirmado/Ausente/En duda). No introduzcas dependencias nuevas sin justificarlas y no toques la capa de autenticación. Muéstrame el plan antes de aplicar los cambios y mantén el comportamiento descrito."

**Prompt 7.2 — Auditoría de accesibilidad (WCAG 2.2 AA)**
> "Audita la pantalla generada contra **WCAG 2.2 nivel AA**: orden de foco y navegación por teclado, etiquetas y mensajes de error asociados en los formularios, contraste mínimo 4.5:1, y uso de semántica antes que roles AREA cuando exista equivalente nativo. Devuélveme un informe con severidad y propuesta de fix por hallazgo; la accesibilidad no es opcional."

**Nota de guía:** se aplicaron los patrones de *prompt engineering para frontend* del máster: **contexto antes que pregunta**, **iteración incremental** (una pantalla concreta, no "toda la app"), **especificar lo que NO se debe tocar** y **mostrar el plan antes de aplicar**. La accesibilidad se auditó contra **WCAG 2.2 AA**, tratada como requisito y no como extra.
