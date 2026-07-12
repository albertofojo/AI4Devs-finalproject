"""Definición de las tablas del modelo relacional (README §3).

Los identificadores se almacenan como texto (UUID en formato string) para que la
misma definición funcione tanto en Postgres (Supabase, producción) como en SQLite
(tests). Las restricciones de unicidad e índices se declaran de forma portable.
"""

from __future__ import annotations

from datetime import datetime, timezone
from uuid import uuid4

from sqlmodel import Field, SQLModel, UniqueConstraint


def _uuid() -> str:
    return str(uuid4())


def _now() -> datetime:
    return datetime.now(timezone.utc)


class User(SQLModel, table=True):
    """Perfil del músico. `id` coincide con auth.users.id de Supabase."""

    __tablename__ = "users"

    id: str = Field(default_factory=_uuid, primary_key=True)
    email: str = Field(index=True, unique=True)
    full_name: str | None = None
    main_instrument: str | None = None
    level: str | None = Field(default=None)  # principiante|intermedio|avanzado|pro
    created_at: datetime = Field(default_factory=_now)


class Group(SQLModel, table=True):
    __tablename__ = "groups"

    id: str = Field(default_factory=_uuid, primary_key=True)
    name: str
    type: str  # banda|orquesta|tradicional|escuela
    description: str | None = None
    created_by: str = Field(foreign_key="users.id", index=True)
    created_at: datetime = Field(default_factory=_now)


class Membership(SQLModel, table=True):
    __tablename__ = "memberships"
    __table_args__ = (UniqueConstraint("group_id", "user_id", name="uq_membership"),)

    id: str = Field(default_factory=_uuid, primary_key=True)
    group_id: str = Field(foreign_key="groups.id", index=True)
    user_id: str = Field(foreign_key="users.id", index=True)
    role: str = Field(default="member")  # admin|member
    status: str = Field(default="active")  # active|invited
    joined_at: datetime = Field(default_factory=_now)


class Invitation(SQLModel, table=True):
    __tablename__ = "invitations"

    id: str = Field(default_factory=_uuid, primary_key=True)
    group_id: str = Field(foreign_key="groups.id", index=True)
    email: str = Field(index=True)
    token: str = Field(index=True, unique=True)
    status: str = Field(default="pending")  # pending|accepted|expired
    invited_by: str = Field(foreign_key="users.id")
    expires_at: datetime
    created_at: datetime = Field(default_factory=_now)


class Score(SQLModel, table=True):
    __tablename__ = "scores"

    id: str = Field(default_factory=_uuid, primary_key=True)
    group_id: str | None = Field(default=None, foreign_key="groups.id", index=True)
    uploaded_by: str = Field(foreign_key="users.id")
    title: str
    composer: str | None = None
    format: str = Field(default="musicxml")  # musicxml|pdf
    file_url: str
    key_signature: str | None = None
    is_public: bool = Field(default=False)
    created_at: datetime = Field(default_factory=_now)


class Setlist(SQLModel, table=True):
    __tablename__ = "setlists"

    id: str = Field(default_factory=_uuid, primary_key=True)
    group_id: str = Field(foreign_key="groups.id", index=True)
    name: str
    description: str | None = None
    created_by: str = Field(foreign_key="users.id")
    created_at: datetime = Field(default_factory=_now)


class SetlistItem(SQLModel, table=True):
    __tablename__ = "setlist_items"
    __table_args__ = (
        UniqueConstraint("setlist_id", "position", name="uq_setlist_position"),
    )

    id: str = Field(default_factory=_uuid, primary_key=True)
    setlist_id: str = Field(foreign_key="setlists.id", index=True)
    score_id: str = Field(foreign_key="scores.id", index=True)
    position: int = Field(default=0)
    notes: str | None = None


class Rehearsal(SQLModel, table=True):
    __tablename__ = "rehearsals"

    id: str = Field(default_factory=_uuid, primary_key=True)
    group_id: str = Field(foreign_key="groups.id", index=True)
    setlist_id: str | None = Field(default=None, foreign_key="setlists.id")
    title: str
    location: str | None = None
    starts_at: datetime
    ends_at: datetime | None = None
    notes: str | None = None
    created_by: str = Field(foreign_key="users.id")
    created_at: datetime = Field(default_factory=_now)


class Attendance(SQLModel, table=True):
    __tablename__ = "attendances"
    __table_args__ = (
        UniqueConstraint("rehearsal_id", "user_id", name="uq_attendance"),
    )

    id: str = Field(default_factory=_uuid, primary_key=True)
    rehearsal_id: str = Field(foreign_key="rehearsals.id", index=True)
    user_id: str = Field(foreign_key="users.id", index=True)
    status: str = Field(default="maybe")  # confirmed|absent|maybe
    responded_at: datetime = Field(default_factory=_now)
