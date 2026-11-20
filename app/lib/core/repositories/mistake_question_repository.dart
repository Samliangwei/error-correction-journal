/// 错题Repository（生命周期管理）
library;

import 'package:drift/drift.dart';
import '../database/database.dart';
import '../scheduling/learning_date.dart';
import 'daily_plan_repository.dart';
import 'review_repository.dart';
import 'settings_repository.dart';

/// 错题生命周期状态
enum QuestionLifecycle {
  active, // 活跃
  archived, // 归档
  deleted, // 已删除（回收站）
}

class MistakeQuestionRepository {
  final AppDatabase db;
  final DailyPlanRepository planRepo;
  final ReviewRepository reviewRepo;
  final SettingsRepository settingsRepo;

  MistakeQuestionRepository(
    this.db,
    this.planRepo,
    this.reviewRepo,
    this.settingsRepo,
  );

  /// 再错处理（含补位）
  Future<void> markAsMistakeAgainWithBackfill({
    required String questionId,
    required LearningDate operationDate,
  }) async {
    await db.transaction(() async {
      // 1. 调用reviewRepo再错（移出计划）
      await reviewRepo.markAsMistakeAgain(
        questionId: questionId,
        operationDate: operationDate,
        skipPlanUpdate: false,
      );

      // 2. 补位
      final plan = await planRepo.getPlan(operationDate);
      if (plan != null) {
        await _backfillPlan(plan.id, operationDate);
      }
    });
  }

  /// 归档题目（事务）
  ///
  /// 已完成：保留计划成员
  /// 未完成：移出计划并补位
  Future<void> archiveQuestion({
    required String questionId,
    required LearningDate operationDate,
  }) async {
    await db.transaction(() async {
      // 1. 更新题目状态
      await (db.update(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .write(MistakeQuestionsCompanion(
        isArchived: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));

      // 2. 检查今日计划
      final todayPlan = await planRepo.getPlan(operationDate);
      if (todayPlan != null) {
        final member = todayPlan.members
            .where((m) => m.questionId == questionId)
            .firstOrNull;

        if (member != null && !member.isCompleted) {
          // 未完成：移出并补位
          await planRepo.removeMember(
            planId: todayPlan.id,
            questionId: questionId,
          );

          // 补位
          await _backfillPlan(todayPlan.id, operationDate);
        }
        // 已完成：保留成员（不操作）
      }
    });
  }

  /// 删除题目（进回收站，事务）
  ///
  /// 无论是否完成，均移出计划并补位
  Future<void> deleteQuestion({
    required String questionId,
    required LearningDate operationDate,
  }) async {
    await db.transaction(() async {
      // 1. 软删除
      await (db.update(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .write(MistakeQuestionsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ));

      // 2. 移出今日计划（无论是否完成）
      final todayPlan = await planRepo.getPlan(operationDate);
      if (todayPlan != null) {
        final member = todayPlan.members
            .where((m) => m.questionId == questionId)
            .firstOrNull;

        if (member != null) {
          await planRepo.removeMember(
            planId: todayPlan.id,
            questionId: questionId,
          );

          // 补位
          await _backfillPlan(todayPlan.id, operationDate);
        }
      }
    });
  }

  /// 恢复题目（从回收站/归档，事务）
  ///
  /// 不重建旧计划，不绕过题日幂等
  Future<void> restoreQuestion({
    required String questionId,
  }) async {
    await db.transaction(() async {
      await (db.update(db.mistakeQuestions)
            ..where((q) => q.id.equals(questionId)))
          .write(MistakeQuestionsCompanion(
        isArchived: const Value(false),
        deletedAt: const Value(null), // 清除deletedAt
        updatedAt: Value(DateTime.now()),
      ));

      // 不重建计划成员（恢复不自动加回计划）
      // 题日幂等约束由数据库保证，恢复后重复提交仍会被拒绝
    });
  }

  /// 补位逻辑：从候选题中选择并填充
  ///
  /// 候选条件：
  /// - 活跃（未归档、未删除）
  /// - 有活动周期
  /// - 今日到期（due <= today）
  /// - 未掌握（k < 4）
  /// - 今日无有效事件
  /// - 今日未再错
  /// - 不在今日计划中
  ///
  /// 排序：due ASC, createdAt ASC, id ASC
  /// 填充：不超过C
  Future<void> _backfillPlan(String planId, LearningDate date) async {
    // 1. 获取计划容量
    final plan = await planRepo.getPlan(date);
    if (plan == null) return;

    final remainingSlots = plan.capacityC - plan.members.length;
    if (remainingSlots <= 0) return;

    // 2. 查询候选题
    final candidates = await _getCandidateQuestions(
        date, plan.members.map((m) => m.questionId).toList());

    // 3. 填充
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
      LEFT JOIN review_events e ON q.id = e.question_id AND e.learning_date = ?
      LEFT JOIN mistake_again_marks m ON q.id = m.question_id AND m.operation_date = ?
      WHERE q.is_archived = 0
        AND q.deleted_at IS NULL
        AND c.is_active = 1
        AND c.k_level < 4
        AND (c.due_date IS NULL OR c.due_date <= ?)
        AND e.id IS NULL
        AND m.id IS NULL
      ORDER BY c.due_date ASC, q.created_at ASC, q.id ASC
    ''', variables: [
      Variable.withString(date.value),
      Variable.withString(date.value),
      Variable.withString(date.value),
    ]).get();

    final allCandidates = query.map((row) => row.read<String>('id')).toList();

    // 排除已在计划中的
    return allCandidates.where((id) => !excludeIds.contains(id)).toList();
  }

  /// 创建或填充计划（首次创建时填满）
  Future<void> ensurePlanFilled({
    required LearningDate date,
    String? reserveForQuestionId,
  }) async {
    await db.transaction(() async {
      // 应用待生效更改（如果到期）
      await settingsRepo.applyPendingIfDue(date);

      // 获取该日期应使用的N
      final targetN = await settingsRepo.getDailyTargetNForDate(date);
      final plan = await planRepo.getOrCreatePlan(date: date, targetN: targetN);

      // 如果需要预留旧卡
      if (reserveForQuestionId != null) {
        final alreadyIn = await planRepo.isQuestionInPlan(
          planId: plan.id,
          questionId: reserveForQuestionId,
        );

        if (!alreadyIn && !plan.isFull) {
          final nextOrder = await planRepo.getNextOrderIndex(plan.id);
          await planRepo.addMember(
            planId: plan.id,
            questionId: reserveForQuestionId,
            orderIndex: nextOrder,
          );
        }
      }

      // 填充剩余容量
      await _backfillPlan(plan.id, date);
    });
  }
}
