/// 设置Repository
library;

import 'package:drift/drift.dart';
import '../database/database.dart';

class SettingsRepository {
  final AppDatabase db;

  SettingsRepository(this.db);

  /// 获取每日目标N（默认20）
  Future<int> getDailyTargetN() async {
    final settings = await _getOrCreateSettings();
    return settings.dailyTargetN;
  }

  /// 设置每日目标N（5-50，次日生效）
  Future<void> setDailyTargetN(int n) async {
    if (n < 5 || n > 50) {
      throw ArgumentError('Daily target N must be between 5 and 50');
    }

    final settings = await _getOrCreateSettings();
    await (db.update(db.settings)..where((s) => s.id.equals(settings.id)))
        .write(SettingsCompanion(
      dailyTargetN: Value(n),
      dailyTargetUpdatedAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// 获取设置最后更新时间
  Future<DateTime?> getDailyTargetUpdatedAt() async {
    final settings = await _getOrCreateSettings();
    return settings.dailyTargetUpdatedAt;
  }

  Future<Setting> _getOrCreateSettings() async {
    final existing = await db.select(db.settings).getSingleOrNull();
    if (existing != null) return existing;

    // 创建默认设置
    await db.into(db.settings).insert(SettingsCompanion.insert(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
    return (await db.select(db.settings).getSingle());
  }
}
