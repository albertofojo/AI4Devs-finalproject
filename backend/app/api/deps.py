"""Dependencias de autorización reutilizables por los routers de dominio."""

from __future__ import annotations

from fastapi import Depends, HTTPException, status
from sqlmodel import Session, select

from app.core.security import get_current_user
from app.db.session import get_session
from app.models import Group, Membership, User


def get_membership(session: Session, group_id: str, user_id: str) -> Membership | None:
    return session.exec(
        select(Membership).where(
            Membership.group_id == group_id,
            Membership.user_id == user_id,
            Membership.status == "active",
        )
    ).first()


def require_group(
    group_id: str,
    session: Session = Depends(get_session),
    user: User = Depends(get_current_user),
) -> Group:
    """El usuario debe ser miembro activo del grupo. Devuelve el grupo."""
    group = session.get(Group, group_id)
    if group is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Grupo no encontrado")
    if get_membership(session, group_id, user.id) is None:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "No perteneces a este grupo")
    return group


def require_group_admin(
    group_id: str,
    session: Session = Depends(get_session),
    user: User = Depends(get_current_user),
) -> Group:
    """El usuario debe ser administrador del grupo. Devuelve el grupo."""
    group = session.get(Group, group_id)
    if group is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Grupo no encontrado")
    membership = get_membership(session, group_id, user.id)
    if membership is None:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "No perteneces a este grupo")
    if membership.role != "admin":
        raise HTTPException(
            status.HTTP_403_FORBIDDEN, "Se requiere rol de administrador"
        )
    return group
