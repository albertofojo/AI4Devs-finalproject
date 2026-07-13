"""DTOs Pydantic: validación de entrada y forma de las respuestas del API."""

from __future__ import annotations

from datetime import datetime
from enum import Enum

from pydantic import BaseModel, ConfigDict, EmailStr, Field


# ----- Enumeraciones de dominio (validación) -----
class GroupType(str, Enum):
    banda = "banda"
    orquesta = "orquesta"
    tradicional = "tradicional"
    escuela = "escuela"


class MemberRole(str, Enum):
    admin = "admin"
    member = "member"


class Level(str, Enum):
    principiante = "principiante"
    intermedio = "intermedio"
    avanzado = "avanzado"
    pro = "pro"


class ScoreFormat(str, Enum):
    musicxml = "musicxml"
    pdf = "pdf"


class AttendanceStatus(str, Enum):
    confirmed = "confirmed"
    absent = "absent"
    maybe = "maybe"


# ----- Usuarios / perfil -----
class UserRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: str
    email: str
    full_name: str | None = None
    main_instrument: str | None = None
    level: str | None = None
    created_at: datetime


class MeUpdate(BaseModel):
    full_name: str | None = None
    main_instrument: str | None = None
    level: Level | None = None


# ----- Grupos -----
class GroupCreate(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    type: GroupType
    description: str | None = None


class GroupRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: str
    name: str
    type: str
    description: str | None = None
    created_by: str
    created_at: datetime
    my_role: str | None = None


# ----- Invitaciones -----
class InvitationCreate(BaseModel):
    email: EmailStr
    expires_in_hours: int = Field(default=168, ge=1, le=720)  # por defecto 7 días


class InvitationRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: str
    group_id: str
    email: str
    token: str
    status: str
    expires_at: datetime
    created_at: datetime


# ----- Partituras -----
class ScoreCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    composer: str | None = None
    format: ScoreFormat = ScoreFormat.musicxml
    file_url: str
    key_signature: str | None = None
    is_public: bool = False


class ScoreRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: str
    group_id: str | None = None
    uploaded_by: str
    title: str
    composer: str | None = None
    format: str
    file_url: str
    key_signature: str | None = None
    is_public: bool
    created_at: datetime


# ----- Setlists -----
class SetlistCreate(BaseModel):
    name: str = Field(min_length=1, max_length=160)
    description: str | None = None


class SetlistItemCreate(BaseModel):
    score_id: str
    position: int | None = Field(default=None, ge=0)
    notes: str | None = None


class SetlistItemRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: str
    setlist_id: str
    score_id: str
    position: int
    notes: str | None = None


class SetlistRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: str
    group_id: str
    name: str
    description: str | None = None
    created_by: str
    created_at: datetime
    items: list[SetlistItemRead] = []


# ----- Ensayos -----
class RehearsalCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    location: str | None = None
    starts_at: datetime
    ends_at: datetime | None = None
    setlist_id: str | None = None
    notes: str | None = None


class RehearsalRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: str
    group_id: str
    title: str
    location: str | None = None
    starts_at: datetime
    ends_at: datetime | None = None
    setlist_id: str | None = None
    notes: str | None = None
    created_by: str
    created_at: datetime


class AttendanceSummary(BaseModel):
    confirmed: int = 0
    absent: int = 0
    maybe: int = 0
    pending: int = 0


class AttendanceRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: str
    rehearsal_id: str
    user_id: str
    status: str
    responded_at: datetime


class RehearsalDetail(RehearsalRead):
    setlist: SetlistRead | None = None
    attendance_summary: AttendanceSummary = AttendanceSummary()
    my_attendance: str | None = None


class AttendanceWrite(BaseModel):
    status: AttendanceStatus
