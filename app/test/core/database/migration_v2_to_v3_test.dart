import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/core/database/database.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('数据库迁移 v2→v3', () {
    late Directory tempDir;
    late String dbPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('migration_test_');
      dbPath = p.join(tempDir.path, 'test.db');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('v2→v3: 业务键去重，完成优先，保留顺序，外键完整', () async {
      // ===== 阶段1: 创建v2 schema并写入测试数据 =====
      final v2DbRaw = sqlite3.open(dbPath);

      // 创建v2表结构
      v2DbRaw.execute('''
        CREATE TABLE mistake_questions (
          id TEXT NOT NULL PRIMARY KEY,
          subject TEXT NOT NULL,
          question_text TEXT NOT NULL,
          correct_answer TEXT,
          my_thinking TEXT,
          error_notes TEXT,
          mistake_date INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          formalized_at INTEGER,
          is_archived INTEGER NOT NULL DEFAULT 0,
          deleted_at INTEGER,
          version INTEGER NOT NULL DEFAULT 1
        )
      ''');

      v2DbRaw.execute('''
        CREATE TABLE review_cycles (
          id TEXT NOT NULL PRIMARY KEY,
          question_id TEXT NOT NULL REFERENCES mistake_questions(id) ON DELETE CASCADE,
          cycle_number INTEGER NOT NULL,
          k_level INTEGER NOT NULL,
          due_date TEXT,
          is_active INTEGER NOT NULL DEFAULT 1,
          version INTEGER NOT NULL DEFAULT 1,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      v2DbRaw.execute('''
        CREATE TABLE review_events (
          id TEXT NOT NULL PRIMARY KEY,
          question_id TEXT NOT NULL,
          cycle_id TEXT NOT NULL,
          cycle_number INTEGER NOT NULL,
          learning_date TEXT NOT NULL,
          result TEXT NOT NULL,
          k_level_before INTEGER NOT NULL,
          k_level_after INTEGER NOT NULL,
          due_date_after TEXT,
          created_at INTEGER NOT NULL,
          UNIQUE(question_id, learning_date)
        )
      ''');

      v2DbRaw.execute('''
        CREATE TABLE daily_plans (
          id TEXT NOT NULL PRIMARY KEY,
          learning_date TEXT NOT NULL UNIQUE,
          target_n INTEGER NOT NULL,
          capacity_c INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // v2版本没有UNIQUE约束，允许重复
      v2DbRaw.execute('''
        CREATE TABLE daily_plan_members (
          id TEXT NOT NULL PRIMARY KEY,
          plan_id TEXT NOT NULL REFERENCES daily_plans(id) ON DELETE CASCADE,
          question_id TEXT NOT NULL,
          order_index INTEGER NOT NULL,
          is_completed INTEGER NOT NULL DEFAULT 0,
          is_skipped INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      v2DbRaw.execute('''
        CREATE TABLE settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          daily_target_n INTEGER NOT NULL DEFAULT 20,
          last_backup_at INTEGER,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // 设置user_version=2
      v2DbRaw.execute('PRAGMA user_version = 2');

      // 写入测试数据
      final now = DateTime.now().millisecondsSinceEpoch;

      // 题目
      v2DbRaw.execute('''
        INSERT INTO mistake_questions VALUES
        ('q1', 'Math', 'Q1', 'A1', NULL, NULL, $now, $now, $now, NULL, 0, NULL, 1),
        ('q2', 'Math', 'Q2', 'A2', NULL, NULL, $now, $now, $now, NULL, 0, NULL, 1)
      ''');

      // 周期
      v2DbRaw.execute('''
        INSERT INTO review_cycles VALUES
        ('c1', 'q1', 1, 0, '2026-11-21', 1, 1, $now, $now),
        ('c2', 'q2', 1, 0, '2026-11-21', 1, 1, $now, $now)
      ''');

      // 事件
      v2DbRaw.execute('''
        INSERT INTO review_events VALUES
        ('e1', 'q1', 'c1', 1, '2026-11-20', 'know', 0, 1, '2026-11-24', $now)
      ''');

      // 计划
      v2DbRaw.execute('''
        INSERT INTO daily_plans VALUES
        ('plan1', '2026-11-20', 20, 20, $now, $now)
      ''');

      // 重复成员：q1有3条记录（不同UUID，相同plan_id+question_id）
      // - member1: 未完成，order=5，早创建
      // - member2: 已完成，order=10，晚创建
      // - member3: 未完成，order=3，中间创建
      // 预期合并后：完成优先→已完成，最早顺序→order=3，稳定id→member1
      v2DbRaw.execute('''
        INSERT INTO daily_plan_members VALUES
        ('member1', 'plan1', 'q1', 5, 0, 0, ${now - 3000}, ${now - 1000}),
        ('member2', 'plan1', 'q1', 10, 1, 0, ${now - 1000}, $now),
        ('member3', 'plan1', 'q1', 3, 0, 0, ${now - 2000}, ${now - 500})
      ''');

      // q2无重复
      v2DbRaw.execute('''
        INSERT INTO daily_plan_members VALUES
        ('member4', 'plan1', 'q2', 15, 0, 0, $now, $now)
      ''');

      // 设置
      v2DbRaw.execute('''
        INSERT INTO settings (daily_target_n, created_at, updated_at)
        VALUES (20, $now, $now)
      ''');

      v2DbRaw.dispose();

      // ===== 阶段2: 用AppDatabase打开，触发v2→v3升级 =====
      final v3Db = AppDatabase.forTesting(NativeDatabase(File(dbPath)));

      // ===== 阶段3: 验证迁移结果 =====

      // 1. 验证q1去重：只剩1条
      final q1Members = await (v3Db.select(v3Db.dailyPlanMembers)
            ..where((m) =>
                m.planId.equals('plan1') & m.questionId.equals('q1')))
          .get();
      expect(q1Members.length, 1, reason: 'q1应该去重为1条记录');

      final q1Member = q1Members.first;
      // 完成优先：应该是已完成
      expect(q1Member.isCompleted, true, reason: '完成优先：保持已完成身份');
      // 最早顺序：MIN(order_index)=3
      expect(q1Member.orderIndex, 3, reason: '保留最早顺序order=3');
      // 稳定id：MIN(id)='member1'
      expect(q1Member.id, 'member1', reason: '稳定id选择字典序最小');
      // 最早created_at (Drift存储为微秒)
      expect(q1Member.createdAt.millisecondsSinceEpoch, (now - 3000) * 1000,
          reason: '保留最早创建时间');
      // 最新updated_at (Drift存储为微秒)
      expect(q1Member.updatedAt.millisecondsSinceEpoch, now * 1000,
          reason: '保留最新更新时间');

      // 2. 验证q2未受影响
      final q2Members = await (v3Db.select(v3Db.dailyPlanMembers)
            ..where((m) =>
                m.planId.equals('plan1') & m.questionId.equals('q2')))
          .get();
      expect(q2Members.length, 1, reason: 'q2应该保持1条');
      expect(q2Members.first.id, 'member4');

      // 3. 验证计划容量C保持一致
      final plan = await (v3Db.select(v3Db.dailyPlans)
            ..where((p) => p.id.equals('plan1')))
          .getSingle();
      expect(plan.capacityC, 20, reason: '计划容量应保持20');

      // 4. 验证外键和关联完整
      final questions = await v3Db.select(v3Db.mistakeQuestions).get();
      expect(questions.length, 2, reason: '题目应保持2个');

      final cycles = await v3Db.select(v3Db.reviewCycles).get();
      expect(cycles.length, 2, reason: '周期应保持2个');

      final events = await v3Db.select(v3Db.reviewEvents).get();
      expect(events.length, 1, reason: '事件应保持1个');

      // 5. 验证settings字段迁移
      final settings = await v3Db.select(v3Db.settings).getSingle();
      expect(settings.dailyTargetN, 20);
      // 新增的pending字段应为null
      expect(settings.dailyTargetPendingN, null);
      expect(settings.dailyTargetEffectiveFrom, null);

      await v3Db.close();

      // ===== 阶段4: 再次重开，验证迁移幂等性 =====
      final v3DbReopened = AppDatabase.forTesting(NativeDatabase(File(dbPath)));

      final q1MembersReopened = await (v3DbReopened.select(
              v3DbReopened.dailyPlanMembers)
            ..where((m) =>
                m.planId.equals('plan1') & m.questionId.equals('q1')))
          .get();
      expect(q1MembersReopened.length, 1, reason: '重开后q1仍为1条');
      expect(q1MembersReopened.first.isCompleted, true, reason: '重开后仍保持已完成');

      // ===== 阶段5: 验证新的重复插入被UNIQUE约束拒绝 =====
      try {
        await v3DbReopened.into(v3DbReopened.dailyPlanMembers).insert(
              DailyPlanMembersCompanion.insert(
                id: 'duplicate-attempt',
                planId: 'plan1',
                questionId: 'q1', // 与已有记录重复
                orderIndex: 99,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
        fail('应该因UNIQUE约束失败');
      } catch (e) {
        expect(e.toString(), contains('UNIQUE constraint'),
            reason: '新的重复插入应被UNIQUE约束拒绝');
      }

      await v3DbReopened.close();
    });
  });
}
