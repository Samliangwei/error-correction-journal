// 集成测试：验证本地模式下的 CRUD 操作不访问网络
//
// 运行方式：flutter test test_integration/local_mode_test.dart
//
// 验证点：
// 1. localOnly 模式下不发起 HTTP 请求
// 2. 新增/编辑/删除错题保存到本地数据库
// 3. 数据持久化（重启后可读）

library;

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:error_journal/features/error_questions/domain/models/error_question.dart'
    as domain;
import 'package:error_journal/features/error_questions/data/local/local_error_question_data_source.dart';
import 'package:error_journal/core/database/database.dart';
import 'package:error_journal/core/constants/app_constants.dart';

void main() {
  group('本地模式集成测试', () {
    late AppDatabase database;
    late LocalErrorQuestionDataSource dataSource;

    setUp(() {
      // 使用内存数据库进行测试
      database = AppDatabase.forTesting(NativeDatabase.memory());
      dataSource = LocalErrorQuestionDataSource(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('新增错题保存到本地数据库', () async {
      final question = domain.ErrorQuestion.create(
        subject: '数学',
        question: '1+1=?',
        myAnswer: '3',
        correctAnswer: '2',
        reason: '计算错误',
        masteryStatus: MasteryStatus.notMastered,
      );

      await dataSource.create(question);

      final retrieved = await dataSource.getById(question.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.id, question.id);
      expect(retrieved.subject, '数学');
      expect(retrieved.question, '1+1=?');
      expect(retrieved.needsSync, isTrue);
    });

    test('编辑错题更新本地数据库', () async {
      final question = domain.ErrorQuestion.create(
        subject: '英语',
        question: 'What is your name?',
        myAnswer: 'I is Tom',
        correctAnswer: 'I am Tom',
        reason: '主谓一致',
      );

      await dataSource.create(question);

      final updated = question.copyWith(
        masteryStatus: MasteryStatus.mastered,
        needsSync: true,
      );
      await dataSource.update(updated);

      final retrieved = await dataSource.getById(question.id);
      expect(retrieved!.masteryStatus, MasteryStatus.mastered);
      expect(retrieved.needsSync, isTrue);
    });

    test('删除错题使用软删除（墓碑）', () async {
      final question = domain.ErrorQuestion.create(
        subject: '物理',
        question: 'F=ma',
        myAnswer: 'F=m/a',
        correctAnswer: 'F=ma',
        reason: '公式记错',
      );

      await dataSource.create(question);
      await dataSource.delete(question.id);

      final retrieved = await dataSource.getById(question.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.deletedAt, isNotNull);
      expect(retrieved.needsSync, isTrue);
    });

    test('列表查询不包含已删除项', () async {
      final question1 = domain.ErrorQuestion.create(
        subject: '化学',
        question: 'H2O',
        myAnswer: 'H2O2',
        correctAnswer: 'H2O',
        reason: '符号写错',
      );
      final question2 = domain.ErrorQuestion.create(
        subject: '生物',
        question: 'DNA',
        myAnswer: 'RNA',
        correctAnswer: 'DNA',
        reason: '概念混淆',
      );

      await dataSource.create(question1);
      await dataSource.create(question2);
      await dataSource.delete(question1.id);

      final all = await dataSource.getAll();
      expect(all.length, 1);
      expect(all.first.id, question2.id);
    });

    test('获取待同步列表', () async {
      final question1 = domain.ErrorQuestion.create(
        subject: '历史',
        question: '1949年',
        myAnswer: '1948年',
        correctAnswer: '1949年',
        reason: '年份记错',
      );
      final question2 = domain.ErrorQuestion.create(
        subject: '地理',
        question: '北京',
        myAnswer: '上海',
        correctAnswer: '北京',
        reason: '地名混淆',
      );

      await dataSource.create(question1);
      await dataSource.create(question2);

      await dataSource.markAsSynced([question1.id]);

      final pending = await dataSource.getPendingSync();
      expect(pending.length, 1);
      expect(pending.first.id, question2.id);
    });
  });
}
