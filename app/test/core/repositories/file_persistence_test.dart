import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/core/database/database.dart';
import 'package:error_journal/core/repositories/review_repository.dart';
import 'package:error_journal/core/repositories/daily_plan_repository.dart';
import 'package:error_journal/core/repositories/settings_repository.dart';
import 'package:error_journal/core/scheduling/learning_date.dart';
import 'package:error_journal/core/scheduling/review_result.dart';

void main() {
  group('文件持久化测试', () {
    late String tempPath;

    setUp(() {
      // 创建临时文件路径
      tempPath = '${Directory.systemTemp.path}/test_db_${DateTime.now().millisecondsSinceEpoch}.sqlite';
    });

    tearDown(() {
      // 清理文件
      final file = File(tempPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }););

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

        // 提交复习
        await reviewRepo.submitScheduledReview(
          questionId: 'q1',
          result: ReviewResult.know,
          submittedDate: LearningDate.parse('2026-11-21'),
          hasAnswer: true,
          hasConfirmedVerification: false,
          expectedCycleId: cycleId,
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

        // 验证：计划持久化
        final plan = await planRepo.getPlan(LearningDate.parse('2026-11-21'));
        expect(plan, isNotNull);
        expect(plan!.members.length, 1);
        expect(plan.members.first.questionId, 'q1');
        expect(plan.members.first.isCompleted, true); // 已完成

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

        await reviewRepo.submitScheduledReview(
          questionId: 'q1',
          result: ReviewResult.know,
          submittedDate: LearningDate.parse('2026-11-21'),
          hasAnswer: true,
          hasConfirmedVerification: false,
          expectedCycleId: cycleId,
        );

        await db.close();
      }

      // === 第二次打开：重复提交（幂等） ===
      {
        final db = AppDatabase.forTesting(NativeDatabase(File(tempPath)));
        final planRepo = DailyPlanRepository(db);
        final settingsRepo = SettingsRepository(db);
        final reviewRepo = ReviewRepository(db, planRepo, settingsRepo);

        final cycleId = (await (db.select(db.reviewCycles)
                  ..where((c) => c.questionId.equals('q1'))
                  ..where((c) => c.isActive.equals(true)))
                .getSingle())
            .id;

        // 重复提交同题同日
        final result2 = await reviewRepo.submitScheduledReview(
          questionId: 'q1',
          result: ReviewResult.fuzzy, // 不同结果
          submittedDate: LearningDate.parse('2026-11-21'),
          hasAnswer: true,
          hasConfirmedVerification: false,
          expectedCycleId: cycleId,
        );

        // 验证：幂等拒绝
        expect(result2.runtimeType.toString(), 'SubmissionDuplicate');

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
  });
}
