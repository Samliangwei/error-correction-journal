/// 间隔复习调度器
library;

import 'learning_date.dart';
import 'review_result.dart';
import 'review_cycle.dart';

/// 调度器（纯函数，无副作用）
class Scheduler {
  const Scheduler._();

  /// 计算下次due日期
  ///
  /// 规则（PRD §06）：
  /// - 不会 → k0, +1天
  /// - 模糊 → k保持, +1天
  /// - 会了 → k递进:
  ///   - k0→k1: +3天
  ///   - k1→k2: +7天
  ///   - k2→k3: +14天
  ///   - k3→k4: 清空due（已掌握）
  ///
  /// 迟做按实际提交日计算，不以原due
  static LearningDate? calculateNextDue({
    required KLevel currentK,
    required ReviewResult result,
    required LearningDate submittedDate,
  }) {
    switch (result) {
      case ReviewResult.notKnow:
        // 不会 → +1天（k变0，但这里只算due）
        return submittedDate.addDays(1);

      case ReviewResult.fuzzy:
        // 模糊 → +1天（k保持）
        return submittedDate.addDays(1);

      case ReviewResult.know:
        // 会了 → k递进
        switch (currentK) {
          case KLevel.k0:
            return submittedDate.addDays(3); // k0→k1, +3
          case KLevel.k1:
            return submittedDate.addDays(7); // k1→k2, +7
          case KLevel.k2:
            return submittedDate.addDays(14); // k2→k3, +14
          case KLevel.k3:
            return null; // k3→k4, 清空due（已掌握）
          case KLevel.k4:
            return null; // 已是k4，保持
        }
    }
  }

  /// 计算新的k级别
  static KLevel calculateNextK({
    required KLevel currentK,
    required ReviewResult result,
  }) {
    switch (result) {
      case ReviewResult.notKnow:
        return KLevel.k0; // 不会归零

      case ReviewResult.fuzzy:
        return currentK; // 模糊保持

      case ReviewResult.know:
        // 会了递进
        final next = currentK.next();
        return next ?? KLevel.k4; // 已是k4则保持
    }
  }

  /// 创建新周期（再次出错）
  ///
  /// 规则（PRD §06）：
  /// - 新周期k0，due=操作日+1
  /// - 周期号递增
  static ReviewCycle createNewCycleForMistakeAgain({
    required String questionId,
    required int previousCycleNumber,
    required LearningDate operationDate,
  }) {
    return ReviewCycle(
      questionId: questionId,
      cycleNumber: previousCycleNumber + 1,
      kLevel: KLevel.k0,
      dueDate: operationDate.addDays(1), // 明日
      isActive: true,
      version: 1,
    );
  }
}
