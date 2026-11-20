import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

import 'app_constants.dart';

Future<QueryExecutor> openDatabaseConnection() async {
  final db = await WasmDatabase.open(
    databaseName: AppConstants.databaseName,
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.dart.js'),
  );
  return db.resolvedExecutor;
}
