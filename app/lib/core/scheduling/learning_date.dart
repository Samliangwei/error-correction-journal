/// 学习日期工具类（固定 UTC+8）
library;

import 'package:clock/clock.dart';

/// 学习日期格式：yyyy-MM-dd
class LearningDate {
  final String value; // e.g., "2026-11-20"

  const LearningDate(this.value);

  /// 从 DateTime 转换（UTC+8）
  factory LearningDate.fromDateTime(DateTime dateTime) {
    final utc8 = dateTime.toUtc().add(const Duration(hours: 8));
    return LearningDate(_formatDate(utc8));
  }

  /// 当前学习日期（UTC+8）
  static LearningDate today({Clock? clock}) {
    final effectiveClock = clock ?? const Clock();
    final now = effectiveClock.now();
    // 确保转为UTC时间
    final utc = now.isUtc ? now : now.toUtc();
    // 加8小时得到UTC+8
    final utc8 = utc.add(const Duration(hours: 8));
    return LearningDate(_formatDate(utc8));
  }

  /// 解析日期字符串
  static LearningDate parse(String dateStr) {
    // 验证格式
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateStr)) {
      throw FormatException(
          'Invalid date format: $dateStr. Expected yyyy-MM-dd');
    }
    return LearningDate(dateStr);
  }

  /// 加天数
  LearningDate addDays(int days) {
    final date = DateTime.parse(value);
    final newDate = date.add(Duration(days: days));
    return LearningDate(_formatDate(newDate));
  }

  /// 比较
  bool operator <(LearningDate other) => value.compareTo(other.value) < 0;
  bool operator <=(LearningDate other) => value.compareTo(other.value) <= 0;
  bool operator >(LearningDate other) => value.compareTo(other.value) > 0;
  bool operator >=(LearningDate other) => value.compareTo(other.value) >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningDate &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
