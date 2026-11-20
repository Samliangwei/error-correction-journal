import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_providers.dart';
import '../../../../core/theme/app_theme.dart';

class ReviewSettingsPage extends ConsumerStatefulWidget {
  const ReviewSettingsPage({super.key});

  @override
  ConsumerState<ReviewSettingsPage> createState() => _ReviewSettingsPageState();
}

class _ReviewSettingsPageState extends ConsumerState<ReviewSettingsPage> {
  final _dailyTargetController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  int? _currentTarget;
  int? _pendingTarget;
  String? _effectiveDate;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _dailyTargetController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final settingsRepo = ref.read(settingsRepositoryProvider);
      final settings = await settingsRepo.getSettingsModel();

      _currentTarget = settings.currentTargetN;
      _pendingTarget = settings.pendingTargetN;
      _effectiveDate = settings.effectiveFromDate?.toString();
      _dailyTargetController.text =
          (_pendingTarget ?? _currentTarget).toString();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = '加载失败: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final newTarget = int.tryParse(_dailyTargetController.text.trim());
    if (newTarget == null || newTarget < 1 || newTarget > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入1-100之间的数字')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final settingsRepo = ref.read(settingsRepositoryProvider);
      await settingsRepo.setDailyTargetN(newTarget);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('设置成功，将于明日生效')),
        );
        _loadSettings();
      }
    } catch (e) {
      setState(() => _errorMessage = '保存失败: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: AppColors.error),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_errorMessage!)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '每日复习目标',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '设置每天计划复习的题目数量',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (_currentTarget != null) ...[
                            Row(
                              children: [
                                const Text(
                                  '当前目标：',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                                Text(
                                  '$_currentTarget 题/天',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            if (_pendingTarget != null && _pendingTarget != _currentTarget) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '待生效: $_pendingTarget 题/天（${_effectiveDate ?? "明日"}生效）',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                          TextField(
                            controller: _dailyTargetController,
                            decoration: const InputDecoration(
                              labelText: '新目标',
                              hintText: '输入1-100之间的数字',
                              suffixText: '题/天',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '修改后将于次日生效，当日计划不受影响',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isSaving ? null : _saveSettings,
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('保存'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '关于',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          const ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.book, color: AppColors.primary),
                            title: Text('拾题'),
                            subtitle: Text('错题复习与间隔记忆'),
                          ),
                          const Divider(),
                          const ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.info, color: AppColors.primary),
                            title: Text('版本'),
                            subtitle: Text('1.0.0'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
