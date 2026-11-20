/// 复习周期
library;

import 'learning_date.dart';

/// k级别 0-4
enum KLevel {
  k0(0),
  k1(1),
  k2(2),
  k3(3),
  k4(4);

  final int value;
  const KLevel(this.value);

  KLevel? next() {
    switch (this) {
      case KLevel.k0:
        return KLevel.k1;
      case KLevel.k1:
        return KLevel.k2;
      case KLevel.k2:
        return KLevel.k3;
      case KLevel.k3:
        return KLevel.k4;
      case KLevel.k4:
        return null; // 已达最高级
    }
  }

  static KLevel fromValue(int value) {
    switch (value) {
      case 0:
        return KLevel.k0;
      case 1:
        return KLevel.k1;
      case 2:
        return KLevel.k2;
      case 3:
        return KLevel.k3;
      case 4:
        return KLevel.k4;
      default:
        throw ArgumentError('Invalid k level: $value');
    }
  }
}

/// 复习周期（领域模型）
class ReviewCycle {
  final String questionId;
  final int cycleNumber; // 周期序号（再错时递增）
  final KLevel kLevel;
  final LearningDate? dueDate; // k4时为null
  final bool isActive; // 是否当前活动周期
  final int version; // 乐观锁版本

  const ReviewCycle({
    required this.questionId,
    required this.cycleNumber,
    required this.kLevel,
    this.dueDate,
    required this.isActive,
    required this.version,
  });

  /// 创建初始周期（保存日次日首复习）
  factory ReviewCycle.initial({
    required String questionId,
    required LearningDate formalizedDate,
  }) {
    return ReviewCycle(
      questionId: questionId,
      cycleNumber: 1,
      kLevel: KLevel.k0,
      dueDate: formalizedDate.addDays(1), // 次日
      isActive: true,
      version: 1,
    );
  }

  /// 复制并更新
  ReviewCycle copyWith({
    String? questionId,
    int? cycleNumber,
    KLevel? kLevel,
    LearningDate? dueDate,
    bool clearDue = false,
    bool? isActive,
    int? version,
  }) {
    return ReviewCycle(
      questionId: questionId ?? this.questionId,
      cycleNumber: cycleNumber ?? this.cycleNumber,
      kLevel: kLevel ?? this.kLevel,
      dueDate: clearDue ? null : (dueDate ?? this.dueDate),
      isActive: isActive ?? this.isActive,
      version: version ?? this.version,
    );
  }

  @override
  String toString() =>
      'ReviewCycle(q=$questionId, cycle=$cycleNumber, k=$kLevel, due=$dueDate, active=$isActive, v=$version)';
}
