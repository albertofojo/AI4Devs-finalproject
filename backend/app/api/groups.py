"""Router de grupos (HU-02)."""

from __future__ import annotations

from fastapi import APIRouter, Depends, status
from sqlmodel import Session, select

from app.api.deps import get_membership, require_group
from app.core.security import get_current_user
from app.db.session import get_session
from app.models import Group, Membership, User
from app.schemas import GroupCreate, GroupRead

router = APIRouter(prefix="/api/groups", tags=["groups"])


def _to_read(group: Group, role: str | None) -> GroupRead:
    return GroupRead(
        id=group.id,
        name=group.name,
        type=group.type,
        description=group.description,
        created_by=group.created_by,
        created_at=group.created_at,
        my_role=role,
    )


@router.post("", response_model=GroupRead, status_code=status.HTTP_201_CREATED)
def create_group(
    payload: GroupCreate,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> GroupRead:
    group = Group(
        name=payload.name,
        type=payload.type.value,
        description=payload.description,
        created_by=user.id,
    )
    session.add(group)
    session.flush()  # asegura group.id
    membership = Membership(
        group_id=group.id, user_id=user.id, role="admin", status="active"
    )
    session.add(membership)
    session.commit()
    session.refresh(group)
    return _to_read(group, "admin")


@router.get("", response_model=list[GroupRead])
def list_my_groups(
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> list[GroupRead]:
    rows = session.exec(
        select(Group, Membership)
        .join(Membership, Membership.group_id == Group.id)
        .where(Membership.user_id == user.id, Membership.status == "active")
    ).all()
    return [_to_read(g, m.role) for g, m in rows]


@router.get("/{group_id}", response_model=GroupRead)
def get_group(
    group: Group = Depends(require_group),
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> GroupRead:
    membership = get_membership(session, group.id, user.id)
    return _to_read(group, membership.role if membership else None)
