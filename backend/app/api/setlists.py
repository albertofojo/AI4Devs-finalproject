"""Routers de setlists (HU-05)."""

from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select

from app.api.deps import get_membership, require_group
from app.core.security import get_current_user
from app.db.session import get_session
from app.models import Group, Score, Setlist, SetlistItem, User
from app.schemas import SetlistCreate, SetlistItemCreate, SetlistRead

group_router = APIRouter(prefix="/api/groups", tags=["setlists"])
setlist_router = APIRouter(prefix="/api/setlists", tags=["setlists"])


def _load_setlist(session: Session, setlist_id: str) -> Setlist:
    setlist = session.get(Setlist, setlist_id)
    if setlist is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Setlist no encontrado")
    return setlist


def _read(session: Session, setlist: Setlist) -> SetlistRead:
    items = session.exec(
        select(SetlistItem)
        .where(SetlistItem.setlist_id == setlist.id)
        .order_by(SetlistItem.position)
    ).all()
    return SetlistRead(
        id=setlist.id,
        group_id=setlist.group_id,
        name=setlist.name,
        description=setlist.description,
        created_by=setlist.created_by,
        created_at=setlist.created_at,
        items=items,
    )


@group_router.post(
    "/{group_id}/setlists",
    response_model=SetlistRead,
    status_code=status.HTTP_201_CREATED,
)
def create_setlist(
    payload: SetlistCreate,
    group: Group = Depends(require_group),
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> SetlistRead:
    setlist = Setlist(
        group_id=group.id,
        name=payload.name,
        description=payload.description,
        created_by=user.id,
    )
    session.add(setlist)
    session.commit()
    session.refresh(setlist)
    return _read(session, setlist)


@group_router.get("/{group_id}/setlists", response_model=list[SetlistRead])
def list_setlists(
    group: Group = Depends(require_group),
    session: Session = Depends(get_session),
) -> list[SetlistRead]:
    setlists = session.exec(
        select(Setlist).where(Setlist.group_id == group.id).order_by(Setlist.created_at)
    ).all()
    return [_read(session, s) for s in setlists]


@setlist_router.get("/{setlist_id}", response_model=SetlistRead)
def get_setlist(
    setlist_id: str,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> SetlistRead:
    setlist = _load_setlist(session, setlist_id)
    if get_membership(session, setlist.group_id, user.id) is None:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "No perteneces a este grupo")
    return _read(session, setlist)


@setlist_router.post(
    "/{setlist_id}/items",
    response_model=SetlistRead,
    status_code=status.HTTP_201_CREATED,
)
def add_item(
    setlist_id: str,
    payload: SetlistItemCreate,
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> SetlistRead:
    setlist = _load_setlist(session, setlist_id)
    if get_membership(session, setlist.group_id, user.id) is None:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "No perteneces a este grupo")

    score = session.get(Score, payload.score_id)
    if score is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Partitura no encontrada")

    # Posición: la indicada o la siguiente al final.
    if payload.position is None:
        last = session.exec(
            select(SetlistItem)
            .where(SetlistItem.setlist_id == setlist_id)
            .order_by(SetlistItem.position.desc())
        ).first()
        position = (last.position + 1) if last else 0
    else:
        position = payload.position

    item = SetlistItem(
        setlist_id=setlist_id,
        score_id=payload.score_id,
        position=position,
        notes=payload.notes,
    )
    session.add(item)
    session.commit()
    return _read(session, setlist)
