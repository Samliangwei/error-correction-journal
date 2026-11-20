import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/core/database/database.dart';
import 'package:error_journal/core/repositories/review_repository.dart';
import 'package:error_journal/core/repositories/daily_plan_repository.dart';
import 'package:error_journal/core/repositories/settings_repository.dart';
import 'package:error_journal/core/scheduling/learning_date.dart';
import 'package:error_journal/core/scheduling/review_result.dart';
import 'package:error_journal/core/scheduling/review_submission.dart';

void main() {
  group('集成测试 - 容量与事务', () {
    late AppDatabase db;
    late ReviewRepository repo;
    late DailyPlanRepository planRepo;
    late SettingsRepository settingsRepo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      planRepo = DailyPlanRepository(db);
      settingsRepo = SettingsRepository(db);
      repo = ReviewRepository(db, planRepo, settingsRepo);
    });

    tearDown(() async {
      await db.close();
    });

    test('旧卡新日：有容量则纳入计划', () async {
      const questionId = 'q1';
      await repo.createInitialCycle(
        questionId: questionId,
        formalizedDate: LearningDate.parse('2026-11-20'),
      );

      // 获取cycleId
      final cycleId = (await (db.select(db.reviewCycles)
                ..where((c) => c.questionId.equals(questionId)))
              .getSingle())
          .id;

      // 次日提交
      final result = await repo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-21'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedCycleId: cycleId,
      );

      // 成功
      expect(result, isA<SubmissionSuccess>());

      // 已加入计划
      final plan = await planRepo.getPlan(LearningDate.parse('2026-11-21'));
      expect(plan, isNotNull);
      expect(plan!.members.length, 1);
      expect(plan.members[0].questionId, questionId);
      expect(plan.members[0].isCompleted, true);
    });

    test('旧卡新日：满额返回需确认，取消零写', () async {
      // 设置容量为5（最小值）
      await settingsRepo.setDailyTargetN(5);

      // 创建6个候选题（5个填满+1个满额测试）
      for (int i = 0; i < 6; i++) {
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
        await repo.createInitialCycle(
          questionId: 'q$i',
          formalizedDate: LearningDate.parse('2026-11-20'),
        );
      }

      // 前5个填满计划
      for (int i = 0; i < 5; i++) {
        final cycleId = (await (db.select(db.reviewCycles)
                  ..where((c) => c.questionId.equals('q$i')))
                .getSingle())
            .id;
        await repo.submitScheduledReview(
          questionId: 'q$i',
          result: ReviewResult.know,
          submittedDate: LearningDate.parse('2026-11-21'),
          hasAnswer: true,
          hasConfirmedVerification: false,
          expectedCycleId: cycleId,
        );
      }

      // 第6个题目（q5），满额
      final cycle5Id = (await (db.select(db.reviewCycles)
                ..where((c) => c.questionId.equals('q5')))
              .getSingle())
          .id;

      // 未确认提交，返回满额
      final result1 = await repo.submitScheduledReview(
        questionId: 'q5',
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-21'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        capacityConfirmed: false,
        expectedCycleId: cycle5Id,
      );

      // 验证：返回满额
      expect(result1, isA<SubmissionCapacityFull>());
      final capacityFull = result1 as SubmissionCapacityFull;
      expect(capacityFull.currentCount, 5);
      expect(capacityFull.capacityC, 5);

      // 验证：零写（事件、周期、计划均未变）
      final events = await db.select(db.reviewEvents).get();
      expect(events.where((e) => e.questionId == 'q5').length, 0);

      final cycle5 = await repo.getActiveCycle('q5');
      expect(cycle5!.kLevel.value, 0); // 未变
      expect(cycle5.version, 1); // 版本未递增

      final plan = await planRepo.getPlan(LearningDate.parse('2026-11-21'));
      expect(plan!.members.length, 5); // 未增加，包含q0-q4
    });

    test('旧卡新日：满额但确认后提交成功', () async {
      await settingsRepo.setDailyTargetN(5);

      // 创建6个候选题
      for (int i = 0; i < 6; i++) {
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
        await repo.createInitialCycle(
          questionId: 'q$i',
          formalizedDate: LearningDate.parse('2026-11-20'),
        );
      }

      // 前5个填满
      for (int i = 0; i < 5; i++) {
        final cycleId = (await (db.select(db.reviewCycles)
                  ..where((c) => c.questionId.equals('q$i')))
                .getSingle())
            .id;
        await repo.submitScheduledReview(
          questionId: 'q$i',
          result: ReviewResult.know,
          submittedDate: LearningDate.parse('2026-11-21'),
          hasAnswer: true,
          hasConfirmedVerification: false,
          expectedCycleId: cycleId,
        );
      }

      // 第6个确认后提交
      final cycle5Id = (await (db.select(db.reviewCycles)
                ..where((c) => c.questionId.equals('q5')))
              .getSingle())
          .id;
      final result = await repo.submitScheduledReview(
        questionId: 'q5',
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-21'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        capacityConfirmed: true,
        expectedCycleId: cycle5Id,
      );

      // 成功（确认扩容）
      expect(result, isA<SubmissionSuccess>());

      final plan = await planRepo.getPlan(LearningDate.parse('2026-11-21'));
      expect(plan!.members.length, 6); // 已扩容
      expect(plan.capacityC, 6); // 问题1已修复：C应扩容
    });

    test('N次日生效', () async {
      // 今日设置N=10
      await settingsRepo.setDailyTargetN(10);
      final model = await settingsRepo.getSettingsModel();
      expect(model.hasPendingChange, true);

      // 今日计划仍用旧N（20）
      final todayPlan = await planRepo.getOrCreatePlan(
        date: LearningDate.parse('2026-11-20'),
        targetN: 20, // 调用方传入旧N
      );
      expect(todayPlan.targetN, 20);
      expect(todayPlan.capacityC, 20);

      // 次日使用新N（10）
      final tomorrowPlan = await planRepo.getOrCreatePlan(
        date: LearningDate.parse('2026-11-21'),
        targetN: 10, // 调用方传入新N
      );
      expect(tomorrowPlan.targetN, 10);
      expect(tomorrowPlan.capacityC, 10);
    });

    test('再错已完成：保留今日事件和完成身份', () async {
      const questionId = 'q1';
      await repo.createInitialCycle(
        questionId: questionId,
        formalizedDate: LearningDate.parse('2026-11-20'),
      );

      // 今日完成复习
      final cycleId1 = (await (db.select(db.reviewCycles)
                ..where((c) => c.questionId.equals(questionId)))
              .getSingle())
          .id;
      await repo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-21'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedCycleId: cycleId1,
      );

      // 今日再错（触发新周期）
      await repo.markAsMistakeAgain(
        questionId: questionId,
        operationDate: LearningDate.parse('2026-11-21'),
      );

      // 获取新周期ID
      final newCycleId = (await (db.select(db.reviewCycles)
                ..where((c) => c.questionId.equals(questionId)))
              .getSingle())
          .id;

      // 再次提交（用新周期）
      final result = await repo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-21'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedCycleId: newCycleId,
      );

      // 返回幂等（今日已有事件）
      expect(result, isA<SubmissionDuplicate>());
    });

    test('再错未完成：退出计划并补位', () async {
      const questionId = 'q1';
      await repo.createInitialCycle(
        questionId: questionId,
        formalizedDate: LearningDate.parse('2026-11-20'),
      );

      // 加入计划但未完成
      final plan = await planRepo.getOrCreatePlan(
        date: LearningDate.parse('2026-11-21'),
        targetN: 20,
      );
      await planRepo.addMember(
          planId: plan.id, questionId: questionId, orderIndex: 0);

      // 再次出错
      await repo.markAsMistakeAgain(
        questionId: questionId,
        operationDate: LearningDate.parse('2026-11-21'),
      );

      // 验证：已移出计划
      final updatedPlan =
          await planRepo.getPlan(LearningDate.parse('2026-11-21'));
      expect(updatedPlan!.members.length, 0);
    });
  });
}
