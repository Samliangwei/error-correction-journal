# 拾题 P0 实施计划

版本：v1.0  
日期：2026-11-20  
状态：规划阶段

## 1. 项目概述

### 1.1 产品定位
免费错题记录与复习 App"拾题"，面向中小学生，本地优先、单设备单学习档案、无账号/云同步/OCR/AI。

### 1.2 P0 核心功能
1. **照片与文字录入**：相机/选图、裁剪旋转、排序删除（跨题目/答案/思路共8图）
2. **反思与整理**：答案、原思路、错因分离；科目、标签、检索
3. **记录管理**：自动草稿、正式保存、编辑、归档、回收站
4. **定期复习**：隐藏答案回忆核验、自评、间隔调度（k0-4，3/7/14天）、每日计划
5. **轻量统计**：状态、到期/逾期、计划处理、错因分布
6. **数据安全**：离线持久化、完整备份导出/恢复预检、原子操作
7. **隐私与可用性**：最小权限、无广告、字号/读屏

### 1.3 技术约束
- 保留当前 Flutter 三端工程
- 先交付本地可预览 Web（IndexedDB + offline ready）
- 不承诺 Android/iOS 构建（环境限制）
- FastAPI 后端保留隔离，本次不使用
- 固定 UTC+8 时区
- 严格的原子操作、幂等性、数据一致性

### 1.4 验收标准
- AC01-26 逐条验证并记录证据
- 调度/跨日/生命周期/容量/再错/幂等领域测试
- 无后端本地真实 CRUD + 关库重开
- 带素材全量备份往返/损坏/不兼容/配额失败
- 不得删测/skip/continue-on-error 达成绿灯
- Flutter analyze、test、build web
- 尽可能浏览器 IndexedDB/离线冒烟

## 2. 架构设计

### 2.1 分层架构

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Pages, Widgets, Providers)           │
├─────────────────────────────────────────┤
│           Domain Layer                  │
│  (Models, Use Cases, Repositories)     │
├─────────────────────────────────────────┤
│            Data Layer                   │
│  (Local DB, Backup/Restore, Scheduler) │
├─────────────────────────────────────────┤
│         Infrastructure                  │
│  (Drift DB, Platform Detection)        │
└─────────────────────────────────────────┘
```

### 2.2 核心模块划分

#### 模块 1：Domain Models（领域模型）
- `mistake_question.dart`：错题实体（UUID、题目、科目、图片、答案、思路、错因、标签）
- `draft.dart`：草稿实体
- `learning_state.dart`：学习状态枚举（待复习、复习中、已掌握）
- `review_cycle.dart`：复习周期（k级别、due日期、历史事件）
- `daily_plan.dart`：每日计划（容量C、目标N、已完成/未完成题）
- `review_event.dart`：复习事件（题+日+周期+档位）

#### 模块 2：Scheduling（调度引擎）
- `scheduler.dart`：间隔复习算法
  - 保存日D → k0, due=D+1
  - 不会 → k0, +1天
  - 模糊 → k保持, +1天
  - 会了 → k递进(0→1→2→3→4), +(3/7/14/清空)天
- `daily_plan_manager.dart`：每日计划管理
  - 容量C、目标N
  - 已完成不释放，未完成补位
  - 跳过逻辑、追加确认
- `idempotency_guard.dart`：幂等性守护
  - 题UUID + 学习日期 → 唯一约束
  - 再次出错同日幂等
  - 旧卡跨日原子检查

#### 模块 3：Local Storage（本地存储）
- `app_database.dart`：Drift 数据库定义
  - `mistake_questions` 表
  - `drafts` 表
  - `review_cycles` 表
  - `review_events` 表
  - `daily_plans` 表
  - `images` 表（UUID、路径、所属）
- `repository_*.dart`：各模块仓库实现

#### 模块 4：Backup & Restore（备份恢复）
- `backup_manager.dart`：完整备份生成
  - 版本化快照（题/草稿/归档/回收站/图片/历史/周期/排期/时区/日计划）
  - Hash校验、数量快照
- `restore_manager.dart`：恢复预检与原子替换
  - 格式/字段/数量/素材hash验证
  - 路径穿越/解压膨胀检查
  - 容量临时回滚空间预检
  - 非空必先生成当前快照
  - 原子替换失败回滚

#### 模块 5：Image Processing（图片处理）
- `image_picker_service.dart`：相机/选图（权限最小化）
- `image_processor.dart`：裁剪、旋转、压缩
  - 导入≤20MB，HEIC转换或降级
  - 保存≤3MB/2400px
  - 移除元数据
- `image_storage.dart`：本地图片管理（跨题目/答案/思路共8张）

#### 模块 6：Search & Filter（搜索筛选）
- `search_service.dart`：关键词检索（手动文本，不搜图）
- `filter_service.dart`：科目/状态/标签/归档筛选

#### 模块 7：Statistics（统计）
- `statistics_service.dart`：状态量、错因分布、7/30日记录

#### 模块 8：UI Layer（展示层）
- 今日复习页（S01）
- 错题本页（S02）
- 录入/编辑页（S04-S06）
- 详情页（S07）
- 复习卡片页（S08-S10）
- 手动练习页（S11-S12）
- 统计页（S13）
- 设置/数据管理页（S16-S21）

### 2.3 Web 平台特殊处理
- Drift wasm + IndexedDB 持久化
- 离线资源准备与 Service Worker
- 下载不是成功，需读回验证
- 浏览器配额探测与失败安全
- 域名隔离风险告知

## 3. 数据模型设计

### 3.1 MistakeQuestion（错题）
```dart
class MistakeQuestion {
  final String id;                    // UUID
  final String subject;               // 科目（10个固定值）
  final String? title;                // 标题≤60字，空则生成
  final String questionText;          // 题干≤5000字
  final List<String> questionImages;  // 题图UUID列表
  final String? correctAnswer;        // 答案≤5000字
  final List<String> answerImages;    // 答案图UUID列表
  final String? answerSource;         // 答案来源≤100字
  final String? myThinking;           // 原思路≤3000字
  final List<String> thinkingImages;  // 思路图UUID列表
  final List<String> errorReasons;    // 错因类型（最多3）
  final String? errorNotes;           // 错因补充≤1000字
  final List<String> tags;            // 标签（最多5个，每个≤20字）
  final DateTime mistakeDate;         // 错题日期（可改过去）
  final DateTime createdAt;           // 创建时刻
  final DateTime updatedAt;           // 更新时刻
  final DateTime? formalizedAt;       // 正式保存日
  final bool isArchived;              // 归档标志
  final DateTime? deletedAt;          // 删除时刻（软删除）
}
```

### 3.2 Draft（草稿）
```dart
class Draft {
  final String id;
  final String? subject;
  final String? title;
  final String? questionText;
  final List<String> questionImages;
  final String? correctAnswer;
  // ... 其他字段同 MistakeQuestion
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSavedAt;        // 持久化完成时间
  final bool isSaved;                 // 已保存标志
}
```

### 3.3 ReviewCycle（复习周期）
```dart
class ReviewCycle {
  final String id;
  final String questionId;            // 关联错题
  final int cycleNumber;              // 周期序号（再错时递增）
  final int kLevel;                   // 当前k级别 0-4
  final LearningState state;          // 学习状态
  final DateTime? dueDate;            // 到期日期（UTC+8）
  final DateTime startedAt;           // 周期开始时刻
  final DateTime? completedAt;        // 达到k4时刻
  final bool isActive;                // 是否当前活动周期
}
```

### 3.4 ReviewEvent（复习事件）
```dart
class ReviewEvent {
  final String id;
  final String questionId;
  final String cycleId;               // 关联周期
  final DateTime eventTime;           // 事件时刻
  final String learningDate;          // 学习日期（UTC+8，格式：2026-11-20）
  final ReviewResult result;          // 不会/模糊/会了
  final int kLevelBefore;             // 自评前k
  final int kLevelAfter;              // 自评后k
  final DateTime? dueDateAfter;       // 自评后due
}
```

### 3.5 DailyPlan（每日计划）
```dart
class DailyPlan {
  final String id;
  final String learningDate;          // 学习日期（UTC+8）
  final int targetN;                  // 目标题数N（快照）
  final int capacityC;                // 当前容量C
  final List<String> questionIds;     // 计划中的题（顺序）
  final List<String> completedIds;    // 已完成的题
  final List<String> skippedIds;      // 当前会话跳过的题
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 3.6 Image（图片）
```dart
class Image {
  final String id;                    // UUID
  final String localPath;             // 本地存储路径
  final String mimeType;              // MIME类型
  final int sizeBytes;                // 文件大小
  final int widthPx;                  // 宽度
  final int heightPx;                 // 高度
  final String? questionId;           // 所属错题
  final String? draftId;              // 所属草稿
  final ImageSection section;         // 题目/答案/思路
  final DateTime createdAt;
}
```

## 4. 安全设计

### 4.1 调度安全
- **固定UTC+8**：不随设备时区漂移，事件存绝对时刻+学习日期
- **k级别推进**：k0→k1→k2→k3→k4，需同周期实际间隔
- **间隔计算**：从实际提交日计算，不以原due
- **幂等约束**：题UUID + 学习日期唯一，跨周期也不能同日第二次自评
- **再次出错**：同题+学习日幂等，新周期k0/due明日，保留旧历史
- **跨日旧卡**：原子重检版本/生命周期/due/同日限制/容量

### 4.2 容量管理
- **目标N**：默认20，5-50整数，修改次日生效
- **容量C**：初始N，只因明确追加增大
- **已完成不释放**：完成后不释放名额
- **自动补位**：空位或未完成题退出时补足，不超C
- **追加确认**：满额加题先明确"追加1题"，确认才C+1，取消零写入
- **归档/删除补位**：未完成归档移除补位，删除无论完成否均移除补位

### 4.3 数据一致性
- **原子操作**：事件+k/due/状态+计划同一事务
- **版本检查**：提交前重检版本/周期/生命周期
- **并发控制**：竞争时重新提示，不静默覆盖
- **陈旧卡拒绝**：被编辑/归档/删除/重学的旧卡不能提交

### 4.4 备份恢复安全
- **完整性校验**：格式版本、字段约束、数量、素材hash
- **路径安全**：解压路径穿越检查
- **容量预检**：临时空间、回滚空间、最终空间
- **非空保护**：当前数据非空必须先生成并确认最新快照
- **原子替换**：失败回滚，防并发编辑
- **Web读回确认**：下载不是成功，重选文件读回验证匹配才更新成功时间

### 4.5 Web 持久化安全
- **Drift wasm + IndexedDB**：真实持久化，不虚假成功
- **离线准备**：Service Worker + 离线资源，完成后显示"离线就绪"
- **配额探测**：可用时探测，不可用时明确未知，逐次写入校验
- **失败安全**：空间不足停止新增，不静默删除/降清晰度
- **域名隔离风险**：不同浏览器/域名不互通，清站点/驱逐可丢失
- **首次离线加载**：不承诺首次飞行模式可加载

## 5. 实施步骤

### Phase 1：基础设施（2周）
- [ ] 1.1 更新 Drift 数据库模式（6张表）
- [ ] 1.2 UTC+8 时区工具类
- [ ] 1.3 UUID 生成器
- [ ] 1.4 Web 平台检测与条件导入
- [ ] 1.5 配额探测服务
- [ ] 1.6 测试：数据库迁移、时区转换

### Phase 2：领域模型与调度（2周）
- [ ] 2.1 领域模型实现（MistakeQuestion, Draft, ReviewCycle等）
- [ ] 2.2 间隔复习算法（Scheduler）
- [ ] 2.3 每日计划管理（DailyPlanManager）
- [ ] 2.4 幂等性守护（IdempotencyGuard）
- [ ] 2.5 测试：调度算法单元测试、跨日测试、幂等性测试

### Phase 3：图片处理（1周）
- [ ] 3.1 相机/选图服务（权限最小化）
- [ ] 3.2 图片处理（裁剪、旋转、压缩、元数据清理）
- [ ] 3.3 图片存储（8张总限制）
- [ ] 3.4 测试：图片处理、HEIC降级、权限拒绝

### Phase 4：录入与编辑（2周）
- [ ] 4.1 草稿自动保存（静止1秒）
- [ ] 4.2 字段验证与限制
- [ ] 4.3 正式保存流程
- [ ] 4.4 编辑保持排期/重学逻辑
- [ ] 4.5 测试：草稿保存、正式保存、编辑

### Phase 5：复习流程（2周）
- [ ] 5.1 到期集合计算（排序）
- [ ] 5.2 每日计划建立
- [ ] 5.3 回忆核验流程（隐藏答案）
- [ ] 5.4 三档自评提交（原子操作）
- [ ] 5.5 跳过逻辑
- [ ] 5.6 手动练习（不计排期）
- [ ] 5.7 测试：复习流程、跨日旧卡、跳过

### Phase 6：生命周期（1周）
- [ ] 6.1 归档/取消归档
- [ ] 6.2 软删除/回收站（30自然日）
- [ ] 6.3 恢复/永久删除
- [ ] 6.4 再次出错（幂等、保留完成）
- [ ] 6.5 测试：生命周期、回收站清理

### Phase 7：搜索筛选统计（1周）
- [ ] 7.1 文本搜索（关键词、科目、标签）
- [ ] 7.2 筛选（状态、归档）
- [ ] 7.3 统计（状态、到期、错因分布、7/30日记录）
- [ ] 7.4 测试：搜索、筛选、统计口径

### Phase 8：备份恢复（2周）
- [ ] 8.1 完整备份生成（版本化快照）
- [ ] 8.2 Web 下载与读回验证
- [ ] 8.3 恢复预检（格式、容量、空间）
- [ ] 8.4 原子替换与回滚
- [ ] 8.5 测试：备份往返、损坏包、配额失败

### Phase 9：UI 实现（3周）
- [ ] 9.1 今日复习页（S01）
- [ ] 9.2 错题本页（S02-S03）
- [ ] 9.3 录入/编辑页（S04-S06）
- [ ] 9.4 详情页（S07）
- [ ] 9.5 复习卡片页（S08-S10）
- [ ] 9.6 手动练习页（S11-S12）
- [ ] 9.7 统计页（S13）
- [ ] 9.8 设置/数据管理页（S16-S21）
- [ ] 9.9 异常状态页（S22-S24）
- [ ] 9.10 测试：Widget 测试、集成测试

### Phase 10：Web 离线与可访问性（1周）
- [ ] 10.1 Service Worker 配置
- [ ] 10.2 离线资源准备
- [ ] 10.3 IndexedDB 持久化验证
- [ ] 10.4 200%字号重排
- [ ] 10.5 键盘导航
- [ ] 10.6 读屏标签
- [ ] 10.7 测试：离线冒烟、可访问性

### Phase 11：AC验收与修复（2周）
- [ ] 11.1 AC01-26 逐条验证
- [ ] 11.2 领域测试（调度、跨日、容量、再错、幂等）
- [ ] 11.3 失败注入测试
- [ ] 11.4 原子回滚测试
- [ ] 11.5 关库重开测试
- [ ] 11.6 修复发现的问题

### Phase 12：文档与交付（1周）
- [ ] 12.1 README 运行说明
- [ ] 12.2 AC01-26 证据记录
- [ ] 12.3 剩余阻塞列表
- [ ] 12.4 Web build zip
- [ ] 12.5 视觉截图（可行时）

## 6. 测试策略

### 6.1 单元测试
- 调度算法：k级别推进、间隔计算、幂等性
- 每日计划：容量管理、补位逻辑、追加确认
- 图片处理：裁剪、旋转、压缩、元数据清理
- 备份恢复：快照生成、校验、预检

### 6.2 集成测试
- 无后端本地 CRUD
- 关库重开持久化
- 复习流程端到端
- 备份往返验证

### 6.3 领域测试
- 调度跨日场景
- 再次出错幂等
- 容量满额追加
- 旧卡版本冲突

### 6.4 失败注入测试
- 空间不足
- 备份损坏
- 并发冲突
- 配额超限

### 6.5 Web 专项测试
- IndexedDB 持久化
- 离线加载
- 下载读回验证
- 配额探测

## 7. 风险与缓解

### 7.1 技术风险
- **Web IndexedDB 限制**：配额探测、失败安全、明确告知风险
- **Drift wasm 性能**：分页加载、延迟渲染、性能测试
- **图片处理性能**：后台处理、可取消、进度反馈

### 7.2 功能风险
- **调度算法复杂度**：充分单元测试、领域测试、边界用例
- **原子操作**：事务包装、失败回滚、并发锁
- **备份恢复安全**：多层预检、原子替换、回滚测试

### 7.3 时间风险
- **规模过大**：分模块增量交付、优先级排序、MVP先行
- **测试不足**：测试驱动开发、持续集成、自动化测试

## 8. 交付清单

- [ ] 可运行的 Web build.zip
- [ ] docs/AC_TRACKING_MATRIX.md（AC01-26逐条证据）
- [ ] docs/DATA_SAFETY_DESIGN.md（数据安全设计）
- [ ] README.md（运行说明、已验证/未验证列表）
- [ ] 视觉截图（可行时）
- [ ] 测试覆盖率报告
- [ ] 剩余阻塞清单

---

**下一步**：完成数据安全设计文档和 AC 追踪矩阵，然后开始 Phase 1 基础设施实现。
