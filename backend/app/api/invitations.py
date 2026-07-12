"""Routers de invitaciones (HU-03)."""

from __future__ import annotations

from fastapi import APIRouter, Depends, status
from sqlmodel import Session

from app.api.deps import require_group_admin
from app.core.security import get_current_user
from app.db.session import get_session
from app.models import Group, User
from app.schemas import InvitationCreate, InvitationRead
from app.services.invitations import accept_invitation, create_invitation

# Crear invitación: cuelga de un grupo y requiere rol admin.
group_router = APIRouter(prefix="/api/groups", tags=["invitations"])
# Aceptar invitación: por token, cualquier usuario autenticado.
invite_router = APIRouter(prefix="/api/invitations", tags=["invitations"])


@group_router.post(
    "/{group_id}/invitations",
    response_model=InvitationRead,
    status_code=status.HTTP_201_CREATED,
)
def invite_member(
    payload: InvitationCreate,
    group: Group = Depends(require_group_admin),
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> InvitationRead:
    invitation = create_invitation(
        session,
        group_id=group.id,
        email=str(payload.email),
        invited_by=user.id,
        expires_in_hours=payload.expires_in_hours,
    )
    return invitation


@invite_router.post("/{token}/accept", status_code=status.HTTP_200_OK)
def accept(
    token: str,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> dict:
    membership = accept_invitation(session, token=token, user_id=user.id)
    return {
        "group_id": membership.group_id,
        "role": membership.role,
        "status": membership.status,
    }
