import 'package:go_router/go_router.dart';

import '../features/review/presentation/pages/today_plan_page.dart';
import '../features/review/presentation/pages/questions_list_page.dart';
import '../features/review/presentation/pages/question_form_page.dart';
import '../features/review/presentation/pages/question_detail_page.dart';
import '../features/review/presentation/pages/review_page.dart';
import '../features/review/presentation/pages/settings_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TodayPlanPage(),
    ),
    GoRoute(
      path: '/questions',
      builder: (context, state) => const QuestionsListPage(),
    ),
    GoRoute(
      path: '/questions/new',
      builder: (context, state) => const QuestionFormPage(),
    ),
    GoRoute(
      path: '/questions/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return QuestionDetailPage(questionId: id);
      },
    ),
    GoRoute(
      path: '/questions/:id/edit',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return QuestionFormPage(questionId: id);
      },
    ),
    GoRoute(
      path: '/review/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ReviewPage(questionId: id);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const ReviewSettingsPage(),
    ),
  ],
);
