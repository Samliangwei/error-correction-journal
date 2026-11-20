# 错题记录 - Error Correction Journal

面向中小学生的免费错题记录与定期复习 App。

## 📱 产品定位

帮助中小学生记录和管理日常学习中的错题，通过定期复习加深理解，提高学习效率。

**核心特性**：
- ✅ **本地优先**：无网络或服务器异常时完全可用
- ✅ **可选云同步**：用户主动启用后备份到服务器
- ✅ **跨平台支持**：iOS、Android、Web 三端
- ✅ **简洁易用**：专注错题记录与复习，避免功能过载

## 📦 当前实现状态

### ✅ 已实现
- [x] Flutter 前端基础架构（Riverpod + go_router + Drift）
- [x] 本地 SQLite 数据库（支持三端持久化）
- [x] 错题 CRUD 功能（创建、查看、编辑、删除）
- [x] 设置页面（本地/云同步模式切换）
- [x] FastAPI 后端基础架构
- [x] 数据库迁移（Alembic）
- [x] OpenAPI 接口合约
- [x] 基础测试和 CI 配置
- [x] 本地模式无需网络即可完整使用

### ⏳ 部分实现/占位
- [ ] **云同步功能**：
  - ✅ 已实现：单向上传（设备→服务器）、待同步标记、失败重试
  - ❌ 未实现：服务器→设备下载、增量拉取、完整多设备双向同步
  - ⚠️ 冲突策略：简单 last-write-wins（后写入覆盖），未实现智能合并
- [ ] **用户认证**：当前使用简单 API Key（X-API-Key header），**仅适用于**：
  - ✅ 本地开发环境（localhost）
  - ✅ 个人单用户部署
  - ❌ 不适用于多用户公开部署
  - 真实部署需实现完整用户认证与授权系统

### ❌ 未实现（非本次范围）
- 复习算法（间隔重复、艾宾浩斯曲线）
- 图片上传与 OCR 识别
- AI 辅助错因分析
- 推送通知提醒
- 应用商店发布
- 生产环境部署配置

## 🛠️ 技术选型

### 前端 (app/)

| 技术 | 版本 | 选择理由 |
|------|------|----------|
| Flutter | 3.24.5 | 官方跨平台框架，iOS/Android/Web 统一代码 |
| Riverpod | 2.6.1 | 声明式状态管理，类型安全，易测试 |
| go_router | 14.6+ | 官方推荐路由，支持深度链接 |
| Drift | 2.20+ | 类型安全的 SQLite 封装，支持 Web wasm |
| Dio | 5.7+ | 强大的 HTTP 客户端，拦截器和错误处理 |
| sqlite3_web | 0.1+ | 官方推荐的 Web SQLite 方案（wasm + IndexedDB）|

**Web 端存储说明**：
- 使用 `sqlite3.wasm` + IndexedDB 持久化
- 受浏览器配额限制（通常 50MB-1GB）
- 用户清理浏览器数据会删除本地数据库
- **强烈建议定期启用云同步备份**

### 后端 (server/)

| 技术 | 版本 | 选择理由 |
|------|------|----------|
| FastAPI | 0.115+ | 现代异步框架，自动 OpenAPI 文档 |
| SQLAlchemy | 2.0+ | 成熟的 ORM，async 支持 |
| Alembic | 1.14+ | 版本化数据库迁移 |
| SQLite | 3.x | 开发环境零配置 |
| PostgreSQL | - | 生产环境可选 |

## 📁 项目结构

```
├── app/                      # Flutter 前端
│   ├── lib/
│   │   ├── core/            # 核心层（数据库、网络、常量）
│   │   ├── features/        # 功能模块
│   │   │   ├── error_questions/  # 错题功能
│   │   │   │   ├── domain/       # 领域层（模型、接口）
│   │   │   │   ├── data/         # 数据层（本地/远程/实现）
│   │   │   │   └── presentation/ # 展示层（UI、状态）
│   │   │   └── settings/    # 设置功能
│   │   ├── router/          # 路由配置
│   │   └── main.dart        # 应用入口
│   ├── test/                # 测试
│   └── pubspec.yaml         # 依赖配置
├── server/                   # Python 后端
│   ├── app/
│   │   ├── models/          # 数据库模型
│   │   ├── schemas/         # API 模式
│   │   ├── routers/         # API 路由
│   │   ├── main.py          # 应用入口
│   │   └── config.py        # 配置管理
│   ├── alembic/             # 数据库迁移
│   ├── tests/               # 测试
│   └── requirements.txt     # 依赖
├── contracts/               # 接口合约
│   └── openapi.yaml         # OpenAPI 3.0 规范
├── .github/workflows/       # CI/CD
│   └── ci.yml              # GitHub Actions 配置
└── DESIGN.md               # 详细设计文档
```

## 🚀 快速开始

### 前端启动（无需后端）

#### Web 版本

```bash
cd app
flutter pub get
flutter run -d chrome
```

#### Android 模拟器

```bash
cd app
flutter pub get
flutter run
```

#### iOS 模拟器（需 macOS + Xcode）

```bash
cd app
flutter pub get
flutter run -d iphone
```

**注意**：默认为本地模式，无需启动后端即可完整使用所有功能。

### 后端启动（可选，启用云同步时需要）

#### 1. 安装依赖

```bash
cd server
pip install -r requirements.txt
```

#### 2. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 修改配置（可选）
```

#### 3. 运行数据库迁移

```bash
alembic upgrade head
```

#### 4. 启动服务

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

服务地址: http://localhost:8000
API 文档: http://localhost:8000/docs

#### Android 模拟器访问本地后端

Android 模拟器使用 `10.0.2.2` 访问宿主机：

```
设置 -> 云同步 -> 服务器地址: http://10.0.2.2:8000
```

#### Web 跨域配置

开发时 Web 访问本地后端已配置 CORS。生产环境需配置白名单。

## 🔄 同步机制说明

### 本地优先原则

所有数据操作**优先写入本地数据库**，确保：
- 无网络时完全可用
- 后端异常不影响使用
- 数据不会因网络问题丢失

### 云同步流程（单向上传）

当前实现为**单向同步**（设备→服务器），适用于单设备 + 云备份场景：

1. **启用云同步**：用户在设置页面主动开启
2. **本地优先**：所有操作先写本地数据库
3. **标记待同步**：保存时设置 `needs_sync=true`
4. **后台上传**：应用尝试将待同步记录上传到服务器
5. **失败重试**：
   - ✅ 网络失败：保留 `needs_sync=true`，下次自动重试
   - ✅ 删除墓碑：`deleted_at` 字段同步到服务器，不影响本地已删除记录
6. **成功确认**：服务器接受后清除 `needs_sync` 标记，更新 `last_synced_at`

### 同步限制与注意事项

**已实现**：
- ✅ 设备→服务器单向上传
- ✅ 待同步队列与失败重试
- ✅ 软删除墓碑同步

**未实现**：
- ❌ 服务器→设备下载（不会拉取服务器最新数据）
- ❌ 增量同步（每次上传所有待同步记录）
- ❌ 冲突智能合并（采用简单 last-write-wins）
- ❌ 多设备间数据同步

**冲突策略**：
- 服务器端比较 `updated_at` 时间戳
- 本地记录时间戳更新 → 覆盖服务器
- 服务器记录更新 → 拒绝上传，返回冲突
- **无自动合并**：用户需手动解决冲突

**使用建议**：
- ✅ 适合场景：单设备使用 + 定期云备份
- ⚠️ 不适合：多设备实时协同编辑
- 💡 多设备使用：只在一台设备编辑，其他设备仅查看

## 🗃️ 浏览器存储限制（Web 版）

### IndexedDB 配额

- **典型限制**：50MB - 1GB（因浏览器和设备而异）
- **超限行为**：写入失败，应用提示错误
- **查看配额**：浏览器开发者工具 → Application → Storage

### 数据清理风险

用户操作会导致数据丢失：
- 清除浏览器数据
- 清除网站数据
- 隐私模式关闭后

### 应对策略

- ✅ 应用启动时提示 Web 版数据特性
- ✅ 设置页面说明存储限制
- ✅ 推荐定期启用云同步备份
- ❌ 未实现：导出本地 JSON 备份功能（可作为增强）

## 🧪 测试

### Flutter 测试

```bash
cd app

# 运行所有测试
flutter test

# 代码格式检查
dart format --output=none --set-exit-if-changed .

# 静态分析
flutter analyze
```

### 后端测试

```bash
cd server

# 运行测试
pytest

# 带覆盖率
pytest --cov=app --cov-report=html
```

### CI 验证场景

- ✅ 无 HTTP 依赖下本地模式可用
- ✅ 后端不可达时数据持久化
- ✅ CRUD 基础功能
- ✅ Web 构建成功

## 🔧 构建

### Web 构建

```bash
cd app
flutter build web --release
```

输出：`app/build/web/`

### Android APK（Debug）

```bash
cd app
flutter build apk --debug
```

输出：`app/build/app/outputs/flutter-apk/app-debug.apk`

### iOS 构建

**状态**：未在 macOS 环境验证

需要：
- macOS 操作系统
- Xcode 开发工具
- 苹果开发者证书（发布时）

```bash
cd app
flutter build ios --release
```

## 🔐 认证与安全

### 当前实现限制

⚠️ **简单 API Key 认证（仅限开发/个人部署）**

- 认证方式：HTTP Header `X-API-Key`
- 默认密钥：`dev-only-change-in-production`
- 用户隔离：所有数据归属 `user_id='default'`

**明确禁止**：
- ❌ 不得直接部署为公开多用户服务
- ❌ 不适合团队共享环境
- ❌ 不支持多用户数据隔离

**仅适用于**：
- ✅ 本地开发环境（localhost）
- ✅ 个人单用户自托管（受信任网络）
- ✅ 学习和原型验证

**如需多用户部署，必须先实现**：
- [ ] 用户注册/登录系统
- [ ] JWT 或 OAuth2 认证
- [ ] 真实的按用户数据隔离
- [ ] HTTPS 强制（生产环境）
- [ ] 密码加密存储（bcrypt/argon2）
- [ ] 会话管理和过期策略
- [ ] API 限流和防爆破

### iOS/Android 网络安全

- iOS 9+、Android 9+ 默认禁止明文 HTTP
- 开发环境已配置例外
- **生产环境必须使用 HTTPS**

## 👶 未成年人隐私保护

本应用面向中小学生，隐私保护措施：

- ✅ **本地优先**：默认数据仅存储在设备本地
- ✅ **主动同步**：需用户或家长主动启用云同步
- ✅ **数据隔离**：每个用户数据独立存储
- ✅ **透明说明**：设置页面明确说明数据去向
- ⚠️ **家长监督**：建议家长了解并管理云同步功能

**不收集**：
- 个人身份信息
- 地理位置
- 设备指纹
- 行为追踪数据

## 🚧 已知限制

### 功能限制
- 仅支持文本错题（图片、公式需未来支持）
- 无复习提醒功能
- 无统计分析面板
- 云同步为单向（设备→服务器）

### 技术限制
- Web 版受浏览器存储配额限制
- 大量数据（>1000条）性能未优化
- 无离线检测和同步队列 UI
- 冲突解决策略简单（last-write-wins）

### 部署限制
- 后端无现成 Docker 配置
- 无生产环境监控和日志
- 未配置自动备份
- 无负载均衡和扩展方案

## 🛣️ 后续规划

### 短期增强
- [ ] 导出/导入错题（JSON/PDF）
- [ ] 图片支持（题目截图、手写答案）
- [ ] 完善云同步（双向、增量）
- [ ] 统计面板（学科分布、掌握率）

### 中期规划
- [ ] 间隔重复算法（艾宾浩斯曲线）
- [ ] 复习提醒推送
- [ ] OCR 识别题目文字
- [ ] 多端实时同步

### 长期愿景
- [ ] AI 辅助错因分析
- [ ] 知识图谱关联
- [ ] 班级/小组协作
- [ ] 教师端管理后台

## 📄 开发文档

- [DESIGN.md](./DESIGN.md) - 详细设计与执行计划
- [contracts/openapi.yaml](./contracts/openapi.yaml) - API 接口规范
- [server/README.md](./server/README.md) - 后端部署文档

## 🤝 贡献

本项目处于早期原型阶段，欢迎：
- 🐛 报告 Bug
- 💡 提出功能建议
- 📝 改进文档
- 🔧 提交代码（请先开 Issue 讨论）

## ⚖️ 许可证

待定

---

**开发者说明**：这是一个教育工具原型项目，重点验证技术可行性和核心功能。真实上线需要完善认证、安全、性能、监控等生产级特性。欢迎交流和反馈！
