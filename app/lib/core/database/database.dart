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
  TextColumn get questionId => text()
      .customConstraint('NOT NULL REFERENCES mistake_questions(id) ON DELETE CASCADE')();
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
  TextColumn get planId => text()
      .customConstraint('NOT NULL REFERENCES daily_plans(id) ON DELETE CASCADE')();
  TextColumn get questionId => text()();
  IntColumn get orderIndex => integer()(); // 排序
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSkipped => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 设置
class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dailyTargetN => integer().withDefault(const Constant(20))();
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
  int get schemaVersion => 2; // 从1升级到2

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
        if (from == 1 && to == 2) {
          // 创建新表
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

          // 迁移旧数据（如果需要）
          // 暂时保留旧表不动，新功能使用新表
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() => openDatabaseConnection());
}
