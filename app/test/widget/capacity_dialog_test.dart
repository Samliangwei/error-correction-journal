import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/core/database/database.dart';
import 'package:error_journal/core/repositories/settings_repository.dart';
import 'package:error_journal/core/scheduling/learning_date.dart';
import 'package:error_journal/features/review/presentation/pages/review_page.dart';
import '../support/widget_test_harness.dart';

Future<void> seedPlanFullExceptOneDue(
    WidgetTestHarness harness, String overflowQuestionId) async {
  final db = harness.db;
  final settingsRepo = SettingsRepository(db);
  await settingsRepo.setDailyTargetN(5);
  await db.customStatement(
      'UPDATE settings SET daily_target_n = 5, daily_target_pending_n = NULL, daily_target_effective_from = NULL WHERE id = 1');

  final today = LearningDate.today().value;
  final now = DateTime.now();
  await db.into(db.dailyPlans).insert(
        DailyPlansCompanion.insert(
          id: 'plan-today',
          learningDate: today,
          targetN: 5,
          capacityC: 5,
          createdAt: now,
          updatedAt: now,
        ),
      );

  for (var i = 0; i < 6; i++) {
    final id = i == 5 ? overflowQuestionId : 'cap-member-$i';
    final now = DateTime.now();
    await db.into(db.mistakeQuestions).insert(
          MistakeQuestionsCompanion.insert(
            id: id,
            subject: 'Math',
            questionText: 'Q$id',
            mistakeDate: now,
            createdAt: now,
            updatedAt: now,
            correctAnswer: const Value('ans'),
          ),
        );
    await db.into(db.reviewCycles).insert(
          ReviewCyclesCompanion.insert(
            id: 'cyc-$id',
            questionId: id,
            cycleNumber: 1,
            kLevel: 0,
            dueDate: const Value('2020-01-01'),
            isActive: const Value(true),
            version: const Value(1),
            createdAt: now,
            updatedAt: now,
          ),
        );
    if (i < 5) {
      await db.into(db.dailyPlanMembers).insert(
            DailyPlanMembersCompanion.insert(
              id: 'mem-$id',
              planId: 'plan-today',
              questionId: id,
              orderIndex: i,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  }

  await (db.update(db.reviewCycles)
        ..where((c) => c.questionId.equals(overflowQuestionId)))
      .write(ReviewCyclesCompanion(dueDate: Value(today)));
}

void main() {
  testWidgets('取消满额追加：不产生溢出题复习事件', (tester) async {
    final harness = WidgetTestHarness();
    addTearDown(harness.dispose);

    const overflowId = 'cap-overflow';
    await seedPlanFullExceptOneDue(harness, overflowId);

    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp(
          home: ReviewPage(questionId: overflowId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看答案'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('会了'),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('会了'));
    await tester.pumpAndSettle();

    if (find.text('今日计划已满').evaluate().isNotEmpty) {
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
    }

    final events = await harness.db.select(harness.db.reviewEvents).get();
    expect(events.where((e) => e.questionId == overflowId), isEmpty);
  });
}