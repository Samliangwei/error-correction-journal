import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.config import settings


@pytest.mark.asyncio
async def test_create_error_question(test_db):
    question_data = {
        "id": "test-uuid-1",
        "subject": "数学",
        "question": "1+1=?",
        "my_answer": "3",
        "correct_answer": "2",
        "reason": "计算错误",
        "mastery_status": "not_mastered",
        "created_at": "2024-11-20T07:00:00Z",
        "updated_at": "2024-11-20T07:00:00Z",
    }
    
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test"
    ) as client:
        response = await client.post(
            "/api/v1/error-questions",
            json=question_data,
            headers={"X-API-Key": settings.api_key},
        )
        
        assert response.status_code == 201
        data = response.json()
        assert data["id"] == question_data["id"]
        assert data["subject"] == question_data["subject"]


@pytest.mark.asyncio
async def test_list_error_questions(test_db):
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test"
    ) as client:
        response = await client.get(
            "/api/v1/error-questions",
            headers={"X-API-Key": settings.api_key},
        )
        
        assert response.status_code == 200
        data = response.json()
        assert "items" in data
        assert "total" in data
        assert isinstance(data["items"], list)


@pytest.mark.asyncio
async def test_unauthorized_access():
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test"
    ) as client:
        response = await client.get("/api/v1/error-questions")
        
        assert response.status_code == 422
