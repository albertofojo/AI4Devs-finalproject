"""Punto de entrada de la API XANEE (FastAPI)."""

from __future__ import annotations

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app import __version__
from app.api import (
    groups,
    invitations,
    me,
    rehearsals,
    scores,
    setlists,
)
from app.core.config import settings
from app.db.session import create_db_and_tables


@asynccontextmanager
async def lifespan(app: FastAPI):
    # En dev/test creamos las tablas al vuelo; en producción se usa Alembic.
    if settings.environment in {"development", "test"}:
        create_db_and_tables()
    yield


app = FastAPI(
    title="XANEE API",
    description="API del espacio de trabajo para agrupaciones musicales.",
    version=__version__,
    lifespan=lifespan,
)

# Orígenes permitidos:
# - los definidos explícitamente en CORS_ORIGINS (dominios propios/producción),
# - cualquier localhost:<puerto> (Flutter Web usa un puerto aleatorio en dev),
# - cualquier subdominio *.vercel.app (despliegues de la web; las URLs de Vercel
#   cambian por deploy, así que se cubren por patrón en lugar de una a una).
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1):\d+|https://[a-z0-9-]+\.vercel\.app",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health", tags=["health"])
def health() -> dict:
    return {"status": "ok", "service": "xanee-api", "version": __version__}


# Routers de dominio
app.include_router(me.router)
app.include_router(groups.router)
app.include_router(invitations.group_router)
app.include_router(invitations.invite_router)
app.include_router(scores.router)
app.include_router(setlists.group_router)
app.include_router(setlists.setlist_router)
app.include_router(rehearsals.group_router)
app.include_router(rehearsals.rehearsal_router)
