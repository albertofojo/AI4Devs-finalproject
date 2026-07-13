# XANEE — Backend (FastAPI)

API REST del espacio de trabajo para agrupaciones musicales. Implementa el flujo
MVP (HU-01 a HU-06): perfiles, grupos, invitaciones, partituras, setlists, ensayos
y asistencia. Autenticación mediante JWT de **Supabase Auth** (verificación de firma
HS256); persistencia en **Postgres (Supabase)** en producción y **SQLite** en tests.

## Puesta en marcha (local)

```bash
cd backend
python -m venv .venv
# Windows PowerShell: .venv\Scripts\Activate.ps1   |  bash: source .venv/bin/activate
.venv/Scripts/python -m pip install -r requirements.txt

cp .env.example .env          # rellena SUPABASE_* y DATABASE_URL
python -m alembic upgrade head   # aplica el esquema (Postgres) — en dev SQLite se crea solo
python -m uvicorn app.main:app --reload   # http://localhost:8000  ·  docs: /docs
```

Con la configuración por defecto (`DATABASE_URL=sqlite:///./xanee_dev.db`,
`ENVIRONMENT=development`) el backend arranca sin necesidad de Supabase: crea las
tablas al vuelo. Para verificar tokens reales, define `SUPABASE_JWT_SECRET`.

## Tests

```bash
cd backend
.venv/Scripts/python -m pytest        # 13 tests: auth, invitaciones y flujo E2E
```

Los tests usan SQLite en memoria y firman JWTs equivalentes a los de Supabase, por
lo que la verificación real de firma se ejercita sin servicios externos.

## Estructura

```
app/
├── main.py            # FastAPI, CORS, wiring de routers, /health
├── core/              # config (Pydantic Settings) y security (JWT)
├── db/                # engine y sesión (portátil SQLite/Postgres)
├── models/            # tablas SQLModel (9 entidades)
├── schemas/           # DTOs Pydantic + enums de validación
├── api/               # routers: me, groups, invitations, scores, setlists, rehearsals
└── services/          # lógica de negocio (invitaciones)
alembic/               # migraciones (initial schema autogenerada)
tests/                 # pytest (unit + integración)
```

## Endpoints principales

Ver `/docs` (OpenAPI) con el servidor arrancado. Resumen en el README raíz §4.
