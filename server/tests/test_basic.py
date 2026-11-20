"""
基础端点测试（无需数据库）

验证：
1. /health 端点可访问
2. 认证机制工作
"""
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.config import settings


@pytest.mark.asyncio
async def test_health_check():
    """健康检查端点"""
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test"
    ) as client:
        response = await client.get("/health")
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ok"
        assert "timestamp" in data


@pytest.mark.asyncio
async def test_unauthorized_access():
    """验证未授权访问被拒绝"""
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test"
    ) as client:
        response = await client.get("/api/v1/error-questions")
        
        # 缺少 X-API-Key header 应该返回 422
        assert response.status_code == 422


@pytest.mark.asyncio
async def test_with_invalid_api_key():
    """验证无效 API Key 被拒绝"""
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test"
    ) as client:
        response = await client.get(
            "/api/v1/error-questions",
            headers={"X-API-Key": "invalid-key-123"},
        )
        
        # 无效 Key 应该返回 401
        assert response.status_code == 401
