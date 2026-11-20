import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers.dart';
import '../../domain/settings.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late SyncMode _syncMode;
  final _serverUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    final settings = await repository.getSettings();

    setState(() {
      _syncMode = settings.syncMode;
      _serverUrlController.text = settings.serverUrl ?? 'http://localhost:8000';
      _apiKeyController.text = settings.apiKey ?? '';
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      final repository = ref.read(settingsRepositoryProvider);
      final settings = AppSettings(
        syncMode: _syncMode,
        serverUrl:
            _syncMode == SyncMode.cloudSync ? _serverUrlController.text : null,
        apiKey: _syncMode == SyncMode.cloudSync ? _apiKeyController.text : null,
      );

      await repository.saveSettings(settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('设置已保存')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '同步模式',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          RadioListTile<SyncMode>(
            title: const Text('仅本地'),
            subtitle: const Text('数据仅保存在设备上，不连接服务器'),
            value: SyncMode.localOnly,
            groupValue: _syncMode,
            onChanged: (value) {
              if (value != null) {
                setState(() => _syncMode = value);
              }
            },
          ),
          RadioListTile<SyncMode>(
            title: const Text('云同步'),
            subtitle: const Text('数据会同步到服务器进行备份'),
            value: SyncMode.cloudSync,
            groupValue: _syncMode,
            onChanged: (value) {
              if (value != null) {
                setState(() => _syncMode = value);
              }
            },
          ),
          if (_syncMode == SyncMode.cloudSync) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              '服务器配置',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                labelText: '服务器地址',
                border: OutlineInputBorder(),
                hintText: 'http://localhost:8000',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存设置', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '关于数据存储',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• 本地模式：数据仅存储在您的设备上\n'
                    '• 云同步模式：数据会同步备份到服务器\n'
                    '• Web 版本：数据存储在浏览器 IndexedDB 中，清理浏览器数据会删除本地数据\n'
                    '• 建议定期启用云同步进行备份',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
