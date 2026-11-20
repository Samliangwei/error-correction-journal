import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/core/database/database.dart';
import 'package:error_journal/features/review/presentation/pages/questions_list_page.dart';
import '../support/widget_test_harness.dart';

void main() {
  group('录入持久化到列表', () {
    late WidgetTestHarness harness;

    setUp(() {
      harness = WidgetTestHarness();
    });

    tearDown(() async {
      await harness.dispose();
    });

    testWidgets('数据库记录出现在列表', (tester) async {
      const unique = 'LIST_PERSIST_题目唯一串';
      final now = DateTime.now();
      await harness.db.into(harness.db.mistakeQuestions).insert(
            MistakeQuestionsCompanion.insert(
              id: 'list-q1',
              subject: '生物',
              questionText: unique,
              mistakeDate: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await tester.pumpWidget(
        ProviderScope(
          overrides: harness.overrides,
          child: const MaterialApp(home: QuestionsListPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining(unique), findsOneWidget);
    });
  });
}