import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/features/review/presentation/pages/question_form_page.dart';
import 'package:error_journal/core/app_providers.dart';
import 'package:error_journal/core/repositories/review_repository.dart';
import '../support/widget_test_harness.dart';

void main() {
  group('QuestionFormPage Widget Tests', () {
    late WidgetTestHarness harness;

    setUp(() {
      harness = WidgetTestHarness();
    });

    tearDown(() async {
      await harness.dispose();
    });

    Future<void> openForm(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: harness.overrides,
          child: const MaterialApp(home: QuestionFormPage()),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> tapSubmit(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.text('提交'),
        80,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('提交'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('必填字段验证：科目为空显示错误', (tester) async {
      await openForm(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, '题目内容 *'),
        '这是一道测试题',
      );

      await tapSubmit(tester);

      expect(find.text('请输入科目'), findsOneWidget);
    });

    testWidgets('必填字段验证：题目内容为空显示错误', (tester) async {
      await openForm(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, '科目 *'),
        '数学',
      );

      await tapSubmit(tester);

      expect(find.text('请输入题目内容'), findsOneWidget);
    });

    testWidgets('成功录入：写入数据库', (tester) async {
      await openForm(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, '科目 *'),
        '数学',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '题目内容 *'),
        '求解方程 x^2 + 2x + 1 = 0',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '正确答案'),
        'x = -1',
      );

      await tapSubmit(tester);

      final questions = await harness.db.select(harness.db.mistakeQuestions).get();
      expect(questions.length, 1);
      expect(questions.first.subject, '数学');
    });

    testWidgets('失败保留输入且不显示成功', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...harness.overrides,
            reviewRepositoryProvider.overrideWith((ref) {
              final planRepo = ref.watch(dailyPlanRepositoryProvider);
              final settingsRepo = ref.watch(settingsRepositoryProvider);
              final repo = ReviewRepository(harness.db, planRepo, settingsRepo);
              repo.faultInjection.afterInitialCycleInsert = () {
                throw StateError('injected cycle fault');
              };
              return repo;
            }),
          ],
          child: const MaterialApp(home: QuestionFormPage()),
        ),
      );
      await tester.binding.setSurfaceSize(const Size(390, 1400));
      await tester.pumpAndSettle();

      const testSubject = '物理';
      const testQuestion = '牛顿第一定律是什么';

      await tester.enterText(
          find.widgetWithText(TextFormField, '科目 *'), testSubject);
      await tester.enterText(
          find.widgetWithText(TextFormField, '题目内容 *'), testQuestion);

      await tapSubmit(tester);

      expect(find.text('录入成功'), findsNothing);
      expect(find.textContaining('保存失败'), findsOneWidget);
      expect(find.text(testSubject), findsOneWidget);
      expect(find.text(testQuestion), findsOneWidget);
    });

    testWidgets('200% 字体录入页无 overflow', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: harness.overrides,
          child: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(2.0),
              size: Size(390, 844),
            ),
            child: const MaterialApp(home: QuestionFormPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}