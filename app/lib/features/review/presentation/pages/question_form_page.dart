import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_providers.dart';
import '../../../../core/database/database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/scheduling/learning_date.dart';

class QuestionFormPage extends ConsumerStatefulWidget {
  final String? questionId;

  const QuestionFormPage({super.key, this.questionId});

  @override
  ConsumerState<QuestionFormPage> createState() => _QuestionFormPageState();
}

class _QuestionFormPageState extends ConsumerState<QuestionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _thinkingController = TextEditingController();
  final _errorNotesController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.questionId != null) {
      _loadQuestion();
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _questionController.dispose();
    _answerController.dispose();
    _thinkingController.dispose();
    _errorNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestion() async {
    if (widget.questionId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final db = ref.read(appDatabaseProvider);
      final question = await (db.select(db.mistakeQuestions)
            ..where((q) => q.id.equals(widget.questionId!)))
          .getSingle();

      _subjectController.text = question.subject;
      _questionController.text = question.questionText;
      _answerController.text = question.correctAnswer ?? '';
      _thinkingController.text = question.myThinking ?? '';
      _errorNotesController.text = question.errorNotes ?? '';
      _isEditing = true;
    } catch (e) {
      setState(() => _errorMessage = '加载失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final questionRepo = ref.read(mistakeQuestionRepositoryProvider);
      final reviewRepo = ref.read(reviewRepositoryProvider);

      final db = ref.read(appDatabaseProvider);

      if (_isEditing && widget.questionId != null) {
        final existingQuestion = await (db.select(db.mistakeQuestions)
              ..where((q) => q.id.equals(widget.questionId!)))
            .getSingle();

        await db.transaction(() async {
          final updated = await (db.update(db.mistakeQuestions)
                ..where((q) => q.id.equals(widget.questionId!)))
              .write(MistakeQuestionsCompanion(
            subject: Value(_subjectController.text.trim()),
            questionText: Value(_questionController.text.trim()),
            correctAnswer: Value(_answerController.text.trim().isEmpty
                ? null
                : _answerController.text.trim()),
            myThinking: Value(_thinkingController.text.trim().isEmpty
                ? null
                : _thinkingController.text.trim()),
            errorNotes: Value(_errorNotesController.text.trim().isEmpty
                ? null
                : _errorNotesController.text.trim()),
            version: Value(existingQuestion.version + 1),
            updatedAt: Value(DateTime.now()),
          ));

          if (updated == 0) {
            throw StateError('更新失败：题目可能已被删除或修改');
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('保存成功')),
          );
          context.pop();
        }
      } else {
        final reviewRepo = ref.read(reviewRepositoryProvider);

        await db.transaction(() async {
          final id = 'q-${DateTime.now().millisecondsSinceEpoch}';
          final now = DateTime.now();

          await db.into(db.mistakeQuestions).insert(
                MistakeQuestionsCompanion.insert(
                  id: id,
                  subject: _subjectController.text.trim(),
                  questionText: _questionController.text.trim(),
                  correctAnswer: Value(_answerController.text.trim().isEmpty
                      ? null
                      : _answerController.text.trim()),
                  myThinking: Value(_thinkingController.text.trim().isEmpty
                      ? null
                      : _thinkingController.text.trim()),
                  errorNotes: Value(_errorNotesController.text.trim().isEmpty
                      ? null
                      : _errorNotesController.text.trim()),
                  mistakeDate: now,
                  createdAt: now,
                  updatedAt: now,
                ),
              );

          await reviewRepo.createInitialCycle(
            questionId: id,
            formalizedDate: LearningDate.today(),
          );
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('录入成功')),
          );
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        }
      }
    } catch (e) {
      setState(() => _errorMessage = '保存失败: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑错题' : '录入错题'),
      ),
      body: _isLoading && !_isEditing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
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
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: '科目 *',
                        hintText: '如：数学、物理、英语',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入科目';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _questionController,
                      decoration: const InputDecoration(
                        labelText: '题目内容 *',
                        hintText: '输入题干文字',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入题目内容';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 8),
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
                              '图片功能暂未实现',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      '答案与解析（选填）',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _answerController,
                      decoration: const InputDecoration(
                        labelText: '正确答案',
                        hintText: '输入正确答案',
                      ),
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _thinkingController,
                      decoration: const InputDecoration(
                        labelText: '我的思考',
                        hintText: '记录你的解题思路',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _errorNotesController,
                      decoration: const InputDecoration(
                        labelText: '错误原因',
                        hintText: '记录错在哪里',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isEditing ? '保存' : '提交'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _isLoading ? null : () => context.pop(),
                      child: const Text('取消'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
