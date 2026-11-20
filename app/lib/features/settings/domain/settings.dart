import '../../../core/constants/app_constants.dart';

class AppSettings {
  final SyncMode syncMode;
  final String? serverUrl;
  final String? apiKey;
  final DateTime? lastSyncTime;

  const AppSettings({
    this.syncMode = SyncMode.localOnly,
    this.serverUrl,
    this.apiKey,
    this.lastSyncTime,
  });

  AppSettings copyWith({
    SyncMode? syncMode,
    String? serverUrl,
    String? apiKey,
    DateTime? lastSyncTime,
  }) {
    return AppSettings(
      syncMode: syncMode ?? this.syncMode,
      serverUrl: serverUrl ?? this.serverUrl,
      apiKey: apiKey ?? this.apiKey,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}
