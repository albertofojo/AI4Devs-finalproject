"""Motor de base de datos y gestión de sesiones (SQLModel / SQLAlchemy).

Portátil: SQLite en desarrollo/tests, Postgres (Supabase) en producción.
"""

from __future__ import annotations

from collections.abc import Iterator

from sqlalchemy.engine import Engine
from sqlmodel import Session, SQLModel, create_engine

from app.core.config import settings


def _make_engine(url: str) -> Engine:
    connect_args: dict = {}
    kwargs: dict = {"echo": False, "pool_pre_ping": True}
    if url.startswith("sqlite"):
        connect_args = {"check_same_thread": False}
        # pool_pre_ping no aplica a SQLite in-memory
        kwargs.pop("pool_pre_ping", None)
    return create_engine(url, connect_args=connect_args, **kwargs)


engine: Engine = _make_engine(settings.database_url)


def create_db_and_tables() -> None:
    """Crea las tablas a partir de los modelos (útil en dev/test; en prod usar Alembic)."""
    # Importa los modelos para registrarlos en el metadata antes de create_all.
    import app.models  # noqa: F401

    SQLModel.metadata.create_all(engine)


def get_session() -> Iterator[Session]:
    """Dependencia FastAPI: abre una sesión por petición."""
    with Session(engine) as session:
        yield session
