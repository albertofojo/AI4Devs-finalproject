"""Router de perfil del usuario autenticado (HU-01)."""

from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlmodel import Session

from app.core.security import get_current_user
from app.db.session import get_session
from app.models import User
from app.schemas import MeUpdate, UserRead

router = APIRouter(prefix="/api", tags=["me"])


@router.get("/me", response_model=UserRead)
def read_me(user: User = Depends(get_current_user)) -> User:
    return user


@router.put("/me", response_model=UserRead)
def update_me(
    payload: MeUpdate,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> User:
    data = payload.model_dump(exclude_unset=True)
    for key, value in data.items():
        setattr(user, key, value.value if hasattr(value, "value") else value)
    session.add(user)
    session.commit()
    session.refresh(user)
    return user
