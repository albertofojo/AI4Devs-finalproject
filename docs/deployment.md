# Guía de despliegue — XANEE

Arquitectura de despliegue: **API FastAPI** en Render (Docker) · **Web Flutter** en
Firebase Hosting (o Vercel) · **Datos/Auth/Storage** en Supabase.

## Requisitos previos

1. Proyecto Supabase provisionado (ver [`setup-supabase.md`](setup-supabase.md)).
2. Repo en GitHub con este monorepo.
3. Cuentas gratuitas en Render y Firebase (o Vercel).

## 1. Base de datos (Supabase Postgres)

Aplica el esquema con Alembic apuntando a la BD de Supabase:

```bash
cd backend
DATABASE_URL="postgresql://postgres.<ref>:<pwd>@...pooler.supabase.com:5432/postgres" \
  .venv/Scripts/python -m alembic upgrade head
```

## 2. Backend (Render, Docker)

- El repo incluye [`render.yaml`](../render.yaml) (Blueprint) y `backend/Dockerfile`.
- En Render: **New → Blueprint** → selecciona el repo. Render detecta `render.yaml`.
- Rellena las variables `sync:false` en el panel:
  `DATABASE_URL`, `SUPABASE_URL`, `SUPABASE_JWT_SECRET`, `SUPABASE_SERVICE_ROLE_KEY`,
  `CORS_ORIGINS` (incluye el dominio del frontend).
- Health check: `GET /health`. Docs OpenAPI: `/docs`.

Resultado: `https://xanee-api.onrender.com` (o el subdominio asignado).

## 3. Frontend (Firebase Hosting)

```bash
cd frontend
flutter build web --release --no-tree-shake-icons \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key> \
  --dart-define=API_BASE_URL=https://xanee-api.onrender.com

npm i -g firebase-tools
firebase login
firebase init hosting     # public dir: build/web (ya configurado en firebase.json)
firebase deploy --only hosting
```

Resultado: `https://<proyecto>.web.app`.

> **Alternativa Vercel:** `vercel.json` incluido; despliega el directorio `build/web`
> como estático. Inyecta las mismas `--dart-define` en el build.

## 4. Cerrar el círculo

- Añade el dominio del frontend a `CORS_ORIGINS` del backend (Render).
- En Supabase → Authentication → URL Configuration, añade el dominio del frontend
  a *Redirect URLs* / *Site URL*.
- Verifica el flujo E2E en la URL pública: registro → grupo → invitar → subir
  partitura → setlist → ensayo → asistencia → abrir partitura.

## CI/CD

`.github/workflows/ci.yml` ejecuta en cada push/PR: tests del backend (pytest),
`flutter analyze`, `flutter test` y `flutter build web`. El despliegue puede
automatizarse añadiendo pasos de deploy (Render deploy hook / Firebase action) con
los secretos correspondientes en GitHub.
