from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy import select, func, and_
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import verify_api_key
from app.models import ErrorQuestion
from app.models.error_question import MasteryStatus as DBMasteryStatus
from app.schemas import (
    ErrorQuestionCreate,
    ErrorQuestionUpdate,
    ErrorQuestionResponse,
    ErrorQuestionSync,
    ErrorQuestionListResponse,
    SyncResponse,
    ConflictItem,
    MasteryStatus,
)

router = APIRouter(
    prefix="/api/v1/error-questions",
    tags=["error-questions"],
)


@router.get("", response_model=ErrorQuestionListResponse)
async def list_error_questions(
    subject: str | None = Query(None),
    mastery_status: MasteryStatus | None = Query(None),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db),
    user_id: str = Depends(verify_api_key),
):
    query = select(ErrorQuestion).where(
        and_(
            ErrorQuestion.user_id == user_id,
            ErrorQuestion.deleted_at.is_(None),
        )
    )
    
    if subject:
        query = query.where(ErrorQuestion.subject == subject)
    
    if mastery_status:
        db_status = DBMasteryStatus(mastery_status.value)
        query = query.where(ErrorQuestion.mastery_status == db_status)
    
    count_query = select(func.count()).select_from(query.subquery())
    total = await db.scalar(count_query) or 0
    
    query = query.order_by(ErrorQuestion.created_at.desc())
    query = query.limit(limit).offset(offset)
    
    result = await db.execute(query)
    items = result.scalars().all()
    
    return ErrorQuestionListResponse(
        items=[ErrorQuestionResponse.model_validate(item) for item in items],
        total=total,
    )


@router.post("", response_model=ErrorQuestionResponse, status_code=status.HTTP_201_CREATED)
async def create_error_question(
    question: ErrorQuestionCreate,
    db: AsyncSession = Depends(get_db),
    user_id: str = Depends(verify_api_key),
):
    result = await db.execute(
        select(ErrorQuestion).where(ErrorQuestion.id == question.id)
    )
    existing = result.scalar_one_or_none()
    
    if existing:
        return ErrorQuestionResponse.model_validate(existing)
    
    db_question = ErrorQuestion(
        id=question.id,
        subject=question.subject,
        question=question.question,
        my_answer=question.my_answer,
        correct_answer=question.correct_answer,
        reason=question.reason,
        mastery_status=DBMasteryStatus(question.mastery_status.value),
        created_at=question.created_at,
        updated_at=question.updated_at,
        last_synced_at=datetime.utcnow(),
        user_id=user_id,
    )
    
    db.add(db_question)
    await db.commit()
    await db.refresh(db_question)
    
    return ErrorQuestionResponse.model_validate(db_question)


@router.get("/{question_id}", response_model=ErrorQuestionResponse)
async def get_error_question(
    question_id: str,
    db: AsyncSession = Depends(get_db),
    user_id: str = Depends(verify_api_key),
):
    result = await db.execute(
        select(ErrorQuestion).where(
            and_(
                ErrorQuestion.id == question_id,
                ErrorQuestion.user_id == user_id,
            )
        )
    )
    question = result.scalar_one_or_none()
    
    if not question:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Error question not found",
        )
    
    return ErrorQuestionResponse.model_validate(question)


@router.put("/{question_id}", response_model=ErrorQuestionResponse)
async def update_error_question(
    question_id: str,
    question_update: ErrorQuestionUpdate,
    db: AsyncSession = Depends(get_db),
    user_id: str = Depends(verify_api_key),
):
    result = await db.execute(
        select(ErrorQuestion).where(
            and_(
                ErrorQuestion.id == question_id,
                ErrorQuestion.user_id == user_id,
                ErrorQuestion.deleted_at.is_(None),
            )
        )
    )
    question = result.scalar_one_or_none()
    
    if not question:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Error question not found",
        )
    
    update_data = question_update.model_dump(exclude_unset=True)
    
    if "mastery_status" in update_data:
        update_data["mastery_status"] = DBMasteryStatus(update_data["mastery_status"].value)
    
    for field, value in update_data.items():
        setattr(question, field, value)
    
    question.last_synced_at = datetime.utcnow()
    
    await db.commit()
    await db.refresh(question)
    
    return ErrorQuestionResponse.model_validate(question)


@router.delete("/{question_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_error_question(
    question_id: str,
    db: AsyncSession = Depends(get_db),
    user_id: str = Depends(verify_api_key),
):
    result = await db.execute(
        select(ErrorQuestion).where(
            and_(
                ErrorQuestion.id == question_id,
                ErrorQuestion.user_id == user_id,
                ErrorQuestion.deleted_at.is_(None),
            )
        )
    )
    question = result.scalar_one_or_none()
    
    if not question:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Error question not found",
        )
    
    question.deleted_at = datetime.utcnow()
    question.last_synced_at = datetime.utcnow()
    
    await db.commit()


@router.post("/sync", response_model=SyncResponse)
async def sync_error_questions(
    questions: list[ErrorQuestionSync],
    db: AsyncSession = Depends(get_db),
    user_id: str = Depends(verify_api_key),
):
    synced = []
    conflicts = []
    
    for question_data in questions:
        try:
            result = await db.execute(
                select(ErrorQuestion).where(ErrorQuestion.id == question_data.id)
            )
            existing = result.scalar_one_or_none()
            
            if existing:
                if existing.updated_at > question_data.updated_at:
                    conflicts.append(ConflictItem(
                        id=question_data.id,
                        reason="Server version is newer",
                    ))
                    continue
                
                existing.subject = question_data.subject
                existing.question = question_data.question
                existing.my_answer = question_data.my_answer
                existing.correct_answer = question_data.correct_answer
                existing.reason = question_data.reason
                existing.mastery_status = DBMasteryStatus(question_data.mastery_status.value)
                existing.updated_at = question_data.updated_at
                existing.deleted_at = question_data.deleted_at
                existing.last_synced_at = datetime.utcnow()
            else:
                new_question = ErrorQuestion(
                    id=question_data.id,
                    subject=question_data.subject,
                    question=question_data.question,
                    my_answer=question_data.my_answer,
                    correct_answer=question_data.correct_answer,
                    reason=question_data.reason,
                    mastery_status=DBMasteryStatus(question_data.mastery_status.value),
                    created_at=question_data.created_at,
                    updated_at=question_data.updated_at,
                    deleted_at=question_data.deleted_at,
                    last_synced_at=datetime.utcnow(),
                    user_id=user_id,
                )
                db.add(new_question)
            
            synced.append(question_data.id)
        
        except Exception as e:
            conflicts.append(ConflictItem(
                id=question_data.id,
                reason=f"Error: {str(e)}",
            ))
    
    await db.commit()
    
    return SyncResponse(synced=synced, conflicts=conflicts)
