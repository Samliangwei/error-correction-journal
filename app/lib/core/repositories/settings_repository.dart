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
  /// - 今日尚未建计划时修改，今日首次计划仍用旧值
  /// - 明日起使用新值
  /// - 多次修改，待生效日累积推进
  Future<void> setDailyTargetN(int n) async {
    if (n < 5 || n > 50) {
      throw ArgumentError('Daily target N must be between 5 and 50');
    }

    final settings = await _getOrCreateSettings();
    final today = LearningDate.today();
    final tomorrow = today.addDays(1);

    // 解析现有待生效
    final currentPendingStr = await db.customSelect(
      'SELECT daily_target_pending_n, daily_target_effective_from FROM settings WHERE id = ?',
      variables: [Variable.withInt(settings.id)],
    ).getSingleOrNull();

    LearningDate? effectiveFrom;

    if (currentPendingStr != null) {
      final pendingValue = currentPendingStr.data['daily_target_pending_n'];
      final effectiveValue =
          currentPendingStr.data['daily_target_effective_from'];

      if (pendingValue != null) {
        pendingN = pendingValue as int;
      }
      if (effectiveValue != null) {
        effectiveFrom = LearningDate.parse(effectiveValue as String);
      }
    }

    // 判断生效日期
    LearningDate newEffectiveFrom;
    if (effectiveFrom != null &&
        effectiveFrom.value.compareTo(today.value) > 0) {
      // 已有待生效且未到期，继承生效日
      newEffectiveFrom = effectiveFrom;
    } else {
      // 新设置或已生效，次日生效
      newEffectiveFrom = tomorrow;
    }

    // 更新待生效值
    await db.customStatement('''
      UPDATE settings 
      SET daily_target_pending_n = ?,
          daily_target_effective_from = ?,
          daily_target_updated_at = ?,
          updated_at = ?
      WHERE id = ?
    ''', [
      n,
      newEffectiveFrom.value,
      DateTime.now().millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch,
      settings.id,
    ]);
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
