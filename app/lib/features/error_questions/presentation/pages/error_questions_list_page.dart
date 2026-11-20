import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../providers/error_questions_provider.dart';

class ErrorQuestionsListPage extends ConsumerWidget {
  const ErrorQuestionsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(
      errorQuestionsProvider(const ErrorQuestionsFilter()),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('错题记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('还没有错题记录',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('点击下方 + 按钮添加',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    question.question,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text(question.subject),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            question.masteryStatus.displayName,
                            style: TextStyle(
                              color: _getMasteryColor(question.masteryStatus),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/error-question/${question.id}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('加载失败: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/error-question/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getMasteryColor(MasteryStatus status) {
    switch (status) {
      case MasteryStatus.notMastered:
        return Colors.red;
      case MasteryStatus.partiallyMastered:
        return Colors.orange;
      case MasteryStatus.mastered:
        return Colors.green;
    }
  }
}
