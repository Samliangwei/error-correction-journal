# 错题记录 API 后端

基于 FastAPI + SQLAlchemy 2.x + Alembic 的异步 RESTful API 服务。

## 技术栈

- **框架**: FastAPI 0.115+
- **ORM**: SQLAlchemy 2.0+ (async)
- **数据库迁移**: Alembic 1.14+
- **数据库**: SQLite (开发) / PostgreSQL (生产可选)
- **认证**: API Key (简单实现，仅限本地/个人部署)

## 快速开始

### 1. 安装依赖

```bash
cd server
pip install -r requirements.txt
```

### 2. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 修改配置
```

### 3. 运行数据库迁移

```bash
alembic upgrade head
```

### 4. 启动开发服务器

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

服务启动后访问:
- API 文档: http://localhost:8000/docs
- 健康检查: http://localhost:8000/health

## 数据库配置

### SQLite (默认，开发环境)

```env
DATABASE_URL=sqlite+aiosqlite:///./error_journal.db
```

### PostgreSQL (生产环境)

```bash
# 安装依赖
pip install asyncpg

# 配置
DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/error_journal
```

## API 认证

当前实现使用简单的 API Key 认证，仅适用于:
- 本地开发
- 个人部署（单用户）

**生产环境警告**: 真实部署必须实现:
- 用户注册/登录
- JWT 或 OAuth2 认证
- 按用户隔离数据
- 完整的权限控制

### 使用 API Key

在请求头中添加:

```
X-API-Key: your-api-key-from-env
```

默认开发密钥: `dev-only-change-in-production`

## 数据库迁移

### 创建新迁移

```bash
alembic revision --autogenerate -m "描述"
```

### 应用迁移

```bash
alembic upgrade head
```

### 回滚

```bash
alembic downgrade -1
```

## 测试

```bash
# 运行所有测试
pytest

# 带覆盖率
pytest --cov=app --cov-report=html

# 特定测试文件
pytest tests/test_error_questions.py -v
```

## 项目结构

```
server/
├── app/
│   ├── main.py              # FastAPI 应用入口
│   ├── config.py            # 配置管理
│   ├── database.py          # 数据库连接
│   ├── dependencies.py      # 依赖注入 (认证等)
│   ├── models/              # SQLAlchemy 模型
│   │   └── error_question.py
│   ├── schemas/             # Pydantic 模式 (请求/响应)
│   │   └── error_question.py
│   └── routers/             # API 路由
│       └── error_questions.py
├── alembic/                 # 数据库迁移
│   ├── versions/            # 迁移脚本
│   └── env.py
├── tests/                   # 测试
├── requirements.txt         # 依赖
├── .env.example            # 环境变量示例
└── README.md
```

## API 端点

完整的 API 文档见 `/contracts/openapi.yaml` 或启动后访问 `/docs`。

主要端点:
- `GET /health` - 健康检查
- `GET /api/v1/error-questions` - 列表查询
- `POST /api/v1/error-questions` - 创建错题 (幂等)
- `GET /api/v1/error-questions/{id}` - 获取详情
- `PUT /api/v1/error-questions/{id}` - 更新错题
- `DELETE /api/v1/error-questions/{id}` - 删除错题 (软删除)
- `POST /api/v1/error-questions/sync` - 批量同步

## 部署注意事项

### 安全

- [ ] 更改 `API_KEY` 为强随机字符串
- [ ] 实现真实的用户认证系统
- [ ] 启用 HTTPS (生产环境强制)
- [ ] 配置 CORS 白名单
- [ ] 使用环境变量管理敏感信息

### 数据库

- [ ] 使用 PostgreSQL 替代 SQLite
- [ ] 配置数据库连接池
- [ ] 定期备份数据
- [ ] 监控慢查询

### 性能

- [ ] 配置 Gunicorn/Uvicorn workers
- [ ] 添加缓存层 (Redis)
- [ ] 实施限流策略
- [ ] 监控和日志

## 开发

### 代码风格

```bash
# 格式化
black app/

# 类型检查
mypy app/

# Lint
ruff check app/
```

### 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `DATABASE_URL` | 数据库连接 URL | `sqlite+aiosqlite:///./error_journal.db` |
| `API_KEY` | API 认证密钥 | `dev-only-change-in-production` |
| `DEBUG` | 调试模式 | `false` |
| `APP_NAME` | 应用名称 | `错题记录 API` |

## 许可证

待定
