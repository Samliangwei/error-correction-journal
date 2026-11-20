from datetime import datetime
from sqlalchemy import String, Text, DateTime, Enum as SQLEnum
from sqlalchemy.orm import Mapped, mapped_column
import enum

from app.database import Base


class MasteryStatus(str, enum.Enum):
    NOT_MASTERED = "not_mastered"
    PARTIALLY_MASTERED = "partially_mastered"
    MASTERED = "mastered"


class ErrorQuestion(Base):
    __tablename__ = "error_questions"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    subject: Mapped[str] = mapped_column(String(50), nullable=False, index=True)
    question: Mapped[str] = mapped_column(Text, nullable=False)
    my_answer: Mapped[str] = mapped_column(Text, nullable=False)
    correct_answer: Mapped[str] = mapped_column(Text, nullable=False)
    reason: Mapped[str] = mapped_column(Text, nullable=False)
    mastery_status: Mapped[MasteryStatus] = mapped_column(
        SQLEnum(MasteryStatus), 
        nullable=False, 
        default=MasteryStatus.NOT_MASTERED,
        index=True,
    )
    created_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    deleted_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True, index=True)
    last_synced_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    
    user_id: Mapped[str] = mapped_column(String(36), nullable=False, default="default", index=True)
