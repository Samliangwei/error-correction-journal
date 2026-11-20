import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/core/database/database.dart';
import 'package:error_journal/core/repositories/daily_plan_repository.dart';
import 'package:error_journal/core/repositories/review_repository.dart';
import 'package:error_journal/core/repositories/settings_repository.dart';
import 'package:error_journal/core/scheduling/learning_date.dart';
import 'package:error_journal/core/scheduling/review_result.dart';

void main() {
  group('补位排序稳定性', () {
    late AppDatabase db;
    late ReviewRepository reviewRepo;
    late DailyPlanRepository planRepo;
    late SettingsRepository settingsRepo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      planRepo = DailyPlanRepository(db);
      settingsRepo = SettingsRepository(db);
      reviewRepo = ReviewRepository(db, planRepo, settingsRepo);

      await settingsRepo.setDailyTargetN(5);
      await db.customStatement(
          'UPDATE settings SET daily_target_n = 5, daily_target_pending_n = NULL WHERE id = 1');
    });

    tearDown(() async {
      await db.close();
    });

    test('相同due+created的题目按q.id ASC排序', () async {
      final now = DateTime.now();
      final sameTime = now.subtract(const Duration(days: 10));

      // 创建3个题目，相同的created_at，逆UUID顺序插入
      // 预期补位时按q.id ASC，应选中q-aaa（字典序最小）
      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
            id: 'q-zzz',
            subject: 'Math',
            questionText: 'Q-zzz',
            mistakeDate: sameTime,
            createdAt: sameTime,
            updatedAt: sameTime,
          ));

      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
            id: 'q-mmm',
            subject: 'Math',
            questionText: 'Q-mmm',
            mistakeDate: sameTime,
            createdAt: sameTime,
            updatedAt: sameTime,
          ));

      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
            id: 'q-aaa',
            subject: 'Math',
            questionText: 'Q-aaa',
            mistakeDate: sameTime,
            createdAt: sameTime,
            updatedAt: sameTime,
          ));

      // 创建周期，相同due日期
      await reviewRepo.createInitialCycle(
        questionId: 'q-zzz',
        formalizedDate: LearningDate.parse('2026-11-10'),
      );
      await reviewRepo.createInitialCycle(
        questionId: 'q-mmm',
        formalizedDate: LearningDate.parse('2026-11-10'),
      );
      await reviewRepo.createInitialCycle(
        questionId: 'q-aaa',
        formalizedDate: LearningDate.parse('2026-11-10'),
      );

      // 提交一个题目，计划已有4个
      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
            id: 'q-existing',
            subject: 'Math',
            questionText: 'Q-existing',
            mistakeDate: now,
            createdAt: now,
            updatedAt: now,
          ));
      await reviewRepo.createInitialCycle(
        questionId: 'q-existing',
        formalizedDate: LearningDate.parse('2026-11-19'),
      );

      final existingCycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals('q-existing')))
          .getSingle();
      final existingQuestion = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals('q-existing')))
          .getSingle();

      await reviewRepo.submitScheduledReview(
        questionId: 'q-existing',
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: existingQuestion.version,
        expectedCycleId: existingCycle.id,
        expectedCycleVersion: existingCycle.version,
      );

      // 现在提交旧卡，只剩1个名额（N=5，已有1个）
      // 应该选择q-aaa（字典序最小）
      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
            id: 'q-old',
            subject: 'Math',
            questionText: 'Q-old',
            mistakeDate: now.subtract(const Duration(days: 20)),
            createdAt: now.subtract(const Duration(days: 20)),
            updatedAt: now.subtract(const Duration(days: 20)),
          ));
      await reviewRepo.createInitialCycle(
        questionId: 'q-old',
        formalizedDate: LearningDate.parse('2026-11-01'),
      );

      final oldCycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals('q-old')))
          .getSingle();
      final oldQuestion = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals('q-old')))
          .getSingle();

      await reviewRepo.submitScheduledReview(
        questionId: 'q-old',
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        capacityConfirmed: true,
        expectedQuestionVersion: oldQuestion.version,
        expectedCycleId: oldCycle.id,
        expectedCycleVersion: oldCycle.version,
      );

      // 验证计划成员
      final plan = await planRepo.getPlan(LearningDate.parse('2026-11-20'));
      expect(plan != null, true);
      expect(plan!.capacityC, 5);

      final members = plan.members;
      expect(members.length, 5); // 2个已提交 + 补满4个候选

      // 验证补位的4个候选题按q.id ASC排序
      // 由于q-old最早due（11-02），它已在计划中
      // 其余3个相同due（11-11），应按q.id ASC：q-aaa, q-mmm, q-zzz
      // 只剩4个名额，应该是：q-old(11-02), q-aaa(11-11), q-mmm(11-11), q-zzz(11-11)
      final memberIds = members.map((m) => m.questionId).toList();
      expect(memberIds, contains('q-existing'));
      expect(memberIds, contains('q-old'));
      expect(memberIds, contains('q-aaa'));
      expect(memberIds, contains('q-mmm'));
      // q-zzz应该被选中（因为N=5，所以5个都能进）
      expect(memberIds, contains('q-zzz'));

      // 验证顺序：按orderIndex排序
      final sortedMembers = members
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      final orderedIds = sortedMembers.map((m) => m.questionId).toList();

      // q-old最早due应排最前
      expect(orderedIds[0], 'q-old');
      // 然后是相同due的三个，按q.id ASC
      expect(orderedIds[1], 'q-aaa');
      expect(orderedIds[2], 'q-mmm');
      expect(orderedIds[3], 'q-zzz');
    });
  });
}
