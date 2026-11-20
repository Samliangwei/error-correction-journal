import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/core/database/database.dart';
import 'package:error_journal/core/repositories/daily_plan_repository.dart';
import 'package:error_journal/core/repositories/review_repository.dart';
import 'package:error_journal/core/repositories/settings_repository.dart';
import 'package:error_journal/core/scheduling/learning_date.dart';
import 'package:error_journal/features/review/presentation/pages/review_page.dart';
import '../support/widget_test_harness.dart';

Future<void> seedQuestion(
  AppDatabase db, {
  required String id,
  String? correctAnswer,
  String questionText = '测试题干',
  String? myThinking,
  String? errorNotes,
}) async {
  final now = DateTime.now();
  await db.into(db.mistakeQuestions).insert(
        MistakeQuestionsCompanion.insert(
          id: id,
          subject: '数学',
          questionText: questionText,
          correctAnswer: Value(correctAnswer),
          myThinking: Value(myThinking),
          errorNotes: Value(errorNotes),
          mistakeDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

  final planRepo = DailyPlanRepository(db);
  final settingsRepo = SettingsRepository(db);
  final reviewRepo = ReviewRepository(db, planRepo, settingsRepo);
  await settingsRepo.setDailyTargetN(20);
  await db.customStatement(
      'UPDATE settings SET daily_target_n = 20, daily_target_pending_n = NULL WHERE id = 1');
  await reviewRepo.createInitialCycle(
    questionId: id,
    formalizedDate: LearningDate.parse('2026-11-19'),
  );
  await (db.update(db.reviewCycles)..where((c) => c.questionId.equals(id)))
      .write(const ReviewCyclesCompanion(dueDate: Value('2026-11-20')));
}

void main() {
  group('ReviewPage Widget Tests', () {
    late WidgetTestHarness harness;

    setUp(() {
      harness = WidgetTestHarness();
    });

    tearDown(() async {
      await harness.dispose();
    });

    Future<void> openReview(WidgetTester tester, String id) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: harness.overrides,
          child: MaterialApp(
            home: ReviewPage(questionId: id),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('回忆前隐藏答案/思路/错因', (tester) async {
      const id = 'q-hide';
      await seedQuestion(
        harness.db,
        id: id,
        correctAnswer: '42',
        myThinking: '先假设',
        errorNotes: '算错符号',
      );
      await openReview(tester, id);

      expect(find.text('正确答案'), findsNothing);
      expect(find.text('42'), findsNothing);
      expect(find.text('先假设'), findsNothing);
      expect(find.text('算错符号'), findsNothing);
      expect(find.text('请先回忆答案'), findsOneWidget);
    });

    testWidgets('确认回忆后揭示答案与解析', (tester) async {
      const id = 'q-reveal';
      await seedQuestion(
        harness.db,
        id: id,
        correctAnswer: 'π',
        myThinking: '用公式',
      );
      await openReview(tester, id);

      await tester.tap(find.text('查看答案'));
      await tester.pumpAndSettle();

      expect(find.text('正确答案'), findsOneWidget);
      expect(find.text('π'), findsOneWidget);
      expect(find.text('用公式'), findsOneWidget);
    });

    testWidgets('无答案：未核验前评分按钮禁用', (tester) async {
      const id = 'q-no-ans';
      await seedQuestion(harness.db, id: id, correctAnswer: null);
      await openReview(tester, id);

      await tester.tap(find.text('继续'));
      await tester.pumpAndSettle();

      final knowButton = find.widgetWithText(ElevatedButton, '会了');
      final button = tester.widget<ElevatedButton>(knowButton);
      expect(button.onPressed, isNull);

      await tester.tap(find.text('我已完成自行核验'));
      await tester.pumpAndSettle();

      final button2 = tester.widget<ElevatedButton>(knowButton);
      expect(button2.onPressed, isNotNull);
    });

    testWidgets('重复点击提交仅产生一条事件', (tester) async {
      const id = 'q-once';
      await seedQuestion(harness.db, id: id, correctAnswer: 'A');
      await openReview(tester, id);

      await tester.tap(find.text('查看答案'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('会了'));
      await tester.pump();
      await tester.tap(find.text('会了'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final events = await harness.db.select(harness.db.reviewEvents).get();
      expect(events.where((e) => e.questionId == id).length, 1);
    });

    testWidgets('未点评分返回：零条复习事件', (tester) async {
      const id = 'q-back';
      await seedQuestion(harness.db, id: id, correctAnswer: 'B');
      await openReview(tester, id);

      await tester.tap(find.text('查看答案'));
      await tester.pumpAndSettle();
      // 不点会/模糊/不会，等同跳过写库

      final events = await harness.db.select(harness.db.reviewEvents).get();
      expect(events, isEmpty);
    });

    testWidgets('版本快照：后台升版本后提交触发冲突提示', (tester) async {
      const id = 'q-version';
      await seedQuestion(harness.db, id: id, correctAnswer: 'V');
      await openReview(tester, id);

      await (harness.db.update(harness.db.mistakeQuestions)
            ..where((q) => q.id.equals(id)))
          .write(const MistakeQuestionsCompanion(version: Value(99)));

      await tester.tap(find.text('查看答案'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('会了'));
      await tester.pumpAndSettle();

      expect(find.text('版本冲突'), findsOneWidget);
    });

    testWidgets('200% 字体录入复习页无 RenderFlex overflow',
        (tester) async {
      const id = 'q-scale';
      await seedQuestion(harness.db, id: id, correctAnswer: 'C');
      await tester.pumpWidget(
        ProviderScope(
          overrides: harness.overrides,
          child: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(2.0),
              size: Size(390, 844),
            ),
            child: MaterialApp(
              home: ReviewPage(questionId: id),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}