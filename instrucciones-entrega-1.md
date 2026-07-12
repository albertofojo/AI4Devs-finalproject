# ✅ Entrega 1 — Qué tengo que hacer mañana

> **Tipo de entrega:** Documentación técnica (sin código todavía).
> **Qué se entrega:** `README.md` + `prompts.md` en una rama de Pull Request, y la URL del PR en el formulario.
> **Iniciales:** AFE → rama `feature-entrega1-AFE`.

---

## 0. Antes de empezar — completar los datos pendientes

Abre `README.md` y rellena los 3 huecos marcados como `_[Pendiente...]_`:

- [ ] **0.1. Nombre completo** — pon tu nombre real.
- [ ] **0.5. URL del repositorio** — la añades una vez creado el repo (paso 2).
- [ ] **0.2 / título** — confirma si te quedas con el nombre **"Tutti"** o usas otro (si lo cambias, cámbialo también en el resto del README).
- [ ] **0.4. URL del proyecto** — déjala como _Pendiente_; el despliegue es de la Entrega final.

> El `prompts.md` ya está listo, no requiere edición.

---

## 1. Preparar el repositorio de la plantilla

La entrega se hace sobre la plantilla oficial **AI4Devs-finalproject**.

- [ ] Entra en https://github.com/LIDR-academy/AI4Devs-finalproject
- [ ] Haz **Fork** a tu cuenta de GitHub (o usa "Use this template" si lo prefieres como repo nuevo).
- [ ] Clónalo en tu máquina:

```powershell
git clone https://github.com/<tu-usuario>/AI4Devs-finalproject.git
cd AI4Devs-finalproject
```

- [ ] Decide visibilidad:
  - Si lo dejas **privado**, anota que tendrás que **dar acceso a tu TA** (paso 6).
  - Público también es válido.

---

## 2. Crear la rama de la Entrega 1

⚠️ **El nombre de la rama DEBE contener tus iniciales** o la entrega no se identifica.

```powershell
git checkout -b feature-entrega1-AFE
```

- [ ] Vuelve al `README.md` y rellena **0.5** con la URL de tu repo recién creado.

---

## 3. Copiar la documentación a la plantilla

Copia los dos ficheros generados a la raíz del repo clonado, **sustituyendo** los de la plantilla:

- [ ] `README.md`  ← el de este proyecto (`D:\src\lidr-final-project\README.md`)
- [ ] `prompts.md` ← el de este proyecto (`D:\src\lidr-final-project\prompts.md`)

```powershell
copy "D:\src\lidr-final-project\README.md"  ".\README.md"
copy "D:\src\lidr-final-project\prompts.md" ".\prompts.md"
```

- [ ] Abre el `README.md` en GitHub (o en VS Code con vista previa) y **comprueba que los diagramas Mermaid se renderizan** (arquitectura, infraestructura y modelo de datos ER).

---

## 4. Commit y push

```powershell
git add README.md prompts.md
git commit -m "Entrega 1: documentacion tecnica (producto, arquitectura, modelo de datos, API, historias y tickets)"
git push -u origin feature-entrega1-AFE
```

---

## 5. Abrir el Pull Request

- [ ] En GitHub, abre un **Pull Request** desde `feature-entrega1-AFE` hacia la rama principal de tu repo.
- [ ] **Título claro**, por ejemplo:
  `Entrega 1 - Documentación técnica (Tutti) - AFE`
- [ ] **Descripción detallada** (qué incluye y por qué). Puedes usar esta plantilla:

```markdown
## Entrega 1 — Documentación técnica

Incluye la documentación inicial del proyecto **Tutti** (plataforma para músicos
y agrupaciones), siguiendo la estructura de la plantilla AI4Devs-finalproject.

### Contenido
- README.md: ficha, descripción de producto, arquitectura (con diagramas),
  modelo de datos relacional, especificación de la API, historias de usuario y tickets.
- prompts.md: prompts clave que guiaron las decisiones de producto, arquitectura,
  modelo de datos, API e historias/tickets.

### Alcance del MVP
Flujo E2E: un director crea un grupo → invita músicos → programa un ensayo con un
Setlist de partituras → los músicos confirman asistencia y abren la partitura.

### Stack
Flutter (web) · FastAPI (Python) · Supabase (Postgres + Auth + Storage) ·
OpenSheetMusicDisplay para render MusicXML.
```

- [ ] Copia la **URL del Pull Request** (la necesitas en el paso siguiente).

---

## 6. Si el repo es privado: dar acceso al TA

- [ ] En GitHub → **Settings → Collaborators** → añade a tu TA por su handle de GitHub o correo.
- [ ] (Recomendado) Avísale de que ya tiene acceso.

---

## 7. Entrega oficial — formulario Typeform

- [ ] Rellena el formulario: 👉 https://lidr.typeform.com/proyectoai4devs
- [ ] Incluye la **URL del Pull Request** de la Entrega 1.

---

## 🔎 Checklist final antes de enviar

- [ ] Nombre completo rellenado en el README (0.1).
- [ ] URL del repo rellenada en el README (0.5).
- [ ] `README.md` y `prompts.md` en la rama, con los diagramas Mermaid renderizando bien.
- [ ] Rama con las iniciales: `feature-entrega1-AFE`.
- [ ] Pull Request abierto con título y descripción claros.
- [ ] Acceso dado al TA (si el repo es privado).
- [ ] Formulario Typeform enviado con la URL del PR.

---

## ⚠️ Nota sobre la fecha

La guía oficial fija la Entrega 1 en el **miércoles 27 de mayo de 2026**. Como hoy es
posterior, **confirma con tu TA** que sigues en plazo al entregar mañana, o si necesitas
indicarlo al enviar el formulario.
