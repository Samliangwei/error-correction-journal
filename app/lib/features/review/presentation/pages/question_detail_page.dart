import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/database.dart';
import '../../../../core/scheduling/learning_date.dart';

class QuestionDetailPage extends ConsumerStatefulWidget {
  final String questionId;

  const QuestionDetailPage({super.key, required this.questionId});

  @override
  ConsumerState<QuestionDetailPage> createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends ConsumerState<QuestionDetailPage> {
  MistakeQuestion? _question;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final db = ref.read(appDatabaseProvider);
      final question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(widget.questionId)))
          .getSingle();

      setState(() {
        _question = question;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载失败: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _archiveQuestion() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('归档确认'),
        content: const Text('确定要归档这道题吗？归档后将不再出现在复习计划中。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repo = ref.read(mistakeQuestionRepositoryProvider);
      await repo.archiveQuestion(
        questionId: widget.questionId,
        operationDate: LearningDate.today(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已归档')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('归档失败: $e')),
        );
      }
    }
  }

  Future<void> _deleteQuestion() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除确认'),
        content: const Text('确定要删除这道题吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repo = ref.read(mistakeQuestionRepositoryProvider);
      await repo.deleteQuestion(
        questionId: widget.questionId,
        operationDate: LearningDate.today(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已删除')),
        );
        context.go('/questions');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }

  Future<void> _restoreQuestion() async {
    try {
      final repo = ref.read(mistakeQuestionRepositoryProvider);
      await repo.restoreQuestion(questionId: widget.questionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已恢复')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('恢复失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('错题详情')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }

    final question = _question!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('错题详情'),
        actions: [
          if (!question.isDeleted && !question.isArchived)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/questions/${widget.questionId}/edit'),
              tooltip: '编辑',
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'archive':
                  _archiveQuestion();
                  break;
                case 'delete':
                  _deleteQuestion();
                  break;
                case 'restore':
                  _restoreQuestion();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (!question.isDeleted && !question.isArchived)
                const PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(Icons.archive, color: AppColors.textPrimary),
                      SizedBox(width: 12),
                      Text('归档'),
                    ],
                  ),
                ),
              if (!question.isDeleted && !question.isArchived)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.error),
                      SizedBox(width: 12),
                      Text('删除', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              if (question.isArchived || question.deletedAt != null)
                const PopupMenuItem(
                  value: 'restore',
                  child: Row(
                    children: [
                      Icon(Icons.restore, color: AppColors.primary),
                      SizedBox(width: 12),
                      Text('恢复'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    question.subject,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (question.isArchived)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '已归档',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                if (question.deletedAt != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '已删除',
                      style: TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection('题目', question.questionText),
            if (question.correctAnswer != null && question.correctAnswer!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSection('正确答案', question.correctAnswer!,
                  color: AppColors.primary),
            ],
            if (question.myThinking != null && question.myThinking!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSection('我的思考', question.myThinking!),
            ],
            if (question.errorNotes != null && question.errorNotes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSection('错误原因', question.errorNotes!,
                  color: AppColors.error),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color?.withOpacity(0.05) ?? AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color?.withOpacity(0.3) ?? AppColors.divider,
            ),
          ),
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
