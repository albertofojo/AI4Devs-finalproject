"""Configuración de pytest: BD SQLite en memoria y cliente autenticado.

Cada test corre contra una base de datos SQLite en memoria aislada (StaticPool para
que todas las sesiones compartan la misma conexión). Los JWT se firman con el mismo
`SUPABASE_JWT_SECRET` que usa la app, de modo que la verificación real de firma se
ejercita sin necesidad de un Supabase en marcha.
"""

from __future__ import annotations

import os

os.environ.setdefault("ENVIRONMENT", "test")
os.environ.setdefault("DATABASE_URL", "sqlite://")
os.environ.setdefault("SUPABASE_JWT_SECRET", "test-secret-xanee")

import time
from collections.abc import Iterator

import jwt
import pytest
from fastapi.testclient import TestClient
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from app.core.config import settings
from app.db.session import get_session
from app.main import app

# --- Motor de test compartido (in-memory) ---
_test_engine = create_engine(
    "sqlite://",
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)


@pytest.fixture(autouse=True)
def _fresh_db() -> Iterator[None]:
    import app.models  # noqa: F401  registra las tablas

    SQLModel.metadata.create_all(_test_engine)
    yield
    SQLModel.metadata.drop_all(_test_engine)


def _get_test_session() -> Iterator[Session]:
    with Session(_test_engine) as session:
        yield session


app.dependency_overrides[get_session] = _get_test_session


@pytest.fixture
def client() -> Iterator[TestClient]:
    with TestClient(app) as c:
        yield c


def make_token(user_id: str, email: str) -> str:
    """Firma un JWT HS256 equivalente al de Supabase Auth."""
    payload = {
        "sub": user_id,
        "email": email,
        "aud": "authenticated",
        "exp": int(time.time()) + 3600,
    }
    return jwt.encode(payload, settings.supabase_jwt_secret, algorithm="HS256")


def auth(user_id: str, email: str) -> dict:
    """Cabecera Authorization Bearer para un usuario dado."""
    return {"Authorization": f"Bearer {make_token(user_id, email)}"}


@pytest.fixture
def alice() -> dict:
    return auth("11111111-1111-1111-1111-111111111111", "alice@example.com")


@pytest.fixture
def bob() -> dict:
    return auth("22222222-2222-2222-2222-222222222222", "bob@example.com")
