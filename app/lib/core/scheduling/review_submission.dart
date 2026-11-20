/// 复习提交结果（领域模型）
library;

import 'learning_date.dart';
import 'review_cycle.dart';
import 'review_event.dart';
import 'review_result.dart';
import 'scheduler.dart';
import 'idempotency_guard.dart';

/// 提交结果基类
sealed class SubmissionResult {}

/// 成功
class SubmissionSuccess extends SubmissionResult {
  final ReviewEvent event;
  final ReviewCycle updatedCycle;

  SubmissionSuccess({
    required this.event,
    required this.updatedCycle,
  });
}

/// 重复（幂等）
class SubmissionDuplicate extends SubmissionResult {
  final ReviewEvent existingEvent;

  SubmissionDuplicate(this.existingEvent);
}

/// 无答案需核验
class SubmissionNeedsVerification extends SubmissionResult {}

/// 今日已再错，禁止排期
class SubmissionBlockedByMistakeAgain extends SubmissionResult {
  final int newCycleNumber;

  SubmissionBlockedByMistakeAgain(this.newCycleNumber);
}

/// 周期版本冲突
class SubmissionStaleVersion extends SubmissionResult {
  final ReviewCycle currentCycle;

  SubmissionStaleVersion(this.currentCycle);
}

/// 容量已满需要确认
class SubmissionCapacityFull extends SubmissionResult {
  final int currentCount;
  final int capacityC;

  SubmissionCapacityFull({
    required this.currentCount,
    required this.capacityC,
  });
}

/// 题目已失效（归档/删除）
class SubmissionQuestionInactive extends SubmissionResult {
  final String reason;
  SubmissionQuestionInactive({required this.reason});
}

/// 周期已替换（旧卡）
class SubmissionStaleCycle extends SubmissionResult {
  final String expectedId;
  final String actualId;
  SubmissionStaleCycle({required this.expectedId, required this.actualId});
}

/// 已掌握
class SubmissionAlreadyMastered extends SubmissionResult {}

/// 未到期
class SubmissionNotDueYet extends SubmissionResult {
  final LearningDate dueDate;
  SubmissionNotDueYet({required this.dueDate});
}

/// 复习提交服务（领域层）
class ReviewSubmissionService {
  /// 提交排期复习
  static SubmissionResult submitScheduledReview({
    required ReviewCycle currentCycle,
    required ReviewResult result,
    required LearningDate submittedDate,
    required List<ReviewEvent> existingEvents,
    required List<ReviewCycle> allCycles,
    required bool hasAnswer,
    required bool hasConfirmedVerification,
  }) {
    // 1. 无答案核验
    if (!hasAnswer && !hasConfirmedVerification) {
      return SubmissionNeedsVerification();
    }

    // 2. 幂等性检查
    final reviewIdempotency = IdempotencyGuard.checkReviewIdempotency(
      questionId: currentCycle.questionId,
      learningDate: submittedDate,
      existingEvents: existingEvents,
    );

    if (reviewIdempotency is IdempotencyDuplicate) {
      return SubmissionDuplicate(reviewIdempotency.existingEvent);
    }

    // 3. 再错检查
    final mistakeAgainCheck = IdempotencyGuard.checkMistakeAgainIdempotency(
      questionId: currentCycle.questionId,
      operationDate: submittedDate,
      allCycles: allCycles,
    );

    if (mistakeAgainCheck is IdempotencyResetToday) {
      return SubmissionBlockedByMistakeAgain(
        mistakeAgainCheck.newCycleNumber,
      );
    }

    // 4. 版本检查
    if (!currentCycle.isActive) {
      return SubmissionStaleVersion(currentCycle);
    }

    // 5. 计算新状态
    final nextDue = Scheduler.calculateNextDue(
      currentK: currentCycle.kLevel,
      result: result,
      submittedDate: submittedDate,
    );

    final nextK = Scheduler.calculateNextK(
      currentK: currentCycle.kLevel,
      result: result,
    );

    // 6. 创建事件
    final event = ReviewEvent(
      questionId: currentCycle.questionId,
      cycleNumber: currentCycle.cycleNumber,
      learningDate: submittedDate,
      result: result,
      kLevelBefore: currentCycle.kLevel,
      kLevelAfter: nextK,
      dueDateAfter: nextDue,
    );

    // 7. 更新周期
    final updatedCycle = ReviewCycle(
      questionId: currentCycle.questionId,
      cycleNumber: currentCycle.cycleNumber,
      kLevel: nextK,
      dueDate: nextDue,
      isActive: currentCycle.isActive,
      version: currentCycle.version + 1,
    );

    return SubmissionSuccess(
      event: event,
      updatedCycle: updatedCycle,
    );
  }
}
