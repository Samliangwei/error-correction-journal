/// 设置模型（含生效日期控制）
library;

import '../scheduling/learning_date.dart';

class SettingsModel {
  final int currentTargetN; // 当前生效的N（今日计划使用）
  final int? pendingTargetN; // 待生效的N（明日起生效）
  final LearningDate? effectiveFromDate; // pendingN生效日期（UTC+8）

  SettingsModel({
    required this.currentTargetN,
    this.pendingTargetN,
    this.effectiveFromDate,
  });

  /// 获取指定日期应使用的N
  int getTargetNForDate(LearningDate date) {
    if (pendingTargetN != null && effectiveFromDate != null) {
      // 如果日期>=生效日，使用待生效值
      if (date.value.compareTo(effectiveFromDate!.value) >= 0) {
        return pendingTargetN!;
      }
    }
    return currentTargetN;
  }

  /// 判断是否有待生效的更改
  bool get hasPendingChange =>
      pendingTargetN != null && effectiveFromDate != null;
}
