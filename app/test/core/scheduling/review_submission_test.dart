import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/core/scheduling/learning_date.dart';
import 'package:error_journal/core/scheduling/review_result.dart';
import 'package:error_journal/core/scheduling/review_cycle.dart';
import 'package:error_journal/core/scheduling/review_event.dart';
import 'package:error_journal/core/scheduling/review_submission.dart';

void main() {
  group('ReviewSubmissionService - 排期复习提交', () {
    test('正常提交成功', () {
      // Given: k0周期，无历史事件，有答案
      final currentCycle = ReviewCycle(
        questionId: 'q1',
        cycleNumber: 1,
        kLevel: KLevel.k0,
        dueDate: LearningDate.parse('2026-11-21'),
        isActive: true,
        version: 1,
      );

      // When: 提交会了
      final result = ReviewSubmissionService.submitScheduledReview(
        currentCycle: currentCycle,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-21'),
        existingEvents: [],
        allCycles: [currentCycle],
        hasAnswer: true,
        hasConfirmedVerification: false,
      );

      // Then: 成功
      expect(result, isA<SubmissionSuccess>());
      final success = result as SubmissionSuccess;
      expect(success.updatedCycle.kLevel, KLevel.k1);
      expect(success.updatedCycle.dueDate?.value, '2026-11-24');
      expect(success.updatedCycle.version, 2); // 版本递增
      expect(success.event.result, ReviewResult.know);
      expect(success.event.learningDate.value, '2026-11-21');
    });

    test('无答案未确认核验，拒绝', () {
      final currentCycle = ReviewCycle(
        questionId: 'q1',
        cycleNumber: 1,
        kLevel: KLevel.k0,
        dueDate: LearningDate.parse('2026-11-21'),
        isActive: true,
        version: 1,
      );

      // When: 无答案且未确认核验
      final result = ReviewSubmissionService.submitScheduledReview(
        currentCycle: currentCycle,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-21'),
        existingEvents: [],
        allCycles: [currentCycle],
        hasAnswer: false,
        hasConfirmedVerification: false, // 未确认
      );

      // Then: 拒绝
      expect(result, isA<SubmissionMissingAnswer>());
      final missing = result as SubmissionMissingAnswer;
      expect(missing.reason, contains('需先确认已自行核验'));
    });

    test('无答案但已确认核验，允许', () {
      final currentCycle = ReviewCycle(
        questionId: 'q1',
        cycleNumber: 1,
        kLevel: KLevel.k0,
        dueDate: LearningDate.parse('2026-11-21'),
        isActive: true,
        version: 1,
      );

      // When: 无答案但已确认核验
      final result = ReviewSubmissionService.submitScheduledReview(
        currentCycle: currentCycle,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-21'),
        existingEvents: [],
        allCycles: [currentCycle],
        hasAnswer: false,
        hasConfirmedVerification: true, // 已确认
      );

      // Then: 成功
      expect(result, isA<SubmissionSuccess>());
    });

    test('同题同日重复提交，返回幂等', () {
      final currentCycle = ReviewCycle(
        questionId: 'q1',
        cycleNumber: 1,
        kLevel: KLevel.k0,
        dueDate: LearningDate.parse('2026-11-21'),
        isActive: true,
        version: 1,
      );

      // Given: 已有首次事件（会了）
      final existingEvent = ReviewEvent(
        questionId: 'q1',
        cycleNumber: 1,
        learningDate: LearningDate.parse('2026-11-21'),
        result: ReviewResult.know,
        kLevelBefore: KLevel.k0,
        kLevelAfter: KLevel.k1,
        dueDateAfter: LearningDate.parse('2026-11-24'),
      );

      // When: 重复提交（不同结果）
      final result = ReviewSubmissionService.submitScheduledReview(
        currentCycle: currentCycle,
        result: ReviewResult.fuzzy, // 不同
        submittedDate: LearningDate.parse('2026-11-21'),
        existingEvents: [existingEvent],
        allCycles: [currentCycle],
        hasAnswer: true,
        hasConfirmedVerification: false,
      );

      // Then: 幂等返回首次
      expect(result, isA<SubmissionDuplicate>());
      final duplicate = result as SubmissionDuplicate;
      expect(duplicate.existingEvent.result, ReviewResult.know); // 首次结果
    });

    test('今日已再错，禁止排期', () {
      final oldCycle = ReviewCycle(
        questionId: 'q1',
        cycleNumber: 1,
        kLevel: KLevel.k2,
        dueDate: LearningDate.parse('2026-11-20'),
        isActive: false, // 已关闭
        version: 5,
      );

      final newCycle = ReviewCycle(
        questionId: 'q1',
        cycleNumber: 2,
        kLevel: KLevel.k0,
        dueDate: LearningDate.parse('2026-11-21'), // 明日
        isActive: true,
        version: 1,
      );

      // When: 尝试在新周期提交（今日已再错）
      final result = ReviewSubmissionService.submitScheduledReview(
        currentCycle: newCycle,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        existingEvents: [],
        allCycles: [oldCycle, newCycle],
        hasAnswer: true,
        hasConfirmedVerification: false,
      );

      // Then: 禁止
      expect(result, isA<SubmissionResetTodayBlocked>());
      final blocked = result as SubmissionResetTodayBlocked;
      expect(blocked.newCycleNumber, 2);
    });

    test('周期已失效（isActive=false），版本冲突', () {
      final inactiveCycle = ReviewCycle(
        questionId: 'q1',
        cycleNumber: 1,
        kLevel: KLevel.k1,
        dueDate: LearningDate.parse('2026-11-21'),
        isActive: false, // 已失效
        version: 3,
      );

      // When: 尝试提交旧卡
      final result = ReviewSubmissionService.submitScheduledReview(
        currentCycle: inactiveCycle,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-21'),
        existingEvents: [],
        allCycles: [inactiveCycle],
        hasAnswer: true,
        hasConfirmedVerification: false,
      );

      // Then: 版本冲突
      expect(result, isA<SubmissionVersionConflict>());
    });
  });

  group('ReviewSubmissionService - 再次出错', () {
    test('创建新周期k0, due=明日', () {
      final currentCycle = ReviewCycle(
        questionId: 'q1',
        cycleNumber: 1,
        kLevel: KLevel.k3,
        dueDate: LearningDate.parse('2026-12-01'),
        isActive: true,
        version: 5,
      );

      // When: 再次出错
      final newCycle = ReviewSubmissionService.markAsMistakeAgain(
        currentCycle: currentCycle,
        operationDate: LearningDate.parse('2026-11-20'),
      );

      // Then: 新周期
      expect(newCycle.questionId, 'q1');
      expect(newCycle.cycleNumber, 2);
      expect(newCycle.kLevel, KLevel.k0);
      expect(newCycle.dueDate?.value, '2026-11-21');
      expect(newCycle.isActive, true);
    });
  });
}
