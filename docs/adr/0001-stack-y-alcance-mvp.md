# ADR 0001 — Stack tecnológico y alcance del MVP

- **Estado:** Aceptado
- **Fecha:** 2026-07-13
- **Autor:** Alberto Fojo Eiras (AFE)

## Contexto

XANEE es el proyecto final del Máster AI4Devs (LIDR). La Entrega 1 (documentación
técnica) definió producto, arquitectura, modelo de datos, API, historias y tickets.
Esta ADR fija las decisiones que gobiernan la implementación (Entregas 2 y 3).

## Decisión

Se implementa el stack **fiel al README**:

- **Backend:** FastAPI (Python 3.13) con SQLModel/SQLAlchemy + Alembic.
- **Frontend:** Flutter Web (Dart), organización *feature-first* (data/domain/presentation).
- **BaaS:** Supabase — Auth (JWT), Postgres y Storage (partituras).
- **Visor de partituras:** OpenSheetMusicDisplay (JS) integrado en Flutter Web vía JS interop.
- **Despliegue:** API en Render/Cloud Run, Web en Vercel/Firebase Hosting, datos en Supabase.
- **CI/CD:** GitHub Actions (lint + tests + deploy).

### Alcance del MVP (evaluable)

Flujo E2E completo de las historias **HU-01 a HU-06** (Must-Have):
login → crear grupo → invitar músicos → subir/ver partitura MusicXML →
crear Setlist → programar ensayo → confirmar asistencia.

Fuera del MVP (roadmap documentado, no evaluable): Modo Directo, grabadora/Play-Along,
inventario+IoT, bolsa de sustitutos, transposición (HU-07) y notas por tema (HU-08).

## Consecuencias

- **Portabilidad de datos para poder testear sin Supabase en marcha:** los modelos usan
  identificadores UUID como texto y tipos portables, de modo que la suite de tests corre
  contra **SQLite** en memoria, mientras producción usa **Postgres (Supabase)**. Solo se
  cambia `DATABASE_URL`.
- **Verificación de JWT** con HS256 usando `SUPABASE_JWT_SECRET`; el `sub` del token es el
  `id` del usuario (= `auth.users.id`). El backend hace *upsert* del perfil en `users`.
- **Riesgo asumido:** la integración del visor MusicXML (OpenSheetMusicDisplay) en Flutter
  Web es la pieza de mayor riesgo (TK-10); se aísla en un widget con fallback a descarga/PDF.
- **Prórroga:** se solicita la prórroga de hasta 2 semanas prevista por la guía para poder
  entregar con tests reales y despliegue verificado.
