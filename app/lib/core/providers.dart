import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/database.dart';
import 'network/dio_client.dart';
import '../features/settings/domain/settings_repository.dart';
import '../features/settings/data/settings_repository_impl.dart';
import '../features/error_questions/domain/repositories/error_question_repository.dart';
import '../features/error_questions/data/repositories/error_question_repository_impl.dart';
import '../features/error_questions/data/local/local_error_question_data_source.dart';
import '../features/error_questions/data/remote/remote_error_question_data_source.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepositoryImpl(prefs);
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    baseUrl: 'http://localhost:8000',
    apiKey: null,
  );
});

final localErrorQuestionDataSourceProvider =
    Provider<LocalErrorQuestionDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return LocalErrorQuestionDataSource(database);
});

final remoteErrorQuestionDataSourceProvider =
    Provider<RemoteErrorQuestionDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return RemoteErrorQuestionDataSource(dioClient.dio);
});

final errorQuestionRepositoryProvider =
    Provider<ErrorQuestionRepository>((ref) {
  final localDataSource = ref.watch(localErrorQuestionDataSourceProvider);
  final remoteDataSource = ref.watch(remoteErrorQuestionDataSourceProvider);
  final settingsRepository = ref.watch(settingsRepositoryProvider);

  return ErrorQuestionRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    settingsRepository: settingsRepository,
  );
});
