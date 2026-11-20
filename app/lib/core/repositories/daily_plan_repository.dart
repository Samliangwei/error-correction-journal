/// 每日计划Repository
library;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../scheduling/learning_date.dart';

/// 每日计划成员（领域模型）
class PlanMember {
  final String questionId;
  final int orderIndex;
  final bool isCompleted;
  final bool isSkipped;

  PlanMember({
    required this.questionId,
    required this.orderIndex,
    this.isCompleted = false,
    this.isSkipped = false,
  });
}

/// 每日计划（领域模型）
class DailyPlanModel {
  final String id;
  final LearningDate learningDate;
  final int targetN;
  final int capacityC;
  final List<PlanMember> members;

  DailyPlanModel({
    required this.id,
    required this.learningDate,
    required this.targetN,
    required this.capacityC,
    required this.members,
  });

  int get completedCount => members.where((m) => m.isCompleted).length;
  int get remainingCapacity => capacityC - members.length;
  bool get isFull => members.length >= capacityC;
}

class DailyPlanRepository {
  final AppDatabase db;

  DailyPlanRepository(this.db);

  /// 获取或创建今日计划
  Future<DailyPlanModel> getOrCreatePlan({
    required LearningDate date,
    required int targetN,
  }) async {
    // 查找已有计划
    final existingPlan = await (db.select(db.dailyPlans)
          ..where((p) => p.learningDate.equals(date.value)))
        .getSingleOrNull();

    if (existingPlan != null) {
      final members = await _getMembers(existingPlan.id);
      return DailyPlanModel(
        id: existingPlan.id,
        learningDate: date,
        targetN: existingPlan.targetN,
        capacityC: existingPlan.capacityC,
        members: members,
      );
    }

    // 创建新计划：C初始=N
    final planId = const Uuid().v4();
    await db.into(db.dailyPlans).insert(DailyPlansCompanion.insert(
          id: planId,
          learningDate: date.value,
          targetN: targetN,
          capacityC: targetN, // C初始=N
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

    return DailyPlanModel(
      id: planId,
      learningDate: date,
      targetN: targetN,
      capacityC: targetN,
      members: [],
    );
  }

  /// 添加成员到计划（预留）
  Future<void> addMember({
    required String planId,
    required String questionId,
    required int orderIndex,
  }) async {
    await db.into(db.dailyPlanMembers).insert(DailyPlanMembersCompanion.insert(
          id: const Uuid().v4(),
          planId: planId,
          questionId: questionId,
          orderIndex: orderIndex,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
  }

  /// 标记成员完成
  Future<void> markMemberCompleted({
    required String planId,
    required String questionId,
  }) async {
    await (db.update(db.dailyPlanMembers)
          ..where((m) =>
              m.planId.equals(planId) & m.questionId.equals(questionId)))
        .write(DailyPlanMembersCompanion(
      isCompleted: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// 移除成员（用于归档/删除补位）
  Future<void> removeMember({
    required String planId,
    required String questionId,
  }) async {
    await (db.delete(db.dailyPlanMembers)
          ..where((m) =>
              m.planId.equals(planId) & m.questionId.equals(questionId)))
        .go();
  }

  /// 检查题目是否在计划中
  Future<bool> isQuestionInPlan({
    required String planId,
    required String questionId,
  }) async {
    final member = await (db.select(db.dailyPlanMembers)
          ..where((m) =>
              m.planId.equals(planId) & m.questionId.equals(questionId)))
        .getSingleOrNull();
    return member != null;
  }

  /// 获取计划成员
  Future<List<PlanMember>> _getMembers(String planId) async {
    final rows = await (db.select(db.dailyPlanMembers)
          ..where((m) => m.planId.equals(planId))
          ..orderBy([(m) => OrderingTerm.asc(m.orderIndex)]))
        .get();

    return rows
        .map((r) => PlanMember(
              questionId: r.questionId,
              orderIndex: r.orderIndex,
              isCompleted: r.isCompleted,
              isSkipped: r.isSkipped,
            ))
        .toList();
  }

  /// 获取下一个可用的orderIndex
  Future<int> getNextOrderIndex(String planId) async {
    final maxOrder = await (db.selectOnly(db.dailyPlanMembers)
          ..addColumns([db.dailyPlanMembers.orderIndex.max()])
          ..where(db.dailyPlanMembers.planId.equals(planId)))
        .map((row) => row.read(db.dailyPlanMembers.orderIndex.max()))
        .getSingleOrNull();

    return (maxOrder ?? -1) + 1;
  }

  /// 获取计划
  Future<DailyPlanModel?> getPlan(LearningDate date) async {
    final plan = await (db.select(db.dailyPlans)
          ..where((p) => p.learningDate.equals(date.value)))
        .getSingleOrNull();

    if (plan == null) return null;

    final members = await _getMembers(plan.id);
    return DailyPlanModel(
      id: plan.id,
      learningDate: date,
      targetN: plan.targetN,
      capacityC: plan.capacityC,
      members: members,
    );
  }
}
