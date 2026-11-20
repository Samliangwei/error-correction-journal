from fastapi import Header, HTTPException, status
from app.config import settings


async def verify_api_key(x_api_key: str = Header(...)) -> str:
    """
    简单 API Key 认证
    
    警告：此实现仅限本地开发和个人部署使用。
    生产环境必须实现真正的用户认证和授权，按用户隔离数据。
    """
    if x_api_key != settings.api_key:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid API Key",
        )
    return "default"
