import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/core/database/database.dart';
import 'package:error_journal/core/repositories/daily_plan_repository.dart';
import 'package:error_journal/core/repositories/settings_repository.dart';
import 'package:error_journal/core/scheduling/learning_date.dart';

void main() {
  late AppDatabase db;
  late DailyPlanRepository repo;
  late SettingsRepository settingsRepo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DailyPlanRepository(db);
    settingsRepo = SettingsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DailyPlanRepository - 容量管理', () {
    test('创建计划：C初始=N（默认20）', () async {
      final date = LearningDate.parse('2026-11-20');
      final n = await settingsRepo.getDailyTargetN();
      expect(n, 20); // 默认

      final plan = await repo.getOrCreatePlan(date: date, targetN: n);

      expect(plan.targetN, 20);
      expect(plan.capacityC, 20); // C初始=N
      expect(plan.members.length, 0);
      expect(plan.isFull, false);
    });

    test('N必须5-50，边界与超出范围', () async {
      // 边界接受
      await settingsRepo.setDailyTargetN(5);
      expect(await settingsRepo.getDailyTargetN(), 5);

      await settingsRepo.setDailyTargetN(50);
      expect(await settingsRepo.getDailyTargetN(), 50);

      // 超出拒绝
      await expectLater(() => settingsRepo.setDailyTargetN(2), throwsArgumentError);
      await expectLater(() => settingsRepo.setDailyTargetN(3), throwsArgumentError);
      await expectLater(() => settingsRepo.setDailyTargetN(4), throwsArgumentError);
      await expectLater(() => settingsRepo.setDailyTargetN(51), throwsArgumentError);
    });

    test('添加成员到计划，按orderIndex排序', () async {
      final date = LearningDate.parse('2026-11-20');
      final plan = await repo.getOrCreatePlan(date: date, targetN: 20);

      await repo.addMember(planId: plan.id, questionId: 'q1', orderIndex: 0);
      await repo.addMember(planId: plan.id, questionId: 'q2', orderIndex: 1);

      final updated = await repo.getPlan(date);
      expect(updated!.members.length, 2);
      expect(updated.members[0].questionId, 'q1');
      expect(updated.members[1].questionId, 'q2');
    });

    test('标记成员完成', () async {
      final date = LearningDate.parse('2026-11-20');
      final plan = await repo.getOrCreatePlan(date: date, targetN: 20);
      await repo.addMember(planId: plan.id, questionId: 'q1', orderIndex: 0);

      await repo.markMemberCompleted(planId: plan.id, questionId: 'q1');

      final updated = await repo.getPlan(date);
      expect(updated!.members[0].isCompleted, true);
      expect(updated.completedCount, 1);
    });

    test('完成不释放容量', () async {
      final date = LearningDate.parse('2026-11-20');
      final plan = await repo.getOrCreatePlan(date: date, targetN: 5);

      for (int i = 0; i < 5; i++) {
        await repo.addMember(planId: plan.id, questionId: 'q$i', orderIndex: i);
      }

      // 满额
      final full = await repo.getPlan(date);
      expect(full!.isFull, true);

      // 完成2个
      await repo.markMemberCompleted(planId: plan.id, questionId: 'q0');
      await repo.markMemberCompleted(planId: plan.id, questionId: 'q1');

      // 仍满额（完成不释放）
      final afterComplete = await repo.getPlan(date);
      expect(afterComplete!.members.length, 5);
      expect(afterComplete.isFull, true);
      expect(afterComplete.completedCount, 2);
    });

    test('移除成员（归档/删除补位）', () async {
      final date = LearningDate.parse('2026-11-20');
      final plan = await repo.getOrCreatePlan(date: date, targetN: 5);

      await repo.addMember(planId: plan.id, questionId: 'q1', orderIndex: 0);
      await repo.addMember(planId: plan.id, questionId: 'q2', orderIndex: 1);
      await repo.addMember(planId: plan.id, questionId: 'q3', orderIndex: 2);

      // 移除q2
      await repo.removeMember(planId: plan.id, questionId: 'q2');

      final updated = await repo.getPlan(date);
      expect(updated!.members.length, 2);
      expect(updated.members.map((m) => m.questionId).toList(), ['q1', 'q3']);
    });

    test('检查题目是否在计划中', () async {
      final date = LearningDate.parse('2026-11-20');
      final plan = await repo.getOrCreatePlan(date: date, targetN: 20);
      await repo.addMember(planId: plan.id, questionId: 'q1', orderIndex: 0);

      expect(await repo.isQuestionInPlan(planId: plan.id, questionId: 'q1'), true);
      expect(await repo.isQuestionInPlan(planId: plan.id, questionId: 'q2'), false);
    });
  });
}
