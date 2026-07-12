"""Verificación de JWT de Supabase Auth y dependencias de usuario actual.

El backend no emite tokens: valida los JWT que emite Supabase Auth (HS256 firmados
con el `SUPABASE_JWT_SECRET`). El claim `sub` es el id del usuario (= auth.users.id).
En la primera petición autenticada se hace *upsert* del perfil en la tabla `users`.
"""

from __future__ import annotations

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jwt import PyJWKClient
from sqlmodel import Session, select

from app.core.config import settings
from app.db.session import get_session
from app.models import User

_bearer = HTTPBearer(auto_error=False)

# Cliente JWKS para verificar los tokens asimétricos (ES256/RS256) de Supabase.
# Supabase firma los access tokens con claves de firma rotables publicadas en el
# endpoint JWKS; la verificación usa la clave pública correspondiente al `kid`.
_jwk_client: PyJWKClient | None = None


def _get_jwk_client() -> PyJWKClient:
    global _jwk_client
    if _jwk_client is None:
        _jwk_client = PyJWKClient(
            f"{settings.supabase_url}/auth/v1/.well-known/jwks.json"
        )
    return _jwk_client


class TokenPayload:
    """Datos mínimos extraídos del JWT verificado."""

    def __init__(self, sub: str, email: str | None):
        self.sub = sub
        self.email = email


def decode_token(token: str) -> TokenPayload:
    """Verifica la firma y la expiración del JWT. Lanza 401 si es inválido.

    Soporta los dos esquemas de Supabase Auth:
    - **ES256/RS256** (asimétrico, por defecto en proyectos nuevos): verifica con la
      clave pública del JWKS según el `kid` del token.
    - **HS256** (simétrico, legacy y usado en la suite de tests): verifica con
      `SUPABASE_JWT_SECRET`.
    """
    try:
        alg = jwt.get_unverified_header(token).get("alg", "")
        if alg == "HS256":
            payload = jwt.decode(
                token,
                settings.supabase_jwt_secret,
                algorithms=["HS256"],
                options={"verify_aud": False},
            )
        else:
            signing_key = _get_jwk_client().get_signing_key_from_jwt(token)
            payload = jwt.decode(
                token,
                signing_key.key,
                algorithms=["ES256", "RS256"],
                options={"verify_aud": False},
            )
    except jwt.ExpiredSignatureError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Token expirado"
        ) from exc
    except jwt.InvalidTokenError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Token inválido"
        ) from exc
    except jwt.PyJWKClientError as exc:  # error al obtener/seleccionar la clave JWKS
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="No se pudo verificar la clave del token",
        ) from exc

    sub = payload.get("sub")
    if not sub:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Token sin 'sub'"
        )
    return TokenPayload(sub=sub, email=payload.get("email"))


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer),
    session: Session = Depends(get_session),
) -> User:
    """Dependencia FastAPI: devuelve el `User` autenticado, creándolo si no existe."""
    if credentials is None or not credentials.credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Falta el token de autenticación",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token_data = decode_token(credentials.credentials)

    user = session.get(User, token_data.sub)
    if user is None:
        # upsert por email por si el perfil se creó con otro flujo
        if token_data.email:
            existing = session.exec(
                select(User).where(User.email == token_data.email)
            ).first()
            if existing is not None:
                return existing
        user = User(
            id=token_data.sub,
            email=token_data.email or f"{token_data.sub}@no-email.local",
        )
        session.add(user)
        session.commit()
        session.refresh(user)
    return user
