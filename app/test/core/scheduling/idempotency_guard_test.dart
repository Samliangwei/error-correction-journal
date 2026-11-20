import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/core/scheduling/learning_date.dart';
import 'package:error_journal/core/scheduling/review_result.dart';
import 'package:error_journal/core/scheduling/review_cycle.dart';
import 'package:error_journal/core/scheduling/review_event.dart';
import 'package:error_journal/core/scheduling/idempotency_guard.dart';

void main() {
  group('IdempotencyGuard - AC07: 幂等性', () {
    test('同题同日无事件，允许提交', () {
      // Given: 无历史事件
      final existingEvents = <ReviewEvent>[];

      // When: 检查幂等性
      final result = IdempotencyGuard.checkReviewIdempotency(
        questionId: 'q1',
        learningDate: LearningDate.parse('2026-11-20'),
        existingEvents: existingEvents,
      );

      // Then: 允许
      expect(result, isA<IdempotencyAllowed>());
    });

    test('同题同日已有事件，返回首次结果', () {
      // Given: 已有一次会了的事件
      final existingEvent = ReviewEvent(
        questionId: 'q1',
        cycleNumber: 1,
        learningDate: LearningDate.parse('2026-11-20'),
        result: ReviewResult.know,
        kLevelBefore: KLevel.k0,
        kLevelAfter: KLevel.k1,
        dueDateAfter: LearningDate.parse('2026-11-23'),
      );

      // When: 重复提交（不同结果）
      final result = IdempotencyGuard.checkReviewIdempotency(
        questionId: 'q1',
        learningDate: LearningDate.parse('2026-11-20'),
        existingEvents: [existingEvent],
      );

      // Then: 拒绝，返回首次
      expect(result, isA<IdempotencyDuplicate>());
      final duplicate = result as IdempotencyDuplicate;
      expect(duplicate.existingEvent.result, ReviewResult.know);
      expect(duplicate.reason, contains('已有有效自评'));
    });

    test('同题不同日，允许提交', () {
      // Given: 昨日有事件
      final existingEvent = ReviewEvent(
        questionId: 'q1',
        cycleNumber: 1,
        learningDate: LearningDate.parse('2026-11-19'),
        result: ReviewResult.know,
        kLevelBefore: KLevel.k0,
        kLevelAfter: KLevel.k1,
        dueDateAfter: LearningDate.parse('2026-11-22'),
      );

      // When: 今日提交
      final result = IdempotencyGuard.checkReviewIdempotency(
        questionId: 'q1',
        learningDate: LearningDate.parse('2026-11-20'),
        existingEvents: [existingEvent],
      );

      // Then: 允许（不同日）
      expect(result, isA<IdempotencyAllowed>());
    });

    test('不同题同日，允许提交', () {
      // Given: q1有事件
      final existingEvent = ReviewEvent(
        questionId: 'q1',
        cycleNumber: 1,
        learningDate: LearningDate.parse('2026-11-20'),
        result: ReviewResult.know,
        kLevelBefore: KLevel.k0,
        kLevelAfter: KLevel.k1,
        dueDateAfter: LearningDate.parse('2026-11-23'),
      );

      // When: q2提交
      final result = IdempotencyGuard.checkReviewIdempotency(
        questionId: 'q2',
        learningDate: LearningDate.parse('2026-11-20'),
        existingEvents: [existingEvent],
      );

      // Then: 允许（不同题）
      expect(result, isA<IdempotencyAllowed>());
    });

    test('跨周期也不能同日第二次自评', () {
      // Given: 周期1已有事件
      final event1 = ReviewEvent(
        questionId: 'q1',
        cycleNumber: 1,
        learningDate: LearningDate.parse('2026-11-20'),
        result: ReviewResult.know,
        kLevelBefore: KLevel.k0,
        kLevelAfter: KLevel.k1,
        dueDateAfter: LearningDate.parse('2026-11-23'),
      );

      // When: 周期2尝试提交（模拟再错后的新周期）
      final result = IdempotencyGuard.checkReviewIdempotency(
        questionId: 'q1',
        learningDate: LearningDate.parse('2026-11-20'),
        existingEvents: [event1],
      );

      // Then: 拒绝（题+日唯一，不论周期）
      expect(result, isA<IdempotencyDuplicate>());
    });
  });

  group('IdempotencyGuard - 再错幂等性', () {
    test('今日未再错，允许', () {
      // Given: 无新周期
      final allCycles = <ReviewCycle>[
        ReviewCycle(
          questionId: 'q1',
          cycleNumber: 1,
          kLevel: KLevel.k2,
          dueDate: LearningDate.parse('2026-11-20'),
          isActive: true,
          version: 3,
        ),
      ];

      // When: 检查再错幂等性
      final result = IdempotencyGuard.checkMistakeAgainIdempotency(
        questionId: 'q1',
        operationDate: LearningDate.parse('2026-11-20'),
        allCycles: allCycles,
      );

      // Then: 允许
      expect(result, isA<IdempotencyAllowed>());
    });

    test('今日已再错（新周期due=明日），禁止排期', () {
      // Given: 今日创建的新周期（due=明日 → 今日创建）
      final allCycles = <ReviewCycle>[
        // 旧周期已关闭
        ReviewCycle(
          questionId: 'q1',
          cycleNumber: 1,
          kLevel: KLevel.k2,
          dueDate: LearningDate.parse('2026-11-20'),
          isActive: false,
          version: 5,
        ),
        // 新周期（今日11/20创建，due=11/21）
        ReviewCycle(
          questionId: 'q1',
          cycleNumber: 2,
          kLevel: KLevel.k0,
          dueDate: LearningDate.parse('2026-11-21'), // 明日
          isActive: true,
          version: 1,
        ),
      ];

      // When: 检查今日11/20的再错幂等性
      final result = IdempotencyGuard.checkMistakeAgainIdempotency(
        questionId: 'q1',
        operationDate: LearningDate.parse('2026-11-20'),
        allCycles: allCycles,
      );

      // Then: 禁止（今日已再错）
      expect(result, isA<IdempotencyResetToday>());
      final blocked = result as IdempotencyResetToday;
      expect(blocked.newCycleNumber, 2);
      expect(blocked.reason, contains('已执行再次出错'));
      expect(blocked.reason, contains('当日不可再排期自评'));
    });
  });
}
