import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:error_journal/core/app_providers.dart';
import 'package:error_journal/core/database/database.dart';
import 'package:error_journal/core/repositories/mistake_question_repository.dart';
import 'package:error_journal/core/repositories/review_repository.dart';
import 'package:error_journal/core/repositories/settings_repository.dart';
import 'package:error_journal/core/repositories/daily_plan_repository.dart';
import 'package:error_journal/router/app_router.dart';

/// 内存 SQLite + 真实 Repository 链，供 Widget 测试 override。
class WidgetTestHarness {
  final AppDatabase db;

  WidgetTestHarness() : db = AppDatabase.forTesting(NativeDatabase.memory());

  Future<void> dispose() => db.close();

  List<Override> get overrides => [
        appDatabaseProvider.overrideWithValue(db),
        settingsRepositoryProvider.overrideWith((ref) => SettingsRepository(db)),
        dailyPlanRepositoryProvider
            .overrideWith((ref) => DailyPlanRepository(db)),
        reviewRepositoryProvider.overrideWith((ref) {
          final planRepo = ref.watch(dailyPlanRepositoryProvider);
          final settingsRepo = ref.watch(settingsRepositoryProvider);
          return ReviewRepository(db, planRepo, settingsRepo);
        }),
        mistakeQuestionRepositoryProvider.overrideWith((ref) {
          final planRepo = ref.watch(dailyPlanRepositoryProvider);
          final reviewRepo = ref.watch(reviewRepositoryProvider);
          final settingsRepo = ref.watch(settingsRepositoryProvider);
          return MistakeQuestionRepository(
              db, planRepo, reviewRepo, settingsRepo);
        }),
      ];

  Widget app({double textScale = 1.0}) {
    return ProviderScope(
      overrides: overrides,
      child: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(textScale),
          size: const Size(390, 844),
        ),
        child: MaterialApp.router(
          routerConfig: appRouter,
        ),
      ),
    );
  }
}