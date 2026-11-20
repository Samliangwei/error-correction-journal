import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/scheduling/learning_date.dart';
import '../../../../core/scheduling/review_result.dart';
import '../../../../core/database/database.dart';

class ReviewPage extends ConsumerStatefulWidget {
  final String questionId;

  const ReviewPage({super.key, required this.questionId});

  @override
  ConsumerState<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends ConsumerState<ReviewPage> {
  MistakeQuestion? _question;
  ReviewCycle? _cycle;
  bool _isLoading = true;
  bool _answerRevealed = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _capacityConfirmed = false;

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
      
      final cycle = await (db.select(db.reviewCycles)
            ..where((c) => c.questionId.equals(widget.questionId))
            ..where((c) => c.isActive.equals(true)))
          .getSingle();

      setState(() {
        _question = question;
        _cycle = cycle;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载失败: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitReview(ReviewResult result) async {
    if (_question == null || _cycle == null) return;

    if (!_answerRevealed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先查看答案再提交')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final reviewRepo = ref.read(reviewRepositoryProvider);
      final hasAnswer = _question!.correctAnswer != null && _question!.correctAnswer!.isNotEmpty;

      final submissionResult = await reviewRepo.submitScheduledReview(
        questionId: widget.questionId,
        result: result,
        submittedDate: LearningDate.today(),
        hasAnswer: hasAnswer,
        hasConfirmedVerification: hasAnswer,
        capacityConfirmed: _capacityConfirmed,
        expectedQuestionVersion: _question!.version,
        expectedCycleId: _cycle!.id,
        expectedCycleVersion: _cycle!.version,
      );

      if (!mounted) return;

      if (submissionResult.accepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('提交成功')),
        );
        context.go('/');
      } else {
        await _handleRejection(submissionResult);
      }
    } catch (e) {
      setState(() {
        _errorMessage = '提交失败: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleRejection(dynamic submissionResult) async {
    final reason = submissionResult.reason?.toString() ?? '未知原因';
    
    if (reason.contains('version')) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('版本冲突'),
          content: const Text('题目或周期已被更新，请重新加载后再试'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loadData();
              },
              child: const Text('重新加载'),
            ),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('返回首页'),
            ),
          ],
        ),
      );
    } else if (reason.contains('capacity')) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('今日计划已满'),
          content: const Text('今日复习任务已满额，是否确认添加？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确认添加'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        setState(() => _capacityConfirmed = true);
      }
    } else if (reason.contains('duplicate')) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('重复提交'),
          content: const Text('今日已提交过该题目'),
          actions: [
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('返回首页'),
            ),
          ],
        ),
      );
    } else {
      setState(() => _errorMessage = '提交被拒绝: $reason');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _question == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('复习')),
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
    final hasAnswer = question.correctAnswer != null && question.correctAnswer!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('复习'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/questions/${widget.questionId}'),
            tooltip: '编辑',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(16),
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
          ],
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  const SizedBox(height: 24),
                  Text(
                    '题目',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      question.questionText,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!_answerRevealed) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.visibility_off,
                            size: 48,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '请先回忆答案',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hasAnswer ? '思考后点击下方按钮查看答案' : '思考后点击下方按钮继续',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => setState(() => _answerRevealed = true),
                            icon: const Icon(Icons.visibility),
                            label: Text(hasAnswer ? '查看答案' : '继续'),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    if (hasAnswer) ...[
                      Text(
                        '正确答案',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Text(
                          question.correctAnswer!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (question.myThinking != null &&
                        question.myThinking!.isNotEmpty) ...[
                      Text(
                        '我的思考',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Text(
                          question.myThinking!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (question.errorNotes != null &&
                        question.errorNotes!.isNotEmpty) ...[
                      Text(
                        '错误原因',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Text(
                          question.errorNotes!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (!hasAnswer) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '该题未录入答案，请自行核验后选择掌握程度',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      '你掌握这道题了吗？',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildResultButton(
                            label: '不会',
                            icon: Icons.close,
                            color: AppColors.error,
                            result: ReviewResult.dontKnow,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildResultButton(
                            label: '模糊',
                            icon: Icons.help_outline,
                            color: Colors.orange,
                            result: ReviewResult.vague,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildResultButton(
                            label: '会了',
                            icon: Icons.check,
                            color: AppColors.primary,
                            result: ReviewResult.know,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultButton({
    required String label,
    required IconData icon,
    required Color color,
    required ReviewResult result,
  }) {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : () => _submitReview(result),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
