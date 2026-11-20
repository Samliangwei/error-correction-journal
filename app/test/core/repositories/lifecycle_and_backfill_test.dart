import 'package:drift/drift.dart' hide isNotNull;
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
  group('生命周期与补位', () {
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

      // 创建默认settings（避免多条记录）
      await db.into(db.settings).insert(SettingsCompanion.insert(
            dailyTargetN: const Value(5),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
    });

    tearDown(() async {
      await db.close();
    });

    test('首次创建计划：填满min(C,候选数)并验证内容', () async {
      // setUp已创建N=5的settings

      // 创建8个候选题（超过容量）
      for (int i = 0; i < 8; i++) {
        await db
            .into(db.mistakeQuestions)
            .insert(MistakeQuestionsCompanion.insert(
              id: 'q$i',
              subject: 'Math',
              questionText: 'Question $i',
              mistakeDate: DateTime.now(),
              createdAt: DateTime.now().add(Duration(minutes: i)), // 不同创建时间
              updatedAt: DateTime.now(),
            ));

        await reviewRepo.createInitialCycle(
          questionId: 'q$i',
          formalizedDate: LearningDate.parse('2026-11-19'),
        );
      }

      // 填充计划
      await questionRepo.ensurePlanFilled(
        date: LearningDate.parse('2026-11-20'),
      );

      final plan = await planRepo.getPlan(LearningDate.parse('2026-11-20'));
      expect(plan, isNotNull);
      expect(plan!.members.length, 5); // min(5, 8)

      // 验证内容：按due（全相同）→创建时间排序
      final memberIds = plan.members.map((m) => m.questionId).toList();
      expect(memberIds, ['q0', 'q1', 'q2', 'q3', 'q4']);
    });

    test('归档已完成：保留计划成员', () async {

      // 创建3个题
      for (int i = 0; i < 3; i++) {
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

      // 填充计划
      await questionRepo.ensurePlanFilled(
        date: LearningDate.parse('2026-11-20'),
      );

      // 完成q1
      final q1CycleId = (await (db.select(db.reviewCycles)
                ..where((c) => c.questionId.equals('q1')))
              .getSingle())
          .id;
      await reviewRepo.submitScheduledReview(
        questionId: 'q1',
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedCycleId: q1CycleId,
      );

      // 归档q1
      await questionRepo.archiveQuestion(
        questionId: 'q1',
        operationDate: LearningDate.parse('2026-11-20'),
      );

      // 验证：q1仍在计划中（已完成保留）
      final plan = await planRepo.getPlan(LearningDate.parse('2026-11-20'));
      expect(plan!.members.map((m) => m.questionId).contains('q1'), true);
      expect(plan.members.where((m) => m.questionId == 'q1').first.isCompleted,
          true);
    });

    test('归档未完成：移出并补位3道候补', () async {

      // 创建8个题
      for (int i = 0; i < 8; i++) {
        await db
            .into(db.mistakeQuestions)
            .insert(MistakeQuestionsCompanion.insert(
              id: 'q$i',
              subject: 'Math',
              questionText: 'Q$i',
              mistakeDate: DateTime.now(),
              createdAt: DateTime.now().add(Duration(minutes: i)),
              updatedAt: DateTime.now(),
            ));
        await reviewRepo.createInitialCycle(
          questionId: 'q$i',
          formalizedDate: LearningDate.parse('2026-11-19'),
        );
      }

      // 填充计划（前5个）
      await questionRepo.ensurePlanFilled(
        date: LearningDate.parse('2026-11-20'),
      );

      // 归档q0（未完成）
      await questionRepo.archiveQuestion(
        questionId: 'q0',
        operationDate: LearningDate.parse('2026-11-20'),
      );

      final plan = await planRepo.getPlan(LearningDate.parse('2026-11-20'));

      // 验证：q0已移出
      expect(plan!.members.map((m) => m.questionId).contains('q0'), false);

      // 验证：补入q5（候补第1个）
      expect(plan.members.length, 5);
      expect(plan.members.map((m) => m.questionId).contains('q5'), true);

      // 验证完整内容
      final memberIds = plan.members.map((m) => m.questionId).toList();
      expect(memberIds, ['q1', 'q2', 'q3', 'q4', 'q5']);
    });

    test('删除无论是否完成：均移出并补位', () async {

      // 创建6个题
      for (int i = 0; i < 6; i++) {
        await db
            .into(db.mistakeQuestions)
            .insert(MistakeQuestionsCompanion.insert(
              id: 'q$i',
              subject: 'Math',
              questionText: 'Q$i',
              mistakeDate: DateTime.now(),
              createdAt: DateTime.now().add(Duration(minutes: i)),
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

      // 完成q0
      final q0CycleId = (await (db.select(db.reviewCycles)
                ..where((c) => c.questionId.equals('q0')))
              .getSingle())
          .id;
      await reviewRepo.submitScheduledReview(
        questionId: 'q0',
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedCycleId: q0CycleId,
      );

      // 删除q0（已完成）
      await questionRepo.deleteQuestion(
        questionId: 'q0',
        operationDate: LearningDate.parse('2026-11-20'),
      );

      final plan = await planRepo.getPlan(LearningDate.parse('2026-11-20'));

      // 验证：q0已移出（虽然已完成）
      expect(plan!.members.map((m) => m.questionId).contains('q0'), false);

      // 验证：补入q5
      expect(plan.members.length, 5);
      expect(plan.members.map((m) => m.questionId).contains('q5'), true);
    });

    test('恢复：不重建旧计划', () async {
      await settingsRepo.setDailyTargetN(5);

      // 创建并归档q1
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
        formalizedDate: LearningDate.parse('2026-11-19'),
      );

      await questionRepo.ensurePlanFilled(
        date: LearningDate.parse('2026-11-20'),
      );

      await questionRepo.archiveQuestion(
        questionId: 'q1',
        operationDate: LearningDate.parse('2026-11-20'),
      );

      // 恢复q1
      await questionRepo.restoreQuestion(questionId: 'q1');

      // 验证：20日计划不自动加回q1
      final plan = await planRepo.getPlan(LearningDate.parse('2026-11-20'));
      expect(plan, isNotNull);
      // q1已移出，不会自动加回
    });

    test('恢复后重复自评：题日幂等保证拒绝', () async {
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
        formalizedDate: LearningDate.parse('2026-11-19'),
      );

      // 获取cycleId
      final q1CycleId = (await (db.select(db.reviewCycles)
                ..where((c) => c.questionId.equals('q1')))
              .getSingle())
          .id;

      // 首次提交
      await reviewRepo.submitScheduledReview(
        questionId: 'q1',
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        capacityConfirmed: true,
        expectedCycleId: q1CycleId,
      );

      // 归档再恢复
      await questionRepo.archiveQuestion(
        questionId: 'q1',
        operationDate: LearningDate.parse('2026-11-20'),
      );
      await questionRepo.restoreQuestion(questionId: 'q1');

      // 重复提交
      final result2 = await reviewRepo.submitScheduledReview(
        questionId: 'q1',
        result: ReviewResult.fuzzy,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        capacityConfirmed: true,
        expectedCycleId: q1CycleId,
      );

      // 验证：幂等拒绝
      expect(result2, isA<SubmissionDuplicate>());
    });

    test('再错未完成：实际补入别的题', () async {

      // 创建6个题
      for (int i = 0; i < 6; i++) {
        await db
            .into(db.mistakeQuestions)
            .insert(MistakeQuestionsCompanion.insert(
              id: 'q$i',
              subject: 'Math',
              questionText: 'Q$i',
              mistakeDate: DateTime.now(),
              createdAt: DateTime.now().add(Duration(minutes: i)),
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

      final planBefore =
          await planRepo.getPlan(LearningDate.parse('2026-11-20'));
      final membersBefore =
          planBefore!.members.map((m) => m.questionId).toList();
      expect(membersBefore, ['q0', 'q1', 'q2', 'q3', 'q4']);

      // 再错q0（未完成），使用含补位的方法
      await questionRepo.markAsMistakeAgainWithBackfill(
        questionId: 'q0',
        operationDate: LearningDate.parse('2026-11-20'),
      );

      final planAfter =
          await planRepo.getPlan(LearningDate.parse('2026-11-20'));
      final membersAfter = planAfter!.members.map((m) => m.questionId).toList();

      // 验证：q0已退出
      expect(membersAfter.contains('q0'), false);

      // 验证：补入q5（实际内容）
      expect(membersAfter.contains('q5'), true);
      expect(membersAfter, ['q1', 'q2', 'q3', 'q4', 'q5']);
    });
  });
}
