import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/database.dart';
import 'repositories/mistake_question_repository.dart';
import 'repositories/review_repository.dart';
import 'repositories/settings_repository.dart';
import 'repositories/daily_plan_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final mistakeQuestionRepositoryProvider = Provider<MistakeQuestionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return MistakeQuestionRepository(db);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SettingsRepository(db);
});

final dailyPlanRepositoryProvider = Provider<DailyPlanRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DailyPlanRepository(db);
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final planRepo = ref.watch(dailyPlanRepositoryProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return ReviewRepository(db, planRepo, settingsRepo);
});
