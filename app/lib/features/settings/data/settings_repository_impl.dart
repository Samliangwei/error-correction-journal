import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/settings.dart';
import '../domain/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const String _keySyncMode = 'sync_mode';
  static const String _keyServerUrl = 'server_url';
  static const String _keyApiKey = 'api_key';
  static const String _keyLastSyncTime = 'last_sync_time';

  final SharedPreferences _prefs;

  SettingsRepositoryImpl(this._prefs);

  @override
  Future<AppSettings> getSettings() async {
    final syncModeStr = _prefs.getString(_keySyncMode);
    final syncMode =
        syncModeStr == 'cloudSync' ? SyncMode.cloudSync : SyncMode.localOnly;

    final lastSyncTimeStr = _prefs.getString(_keyLastSyncTime);
    final lastSyncTime =
        lastSyncTimeStr != null ? DateTime.tryParse(lastSyncTimeStr) : null;

    return AppSettings(
      syncMode: syncMode,
      serverUrl: _prefs.getString(_keyServerUrl),
      apiKey: _prefs.getString(_keyApiKey),
      lastSyncTime: lastSyncTime,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString(
      _keySyncMode,
      settings.syncMode == SyncMode.cloudSync ? 'cloudSync' : 'localOnly',
    );

    if (settings.serverUrl != null) {
      await _prefs.setString(_keyServerUrl, settings.serverUrl!);
    } else {
      await _prefs.remove(_keyServerUrl);
    }

    if (settings.apiKey != null) {
      await _prefs.setString(_keyApiKey, settings.apiKey!);
    } else {
      await _prefs.remove(_keyApiKey);
    }

    if (settings.lastSyncTime != null) {
      await _prefs.setString(
        _keyLastSyncTime,
        settings.lastSyncTime!.toIso8601String(),
      );
    } else {
      await _prefs.remove(_keyLastSyncTime);
    }
  }
}
