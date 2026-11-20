from datetime import datetime
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.routers import error_questions_router

app = FastAPI(
    title=settings.app_name,
    description="面向中小学生的错题记录与复习应用后端接口",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(error_questions_router)


@app.get("/health")
async def health_check():
    """健康检查端点"""
    return {
        "status": "ok",
        "timestamp": datetime.utcnow().isoformat() + "Z",
    }


@app.get("/")
async def root():
    """API 根路径"""
    return {
        "message": "错题记录 API",
        "docs": "/docs",
        "openapi": "/openapi.json",
    }
