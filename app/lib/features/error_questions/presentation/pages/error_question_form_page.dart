import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers.dart';
import '../../domain/models/error_question.dart';

class ErrorQuestionFormPage extends ConsumerStatefulWidget {
  final String? id;

  const ErrorQuestionFormPage({this.id, super.key});

  @override
  ConsumerState<ErrorQuestionFormPage> createState() => _ErrorQuestionFormPageState();
}

class _ErrorQuestionFormPageState extends ConsumerState<ErrorQuestionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _myAnswerController = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final _reasonController = TextEditingController();

  String _selectedSubject = AppConstants.subjects.first;
  MasteryStatus _masteryStatus = MasteryStatus.notMastered;
  bool _isLoading = false;

  @override
  void dispose() {
    _questionController.dispose();
    _myAnswerController.dispose();
    _correctAnswerController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(errorQuestionRepositoryProvider);

      if (widget.id == null) {
        final question = ErrorQuestion.create(
          subject: _selectedSubject,
          question: _questionController.text,
          myAnswer: _myAnswerController.text,
          correctAnswer: _correctAnswerController.text,
          reason: _reasonController.text,
          masteryStatus: _masteryStatus,
        );
        await repository.create(question);
      } else {
        final existing = await repository.getById(widget.id!);
        if (existing != null) {
          final updated = existing.copyWith(
            subject: _selectedSubject,
            question: _questionController.text,
            myAnswer: _myAnswerController.text,
            correctAnswer: _correctAnswerController.text,
            reason: _reasonController.text,
            masteryStatus: _masteryStatus,
          );
          await repository.update(updated);
        }
      }

      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? '新增错题' : '编辑错题'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedSubject,
                      decoration: const InputDecoration(
                        labelText: '学科',
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.subjects.map((subject) {
                        return DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedSubject = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _questionController,
                      decoration: const InputDecoration(
                        labelText: '题目',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value?.isEmpty ?? true ? '请输入题目' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _myAnswerController,
                      decoration: const InputDecoration(
                        labelText: '我的答案',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value?.isEmpty ?? true ? '请输入你的答案' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _correctAnswerController,
                      decoration: const InputDecoration(
                        labelText: '正确答案',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value?.isEmpty ?? true ? '请输入正确答案' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        labelText: '错因分析',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value?.isEmpty ?? true ? '请输入错因分析' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<MasteryStatus>(
                      value: _masteryStatus,
                      decoration: const InputDecoration(
                        labelText: '掌握状态',
                        border: OutlineInputBorder(),
                      ),
                      items: MasteryStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _masteryStatus = value);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _save,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          widget.id == null ? '添加' : '保存',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
