"""Lógica de negocio de invitaciones a grupo (HU-03)."""

from __future__ import annotations

import secrets
from datetime import datetime, timedelta, timezone

from fastapi import HTTPException, status
from sqlmodel import Session, select

from app.models import Invitation, Membership


def create_invitation(
    session: Session, group_id: str, email: str, invited_by: str, expires_in_hours: int
) -> Invitation:
    invitation = Invitation(
        group_id=group_id,
        email=email.lower(),
        token=secrets.token_urlsafe(32),
        status="pending",
        invited_by=invited_by,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=expires_in_hours),
    )
    session.add(invitation)
    session.commit()
    session.refresh(invitation)
    return invitation


def _as_utc(dt: datetime) -> datetime:
    """Normaliza a UTC-aware (SQLite puede devolver datetimes naive)."""
    return dt if dt.tzinfo is not None else dt.replace(tzinfo=timezone.utc)


def accept_invitation(session: Session, token: str, user_id: str) -> Membership:
    invitation = session.exec(
        select(Invitation).where(Invitation.token == token)
    ).first()
    if invitation is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Invitación no encontrada")

    # Idempotencia: si ya es miembro activo, devolvemos su membresía.
    existing = session.exec(
        select(Membership).where(
            Membership.group_id == invitation.group_id,
            Membership.user_id == user_id,
        )
    ).first()
    if existing is not None and existing.status == "active":
        return existing

    if invitation.status == "accepted":
        raise HTTPException(status.HTTP_409_CONFLICT, "La invitación ya fue aceptada")

    now = datetime.now(timezone.utc)
    if invitation.status == "expired" or _as_utc(invitation.expires_at) < now:
        invitation.status = "expired"
        session.add(invitation)
        session.commit()
        raise HTTPException(status.HTTP_409_CONFLICT, "La invitación ha caducado")

    if existing is not None:
        existing.status = "active"
        existing.role = existing.role or "member"
        membership = existing
    else:
        membership = Membership(
            group_id=invitation.group_id,
            user_id=user_id,
            role="member",
            status="active",
        )
    invitation.status = "accepted"
    session.add(membership)
    session.add(invitation)
    session.commit()
    session.refresh(membership)
    return membership
