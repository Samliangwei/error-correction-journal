import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/core/database/database.dart';
import 'package:error_journal/core/repositories/review_repository.dart';
import 'package:error_journal/core/repositories/daily_plan_repository.dart';
import 'package:error_journal/core/repositories/settings_repository.dart';
import 'package:error_journal/core/repositories/mistake_question_repository.dart';
import 'package:error_journal/core/scheduling/learning_date.dart';
import 'package:error_journal/core/scheduling/review_result.dart';
import 'package:error_journal/core/scheduling/review_submission.dart';

/// 回归测试：问题4/5/8 - 提交拒绝场景
void main() {
  late AppDatabase db;
  late ReviewRepository reviewRepo;
  late DailyPlanRepository planRepo;
  late SettingsRepository settingsRepo;
  late MistakeQuestionRepository questionRepo;

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

  group('问题4：生命周期检查', () {
    test('归档题目：拒绝提交+零写', () async {
      const questionId = 'q1';

      // 创建题目和周期
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

      final cycleBeforeArchive = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(questionId)))
          .getSingle();
      final questionBeforeArchive = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .getSingle();

      // 归档题目
      await questionRepo.archiveQuestion(
        questionId: questionId,
        operationDate: LearningDate.parse('2026-11-20'),
      );

      // 尝试提交（归档后version已变化，旧version应被拒绝）
      final result = await reviewRepo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: questionBeforeArchive.version,
        expectedCycleId: cycleBeforeArchive.id,
        expectedCycleVersion: cycleBeforeArchive.version,
      );

      // 验证：拒绝（归档后version递增，旧version被拒）
      expect(result, isA<SubmissionStaleQuestion>());

      // 验证：零写（无事件）
      final events = await db.select(db.reviewEvents).get();
      expect(events.length, 0);

      // 验证：周期未变，但题目version已递增
      final cycleAfter = await reviewRepo.getActiveCycle(questionId);
      expect(cycleAfter!.version, 1); // 周期版本未递增
    });

    test('软删除题目：拒绝提交+零写', () async {
      const questionId = 'q2';

      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
            id: questionId,
            subject: 'Math',
            questionText: 'Q2',
            mistakeDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
      await reviewRepo.createInitialCycle(
        questionId: questionId,
        formalizedDate: LearningDate.parse('2026-11-19'),
      );

      final cycleBeforeDelete = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(questionId)))
          .getSingle();
      final questionBeforeDelete = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .getSingle();

      // 软删除
      await questionRepo.deleteQuestion(
        questionId: questionId,
        operationDate: LearningDate.parse('2026-11-20'),
      );

      // 尝试提交（删除后version已变化，旧version应被拒绝）
      final result = await reviewRepo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: questionBeforeDelete.version,
        expectedCycleId: cycleBeforeDelete.id,
        expectedCycleVersion: cycleBeforeDelete.version,
      );

      // 验证：拒绝（删除后version递增，旧version被拒）
      expect(result, isA<SubmissionStaleQuestion>());

      // 验证：零写
      final events = await db.select(db.reviewEvents).get();
      expect(events.length, 0);
    });

    test('已掌握k>=4：拒绝提交+零写', () async {
      const questionId = 'q3';

      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
            id: questionId,
            subject: 'Math',
            questionText: 'Q3',
            mistakeDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
      await reviewRepo.createInitialCycle(
        questionId: questionId,
        formalizedDate: LearningDate.parse('2026-11-19'),
      );

      // 手动设置k=4
      await (db.update(db.reviewCycles)
            ..where((c) => c.questionId.equals(questionId)))
          .write(const ReviewCyclesCompanion(kLevel: Value(4)));

      final cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(questionId)))
          .getSingle();
      final question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .getSingle();

      // 尝试提交（k4已掌握应拒绝）
      final result = await reviewRepo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: cycle.id,
        expectedCycleVersion: cycle.version,
      );

      // 验证：拒绝
      expect(result, isA<SubmissionAlreadyMastered>());

      // 验证：零写
      final events = await db.select(db.reviewEvents).get();
      expect(events.length, 0);
    });

    test('未到期题目：拒绝提交+零写', () async {
      const questionId = 'q4';

      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
            id: questionId,
            subject: 'Math',
            questionText: 'Q4',
            mistakeDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
      await reviewRepo.createInitialCycle(
        questionId: questionId,
        formalizedDate: LearningDate.parse('2026-11-19'),
      ); // due=2026-11-20

      final cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(questionId)))
          .getSingle();
      final question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .getSingle();

      // 尝试在到期前提交（11-19提交，due=11-20）
      final result = await reviewRepo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-19'), // 未到期
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: cycle.id,
        expectedCycleVersion: cycle.version,
      );

      // 验证：拒绝
      expect(result, isA<SubmissionNotDueYet>());
      final notDue = result as SubmissionNotDueYet;
      expect(notDue.dueDate.value, '2026-11-20');

      // 验证：零写
      final events = await db.select(db.reviewEvents).get();
      expect(events.length, 0);
    });
  });

  group('问题5：版本校验', () {
    test('题目版本冲突：拒绝提交+零写', () async {
      const questionId = 'q5';

      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
            id: questionId,
            subject: 'Math',
            questionText: 'Q5',
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

      // 模拟题目被编辑（版本递增）
      await (db.update(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .write(MistakeQuestionsCompanion(
        questionText: const Value('Q5 - edited'),
        version: const Value(2),
        updatedAt: Value(DateTime.now()),
      ));

      // 尝试用旧版本提交
      final result = await reviewRepo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: 1, // 旧版本
        expectedCycleId: cycle.id,
        expectedCycleVersion: cycle.version,
      );

      // 验证：拒绝
      expect(result, isA<SubmissionStaleQuestion>());
      final stale = result as SubmissionStaleQuestion;
      expect(stale.expectedVersion, 1);
      expect(stale.actualVersion, 2);

      // 验证：零写
      final events = await db.select(db.reviewEvents).get();
      expect(events.length, 0);
    });

    test('周期ID冲突（旧周期）：拒绝提交+零写', () async {
      const questionId = 'q6';

      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
            id: questionId,
            subject: 'Math',
            questionText: 'Q6',
            mistakeDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
      await reviewRepo.createInitialCycle(
        questionId: questionId,
        formalizedDate: LearningDate.parse('2026-11-19'),
      );

      final firstCycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(questionId)))
          .getSingle();
      final question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .getSingle();

      // 模拟再错（创建新周期）
      await reviewRepo.markAsMistakeAgain(
        questionId: questionId,
        operationDate: LearningDate.parse('2026-11-20'),
      );

      // 尝试用旧周期ID提交（旧周期已失效）
      final result = await reviewRepo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: firstCycle.id, // 旧周期ID
        expectedCycleVersion: firstCycle.version,
      );

      // 验证：拒绝
      expect(result, isA<SubmissionStaleCycle>());
      final stale = result as SubmissionStaleCycle;
      expect(stale.expectedId, firstCycle.id);
      expect(stale.actualId, isNot(firstCycle.id)); // 新周期ID不同

      // 验证：零写（无新事件）
      final events = await db.select(db.reviewEvents).get();
      expect(events.length, 0);
    });
  });

  group('问题8：事件cycleId关联', () {
    test('成功提交：event.cycleId引用真实cycle.id', () async {
      const questionId = 'q7';

      await db
          .into(db.mistakeQuestions)
          .insert(MistakeQuestionsCompanion.insert(
            id: questionId,
            subject: 'Math',
            questionText: 'Q7',
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

      // 提交
      final result = await reviewRepo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: cycle.id,
        expectedCycleVersion: cycle.version,
      );

      expect(result, isA<SubmissionSuccess>());

      // 验证：event.cycleId == cycle.id
      final event = await (db.select(db.reviewEvents)
            ..where((e) => e.questionId.equals(questionId)))
          .getSingle();
      expect(event.cycleId, cycle.id); // 必须是真实的cycle.id，不是随机UUID

      // 验证：可通过cycleId关联查询
      final cycleById = await (db.select(db.reviewCycles)
            ..where((c) => c.id.equals(event.cycleId)))
          .getSingle();
      expect(cycleById.questionId, questionId);
    });

    test('问题5：版本校验 周期版本推进后旧卡到新due仍拒绝', () async {
      // 创建题目和周期
      await db.into(db.mistakeQuestions).insert(MistakeQuestionsCompanion.insert(
            id: 'q1',
            subject: 'Math',
            questionText: 'Q1',
            mistakeDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
      final questionId = 'q1';

      await reviewRepo.createInitialCycle(
        questionId: questionId,
        formalizedDate: LearningDate.parse('2026-11-19'),
      );

      // 读取卡片快照（当前版本）
      var cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(questionId)))
          .getSingle();
      var question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .getSingle();
      final oldCycleVersion = cycle.version;

      // 提交一次成功，推进周期版本
      var result1 = await reviewRepo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: cycle.id,
        expectedCycleVersion: cycle.version,
      );
      expect(result1, isA<SubmissionSuccess>());

      // 重新读取周期，版本已递增
      cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(questionId))
            ..where((c) => c.isActive.equals(true)))
          .getSingle();
      expect(cycle.version, greaterThan(oldCycleVersion), reason: '周期版本应递增');

      // 到新due日期（11-24），但使用旧版本快照尝试提交
      question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .getSingle();
      final result2 = await reviewRepo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-24'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: cycle.id,
        expectedCycleVersion: oldCycleVersion, // 使用旧版本
      );

      // 验证：旧版本卡片到新due日期仍被拒绝
      expect(result2, isA<SubmissionStaleCycle>());

      // 验证：零写
      final events = await (db.select(db.reviewEvents)
            ..where((e) => e.learningDate.equals('2026-11-24')))
          .get();
      expect(events.length, 0, reason: '不应写入新事件');
    });

    test('问题5：版本校验 归档后恢复，旧卡拒绝', () async {
      // 创建题目和周期
      await db.into(db.mistakeQuestions).insert(MistakeQuestionsCompanion.insert(
            id: 'q2',
            subject: 'Math',
            questionText: 'Q2',
            mistakeDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
      final questionId = 'q2';

      await reviewRepo.createInitialCycle(
        questionId: questionId,
        formalizedDate: LearningDate.parse('2026-11-19'),
      );

      // 读取归档前的卡片快照
      final cycleBeforeArchive = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(questionId)))
          .getSingle();
      final questionBeforeArchive = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .getSingle();

      // 归档题目（递增version）
      await questionRepo.archiveQuestion(questionId: questionId);

      // 恢复题目（再次递增version）
      await questionRepo.restoreQuestion(questionId: questionId);

      // 使用归档前的旧版本卡片尝试提交
      final result = await reviewRepo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-20'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: questionBeforeArchive.version, // 旧version
        expectedCycleId: cycleBeforeArchive.id,
        expectedCycleVersion: cycleBeforeArchive.version,
      );

      // 验证：旧卡被拒绝（version已变）
      expect(result, isA<SubmissionStaleQuestion>());

      // 验证：零写
      final events = await db.select(db.reviewEvents).get();
      expect(events.length, 0, reason: '不应写入事件');
    });
  });
}
