import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/scheduling/learning_date.dart';

class TodayPlanPage extends ConsumerStatefulWidget {
  const TodayPlanPage({super.key});

  @override
  ConsumerState<TodayPlanPage> createState() => _TodayPlanPageState();
}

class _TodayPlanPageState extends ConsumerState<TodayPlanPage> {
  @override
  Widget build(BuildContext context) {
    final planRepo = ref.watch(dailyPlanRepositoryProvider);
    final today = LearningDate.today();

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日计划'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => context.push('/questions'),
            tooltip: '错题列表',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: '设置',
          ),
        ],
      ),
      body: FutureBuilder(
        future: planRepo.getPlan(today),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final plan = snapshot.data;
          if (plan == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '今日暂无计划',
                    style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/questions'),
                    icon: const Icon(Icons.add),
                    label: const Text('查看错题列表'),
                  ),
                ],
              ),
            );
          }

          final members = plan.members;
          final completed = members.where((m) => m.isCompleted).length;
          final skipped = members.where((m) => m.isSkipped).length;
          final remaining = members.length - completed - skipped;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      today.toString(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStat('已完成', completed, AppColors.primary),
                        const SizedBox(width: 24),
                        _buildStat('已跳过', skipped, AppColors.textSecondary),
                        const SizedBox(width: 24),
                        _buildStat('待复习', remaining, AppColors.primaryDark),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: members.isEmpty ? 0 : completed / members.length,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return FutureBuilder(
                      future: ref.read(appDatabaseProvider).select(
                        ref.read(appDatabaseProvider).mistakeQuestions
                      )..where((q) => q.id.equals(member.questionId)),
                      builder: (context, questionSnapshot) {
                        if (!questionSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        
                        final questions = questionSnapshot.data as List;
                        if (questions.isEmpty) return const SizedBox.shrink();
                        
                        final question = questions.first;
                        
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: member.isCompleted
                                  ? AppColors.primary
                                  : member.isSkipped
                                      ? AppColors.textSecondary
                                      : AppColors.primaryLight,
                              child: Icon(
                                member.isCompleted
                                    ? Icons.check
                                    : member.isSkipped
                                        ? Icons.skip_next
                                        : Icons.schedule,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              question.subject,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: member.isSkipped
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              question.questionText.length > 50
                                  ? '${question.questionText.substring(0, 50)}...'
                                  : question.questionText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: member.isCompleted || member.isSkipped
                                ? null
                                : const Icon(Icons.arrow_forward_ios, size: 16),
                            enabled: !member.isCompleted && !member.isSkipped,
                            onTap: () {
                              if (!member.isCompleted && !member.isSkipped) {
                                context.push('/review/${member.questionId}');
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/questions/new'),
        icon: const Icon(Icons.add),
        label: const Text('录入错题'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildStat(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
