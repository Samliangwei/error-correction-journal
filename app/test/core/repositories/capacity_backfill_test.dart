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
  group('问题6：容量预留与补满', () {
    late AppDatabase db;
    late ReviewRepository reviewRepo;
    late DailyPlanRepository planRepo;
    late SettingsRepository settingsRepo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      planRepo = DailyPlanRepository(db);
      settingsRepo = SettingsRepository(db);
      reviewRepo = ReviewRepository(db, planRepo, settingsRepo);

      // 设置N=20（通过API确保只有一条记录）
      await settingsRepo.setDailyTargetN(20);
      // 手动应用到当前生效（测试用）
      await db.customStatement(
          'UPDATE settings SET daily_target_n = 20, daily_target_pending_n = NULL WHERE id = 1');
    });

    tearDown(() async {
      await db.close();
    });

    test('旧卡跨日确认：预留+补满到N，旧卡不在前20但在最终20内', () async {
      // 创建30个候选题
      for (int i = 0; i < 30; i++) {
        await db
            .into(db.mistakeQuestions)
            .insert(MistakeQuestionsCompanion.insert(
              id: 'q$i',
              subject: 'Math',
              questionText: 'Q$i',
              mistakeDate: DateTime.now(),
              createdAt: DateTime.now().add(Duration(minutes: i)), // 按创建时间排序
              updatedAt: DateTime.now(),
            ));
        await reviewRepo.createInitialCycle(
          questionId: 'q$i',
          formalizedDate: LearningDate.parse('2026-11-19'),
        );
      }

      // 旧卡：q25（排序第26，不在前20）
      const oldCardId = 'q25';
      final cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(oldCardId))
            ..where((c) => c.isActive.equals(true)))
          .getSingle();
      final question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(oldCardId)))
          .getSingle();

      // 提交旧卡（跨日）
      final result = await reviewRepo.submitScheduledReview(
        questionId: oldCardId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: cycle.id,
        expectedCycleVersion: cycle.version,
        capacityConfirmed: true, // 确认
      );

      // 验证：提交成功
      expect(result, isA<SubmissionSuccess>());

      // 验证：计划已创建且填满到N=20
      final plan = await planRepo.getPlan(LearningDate.parse('2026-11-20'));
      expect(plan, isNotNull);
      expect(plan!.members.length, 20); // 填满到N
      expect(plan.capacityC, 20); // C=20

      // 验证：旧卡在计划中
      final memberIds = plan.members.map((m) => m.questionId).toList();
      expect(memberIds.contains(oldCardId), true);

      // 验证：包含排序靠前的19个题（q0-q19中的19个，加上q25共20个）
      // 由于q25已在计划中，补满时会填入前19个非q25的题
      int topCount = 0;
      for (int i = 0; i < 20; i++) {
        if (memberIds.contains('q$i')) {
          topCount++;
        }
      }
      expect(topCount, 19); // 前20个中的19个（排除q25）

      // 验证：旧卡已完成
      final member = plan.members.firstWhere((m) => m.questionId == oldCardId);
      expect(member.isCompleted, true);

      // 验证：事件已记录
      final events = await db.select(db.reviewEvents).get();
      expect(events.length, 1);
      expect(events.first.questionId, oldCardId);
      expect(events.first.result, 'know');

      // 验证：周期已更新
      final cycleAfter2 = await reviewRepo.getActiveCycle(oldCardId);
      expect(cycleAfter2, isNotNull);
      expect(cycleAfter2!.kLevel.value, 1);
    });

    test('已有计划满额，重复确认同题：零扩容', () async {
      // 创建30个候选题
      for (int i = 0; i < 30; i++) {
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

      const oldCardId = 'q25';
      var cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(oldCardId))
            ..where((c) => c.isActive.equals(true)))
          .getSingle();
      var question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(oldCardId)))
          .getSingle();

      // 首次确认提交
      await reviewRepo.submitScheduledReview(
        questionId: oldCardId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: cycle.id,
        expectedCycleVersion: cycle.version,
        capacityConfirmed: true,
      );

      final planBefore =
          await planRepo.getPlan(LearningDate.parse('2026-11-20'));
      final capacityBefore = planBefore!.capacityC;
      final memberCountBefore = planBefore.members.length;

      // 重新读取更新后的cycle和question（虽然幂等会拒绝）
      cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(oldCardId))
            ..where((c) => c.isActive.equals(true)))
          .getSingle();
      question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(oldCardId)))
          .getSingle();

      // 重复确认（同题同日）
      final result2 = await reviewRepo.submitScheduledReview(
        questionId: oldCardId,
        result: ReviewResult.fuzzy, // 不同结果
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: cycle.id,
        expectedCycleVersion: cycle.version,
        capacityConfirmed: true, // 再次确认
      );

      // 验证：幂等拒绝
      expect(result2, isA<SubmissionDuplicate>());

      // 验证：C值不变（零扩容）
      final planAfter =
          await planRepo.getPlan(LearningDate.parse('2026-11-20'));
      expect(planAfter!.capacityC, capacityBefore); // C不变
      expect(planAfter.members.length, memberCountBefore); // 成员数不变

      // 验证：只有一个事件
      final events = await db.select(db.reviewEvents).get();
      expect(events.length, 1);
      expect(events.first.result, 'know'); // 保留首次结果
    });

    test('新日无计划：预留旧卡+补满候选', () async {
      // 创建10个候选题
      for (int i = 0; i < 10; i++) {
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

      // 旧卡：q5
      const oldCardId = 'q5';
      final cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(oldCardId))
            ..where((c) => c.isActive.equals(true)))
          .getSingle();
      final question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(oldCardId)))
          .getSingle();

      // 提交旧卡（新日无计划）
      final result = await reviewRepo.submitScheduledReview(
        questionId: oldCardId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: cycle.id,
        expectedCycleVersion: cycle.version,
        capacityConfirmed: false, // 不确认（有容量）
      );

      // 验证：提交成功
      expect(result, isA<SubmissionSuccess>());

      // 验证：计划已补满min(C, 候选数) = min(20, 10) = 10
      final plan = await planRepo.getPlan(LearningDate.parse('2026-11-20'));
      expect(plan, isNotNull);
      expect(plan!.members.length, 10); // 旧卡q5 + 补满到10个
      expect(
          plan.members.any((m) => m.questionId == oldCardId), isTrue); // 包含旧卡
      expect(plan.capacityC, 20); // C初始=N
    });

    test('满额确认：断言C值而不只count', () async {
      // 创建25个候选题
      for (int i = 0; i < 25; i++) {
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

      const oldCardId = 'q20';
      final cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(oldCardId))
            ..where((c) => c.isActive.equals(true)))
          .getSingle();
      final question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(oldCardId)))
          .getSingle();

      // 提交旧卡（确认）
      await reviewRepo.submitScheduledReview(
        questionId: oldCardId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: cycle.id,
        expectedCycleVersion: cycle.version,
        capacityConfirmed: true,
      );

      // 验证：C=20（填满到N）
      final plan = await planRepo.getPlan(LearningDate.parse('2026-11-20'));
      expect(plan, isNotNull);
      expect(plan!.capacityC, 20); // 断言C值
      expect(plan.members.length, 20); // 成员数也是20

      // 验证：旧卡在内
      final memberIds = plan.members.map((m) => m.questionId).toList();
      expect(memberIds.contains(oldCardId), true);
    });
  });
}
