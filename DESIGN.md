# 错题记录 App 设计与执行计划

## 产品定位
面向中小学生的免费错题记录与定期复习 App。

## 核心约束
1. **本地优先**：无后端或网络异常时仍可完整使用（新增/编辑/删除/查看错题）
2. **可选云同步**：用户主动启用后才连接服务器
3. **跨平台**：Flutter 支持 iOS/Android/Web 三端
4. **接口隔离**：前后端通过 OpenAPI 合约通信

## 技术选型

### 前端 (app/)
- **框架**：Flutter 3.x
- **状态管理**：Riverpod 2.x（声明式、类型安全）
- **路由**：go_router（官方推荐，深度链接支持）
- **本地存储**：Drift（SQLite 封装，类型安全，支持 Web wasm）
- **网络请求**：Dio（拦截器、错误处理、超时控制）
- **平台支持**：
  - iOS/Android：原生 SQLite
  - Web：sqlite3.wasm（官方推荐方案，持久化到 IndexedDB）

**Web 存储限制说明**：
- 浏览器 IndexedDB 受配额限制（通常 50MB-1GB）
- 用户清理浏览器数据会删除本地数据库
- 建议用户定期启用云同步备份

### 后端 (server/)
- **框架**：FastAPI（async，自动 OpenAPI 文档）
- **ORM**：SQLAlchemy 2.x（现代 async API）
- **迁移**：Alembic（版本化数据库迁移）
- **数据库**：
  - 开发：SQLite（零配置）
  - 生产可选：PostgreSQL

### 接口合约 (contracts/)
- OpenAPI 3.0 规范文档（openapi.yaml）
- 前端根据合约生成类型

## 数据模型

### 错题 (ErrorQuestion)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | UUID | 客户端生成，全局唯一 |
| subject | String | 学科（语文、数学、英语等）|
| question | Text | 题目内容 |
| my_answer | Text | 我的错误答案 |
| correct_answer | Text | 正确解法 |
| reason | Text | 错因分析 |
| mastery_status | Enum | 掌握状态（未掌握/部分掌握/已掌握）|
| created_at | DateTime | 创建时间 |
| updated_at | DateTime | 更新时间 |
| deleted_at | DateTime? | 删除时间（软删除墓碑）|
| last_synced_at | DateTime? | 最后同步时间 |

### 设置 (Settings)
| 字段 | 类型 | 说明 |
|------|------|------|
| sync_mode | Enum | localOnly / cloudSync |
| server_url | String? | 服务器地址（云同步时）|
| last_sync_time | DateTime? | 最后同步时间 |

## 架构设计

### 前端分层
```
lib/
├── main.dart                 # 应用入口
├── core/                     # 核心层
│   ├── database/            # Drift 数据库定义
│   ├── network/             # Dio 配置
│   └── constants/           # 常量定义
├── features/                # 功能模块
│   ├── error_questions/    
│   │   ├── domain/         # 领域层
│   │   │   ├── models/     # 领域模型
│   │   │   └── repositories/  # Repository 接口
│   │   ├── data/           # 数据层
│   │   │   ├── local/      # 本地数据源（Drift）
│   │   │   ├── remote/     # 远程数据源（Dio）
│   │   │   └── repositories/  # Repository 实现（聚合本地+远程）
│   │   └── presentation/   # 展示层
│   │       ├── providers/  # Riverpod 状态管理
│   │       ├── pages/      # 页面
│   │       └── widgets/    # 组件
│   └── settings/           # 设置模块（同样分层）
└── router/                  # 路由配置
```

### 同步策略
1. **默认 localOnly 模式**：
   - 所有读写操作只访问本地数据库
   - 不发起任何网络请求
   - 启动时不做健康检查

2. **cloudSync 模式**：
   - 保存时先写本地，标记 `needs_sync=true`
   - 后台尝试上传到服务器，成功后更新 `last_synced_at`
   - 失败保留本地修改，不覆盖
   - 下次启动时增量同步未同步的记录

3. **冲突处理**：
   - 使用 UUID 确保 ID 唯一性
   - `updated_at` 时间戳判断新旧
   - 本次实现：last-write-wins（后写入覆盖）
   - 删除使用软删除墓碑（deleted_at），同步墓碑到服务器

4. **边界说明**：
   - 本次实现单向同步（本地→服务器）或占位标注
   - 完整多设备双向同步需要更复杂的冲突解决
   - 网络超时设置 10 秒，失败不影响本地操作

### 后端设计
```
server/
├── app/
│   ├── main.py             # FastAPI 应用入口
│   ├── config.py           # 配置管理
│   ├── database.py         # 数据库连接
│   ├── models/             # SQLAlchemy 模型
│   ├── schemas/            # Pydantic 模式
│   ├── routers/            # API 路由
│   └── dependencies.py     # 依赖注入
├── alembic/                # 数据库迁移
├── tests/                  # 测试
├── requirements.txt        # 依赖
├── .env.example            # 配置示例（无秘密）
└── README.md              # 后端文档
```

### API 设计
- `GET /health` - 健康检查
- `POST /api/v1/error-questions` - 创建错题（幂等，UUID）
- `PUT /api/v1/error-questions/{id}` - 更新错题
- `DELETE /api/v1/error-questions/{id}` - 删除错题（软删除）
- `GET /api/v1/error-questions` - 列表查询
- `GET /api/v1/error-questions/{id}` - 详情查询
- `POST /api/v1/error-questions/sync` - 批量同步

**认证说明**：
- 本次实现使用简单的 API Key 或 HTTP Basic Auth
- 仅限本地开发和个人部署
- 生产部署必须配置认证，按用户隔离数据
- 如认证仅预留占位，后端需明确标注"仅限本地开发"

## 执行计划

### Phase 1: 项目初始化与基础框架
1. ✅ 创建工作分支
2. ⬜ 初始化 Flutter 项目（包含 iOS/Android/Web 平台目录）
3. ⬜ 配置依赖（Riverpod, go_router, Drift, Dio）
4. ⬜ 初始化 FastAPI 项目
5. ⬜ 配置后端依赖和数据库
6. ⬜ 创建 OpenAPI 合约文档

### Phase 2: 数据层实现
7. ⬜ 定义 Drift 数据库表结构
8. ⬜ 实现本地 Repository
9. ⬜ 定义 SQLAlchemy 模型
10. ⬜ 创建 Alembic 迁移
11. ⬜ 实现远程 Repository（带超时和错误处理）

### Phase 3: 业务逻辑与 UI
12. ⬜ 实现错题列表页面（本地数据）
13. ⬜ 实现错题新增/编辑页面
14. ⬜ 实现设置页面（切换同步模式）
15. ⬜ 实现基础同步逻辑（标记待同步、后台上传）
16. ⬜ 后端 API 实现（CRUD + 认证）

### Phase 4: 测试与 CI
17. ⬜ 编写 Flutter 单元测试（Repository 层）
18. ⬜ 编写 Flutter Widget 测试
19. ⬜ 编写后端测试（API + 数据库）
20. ⬜ 配置 GitHub Actions CI
   - Flutter: 格式检查、静态分析、单元测试
   - 后端: pytest + coverage
   - 验证无 HTTP 依赖下本地模式可用
   - 验证后端不可达时数据持久化

### Phase 5: 构建与文档
21. ⬜ 尝试 `flutter build web`
22. ⬜ 尝试 `flutter build apk --debug`
23. ⬜ iOS 构建说明（如无 Mac 列出未验证）
24. ⬜ 完善中文 README
25. ⬜ 创建 PR 并报告

## 未包含范围
- ❌ 复习算法（间隔重复、艾宾浩斯曲线）
- ❌ 图片上传与 OCR
- ❌ AI 辅助分析
- ❌ 推送通知
- ❌ 应用商店发布
- ❌ 完整多设备双向同步
- ❌ 复杂用户账户系统

## 隐私保护
- 本地模式数据仅存储在设备上
- 云同步需要用户主动启用
- 不收集未成年人个人信息
- 服务器数据按用户隔离
- 建议家长监督使用

## 验收标准
1. ✅ Flutter 项目包含 ios/android/web 平台目录
2. ✅ 默认 localOnly 模式无需网络即可 CRUD 错题
3. ✅ 后端不可达时应用正常启动和使用
4. ✅ 重启应用后本地数据完整保留
5. ✅ 云同步模式可配置且网络失败不丢数据
6. ✅ 后端可独立运行并通过 /health 检查
7. ✅ CI 验证上述场景
8. ✅ README 完整说明架构、启动方法和限制
