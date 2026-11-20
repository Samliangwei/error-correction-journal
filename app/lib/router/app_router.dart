import 'package:go_router/go_router.dart';

import '../features/error_questions/presentation/pages/error_questions_list_page.dart';
import '../features/error_questions/presentation/pages/error_question_form_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ErrorQuestionsListPage(),
    ),
    GoRoute(
      path: '/error-question/new',
      builder: (context, state) => const ErrorQuestionFormPage(),
    ),
    GoRoute(
      path: '/error-question/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ErrorQuestionFormPage(id: id);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
