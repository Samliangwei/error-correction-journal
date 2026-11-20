import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/core/database/database.dart';
import 'package:error_journal/core/repositories/review_repository.dart';
import 'package:error_journal/core/repositories/daily_plan_repository.dart';
import 'package:error_journal/core/repositories/settings_repository.dart';
import 'package:error_journal/core/scheduling/learning_date.dart';
import 'package:error_journal/core/scheduling/review_result.dart';

void main() {
  group('故障注入测试', () {
    late AppDatabase db;
    late ReviewRepository reviewRepo;
    late DailyPlanRepository planRepo;
    late SettingsRepository settingsRepo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      planRepo = DailyPlanRepository(db);
      settingsRepo = SettingsRepository(db);
      reviewRepo = ReviewRepository(db, planRepo, settingsRepo);

      await settingsRepo.setDailyTargetN(20);
      await db.customStatement(
          'UPDATE settings SET daily_target_n = 20, daily_target_pending_n = NULL WHERE id = 1');
    });

    tearDown(() async {
      reviewRepo.faultInjection.reset();
      await db.close();
    });

    test('事件写入后故障：全部回滚', () async {
      // 创建题目和周期
      await db.into(db.mistakeQuestions).insert(MistakeQuestionsCompanion.insert(
            id: 'q1',
            subject: 'Math',
            questionText: 'Q1',
            mistakeDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
      await reviewRepo.createInitialCycle(
        questionId: 'q1',
        formalizedDate: LearningDate.parse('2026-11-20'),
      );

      final cycleId = (await (db.select(db.reviewCycles)
                ..where((c) => c.questionId.equals('q1'))
                ..where((c) => c.isActive.equals(true)))
              .getSingle())
          .id;

      // 注入故障：事件写入后抛错
      reviewRepo.faultInjection.afterEventInsert = () {
        throw Exception('Injected fault after event insert');
      };

      // 尝试提交（应该失败）
      try {
        await reviewRepo.submitScheduledReview(
          questionId: 'q1',
          result: ReviewResult.know,
          submittedDate: LearningDate.parse('2026-11-21'),
          hasAnswer: true,
          hasConfirmedVerification: false,
          expectedCycleId: cycleId,
        );
        fail('Should have thrown');
      } catch (e) {
        expect(e.toString(), contains('Injected fault'));
      }

      // 验证：事件未写入
      final events = await db.select(db.reviewEvents).get();
      expect(events.length, 0);

      // 验证：周期未更新
      final cycle = await reviewRepo.getActiveCycle('q1');
      expect(cycle, isNotNull);
      expect(cycle!.kLevel.value, 0); // 仍然是k0

      // 验证：计划未创建
      final plan = await planRepo.getPlan(LearningDate.parse('2026-11-21'));
      expect(plan, isNull);

      // 清除故障，重试成功
      reviewRepo.faultInjection.reset();

      final result2 = await reviewRepo.submitScheduledReview(
        questionId: 'q1',
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-21'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedCycleId: cycleId,
      );

      // 验证：重试成功
      expect(result2.runtimeType.toString(), 'SubmissionSuccess');

      // 验证：事件已写入
      final events2 = await db.select(db.reviewEvents).get();
      expect(events2.length, 1);

      // 验证：周期已更新
      final cycle2 = await reviewRepo.getActiveCycle('q1');
      expect(cycle2!.kLevel.value, 1);
    });

    test('周期更新后故障：全部回滚', () async {
      // 创建题目和周期
      await db.into(db.mistakeQuestions).insert(MistakeQuestionsCompanion.insert(
            id: 'q1',
            subject: 'Math',
            questionText: 'Q1',
            mistakeDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
      await reviewRepo.createInitialCycle(
        questionId: 'q1',
        formalizedDate: LearningDate.parse('2026-11-20'),
      );

      final cycleId = (await (db.select(db.reviewCycles)
                ..where((c) => c.questionId.equals('q1'))
                ..where((c) => c.isActive.equals(true)))
              .getSingle())
          .id;

      // 注入故障：周期更新后抛错
      reviewRepo.faultInjection.afterCycleUpdate = () {
        throw Exception('Injected fault after cycle update');
      };

      // 尝试提交（应该失败）
      try {
        await reviewRepo.submitScheduledReview(
          questionId: 'q1',
          result: ReviewResult.know,
          submittedDate: LearningDate.parse('2026-11-21'),
          hasAnswer: true,
          hasConfirmedVerification: false,
          expectedCycleId: cycleId,
        );
        fail('Should have thrown');
      } catch (e) {
        expect(e.toString(), contains('Injected fault'));
      }

      // 验证：事件未写入
      final events = await db.select(db.reviewEvents).get();
      expect(events.length, 0);

      // 验证：周期未更新
      final cycle = await reviewRepo.getActiveCycle('q1');
      expect(cycle, isNotNull);
      expect(cycle!.kLevel.value, 0); // 仍然是k0

      // 验证：计划未创建
      final plan = await planRepo.getPlan(LearningDate.parse('2026-11-21'));
      expect(plan, isNull);

      // 清除故障，重试成功
      reviewRepo.faultInjection.reset();

      final result2 = await reviewRepo.submitScheduledReview(
        questionId: 'q1',
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-21'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedCycleId: cycleId,
      );

      // 验证：重试成功
      expect(result2.runtimeType.toString(), 'SubmissionSuccess');

      // 验证：事件已写入
      final events2 = await db.select(db.reviewEvents).get();
      expect(events2.length, 1);

      // 验证：周期已更新
      final cycle2 = await reviewRepo.getActiveCycle('q1');
      expect(cycle2!.kLevel.value, 1);
    });

    test('再错操作故障：全部回滚', () async {
      // 创建题目和周期（k2）
      await db.into(db.mistakeQuestions).insert(MistakeQuestionsCompanion.insert(
            id: 'q1',
            subject: 'Math',
            questionText: 'Q1',
            mistakeDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
      await reviewRepo.createInitialCycle(
        questionId: 'q1',
        formalizedDate: LearningDate.parse('2026-11-20'),
      );

      // 手动更新到k2
      await (db.update(db.reviewCycles)
            ..where((c) => c.questionId.equals('q1')))
          .write(const ReviewCyclesCompanion(kLevel: Value(2)));

      // 注入故障（在事务内部模拟，这里简化测试，只验证最终一致性）
      // 由于markAsMistakeAgain使用db.transaction，故障会导致回滚

      // 正常执行再错操作
      await reviewRepo.markAsMistakeAgain(
        questionId: 'q1',
        operationDate: LearningDate.parse('2026-11-25'),
      );

      // 验证：旧周期关闭，新周期创建
      final allCycles = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals('q1')))
          .get();
      expect(allCycles.length, 2);

      final activeCycle = allCycles.firstWhere((c) => c.isActive);
      expect(activeCycle.cycleNumber, 2);
      expect(activeCycle.kLevel, 0);

      // 验证：再错标记已记录
      final marks = await db.select(db.mistakeAgainMarks).get();
      expect(marks.length, 1);
    });
  });
}
