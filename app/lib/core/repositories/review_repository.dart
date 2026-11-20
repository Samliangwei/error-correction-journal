/// 复习Repository（持久化层）
library;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../scheduling/learning_date.dart';
import '../scheduling/review_cycle.dart' as domain;
import '../scheduling/review_event.dart' as domain;
import '../scheduling/review_result.dart';
import '../scheduling/review_submission.dart';
import '../scheduling/scheduler.dart';
import '../scheduling/idempotency_guard.dart';

/// Repository实现（将领域模型映射到数据库）
class ReviewRepository {
  final AppDatabase db;

  ReviewRepository(this.db);

  /// 创建初始周期（保存时）
  Future<domain.ReviewCycle> createInitialCycle({
    required String questionId,
    required LearningDate formalizedDate,
  }) async {
    final cycle = domain.ReviewCycle.initial(
      questionId: questionId,
      formalizedDate: formalizedDate,
    );

    await db.into(db.reviewCycles).insert(ReviewCyclesCompanion.insert(
          id: const Uuid().v4(),
          questionId: cycle.questionId,
          cycleNumber: cycle.cycleNumber,
          kLevel: cycle.kLevel.value,
          dueDate: Value(cycle.dueDate?.value),
          isActive: Value(cycle.isActive),
          version: Value(cycle.version),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

    return cycle;
  }

  /// 获取活动周期
  Future<domain.ReviewCycle?> getActiveCycle(String questionId) async {
    final row = await (db.select(db.reviewCycles)
          ..where((c) => c.questionId.equals(questionId) & c.isActive.equals(true)))
        .getSingleOrNull();

    if (row == null) return null;

    return domain.ReviewCycle(
      questionId: row.questionId,
      cycleNumber: row.cycleNumber,
      kLevel: domain.KLevel.fromValue(row.kLevel),
      dueDate: row.dueDate != null ? LearningDate.parse(row.dueDate!) : null,
      isActive: row.isActive,
      version: row.version,
    );
  }

  /// 获取今日事件（幂等性检查）
  Future<List<domain.ReviewEvent>> getTodayEvents({
    required String questionId,
    required LearningDate learningDate,
  }) async {
    final rows = await (db.select(db.reviewEvents)
          ..where((e) =>
              e.questionId.equals(questionId) &
              e.learningDate.equals(learningDate.value)))
        .get();

    return rows
        .map((r) => domain.ReviewEvent(
              questionId: r.questionId,
              cycleNumber: r.cycleNumber,
              learningDate: LearningDate.parse(r.learningDate),
              result: _parseResult(r.result),
              kLevelBefore: domain.KLevel.fromValue(r.kLevelBefore),
              kLevelAfter: domain.KLevel.fromValue(r.kLevelAfter),
              dueDateAfter: r.dueDateAfter != null ? LearningDate.parse(r.dueDateAfter!) : null,
            ))
        .toList();
  }

  /// 提交排期复习（事务集成）
  ///
  /// 原子操作：事件 + 周期更新 同一事务
  Future<SubmissionResult> submitScheduledReview({
    required String questionId,
    required ReviewResult result,
    required LearningDate submittedDate,
    required bool hasAnswer,
    required bool hasConfirmedVerification,
  }) async {
    return await db.transaction(() async {
      // 1. 获取当前周期
      final currentCycle = await getActiveCycle(questionId);
      if (currentCycle == null) {
        throw StateError('No active cycle for question $questionId');
      }

      // 2. 获取今日事件（幂等性）
      final existingEvents = await getTodayEvents(
        questionId: questionId,
        learningDate: submittedDate,
      );

      // 3. 获取所有周期（再错检查）
      final allCycles = await _getAllCycles(questionId);

      // 4. 调用领域服务
      final domainResult = ReviewSubmissionService.submitScheduledReview(
        currentCycle: currentCycle,
        result: result,
        submittedDate: submittedDate,
        existingEvents: existingEvents,
        allCycles: allCycles,
        hasAnswer: hasAnswer,
        hasConfirmedVerification: hasConfirmedVerification,
      );

      // 5. 处理结果
      if (domainResult is SubmissionSuccess) {
        // 5.1 写入事件
        await db.into(db.reviewEvents).insert(ReviewEventsCompanion.insert(
              id: const Uuid().v4(),
              questionId: domainResult.event.questionId,
              cycleId: const Uuid().v4(), // TODO: 关联实际cycleId
              cycleNumber: domainResult.event.cycleNumber,
              learningDate: domainResult.event.learningDate.value,
              result: _serializeResult(domainResult.event.result),
              kLevelBefore: domainResult.event.kLevelBefore.value,
              kLevelAfter: domainResult.event.kLevelAfter.value,
              dueDateAfter: Value(domainResult.event.dueDateAfter?.value),
              createdAt: DateTime.now(),
            ));

        // 5.2 更新周期
        await (db.update(db.reviewCycles)
              ..where((c) =>
                  c.questionId.equals(questionId) & c.isActive.equals(true)))
            .write(ReviewCyclesCompanion(
          kLevel: Value(domainResult.updatedCycle.kLevel.value),
          dueDate: Value(domainResult.updatedCycle.dueDate?.value),
          version: Value(domainResult.updatedCycle.version),
          updatedAt: Value(DateTime.now()),
        ));

        // TODO: 5.3 更新每日计划（后续实现）
      }

      return domainResult;
    });
  }

  /// 再次出错（新周期）
  Future<void> markAsMistakeAgain({
    required String questionId,
    required LearningDate operationDate,
  }) async {
    await db.transaction(() async {
      // 1. 检查同日幂等
      final existingMark = await (db.select(db.mistakeAgainMarks)
            ..where((m) =>
                m.questionId.equals(questionId) &
                m.operationDate.equals(operationDate.value)))
          .getSingleOrNull();

      if (existingMark != null) {
        // 同日已再错，幂等返回
        return;
      }

      // 2. 关闭旧周期
      final oldCycle = await getActiveCycle(questionId);
      if (oldCycle != null) {
        await (db.update(db.reviewCycles)
              ..where((c) =>
                  c.questionId.equals(questionId) & c.isActive.equals(true)))
            .write(ReviewCyclesCompanion(
          isActive: const Value(false),
          updatedAt: Value(DateTime.now()),
        ));
      }

      // 3. 创建新周期
      final newCycle = Scheduler.createNewCycleForMistakeAgain(
        questionId: questionId,
        previousCycleNumber: oldCycle?.cycleNumber ?? 0,
        operationDate: operationDate,
      );

      await db.into(db.reviewCycles).insert(ReviewCyclesCompanion.insert(
            id: const Uuid().v4(),
            questionId: newCycle.questionId,
            cycleNumber: newCycle.cycleNumber,
            kLevel: newCycle.kLevel.value,
            dueDate: Value(newCycle.dueDate?.value),
            isActive: Value(newCycle.isActive),
            version: Value(newCycle.version),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));

      // 4. 记录再错标记
      await db.into(db.mistakeAgainMarks).insert(MistakeAgainMarksCompanion.insert(
            id: const Uuid().v4(),
            questionId: questionId,
            operationDate: operationDate.value,
            newCycleNumber: newCycle.cycleNumber,
            createdAt: DateTime.now(),
          ));
    });
  }

  Future<List<domain.ReviewCycle>> _getAllCycles(String questionId) async {
    final rows = await (db.select(db.reviewCycles)
          ..where((c) => c.questionId.equals(questionId)))
        .get();

    return rows
        .map((r) => domain.ReviewCycle(
              questionId: r.questionId,
              cycleNumber: r.cycleNumber,
              kLevel: domain.KLevel.fromValue(r.kLevel),
              dueDate: r.dueDate != null ? LearningDate.parse(r.dueDate!) : null,
              isActive: r.isActive,
              version: r.version,
            ))
        .toList();
  }

  ReviewResult _parseResult(String value) {
    switch (value) {
      case 'notKnow':
        return ReviewResult.notKnow;
      case 'fuzzy':
        return ReviewResult.fuzzy;
      case 'know':
        return ReviewResult.know;
      default:
        throw ArgumentError('Invalid review result: $value');
    }
  }

  String _serializeResult(ReviewResult result) {
    switch (result) {
      case ReviewResult.notKnow:
        return 'notKnow';
      case ReviewResult.fuzzy:
        return 'fuzzy';
      case ReviewResult.know:
        return 'know';
    }
  }
}
