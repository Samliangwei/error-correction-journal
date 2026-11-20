/// 设置Repository（含次日生效控制）
library;

import 'package:drift/drift.dart';
import '../database/database.dart';
import '../scheduling/learning_date.dart';
import '../models/settings_model.dart';

class SettingsRepository {
  final AppDatabase db;

  SettingsRepository(this.db);

  /// 获取指定日期的每日目标N
  Future<int> getDailyTargetNForDate(LearningDate date) async {
    final model = await getSettingsModel();
    return model.getTargetNForDate(date);
  }

  /// 获取今日（默认）每日目标N
  Future<int> getDailyTargetN() async {
    final today = LearningDate.today();
    return getDailyTargetNForDate(today);
  }

  /// 设置每日目标N（5-50，次日生效）
  ///
  /// 规则：
  /// - 事务内先结转到期的pending
  /// - 再设置明日生效的新pending
  Future<void> setDailyTargetN(int n) async {
    if (n < 5 || n > 50) {
      throw ArgumentError('Daily target N must be between 5 and 50');
    }

    await db.transaction(() async {
      final settings = await _getOrCreateSettings();
      final today = LearningDate.today();
      final tomorrow = today.addDays(1);

      // 1. 先结转到期的pending
      final currentData = await db.customSelect(
        'SELECT daily_target_n, daily_target_pending_n, daily_target_effective_from FROM settings WHERE id = ?',
        variables: [Variable.withInt(settings.id)],
      ).getSingleOrNull();

      if (currentData != null) {
        final pendingN = currentData.data['daily_target_pending_n'];
        final effectiveValue = currentData.data['daily_target_effective_from'];

        if (pendingN != null && effectiveValue != null) {
          final effectiveFrom = LearningDate.parse(effectiveValue as String);

          // 如果待生效日期<=今日，需要结转
          if (effectiveFrom.value.compareTo(today.value) <= 0) {
            await db.customStatement('''
              UPDATE settings 
              SET daily_target_n = ?,
                  daily_target_pending_n = NULL,
                  daily_target_effective_from = NULL,
                  updated_at = ?
              WHERE id = ?
            ''', [
              pendingN,
              DateTime.now().millisecondsSinceEpoch,
              settings.id,
            ]);
          }
        }
      }

      // 2. 设置明日生效的新pending
      await db.customStatement('''
        UPDATE settings 
        SET daily_target_pending_n = ?,
            daily_target_effective_from = ?,
            updated_at = ?
        WHERE id = ?
      ''', [
        n,
        tomorrow.value,
        DateTime.now().millisecondsSinceEpoch,
        settings.id,
      ]);
    });
  }

  /// 获取设置模型
  Future<SettingsModel> getSettingsModel() async {
    final settings = await _getOrCreateSettings();

    // 查询待生效值
    final row = await db.customSelect(
      'SELECT daily_target_pending_n, daily_target_effective_from FROM settings WHERE id = ?',
      variables: [Variable.withInt(settings.id)],
    ).getSingleOrNull();

    int? pendingN;
    LearningDate? effectiveFrom;

    if (row != null) {
      final pendingValue = row.data['daily_target_pending_n'];
      final effectiveValue = row.data['daily_target_effective_from'];

      if (pendingValue != null && effectiveValue != null) {
        pendingN = pendingValue as int;
        effectiveFrom = LearningDate.parse(effectiveValue as String);
      }
    }

    return SettingsModel(
      currentTargetN: settings.dailyTargetN,
      pendingTargetN: pendingN,
      effectiveFromDate: effectiveFrom,
    );
  }

  /// 应用待生效的更改（内部使用，在创建计划时调用）
  Future<void> applyPendingIfDue(LearningDate date) async {
    final model = await getSettingsModel();

    if (model.hasPendingChange &&
        date.value.compareTo(model.effectiveFromDate!.value) >= 0) {
      // 生效日已到，应用更改
      final settings = await _getOrCreateSettings();
      await db.customStatement('''
        UPDATE settings 
        SET daily_target_n = ?,
            daily_target_pending_n = NULL,
            daily_target_effective_from = NULL,
            updated_at = ?
        WHERE id = ?
      ''', [
        model.pendingTargetN!,
        DateTime.now().millisecondsSinceEpoch,
        settings.id,
      ]);
    }
  }

  Future<Setting> _getOrCreateSettings() async {
    // 先查询所有settings（如果有多条，只取第一条）
    final allSettings = await db.select(db.settings).get();
    if (allSettings.isNotEmpty) return allSettings.first;

    // 创建默认设置
    await db.into(db.settings).insert(SettingsCompanion.insert(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

    // 再次查询所有，取第一条（防止并发创建多条）
    final allAfterInsert = await db.select(db.settings).get();
    return allAfterInsert.first;
  }
}
