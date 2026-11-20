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

  /// 检查容量并预留（旧卡新日）
  Future<CapacityCheckResult> checkCapacityAndReserve({
    required String questionId,
    required LearningDate submittedDate,
    required bool confirmed,
  }) async {
    final targetN = await settingsRepo.getDailyTargetN();
    final plan = await planRepo.getOrCreatePlan(date: submittedDate, targetN: targetN);

    // 已在计划中
    if (await planRepo.isQuestionInPlan(planId: plan.id, questionId: questionId)) {
      return CapacityAvailable(plan.id);
    }

    // 有剩余容量：直接预留
    if (!plan.isFull) {
      final nextOrder = await planRepo.getNextOrderIndex(plan.id);
      await planRepo.addMember(
        planId: plan.id,
        questionId: questionId,
        orderIndex: nextOrder,
      );
      return CapacityAvailable(plan.id);
    }

    // 满额且未确认：返回需要确认
    if (!confirmed) {
      return CapacityFullNeedsConfirmation(plan.members.length, plan.capacityC);
    }

    // 满额但已确认：重检后扩容
    final planRecheck = await planRepo.getPlan(submittedDate);
    if (planRecheck == null || planRecheck.isFull) {
      // 仍满额，扩容加入
      final nextOrder = await planRepo.getNextOrderIndex(plan.id);
      await planRepo.addMember(
        planId: plan.id,
        questionId: questionId,
        orderIndex: nextOrder,
      );
      return CapacityAvailable(plan.id);
    }

    // 重检后有空位，直接预留
    final nextOrder = await planRepo.getNextOrderIndex(plan.id);
    await planRepo.addMember(
      planId: plan.id,
      questionId: questionId,
      orderIndex: nextOrder,
    );
    return CapacityAvailable(plan.id);
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
    bool capacityConfirmed = false,
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

        // 5.2 写入事件
        await db.into(db.reviewEvents).insert(ReviewEventsCompanion.insert(
              id: const Uuid().v4(),
              questionId: domainResult.event.questionId,
              cycleId: const Uuid().v4(),
              cycleNumber: domainResult.event.cycleNumber,
              learningDate: domainResult.event.learningDate.value,
              result: _serializeResult(domainResult.event.result),
              kLevelBefore: domainResult.event.kLevelBefore.value,
              kLevelAfter: domainResult.event.kLevelAfter.value,
              dueDateAfter: Value(domainResult.event.dueDateAfter?.value),
              createdAt: DateTime.now(),
            ));

        // 5.3 更新周期
        await (db.update(db.reviewCycles)
              ..where((c) =>
                  c.questionId.equals(questionId) & c.isActive.equals(true)))
            .write(ReviewCyclesCompanion(
          kLevel: Value(domainResult.updatedCycle.kLevel.value),
          dueDate: Value(domainResult.updatedCycle.dueDate?.value),
          version: Value(domainResult.updatedCycle.version),
          updatedAt: Value(DateTime.now()),
        ));

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

      // 3. 关闭旧周期
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

      // 4. 创建新周期
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

      // 5. 记录再错标记
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
