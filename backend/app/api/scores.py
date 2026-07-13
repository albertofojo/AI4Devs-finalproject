"""Router de partituras (HU-04).

El fichero se sube a Supabase Storage desde el cliente; este endpoint persiste los
metadatos y la `file_url` resultante, asociando la partitura al grupo.
"""

from __future__ import annotations

from fastapi import APIRouter, Depends, status
from sqlmodel import Session, select

from app.api.deps import require_group
from app.core.security import get_current_user
from app.db.session import get_session
from app.models import Group, Score, User
from app.schemas import ScoreCreate, ScoreRead

router = APIRouter(prefix="/api/groups", tags=["scores"])


@router.post(
    "/{group_id}/scores", response_model=ScoreRead, status_code=status.HTTP_201_CREATED
)
def upload_score(
    payload: ScoreCreate,
    group: Group = Depends(require_group),
    user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
) -> Score:
    score = Score(
        group_id=group.id,
        uploaded_by=user.id,
        title=payload.title,
        composer=payload.composer,
        format=payload.format.value,
        file_url=payload.file_url,
        key_signature=payload.key_signature,
        is_public=payload.is_public,
    )
    session.add(score)
    session.commit()
    session.refresh(score)
    return score


@router.get("/{group_id}/scores", response_model=list[ScoreRead])
def list_scores(
    group: Group = Depends(require_group),
    session: Session = Depends(get_session),
) -> list[Score]:
    return session.exec(
        select(Score).where(Score.group_id == group.id).order_by(Score.created_at)
    ).all()
