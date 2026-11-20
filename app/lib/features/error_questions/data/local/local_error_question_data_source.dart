import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/error_question.dart' as domain;

class LocalErrorQuestionDataSource {
  final AppDatabase _database;

  LocalErrorQuestionDataSource(this._database);

  Future<List<domain.ErrorQuestion>> getAll({
    String? subject,
    MasteryStatus? masteryStatus,
  }) async {
    var query = _database.select(_database.errorQuestions)
      ..where((tbl) => tbl.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    if (subject != null) {
      query = query..where((tbl) => tbl.subject.equals(subject));
    }

    if (masteryStatus != null) {
      query = query..where((tbl) => tbl.masteryStatus.equals(masteryStatus.apiValue));
    }

    final rows = await query.get();
    return rows.map(_toDomain).toList();
  }

  Future<domain.ErrorQuestion?> getById(String id) async {
    final query = _database.select(_database.errorQuestions)
      ..where((tbl) => tbl.id.equals(id));

    final row = await query.getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  Future<void> create(domain.ErrorQuestion question) async {
    await _database.into(_database.errorQuestions).insert(
      ErrorQuestionsCompanion.insert(
        id: question.id,
        subject: question.subject,
        question: question.question,
        myAnswer: question.myAnswer,
        correctAnswer: question.correctAnswer,
        reason: question.reason,
        masteryStatus: question.masteryStatus.apiValue,
        createdAt: question.createdAt,
        updatedAt: question.updatedAt,
        deletedAt: Value(question.deletedAt),
        lastSyncedAt: Value(question.lastSyncedAt),
        needsSync: Value(question.needsSync),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> update(domain.ErrorQuestion question) async {
    await (_database.update(_database.errorQuestions)
          ..where((tbl) => tbl.id.equals(question.id)))
        .write(ErrorQuestionsCompanion(
      subject: Value(question.subject),
      question: Value(question.question),
      myAnswer: Value(question.myAnswer),
      correctAnswer: Value(question.correctAnswer),
      reason: Value(question.reason),
      masteryStatus: Value(question.masteryStatus.apiValue),
      updatedAt: Value(question.updatedAt),
      deletedAt: Value(question.deletedAt),
      lastSyncedAt: Value(question.lastSyncedAt),
      needsSync: Value(question.needsSync),
    ));
  }

  Future<void> delete(String id) async {
    await (_database.update(_database.errorQuestions)
          ..where((tbl) => tbl.id.equals(id)))
        .write(ErrorQuestionsCompanion(
      deletedAt: Value(DateTime.now()),
      needsSync: const Value(true),
    ));
  }

  Future<List<domain.ErrorQuestion>> getPendingSync() async {
    final query = _database.select(_database.errorQuestions)
      ..where((tbl) => tbl.needsSync.equals(true));

    final rows = await query.get();
    return rows.map(_toDomain).toList();
  }

  Future<void> markAsSynced(List<String> ids) async {
    if (ids.isEmpty) return;

    await (_database.update(_database.errorQuestions)
          ..where((tbl) => tbl.id.isIn(ids)))
        .write(ErrorQuestionsCompanion(
      needsSync: const Value(false),
      lastSyncedAt: Value(DateTime.now()),
    ));
  }

  domain.ErrorQuestion _toDomain(ErrorQuestion row) {
    return domain.ErrorQuestion(
      id: row.id,
      subject: row.subject,
      question: row.question,
      myAnswer: row.myAnswer,
      correctAnswer: row.correctAnswer,
      reason: row.reason,
      masteryStatus: MasteryStatusExtension.fromApiValue(row.masteryStatus),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      lastSyncedAt: row.lastSyncedAt,
      needsSync: row.needsSync,
    );
  }
}
