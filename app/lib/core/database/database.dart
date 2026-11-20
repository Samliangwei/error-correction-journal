import 'package:drift/drift.dart';

// Conditional imports  
import 'database_native.dart' if (dart.library.html) 'database_web.dart';
import '../constants/app_constants.dart';

part 'database.g.dart';

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

@DriftDatabase(tables: [ErrorQuestions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => AppConstants.databaseVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {},
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() => openDatabaseConnection());
}
