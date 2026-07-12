# Prompts — XANEE

Registro de los **prompts más relevantes** usados con el asistente de IA (Claude / Claude Code) durante la concepción y diseño del proyecto. Para cada sección del `README.md` se incluyen hasta 3 prompts clave, transcritos de forma fiel, junto con una nota de cómo se guió al asistente y qué decisión produjo cada uno.

> Estos prompts son el origen de las decisiones que documenta el `README.md`: el recorte del alcance, la elección del stack, el modelo de datos relacional, la API y las historias/tickets. La herramienta principal de asistencia ha sido **Claude Code**, trabajando con el contexto de producto (`.ai-context/project-context.md`) y las instrucciones oficiales de la entrega (`.lidr/`).

---

## 1. Producto

**Prompt 1.1 — Encuadre de la entrega y verificación de contexto**
> "Estoy cursando un máster de IA que requiere un proyecto final. En la carpeta `.lidr/` tienes toda la información de cómo se construye ese proyecto y sus entregas; en `.ai-context/project-context.md` tienes la descripción de la app que quiero crear. Tengo que realizar la primera entrega mañana. Antes de escribir nada, revisa de qué trata exactamente esta primera entrega (que es solo documentación), qué artefactos exige la plantilla oficial, y analiza con espíritu crítico si tienes toda la información necesaria para producirla. Si falta algo o hay incoherencias, dímelo antes de avanzar."

**Prompt 1.2 — Reducción del alcance a un MVP realista**
> "Mi visión de producto tiene 4 pilares y 4 funcionalidades avanzadas (Modo Directo, IoT, Play-Along, Bolsa de Sustitutos), pero la entrega solo pide UN flujo E2E prioritario con 3–5 historias Must-Have y la dedicación total estimada es de 30 horas. Actúa como product owner crítico, no como redactor: propón un único flujo de extremo a extremo que (a) aporte valor completo por sí mismo, (b) sea demostrable en una URL pública y (c) sea construible en ese tiempo. Justifica por qué dejas el resto fuera y conviértelo en un roadmap por fases. Señálame explícitamente cualquier funcionalidad que sea un riesgo técnico para el plazo."

**Prompt 1.3 — Definición y priorización de historias de usuario**
> "Para el flujo elegido (un director crea un grupo, invita a sus músicos, programa un ensayo asociándole un Setlist de partituras y los músicos confirman asistencia y ven qué estudiar), redacta las historias de usuario en formato 'Como [rol] quiero [objetivo] para [beneficio]', con criterios de aceptación en Gherkin (Dado/Cuando/Entonces) y priorización MoSCoW. Mantén el flujo principal como Must-Have y deja como Should-Have lo que no bloquee el recorrido E2E (p. ej. transposición de tonalidad o notas por tema)."

**Nota de guía:** se proporcionó al asistente el contexto de producto y las instrucciones oficiales, y se le pidió explícitamente que ejerciera de crítico del alcance, no solo de redactor. De aquí salió el recorte del MVP al flujo Grupos+Partituras+Ensayos, el roadmap de funcionalidades futuras y el conjunto de historias de usuario de la sección 5 del README.

---

## 2. Arquitectura

**Prompt 2.1 — Resolución del conflicto entre la visión y el requisito de despliegue**
> "Hay una tensión que quiero resolver antes de fijar la arquitectura: el contexto de producto describe una app móvil/tablet con enfoque offline-first (SQLite/Room/CoreData), pero la entrega final exige una URL pública accesible con backend, frontend y base de datos desplegados para que el evaluador pruebe el flujo en vivo. Explícame las implicaciones de cada camino, y propón una arquitectura que respete la visión multiplataforma pero garantice ese despliegue público con coste cero. Dame ventajas e inconvenientes de cada opción, no solo tu recomendación."

**Prompt 2.2 — Elección del stack bajo restricciones concretas**
> "Decisiones que ya tengo tomadas: frontend en Flutter (que puede compilar a web y desplegarse en algo como Firebase Hosting), backend en Python, y quiero una base de datos relacional porque gran parte del dominio (grupos↔miembros, ensayos↔asistencia, setlists↔partituras) lo es. Tengo restricción de coste, así que la BD debe ser gratuita. ¿Puedo combinar Firebase con Postgres? Compárame las opciones reales (Firebase Data Connect vs. Neon vs. Supabase) por coste, madurez y esfuerzo de integración, y recomiéndame el framework de Python más adecuado para documentar bien la API."

**Prompt 2.3 — Formalización de la arquitectura y sus trade-offs**
> "Con el stack ya cerrado (Flutter web, FastAPI, Supabase para Postgres + Auth + Storage, y OpenSheetMusicDisplay para renderizar MusicXML en el cliente web), genera el diagrama de arquitectura en Mermaid mostrando las tres capas y el flujo de datos (incluida la verificación del JWT de Supabase en el backend y las URLs firmadas del Storage). Acompáñalo de una justificación del patrón que sea honesta: beneficios, pero también sacrificios y riesgos (cold starts del plan gratuito, dependencia de proveedor, y que el render avanzado de partituras solo se garantiza en Flutter Web)."

**Nota de guía:** se iteró deliberadamente sobre las alternativas en lugar de aceptar la primera propuesta. El asistente tuvo que explicitar los *trade-offs* de Firebase Data Connect vs. Neon vs. Supabase; la conversación convergió en **FastAPI + Supabase** por su free tier, su Postgres relacional y porque FastAPI genera documentación OpenAPI (requisito de la entrega). De estos prompts salieron los diagramas y la sección 2 del README.

---

## 3. Modelo de datos

**Prompt 3.1 — Diseño del esquema relacional normalizado**
> "Diseña el modelo de datos relacional que soporta el flujo MVP completo. Necesito: usuarios (cuyo id debe coincidir con el de Supabase Auth para no duplicar la identidad), grupos, la pertenencia de usuarios a grupos con su rol (admin/miembro) y estado, invitaciones por email con token y caducidad, partituras con sus metadatos y referencia al archivo en Storage, setlists, la relación ordenada entre setlist y partituras, ensayos con un setlist opcional asociado, y la asistencia de cada músico a cada ensayo. Usa tablas de unión explícitas donde haya relaciones N:M y dime las cardinalidades de cada relación. Prioriza la normalización."

**Prompt 3.2 — Representación visual y documentación de entidades**
> "Convierte ese esquema en un diagrama entidad-relación en Mermaid (`erDiagram`) con las claves primarias, foráneas y los atributos y enumerados clave de cada tabla (roles, estados de invitación, estados de asistencia, formato de partitura). Añade después una tabla que describa cada entidad, sus claves y restricciones de unicidad, y un párrafo que resuma las cardinalidades N:M más importantes para que se entienda el porqué de las tablas de unión."

**Nota de guía:** se insistió en un modelo normalizado con tablas de unión explícitas (`memberships`, `setlist_items`, `attendances`) en lugar de campos embebidos, y en alinear `users.id` con el identificador de Supabase Auth para evitar tener dos fuentes de verdad sobre la identidad del usuario. El resultado es el diagrama ER y las descripciones de la sección 3 del README.

---

## 4. API

**Prompt 4.1 — Especificación de la superficie REST del MVP**
> "Define la especificación de la API REST que cubre exactamente el flujo MVP, alineada con lo que FastAPI generará en su OpenAPI para que documento y código no se desincronicen. Quiero una tabla con método, ruta, descripción y nivel de autorización requerido (autenticado / miembro del grupo / administrador) para cada endpoint del recorrido: perfil, grupos, invitaciones, partituras, setlists, ensayos y asistencia. Después, desarrolla tres ejemplos completos —crear grupo, programar ensayo asociando un setlist, y confirmar asistencia— con su request, su response y los códigos de estado, incluyendo los de error."

**Prompt 4.2 — Modelo de autorización por rol y pertenencia**
> "Documenta de forma precisa cómo se aplica la seguridad en cada endpoint: el backend FastAPI debe verificar la firma del JWT emitido por Supabase Auth en toda petición protegida, y además comprobar la pertenencia al grupo y el rol antes de permitir acciones sensibles (solo un administrador invita o crea ensayos; solo un miembro sube partituras o ve el detalle del grupo). Refleja esa matriz de permisos en la columna de autorización de la tabla de endpoints y enumera los códigos de error comunes (401, 403, 404, 409) con un ejemplo de cuándo se da cada uno."

**Nota de guía:** se pidió que la especificación coincidiera con la documentación OpenAPI que FastAPI generará automáticamente, manteniendo trazabilidad entre el documento y el futuro código, y que la autorización por rol/pertenencia fuera explícita endpoint a endpoint. De aquí salió la sección 4 del README (tabla de endpoints, ejemplos y códigos de error).

---

## 5. Historias de usuario y tickets

**Prompt 5.1 — Derivación de tickets de trabajo con trazabilidad**
> "A partir de las historias de usuario, descompón el trabajo en tickets técnicos concretos, separando frontend, backend, infraestructura y QA. Cada ticket debe tener: tipo, la historia de la que proviene (para garantizar trazabilidad bidireccional historia↔ticket), una descripción técnica de qué construir y criterios de aceptación verificables (incluyendo qué test lo cubre). Desarrolla en detalle los tickets de las historias del núcleo del flujo E2E y deja el resto en una tabla resumen; incluye también los tickets transversales de CI/CD y del test E2E obligatorio."

**Prompt 5.2 — Identificación y marcado de riesgo técnico**
> "Revisa los tickets y marca explícitamente como riesgo alto el del visor de partituras: integrar OpenSheetMusicDisplay (una librería JavaScript) dentro de Flutter mediante JS interop solo se puede garantizar en la versión Web. Refleja esa limitación de plataforma en los criterios de aceptación del ticket y asegúrate de que el test E2E del flujo principal contemple abrir y renderizar una partitura como paso final."

**Nota de guía:** se exigió formato Gherkin y prioridad MoSCoW en las historias, y trazabilidad explícita historia↔ticket en ambos sentidos. El asistente marcó el visor MusicXML como el principal riesgo técnico del MVP y lo dejó documentado, en coherencia con la decisión de alcance tomada en la sección 1. De estos prompts salieron las secciones 5 y 6 del README.
