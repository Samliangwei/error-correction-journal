import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/core/scheduling/learning_date.dart';
import 'package:error_journal/core/scheduling/review_result.dart';
import 'package:error_journal/core/scheduling/review_cycle.dart';
import 'package:error_journal/core/scheduling/scheduler.dart';

void main() {
  group('Scheduler - AC04: k级别与间隔推进', () {
    test('保存日次日首复习', () {
      // Given: 11月20日保存
      final formalizedDate = LearningDate.parse('2026-11-20');

      // When: 创建初始周期
      final cycle = ReviewCycle.initial(
        questionId: 'q1',
        formalizedDate: formalizedDate,
      );

      // Then: k=0, due=次日
      expect(cycle.kLevel, KLevel.k0);
      expect(cycle.dueDate?.value, '2026-11-21');
      expect(cycle.cycleNumber, 1);
      expect(cycle.isActive, true);
    });

    test('k0会了→k1, +3天 (11/21→11/24)', () {
      // Given: k0
      final submittedDate = LearningDate.parse('2026-11-21');

      // When: 会了
      final newDue = Scheduler.calculateNextDue(
        currentK: KLevel.k0,
        result: ReviewResult.know,
        submittedDate: submittedDate,
      );

      final newK = Scheduler.calculateNextK(
        currentK: KLevel.k0,
        result: ReviewResult.know,
      );

      // Then: k1, +3天
      expect(newK, KLevel.k1);
      expect(newDue?.value, '2026-11-24'); // 21+3
    });

    test('k1会了→k2, +7天 (11/24→12/01)', () {
      final submittedDate = LearningDate.parse('2026-11-24');

      final newDue = Scheduler.calculateNextDue(
        currentK: KLevel.k1,
        result: ReviewResult.know,
        submittedDate: submittedDate,
      );

      final newK = Scheduler.calculateNextK(
        currentK: KLevel.k1,
        result: ReviewResult.know,
      );

      expect(newK, KLevel.k2);
      expect(newDue?.value, '2026-12-01'); // 24+7
    });

    test('k2会了→k3, +14天 (12/01→12/15)', () {
      final submittedDate = LearningDate.parse('2026-12-01');

      final newDue = Scheduler.calculateNextDue(
        currentK: KLevel.k2,
        result: ReviewResult.know,
        submittedDate: submittedDate,
      );

      final newK = Scheduler.calculateNextK(
        currentK: KLevel.k2,
        result: ReviewResult.know,
      );

      expect(newK, KLevel.k3);
      expect(newDue?.value, '2026-12-15'); // 1+14
    });

    test('k3会了→k4, due清空（已掌握）', () {
      final submittedDate = LearningDate.parse('2026-12-15');

      final newDue = Scheduler.calculateNextDue(
        currentK: KLevel.k3,
        result: ReviewResult.know,
        submittedDate: submittedDate,
      );

      final newK = Scheduler.calculateNextK(
        currentK: KLevel.k3,
        result: ReviewResult.know,
      );

      expect(newK, KLevel.k4);
      expect(newDue, isNull); // 清空due
    });

    test('完整周期：11/20保存→11/21→11/24→12/01→12/15，k4达标', () {
      // 11/20 保存
      final formalizedDate = LearningDate.parse('2026-11-20');
      var cycle = ReviewCycle.initial(
        questionId: 'q1',
        formalizedDate: formalizedDate,
      );
      expect(cycle.kLevel, KLevel.k0);
      expect(cycle.dueDate?.value, '2026-11-21');

      // 11/21 会了
      var newK = Scheduler.calculateNextK(currentK: cycle.kLevel, result: ReviewResult.know);
      var newDue = Scheduler.calculateNextDue(
        currentK: cycle.kLevel,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-21'),
      );
      cycle = cycle.copyWith(kLevel: newK, dueDate: newDue);
      expect(cycle.kLevel, KLevel.k1);
      expect(cycle.dueDate?.value, '2026-11-24');

      // 11/24 会了
      newK = Scheduler.calculateNextK(currentK: cycle.kLevel, result: ReviewResult.know);
      newDue = Scheduler.calculateNextDue(
        currentK: cycle.kLevel,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-24'),
      );
      cycle = cycle.copyWith(kLevel: newK, dueDate: newDue);
      expect(cycle.kLevel, KLevel.k2);
      expect(cycle.dueDate?.value, '2026-12-01');

      // 12/01 会了
      newK = Scheduler.calculateNextK(currentK: cycle.kLevel, result: ReviewResult.know);
      newDue = Scheduler.calculateNextDue(
        currentK: cycle.kLevel,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-12-01'),
      );
      cycle = cycle.copyWith(kLevel: newK, dueDate: newDue);
      expect(cycle.kLevel, KLevel.k3);
      expect(cycle.dueDate?.value, '2026-12-15');

      // 12/15 会了 → k4
      newK = Scheduler.calculateNextK(currentK: cycle.kLevel, result: ReviewResult.know);
      newDue = Scheduler.calculateNextDue(
        currentK: cycle.kLevel,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-12-15'),
      );
      cycle = cycle.copyWith(kLevel: newK, dueDate: newDue, clearDue: newDue == null);
      expect(cycle.kLevel, KLevel.k4);
      expect(cycle.dueDate, isNull);
    });
  });

  group('Scheduler - AC05: 模糊与不会', () {
    test('k2模糊→k保持2, +1天', () {
      // Given: k2
      final submittedDate = LearningDate.parse('2026-11-25');

      // When: 模糊
      final newK = Scheduler.calculateNextK(
        currentK: KLevel.k2,
        result: ReviewResult.fuzzy,
      );

      final newDue = Scheduler.calculateNextDue(
        currentK: KLevel.k2,
        result: ReviewResult.fuzzy,
        submittedDate: submittedDate,
      );

      // Then: k保持, +1天
      expect(newK, KLevel.k2);
      expect(newDue?.value, '2026-11-26');
    });

    test('k2不会→k归0, +1天', () {
      final submittedDate = LearningDate.parse('2026-11-26');

      final newK = Scheduler.calculateNextK(
        currentK: KLevel.k2,
        result: ReviewResult.notKnow,
      );

      final newDue = Scheduler.calculateNextDue(
        currentK: KLevel.k2,
        result: ReviewResult.notKnow,
        submittedDate: submittedDate,
      );

      expect(newK, KLevel.k0); // 清零
      expect(newDue?.value, '2026-11-27');
    });

    test('k2模糊→k2, 再不会→k0（周期不变）', () {
      var cycle = ReviewCycle(
        questionId: 'q1',
        cycleNumber: 1,
        kLevel: KLevel.k2,
        dueDate: LearningDate.parse('2026-11-25'),
        isActive: true,
        version: 1,
      );

      // 11/25 模糊
      var newK = Scheduler.calculateNextK(currentK: cycle.kLevel, result: ReviewResult.fuzzy);
      var newDue = Scheduler.calculateNextDue(
        currentK: cycle.kLevel,
        result: ReviewResult.fuzzy,
        submittedDate: LearningDate.parse('2026-11-25'),
      );
      cycle = cycle.copyWith(kLevel: newK, dueDate: newDue, version: cycle.version + 1);
      expect(cycle.kLevel, KLevel.k2);
      expect(cycle.dueDate?.value, '2026-11-26');
      expect(cycle.cycleNumber, 1); // 周期不变

      // 11/26 不会
      newK = Scheduler.calculateNextK(currentK: cycle.kLevel, result: ReviewResult.notKnow);
      newDue = Scheduler.calculateNextDue(
        currentK: cycle.kLevel,
        result: ReviewResult.notKnow,
        submittedDate: LearningDate.parse('2026-11-26'),
      );
      cycle = cycle.copyWith(kLevel: newK, dueDate: newDue, version: cycle.version + 1);
      expect(cycle.kLevel, KLevel.k0);
      expect(cycle.dueDate?.value, '2026-11-27');
      expect(cycle.cycleNumber, 1); // 周期仍不变（不是再错）
    });
  });

  group('Scheduler - AC06: 迟做按实际提交日', () {
    test('due=11/20, 实际11/21提交，从11/21计算', () {
      // Given: due='2026-11-20', 但实际'2026-11-21'才提交
      final submittedDate = LearningDate.parse('2026-11-21');

      // When: k0会了
      final newDue = Scheduler.calculateNextDue(
        currentK: KLevel.k0,
        result: ReviewResult.know,
        submittedDate: submittedDate,
      );

      // Then: 从11/21计算，不是从due的11/20
      expect(newDue?.value, '2026-11-24'); // 21+3
    });

    test('逾期多日后提交，从实际日计算', () {
      // due='2026-11-15', 实际'2026-11-25'才提交（逾期10天）
      final submittedDate = LearningDate.parse('2026-11-25');

      final newDue = Scheduler.calculateNextDue(
        currentK: KLevel.k0,
        result: ReviewResult.know,
        submittedDate: submittedDate,
      );

      expect(newDue?.value, '2026-11-28'); // 25+3，不是15+3
    });
  });

  group('Scheduler - 再次出错', () {
    test('再次出错创建新周期k0, due=明日', () {
      // Given: 旧周期k3
      final oldCycle = ReviewCycle(
        questionId: 'q1',
        cycleNumber: 1,
        kLevel: KLevel.k3,
        dueDate: LearningDate.parse('2026-12-01'),
        isActive: true,
        version: 5,
      );

      final operationDate = LearningDate.parse('2026-11-20');

      // When: 再次出错
      final newCycle = Scheduler.createNewCycleForMistakeAgain(
        questionId: oldCycle.questionId,
        previousCycleNumber: oldCycle.cycleNumber,
        operationDate: operationDate,
      );

      // Then: 新周期k0, due=明日
      expect(newCycle.questionId, 'q1');
      expect(newCycle.cycleNumber, 2); // 递增
      expect(newCycle.kLevel, KLevel.k0);
      expect(newCycle.dueDate?.value, '2026-11-21'); // 明日
      expect(newCycle.isActive, true);
      expect(newCycle.version, 1); // 新周期
    });
  });
}
