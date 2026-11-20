import '../../../../core/constants/app_constants.dart';
import '../../domain/models/error_question.dart';
import '../../domain/repositories/error_question_repository.dart';
import '../local/local_error_question_data_source.dart';
import '../remote/remote_error_question_data_source.dart';
import '../../../settings/domain/settings_repository.dart';

class ErrorQuestionRepositoryImpl implements ErrorQuestionRepository {
  final LocalErrorQuestionDataSource _localDataSource;
  final RemoteErrorQuestionDataSource _remoteDataSource;
  final SettingsRepository _settingsRepository;

  ErrorQuestionRepositoryImpl({
    required LocalErrorQuestionDataSource localDataSource,
    required RemoteErrorQuestionDataSource remoteDataSource,
    required SettingsRepository settingsRepository,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _settingsRepository = settingsRepository;

  @override
  Future<List<ErrorQuestion>> getAll({
    String? subject,
    MasteryStatus? masteryStatus,
  }) async {
    return await _localDataSource.getAll(
      subject: subject,
      masteryStatus: masteryStatus,
    );
  }

  @override
  Future<ErrorQuestion?> getById(String id) async {
    return await _localDataSource.getById(id);
  }

  @override
  Future<void> create(ErrorQuestion question) async {
    await _localDataSource.create(question);
    await _trySyncInBackground();
  }

  @override
  Future<void> update(ErrorQuestion question) async {
    final updated = question.copyWith(
      updatedAt: DateTime.now(),
      needsSync: true,
    );
    await _localDataSource.update(updated);
    await _trySyncInBackground();
  }

  @override
  Future<void> delete(String id) async {
    await _localDataSource.delete(id);
    await _trySyncInBackground();
  }

  @override
  Future<void> sync() async {
    final settings = await _settingsRepository.getSettings();
    if (settings.syncMode != SyncMode.cloudSync) {
      return;
    }

    final pendingQuestions = await _localDataSource.getPendingSync();
    if (pendingQuestions.isEmpty) {
      return;
    }

    try {
      final synced = await _remoteDataSource.syncQuestions(pendingQuestions);
      await _localDataSource.markAsSynced(synced.map((q) => q.id).toList());
    } catch (e) {
      // 同步失败，将在下次重试
    }
  }

  @override
  Future<List<ErrorQuestion>> getPendingSync() async {
    return await _localDataSource.getPendingSync();
  }

  Future<void> _trySyncInBackground() async {
    try {
      await sync();
    } catch (e) {
      // 后台同步失败，静默处理
    }
  }
}
