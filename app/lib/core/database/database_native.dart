import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'app_constants.dart';

Future<QueryExecutor> openDatabaseConnection() async {
  if (Platform.isAndroid) {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
  }

  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, AppConstants.databaseName));
  
  return NativeDatabase.createInBackground(file);
}
