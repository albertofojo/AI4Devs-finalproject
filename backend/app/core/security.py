"""Verificación de JWT de Supabase Auth y dependencias de usuario actual.

El backend no emite tokens: valida los JWT que emite Supabase Auth (HS256 firmados
con el `SUPABASE_JWT_SECRET`). El claim `sub` es el id del usuario (= auth.users.id).
En la primera petición autenticada se hace *upsert* del perfil en la tabla `users`.
"""

from __future__ import annotations

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlmodel import Session, select

from app.core.config import settings
from app.db.session import get_session
from app.models import User

_bearer = HTTPBearer(auto_error=False)


class TokenPayload:
    """Datos mínimos extraídos del JWT verificado."""

    def __init__(self, sub: str, email: str | None):
        self.sub = sub
        self.email = email


def decode_token(token: str) -> TokenPayload:
    """Verifica la firma y la expiración del JWT. Lanza 401 si es inválido."""
    try:
        payload = jwt.decode(
            token,
            settings.supabase_jwt_secret,
            algorithms=["HS256"],
            audience="authenticated",
            options={"verify_aud": False},  # Supabase usa aud="authenticated"; toleramos ausencia
        )
    except jwt.ExpiredSignatureError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Token expirado"
        ) from exc
    except jwt.InvalidTokenError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Token inválido"
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
