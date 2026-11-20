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
      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
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

      var cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals('q1'))
            ..where((c) => c.isActive.equals(true)))
          .getSingle();
      var question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals('q1')))
          .getSingle();

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
          expectedQuestionVersion: question.version,
          expectedCycleId: cycle.id,
          expectedCycleVersion: cycle.version,
        );
        fail('Should have thrown');
      } catch (e) {
        expect(e.toString(), contains('Injected fault'));
      }

      // 验证：事件未写入
      final events = await db.select(db.reviewEvents).get();
      expect(events.length, 0);

      // 验证：周期未更新
      final cycleCheck = await reviewRepo.getActiveCycle('q1');
      expect(cycleCheck, isNotNull);
      expect(cycleCheck!.kLevel.value, 0); // 仍然是k0

      // 验证：计划未创建
      final plan = await planRepo.getPlan(LearningDate.parse('2026-11-21'));
      expect(plan, isNull);

      // 清除故障，重试成功
      reviewRepo.faultInjection.reset();

      cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals('q1'))
            ..where((c) => c.isActive.equals(true)))
          .getSingle();
      question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals('q1')))
          .getSingle();

      final result2 = await reviewRepo.submitScheduledReview(
        questionId: 'q1',
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-21'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: cycle.id,
        expectedCycleVersion: cycle.version,
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
      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
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

      var cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals('q1'))
            ..where((c) => c.isActive.equals(true)))
          .getSingle();
      var question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals('q1')))
          .getSingle();

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
          expectedQuestionVersion: question.version,
          expectedCycleId: cycle.id,
          expectedCycleVersion: cycle.version,
        );
        fail('Should have thrown');
      } catch (e) {
        expect(e.toString(), contains('Injected fault'));
      }

      // 验证：事件未写入
      final eventsAfterFault = await db.select(db.reviewEvents).get();
      expect(eventsAfterFault.length, 0);

      // 验证：周期未更新
      final cycleAfterFault = await reviewRepo.getActiveCycle('q1');
      expect(cycleAfterFault, isNotNull);
      expect(cycleAfterFault!.kLevel.value, 0); // 仍然是k0

      // 验证：计划未创建
      final planAfterFault =
          await planRepo.getPlan(LearningDate.parse('2026-11-21'));
      expect(planAfterFault, isNull);

      // 清除故障，重试成功
      reviewRepo.faultInjection.reset();

      cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals('q1'))
            ..where((c) => c.isActive.equals(true)))
          .getSingle();
      question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals('q1')))
          .getSingle();

      final result2Again = await reviewRepo.submitScheduledReview(
        questionId: 'q1',
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-21'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: cycle.id,
        expectedCycleVersion: cycle.version,
      );

      // 验证：重试成功
      expect(result2Again.runtimeType.toString(), 'SubmissionSuccess');

      // 验证：事件已写入
      final events2After = await db.select(db.reviewEvents).get();
      expect(events2After.length, 1);

      // 验证：周期已更新
      final cycle2After = await reviewRepo.getActiveCycle('q1');
      expect(cycle2After!.kLevel.value, 1);
    });

    test('再错操作故障：全部回滚', () async {
      // 创建题目和周期（k2）
      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
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

      // 记录故障前状态
      final cyclesBeforeFault = await db.select(db.reviewCycles).get();
      final marksBeforeFault = await db.select(db.mistakeAgainMarks).get();
      expect(cyclesBeforeFault.length, 1);
      expect(marksBeforeFault.length, 0);

      // 注入故障：再错标记插入后抛错
      reviewRepo.faultInjection.afterMistakeAgainInsert = () {
        throw Exception('Injected fault after mistake again mark insert');
      };

      // 尝试执行再错操作（应该失败）
      try {
        await reviewRepo.markAsMistakeAgain(
          questionId: 'q1',
          operationDate: LearningDate.parse('2026-11-25'),
        );
        fail('Should have thrown');
      } catch (e) {
        expect(e.toString(), contains('Injected fault'));
      }

      // 验证：全部回滚，状态不变
      final cyclesAfterFault = await db.select(db.reviewCycles).get();
      final marksAfterFault = await db.select(db.mistakeAgainMarks).get();
      expect(cyclesAfterFault.length, 1, reason: '周期数应保持1个');
      expect(cyclesAfterFault.first.isActive, true, reason: '旧周期应仍然活跃');
      expect(cyclesAfterFault.first.cycleNumber, 1, reason: '周期号应保持1');
      expect(marksAfterFault.length, 0, reason: '再错标记应未写入');

      // 清除故障，重试成功
      reviewRepo.faultInjection.reset();

      await reviewRepo.markAsMistakeAgain(
        questionId: 'q1',
        operationDate: LearningDate.parse('2026-11-25'),
      );

      // 验证：重试成功
      final allCycles = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals('q1')))
          .get();
      expect(allCycles.length, 2, reason: '应有2个周期');

      final activeCycle = allCycles.firstWhere((c) => c.isActive);
      expect(activeCycle.cycleNumber, 2, reason: '新周期号应为2');
      expect(activeCycle.kLevel, 0, reason: '新周期应重置为k0');

      final marks = await db.select(db.mistakeAgainMarks).get();
      expect(marks.length, 1, reason: '应有1个再错标记');
    });
  });
}
