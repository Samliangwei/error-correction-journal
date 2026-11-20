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
import 'daily_plan_repository.dart';
import 'settings_repository.dart';
import 'fault_injection.dart';

/// 容量检查结果
sealed class CapacityCheckResult {}

class CapacityAvailable extends CapacityCheckResult {
  final String planId;
  CapacityAvailable(this.planId);
}

class CapacityFullNeedsConfirmation extends CapacityCheckResult {
  final int currentCount;
  final int capacityC;
  CapacityFullNeedsConfirmation(this.currentCount, this.capacityC);
}

/// Repository实现（将领域模型映射到数据库）
class ReviewRepository {
  final AppDatabase db;
  final DailyPlanRepository planRepo;
  final SettingsRepository settingsRepo;

  /// 故障注入（仅测试用，不对用户暴露）
  final FaultInjection faultInjection = FaultInjection();

  ReviewRepository(this.db, this.planRepo, this.settingsRepo);

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
    faultInjection.triggerAfterInitialCycleInsert();

    return cycle;
  }

  /// 获取活动周期
  Future<domain.ReviewCycle?> getActiveCycle(String questionId) async {
    final row = await (db.select(db.reviewCycles)
          ..where(
              (c) => c.questionId.equals(questionId) & c.isActive.equals(true)))
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
              dueDateAfter: r.dueDateAfter != null
                  ? LearningDate.parse(r.dueDateAfter!)
                  : null,
            ))
        .toList();
  }

  /// 检查容量并预留（旧卡新日）
  Future<CapacityCheckResult> checkCapacityAndReserve({
    required String questionId,
    required LearningDate submittedDate,
    required bool confirmed,
  }) async {
    // 使用日期相关的N（次日生效规则）
    final targetN = await settingsRepo.getDailyTargetNForDate(submittedDate);
    final plan =
        await planRepo.getOrCreatePlan(date: submittedDate, targetN: targetN);

    // 已在计划中（检查同题同日重复确认）
    if (await planRepo.isQuestionInPlan(
        planId: plan.id, questionId: questionId)) {
      return CapacityAvailable(plan.id);
    }

    // 有剩余容量：预留+补满
    if (!plan.isFull) {
      final nextOrder = await planRepo.getNextOrderIndex(plan.id);
      await planRepo.addMember(
        planId: plan.id,
        questionId: questionId,
        orderIndex: nextOrder,
      );

      // 补满到min(N, 合格数)（无需确认）
      await _backfillPlanToN(plan.id, submittedDate, targetN);

      // C保持不变（初始C=N，不会因为候选少而缩小）

      return CapacityAvailable(plan.id);
    }

    // 满额且未确认：返回需要确认
    if (!confirmed) {
      return CapacityFullNeedsConfirmation(plan.members.length, plan.capacityC);
    }

    // 满额但已确认：重检后扩容+补满
    final planRecheck = await planRepo.getPlan(submittedDate);
    if (planRecheck != null &&
        await planRepo.isQuestionInPlan(
            planId: planRecheck.id, questionId: questionId)) {
      // 已在计划中（同题重复确认），零扩容
      return CapacityAvailable(planRecheck.id);
    }

    // 1. 先扩容C = members.length + (预留1 + 补位数量)
    // 但不能提前知道补位数量，所以先扩容到members.length + 1
    // 最后再根据实际填充数量更新C

    // 2. 加入该题成员
    var nextOrder = await planRepo.getNextOrderIndex(plan.id);
    await planRepo.addMember(
      planId: plan.id,
      questionId: questionId,
      orderIndex: nextOrder++,
    );

    // 3. 填满到min(N, 合格数)
    await _backfillPlanToN(plan.id, submittedDate, targetN);

    // 4. 获取最终计划并设置C为实际成员数（只增长，不缩小）
    final finalPlan = await planRepo.getPlan(submittedDate);
    if (finalPlan != null) {
      final newC = finalPlan.members.length;
      // 只有当新成员数>原C时才更新（明确追加才增长）
      if (newC > plan.capacityC) {
        await (db.update(db.dailyPlans)
              ..where((p) => p.id.equals(finalPlan.id)))
            .write(DailyPlansCompanion(
          capacityC: Value(newC),
          updatedAt: Value(DateTime.now()),
        ));
      }
    }

    return CapacityAvailable(plan.id);
  }

  /// 补满计划到N
  Future<void> _backfillPlanToN(
    String planId,
    LearningDate date,
    int targetN,
  ) async {
    final plan = await planRepo.getPlan(date);
    if (plan == null) return;

    final remainingSlots = targetN - plan.members.length;
    if (remainingSlots <= 0) return;

    final excludeIds = plan.members.map((m) => m.questionId).toList();
    final candidates = await _getCandidateQuestions(date, excludeIds);

    var nextOrder = await planRepo.getNextOrderIndex(planId);
    for (int i = 0; i < remainingSlots && i < candidates.length; i++) {
      await planRepo.addMember(
        planId: planId,
        questionId: candidates[i],
        orderIndex: nextOrder++,
      );
    }
  }

  /// 获取候选题（排除不合格的）
  Future<List<String>> _getCandidateQuestions(
    LearningDate date,
    List<String> excludeIds,
  ) async {
    // 查询活跃题目及其周期
    final query = await db.customSelect('''
      SELECT DISTINCT q.id
      FROM mistake_questions q
      INNER JOIN review_cycles c ON q.id = c.question_id
      WHERE q.is_archived = 0
        AND q.deleted_at IS NULL
        AND c.is_active = 1
        AND c.k_level < 4
        AND c.due_date IS NOT NULL
        AND c.due_date <= ?
      ORDER BY c.due_date ASC, q.created_at ASC, q.id ASC
    ''', variables: [Variable.withString(date.value)]).get();

    final allCandidates = query.map((row) => row.data['id'] as String).toList();

    // 排除已在计划中的和今日已有事件/再错的
    final result = <String>[];
    for (final candidateId in allCandidates) {
      if (excludeIds.contains(candidateId)) continue;

      // 检查今日是否已有事件
      final todayEvents = await (db.select(db.reviewEvents)
            ..where((e) =>
                e.questionId.equals(candidateId) &
                e.learningDate.equals(date.value)))
          .get();
      if (todayEvents.isNotEmpty) continue;

      // 检查今日是否已再错
      final todayMarks = await (db.select(db.mistakeAgainMarks)
            ..where((m) =>
                m.questionId.equals(candidateId) &
                m.operationDate.equals(date.value)))
          .get();
      if (todayMarks.isNotEmpty) continue;

      result.add(candidateId);
    }

    return result;
  }

  /// 提交排期复习（事务集成）
  ///
  /// 原子操作：事件 + 周期更新 + 计划完成
  Future<SubmissionResult> submitScheduledReview({
    required String questionId,
    required ReviewResult result,
    required LearningDate submittedDate,
    required bool hasAnswer,
    required bool hasConfirmedVerification,
    required int expectedQuestionVersion,
    required String expectedCycleId,
    required int expectedCycleVersion,
    bool capacityConfirmed = false,
  }) async {
    return await db.transaction(() async {
      // 1. 先检查幂等性（同题同日已有成功事件）
      final existingEvents = await (db.select(db.reviewEvents)
            ..where((e) =>
                e.questionId.equals(questionId) &
                e.learningDate.equals(submittedDate.value)))
          .get();

      if (existingEvents.isNotEmpty) {
        final firstEvent = existingEvents.first;
        final existingDomainEvent = domain.ReviewEvent(
          questionId: firstEvent.questionId,
          cycleNumber: firstEvent.cycleNumber,
          learningDate: LearningDate.parse(firstEvent.learningDate),
          result: _parseResult(firstEvent.result),
          kLevelBefore: domain.KLevel.fromValue(firstEvent.kLevelBefore),
          kLevelAfter: domain.KLevel.fromValue(firstEvent.kLevelAfter),
          dueDateAfter: firstEvent.dueDateAfter != null
              ? LearningDate.parse(firstEvent.dueDateAfter!)
              : null,
        );
        return SubmissionDuplicate(existingDomainEvent);
      }

      // 2. 检查题目版本（先检查）和生命周期
      final question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .getSingleOrNull();

      if (question == null) {
        return SubmissionQuestionInactive(reason: 'Question not found');
      }

      // 先检查题目版本（归档/删除操作会递增version，旧版本卡片应先被版本拦截）
      if (question.version != expectedQuestionVersion) {
        return SubmissionStaleQuestion(
          expectedVersion: expectedQuestionVersion,
          actualVersion: question.version,
        );
      }

      // 再检查生命周期（已通过版本检查，但最新题目也可能归档/删除）
      if (question.isArchived) {
        return SubmissionQuestionInactive(reason: 'Question is archived');
      }
      if (question.deletedAt != null) {
        return SubmissionQuestionInactive(reason: 'Question is deleted');
      }

      // 3. 获取当前周期并检查真实周期id（问题5）
      final cycleRow = await (db.select(db.reviewCycles)
            ..where((c) =>
                c.questionId.equals(questionId) & c.isActive.equals(true)))
          .getSingleOrNull();

      if (cycleRow == null) {
        throw StateError('No active cycle for question $questionId');
      }

      // 检查周期id和版本匹配（旧卡校验）
      if (cycleRow.id != expectedCycleId) {
        return SubmissionStaleCycle(
          expectedId: expectedCycleId,
          actualId: cycleRow.id,
        );
      }

      // 检查周期版本
      if (cycleRow.version != expectedCycleVersion) {
        return SubmissionStaleCycle(
          expectedId: expectedCycleId,
          actualId: cycleRow.id,
        );
      }

      // 4. 检查今日再错标记（在周期版本检查之后）
      final mistakeAgainMarks = await (db.select(db.mistakeAgainMarks)
            ..where((m) =>
                m.questionId.equals(questionId) &
                m.operationDate.equals(submittedDate.value)))
          .get();

      if (mistakeAgainMarks.isNotEmpty) {
        // 今日再错后产生新周期，返回blocked
        return SubmissionBlockedByMistakeAgain(cycleRow.cycleNumber);
      }

      // 5. 检查k<4、due条件
      if (cycleRow.kLevel >= 4) {
        return SubmissionAlreadyMastered();
      }

      if (cycleRow.dueDate != null &&
          cycleRow.dueDate!.compareTo(submittedDate.value) > 0) {
        return SubmissionNotDueYet(
            dueDate: LearningDate.parse(cycleRow.dueDate!));
      }

      final currentCycle = domain.ReviewCycle(
        questionId: cycleRow.questionId,
        cycleNumber: cycleRow.cycleNumber,
        kLevel: domain.KLevel.fromValue(cycleRow.kLevel),
        dueDate: cycleRow.dueDate != null
            ? LearningDate.parse(cycleRow.dueDate!)
            : null,
        isActive: cycleRow.isActive,
        version: cycleRow.version,
      );

      // 6. 获取所有周期（领域服务需要）
      final allCycles = await _getAllCycles(questionId);

      // 7. 调用领域服务（已经过幂等性+生命周期+版本+再错+due/k检查）
      final domainResult = ReviewSubmissionService.submitScheduledReview(
        currentCycle: currentCycle,
        result: result,
        submittedDate: submittedDate,
        existingEvents: const [], // 已在事务开始检查幂等性
        allCycles: allCycles,
        hasAnswer: hasAnswer,
        hasConfirmedVerification: hasConfirmedVerification,
      );

      // 5. 处理结果
      if (domainResult is SubmissionSuccess) {
        // 5.1 容量检查（旧卡新日场景）
        final capacityResult = await checkCapacityAndReserve(
          questionId: questionId,
          submittedDate: submittedDate,
          confirmed: capacityConfirmed,
        );

        if (capacityResult is CapacityFullNeedsConfirmation) {
          // 满额需要确认，零写返回
          return SubmissionCapacityFull(
            currentCount: capacityResult.currentCount,
            capacityC: capacityResult.capacityC,
          );
        }

        final planId = (capacityResult as CapacityAvailable).planId;

        // 5.2 写入事件（问题8：使用真实cycleId）
        await db.into(db.reviewEvents).insert(ReviewEventsCompanion.insert(
              id: const Uuid().v4(),
              questionId: domainResult.event.questionId,
              cycleId: cycleRow.id, // 真实周期id
              cycleNumber: domainResult.event.cycleNumber,
              learningDate: domainResult.event.learningDate.value,
              result: _serializeResult(domainResult.event.result),
              kLevelBefore: domainResult.event.kLevelBefore.value,
              kLevelAfter: domainResult.event.kLevelAfter.value,
              dueDateAfter: Value(domainResult.event.dueDateAfter?.value),
              createdAt: DateTime.now(),
            ));

        // 故障注入点：事件写入后
        faultInjection.triggerAfterEventInsert();

        // 5.3 更新周期（问题5：条件更新检查行数）
        final updatedRows = await (db.update(db.reviewCycles)
              ..where((c) =>
                  c.id.equals(cycleRow.id) &
                  c.version.equals(cycleRow.version)))
            .write(ReviewCyclesCompanion(
          kLevel: Value(domainResult.updatedCycle.kLevel.value),
          dueDate: Value(domainResult.updatedCycle.dueDate?.value),
          version: Value(domainResult.updatedCycle.version),
          updatedAt: Value(DateTime.now()),
        ));

        // 故障注入点：周期更新后
        faultInjection.triggerAfterCycleUpdate();

        if (updatedRows == 0) {
          throw StateError(
              'Cycle version conflict: expected ${cycleRow.version}');
        }

        // 5.4 标记计划完成
        await planRepo.markMemberCompleted(
          planId: planId,
          questionId: questionId,
        );
      }

      return domainResult;
    });
  }

  /// 再次出错（新周期）
  ///
  /// 已完成：保留今日事件/完成身份
  /// 未完成：退出计划并补位（需要MistakeQuestionRepository支持）
  /// 注意：此方法不包含补位逻辑，由调用方（MistakeQuestionRepository）处理
  Future<void> markAsMistakeAgain({
    required String questionId,
    required LearningDate operationDate,
    bool skipPlanUpdate = false,
  }) async {
    await db.transaction(() async {
      // 1. 生命周期检查
      final question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .getSingleOrNull();

      if (question == null) {
        throw StateError('Question not found: $questionId');
      }
      if (question.isArchived) {
        throw StateError('Question is archived: $questionId');
      }
      if (question.deletedAt != null) {
        throw StateError('Question is deleted: $questionId');
      }

      // 2. 检查同日幂等
      final existingMark = await (db.select(db.mistakeAgainMarks)
            ..where((m) =>
                m.questionId.equals(questionId) &
                m.operationDate.equals(operationDate.value)))
          .getSingleOrNull();

      if (existingMark != null) {
        // 同日已再错，幂等返回
        return;
      }

      // 2. 检查今日计划状态（如果不跳过）
      if (!skipPlanUpdate) {
        final todayPlan = await planRepo.getPlan(operationDate);
        if (todayPlan != null) {
          final member = todayPlan.members
              .where((m) => m.questionId == questionId)
              .firstOrNull;
          final wasCompleted = member?.isCompleted ?? false;

          // 未完成则移出（已完成保留成员）
          if (!wasCompleted && member != null) {
            await planRepo.removeMember(
              planId: todayPlan.id,
              questionId: questionId,
            );
          }
        }
      }

      // 3. 获取并关闭旧周期
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

      // 4. 写入再错标记（提前写入以便验证事务回滚）
      await db
          .into(db.mistakeAgainMarks)
          .insert(MistakeAgainMarksCompanion.insert(
            id: const Uuid().v4(),
            questionId: questionId,
            operationDate: operationDate.value,
            newCycleNumber: oldCycle != null ? oldCycle.cycleNumber + 1 : 1,
            createdAt: DateTime.now(),
          ));

      // 故障注入点：再错操作写入后
      faultInjection.triggerAfterMistakeAgainInsert();

      // 5. 创建新周期
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
              dueDate:
                  r.dueDate != null ? LearningDate.parse(r.dueDate!) : null,
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
