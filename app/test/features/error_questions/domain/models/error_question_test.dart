import 'package:flutter_test/flutter_test.dart';
import 'package:error_journal/features/error_questions/domain/models/error_question.dart';
import 'package:error_journal/core/constants/app_constants.dart';

void main() {
  group('ErrorQuestion', () {
    test('create() generates unique ID and timestamps', () {
      final question = ErrorQuestion.create(
        subject: '数学',
        question: '1+1=?',
        myAnswer: '3',
        correctAnswer: '2',
        reason: '计算错误',
      );

      expect(question.id, isNotEmpty);
      expect(question.subject, '数学');
      expect(question.needsSync, isTrue);
      expect(question.masteryStatus, MasteryStatus.notMastered);
    });

    test('toJson() and fromJson() round trip', () {
      final original = ErrorQuestion.create(
        subject: '英语',
        question: 'What is your name?',
        myAnswer: 'I is Tom',
        correctAnswer: 'I am Tom',
        reason: '主语为 I 时，be 动词用 am',
        masteryStatus: MasteryStatus.partiallyMastered,
      );

      final json = original.toJson();
      final restored = ErrorQuestion.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.subject, original.subject);
      expect(restored.question, original.question);
      expect(restored.masteryStatus, original.masteryStatus);
    });
  });
}
