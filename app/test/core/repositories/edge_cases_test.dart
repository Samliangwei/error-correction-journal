import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/core/database/database.dart';
import 'package:error_journal/core/repositories/mistake_question_repository.dart';
import 'package:error_journal/core/repositories/review_repository.dart';
import 'package:error_journal/core/repositories/daily_plan_repository.dart';
import 'package:error_journal/core/repositories/settings_repository.dart';
import 'package:error_journal/core/scheduling/learning_date.dart';
import 'package:error_journal/core/scheduling/review_result.dart';
import 'package:error_journal/core/scheduling/review_submission.dart';

void main() {
  group('边界场景', () {
    late AppDatabase db;
    late MistakeQuestionRepository questionRepo;
    late ReviewRepository reviewRepo;
    late DailyPlanRepository planRepo;
    late SettingsRepository settingsRepo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      planRepo = DailyPlanRepository(db);
      settingsRepo = SettingsRepository(db);
      reviewRepo = ReviewRepository(db, planRepo, settingsRepo);
      questionRepo =
          MistakeQuestionRepository(db, planRepo, reviewRepo, settingsRepo);
    });

    tearDown(() async {
      await db.close();
    });

    test('N当日多次改动，次日首次生效', () async {
      // 创建今日计划（使用默认N=20）
      final todayDate = LearningDate.parse('2026-11-20');
      await questionRepo.ensurePlanFilled(date: todayDate);

      final todayPlan1 = await planRepo.getPlan(todayDate);
      expect(todayPlan1!.targetN, 20);
      expect(todayPlan1.capacityC, 20);

      // 当日多次改N
      await settingsRepo.setDailyTargetN(10);
      await settingsRepo.setDailyTargetN(15);
      await settingsRepo.setDailyTargetN(8);

      // 今日计划不变
      final todayPlan2 = await planRepo.getPlan(todayDate);
      expect(todayPlan2!.targetN, 20); // 仍是创建时的N
      expect(todayPlan2.capacityC, 20);

      // 次日使用最终N
      final tomorrowDate = LearningDate.parse('2026-11-21');
      await questionRepo.ensurePlanFilled(date: tomorrowDate);

      final tomorrowPlan = await planRepo.getPlan(tomorrowDate);
      expect(tomorrowPlan!.targetN, 8); // 使用最终设置
      expect(tomorrowPlan.capacityC, 8);
    });

    test('满额确认必须重读当前状态', () async {
      await settingsRepo.setDailyTargetN(5);

      // 创建5个题填满
      for (int i = 0; i < 5; i++) {
        await db
            .into(db.mistakeQuestions)
            .insert(MistakeQuestionsCompanion.insert(
              id: 'q$i',
              subject: 'Math',
              questionText: 'Q$i',
              mistakeDate: DateTime.now(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));
        await reviewRepo.createInitialCycle(
          questionId: 'q$i',
          formalizedDate: LearningDate.parse('2026-11-19'),
        );
      }

      await questionRepo.ensurePlanFilled(
        date: LearningDate.parse('2026-11-20'),
      );

      // 旧卡q6
      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
            id: 'q6',
            subject: 'Math',
            questionText: 'Q6',
            mistakeDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
      await reviewRepo.createInitialCycle(
        questionId: 'q6',
        formalizedDate: LearningDate.parse('2026-11-19'),
      );

      // 第1次确认
      final q6Cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals('q6')))
          .getSingle();
      final q6Question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals('q6')))
          .getSingle();
      final result1 = await reviewRepo.submitScheduledReview(
        questionId: 'q6',
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: q6Question.version,
        expectedCycleId: q6Cycle.id,
        expectedCycleVersion: q6Cycle.version,
        capacityConfirmed: true,
      );

      expect(result1, isA<SubmissionSuccess>());

      final plan1 = await planRepo.getPlan(LearningDate.parse('2026-11-20'));
      expect(plan1!.members.length, 6);

      // 第2次重复确认（不得再扩C）
      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
            id: 'q7',
            subject: 'Math',
            questionText: 'Q7',
            mistakeDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
      await reviewRepo.createInitialCycle(
        questionId: 'q7',
        formalizedDate: LearningDate.parse('2026-11-19'),
      );

      final q7Cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals('q7')))
          .getSingle();
      final q7Question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals('q7')))
          .getSingle();
      final result2 = await reviewRepo.submitScheduledReview(
        questionId: 'q7',
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: q7Question.version,
        expectedCycleId: q7Cycle.id,
        expectedCycleVersion: q7Cycle.version,
        capacityConfirmed: true,
      );

      expect(result2, isA<SubmissionSuccess>());

      final plan2 = await planRepo.getPlan(LearningDate.parse('2026-11-20'));
      expect(plan2!.members.length, 7);
    });

    test('周期已失效：不能提交', () async {
      const questionId = 'q1';
      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
            id: questionId,
            subject: 'Math',
            questionText: 'Q1',
            mistakeDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));

      await reviewRepo.createInitialCycle(
        questionId: questionId,
        formalizedDate: LearningDate.parse('2026-11-19'),
      );

      final cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(questionId)))
          .getSingle();
      final question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .getSingle();

      // 模拟周期已失效（如被再错关闭）
      await db.customStatement(
          'UPDATE review_cycles SET is_active = 0 WHERE question_id = ?',
          [questionId]);

      // 尝试提交（周期已失效）
      try {
        await reviewRepo.submitScheduledReview(
          questionId: questionId,
          result: ReviewResult.fuzzy,
          submittedDate: LearningDate.parse('2026-11-20'),
          hasAnswer: true,
          hasConfirmedVerification: false,
          expectedQuestionVersion: question.version,
          expectedCycleId: cycle.id,
          expectedCycleVersion: cycle.version,
          capacityConfirmed: true,
        );
        fail('Should have thrown StateError');
      } catch (e) {
        expect(e.toString(), contains('No active cycle'));
      }

      // 验证：零写（无事件）
      final events = await db.select(db.reviewEvents).get();
      expect(events.where((e) => e.questionId == questionId).length, 0);
    });

    test('旧卡同日再错：零写', () async {
      const questionId = 'q1';
      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
            id: questionId,
            subject: 'Math',
            questionText: 'Q1',
            mistakeDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));

      await reviewRepo.createInitialCycle(
        questionId: questionId,
        formalizedDate: LearningDate.parse('2026-11-19'),
      );

      // 获取第一个周期（在再错之前）
      final firstCycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(questionId))
            ..where((c) => c.isActive.equals(true)))
          .getSingle();
      final question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .getSingle();

      // 今日再错（会创建新周期）
      await questionRepo.markAsMistakeAgainWithBackfill(
        questionId: questionId,
        operationDate: LearningDate.parse('2026-11-20'),
      );

      // 尝试用旧周期ID提交（应该被拒绝）
      final result = await reviewRepo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: firstCycle.id, // 旧周期ID
        expectedCycleVersion: firstCycle.version,
        capacityConfirmed: true,
      );

      // 验证：旧周期被拒绝（版本检查优先于再错检查）
      expect(result, isA<SubmissionStaleCycle>());

      // 验证：零写（未创建事件）
      final events = await db.select(db.reviewEvents).get();
      final todayEvents = events
          .where((e) =>
              e.questionId == questionId && e.learningDate == '2026-11-20')
          .toList();
      expect(todayEvents.length, 0);
    });
  });
}
