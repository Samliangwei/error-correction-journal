# 增量交付 1：复习调度领域模块

交付时间：2026-11-20  
提交哈希：`a614c027894701ca60756f83e4d0136ade486349`

## ✅ 交付内容

### 1. 纯Dart领域模块（无SQLite/设备依赖）

**7个核心文件**：
- `app/lib/core/scheduling/learning_date.dart` (69行)
- `app/lib/core/scheduling/review_result.dart` (11行)
- `app/lib/core/scheduling/review_cycle.dart` (106行)
- `app/lib/core/scheduling/review_event.dart` (32行)
- `app/lib/core/scheduling/scheduler.dart` (93行)
- `app/lib/core/scheduling/idempotency_guard.dart` (105行)
- `app/lib/core/scheduling/review_submission.dart` (193行)

**总计**：609行生产代码

### 2. 完整自动化测试

**4个测试文件**：
- `app/test/core/scheduling/learning_date_test.dart` (72行)
- `app/test/core/scheduling/scheduler_test.dart` (293行)
- `app/test/core/scheduling/idempotency_guard_test.dart` (184行)
- `app/test/core/scheduling/review_submission_test.dart` (219行)

**总计**：768行测试代码，33个测试用例

## ✅ 验收证据

### flutter analyze
```bash
cd app && flutter analyze
```
**结果**：✅ `No issues found! (ran in 1.2s)`

### flutter test
```bash
cd app && flutter test test/core/scheduling/
```
**结果**：✅ `33个测试全部通过 (00:02)`

### 测试覆盖

| AC编号 | 测试场景 | 测试数量 | 状态 |
|--------|----------|----------|------|
| AC-04 | k级别与间隔推进 | 7 | ✅ 通过 |
| AC-05 | 模糊与不会 | 3 | ✅ 通过 |
| AC-06 | 迟做按实际提交日 | 2 | ✅ 通过 |
| AC-07 | 幂等性（题+日唯一） | 7 | ✅ 通过 |
| - | 再错幂等性 | 2 | ✅ 通过 |
| - | 答案核验门槛 | 3 | ✅ 通过 |
| - | 版本冲突检查 | 1 | ✅ 通过 |
| - | UTC+8时区 | 8 | ✅ 通过 |

**总计**：33个测试用例，全部通过

## ✅ 实现的核心功能

### 1. 固定UTC+8学习日期
- ✅ 支持Clock注入，可测试
- ✅ UTC时间自动转UTC+8
- ✅ 跨日边界正确处理（UTC 23:00 → UTC+8次日07:00）
- ✅ 日期加减天数计算
- ✅ 格式验证（yyyy-MM-dd）

**示例**：
```dart
// 注入测试clock
final fakeClock = Clock.fixed(DateTime.utc(2026, 11, 20, 23, 0, 0));
final today = LearningDate.today(clock: fakeClock);
// today.value == '2026-11-21' (UTC+8次日)
```

### 2. k0-4级别推进算法
- ✅ 保存日D → k0, due=D+1（次日首复习）
- ✅ k0会了 → k1, +3天
- ✅ k1会了 → k2, +7天
- ✅ k2会了 → k3, +14天
- ✅ k3会了 → k4, 清空due（已掌握）

**PRD示例验证**（AC-04）：
```
11/20保存 → 11/21首复习(k0会了)
         → 11/24复习(k1会了)
         → 12/01复习(k2会了)
         → 12/15复习(k3会了)
         → k4已掌握
```
✅ 测试通过

### 3. 模糊与不会
- ✅ 模糊 → k保持，+1天
- ✅ 不会 → k归0，+1天
- ✅ 周期号不变（非再错）

**PRD示例验证**（AC-05）：
```
k2模糊 → k2, +1天
k2不会 → k0, +1天
```
✅ 测试通过

### 4. 迟做按实际提交日
- ✅ 逾期后从提交日计算新due，不从原due
- ✅ 支持任意天数逾期

**PRD示例验证**（AC-06）：
```
due=11/20, 实际11/21提交 → 从11/21计算+3天=11/24
```
✅ 测试通过

### 5. 再次出错
- ✅ 新周期k0, due=明日
- ✅ 周期号递增
- ✅ 旧周期保留（历史）

**PRD规则验证**：
```dart
// 旧周期k3, 再错
final newCycle = Scheduler.createNewCycleForMistakeAgain(
  questionId: 'q1',
  previousCycleNumber: 1,
  operationDate: LearningDate.parse('2026-11-20'),
);
// newCycle.cycleNumber == 2
// newCycle.kLevel == k0
// newCycle.dueDate == '2026-11-21'
```
✅ 测试通过

### 6. 题+日幂等性守护
- ✅ 题UUID + 学习日期 → 唯一有效自评
- ✅ 重复提交返回首次结果
- ✅ 跨周期也不能同日第二次自评
- ✅ 再错同日禁止排期自评

**PRD示例验证**（AC-07）：
```
题q1, 11/20首次提交(会了) → 成功
题q1, 11/20重复提交(模糊) → 拒绝，返回首次"会了"
题q1, 11/20再错后尝试自评 → 拒绝，"当日不可再排期"
```
✅ 测试通过

### 7. 无答案核验门槛
- ✅ 有答案 → 直接允许自评
- ✅ 无答案且未确认核验 → 拒绝，提示"需先确认已自行核验"
- ✅ 无答案但已确认核验 → 允许自评

**领域规则验证**：
```dart
// 无答案且未确认
final result = ReviewSubmissionService.submitScheduledReview(
  hasAnswer: false,
  hasConfirmedVerification: false,
  // ...
);
// result is SubmissionMissingAnswer
```
✅ 测试通过

### 8. 旧版本卡拒绝
- ✅ 周期已失效（isActive=false）→ 版本冲突
- ✅ 保护数据一致性

## ⚠️ 已知限制（明确标注）

### 1. 纯领域层实现
- ✅ **已实现**：领域逻辑、业务规则、算法
- ❌ **未实现**：持久化、数据库事务、并发控制
- 📝 **说明**：真实并发控制需在持久化层通过数据库事务+唯一约束实现

### 2. 事务集成待完成
- ✅ **已实现**：领域层的原子提交逻辑设计
- ❌ **未实现**：事件+k/due/状态+计划的真实数据库原子事务
- 📝 **说明**：需在应用层/持久化层实现

### 3. 手动练习和跳过
- ✅ **已实现**：领域层的"不改排期"条件验证
- ❌ **未实现**：UI集成、完整跳过会话管理
- 📝 **说明**：领域层提供基础，应用层实现完整流程

## 📊 代码统计

```
生产代码：609行（7个文件）
测试代码：768行（4个文件）
测试覆盖：33个测试用例，100%通过
代码/测试比：1:1.26
```

## 🔄 Git信息

**分支**：`cursor/error-journal-scaffold-1e05`  
**提交哈希**：`a614c027894701ca60756f83e4d0136ade486349`  
**提交时间**：2026-11-20 08:25:59 UTC  
**远程仓库**：https://github.com/Samliangwei/error-correction-journal  

**修改文件**：
```
新增：
  app/lib/core/scheduling/idempotency_guard.dart
  app/lib/core/scheduling/learning_date.dart
  app/lib/core/scheduling/review_cycle.dart
  app/lib/core/scheduling/review_event.dart
  app/lib/core/scheduling/review_result.dart
  app/lib/core/scheduling/review_submission.dart
  app/lib/core/scheduling/scheduler.dart
  app/test/core/scheduling/idempotency_guard_test.dart
  app/test/core/scheduling/learning_date_test.dart
  app/test/core/scheduling/review_submission_test.dart
  app/test/core/scheduling/scheduler_test.dart

修改：
  app/pubspec.yaml (添加clock依赖)
  app/pubspec.lock
```

## ✅ 执行命令（可复现）

```bash
# 1. 静态分析
cd app && flutter analyze
# 结果：No issues found!

# 2. 运行测试
cd app && flutter test test/core/scheduling/
# 结果：33个测试全部通过

# 3. 查看提交
git show a614c027894701ca60756f83e4d0136ade486349
# 结果：13 files changed, 1381 insertions(+), 1 deletion(-)
```

## 📋 AC追踪矩阵更新

### AC-04（k级别与间隔推进）
- **领域层测试**：✅ 7/7通过
- **持久化集成**：⏸️ 待实现
- **多窗口并发**：⏸️ 待实现

### AC-05（模糊与不会）
- **领域层测试**：✅ 3/3通过
- **持久化集成**：⏸️ 待实现

### AC-06（迟做按实际提交日）
- **领域层测试**：✅ 2/2通过
- **跨日旧卡原子检查**：⏸️ 待实现（需持久化层）

### AC-07（幂等性）
- **领域层测试**：✅ 7/7通过（逻辑验证）
- **数据库唯一约束**：⏸️ 待实现
- **并发冲突处理**：⏸️ 待实现

### 其他AC（AC-01至AC-03, AC-08至AC-26）
- **状态**：⏸️ 未开始
- **依赖**：需要持久化层、UI层、图片处理等

## 🎯 下一步建议

### 优先级1：持久化层
1. Drift数据库表定义（mistake_questions, review_cycles, review_events, daily_plans）
2. Repository实现（将领域模型映射到数据库）
3. 数据库唯一约束（questionId + learningDate）
4. 事务包装（原子提交）

### 优先级2：每日计划管理
1. DailyPlanManager实现
2. 容量C、目标N规则
3. 已完成不释放、自动补位逻辑
4. 追加确认流程

### 优先级3：UI集成
1. 复习卡片页面（隐藏答案、回忆确认、三档自评）
2. 今日计划页面
3. 详情页面（编辑、再错、手动练习）

---

**交付状态**：✅ **完成并已验证**

本增量实现了复习调度算法的核心领域逻辑，通过33个自动化测试验证，无任何静态分析错误，已推送到远程仓库。

下一增量将实现持久化层，将领域模型与Drift数据库集成。
