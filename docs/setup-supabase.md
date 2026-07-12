# Guía rápida — Provisionar Supabase para XANEE (~5 min)

Necesitamos Supabase para tres cosas: **Auth** (login/registro y emisión de JWT),
**Postgres** (base de datos del backend) y **Storage** (ficheros de partitura).

## 1. Crear el proyecto

1. Entra en <https://supabase.com> → **Sign in** (GitHub) → **New project**.
2. Nombre: `xanee`. Contraseña de BD: genera una fuerte y **guárdala**.
3. Región: la más cercana (p. ej. `West EU (Ireland)`). Plan **Free**.
4. Espera ~2 min a que se aprovisione.

## 2. Copiar las 3 claves (Project Settings → API)

| Clave | Dónde | Se usa en |
|---|---|---|
| **Project URL** | Settings → API → *Project URL* | `SUPABASE_URL` (front y back) |
| **anon public** | Settings → API → *Project API keys → anon* | `SUPABASE_ANON_KEY` (frontend) |
| **JWT Secret** | Settings → API → *JWT Settings → JWT Secret* | `SUPABASE_JWT_SECRET` (backend) |
| **service_role** | Settings → API → *Project API keys → service_role* | `SUPABASE_SERVICE_ROLE_KEY` (backend, opcional) |

> ⚠️ `service_role` y `JWT Secret` son **secretos de backend**: nunca en el frontend ni en el repo.

## 3. Cadena de conexión de Postgres (para el backend)

Settings → **Database** → *Connection string* → **URI**. Copia la que usa el
**pooler** (puerto 6543, modo *transaction*) para producción, o la directa (5432)
para migraciones. Formato:

```
postgresql://postgres.<ref>:<password>@aws-0-<region>.pooler.supabase.com:6543/postgres
```

Esto va en `DATABASE_URL` del backend. Para aplicar el esquema:

```bash
cd backend
DATABASE_URL="postgresql://..." .venv/Scripts/python -m alembic upgrade head
```

## 4. Crear el bucket de Storage

1. En el panel → **Storage** → **New bucket**.
2. Nombre: `scores`. Marca **Public** (para el MVP; las URLs de partitura serán
   accesibles vía link) o déjalo privado y usaremos URLs firmadas.
3. (Opcional) Políticas: permitir `insert`/`select` a usuarios autenticados.

## 5. Configuración de Auth

- **Authentication → Providers → Email**: activado (por defecto).
- Para desarrollo, **Authentication → Sign In / Providers → Email → "Confirm email"**:
  puedes **desactivarlo** para que el registro no requiera confirmación por correo
  (agiliza pruebas y el test E2E). En producción, reactívalo.

## 6. Rellenar los `.env`

**backend/.env**
```
DATABASE_URL=postgresql://postgres.<ref>:<pwd>@...pooler.supabase.com:6543/postgres
SUPABASE_URL=https://<ref>.supabase.co
SUPABASE_JWT_SECRET=<jwt-secret>
SUPABASE_SERVICE_ROLE_KEY=<service-role>
SUPABASE_STORAGE_BUCKET=scores
ENVIRONMENT=production
CORS_ORIGINS=http://localhost:8080,https://<tu-dominio-web>
```

**frontend/.env** (o `--dart-define`)
```
SUPABASE_URL=https://<ref>.supabase.co
SUPABASE_ANON_KEY=<anon-key>
API_BASE_URL=http://localhost:8000
```

Cuando tengas estas claves, pásamelas (o ponlas tú en los `.env`) y conectamos el
frontend y el despliegue contra auth real.
