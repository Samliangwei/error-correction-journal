class AppConstants {
  static const String appName = '错题记录';
  static const String databaseName = 'error_journal.db';
  static const int databaseVersion = 1;
  
  static const Duration networkTimeout = Duration(seconds: 10);
  
  static const List<String> subjects = [
    '语文',
    '数学',
    '英语',
    '物理',
    '化学',
    '生物',
    '历史',
    '地理',
    '政治',
    '其他',
  ];
}

enum SyncMode {
  localOnly,
  cloudSync,
}

enum MasteryStatus {
  notMastered,
  partiallyMastered,
  mastered,
}

extension MasteryStatusExtension on MasteryStatus {
  String get displayName {
    switch (this) {
      case MasteryStatus.notMastered:
        return '未掌握';
      case MasteryStatus.partiallyMastered:
        return '部分掌握';
      case MasteryStatus.mastered:
        return '已掌握';
    }
  }
  
  String get apiValue {
    switch (this) {
      case MasteryStatus.notMastered:
        return 'not_mastered';
      case MasteryStatus.partiallyMastered:
        return 'partially_mastered';
      case MasteryStatus.mastered:
        return 'mastered';
    }
  }
  
  static MasteryStatus fromApiValue(String value) {
    switch (value) {
      case 'not_mastered':
        return MasteryStatus.notMastered;
      case 'partially_mastered':
        return MasteryStatus.partiallyMastered;
      case 'mastered':
        return MasteryStatus.mastered;
      default:
        return MasteryStatus.notMastered;
    }
  }
}
