import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/core/repositories/review_repository.dart';
import 'package:error_journal/core/repositories/daily_plan_repository.dart';
import 'package:error_journal/core/repositories/settings_repository.dart';
import 'package:error_journal/core/scheduling/learning_date.dart';
import 'package:error_journal/features/review/presentation/pages/question_form_page.dart';
import '../support/widget_test_harness.dart';

/// 表单提交经真实 ReviewRepository.createInitialCycle 持久化。
void main() {
  testWidgets('录入表单提交创建题目与周期', (tester) async {
    final harness = WidgetTestHarness();
    addTearDown(harness.dispose);

    await tester.binding.setSurfaceSize(const Size(390, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: const MaterialApp(home: QuestionFormPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, '科目 *'),
      '地理',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '题目内容 *'),
      '首都题',
    );
    await tester.scrollUntilVisible(
      find.text('提交'),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('提交'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final questions = await harness.db.select(harness.db.mistakeQuestions).get();
    expect(questions.length, 1);
    expect(questions.first.subject, '地理');

    final cycles = await harness.db.select(harness.db.reviewCycles).get();
    expect(cycles.length, 1);
    expect(cycles.first.questionId, questions.first.id);
  });
}