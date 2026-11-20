import 'package:drift/drift.dart' hide isNotNull;
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
  late AppDatabase db;
  late ReviewRepository repo;
  late DailyPlanRepository planRepo;
  late SettingsRepository settingsRepo;

  setUp(() async {
    // 内存数据库
    db = AppDatabase.forTesting(NativeDatabase.memory());
    planRepo = DailyPlanRepository(db);
    settingsRepo = SettingsRepository(db);
    repo = ReviewRepository(db, planRepo, settingsRepo);
  });

  tearDown(() async {
    await db.close();
  });

  group('ReviewRepository - 持久化集成', () {
    test('创建初始周期并持久化', () async {
      const questionId = 'q1';
      final formalizedDate = LearningDate.parse('2026-11-20');

      // 创建题目
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

      // When: 创建初始周期
      final cycle = await repo.createInitialCycle(
        questionId: questionId,
        formalizedDate: formalizedDate,
      );

      // Then: 验证领域模型
      expect(cycle.questionId, questionId);
      expect(cycle.cycleNumber, 1);
      expect(cycle.kLevel.value, 0);
      expect(cycle.dueDate?.value, '2026-11-21');

      // Then: 验证持久化
      final rows = await db.select(db.reviewCycles).get();
      expect(rows.length, 1);
      expect(rows.first.questionId, questionId);
      expect(rows.first.kLevel, 0);
      expect(rows.first.dueDate, '2026-11-21');
    });

    test('获取活动周期', () async {
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
      await repo.createInitialCycle(
        questionId: questionId,
        formalizedDate: LearningDate.parse('2026-11-20'),
      );

      // When: 获取
      final cycle = await repo.getActiveCycle(questionId);

      // Then: 正确返回
      expect(cycle, isNotNull);
      expect(cycle!.questionId, questionId);
      expect(cycle.isActive, true);
    });

    test('提交复习（事务集成：事件+周期）', () async {
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
      await repo.createInitialCycle(
        questionId: questionId,
        formalizedDate: LearningDate.parse('2026-11-20'),
      );

      final cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(questionId)))
          .getSingle();
      final question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .getSingle();

      // When: 提交会了
      final result = await repo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-21'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: cycle.id,
        expectedCycleVersion: cycle.version,
      );

      // Then: 领域层成功
      expect(result, isA<SubmissionSuccess>());
      final success = result as SubmissionSuccess;
      expect(success.updatedCycle.kLevel.value, 1);
      expect(success.updatedCycle.dueDate?.value, '2026-11-24');

      // Then: 事件已持久化
      final events = await db.select(db.reviewEvents).get();
      expect(events.length, 1);
      expect(events.first.questionId, questionId);
      expect(events.first.result, 'know');
      expect(events.first.kLevelBefore, 0);
      expect(events.first.kLevelAfter, 1);

      // Then: 周期已更新
      final cycle = await repo.getActiveCycle(questionId);
      expect(cycle!.kLevel.value, 1);
      expect(cycle.dueDate?.value, '2026-11-24');
      expect(cycle.version, 2); // 版本递增
    });

    test('同题同日重复提交（幂等性）', () async {
      const questionId = 'q1';
      final learningDate = LearningDate.parse('2026-11-21');

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
      await repo.createInitialCycle(
        questionId: questionId,
        formalizedDate: LearningDate.parse('2026-11-20'),
      );

      var cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(questionId)))
          .getSingle();
      var question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .getSingle();

      // 首次提交
      await repo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.know,
        submittedDate: learningDate,
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: cycle.id,
        expectedCycleVersion: cycle.version,
      );

      // 重新读取更新后的数据（虽然幂等会拒绝）
      cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(questionId)))
          .getSingle();
      question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .getSingle();

      // When: 重复提交
      final result2 = await repo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.fuzzy, // 不同结果
        submittedDate: learningDate,
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: cycle.id,
        expectedCycleVersion: cycle.version,
      );

      // Then: 幂等拒绝
      expect(result2, isA<SubmissionDuplicate>());
      final duplicate = result2 as SubmissionDuplicate;
      expect(duplicate.existingEvent.result, ReviewResult.know); // 返回首次

      // Then: 只有一条事件
      final events = await db.select(db.reviewEvents).get();
      expect(events.length, 1);
    });

    test('再次出错：新周期k0/明日（事务）', () async {
      const questionId = 'q1';
      final operationDate = LearningDate.parse('2026-11-25');

      // Given: 旧周期k2
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
      await repo.createInitialCycle(
        questionId: questionId,
        formalizedDate: LearningDate.parse('2026-11-20'),
      );
      // 手动更新到k2
      await (db.update(db.reviewCycles)
            ..where((c) => c.questionId.equals(questionId)))
          .write(const ReviewCyclesCompanion(kLevel: Value(2)));

      // When: 再次出错
      await repo.markAsMistakeAgain(
        questionId: questionId,
        operationDate: operationDate,
      );

      // Then: 旧周期关闭
      final allCycles = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(questionId)))
          .get();
      final oldCycles = allCycles.where((c) => !c.isActive).toList();
      expect(oldCycles.length, 1);
      expect(oldCycles.first.cycleNumber, 1);

      // Then: 新周期k0/明日
      final newCycle = await repo.getActiveCycle(questionId);
      expect(newCycle, isNotNull);
      expect(newCycle!.cycleNumber, 2);
      expect(newCycle.kLevel.value, 0);
      expect(newCycle.dueDate?.value, '2026-11-26'); // 明日

      // Then: 再错标记已记录
      final marks = await db.select(db.mistakeAgainMarks).get();
      expect(marks.length, 1);
      expect(marks.first.questionId, questionId);
      expect(marks.first.operationDate, operationDate.value);
    });

    test('再次出错同日幂等', () async {
      const questionId = 'q1';
      final operationDate = LearningDate.parse('2026-11-25');

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
      await repo.createInitialCycle(
        questionId: questionId,
        formalizedDate: LearningDate.parse('2026-11-20'),
      );

      // 首次再错
      await repo.markAsMistakeAgain(
        questionId: questionId,
        operationDate: operationDate,
      );

      final cycle1 = await repo.getActiveCycle(questionId);

      // When: 同日重复再错
      await repo.markAsMistakeAgain(
        questionId: questionId,
        operationDate: operationDate,
      );

      final cycle2 = await repo.getActiveCycle(questionId);

      // Then: 幂等，周期号不变
      expect(cycle2!.cycleNumber, cycle1!.cycleNumber);

      // Then: 只有一条标记
      final marks = await db.select(db.mistakeAgainMarks).get();
      expect(marks.length, 1);
    });

    test('数据库持久化（概念验证）', () async {
      // 注意：内存数据库关闭后数据会丢失
      // 真实文件数据库持久化测试见集成测试
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
      await repo.createInitialCycle(
        questionId: questionId,
        formalizedDate: LearningDate.parse('2026-11-20'),
      );

      final cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(questionId)))
          .getSingle();
      final question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .getSingle();

      await repo.submitScheduledReview(
        questionId: questionId,
        result: ReviewResult.know,
        submittedDate: LearningDate.parse('2026-11-21'),
        hasAnswer: true,
        hasConfirmedVerification: false,
        expectedQuestionVersion: question.version,
        expectedCycleId: cycle.id,
        expectedCycleVersion: cycle.version,
      );

      // 验证数据已持久化到当前数据库实例
      final cycleFromCurrentDb = await repo.getActiveCycle(questionId);
      expect(cycleFromCurrentDb, isNotNull);
      expect(cycleFromCurrentDb!.kLevel.value, 1);

      final events = await db.select(db.reviewEvents).get();
      expect(events.length, 1);
    });
  });
}
