from datetime import datetime
from pydantic import BaseModel, Field
from enum import Enum


class MasteryStatus(str, Enum):
    NOT_MASTERED = "not_mastered"
    PARTIALLY_MASTERED = "partially_mastered"
    MASTERED = "mastered"


class ErrorQuestionCreate(BaseModel):
    id: str = Field(..., description="客户端生成的 UUID")
    subject: str = Field(..., max_length=50)
    question: str
    my_answer: str
    correct_answer: str
    reason: str
    mastery_status: MasteryStatus
    created_at: datetime
    updated_at: datetime


class ErrorQuestionUpdate(BaseModel):
    subject: str | None = Field(None, max_length=50)
    question: str | None = None
    my_answer: str | None = None
    correct_answer: str | None = None
    reason: str | None = None
    mastery_status: MasteryStatus | None = None
    updated_at: datetime


class ErrorQuestionResponse(BaseModel):
    id: str
    subject: str
    question: str
    my_answer: str
    correct_answer: str
    reason: str
    mastery_status: MasteryStatus
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None = None
    last_synced_at: datetime | None = None

    class Config:
        from_attributes = True


class ErrorQuestionSync(ErrorQuestionCreate):
    deleted_at: datetime | None = None


class ErrorQuestionListResponse(BaseModel):
    items: list[ErrorQuestionResponse]
    total: int


class ConflictItem(BaseModel):
    id: str
    reason: str


class SyncResponse(BaseModel):
    synced: list[str]
    conflicts: list[ConflictItem]
