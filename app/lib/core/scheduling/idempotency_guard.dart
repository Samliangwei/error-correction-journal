/// 幂等性守护
library;

import 'learning_date.dart';
import 'review_event.dart';
import 'review_cycle.dart';

/// 幂等性检查结果
sealed class IdempotencyResult {
  const IdempotencyResult();
}

/// 允许提交
class IdempotencyAllowed extends IdempotencyResult {
  const IdempotencyAllowed();
}

/// 重复提交（同题同日已有有效自评）
class IdempotencyDuplicate extends IdempotencyResult {
  final ReviewEvent existingEvent;
  final String reason;

  const IdempotencyDuplicate({
    required this.existingEvent,
    required this.reason,
  });
}

/// 再错后当日禁止
class IdempotencyResetToday extends IdempotencyResult {
  final int newCycleNumber;
  final String reason;

  const IdempotencyResetToday({
    required this.newCycleNumber,
    required this.reason,
  });
}

/// 幂等性守护（领域规则）
///
/// 注意：这只是领域层的幂等性逻辑验证。
/// 真实的并发控制需要在持久化层通过数据库事务+唯一约束实现。
class IdempotencyGuard {
  const IdempotencyGuard._();

  /// 检查题+日的复习幂等性
  ///
  /// 规则（PRD §06）：
  /// - 题UUID + 学习日期 → 唯一有效自评
  /// - 跨周期也不能同日第二次自评
  /// - 重复请求返回首次结果
  static IdempotencyResult checkReviewIdempotency({
    required String questionId,
    required LearningDate learningDate,
    required List<ReviewEvent> existingEvents,
  }) {
    // 查找同题同日的事件
    final todayEvents = existingEvents.where(
      (e) => e.questionId == questionId && e.learningDate == learningDate,
    );

    if (todayEvents.isEmpty) {
      return const IdempotencyAllowed();
    }

    // 已有事件，返回首次
    final firstEvent = todayEvents.first;
    return IdempotencyDuplicate(
      existingEvent: firstEvent,
      reason:
          '题 $questionId 在 $learningDate 已有有效自评（周期 ${firstEvent.cycleNumber}），'
          '不能重复提交',
    );
  }

  /// 检查再错幂等性
  ///
  /// 规则（PRD §06）：
  /// - 同题+学习日只能再错一次（幂等）
  /// - 已再错当日禁止排期自评
  static IdempotencyResult checkMistakeAgainIdempotency({
    required String questionId,
    required LearningDate operationDate,
    required List<ReviewCycle> allCycles,
  }) {
    // 查找今日创建的新周期
    final todayNewCycles = allCycles.where((c) =>
        c.questionId == questionId &&
        c.isActive &&
        c.dueDate != null &&
        c.dueDate!.addDays(-1) == operationDate); // due=明日 → 今日创建

    if (todayNewCycles.isEmpty) {
      return const IdempotencyAllowed();
    }

    // 同日已再错，返回新周期号
    final newCycle = todayNewCycles.first;
    return IdempotencyResetToday(
      newCycleNumber: newCycle.cycleNumber,
      reason:
          '题 $questionId 在 $operationDate 已执行再次出错（新周期 ${newCycle.cycleNumber}），'
          '当日不可再排期自评',
    );
  }
}
