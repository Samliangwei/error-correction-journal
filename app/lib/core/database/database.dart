import 'package:drift/drift.dart';

// Conditional imports
import 'database_native.dart' if (dart.library.html) 'database_web.dart';

part 'database.g.dart';

// 旧表（保留兼容）
class ErrorQuestions extends Table {
  TextColumn get id => text()();
  TextColumn get subject => text().withLength(min: 1, max: 50)();
  TextColumn get question => text()();
  TextColumn get myAnswer => text()();
  TextColumn get correctAnswer => text()();
  TextColumn get reason => text()();
  TextColumn get masteryStatus => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 新表：错题（mistake questions）
class MistakeQuestions extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get subject => text().withLength(min: 1, max: 50)();
  TextColumn get questionText => text().withLength(max: 5000)();
  TextColumn get correctAnswer => text().withLength(max: 5000).nullable()();
  TextColumn get myThinking => text().withLength(max: 3000).nullable()();
  TextColumn get errorNotes => text().withLength(max: 1000).nullable()();
  DateTimeColumn get mistakeDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get formalizedAt => dateTime().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

// 复习周期
class ReviewCycles extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get questionId => text().customConstraint(
      'NOT NULL REFERENCES mistake_questions(id) ON DELETE CASCADE')();
  IntColumn get cycleNumber => integer()();
  IntColumn get kLevel => integer()(); // 0-4
  TextColumn get dueDate => text().nullable()(); // yyyy-MM-dd
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 复习事件
class ReviewEvents extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get questionId => text()();
  TextColumn get cycleId => text()();
  IntColumn get cycleNumber => integer()();
  TextColumn get learningDate => text()(); // yyyy-MM-dd
  TextColumn get result => text()(); // notKnow/fuzzy/know
  IntColumn get kLevelBefore => integer()();
  IntColumn get kLevelAfter => integer()();
  TextColumn get dueDateAfter => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {questionId, learningDate}, // 题+日唯一约束
      ];
}

// 再错标记（幂等性）
class MistakeAgainMarks extends Table {
  TextColumn get id => text()();
  TextColumn get questionId => text()();
  TextColumn get operationDate => text()(); // yyyy-MM-dd
  IntColumn get newCycleNumber => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {questionId, operationDate}, // 同题同日幂等
      ];
}

// 每日计划
class DailyPlans extends Table {
  TextColumn get id => text()();
  TextColumn get learningDate => text()(); // yyyy-MM-dd
  IntColumn get targetN => integer()(); // 目标题数（快照）
  IntColumn get capacityC => integer()(); // 当前容量
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {learningDate}, // 每日唯一
      ];
}

// 计划成员
class DailyPlanMembers extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text().customConstraint(
      'NOT NULL REFERENCES daily_plans(id) ON DELETE CASCADE')();
  TextColumn get questionId => text()();
  IntColumn get orderIndex => integer()(); // 排序
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSkipped => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {planId, questionId}, // 计划+题目唯一
      ];
}

// 设置
class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dailyTargetN => integer().withDefault(const Constant(20))();
  IntColumn get dailyTargetPendingN => integer().nullable()();
  TextColumn get dailyTargetEffectiveFrom => text().nullable()(); // yyyy-MM-dd
  DateTimeColumn get dailyTargetUpdatedAt => dateTime().nullable()();
  DateTimeColumn get lastBackupAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [
  ErrorQuestions, // 旧表保留
  MistakeQuestions,
  ReviewCycles,
  ReviewEvents,
  MistakeAgainMarks,
  DailyPlans,
  DailyPlanMembers,
  Settings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3; // 升级到v3

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // 创建默认设置
        await into(settings).insert(SettingsCompanion.insert(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1 && to >= 2) {
          // v1→v2: 创建新表
          await m.createTable(mistakeQuestions);
          await m.createTable(reviewCycles);
          await m.createTable(reviewEvents);
          await m.createTable(mistakeAgainMarks);
          await m.createTable(dailyPlans);
          await m.createTable(dailyPlanMembers);
          await m.createTable(settings);

          // 创建默认设置
          await into(settings).insert(SettingsCompanion.insert(
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
        }

        if (from == 2 && to == 3) {
          // v2→v3: 添加唯一约束 + settings pending字段 + 业务去重
          // 1. 重建daily_plan_members表
          await customStatement('''
            CREATE TABLE daily_plan_members_new (
              id TEXT NOT NULL PRIMARY KEY,
              plan_id TEXT NOT NULL REFERENCES daily_plans(id) ON DELETE CASCADE,
              question_id TEXT NOT NULL,
              order_index INTEGER NOT NULL,
              is_completed INTEGER NOT NULL DEFAULT 0,
              is_skipped INTEGER NOT NULL DEFAULT 0,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              UNIQUE(plan_id, question_id)
            )
          ''');

          // 业务键确定性合并：
          // - 完成优先：MAX(is_completed)保持已完成身份
          // - 最早顺序：MIN(order_index)保留合理顺序
          // - 稳定id：MIN(id)选择字典序最小的id
          // - 保留最早created_at和最新updated_at
          await customStatement('''
            INSERT INTO daily_plan_members_new (
              id, plan_id, question_id, order_index, 
              is_completed, is_skipped, created_at, updated_at
            )
            SELECT 
              MIN(id) as id,
              plan_id,
              question_id,
              MIN(order_index) as order_index,
              MAX(is_completed) as is_completed,
              MAX(is_skipped) as is_skipped,
              MIN(created_at) as created_at,
              MAX(updated_at) as updated_at
            FROM daily_plan_members
            GROUP BY plan_id, question_id
          ''');

          await customStatement('DROP TABLE daily_plan_members');
          await customStatement(
              'ALTER TABLE daily_plan_members_new RENAME TO daily_plan_members');

          // 2. 添加settings pending字段
          await customStatement(
              'ALTER TABLE settings ADD COLUMN daily_target_pending_n INTEGER');
          await customStatement(
              'ALTER TABLE settings ADD COLUMN daily_target_effective_from TEXT');
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() => openDatabaseConnection());
}
