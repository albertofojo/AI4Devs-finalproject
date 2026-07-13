# Project Context: Plataforma Integral para Músicos y Agrupaciones

Este documento sirve como punto de partida, visión estratégica y contexto unificado para el desarrollo de la aplicación. Su objetivo es alinear al equipo de producto, diseño y desarrollo en la definición del Backend, Frontend, Arquitectura, UI/UX y Estrategia de Pruebas.

---

## 1. Visión General del Proyecto

La aplicación es un **ecosistema digital unificado** diseñado específicamente para resolver la fragmentación de herramientas que sufren los músicos individuales y las agrupaciones (bandas, orquestas, grupos tradicionales, escuelas). 

En lugar de depender de múltiples aplicaciones genéricas (WhatsApp para comunicación, Google Drive para partituras, Calendar para ensayos y la memoria para el mantenimiento de instrumentos), esta plataforma centraliza la utilidad musical bajo un enfoque colaborativo y de alta fiabilidad técnica.

### Filosofía del Producto (Visión CEO)
* **Utilidad sobre Red Social:** La plataforma no busca competir como una red social masiva de "muros vacíos". Se concibe como un **espacio de trabajo colaborativo (estilo Slack/Teams) optimizado para música**.
* **El "Grupo" como Motor de Crecimiento:** La unidad mínima de viralidad es la agrupación. Si un director o miembro adopta la app, arrastra al resto del grupo, generando un crecimiento orgánico y de alta retención.
* **Resiliencia en el Directo:** El software debe ser tan fiable en el escenario como lo es en el estudio de práctica.

---

## 2. Pilares Core del Producto (MVP)

### Pilar 1: Inventario de Instrumentos y Gestión de Mantenimiento
* **Descripción:** Registro digital personalizado de los activos más valiosos del músico.
* **Funcionalidades:**
  * Ficha detallada del instrumento (Marca, modelo, número de serie, tipo).
  * Acceso centralizado a manuales de usuario y consejos de conservación específicos (estructurados inicialmente por familias de instrumentos: viento, cuerda, percusión).
  * **Calendario de revisiones:** Historial de mantenimiento realizado (cambio de cuerdas, cañas, ajustes de luthier, zapatillas).
  * **Alertas inteligentes:** Avisos push/email para futuras revisiones predictivas o preventivas.

### Pilar 2: Espacio Colaborativo (Red, Amigos y Grupos)
* **Descripción:** Capa social y funcional que conecta a los músicos dentro de un entorno profesional o amateur controlado.
* **Funcionalidades:**
  * **Perfiles individuales:** Músicos con su instrumento principal, nivel, disponibilidad geográfica y equipamiento.
  * **El Concepto de "Grupo" (Banda/Orquesta):** Espacio cerrado gestionado por administradores/directores.
  * Canal de comunicación interna y tablón de anuncios enfocado exclusivamente en la actividad musical del grupo.

### Pilar 3: Gestor Inteligente de Partituras (Motor MusicXML)
* **Descripción:** Repositorio digital avanzado y dinámico para el almacenamiento y visualización de partituras.
* **Funcionalidades:**
  * **Estándar Abierto:** Uso de **MusicXML** como formato nativo para permitir la renderización adaptativa, transposición dinámica de tonalidad y reproducción de guías de audio.
  * **Colección Pública:** Acceso integrado a una biblioteca curada de partituras gratuitas de dominio público.
  * **Almacenamiento Privado:** Capacidad para que los usuarios o grupos suban sus propios archivos (respetando derechos de autor mediante acceso restringido).
  * **Organización:** Creación de repertorios, carpetas temáticas y *Setlists* (listas de temas para un concierto específico).

### Pilar 4: Gestión de Ensayos y Eventos
* **Descripción:** Herramienta logística para optimizar el tiempo de las agrupaciones musicales.
* **Funcionalidades:**
  * Convocatoria de ensayos con control de asistencia (Confirmado / Ausente / En duda).
  * **Vinculación Musical:** Posibilidad de asociar un *Setlist* específico de partituras al ensayo programado para que los músicos sepan exactamente qué estudiar antes de asistir.
  * Notas y comentarios específicos por sección o tema dentro de la convocatoria de ensayo.

---

## 3. Funcionalidades Estratégicas de Alto Impacto (Fase 1.5 - Escalamiento)

Para diferenciar el producto en el mercado y aportar un valor disruptivo, se integrarán las siguientes cuatro capacidades de vanguardia:

```
+------------------------------------------------------------------------+
|                      Ecosistema de la Aplicación                       |
+------------------------------------------------------------------------+
|  [Pilar 1: Inventario]   [Pilar 2: Grupos/Red]   [Pilar 3: Partituras] |
|                                                                        |
|         [Modo Directo]  <--- Sincronización en Escenario --->          |
|         [Grabación/Play] <--- Práctica Diaria en Casa --->             |
|         [Conectividad IoT] <--- Cuidado del Instrumento --->           |
|         [Bolsa Sustitutos] <--- Red de Emergencia (Geolocalizada) ---> |
+------------------------------------------------------------------------+
```

### A. Modo Directo (Stage Mode) con Control Manos Libres
* **Objetivo:** Convertir la app en la herramienta definitiva sobre el escenario.
* **Mecánica:** Interfaz de alto contraste, bajo consumo energético y **operación 100% offline**. Bloquea notificaciones del sistema para evitar interrupciones.
* **Efecto multiplicador:** Compatibilidad con pedales Bluetooth (vía HID) para pasar páginas inalámbricamente. **Sincronización en tiempo real:** Si el director pasa de página o cambia de tema en su tablet, la pantalla de todos los músicos conectados al grupo cambia simultáneamente.

### B. Grabadora de Ensayos y Asistente de Práctica (Play-Along)
* **Objetivo:** Conectar el trabajo grupal con el estudio individual diario en casa.
* **Mecánica:** Grabación de audio directamente desde la aplicación durante el ensayo, quedando el archivo automáticamente vinculado a la fecha del evento y al tema del repertorio.
* **Estudio en Casa:** El usuario puede reproducir el archivo MusicXML variando el *tempo* (sin alterar el tono) o mutear/aislar pistas específicas para practicar su parte por encima del acompañamiento.

### C. Conectividad con el Ecosistema Físico (IoT y Monitoreo de Clima)
* **Objetivo:** Proteger los activos físicos de alto valor del músico (instrumentos de madera, viento o cuerda tradicional expuestos a daños por humedad/temperatura).
* **Mecánica:** Vinculación por BLE (Bluetooth Low Energy) con sensores higrómetros colocados dentro del estuche del instrumento.
* **Acción Predictiva:** Alertas críticas al móvil si los niveles bajan o suben de rangos seguros (prevención de fisuras o desajustes). Cálculo de desgaste predictivo basado en las horas de uso registradas en los ensayos.

### D. Bolsa de Sustitutos y Músicos Invitados (El Botón del Pánico)
* **Objetivo:** Resolver emergencias logísticas de última hora (bajas por enfermedad, refuerzos necesarios para conciertos).
* **Mecánica:** Un grupo puede publicar una oferta de sustitución geolocalizada especificando instrumento, repertorio y remuneración/condiciones.
* **Acceso Efímero:** Al aceptar el "bolo", el músico sustituto recibe acceso temporal y restringido únicamente al *Setlist* y partituras de ese evento, integrándose en la dinámica del grupo de inmediato sin comprometer la privacidad a largo plazo de la agrupación.

---

## 4. Pilares Tecnológicos Sugeridos

Para guiar la próxima fase de definición técnica, se establecen los siguientes requisitos base:

* **Frontend:** Soporte multiplataforma (Mobile/Tablet es crítico para el uso en atriles). Se requiere alta fidelidad de renderizado para partituras y soporte para eventos Bluetooth (Pedales).
* **Backend:** Arquitectura orientada a servicios/microservicios capaz de gestionar conexiones en tiempo real de baja latencia (WebSockets/SSE) para la sincronización del Modo Directo.
* **Motor de Partituras:** Integración de librerías capaces de parsear y renderizar MusicXML de forma fluida y responsiva (ej. OpenSheetMusicDisplay o similares).
* **Estrategia Offline-First:** Las bases de datos locales (p. ej., SQLite/Room/CoreData) deben garantizar que las partituras, repertorios y modo directo funcionen sin conexión a internet.

---

## 5. Roadmap Estratégico de Desarrollo (Sugerido)

1. **Fase 1: MVP Utilitario Grupal:** Foco estricto en el **Pilar 2 (Grupos)**, **Pilar 3 (Partituras locales/subidas)** y **Pilar 4 (Gestión de Ensayos básicos)**.
2. **Fase 2: Robustez Musical & Escenario:** Implementación del motor dinámico MusicXML avanzado y el **Modo Directo (Sincronización)**.
3. **Fase 3: Utilidad Individual e IoT:** Despliegue del **Pilar 1 (Inventario)** enriquecido con la **Conectividad IoT** y la **Grabadora/Play-Along**.
4. **Fase 4: Red y Ecosistema Abierto:** Apertura de la **Bolsa de Sustitutos**, perfiles públicos de músicos y herramientas de descubrimiento de red.
