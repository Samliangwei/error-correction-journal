import 'dart:io';
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
  group('文件持久化测试', () {
    late String tempPath;

    setUp(() {
      // 创建临时文件路径
      tempPath =
          '${Directory.systemTemp.path}/test_db_${DateTime.now().millisecondsSinceEpoch}.sqlite';
    });

    tearDown(() {
      // 清理文件
      final file = File(tempPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    test('关闭重开：完整状态持久化', () async {
      // === 第一次打开数据库：写入数据 ===
      {
        final db = AppDatabase.forTesting(NativeDatabase(File(tempPath)));
        final planRepo = DailyPlanRepository(db);
        final settingsRepo = SettingsRepository(db);
        final reviewRepo = ReviewRepository(db, planRepo, settingsRepo);

        // 设置N=5
        await settingsRepo.setDailyTargetN(5);
        await db.customStatement(
            'UPDATE settings SET daily_target_n = 5, daily_target_pending_n = NULL WHERE id = 1');

        // 创建题目和周期
        await db.into(db.mistakeQuestions).insert(
            MistakeQuestionsCompanion.insert(
                id: 'q1',
                subject: 'Math',
                questionText: 'Q1',
                mistakeDate: DateTime.now(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now()));
        await reviewRepo.createInitialCycle(
          questionId: 'q1',
          formalizedDate: LearningDate.parse('2026-11-20'),
        );

        final cycle = await (db.select(db.reviewCycles)
              ..where((c) => c.questionId.equals('q1'))
              ..where((c) => c.isActive.equals(true)))
            .getSingle();
        final question = await (db.select(db.mistakeQuestions)
              ..where((q) => q.id.equals('q1')))
            .getSingle();

        // 提交复习
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

        // 再错标记
        await reviewRepo.markAsMistakeAgain(
          questionId: 'q1',
          operationDate: LearningDate.parse('2026-11-25'),
        );

        // 关闭数据库
        await db.close();
      }

      // === 第二次打开数据库：验证持久化 ===
      {
        final db = AppDatabase.forTesting(NativeDatabase(File(tempPath)));
        final planRepo = DailyPlanRepository(db);
        final settingsRepo = SettingsRepository(db);
        final reviewRepo = ReviewRepository(db, planRepo, settingsRepo);

        // 验证：设置持久化
        final n = await settingsRepo.getDailyTargetN();
        expect(n, 5);

        // 验证：题目持久化
        final questions = await db.select(db.mistakeQuestions).get();
        expect(questions.length, 1);
        expect(questions.first.id, 'q1');

        // 验证：周期持久化（k0，新周期）
        final cycles = await db.select(db.reviewCycles).get();
        expect(cycles.length, 2); // 旧周期（关闭） + 新周期（活跃）

        final activeCycle = await reviewRepo.getActiveCycle('q1');
        expect(activeCycle, isNotNull);
        expect(activeCycle!.cycleNumber, 2); // 再错后的新周期
        expect(activeCycle.kLevel.value, 0); // k0

        // 验证：事件持久化
        final events = await db.select(db.reviewEvents).get();
        expect(events.length, 1);
        expect(events.first.questionId, 'q1');
        expect(events.first.result, 'know');

        // 验证：再错标记持久化
        final marks = await db.select(db.mistakeAgainMarks).get();
        expect(marks.length, 1);
        expect(marks.first.questionId, 'q1');

        // 验证：计划持久化(验证id/targetN/C/member顺序/skip)
        final plan = await planRepo.getPlan(LearningDate.parse('2026-11-21'));
        expect(plan, isNotNull);
        expect(plan!.id, isNotEmpty, reason: 'plan.id应持久化');
        expect(plan.targetN, 5, reason: 'targetN应持久化');
        expect(plan.capacityC, 5, reason: 'capacityC应持久化');
        expect(plan.members.length, 1);
        expect(plan.members.first.questionId, 'q1');
        expect(plan.members.first.orderIndex, greaterThanOrEqualTo(0),
            reason: 'orderIndex应持久化');
        expect(plan.members.first.isCompleted, true, reason: '应已完成');
        expect(plan.members.first.isSkipped, false, reason: 'skip应持久化');

        // 验证：settings的pending字段持久化
        final settings = await db.select(db.settings).getSingle();
        expect(settings.dailyTargetPendingN, null,
            reason: 'pendingN应持久化为null');
        expect(settings.dailyTargetEffectiveFrom, null,
            reason: 'effectiveFrom应持久化为null');

        // 关闭数据库
        await db.close();
      }
    });

    test('关闭重开：幂等性跨重启保持', () async {
      // === 第一次打开：提交一次 ===
      {
        final db = AppDatabase.forTesting(NativeDatabase(File(tempPath)));
        final planRepo = DailyPlanRepository(db);
        final settingsRepo = SettingsRepository(db);
        final reviewRepo = ReviewRepository(db, planRepo, settingsRepo);

        await settingsRepo.setDailyTargetN(5);
        await db.customStatement(
            'UPDATE settings SET daily_target_n = 5, daily_target_pending_n = NULL WHERE id = 1');

        await db.into(db.mistakeQuestions).insert(
            MistakeQuestionsCompanion.insert(
                id: 'q1',
                subject: 'Math',
                questionText: 'Q1',
                mistakeDate: DateTime.now(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now()));
        await reviewRepo.createInitialCycle(
          questionId: 'q1',
          formalizedDate: LearningDate.parse('2026-11-20'),
        );

        final cycle = await (db.select(db.reviewCycles)
              ..where((c) => c.questionId.equals('q1'))
              ..where((c) => c.isActive.equals(true)))
            .getSingle();
        final question = await (db.select(db.mistakeQuestions)
              ..where((q) => q.id.equals('q1')))
            .getSingle();

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

        await db.close();
      }

      // === 第二次打开：重复提交（幂等） ===
      {
        final db = AppDatabase.forTesting(NativeDatabase(File(tempPath)));
        final planRepo = DailyPlanRepository(db);
        final settingsRepo = SettingsRepository(db);
        final reviewRepo = ReviewRepository(db, planRepo, settingsRepo);

        final cycle = await (db.select(db.reviewCycles)
              ..where((c) => c.questionId.equals('q1'))
              ..where((c) => c.isActive.equals(true)))
            .getSingle();
        final question = await (db.select(db.mistakeQuestions)
              ..where((q) => q.id.equals('q1')))
            .getSingle();

        // 重复提交同题同日
        final result2 = await reviewRepo.submitScheduledReview(
          questionId: 'q1',
          result: ReviewResult.fuzzy, // 不同结果
          submittedDate: LearningDate.parse('2026-11-21'),
          hasAnswer: true,
          hasConfirmedVerification: false,
          expectedQuestionVersion: question.version,
          expectedCycleId: cycle.id,
          expectedCycleVersion: cycle.version,
        );

        // 验证：幂等拒绝
        expect(result2, isA<SubmissionDuplicate>());

        // 验证：只有一条事件
        final events = await db.select(db.reviewEvents).get();
        expect(events.length, 1);
        expect(events.first.result, 'know'); // 保留首次结果

        await db.close();
      }
    });

    test('关闭重开：再错幂等跨重启保持', () async {
      // === 第一次打开：首次再错 ===
      {
        final db = AppDatabase.forTesting(NativeDatabase(File(tempPath)));
        final planRepo = DailyPlanRepository(db);
        final settingsRepo = SettingsRepository(db);
        final reviewRepo = ReviewRepository(db, planRepo, settingsRepo);

        await settingsRepo.setDailyTargetN(5);
        await db.customStatement(
            'UPDATE settings SET daily_target_n = 5, daily_target_pending_n = NULL WHERE id = 1');

        await db.into(db.mistakeQuestions).insert(
            MistakeQuestionsCompanion.insert(
                id: 'q1',
                subject: 'Math',
                questionText: 'Q1',
                mistakeDate: DateTime.now(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now()));
        await reviewRepo.createInitialCycle(
          questionId: 'q1',
          formalizedDate: LearningDate.parse('2026-11-20'),
        );

        await reviewRepo.markAsMistakeAgain(
          questionId: 'q1',
          operationDate: LearningDate.parse('2026-11-25'),
        );

        await db.close();
      }

      // === 第二次打开：重复再错（幂等） ===
      {
        final db = AppDatabase.forTesting(NativeDatabase(File(tempPath)));
        final planRepo = DailyPlanRepository(db);
        final settingsRepo = SettingsRepository(db);
        final reviewRepo = ReviewRepository(db, planRepo, settingsRepo);

        // 重复再错同日
        await reviewRepo.markAsMistakeAgain(
          questionId: 'q1',
          operationDate: LearningDate.parse('2026-11-25'),
        );

        // 验证：周期号不变（幂等）
        final activeCycle = await reviewRepo.getActiveCycle('q1');
        expect(activeCycle, isNotNull);
        expect(activeCycle!.cycleNumber, 2); // 仍然是周期2

        // 验证：只有一条再错标记
        final marks = await db.select(db.mistakeAgainMarks).get();
        expect(marks.length, 1);

        await db.close();
      }
    });

    test('组合操作跨重启：提交→再错→同日重复提交保留首次', () async {
      String? firstPlanId;
      String? firstEventId;

      // === 第一次打开：提交 ===
      {
        final db = AppDatabase.forTesting(NativeDatabase(File(tempPath)));
        final planRepo = DailyPlanRepository(db);
        final settingsRepo = SettingsRepository(db);
        final reviewRepo = ReviewRepository(db, planRepo, settingsRepo);

        await settingsRepo.setDailyTargetN(10);
        await db.customStatement(
            'UPDATE settings SET daily_target_n = 10, daily_target_pending_n = NULL WHERE id = 1');

        await db.into(db.mistakeQuestions).insert(
            MistakeQuestionsCompanion.insert(
                id: 'q1',
                subject: 'Math',
                questionText: 'Q1',
                mistakeDate: DateTime.now(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now()));
        await reviewRepo.createInitialCycle(
          questionId: 'q1',
          formalizedDate: LearningDate.parse('2026-11-20'),
        );

        var cycle = await (db.select(db.reviewCycles)
              ..where((c) => c.questionId.equals('q1')))
            .getSingle();
        var question = await (db.select(db.mistakeQuestions)
              ..where((q) => q.id.equals('q1')))
            .getSingle();

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

        final plan = await planRepo.getPlan(LearningDate.parse('2026-11-21'));
        firstPlanId = plan!.id;
        final events = await db.select(db.reviewEvents).get();
        firstEventId = events.first.id;

        await db.close();
      }

      // === 第二次打开：再错 ===
      {
        final db = AppDatabase.forTesting(NativeDatabase(File(tempPath)));
        final planRepo = DailyPlanRepository(db);
        final settingsRepo = SettingsRepository(db);
        final reviewRepo = ReviewRepository(db, planRepo, settingsRepo);

        await reviewRepo.markAsMistakeAgain(
          questionId: 'q1',
          operationDate: LearningDate.parse('2026-11-21'),
        );

        await db.close();
      }

      // === 第三次打开：同日重复提交 ===
      {
        final db = AppDatabase.forTesting(NativeDatabase(File(tempPath)));
        final planRepo = DailyPlanRepository(db);
        final settingsRepo = SettingsRepository(db);
        final reviewRepo = ReviewRepository(db, planRepo, settingsRepo);

        final cycle = await (db.select(db.reviewCycles)
              ..where((c) => c.questionId.equals('q1'))
              ..where((c) => c.isActive.equals(true)))
            .getSingle();
        final question = await (db.select(db.mistakeQuestions)
              ..where((q) => q.id.equals('q1')))
            .getSingle();

        final result = await reviewRepo.submitScheduledReview(
          questionId: 'q1',
          result: ReviewResult.fuzzy,
          submittedDate: LearningDate.parse('2026-11-21'),
          hasAnswer: true,
          hasConfirmedVerification: false,
          expectedQuestionVersion: question.version,
          expectedCycleId: cycle.id,
          expectedCycleVersion: cycle.version,
        );

        // 验证：幂等拒绝
        expect(result, isA<SubmissionDuplicate>());

        // 验证：plan.id不变
        final plan = await planRepo.getPlan(LearningDate.parse('2026-11-21'));
        expect(plan!.id, firstPlanId, reason: 'plan.id应保持不变');

        // 验证：首次事件保留，完成身份保留
        final events = await db.select(db.reviewEvents).get();
        expect(events.length, 1, reason: '应只有首次事件');
        expect(events.first.id, firstEventId, reason: 'event.id应保持不变');
        expect(events.first.result, 'know', reason: '应保留首次结果');
        expect(plan.members.first.isCompleted, true,
            reason: '完成身份应保留');

        await db.close();
      }
    });
  });
}
