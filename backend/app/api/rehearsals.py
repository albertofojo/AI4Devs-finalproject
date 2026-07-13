"""Routers de ensayos y asistencia (HU-05, HU-06)."""

from __future__ import annotations

from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select

from app.api.deps import get_membership, require_group, require_group_admin
from app.core.security import get_current_user
from app.db.session import get_session
from app.models import (
    Attendance,
    Group,
    Membership,
    Rehearsal,
    Setlist,
    SetlistItem,
    User,
)
from app.schemas import (
    AttendanceSummary,
    AttendanceWrite,
    RehearsalCreate,
    RehearsalDetail,
    SetlistRead,
)

group_router = APIRouter(prefix="/api/groups", tags=["rehearsals"])
rehearsal_router = APIRouter(prefix="/api/rehearsals", tags=["rehearsals"])


@group_router.post(
    "/{group_id}/rehearsals",
    response_model=RehearsalDetail,
    status_code=status.HTTP_201_CREATED,
)
def create_rehearsal(
    payload: RehearsalCreate,
    group: Group = Depends(require_group_admin),
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> RehearsalDetail:
    if payload.setlist_id is not None:
        setlist = session.get(Setlist, payload.setlist_id)
        if setlist is None or setlist.group_id != group.id:
            raise HTTPException(
                status.HTTP_400_BAD_REQUEST,
                "El setlist no existe o no pertenece a este grupo",
            )
    rehearsal = Rehearsal(
        group_id=group.id,
        setlist_id=payload.setlist_id,
        title=payload.title,
        location=payload.location,
        starts_at=payload.starts_at,
        ends_at=payload.ends_at,
        notes=payload.notes,
        created_by=user.id,
    )
    session.add(rehearsal)
    session.commit()
    session.refresh(rehearsal)
    return _detail(session, rehearsal, user.id)


@group_router.get("/{group_id}/rehearsals", response_model=list[RehearsalDetail])
def list_rehearsals(
    group: Group = Depends(require_group),
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> list[RehearsalDetail]:
    rehearsals = session.exec(
        select(Rehearsal)
        .where(Rehearsal.group_id == group.id)
        .order_by(Rehearsal.starts_at)
    ).all()
    return [_detail(session, r, user.id) for r in rehearsals]


@rehearsal_router.get("/{rehearsal_id}", response_model=RehearsalDetail)
def get_rehearsal(
    rehearsal_id: str,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> RehearsalDetail:
    rehearsal = _load(session, rehearsal_id)
    if get_membership(session, rehearsal.group_id, user.id) is None:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "No perteneces a este grupo")
    return _detail(session, rehearsal, user.id)


@rehearsal_router.put("/{rehearsal_id}/attendance", response_model=RehearsalDetail)
def set_attendance(
    rehearsal_id: str,
    payload: AttendanceWrite,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> RehearsalDetail:
    rehearsal = _load(session, rehearsal_id)
    if get_membership(session, rehearsal.group_id, user.id) is None:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "No perteneces a este grupo")

    # Upsert idempotente por (rehearsal, user).
    attendance = session.exec(
        select(Attendance).where(
            Attendance.rehearsal_id == rehearsal_id,
            Attendance.user_id == user.id,
        )
    ).first()
    if attendance is None:
        attendance = Attendance(
            rehearsal_id=rehearsal_id, user_id=user.id, status=payload.status.value
        )
    else:
        attendance.status = payload.status.value
        attendance.responded_at = datetime.now(timezone.utc)
    session.add(attendance)
    session.commit()
    return _detail(session, rehearsal, user.id)


# ----- helpers -----
def _load(session: Session, rehearsal_id: str) -> Rehearsal:
    rehearsal = session.get(Rehearsal, rehearsal_id)
    if rehearsal is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Ensayo no encontrado")
    return rehearsal


def _detail(session: Session, rehearsal: Rehearsal, user_id: str) -> RehearsalDetail:
    # Setlist asociado (con items ordenados)
    setlist_read: SetlistRead | None = None
    if rehearsal.setlist_id:
        setlist = session.get(Setlist, rehearsal.setlist_id)
        if setlist is not None:
            items = session.exec(
                select(SetlistItem)
                .where(SetlistItem.setlist_id == setlist.id)
                .order_by(SetlistItem.position)
            ).all()
            setlist_read = SetlistRead(
                id=setlist.id,
                group_id=setlist.group_id,
                name=setlist.name,
                description=setlist.description,
                created_by=setlist.created_by,
                created_at=setlist.created_at,
                items=items,
            )

    # Resumen de asistencia
    attendances = session.exec(
        select(Attendance).where(Attendance.rehearsal_id == rehearsal.id)
    ).all()
    members = session.exec(
        select(Membership).where(
            Membership.group_id == rehearsal.group_id,
            Membership.status == "active",
        )
    ).all()
    counts = {"confirmed": 0, "absent": 0, "maybe": 0}
    my_status: str | None = None
    for a in attendances:
        if a.status in counts:
            counts[a.status] += 1
        if a.user_id == user_id:
            my_status = a.status
    pending = max(len(members) - len(attendances), 0)
    summary = AttendanceSummary(pending=pending, **counts)

    return RehearsalDetail(
        id=rehearsal.id,
        group_id=rehearsal.group_id,
        title=rehearsal.title,
        location=rehearsal.location,
        starts_at=rehearsal.starts_at,
        ends_at=rehearsal.ends_at,
        setlist_id=rehearsal.setlist_id,
        notes=rehearsal.notes,
        created_by=rehearsal.created_by,
        created_at=rehearsal.created_at,
        setlist=setlist_read,
        attendance_summary=summary,
        my_attendance=my_status,
    )
