import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/database.dart';

class QuestionsListPage extends ConsumerStatefulWidget {
  const QuestionsListPage({super.key});

  @override
  ConsumerState<QuestionsListPage> createState() => _QuestionsListPageState();
}

class _QuestionsListPageState extends ConsumerState<QuestionsListPage> {
  String _searchQuery = '';
  String? _selectedSubject;

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('错题列表'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索题目内容...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: FutureBuilder<List<MistakeQuestion>>(
              future: _loadQuestions(db),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('加载失败: ${snapshot.error}'),
                  );
                }

                final questions = snapshot.data ?? [];
                if (questions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inbox,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? '暂无错题' : '未找到匹配的错题',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return _buildQuestionCard(context, question);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/questions/new'),
        icon: const Icon(Icons.add),
        label: const Text('录入错题'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildFilterChips() {
    return FutureBuilder<List<String>>(
      future: _loadSubjects(),
      builder: (context, snapshot) {
        final subjects = snapshot.data ?? [];
        if (subjects.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('全部'),
                selected: _selectedSubject == null,
                onSelected: (selected) {
                  setState(() => _selectedSubject = null);
                },
              ),
              ...subjects.map((subject) {
                return FilterChip(
                  label: Text(subject),
                  selected: _selectedSubject == subject,
                  onSelected: (selected) {
                    setState(() => _selectedSubject = selected ? subject : null);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionCard(BuildContext context, MistakeQuestion question) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/questions/${question.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      question.subject,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (question.isArchived)
                    const Icon(
                        Icons.archive, size: 16, color: AppColors.textSecondary),
                  if (question.deletedAt != null)
                    const Icon(Icons.delete, size: 16, color: AppColors.error),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                question.questionText,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (question.correctAnswer != null) ...[
                const SizedBox(height: 8),
                Text(
                  '答案: ${question.correctAnswer}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<List<MistakeQuestion>> _loadQuestions(AppDatabase db) async {
    var query = db.select(db.mistakeQuestions);

    query = query..where((q) => q.deletedAt.isNull());

    if (_selectedSubject != null) {
      query = query..where((q) => q.subject.equals(_selectedSubject!));
    }

    if (_searchQuery.isNotEmpty) {
      final pattern = '%$_searchQuery%';
      query = query..where((q) => q.questionText.like(pattern));
    }

    query = query..orderBy([(q) => OrderingTerm.desc(q.createdAt)]);

    return query.get();
  }

  Future<List<String>> _loadSubjects() async {
    final db = ref.read(appDatabaseProvider);
    final questions =
        await (db.select(db.mistakeQuestions)..where((q) => q.deletedAt.isNull()))
            .get();

    return questions.map((q) => q.subject).toSet().toList()..sort();
  }
}
