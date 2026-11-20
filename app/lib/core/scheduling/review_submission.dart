/// 复习提交（领域服务）
library;

import 'learning_date.dart';
import 'review_result.dart';
import 'review_cycle.dart';
import 'review_event.dart';
import 'scheduler.dart';
import 'idempotency_guard.dart';

/// 提交结果
sealed class SubmissionResult {
  const SubmissionResult();
}

/// 提交成功
class SubmissionSuccess extends SubmissionResult {
  final ReviewCycle updatedCycle;
  final ReviewEvent event;

  const SubmissionSuccess({
    required this.updatedCycle,
    required this.event,
  });
}

/// 幂等重复
class SubmissionDuplicate extends SubmissionResult {
  final ReviewEvent existingEvent;
  final String reason;

  const SubmissionDuplicate({
    required this.existingEvent,
    required this.reason,
  });
}

/// 版本冲突
class SubmissionVersionConflict extends SubmissionResult {
  final int expectedVersion;
  final int actualVersion;

  const SubmissionVersionConflict({
    required this.expectedVersion,
    required this.actualVersion,
  });
}

/// 当日已再错禁止
class SubmissionResetTodayBlocked extends SubmissionResult {
  final int newCycleNumber;
  final String reason;

  const SubmissionResetTodayBlocked({
    required this.newCycleNumber,
    required this.reason,
  });
}

/// 缺少答案（无答案需先核验）
class SubmissionMissingAnswer extends SubmissionResult {
  final String reason;

  const SubmissionMissingAnswer({required this.reason});
}

/// 复习提交服务（领域层）
///
/// 注意：
/// - 这只是领域逻辑，不包含持久化
/// - 真实的原子操作需要在应用层通过数据库事务实现
/// - 文档明示：事件+k/due/状态+计划的事务集成仍未完成
class ReviewSubmissionService {
  const ReviewSubmissionService._();

  /// 提交排期复习自评
  ///
  /// 规则（PRD §06）：
  /// - 检查版本（乐观锁）
  /// - 检查幂等性（题+日唯一）
  /// - 检查再错当日禁止
  /// - 检查答案核验门槛（无答案需先确认核验）
  /// - 计算新k和新due
  /// - 生成事件
  ///
  /// 注意：手动练习和跳过不调用此方法（无排期变更）
  static SubmissionResult submitScheduledReview({
    required ReviewCycle currentCycle,
    required ReviewResult result,
    required LearningDate submittedDate,
    required List<ReviewEvent> existingEvents,
    required List<ReviewCycle> allCycles,
    required bool hasAnswer,
    required bool hasConfirmedVerification,
  }) {
    // 1. 检查版本（旧卡拒绝）
    if (!currentCycle.isActive) {
      return SubmissionVersionConflict(
        expectedVersion: currentCycle.version,
        actualVersion: -1, // 已失效
      );
    }

    // 2. 检查答案核验门槛
    if (!hasAnswer && !hasConfirmedVerification) {
      return const SubmissionMissingAnswer(
        reason: '无参考答案，需先确认已自行核验',
      );
    }

    // 3. 检查幂等性（题+日唯一）
    final idempotencyCheck = IdempotencyGuard.checkReviewIdempotency(
      questionId: currentCycle.questionId,
      learningDate: submittedDate,
      existingEvents: existingEvents,
    );

    if (idempotencyCheck is IdempotencyDuplicate) {
      return SubmissionDuplicate(
        existingEvent: idempotencyCheck.existingEvent,
        reason: idempotencyCheck.reason,
      );
    }

    // 4. 检查再错当日禁止
    final resetCheck = IdempotencyGuard.checkMistakeAgainIdempotency(
      questionId: currentCycle.questionId,
      operationDate: submittedDate,
      allCycles: allCycles,
    );

    if (resetCheck is IdempotencyResetToday) {
      return SubmissionResetTodayBlocked(
        newCycleNumber: resetCheck.newCycleNumber,
        reason: resetCheck.reason,
      );
    }

    // 5. 计算新状态
    final newK = Scheduler.calculateNextK(
      currentK: currentCycle.kLevel,
      result: result,
    );

    final newDue = Scheduler.calculateNextDue(
      currentK: currentCycle.kLevel,
      result: result,
      submittedDate: submittedDate,
    );

    // 6. 生成更新后的周期
    final updatedCycle = currentCycle.copyWith(
      kLevel: newK,
      dueDate: newDue,
      clearDue: newDue == null,
      version: currentCycle.version + 1,
    );

    // 7. 生成事件
    final event = ReviewEvent(
      questionId: currentCycle.questionId,
      cycleNumber: currentCycle.cycleNumber,
      learningDate: submittedDate,
      result: result,
      kLevelBefore: currentCycle.kLevel,
      kLevelAfter: newK,
      dueDateAfter: newDue,
    );

    return SubmissionSuccess(
      updatedCycle: updatedCycle,
      event: event,
    );
  }

  /// 再次出错（领域逻辑）
  ///
  /// 规则（PRD §06）：
  /// - 同题+日幂等
  /// - 新周期k0，due=明日
  /// - 旧周期关闭
  /// - 当日不可再排期
  static ReviewCycle markAsMistakeAgain({
    required ReviewCycle currentCycle,
    required LearningDate operationDate,
  }) {
    return Scheduler.createNewCycleForMistakeAgain(
      questionId: currentCycle.questionId,
      previousCycleNumber: currentCycle.cycleNumber,
      operationDate: operationDate,
    );
  }
}
