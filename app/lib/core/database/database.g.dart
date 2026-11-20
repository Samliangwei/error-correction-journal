// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ErrorQuestionsTable extends ErrorQuestions
    with TableInfo<$ErrorQuestionsTable, ErrorQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ErrorQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _questionMeta =
      const VerificationMeta('question');
  @override
  late final GeneratedColumn<String> question = GeneratedColumn<String>(
      'question', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _myAnswerMeta =
      const VerificationMeta('myAnswer');
  @override
  late final GeneratedColumn<String> myAnswer = GeneratedColumn<String>(
      'my_answer', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _correctAnswerMeta =
      const VerificationMeta('correctAnswer');
  @override
  late final GeneratedColumn<String> correctAnswer = GeneratedColumn<String>(
      'correct_answer', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _masteryStatusMeta =
      const VerificationMeta('masteryStatus');
  @override
  late final GeneratedColumn<String> masteryStatus = GeneratedColumn<String>(
      'mastery_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        subject,
        question,
        myAnswer,
        correctAnswer,
        reason,
        masteryStatus,
        createdAt,
        updatedAt,
        deletedAt,
        lastSyncedAt,
        needsSync
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'error_questions';
  @override
  VerificationContext validateIntegrity(Insertable<ErrorQuestion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta));
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('question')) {
      context.handle(_questionMeta,
          question.isAcceptableOrUnknown(data['question']!, _questionMeta));
    } else if (isInserting) {
      context.missing(_questionMeta);
    }
    if (data.containsKey('my_answer')) {
      context.handle(_myAnswerMeta,
          myAnswer.isAcceptableOrUnknown(data['my_answer']!, _myAnswerMeta));
    } else if (isInserting) {
      context.missing(_myAnswerMeta);
    }
    if (data.containsKey('correct_answer')) {
      context.handle(
          _correctAnswerMeta,
          correctAnswer.isAcceptableOrUnknown(
              data['correct_answer']!, _correctAnswerMeta));
    } else if (isInserting) {
      context.missing(_correctAnswerMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('mastery_status')) {
      context.handle(
          _masteryStatusMeta,
          masteryStatus.isAcceptableOrUnknown(
              data['mastery_status']!, _masteryStatusMeta));
    } else if (isInserting) {
      context.missing(_masteryStatusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ErrorQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ErrorQuestion(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject'])!,
      question: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question'])!,
      myAnswer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}my_answer'])!,
      correctAnswer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}correct_answer'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      masteryStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mastery_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
    );
  }

  @override
  $ErrorQuestionsTable createAlias(String alias) {
    return $ErrorQuestionsTable(attachedDatabase, alias);
  }
}

class ErrorQuestion extends DataClass implements Insertable<ErrorQuestion> {
  final String id;
  final String subject;
  final String question;
  final String myAnswer;
  final String correctAnswer;
  final String reason;
  final String masteryStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? lastSyncedAt;
  final bool needsSync;
  const ErrorQuestion(
      {required this.id,
      required this.subject,
      required this.question,
      required this.myAnswer,
      required this.correctAnswer,
      required this.reason,
      required this.masteryStatus,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.lastSyncedAt,
      required this.needsSync});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject'] = Variable<String>(subject);
    map['question'] = Variable<String>(question);
    map['my_answer'] = Variable<String>(myAnswer);
    map['correct_answer'] = Variable<String>(correctAnswer);
    map['reason'] = Variable<String>(reason);
    map['mastery_status'] = Variable<String>(masteryStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['needs_sync'] = Variable<bool>(needsSync);
    return map;
  }

  ErrorQuestionsCompanion toCompanion(bool nullToAbsent) {
    return ErrorQuestionsCompanion(
      id: Value(id),
      subject: Value(subject),
      question: Value(question),
      myAnswer: Value(myAnswer),
      correctAnswer: Value(correctAnswer),
      reason: Value(reason),
      masteryStatus: Value(masteryStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      needsSync: Value(needsSync),
    );
  }

  factory ErrorQuestion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ErrorQuestion(
      id: serializer.fromJson<String>(json['id']),
      subject: serializer.fromJson<String>(json['subject']),
      question: serializer.fromJson<String>(json['question']),
      myAnswer: serializer.fromJson<String>(json['myAnswer']),
      correctAnswer: serializer.fromJson<String>(json['correctAnswer']),
      reason: serializer.fromJson<String>(json['reason']),
      masteryStatus: serializer.fromJson<String>(json['masteryStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subject': serializer.toJson<String>(subject),
      'question': serializer.toJson<String>(question),
      'myAnswer': serializer.toJson<String>(myAnswer),
      'correctAnswer': serializer.toJson<String>(correctAnswer),
      'reason': serializer.toJson<String>(reason),
      'masteryStatus': serializer.toJson<String>(masteryStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
    };
  }

  ErrorQuestion copyWith(
          {String? id,
          String? subject,
          String? question,
          String? myAnswer,
          String? correctAnswer,
          String? reason,
          String? masteryStatus,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          bool? needsSync}) =>
      ErrorQuestion(
        id: id ?? this.id,
        subject: subject ?? this.subject,
        question: question ?? this.question,
        myAnswer: myAnswer ?? this.myAnswer,
        correctAnswer: correctAnswer ?? this.correctAnswer,
        reason: reason ?? this.reason,
        masteryStatus: masteryStatus ?? this.masteryStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        needsSync: needsSync ?? this.needsSync,
      );
  ErrorQuestion copyWithCompanion(ErrorQuestionsCompanion data) {
    return ErrorQuestion(
      id: data.id.present ? data.id.value : this.id,
      subject: data.subject.present ? data.subject.value : this.subject,
      question: data.question.present ? data.question.value : this.question,
      myAnswer: data.myAnswer.present ? data.myAnswer.value : this.myAnswer,
      correctAnswer: data.correctAnswer.present
          ? data.correctAnswer.value
          : this.correctAnswer,
      reason: data.reason.present ? data.reason.value : this.reason,
      masteryStatus: data.masteryStatus.present
          ? data.masteryStatus.value
          : this.masteryStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ErrorQuestion(')
          ..write('id: $id, ')
          ..write('subject: $subject, ')
          ..write('question: $question, ')
          ..write('myAnswer: $myAnswer, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('reason: $reason, ')
          ..write('masteryStatus: $masteryStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      subject,
      question,
      myAnswer,
      correctAnswer,
      reason,
      masteryStatus,
      createdAt,
      updatedAt,
      deletedAt,
      lastSyncedAt,
      needsSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ErrorQuestion &&
          other.id == this.id &&
          other.subject == this.subject &&
          other.question == this.question &&
          other.myAnswer == this.myAnswer &&
          other.correctAnswer == this.correctAnswer &&
          other.reason == this.reason &&
          other.masteryStatus == this.masteryStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.needsSync == this.needsSync);
}

class ErrorQuestionsCompanion extends UpdateCompanion<ErrorQuestion> {
  final Value<String> id;
  final Value<String> subject;
  final Value<String> question;
  final Value<String> myAnswer;
  final Value<String> correctAnswer;
  final Value<String> reason;
  final Value<String> masteryStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<bool> needsSync;
  final Value<int> rowid;
  const ErrorQuestionsCompanion({
    this.id = const Value.absent(),
    this.subject = const Value.absent(),
    this.question = const Value.absent(),
    this.myAnswer = const Value.absent(),
    this.correctAnswer = const Value.absent(),
    this.reason = const Value.absent(),
    this.masteryStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ErrorQuestionsCompanion.insert({
    required String id,
    required String subject,
    required String question,
    required String myAnswer,
    required String correctAnswer,
    required String reason,
    required String masteryStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        subject = Value(subject),
        question = Value(question),
        myAnswer = Value(myAnswer),
        correctAnswer = Value(correctAnswer),
        reason = Value(reason),
        masteryStatus = Value(masteryStatus),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ErrorQuestion> custom({
    Expression<String>? id,
    Expression<String>? subject,
    Expression<String>? question,
    Expression<String>? myAnswer,
    Expression<String>? correctAnswer,
    Expression<String>? reason,
    Expression<String>? masteryStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? needsSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subject != null) 'subject': subject,
      if (question != null) 'question': question,
      if (myAnswer != null) 'my_answer': myAnswer,
      if (correctAnswer != null) 'correct_answer': correctAnswer,
      if (reason != null) 'reason': reason,
      if (masteryStatus != null) 'mastery_status': masteryStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (needsSync != null) 'needs_sync': needsSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ErrorQuestionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? subject,
      Value<String>? question,
      Value<String>? myAnswer,
      Value<String>? correctAnswer,
      Value<String>? reason,
      Value<String>? masteryStatus,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<DateTime?>? lastSyncedAt,
      Value<bool>? needsSync,
      Value<int>? rowid}) {
    return ErrorQuestionsCompanion(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      question: question ?? this.question,
      myAnswer: myAnswer ?? this.myAnswer,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      reason: reason ?? this.reason,
      masteryStatus: masteryStatus ?? this.masteryStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (question.present) {
      map['question'] = Variable<String>(question.value);
    }
    if (myAnswer.present) {
      map['my_answer'] = Variable<String>(myAnswer.value);
    }
    if (correctAnswer.present) {
      map['correct_answer'] = Variable<String>(correctAnswer.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (masteryStatus.present) {
      map['mastery_status'] = Variable<String>(masteryStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ErrorQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('subject: $subject, ')
          ..write('question: $question, ')
          ..write('myAnswer: $myAnswer, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('reason: $reason, ')
          ..write('masteryStatus: $masteryStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ErrorQuestionsTable errorQuestions = $ErrorQuestionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [errorQuestions];
}

typedef $$ErrorQuestionsTableCreateCompanionBuilder = ErrorQuestionsCompanion
    Function({
  required String id,
  required String subject,
  required String question,
  required String myAnswer,
  required String correctAnswer,
  required String reason,
  required String masteryStatus,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> lastSyncedAt,
  Value<bool> needsSync,
  Value<int> rowid,
});
typedef $$ErrorQuestionsTableUpdateCompanionBuilder = ErrorQuestionsCompanion
    Function({
  Value<String> id,
  Value<String> subject,
  Value<String> question,
  Value<String> myAnswer,
  Value<String> correctAnswer,
  Value<String> reason,
  Value<String> masteryStatus,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<DateTime?> lastSyncedAt,
  Value<bool> needsSync,
  Value<int> rowid,
});

class $$ErrorQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $ErrorQuestionsTable> {
  $$ErrorQuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get question => $composableBuilder(
      column: $table.question, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get myAnswer => $composableBuilder(
      column: $table.myAnswer, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get correctAnswer => $composableBuilder(
      column: $table.correctAnswer, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get masteryStatus => $composableBuilder(
      column: $table.masteryStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));
}

class $$ErrorQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ErrorQuestionsTable> {
  $$ErrorQuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get question => $composableBuilder(
      column: $table.question, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get myAnswer => $composableBuilder(
      column: $table.myAnswer, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get correctAnswer => $composableBuilder(
      column: $table.correctAnswer,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get masteryStatus => $composableBuilder(
      column: $table.masteryStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));
}

class $$ErrorQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ErrorQuestionsTable> {
  $$ErrorQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);

  GeneratedColumn<String> get myAnswer =>
      $composableBuilder(column: $table.myAnswer, builder: (column) => column);

  GeneratedColumn<String> get correctAnswer => $composableBuilder(
      column: $table.correctAnswer, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get masteryStatus => $composableBuilder(
      column: $table.masteryStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);
}

class $$ErrorQuestionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ErrorQuestionsTable,
    ErrorQuestion,
    $$ErrorQuestionsTableFilterComposer,
    $$ErrorQuestionsTableOrderingComposer,
    $$ErrorQuestionsTableAnnotationComposer,
    $$ErrorQuestionsTableCreateCompanionBuilder,
    $$ErrorQuestionsTableUpdateCompanionBuilder,
    (
      ErrorQuestion,
      BaseReferences<_$AppDatabase, $ErrorQuestionsTable, ErrorQuestion>
    ),
    ErrorQuestion,
    PrefetchHooks Function()> {
  $$ErrorQuestionsTableTableManager(
      _$AppDatabase db, $ErrorQuestionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ErrorQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ErrorQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ErrorQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<String> question = const Value.absent(),
            Value<String> myAnswer = const Value.absent(),
            Value<String> correctAnswer = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<String> masteryStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ErrorQuestionsCompanion(
            id: id,
            subject: subject,
            question: question,
            myAnswer: myAnswer,
            correctAnswer: correctAnswer,
            reason: reason,
            masteryStatus: masteryStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            lastSyncedAt: lastSyncedAt,
            needsSync: needsSync,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String subject,
            required String question,
            required String myAnswer,
            required String correctAnswer,
            required String reason,
            required String masteryStatus,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ErrorQuestionsCompanion.insert(
            id: id,
            subject: subject,
            question: question,
            myAnswer: myAnswer,
            correctAnswer: correctAnswer,
            reason: reason,
            masteryStatus: masteryStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            lastSyncedAt: lastSyncedAt,
            needsSync: needsSync,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ErrorQuestionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ErrorQuestionsTable,
    ErrorQuestion,
    $$ErrorQuestionsTableFilterComposer,
    $$ErrorQuestionsTableOrderingComposer,
    $$ErrorQuestionsTableAnnotationComposer,
    $$ErrorQuestionsTableCreateCompanionBuilder,
    $$ErrorQuestionsTableUpdateCompanionBuilder,
    (
      ErrorQuestion,
      BaseReferences<_$AppDatabase, $ErrorQuestionsTable, ErrorQuestion>
    ),
    ErrorQuestion,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ErrorQuestionsTableTableManager get errorQuestions =>
      $$ErrorQuestionsTableTableManager(_db, _db.errorQuestions);
}
