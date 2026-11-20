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

class $MistakeQuestionsTable extends MistakeQuestions
    with TableInfo<$MistakeQuestionsTable, MistakeQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MistakeQuestionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _questionTextMeta =
      const VerificationMeta('questionText');
  @override
  late final GeneratedColumn<String> questionText = GeneratedColumn<String>(
      'question_text', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 5000),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _correctAnswerMeta =
      const VerificationMeta('correctAnswer');
  @override
  late final GeneratedColumn<String> correctAnswer = GeneratedColumn<String>(
      'correct_answer', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 5000),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _myThinkingMeta =
      const VerificationMeta('myThinking');
  @override
  late final GeneratedColumn<String> myThinking = GeneratedColumn<String>(
      'my_thinking', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 3000),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _errorNotesMeta =
      const VerificationMeta('errorNotes');
  @override
  late final GeneratedColumn<String> errorNotes = GeneratedColumn<String>(
      'error_notes', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 1000),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _mistakeDateMeta =
      const VerificationMeta('mistakeDate');
  @override
  late final GeneratedColumn<DateTime> mistakeDate = GeneratedColumn<DateTime>(
      'mistake_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
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
  static const VerificationMeta _formalizedAtMeta =
      const VerificationMeta('formalizedAt');
  @override
  late final GeneratedColumn<DateTime> formalizedAt = GeneratedColumn<DateTime>(
      'formalized_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        subject,
        questionText,
        correctAnswer,
        myThinking,
        errorNotes,
        mistakeDate,
        createdAt,
        updatedAt,
        formalizedAt,
        isArchived,
        deletedAt,
        version
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mistake_questions';
  @override
  VerificationContext validateIntegrity(Insertable<MistakeQuestion> instance,
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
    if (data.containsKey('question_text')) {
      context.handle(
          _questionTextMeta,
          questionText.isAcceptableOrUnknown(
              data['question_text']!, _questionTextMeta));
    } else if (isInserting) {
      context.missing(_questionTextMeta);
    }
    if (data.containsKey('correct_answer')) {
      context.handle(
          _correctAnswerMeta,
          correctAnswer.isAcceptableOrUnknown(
              data['correct_answer']!, _correctAnswerMeta));
    }
    if (data.containsKey('my_thinking')) {
      context.handle(
          _myThinkingMeta,
          myThinking.isAcceptableOrUnknown(
              data['my_thinking']!, _myThinkingMeta));
    }
    if (data.containsKey('error_notes')) {
      context.handle(
          _errorNotesMeta,
          errorNotes.isAcceptableOrUnknown(
              data['error_notes']!, _errorNotesMeta));
    }
    if (data.containsKey('mistake_date')) {
      context.handle(
          _mistakeDateMeta,
          mistakeDate.isAcceptableOrUnknown(
              data['mistake_date']!, _mistakeDateMeta));
    } else if (isInserting) {
      context.missing(_mistakeDateMeta);
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
    if (data.containsKey('formalized_at')) {
      context.handle(
          _formalizedAtMeta,
          formalizedAt.isAcceptableOrUnknown(
              data['formalized_at']!, _formalizedAtMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MistakeQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MistakeQuestion(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject'])!,
      questionText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_text'])!,
      correctAnswer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}correct_answer']),
      myThinking: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}my_thinking']),
      errorNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_notes']),
      mistakeDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}mistake_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      formalizedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}formalized_at']),
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $MistakeQuestionsTable createAlias(String alias) {
    return $MistakeQuestionsTable(attachedDatabase, alias);
  }
}

class MistakeQuestion extends DataClass implements Insertable<MistakeQuestion> {
  final String id;
  final String subject;
  final String questionText;
  final String? correctAnswer;
  final String? myThinking;
  final String? errorNotes;
  final DateTime mistakeDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? formalizedAt;
  final bool isArchived;
  final DateTime? deletedAt;
  final int version;
  const MistakeQuestion(
      {required this.id,
      required this.subject,
      required this.questionText,
      this.correctAnswer,
      this.myThinking,
      this.errorNotes,
      required this.mistakeDate,
      required this.createdAt,
      required this.updatedAt,
      this.formalizedAt,
      required this.isArchived,
      this.deletedAt,
      required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject'] = Variable<String>(subject);
    map['question_text'] = Variable<String>(questionText);
    if (!nullToAbsent || correctAnswer != null) {
      map['correct_answer'] = Variable<String>(correctAnswer);
    }
    if (!nullToAbsent || myThinking != null) {
      map['my_thinking'] = Variable<String>(myThinking);
    }
    if (!nullToAbsent || errorNotes != null) {
      map['error_notes'] = Variable<String>(errorNotes);
    }
    map['mistake_date'] = Variable<DateTime>(mistakeDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || formalizedAt != null) {
      map['formalized_at'] = Variable<DateTime>(formalizedAt);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  MistakeQuestionsCompanion toCompanion(bool nullToAbsent) {
    return MistakeQuestionsCompanion(
      id: Value(id),
      subject: Value(subject),
      questionText: Value(questionText),
      correctAnswer: correctAnswer == null && nullToAbsent
          ? const Value.absent()
          : Value(correctAnswer),
      myThinking: myThinking == null && nullToAbsent
          ? const Value.absent()
          : Value(myThinking),
      errorNotes: errorNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(errorNotes),
      mistakeDate: Value(mistakeDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      formalizedAt: formalizedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(formalizedAt),
      isArchived: Value(isArchived),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
    );
  }

  factory MistakeQuestion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MistakeQuestion(
      id: serializer.fromJson<String>(json['id']),
      subject: serializer.fromJson<String>(json['subject']),
      questionText: serializer.fromJson<String>(json['questionText']),
      correctAnswer: serializer.fromJson<String?>(json['correctAnswer']),
      myThinking: serializer.fromJson<String?>(json['myThinking']),
      errorNotes: serializer.fromJson<String?>(json['errorNotes']),
      mistakeDate: serializer.fromJson<DateTime>(json['mistakeDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      formalizedAt: serializer.fromJson<DateTime?>(json['formalizedAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subject': serializer.toJson<String>(subject),
      'questionText': serializer.toJson<String>(questionText),
      'correctAnswer': serializer.toJson<String?>(correctAnswer),
      'myThinking': serializer.toJson<String?>(myThinking),
      'errorNotes': serializer.toJson<String?>(errorNotes),
      'mistakeDate': serializer.toJson<DateTime>(mistakeDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'formalizedAt': serializer.toJson<DateTime?>(formalizedAt),
      'isArchived': serializer.toJson<bool>(isArchived),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
    };
  }

  MistakeQuestion copyWith(
          {String? id,
          String? subject,
          String? questionText,
          Value<String?> correctAnswer = const Value.absent(),
          Value<String?> myThinking = const Value.absent(),
          Value<String?> errorNotes = const Value.absent(),
          DateTime? mistakeDate,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> formalizedAt = const Value.absent(),
          bool? isArchived,
          Value<DateTime?> deletedAt = const Value.absent(),
          int? version}) =>
      MistakeQuestion(
        id: id ?? this.id,
        subject: subject ?? this.subject,
        questionText: questionText ?? this.questionText,
        correctAnswer:
            correctAnswer.present ? correctAnswer.value : this.correctAnswer,
        myThinking: myThinking.present ? myThinking.value : this.myThinking,
        errorNotes: errorNotes.present ? errorNotes.value : this.errorNotes,
        mistakeDate: mistakeDate ?? this.mistakeDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        formalizedAt:
            formalizedAt.present ? formalizedAt.value : this.formalizedAt,
        isArchived: isArchived ?? this.isArchived,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        version: version ?? this.version,
      );
  MistakeQuestion copyWithCompanion(MistakeQuestionsCompanion data) {
    return MistakeQuestion(
      id: data.id.present ? data.id.value : this.id,
      subject: data.subject.present ? data.subject.value : this.subject,
      questionText: data.questionText.present
          ? data.questionText.value
          : this.questionText,
      correctAnswer: data.correctAnswer.present
          ? data.correctAnswer.value
          : this.correctAnswer,
      myThinking:
          data.myThinking.present ? data.myThinking.value : this.myThinking,
      errorNotes:
          data.errorNotes.present ? data.errorNotes.value : this.errorNotes,
      mistakeDate:
          data.mistakeDate.present ? data.mistakeDate.value : this.mistakeDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      formalizedAt: data.formalizedAt.present
          ? data.formalizedAt.value
          : this.formalizedAt,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MistakeQuestion(')
          ..write('id: $id, ')
          ..write('subject: $subject, ')
          ..write('questionText: $questionText, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('myThinking: $myThinking, ')
          ..write('errorNotes: $errorNotes, ')
          ..write('mistakeDate: $mistakeDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('formalizedAt: $formalizedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      subject,
      questionText,
      correctAnswer,
      myThinking,
      errorNotes,
      mistakeDate,
      createdAt,
      updatedAt,
      formalizedAt,
      isArchived,
      deletedAt,
      version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MistakeQuestion &&
          other.id == this.id &&
          other.subject == this.subject &&
          other.questionText == this.questionText &&
          other.correctAnswer == this.correctAnswer &&
          other.myThinking == this.myThinking &&
          other.errorNotes == this.errorNotes &&
          other.mistakeDate == this.mistakeDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.formalizedAt == this.formalizedAt &&
          other.isArchived == this.isArchived &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version);
}

class MistakeQuestionsCompanion extends UpdateCompanion<MistakeQuestion> {
  final Value<String> id;
  final Value<String> subject;
  final Value<String> questionText;
  final Value<String?> correctAnswer;
  final Value<String?> myThinking;
  final Value<String?> errorNotes;
  final Value<DateTime> mistakeDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> formalizedAt;
  final Value<bool> isArchived;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<int> rowid;
  const MistakeQuestionsCompanion({
    this.id = const Value.absent(),
    this.subject = const Value.absent(),
    this.questionText = const Value.absent(),
    this.correctAnswer = const Value.absent(),
    this.myThinking = const Value.absent(),
    this.errorNotes = const Value.absent(),
    this.mistakeDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.formalizedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MistakeQuestionsCompanion.insert({
    required String id,
    required String subject,
    required String questionText,
    this.correctAnswer = const Value.absent(),
    this.myThinking = const Value.absent(),
    this.errorNotes = const Value.absent(),
    required DateTime mistakeDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.formalizedAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        subject = Value(subject),
        questionText = Value(questionText),
        mistakeDate = Value(mistakeDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<MistakeQuestion> custom({
    Expression<String>? id,
    Expression<String>? subject,
    Expression<String>? questionText,
    Expression<String>? correctAnswer,
    Expression<String>? myThinking,
    Expression<String>? errorNotes,
    Expression<DateTime>? mistakeDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? formalizedAt,
    Expression<bool>? isArchived,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subject != null) 'subject': subject,
      if (questionText != null) 'question_text': questionText,
      if (correctAnswer != null) 'correct_answer': correctAnswer,
      if (myThinking != null) 'my_thinking': myThinking,
      if (errorNotes != null) 'error_notes': errorNotes,
      if (mistakeDate != null) 'mistake_date': mistakeDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (formalizedAt != null) 'formalized_at': formalizedAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MistakeQuestionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? subject,
      Value<String>? questionText,
      Value<String?>? correctAnswer,
      Value<String?>? myThinking,
      Value<String?>? errorNotes,
      Value<DateTime>? mistakeDate,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? formalizedAt,
      Value<bool>? isArchived,
      Value<DateTime?>? deletedAt,
      Value<int>? version,
      Value<int>? rowid}) {
    return MistakeQuestionsCompanion(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      questionText: questionText ?? this.questionText,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      myThinking: myThinking ?? this.myThinking,
      errorNotes: errorNotes ?? this.errorNotes,
      mistakeDate: mistakeDate ?? this.mistakeDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      formalizedAt: formalizedAt ?? this.formalizedAt,
      isArchived: isArchived ?? this.isArchived,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
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
    if (questionText.present) {
      map['question_text'] = Variable<String>(questionText.value);
    }
    if (correctAnswer.present) {
      map['correct_answer'] = Variable<String>(correctAnswer.value);
    }
    if (myThinking.present) {
      map['my_thinking'] = Variable<String>(myThinking.value);
    }
    if (errorNotes.present) {
      map['error_notes'] = Variable<String>(errorNotes.value);
    }
    if (mistakeDate.present) {
      map['mistake_date'] = Variable<DateTime>(mistakeDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (formalizedAt.present) {
      map['formalized_at'] = Variable<DateTime>(formalizedAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MistakeQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('subject: $subject, ')
          ..write('questionText: $questionText, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('myThinking: $myThinking, ')
          ..write('errorNotes: $errorNotes, ')
          ..write('mistakeDate: $mistakeDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('formalizedAt: $formalizedAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewCyclesTable extends ReviewCycles
    with TableInfo<$ReviewCyclesTable, ReviewCycle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewCyclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questionIdMeta =
      const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
      'question_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints:
          'NOT NULL REFERENCES mistake_questions(id) ON DELETE CASCADE');
  static const VerificationMeta _cycleNumberMeta =
      const VerificationMeta('cycleNumber');
  @override
  late final GeneratedColumn<int> cycleNumber = GeneratedColumn<int>(
      'cycle_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _kLevelMeta = const VerificationMeta('kLevel');
  @override
  late final GeneratedColumn<int> kLevel = GeneratedColumn<int>(
      'k_level', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
      'due_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        questionId,
        cycleNumber,
        kLevel,
        dueDate,
        isActive,
        version,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_cycles';
  @override
  VerificationContext validateIntegrity(Insertable<ReviewCycle> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
          _questionIdMeta,
          questionId.isAcceptableOrUnknown(
              data['question_id']!, _questionIdMeta));
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('cycle_number')) {
      context.handle(
          _cycleNumberMeta,
          cycleNumber.isAcceptableOrUnknown(
              data['cycle_number']!, _cycleNumberMeta));
    } else if (isInserting) {
      context.missing(_cycleNumberMeta);
    }
    if (data.containsKey('k_level')) {
      context.handle(_kLevelMeta,
          kLevel.isAcceptableOrUnknown(data['k_level']!, _kLevelMeta));
    } else if (isInserting) {
      context.missing(_kLevelMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewCycle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewCycle(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_id'])!,
      cycleNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cycle_number'])!,
      kLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}k_level'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}due_date']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ReviewCyclesTable createAlias(String alias) {
    return $ReviewCyclesTable(attachedDatabase, alias);
  }
}

class ReviewCycle extends DataClass implements Insertable<ReviewCycle> {
  final String id;
  final String questionId;
  final int cycleNumber;
  final int kLevel;
  final String? dueDate;
  final bool isActive;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ReviewCycle(
      {required this.id,
      required this.questionId,
      required this.cycleNumber,
      required this.kLevel,
      this.dueDate,
      required this.isActive,
      required this.version,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['question_id'] = Variable<String>(questionId);
    map['cycle_number'] = Variable<int>(cycleNumber);
    map['k_level'] = Variable<int>(kLevel);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<String>(dueDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReviewCyclesCompanion toCompanion(bool nullToAbsent) {
    return ReviewCyclesCompanion(
      id: Value(id),
      questionId: Value(questionId),
      cycleNumber: Value(cycleNumber),
      kLevel: Value(kLevel),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      isActive: Value(isActive),
      version: Value(version),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReviewCycle.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewCycle(
      id: serializer.fromJson<String>(json['id']),
      questionId: serializer.fromJson<String>(json['questionId']),
      cycleNumber: serializer.fromJson<int>(json['cycleNumber']),
      kLevel: serializer.fromJson<int>(json['kLevel']),
      dueDate: serializer.fromJson<String?>(json['dueDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'questionId': serializer.toJson<String>(questionId),
      'cycleNumber': serializer.toJson<int>(cycleNumber),
      'kLevel': serializer.toJson<int>(kLevel),
      'dueDate': serializer.toJson<String?>(dueDate),
      'isActive': serializer.toJson<bool>(isActive),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReviewCycle copyWith(
          {String? id,
          String? questionId,
          int? cycleNumber,
          int? kLevel,
          Value<String?> dueDate = const Value.absent(),
          bool? isActive,
          int? version,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ReviewCycle(
        id: id ?? this.id,
        questionId: questionId ?? this.questionId,
        cycleNumber: cycleNumber ?? this.cycleNumber,
        kLevel: kLevel ?? this.kLevel,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        isActive: isActive ?? this.isActive,
        version: version ?? this.version,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ReviewCycle copyWithCompanion(ReviewCyclesCompanion data) {
    return ReviewCycle(
      id: data.id.present ? data.id.value : this.id,
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      cycleNumber:
          data.cycleNumber.present ? data.cycleNumber.value : this.cycleNumber,
      kLevel: data.kLevel.present ? data.kLevel.value : this.kLevel,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewCycle(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('cycleNumber: $cycleNumber, ')
          ..write('kLevel: $kLevel, ')
          ..write('dueDate: $dueDate, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, questionId, cycleNumber, kLevel, dueDate,
      isActive, version, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewCycle &&
          other.id == this.id &&
          other.questionId == this.questionId &&
          other.cycleNumber == this.cycleNumber &&
          other.kLevel == this.kLevel &&
          other.dueDate == this.dueDate &&
          other.isActive == this.isActive &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ReviewCyclesCompanion extends UpdateCompanion<ReviewCycle> {
  final Value<String> id;
  final Value<String> questionId;
  final Value<int> cycleNumber;
  final Value<int> kLevel;
  final Value<String?> dueDate;
  final Value<bool> isActive;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ReviewCyclesCompanion({
    this.id = const Value.absent(),
    this.questionId = const Value.absent(),
    this.cycleNumber = const Value.absent(),
    this.kLevel = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewCyclesCompanion.insert({
    required String id,
    required String questionId,
    required int cycleNumber,
    required int kLevel,
    this.dueDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        questionId = Value(questionId),
        cycleNumber = Value(cycleNumber),
        kLevel = Value(kLevel),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ReviewCycle> custom({
    Expression<String>? id,
    Expression<String>? questionId,
    Expression<int>? cycleNumber,
    Expression<int>? kLevel,
    Expression<String>? dueDate,
    Expression<bool>? isActive,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionId != null) 'question_id': questionId,
      if (cycleNumber != null) 'cycle_number': cycleNumber,
      if (kLevel != null) 'k_level': kLevel,
      if (dueDate != null) 'due_date': dueDate,
      if (isActive != null) 'is_active': isActive,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewCyclesCompanion copyWith(
      {Value<String>? id,
      Value<String>? questionId,
      Value<int>? cycleNumber,
      Value<int>? kLevel,
      Value<String?>? dueDate,
      Value<bool>? isActive,
      Value<int>? version,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ReviewCyclesCompanion(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      cycleNumber: cycleNumber ?? this.cycleNumber,
      kLevel: kLevel ?? this.kLevel,
      dueDate: dueDate ?? this.dueDate,
      isActive: isActive ?? this.isActive,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (cycleNumber.present) {
      map['cycle_number'] = Variable<int>(cycleNumber.value);
    }
    if (kLevel.present) {
      map['k_level'] = Variable<int>(kLevel.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewCyclesCompanion(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('cycleNumber: $cycleNumber, ')
          ..write('kLevel: $kLevel, ')
          ..write('dueDate: $dueDate, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewEventsTable extends ReviewEvents
    with TableInfo<$ReviewEventsTable, ReviewEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questionIdMeta =
      const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
      'question_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cycleIdMeta =
      const VerificationMeta('cycleId');
  @override
  late final GeneratedColumn<String> cycleId = GeneratedColumn<String>(
      'cycle_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cycleNumberMeta =
      const VerificationMeta('cycleNumber');
  @override
  late final GeneratedColumn<int> cycleNumber = GeneratedColumn<int>(
      'cycle_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _learningDateMeta =
      const VerificationMeta('learningDate');
  @override
  late final GeneratedColumn<String> learningDate = GeneratedColumn<String>(
      'learning_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
      'result', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kLevelBeforeMeta =
      const VerificationMeta('kLevelBefore');
  @override
  late final GeneratedColumn<int> kLevelBefore = GeneratedColumn<int>(
      'k_level_before', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _kLevelAfterMeta =
      const VerificationMeta('kLevelAfter');
  @override
  late final GeneratedColumn<int> kLevelAfter = GeneratedColumn<int>(
      'k_level_after', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dueDateAfterMeta =
      const VerificationMeta('dueDateAfter');
  @override
  late final GeneratedColumn<String> dueDateAfter = GeneratedColumn<String>(
      'due_date_after', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        questionId,
        cycleId,
        cycleNumber,
        learningDate,
        result,
        kLevelBefore,
        kLevelAfter,
        dueDateAfter,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_events';
  @override
  VerificationContext validateIntegrity(Insertable<ReviewEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
          _questionIdMeta,
          questionId.isAcceptableOrUnknown(
              data['question_id']!, _questionIdMeta));
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('cycle_id')) {
      context.handle(_cycleIdMeta,
          cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta));
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    if (data.containsKey('cycle_number')) {
      context.handle(
          _cycleNumberMeta,
          cycleNumber.isAcceptableOrUnknown(
              data['cycle_number']!, _cycleNumberMeta));
    } else if (isInserting) {
      context.missing(_cycleNumberMeta);
    }
    if (data.containsKey('learning_date')) {
      context.handle(
          _learningDateMeta,
          learningDate.isAcceptableOrUnknown(
              data['learning_date']!, _learningDateMeta));
    } else if (isInserting) {
      context.missing(_learningDateMeta);
    }
    if (data.containsKey('result')) {
      context.handle(_resultMeta,
          result.isAcceptableOrUnknown(data['result']!, _resultMeta));
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('k_level_before')) {
      context.handle(
          _kLevelBeforeMeta,
          kLevelBefore.isAcceptableOrUnknown(
              data['k_level_before']!, _kLevelBeforeMeta));
    } else if (isInserting) {
      context.missing(_kLevelBeforeMeta);
    }
    if (data.containsKey('k_level_after')) {
      context.handle(
          _kLevelAfterMeta,
          kLevelAfter.isAcceptableOrUnknown(
              data['k_level_after']!, _kLevelAfterMeta));
    } else if (isInserting) {
      context.missing(_kLevelAfterMeta);
    }
    if (data.containsKey('due_date_after')) {
      context.handle(
          _dueDateAfterMeta,
          dueDateAfter.isAcceptableOrUnknown(
              data['due_date_after']!, _dueDateAfterMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {questionId, learningDate},
      ];
  @override
  ReviewEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_id'])!,
      cycleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cycle_id'])!,
      cycleNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cycle_number'])!,
      learningDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}learning_date'])!,
      result: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result'])!,
      kLevelBefore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}k_level_before'])!,
      kLevelAfter: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}k_level_after'])!,
      dueDateAfter: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}due_date_after']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ReviewEventsTable createAlias(String alias) {
    return $ReviewEventsTable(attachedDatabase, alias);
  }
}

class ReviewEvent extends DataClass implements Insertable<ReviewEvent> {
  final String id;
  final String questionId;
  final String cycleId;
  final int cycleNumber;
  final String learningDate;
  final String result;
  final int kLevelBefore;
  final int kLevelAfter;
  final String? dueDateAfter;
  final DateTime createdAt;
  const ReviewEvent(
      {required this.id,
      required this.questionId,
      required this.cycleId,
      required this.cycleNumber,
      required this.learningDate,
      required this.result,
      required this.kLevelBefore,
      required this.kLevelAfter,
      this.dueDateAfter,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['question_id'] = Variable<String>(questionId);
    map['cycle_id'] = Variable<String>(cycleId);
    map['cycle_number'] = Variable<int>(cycleNumber);
    map['learning_date'] = Variable<String>(learningDate);
    map['result'] = Variable<String>(result);
    map['k_level_before'] = Variable<int>(kLevelBefore);
    map['k_level_after'] = Variable<int>(kLevelAfter);
    if (!nullToAbsent || dueDateAfter != null) {
      map['due_date_after'] = Variable<String>(dueDateAfter);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReviewEventsCompanion toCompanion(bool nullToAbsent) {
    return ReviewEventsCompanion(
      id: Value(id),
      questionId: Value(questionId),
      cycleId: Value(cycleId),
      cycleNumber: Value(cycleNumber),
      learningDate: Value(learningDate),
      result: Value(result),
      kLevelBefore: Value(kLevelBefore),
      kLevelAfter: Value(kLevelAfter),
      dueDateAfter: dueDateAfter == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDateAfter),
      createdAt: Value(createdAt),
    );
  }

  factory ReviewEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewEvent(
      id: serializer.fromJson<String>(json['id']),
      questionId: serializer.fromJson<String>(json['questionId']),
      cycleId: serializer.fromJson<String>(json['cycleId']),
      cycleNumber: serializer.fromJson<int>(json['cycleNumber']),
      learningDate: serializer.fromJson<String>(json['learningDate']),
      result: serializer.fromJson<String>(json['result']),
      kLevelBefore: serializer.fromJson<int>(json['kLevelBefore']),
      kLevelAfter: serializer.fromJson<int>(json['kLevelAfter']),
      dueDateAfter: serializer.fromJson<String?>(json['dueDateAfter']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'questionId': serializer.toJson<String>(questionId),
      'cycleId': serializer.toJson<String>(cycleId),
      'cycleNumber': serializer.toJson<int>(cycleNumber),
      'learningDate': serializer.toJson<String>(learningDate),
      'result': serializer.toJson<String>(result),
      'kLevelBefore': serializer.toJson<int>(kLevelBefore),
      'kLevelAfter': serializer.toJson<int>(kLevelAfter),
      'dueDateAfter': serializer.toJson<String?>(dueDateAfter),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReviewEvent copyWith(
          {String? id,
          String? questionId,
          String? cycleId,
          int? cycleNumber,
          String? learningDate,
          String? result,
          int? kLevelBefore,
          int? kLevelAfter,
          Value<String?> dueDateAfter = const Value.absent(),
          DateTime? createdAt}) =>
      ReviewEvent(
        id: id ?? this.id,
        questionId: questionId ?? this.questionId,
        cycleId: cycleId ?? this.cycleId,
        cycleNumber: cycleNumber ?? this.cycleNumber,
        learningDate: learningDate ?? this.learningDate,
        result: result ?? this.result,
        kLevelBefore: kLevelBefore ?? this.kLevelBefore,
        kLevelAfter: kLevelAfter ?? this.kLevelAfter,
        dueDateAfter:
            dueDateAfter.present ? dueDateAfter.value : this.dueDateAfter,
        createdAt: createdAt ?? this.createdAt,
      );
  ReviewEvent copyWithCompanion(ReviewEventsCompanion data) {
    return ReviewEvent(
      id: data.id.present ? data.id.value : this.id,
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      cycleNumber:
          data.cycleNumber.present ? data.cycleNumber.value : this.cycleNumber,
      learningDate: data.learningDate.present
          ? data.learningDate.value
          : this.learningDate,
      result: data.result.present ? data.result.value : this.result,
      kLevelBefore: data.kLevelBefore.present
          ? data.kLevelBefore.value
          : this.kLevelBefore,
      kLevelAfter:
          data.kLevelAfter.present ? data.kLevelAfter.value : this.kLevelAfter,
      dueDateAfter: data.dueDateAfter.present
          ? data.dueDateAfter.value
          : this.dueDateAfter,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewEvent(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('cycleId: $cycleId, ')
          ..write('cycleNumber: $cycleNumber, ')
          ..write('learningDate: $learningDate, ')
          ..write('result: $result, ')
          ..write('kLevelBefore: $kLevelBefore, ')
          ..write('kLevelAfter: $kLevelAfter, ')
          ..write('dueDateAfter: $dueDateAfter, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, questionId, cycleId, cycleNumber,
      learningDate, result, kLevelBefore, kLevelAfter, dueDateAfter, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewEvent &&
          other.id == this.id &&
          other.questionId == this.questionId &&
          other.cycleId == this.cycleId &&
          other.cycleNumber == this.cycleNumber &&
          other.learningDate == this.learningDate &&
          other.result == this.result &&
          other.kLevelBefore == this.kLevelBefore &&
          other.kLevelAfter == this.kLevelAfter &&
          other.dueDateAfter == this.dueDateAfter &&
          other.createdAt == this.createdAt);
}

class ReviewEventsCompanion extends UpdateCompanion<ReviewEvent> {
  final Value<String> id;
  final Value<String> questionId;
  final Value<String> cycleId;
  final Value<int> cycleNumber;
  final Value<String> learningDate;
  final Value<String> result;
  final Value<int> kLevelBefore;
  final Value<int> kLevelAfter;
  final Value<String?> dueDateAfter;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ReviewEventsCompanion({
    this.id = const Value.absent(),
    this.questionId = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.cycleNumber = const Value.absent(),
    this.learningDate = const Value.absent(),
    this.result = const Value.absent(),
    this.kLevelBefore = const Value.absent(),
    this.kLevelAfter = const Value.absent(),
    this.dueDateAfter = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewEventsCompanion.insert({
    required String id,
    required String questionId,
    required String cycleId,
    required int cycleNumber,
    required String learningDate,
    required String result,
    required int kLevelBefore,
    required int kLevelAfter,
    this.dueDateAfter = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        questionId = Value(questionId),
        cycleId = Value(cycleId),
        cycleNumber = Value(cycleNumber),
        learningDate = Value(learningDate),
        result = Value(result),
        kLevelBefore = Value(kLevelBefore),
        kLevelAfter = Value(kLevelAfter),
        createdAt = Value(createdAt);
  static Insertable<ReviewEvent> custom({
    Expression<String>? id,
    Expression<String>? questionId,
    Expression<String>? cycleId,
    Expression<int>? cycleNumber,
    Expression<String>? learningDate,
    Expression<String>? result,
    Expression<int>? kLevelBefore,
    Expression<int>? kLevelAfter,
    Expression<String>? dueDateAfter,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionId != null) 'question_id': questionId,
      if (cycleId != null) 'cycle_id': cycleId,
      if (cycleNumber != null) 'cycle_number': cycleNumber,
      if (learningDate != null) 'learning_date': learningDate,
      if (result != null) 'result': result,
      if (kLevelBefore != null) 'k_level_before': kLevelBefore,
      if (kLevelAfter != null) 'k_level_after': kLevelAfter,
      if (dueDateAfter != null) 'due_date_after': dueDateAfter,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? questionId,
      Value<String>? cycleId,
      Value<int>? cycleNumber,
      Value<String>? learningDate,
      Value<String>? result,
      Value<int>? kLevelBefore,
      Value<int>? kLevelAfter,
      Value<String?>? dueDateAfter,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ReviewEventsCompanion(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      cycleId: cycleId ?? this.cycleId,
      cycleNumber: cycleNumber ?? this.cycleNumber,
      learningDate: learningDate ?? this.learningDate,
      result: result ?? this.result,
      kLevelBefore: kLevelBefore ?? this.kLevelBefore,
      kLevelAfter: kLevelAfter ?? this.kLevelAfter,
      dueDateAfter: dueDateAfter ?? this.dueDateAfter,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<String>(cycleId.value);
    }
    if (cycleNumber.present) {
      map['cycle_number'] = Variable<int>(cycleNumber.value);
    }
    if (learningDate.present) {
      map['learning_date'] = Variable<String>(learningDate.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (kLevelBefore.present) {
      map['k_level_before'] = Variable<int>(kLevelBefore.value);
    }
    if (kLevelAfter.present) {
      map['k_level_after'] = Variable<int>(kLevelAfter.value);
    }
    if (dueDateAfter.present) {
      map['due_date_after'] = Variable<String>(dueDateAfter.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewEventsCompanion(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('cycleId: $cycleId, ')
          ..write('cycleNumber: $cycleNumber, ')
          ..write('learningDate: $learningDate, ')
          ..write('result: $result, ')
          ..write('kLevelBefore: $kLevelBefore, ')
          ..write('kLevelAfter: $kLevelAfter, ')
          ..write('dueDateAfter: $dueDateAfter, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MistakeAgainMarksTable extends MistakeAgainMarks
    with TableInfo<$MistakeAgainMarksTable, MistakeAgainMark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MistakeAgainMarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questionIdMeta =
      const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
      'question_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationDateMeta =
      const VerificationMeta('operationDate');
  @override
  late final GeneratedColumn<String> operationDate = GeneratedColumn<String>(
      'operation_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _newCycleNumberMeta =
      const VerificationMeta('newCycleNumber');
  @override
  late final GeneratedColumn<int> newCycleNumber = GeneratedColumn<int>(
      'new_cycle_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, questionId, operationDate, newCycleNumber, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mistake_again_marks';
  @override
  VerificationContext validateIntegrity(Insertable<MistakeAgainMark> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
          _questionIdMeta,
          questionId.isAcceptableOrUnknown(
              data['question_id']!, _questionIdMeta));
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('operation_date')) {
      context.handle(
          _operationDateMeta,
          operationDate.isAcceptableOrUnknown(
              data['operation_date']!, _operationDateMeta));
    } else if (isInserting) {
      context.missing(_operationDateMeta);
    }
    if (data.containsKey('new_cycle_number')) {
      context.handle(
          _newCycleNumberMeta,
          newCycleNumber.isAcceptableOrUnknown(
              data['new_cycle_number']!, _newCycleNumberMeta));
    } else if (isInserting) {
      context.missing(_newCycleNumberMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {questionId, operationDate},
      ];
  @override
  MistakeAgainMark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MistakeAgainMark(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_id'])!,
      operationDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation_date'])!,
      newCycleNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}new_cycle_number'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MistakeAgainMarksTable createAlias(String alias) {
    return $MistakeAgainMarksTable(attachedDatabase, alias);
  }
}

class MistakeAgainMark extends DataClass
    implements Insertable<MistakeAgainMark> {
  final String id;
  final String questionId;
  final String operationDate;
  final int newCycleNumber;
  final DateTime createdAt;
  const MistakeAgainMark(
      {required this.id,
      required this.questionId,
      required this.operationDate,
      required this.newCycleNumber,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['question_id'] = Variable<String>(questionId);
    map['operation_date'] = Variable<String>(operationDate);
    map['new_cycle_number'] = Variable<int>(newCycleNumber);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MistakeAgainMarksCompanion toCompanion(bool nullToAbsent) {
    return MistakeAgainMarksCompanion(
      id: Value(id),
      questionId: Value(questionId),
      operationDate: Value(operationDate),
      newCycleNumber: Value(newCycleNumber),
      createdAt: Value(createdAt),
    );
  }

  factory MistakeAgainMark.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MistakeAgainMark(
      id: serializer.fromJson<String>(json['id']),
      questionId: serializer.fromJson<String>(json['questionId']),
      operationDate: serializer.fromJson<String>(json['operationDate']),
      newCycleNumber: serializer.fromJson<int>(json['newCycleNumber']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'questionId': serializer.toJson<String>(questionId),
      'operationDate': serializer.toJson<String>(operationDate),
      'newCycleNumber': serializer.toJson<int>(newCycleNumber),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MistakeAgainMark copyWith(
          {String? id,
          String? questionId,
          String? operationDate,
          int? newCycleNumber,
          DateTime? createdAt}) =>
      MistakeAgainMark(
        id: id ?? this.id,
        questionId: questionId ?? this.questionId,
        operationDate: operationDate ?? this.operationDate,
        newCycleNumber: newCycleNumber ?? this.newCycleNumber,
        createdAt: createdAt ?? this.createdAt,
      );
  MistakeAgainMark copyWithCompanion(MistakeAgainMarksCompanion data) {
    return MistakeAgainMark(
      id: data.id.present ? data.id.value : this.id,
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      operationDate: data.operationDate.present
          ? data.operationDate.value
          : this.operationDate,
      newCycleNumber: data.newCycleNumber.present
          ? data.newCycleNumber.value
          : this.newCycleNumber,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MistakeAgainMark(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('operationDate: $operationDate, ')
          ..write('newCycleNumber: $newCycleNumber, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, questionId, operationDate, newCycleNumber, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MistakeAgainMark &&
          other.id == this.id &&
          other.questionId == this.questionId &&
          other.operationDate == this.operationDate &&
          other.newCycleNumber == this.newCycleNumber &&
          other.createdAt == this.createdAt);
}

class MistakeAgainMarksCompanion extends UpdateCompanion<MistakeAgainMark> {
  final Value<String> id;
  final Value<String> questionId;
  final Value<String> operationDate;
  final Value<int> newCycleNumber;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MistakeAgainMarksCompanion({
    this.id = const Value.absent(),
    this.questionId = const Value.absent(),
    this.operationDate = const Value.absent(),
    this.newCycleNumber = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MistakeAgainMarksCompanion.insert({
    required String id,
    required String questionId,
    required String operationDate,
    required int newCycleNumber,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        questionId = Value(questionId),
        operationDate = Value(operationDate),
        newCycleNumber = Value(newCycleNumber),
        createdAt = Value(createdAt);
  static Insertable<MistakeAgainMark> custom({
    Expression<String>? id,
    Expression<String>? questionId,
    Expression<String>? operationDate,
    Expression<int>? newCycleNumber,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionId != null) 'question_id': questionId,
      if (operationDate != null) 'operation_date': operationDate,
      if (newCycleNumber != null) 'new_cycle_number': newCycleNumber,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MistakeAgainMarksCompanion copyWith(
      {Value<String>? id,
      Value<String>? questionId,
      Value<String>? operationDate,
      Value<int>? newCycleNumber,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return MistakeAgainMarksCompanion(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      operationDate: operationDate ?? this.operationDate,
      newCycleNumber: newCycleNumber ?? this.newCycleNumber,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (operationDate.present) {
      map['operation_date'] = Variable<String>(operationDate.value);
    }
    if (newCycleNumber.present) {
      map['new_cycle_number'] = Variable<int>(newCycleNumber.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MistakeAgainMarksCompanion(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('operationDate: $operationDate, ')
          ..write('newCycleNumber: $newCycleNumber, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyPlansTable extends DailyPlans
    with TableInfo<$DailyPlansTable, DailyPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _learningDateMeta =
      const VerificationMeta('learningDate');
  @override
  late final GeneratedColumn<String> learningDate = GeneratedColumn<String>(
      'learning_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetNMeta =
      const VerificationMeta('targetN');
  @override
  late final GeneratedColumn<int> targetN = GeneratedColumn<int>(
      'target_n', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _capacityCMeta =
      const VerificationMeta('capacityC');
  @override
  late final GeneratedColumn<int> capacityC = GeneratedColumn<int>(
      'capacity_c', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, learningDate, targetN, capacityC, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_plans';
  @override
  VerificationContext validateIntegrity(Insertable<DailyPlan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('learning_date')) {
      context.handle(
          _learningDateMeta,
          learningDate.isAcceptableOrUnknown(
              data['learning_date']!, _learningDateMeta));
    } else if (isInserting) {
      context.missing(_learningDateMeta);
    }
    if (data.containsKey('target_n')) {
      context.handle(_targetNMeta,
          targetN.isAcceptableOrUnknown(data['target_n']!, _targetNMeta));
    } else if (isInserting) {
      context.missing(_targetNMeta);
    }
    if (data.containsKey('capacity_c')) {
      context.handle(_capacityCMeta,
          capacityC.isAcceptableOrUnknown(data['capacity_c']!, _capacityCMeta));
    } else if (isInserting) {
      context.missing(_capacityCMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {learningDate},
      ];
  @override
  DailyPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyPlan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      learningDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}learning_date'])!,
      targetN: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_n'])!,
      capacityC: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}capacity_c'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DailyPlansTable createAlias(String alias) {
    return $DailyPlansTable(attachedDatabase, alias);
  }
}

class DailyPlan extends DataClass implements Insertable<DailyPlan> {
  final String id;
  final String learningDate;
  final int targetN;
  final int capacityC;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DailyPlan(
      {required this.id,
      required this.learningDate,
      required this.targetN,
      required this.capacityC,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['learning_date'] = Variable<String>(learningDate);
    map['target_n'] = Variable<int>(targetN);
    map['capacity_c'] = Variable<int>(capacityC);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyPlansCompanion toCompanion(bool nullToAbsent) {
    return DailyPlansCompanion(
      id: Value(id),
      learningDate: Value(learningDate),
      targetN: Value(targetN),
      capacityC: Value(capacityC),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyPlan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyPlan(
      id: serializer.fromJson<String>(json['id']),
      learningDate: serializer.fromJson<String>(json['learningDate']),
      targetN: serializer.fromJson<int>(json['targetN']),
      capacityC: serializer.fromJson<int>(json['capacityC']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'learningDate': serializer.toJson<String>(learningDate),
      'targetN': serializer.toJson<int>(targetN),
      'capacityC': serializer.toJson<int>(capacityC),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyPlan copyWith(
          {String? id,
          String? learningDate,
          int? targetN,
          int? capacityC,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DailyPlan(
        id: id ?? this.id,
        learningDate: learningDate ?? this.learningDate,
        targetN: targetN ?? this.targetN,
        capacityC: capacityC ?? this.capacityC,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DailyPlan copyWithCompanion(DailyPlansCompanion data) {
    return DailyPlan(
      id: data.id.present ? data.id.value : this.id,
      learningDate: data.learningDate.present
          ? data.learningDate.value
          : this.learningDate,
      targetN: data.targetN.present ? data.targetN.value : this.targetN,
      capacityC: data.capacityC.present ? data.capacityC.value : this.capacityC,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyPlan(')
          ..write('id: $id, ')
          ..write('learningDate: $learningDate, ')
          ..write('targetN: $targetN, ')
          ..write('capacityC: $capacityC, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, learningDate, targetN, capacityC, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyPlan &&
          other.id == this.id &&
          other.learningDate == this.learningDate &&
          other.targetN == this.targetN &&
          other.capacityC == this.capacityC &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DailyPlansCompanion extends UpdateCompanion<DailyPlan> {
  final Value<String> id;
  final Value<String> learningDate;
  final Value<int> targetN;
  final Value<int> capacityC;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DailyPlansCompanion({
    this.id = const Value.absent(),
    this.learningDate = const Value.absent(),
    this.targetN = const Value.absent(),
    this.capacityC = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyPlansCompanion.insert({
    required String id,
    required String learningDate,
    required int targetN,
    required int capacityC,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        learningDate = Value(learningDate),
        targetN = Value(targetN),
        capacityC = Value(capacityC),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DailyPlan> custom({
    Expression<String>? id,
    Expression<String>? learningDate,
    Expression<int>? targetN,
    Expression<int>? capacityC,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (learningDate != null) 'learning_date': learningDate,
      if (targetN != null) 'target_n': targetN,
      if (capacityC != null) 'capacity_c': capacityC,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyPlansCompanion copyWith(
      {Value<String>? id,
      Value<String>? learningDate,
      Value<int>? targetN,
      Value<int>? capacityC,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return DailyPlansCompanion(
      id: id ?? this.id,
      learningDate: learningDate ?? this.learningDate,
      targetN: targetN ?? this.targetN,
      capacityC: capacityC ?? this.capacityC,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (learningDate.present) {
      map['learning_date'] = Variable<String>(learningDate.value);
    }
    if (targetN.present) {
      map['target_n'] = Variable<int>(targetN.value);
    }
    if (capacityC.present) {
      map['capacity_c'] = Variable<int>(capacityC.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyPlansCompanion(')
          ..write('id: $id, ')
          ..write('learningDate: $learningDate, ')
          ..write('targetN: $targetN, ')
          ..write('capacityC: $capacityC, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyPlanMembersTable extends DailyPlanMembers
    with TableInfo<$DailyPlanMembersTable, DailyPlanMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyPlanMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
      'plan_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints:
          'NOT NULL REFERENCES daily_plans(id) ON DELETE CASCADE');
  static const VerificationMeta _questionIdMeta =
      const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
      'question_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isSkippedMeta =
      const VerificationMeta('isSkipped');
  @override
  late final GeneratedColumn<bool> isSkipped = GeneratedColumn<bool>(
      'is_skipped', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_skipped" IN (0, 1))'),
      defaultValue: const Constant(false));
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        planId,
        questionId,
        orderIndex,
        isCompleted,
        isSkipped,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_plan_members';
  @override
  VerificationContext validateIntegrity(Insertable<DailyPlanMember> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(_planIdMeta,
          planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta));
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
          _questionIdMeta,
          questionId.isAcceptableOrUnknown(
              data['question_id']!, _questionIdMeta));
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('is_skipped')) {
      context.handle(_isSkippedMeta,
          isSkipped.isAcceptableOrUnknown(data['is_skipped']!, _isSkippedMeta));
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {planId, questionId},
      ];
  @override
  DailyPlanMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyPlanMember(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      planId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan_id'])!,
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_id'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      isSkipped: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_skipped'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DailyPlanMembersTable createAlias(String alias) {
    return $DailyPlanMembersTable(attachedDatabase, alias);
  }
}

class DailyPlanMember extends DataClass implements Insertable<DailyPlanMember> {
  final String id;
  final String planId;
  final String questionId;
  final int orderIndex;
  final bool isCompleted;
  final bool isSkipped;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DailyPlanMember(
      {required this.id,
      required this.planId,
      required this.questionId,
      required this.orderIndex,
      required this.isCompleted,
      required this.isSkipped,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['question_id'] = Variable<String>(questionId);
    map['order_index'] = Variable<int>(orderIndex);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['is_skipped'] = Variable<bool>(isSkipped);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailyPlanMembersCompanion toCompanion(bool nullToAbsent) {
    return DailyPlanMembersCompanion(
      id: Value(id),
      planId: Value(planId),
      questionId: Value(questionId),
      orderIndex: Value(orderIndex),
      isCompleted: Value(isCompleted),
      isSkipped: Value(isSkipped),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyPlanMember.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyPlanMember(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      isSkipped: serializer.fromJson<bool>(json['isSkipped']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'questionId': serializer.toJson<String>(questionId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'isSkipped': serializer.toJson<bool>(isSkipped),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailyPlanMember copyWith(
          {String? id,
          String? planId,
          String? questionId,
          int? orderIndex,
          bool? isCompleted,
          bool? isSkipped,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DailyPlanMember(
        id: id ?? this.id,
        planId: planId ?? this.planId,
        questionId: questionId ?? this.questionId,
        orderIndex: orderIndex ?? this.orderIndex,
        isCompleted: isCompleted ?? this.isCompleted,
        isSkipped: isSkipped ?? this.isSkipped,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DailyPlanMember copyWithCompanion(DailyPlanMembersCompanion data) {
    return DailyPlanMember(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      isSkipped: data.isSkipped.present ? data.isSkipped.value : this.isSkipped,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyPlanMember(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('questionId: $questionId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isSkipped: $isSkipped, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, planId, questionId, orderIndex,
      isCompleted, isSkipped, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyPlanMember &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.questionId == this.questionId &&
          other.orderIndex == this.orderIndex &&
          other.isCompleted == this.isCompleted &&
          other.isSkipped == this.isSkipped &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DailyPlanMembersCompanion extends UpdateCompanion<DailyPlanMember> {
  final Value<String> id;
  final Value<String> planId;
  final Value<String> questionId;
  final Value<int> orderIndex;
  final Value<bool> isCompleted;
  final Value<bool> isSkipped;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DailyPlanMembersCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isSkipped = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyPlanMembersCompanion.insert({
    required String id,
    required String planId,
    required String questionId,
    required int orderIndex,
    this.isCompleted = const Value.absent(),
    this.isSkipped = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        planId = Value(planId),
        questionId = Value(questionId),
        orderIndex = Value(orderIndex),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DailyPlanMember> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<String>? questionId,
    Expression<int>? orderIndex,
    Expression<bool>? isCompleted,
    Expression<bool>? isSkipped,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (questionId != null) 'question_id': questionId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (isSkipped != null) 'is_skipped': isSkipped,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyPlanMembersCompanion copyWith(
      {Value<String>? id,
      Value<String>? planId,
      Value<String>? questionId,
      Value<int>? orderIndex,
      Value<bool>? isCompleted,
      Value<bool>? isSkipped,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return DailyPlanMembersCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      questionId: questionId ?? this.questionId,
      orderIndex: orderIndex ?? this.orderIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      isSkipped: isSkipped ?? this.isSkipped,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (isSkipped.present) {
      map['is_skipped'] = Variable<bool>(isSkipped.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyPlanMembersCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('questionId: $questionId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isSkipped: $isSkipped, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dailyTargetNMeta =
      const VerificationMeta('dailyTargetN');
  @override
  late final GeneratedColumn<int> dailyTargetN = GeneratedColumn<int>(
      'daily_target_n', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(20));
  static const VerificationMeta _dailyTargetUpdatedAtMeta =
      const VerificationMeta('dailyTargetUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> dailyTargetUpdatedAt =
      GeneratedColumn<DateTime>('daily_target_updated_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastBackupAtMeta =
      const VerificationMeta('lastBackupAt');
  @override
  late final GeneratedColumn<DateTime> lastBackupAt = GeneratedColumn<DateTime>(
      'last_backup_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        dailyTargetN,
        dailyTargetUpdatedAt,
        lastBackupAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('daily_target_n')) {
      context.handle(
          _dailyTargetNMeta,
          dailyTargetN.isAcceptableOrUnknown(
              data['daily_target_n']!, _dailyTargetNMeta));
    }
    if (data.containsKey('daily_target_updated_at')) {
      context.handle(
          _dailyTargetUpdatedAtMeta,
          dailyTargetUpdatedAt.isAcceptableOrUnknown(
              data['daily_target_updated_at']!, _dailyTargetUpdatedAtMeta));
    }
    if (data.containsKey('last_backup_at')) {
      context.handle(
          _lastBackupAtMeta,
          lastBackupAt.isAcceptableOrUnknown(
              data['last_backup_at']!, _lastBackupAtMeta));
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      dailyTargetN: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}daily_target_n'])!,
      dailyTargetUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}daily_target_updated_at']),
      lastBackupAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_backup_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final int dailyTargetN;
  final DateTime? dailyTargetUpdatedAt;
  final DateTime? lastBackupAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Setting(
      {required this.id,
      required this.dailyTargetN,
      this.dailyTargetUpdatedAt,
      this.lastBackupAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['daily_target_n'] = Variable<int>(dailyTargetN);
    if (!nullToAbsent || dailyTargetUpdatedAt != null) {
      map['daily_target_updated_at'] = Variable<DateTime>(dailyTargetUpdatedAt);
    }
    if (!nullToAbsent || lastBackupAt != null) {
      map['last_backup_at'] = Variable<DateTime>(lastBackupAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      dailyTargetN: Value(dailyTargetN),
      dailyTargetUpdatedAt: dailyTargetUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyTargetUpdatedAt),
      lastBackupAt: lastBackupAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBackupAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      dailyTargetN: serializer.fromJson<int>(json['dailyTargetN']),
      dailyTargetUpdatedAt:
          serializer.fromJson<DateTime?>(json['dailyTargetUpdatedAt']),
      lastBackupAt: serializer.fromJson<DateTime?>(json['lastBackupAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dailyTargetN': serializer.toJson<int>(dailyTargetN),
      'dailyTargetUpdatedAt':
          serializer.toJson<DateTime?>(dailyTargetUpdatedAt),
      'lastBackupAt': serializer.toJson<DateTime?>(lastBackupAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Setting copyWith(
          {int? id,
          int? dailyTargetN,
          Value<DateTime?> dailyTargetUpdatedAt = const Value.absent(),
          Value<DateTime?> lastBackupAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Setting(
        id: id ?? this.id,
        dailyTargetN: dailyTargetN ?? this.dailyTargetN,
        dailyTargetUpdatedAt: dailyTargetUpdatedAt.present
            ? dailyTargetUpdatedAt.value
            : this.dailyTargetUpdatedAt,
        lastBackupAt:
            lastBackupAt.present ? lastBackupAt.value : this.lastBackupAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      dailyTargetN: data.dailyTargetN.present
          ? data.dailyTargetN.value
          : this.dailyTargetN,
      dailyTargetUpdatedAt: data.dailyTargetUpdatedAt.present
          ? data.dailyTargetUpdatedAt.value
          : this.dailyTargetUpdatedAt,
      lastBackupAt: data.lastBackupAt.present
          ? data.lastBackupAt.value
          : this.lastBackupAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('dailyTargetN: $dailyTargetN, ')
          ..write('dailyTargetUpdatedAt: $dailyTargetUpdatedAt, ')
          ..write('lastBackupAt: $lastBackupAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dailyTargetN, dailyTargetUpdatedAt,
      lastBackupAt, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.dailyTargetN == this.dailyTargetN &&
          other.dailyTargetUpdatedAt == this.dailyTargetUpdatedAt &&
          other.lastBackupAt == this.lastBackupAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<int> dailyTargetN;
  final Value<DateTime?> dailyTargetUpdatedAt;
  final Value<DateTime?> lastBackupAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.dailyTargetN = const Value.absent(),
    this.dailyTargetUpdatedAt = const Value.absent(),
    this.lastBackupAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.dailyTargetN = const Value.absent(),
    this.dailyTargetUpdatedAt = const Value.absent(),
    this.lastBackupAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<int>? dailyTargetN,
    Expression<DateTime>? dailyTargetUpdatedAt,
    Expression<DateTime>? lastBackupAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dailyTargetN != null) 'daily_target_n': dailyTargetN,
      if (dailyTargetUpdatedAt != null)
        'daily_target_updated_at': dailyTargetUpdatedAt,
      if (lastBackupAt != null) 'last_backup_at': lastBackupAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SettingsCompanion copyWith(
      {Value<int>? id,
      Value<int>? dailyTargetN,
      Value<DateTime?>? dailyTargetUpdatedAt,
      Value<DateTime?>? lastBackupAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return SettingsCompanion(
      id: id ?? this.id,
      dailyTargetN: dailyTargetN ?? this.dailyTargetN,
      dailyTargetUpdatedAt: dailyTargetUpdatedAt ?? this.dailyTargetUpdatedAt,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dailyTargetN.present) {
      map['daily_target_n'] = Variable<int>(dailyTargetN.value);
    }
    if (dailyTargetUpdatedAt.present) {
      map['daily_target_updated_at'] =
          Variable<DateTime>(dailyTargetUpdatedAt.value);
    }
    if (lastBackupAt.present) {
      map['last_backup_at'] = Variable<DateTime>(lastBackupAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('dailyTargetN: $dailyTargetN, ')
          ..write('dailyTargetUpdatedAt: $dailyTargetUpdatedAt, ')
          ..write('lastBackupAt: $lastBackupAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ErrorQuestionsTable errorQuestions = $ErrorQuestionsTable(this);
  late final $MistakeQuestionsTable mistakeQuestions =
      $MistakeQuestionsTable(this);
  late final $ReviewCyclesTable reviewCycles = $ReviewCyclesTable(this);
  late final $ReviewEventsTable reviewEvents = $ReviewEventsTable(this);
  late final $MistakeAgainMarksTable mistakeAgainMarks =
      $MistakeAgainMarksTable(this);
  late final $DailyPlansTable dailyPlans = $DailyPlansTable(this);
  late final $DailyPlanMembersTable dailyPlanMembers =
      $DailyPlanMembersTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        errorQuestions,
        mistakeQuestions,
        reviewCycles,
        reviewEvents,
        mistakeAgainMarks,
        dailyPlans,
        dailyPlanMembers,
        settings
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('mistake_questions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('review_cycles', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('daily_plans',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('daily_plan_members', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
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
typedef $$MistakeQuestionsTableCreateCompanionBuilder
    = MistakeQuestionsCompanion Function({
  required String id,
  required String subject,
  required String questionText,
  Value<String?> correctAnswer,
  Value<String?> myThinking,
  Value<String?> errorNotes,
  required DateTime mistakeDate,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> formalizedAt,
  Value<bool> isArchived,
  Value<DateTime?> deletedAt,
  Value<int> version,
  Value<int> rowid,
});
typedef $$MistakeQuestionsTableUpdateCompanionBuilder
    = MistakeQuestionsCompanion Function({
  Value<String> id,
  Value<String> subject,
  Value<String> questionText,
  Value<String?> correctAnswer,
  Value<String?> myThinking,
  Value<String?> errorNotes,
  Value<DateTime> mistakeDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> formalizedAt,
  Value<bool> isArchived,
  Value<DateTime?> deletedAt,
  Value<int> version,
  Value<int> rowid,
});

final class $$MistakeQuestionsTableReferences extends BaseReferences<
    _$AppDatabase, $MistakeQuestionsTable, MistakeQuestion> {
  $$MistakeQuestionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReviewCyclesTable, List<ReviewCycle>>
      _reviewCyclesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.reviewCycles,
              aliasName: $_aliasNameGenerator(
                  db.mistakeQuestions.id, db.reviewCycles.questionId));

  $$ReviewCyclesTableProcessedTableManager get reviewCyclesRefs {
    final manager = $$ReviewCyclesTableTableManager($_db, $_db.reviewCycles)
        .filter((f) => f.questionId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_reviewCyclesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MistakeQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $MistakeQuestionsTable> {
  $$MistakeQuestionsTableFilterComposer({
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

  ColumnFilters<String> get questionText => $composableBuilder(
      column: $table.questionText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get correctAnswer => $composableBuilder(
      column: $table.correctAnswer, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get myThinking => $composableBuilder(
      column: $table.myThinking, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorNotes => $composableBuilder(
      column: $table.errorNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get mistakeDate => $composableBuilder(
      column: $table.mistakeDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get formalizedAt => $composableBuilder(
      column: $table.formalizedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  Expression<bool> reviewCyclesRefs(
      Expression<bool> Function($$ReviewCyclesTableFilterComposer f) f) {
    final $$ReviewCyclesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reviewCycles,
        getReferencedColumn: (t) => t.questionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReviewCyclesTableFilterComposer(
              $db: $db,
              $table: $db.reviewCycles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MistakeQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MistakeQuestionsTable> {
  $$MistakeQuestionsTableOrderingComposer({
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

  ColumnOrderings<String> get questionText => $composableBuilder(
      column: $table.questionText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get correctAnswer => $composableBuilder(
      column: $table.correctAnswer,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get myThinking => $composableBuilder(
      column: $table.myThinking, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorNotes => $composableBuilder(
      column: $table.errorNotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get mistakeDate => $composableBuilder(
      column: $table.mistakeDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get formalizedAt => $composableBuilder(
      column: $table.formalizedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));
}

class $$MistakeQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MistakeQuestionsTable> {
  $$MistakeQuestionsTableAnnotationComposer({
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

  GeneratedColumn<String> get questionText => $composableBuilder(
      column: $table.questionText, builder: (column) => column);

  GeneratedColumn<String> get correctAnswer => $composableBuilder(
      column: $table.correctAnswer, builder: (column) => column);

  GeneratedColumn<String> get myThinking => $composableBuilder(
      column: $table.myThinking, builder: (column) => column);

  GeneratedColumn<String> get errorNotes => $composableBuilder(
      column: $table.errorNotes, builder: (column) => column);

  GeneratedColumn<DateTime> get mistakeDate => $composableBuilder(
      column: $table.mistakeDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get formalizedAt => $composableBuilder(
      column: $table.formalizedAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  Expression<T> reviewCyclesRefs<T extends Object>(
      Expression<T> Function($$ReviewCyclesTableAnnotationComposer a) f) {
    final $$ReviewCyclesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reviewCycles,
        getReferencedColumn: (t) => t.questionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReviewCyclesTableAnnotationComposer(
              $db: $db,
              $table: $db.reviewCycles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MistakeQuestionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MistakeQuestionsTable,
    MistakeQuestion,
    $$MistakeQuestionsTableFilterComposer,
    $$MistakeQuestionsTableOrderingComposer,
    $$MistakeQuestionsTableAnnotationComposer,
    $$MistakeQuestionsTableCreateCompanionBuilder,
    $$MistakeQuestionsTableUpdateCompanionBuilder,
    (MistakeQuestion, $$MistakeQuestionsTableReferences),
    MistakeQuestion,
    PrefetchHooks Function({bool reviewCyclesRefs})> {
  $$MistakeQuestionsTableTableManager(
      _$AppDatabase db, $MistakeQuestionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MistakeQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MistakeQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MistakeQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> subject = const Value.absent(),
            Value<String> questionText = const Value.absent(),
            Value<String?> correctAnswer = const Value.absent(),
            Value<String?> myThinking = const Value.absent(),
            Value<String?> errorNotes = const Value.absent(),
            Value<DateTime> mistakeDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> formalizedAt = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MistakeQuestionsCompanion(
            id: id,
            subject: subject,
            questionText: questionText,
            correctAnswer: correctAnswer,
            myThinking: myThinking,
            errorNotes: errorNotes,
            mistakeDate: mistakeDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            formalizedAt: formalizedAt,
            isArchived: isArchived,
            deletedAt: deletedAt,
            version: version,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String subject,
            required String questionText,
            Value<String?> correctAnswer = const Value.absent(),
            Value<String?> myThinking = const Value.absent(),
            Value<String?> errorNotes = const Value.absent(),
            required DateTime mistakeDate,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> formalizedAt = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MistakeQuestionsCompanion.insert(
            id: id,
            subject: subject,
            questionText: questionText,
            correctAnswer: correctAnswer,
            myThinking: myThinking,
            errorNotes: errorNotes,
            mistakeDate: mistakeDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            formalizedAt: formalizedAt,
            isArchived: isArchived,
            deletedAt: deletedAt,
            version: version,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MistakeQuestionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({reviewCyclesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (reviewCyclesRefs) db.reviewCycles],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (reviewCyclesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$MistakeQuestionsTableReferences
                            ._reviewCyclesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MistakeQuestionsTableReferences(db, table, p0)
                                .reviewCyclesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.questionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MistakeQuestionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MistakeQuestionsTable,
    MistakeQuestion,
    $$MistakeQuestionsTableFilterComposer,
    $$MistakeQuestionsTableOrderingComposer,
    $$MistakeQuestionsTableAnnotationComposer,
    $$MistakeQuestionsTableCreateCompanionBuilder,
    $$MistakeQuestionsTableUpdateCompanionBuilder,
    (MistakeQuestion, $$MistakeQuestionsTableReferences),
    MistakeQuestion,
    PrefetchHooks Function({bool reviewCyclesRefs})>;
typedef $$ReviewCyclesTableCreateCompanionBuilder = ReviewCyclesCompanion
    Function({
  required String id,
  required String questionId,
  required int cycleNumber,
  required int kLevel,
  Value<String?> dueDate,
  Value<bool> isActive,
  Value<int> version,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ReviewCyclesTableUpdateCompanionBuilder = ReviewCyclesCompanion
    Function({
  Value<String> id,
  Value<String> questionId,
  Value<int> cycleNumber,
  Value<int> kLevel,
  Value<String?> dueDate,
  Value<bool> isActive,
  Value<int> version,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ReviewCyclesTableReferences
    extends BaseReferences<_$AppDatabase, $ReviewCyclesTable, ReviewCycle> {
  $$ReviewCyclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MistakeQuestionsTable _questionIdTable(_$AppDatabase db) =>
      db.mistakeQuestions.createAlias($_aliasNameGenerator(
          db.reviewCycles.questionId, db.mistakeQuestions.id));

  $$MistakeQuestionsTableProcessedTableManager get questionId {
    final manager =
        $$MistakeQuestionsTableTableManager($_db, $_db.mistakeQuestions)
            .filter((f) => f.id($_item.questionId));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReviewCyclesTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewCyclesTable> {
  $$ReviewCyclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cycleNumber => $composableBuilder(
      column: $table.cycleNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get kLevel => $composableBuilder(
      column: $table.kLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$MistakeQuestionsTableFilterComposer get questionId {
    final $$MistakeQuestionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.mistakeQuestions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MistakeQuestionsTableFilterComposer(
              $db: $db,
              $table: $db.mistakeQuestions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReviewCyclesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewCyclesTable> {
  $$ReviewCyclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cycleNumber => $composableBuilder(
      column: $table.cycleNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kLevel => $composableBuilder(
      column: $table.kLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$MistakeQuestionsTableOrderingComposer get questionId {
    final $$MistakeQuestionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.mistakeQuestions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MistakeQuestionsTableOrderingComposer(
              $db: $db,
              $table: $db.mistakeQuestions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReviewCyclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewCyclesTable> {
  $$ReviewCyclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cycleNumber => $composableBuilder(
      column: $table.cycleNumber, builder: (column) => column);

  GeneratedColumn<int> get kLevel =>
      $composableBuilder(column: $table.kLevel, builder: (column) => column);

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MistakeQuestionsTableAnnotationComposer get questionId {
    final $$MistakeQuestionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.mistakeQuestions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MistakeQuestionsTableAnnotationComposer(
              $db: $db,
              $table: $db.mistakeQuestions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReviewCyclesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReviewCyclesTable,
    ReviewCycle,
    $$ReviewCyclesTableFilterComposer,
    $$ReviewCyclesTableOrderingComposer,
    $$ReviewCyclesTableAnnotationComposer,
    $$ReviewCyclesTableCreateCompanionBuilder,
    $$ReviewCyclesTableUpdateCompanionBuilder,
    (ReviewCycle, $$ReviewCyclesTableReferences),
    ReviewCycle,
    PrefetchHooks Function({bool questionId})> {
  $$ReviewCyclesTableTableManager(_$AppDatabase db, $ReviewCyclesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewCyclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewCyclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewCyclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> questionId = const Value.absent(),
            Value<int> cycleNumber = const Value.absent(),
            Value<int> kLevel = const Value.absent(),
            Value<String?> dueDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewCyclesCompanion(
            id: id,
            questionId: questionId,
            cycleNumber: cycleNumber,
            kLevel: kLevel,
            dueDate: dueDate,
            isActive: isActive,
            version: version,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String questionId,
            required int cycleNumber,
            required int kLevel,
            Value<String?> dueDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> version = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewCyclesCompanion.insert(
            id: id,
            questionId: questionId,
            cycleNumber: cycleNumber,
            kLevel: kLevel,
            dueDate: dueDate,
            isActive: isActive,
            version: version,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ReviewCyclesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({questionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (questionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.questionId,
                    referencedTable:
                        $$ReviewCyclesTableReferences._questionIdTable(db),
                    referencedColumn:
                        $$ReviewCyclesTableReferences._questionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReviewCyclesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReviewCyclesTable,
    ReviewCycle,
    $$ReviewCyclesTableFilterComposer,
    $$ReviewCyclesTableOrderingComposer,
    $$ReviewCyclesTableAnnotationComposer,
    $$ReviewCyclesTableCreateCompanionBuilder,
    $$ReviewCyclesTableUpdateCompanionBuilder,
    (ReviewCycle, $$ReviewCyclesTableReferences),
    ReviewCycle,
    PrefetchHooks Function({bool questionId})>;
typedef $$ReviewEventsTableCreateCompanionBuilder = ReviewEventsCompanion
    Function({
  required String id,
  required String questionId,
  required String cycleId,
  required int cycleNumber,
  required String learningDate,
  required String result,
  required int kLevelBefore,
  required int kLevelAfter,
  Value<String?> dueDateAfter,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ReviewEventsTableUpdateCompanionBuilder = ReviewEventsCompanion
    Function({
  Value<String> id,
  Value<String> questionId,
  Value<String> cycleId,
  Value<int> cycleNumber,
  Value<String> learningDate,
  Value<String> result,
  Value<int> kLevelBefore,
  Value<int> kLevelAfter,
  Value<String?> dueDateAfter,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ReviewEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewEventsTable> {
  $$ReviewEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cycleId => $composableBuilder(
      column: $table.cycleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cycleNumber => $composableBuilder(
      column: $table.cycleNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get learningDate => $composableBuilder(
      column: $table.learningDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get kLevelBefore => $composableBuilder(
      column: $table.kLevelBefore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get kLevelAfter => $composableBuilder(
      column: $table.kLevelAfter, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dueDateAfter => $composableBuilder(
      column: $table.dueDateAfter, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ReviewEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewEventsTable> {
  $$ReviewEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cycleId => $composableBuilder(
      column: $table.cycleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cycleNumber => $composableBuilder(
      column: $table.cycleNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get learningDate => $composableBuilder(
      column: $table.learningDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kLevelBefore => $composableBuilder(
      column: $table.kLevelBefore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kLevelAfter => $composableBuilder(
      column: $table.kLevelAfter, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dueDateAfter => $composableBuilder(
      column: $table.dueDateAfter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ReviewEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewEventsTable> {
  $$ReviewEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => column);

  GeneratedColumn<String> get cycleId =>
      $composableBuilder(column: $table.cycleId, builder: (column) => column);

  GeneratedColumn<int> get cycleNumber => $composableBuilder(
      column: $table.cycleNumber, builder: (column) => column);

  GeneratedColumn<String> get learningDate => $composableBuilder(
      column: $table.learningDate, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<int> get kLevelBefore => $composableBuilder(
      column: $table.kLevelBefore, builder: (column) => column);

  GeneratedColumn<int> get kLevelAfter => $composableBuilder(
      column: $table.kLevelAfter, builder: (column) => column);

  GeneratedColumn<String> get dueDateAfter => $composableBuilder(
      column: $table.dueDateAfter, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ReviewEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReviewEventsTable,
    ReviewEvent,
    $$ReviewEventsTableFilterComposer,
    $$ReviewEventsTableOrderingComposer,
    $$ReviewEventsTableAnnotationComposer,
    $$ReviewEventsTableCreateCompanionBuilder,
    $$ReviewEventsTableUpdateCompanionBuilder,
    (
      ReviewEvent,
      BaseReferences<_$AppDatabase, $ReviewEventsTable, ReviewEvent>
    ),
    ReviewEvent,
    PrefetchHooks Function()> {
  $$ReviewEventsTableTableManager(_$AppDatabase db, $ReviewEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> questionId = const Value.absent(),
            Value<String> cycleId = const Value.absent(),
            Value<int> cycleNumber = const Value.absent(),
            Value<String> learningDate = const Value.absent(),
            Value<String> result = const Value.absent(),
            Value<int> kLevelBefore = const Value.absent(),
            Value<int> kLevelAfter = const Value.absent(),
            Value<String?> dueDateAfter = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewEventsCompanion(
            id: id,
            questionId: questionId,
            cycleId: cycleId,
            cycleNumber: cycleNumber,
            learningDate: learningDate,
            result: result,
            kLevelBefore: kLevelBefore,
            kLevelAfter: kLevelAfter,
            dueDateAfter: dueDateAfter,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String questionId,
            required String cycleId,
            required int cycleNumber,
            required String learningDate,
            required String result,
            required int kLevelBefore,
            required int kLevelAfter,
            Value<String?> dueDateAfter = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewEventsCompanion.insert(
            id: id,
            questionId: questionId,
            cycleId: cycleId,
            cycleNumber: cycleNumber,
            learningDate: learningDate,
            result: result,
            kLevelBefore: kLevelBefore,
            kLevelAfter: kLevelAfter,
            dueDateAfter: dueDateAfter,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReviewEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReviewEventsTable,
    ReviewEvent,
    $$ReviewEventsTableFilterComposer,
    $$ReviewEventsTableOrderingComposer,
    $$ReviewEventsTableAnnotationComposer,
    $$ReviewEventsTableCreateCompanionBuilder,
    $$ReviewEventsTableUpdateCompanionBuilder,
    (
      ReviewEvent,
      BaseReferences<_$AppDatabase, $ReviewEventsTable, ReviewEvent>
    ),
    ReviewEvent,
    PrefetchHooks Function()>;
typedef $$MistakeAgainMarksTableCreateCompanionBuilder
    = MistakeAgainMarksCompanion Function({
  required String id,
  required String questionId,
  required String operationDate,
  required int newCycleNumber,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$MistakeAgainMarksTableUpdateCompanionBuilder
    = MistakeAgainMarksCompanion Function({
  Value<String> id,
  Value<String> questionId,
  Value<String> operationDate,
  Value<int> newCycleNumber,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$MistakeAgainMarksTableFilterComposer
    extends Composer<_$AppDatabase, $MistakeAgainMarksTable> {
  $$MistakeAgainMarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operationDate => $composableBuilder(
      column: $table.operationDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get newCycleNumber => $composableBuilder(
      column: $table.newCycleNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MistakeAgainMarksTableOrderingComposer
    extends Composer<_$AppDatabase, $MistakeAgainMarksTable> {
  $$MistakeAgainMarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operationDate => $composableBuilder(
      column: $table.operationDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get newCycleNumber => $composableBuilder(
      column: $table.newCycleNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MistakeAgainMarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $MistakeAgainMarksTable> {
  $$MistakeAgainMarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => column);

  GeneratedColumn<String> get operationDate => $composableBuilder(
      column: $table.operationDate, builder: (column) => column);

  GeneratedColumn<int> get newCycleNumber => $composableBuilder(
      column: $table.newCycleNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MistakeAgainMarksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MistakeAgainMarksTable,
    MistakeAgainMark,
    $$MistakeAgainMarksTableFilterComposer,
    $$MistakeAgainMarksTableOrderingComposer,
    $$MistakeAgainMarksTableAnnotationComposer,
    $$MistakeAgainMarksTableCreateCompanionBuilder,
    $$MistakeAgainMarksTableUpdateCompanionBuilder,
    (
      MistakeAgainMark,
      BaseReferences<_$AppDatabase, $MistakeAgainMarksTable, MistakeAgainMark>
    ),
    MistakeAgainMark,
    PrefetchHooks Function()> {
  $$MistakeAgainMarksTableTableManager(
      _$AppDatabase db, $MistakeAgainMarksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MistakeAgainMarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MistakeAgainMarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MistakeAgainMarksTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> questionId = const Value.absent(),
            Value<String> operationDate = const Value.absent(),
            Value<int> newCycleNumber = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MistakeAgainMarksCompanion(
            id: id,
            questionId: questionId,
            operationDate: operationDate,
            newCycleNumber: newCycleNumber,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String questionId,
            required String operationDate,
            required int newCycleNumber,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MistakeAgainMarksCompanion.insert(
            id: id,
            questionId: questionId,
            operationDate: operationDate,
            newCycleNumber: newCycleNumber,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MistakeAgainMarksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MistakeAgainMarksTable,
    MistakeAgainMark,
    $$MistakeAgainMarksTableFilterComposer,
    $$MistakeAgainMarksTableOrderingComposer,
    $$MistakeAgainMarksTableAnnotationComposer,
    $$MistakeAgainMarksTableCreateCompanionBuilder,
    $$MistakeAgainMarksTableUpdateCompanionBuilder,
    (
      MistakeAgainMark,
      BaseReferences<_$AppDatabase, $MistakeAgainMarksTable, MistakeAgainMark>
    ),
    MistakeAgainMark,
    PrefetchHooks Function()>;
typedef $$DailyPlansTableCreateCompanionBuilder = DailyPlansCompanion Function({
  required String id,
  required String learningDate,
  required int targetN,
  required int capacityC,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$DailyPlansTableUpdateCompanionBuilder = DailyPlansCompanion Function({
  Value<String> id,
  Value<String> learningDate,
  Value<int> targetN,
  Value<int> capacityC,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$DailyPlansTableReferences
    extends BaseReferences<_$AppDatabase, $DailyPlansTable, DailyPlan> {
  $$DailyPlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DailyPlanMembersTable, List<DailyPlanMember>>
      _dailyPlanMembersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.dailyPlanMembers,
              aliasName: $_aliasNameGenerator(
                  db.dailyPlans.id, db.dailyPlanMembers.planId));

  $$DailyPlanMembersTableProcessedTableManager get dailyPlanMembersRefs {
    final manager =
        $$DailyPlanMembersTableTableManager($_db, $_db.dailyPlanMembers)
            .filter((f) => f.planId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_dailyPlanMembersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DailyPlansTableFilterComposer
    extends Composer<_$AppDatabase, $DailyPlansTable> {
  $$DailyPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get learningDate => $composableBuilder(
      column: $table.learningDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetN => $composableBuilder(
      column: $table.targetN, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get capacityC => $composableBuilder(
      column: $table.capacityC, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> dailyPlanMembersRefs(
      Expression<bool> Function($$DailyPlanMembersTableFilterComposer f) f) {
    final $$DailyPlanMembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dailyPlanMembers,
        getReferencedColumn: (t) => t.planId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DailyPlanMembersTableFilterComposer(
              $db: $db,
              $table: $db.dailyPlanMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DailyPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyPlansTable> {
  $$DailyPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get learningDate => $composableBuilder(
      column: $table.learningDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetN => $composableBuilder(
      column: $table.targetN, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get capacityC => $composableBuilder(
      column: $table.capacityC, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DailyPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyPlansTable> {
  $$DailyPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get learningDate => $composableBuilder(
      column: $table.learningDate, builder: (column) => column);

  GeneratedColumn<int> get targetN =>
      $composableBuilder(column: $table.targetN, builder: (column) => column);

  GeneratedColumn<int> get capacityC =>
      $composableBuilder(column: $table.capacityC, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> dailyPlanMembersRefs<T extends Object>(
      Expression<T> Function($$DailyPlanMembersTableAnnotationComposer a) f) {
    final $$DailyPlanMembersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.dailyPlanMembers,
        getReferencedColumn: (t) => t.planId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DailyPlanMembersTableAnnotationComposer(
              $db: $db,
              $table: $db.dailyPlanMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DailyPlansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyPlansTable,
    DailyPlan,
    $$DailyPlansTableFilterComposer,
    $$DailyPlansTableOrderingComposer,
    $$DailyPlansTableAnnotationComposer,
    $$DailyPlansTableCreateCompanionBuilder,
    $$DailyPlansTableUpdateCompanionBuilder,
    (DailyPlan, $$DailyPlansTableReferences),
    DailyPlan,
    PrefetchHooks Function({bool dailyPlanMembersRefs})> {
  $$DailyPlansTableTableManager(_$AppDatabase db, $DailyPlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> learningDate = const Value.absent(),
            Value<int> targetN = const Value.absent(),
            Value<int> capacityC = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyPlansCompanion(
            id: id,
            learningDate: learningDate,
            targetN: targetN,
            capacityC: capacityC,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String learningDate,
            required int targetN,
            required int capacityC,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyPlansCompanion.insert(
            id: id,
            learningDate: learningDate,
            targetN: targetN,
            capacityC: capacityC,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DailyPlansTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({dailyPlanMembersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (dailyPlanMembersRefs) db.dailyPlanMembers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dailyPlanMembersRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$DailyPlansTableReferences
                            ._dailyPlanMembersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DailyPlansTableReferences(db, table, p0)
                                .dailyPlanMembersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.planId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DailyPlansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyPlansTable,
    DailyPlan,
    $$DailyPlansTableFilterComposer,
    $$DailyPlansTableOrderingComposer,
    $$DailyPlansTableAnnotationComposer,
    $$DailyPlansTableCreateCompanionBuilder,
    $$DailyPlansTableUpdateCompanionBuilder,
    (DailyPlan, $$DailyPlansTableReferences),
    DailyPlan,
    PrefetchHooks Function({bool dailyPlanMembersRefs})>;
typedef $$DailyPlanMembersTableCreateCompanionBuilder
    = DailyPlanMembersCompanion Function({
  required String id,
  required String planId,
  required String questionId,
  required int orderIndex,
  Value<bool> isCompleted,
  Value<bool> isSkipped,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$DailyPlanMembersTableUpdateCompanionBuilder
    = DailyPlanMembersCompanion Function({
  Value<String> id,
  Value<String> planId,
  Value<String> questionId,
  Value<int> orderIndex,
  Value<bool> isCompleted,
  Value<bool> isSkipped,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$DailyPlanMembersTableReferences extends BaseReferences<
    _$AppDatabase, $DailyPlanMembersTable, DailyPlanMember> {
  $$DailyPlanMembersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DailyPlansTable _planIdTable(_$AppDatabase db) =>
      db.dailyPlans.createAlias(
          $_aliasNameGenerator(db.dailyPlanMembers.planId, db.dailyPlans.id));

  $$DailyPlansTableProcessedTableManager get planId {
    final manager = $$DailyPlansTableTableManager($_db, $_db.dailyPlans)
        .filter((f) => f.id($_item.planId));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DailyPlanMembersTableFilterComposer
    extends Composer<_$AppDatabase, $DailyPlanMembersTable> {
  $$DailyPlanMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSkipped => $composableBuilder(
      column: $table.isSkipped, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$DailyPlansTableFilterComposer get planId {
    final $$DailyPlansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.dailyPlans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DailyPlansTableFilterComposer(
              $db: $db,
              $table: $db.dailyPlans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DailyPlanMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyPlanMembersTable> {
  $$DailyPlanMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSkipped => $composableBuilder(
      column: $table.isSkipped, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$DailyPlansTableOrderingComposer get planId {
    final $$DailyPlansTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.dailyPlans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DailyPlansTableOrderingComposer(
              $db: $db,
              $table: $db.dailyPlans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DailyPlanMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyPlanMembersTable> {
  $$DailyPlanMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
      column: $table.questionId, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<bool> get isSkipped =>
      $composableBuilder(column: $table.isSkipped, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$DailyPlansTableAnnotationComposer get planId {
    final $$DailyPlansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.dailyPlans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DailyPlansTableAnnotationComposer(
              $db: $db,
              $table: $db.dailyPlans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DailyPlanMembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyPlanMembersTable,
    DailyPlanMember,
    $$DailyPlanMembersTableFilterComposer,
    $$DailyPlanMembersTableOrderingComposer,
    $$DailyPlanMembersTableAnnotationComposer,
    $$DailyPlanMembersTableCreateCompanionBuilder,
    $$DailyPlanMembersTableUpdateCompanionBuilder,
    (DailyPlanMember, $$DailyPlanMembersTableReferences),
    DailyPlanMember,
    PrefetchHooks Function({bool planId})> {
  $$DailyPlanMembersTableTableManager(
      _$AppDatabase db, $DailyPlanMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyPlanMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyPlanMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyPlanMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> planId = const Value.absent(),
            Value<String> questionId = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isSkipped = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyPlanMembersCompanion(
            id: id,
            planId: planId,
            questionId: questionId,
            orderIndex: orderIndex,
            isCompleted: isCompleted,
            isSkipped: isSkipped,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String planId,
            required String questionId,
            required int orderIndex,
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isSkipped = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyPlanMembersCompanion.insert(
            id: id,
            planId: planId,
            questionId: questionId,
            orderIndex: orderIndex,
            isCompleted: isCompleted,
            isSkipped: isSkipped,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DailyPlanMembersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({planId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (planId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.planId,
                    referencedTable:
                        $$DailyPlanMembersTableReferences._planIdTable(db),
                    referencedColumn:
                        $$DailyPlanMembersTableReferences._planIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DailyPlanMembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyPlanMembersTable,
    DailyPlanMember,
    $$DailyPlanMembersTableFilterComposer,
    $$DailyPlanMembersTableOrderingComposer,
    $$DailyPlanMembersTableAnnotationComposer,
    $$DailyPlanMembersTableCreateCompanionBuilder,
    $$DailyPlanMembersTableUpdateCompanionBuilder,
    (DailyPlanMember, $$DailyPlanMembersTableReferences),
    DailyPlanMember,
    PrefetchHooks Function({bool planId})>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<int> dailyTargetN,
  Value<DateTime?> dailyTargetUpdatedAt,
  Value<DateTime?> lastBackupAt,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<int> dailyTargetN,
  Value<DateTime?> dailyTargetUpdatedAt,
  Value<DateTime?> lastBackupAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dailyTargetN => $composableBuilder(
      column: $table.dailyTargetN, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dailyTargetUpdatedAt => $composableBuilder(
      column: $table.dailyTargetUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastBackupAt => $composableBuilder(
      column: $table.lastBackupAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dailyTargetN => $composableBuilder(
      column: $table.dailyTargetN,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dailyTargetUpdatedAt => $composableBuilder(
      column: $table.dailyTargetUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastBackupAt => $composableBuilder(
      column: $table.lastBackupAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dailyTargetN => $composableBuilder(
      column: $table.dailyTargetN, builder: (column) => column);

  GeneratedColumn<DateTime> get dailyTargetUpdatedAt => $composableBuilder(
      column: $table.dailyTargetUpdatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastBackupAt => $composableBuilder(
      column: $table.lastBackupAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> dailyTargetN = const Value.absent(),
            Value<DateTime?> dailyTargetUpdatedAt = const Value.absent(),
            Value<DateTime?> lastBackupAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SettingsCompanion(
            id: id,
            dailyTargetN: dailyTargetN,
            dailyTargetUpdatedAt: dailyTargetUpdatedAt,
            lastBackupAt: lastBackupAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> dailyTargetN = const Value.absent(),
            Value<DateTime?> dailyTargetUpdatedAt = const Value.absent(),
            Value<DateTime?> lastBackupAt = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              SettingsCompanion.insert(
            id: id,
            dailyTargetN: dailyTargetN,
            dailyTargetUpdatedAt: dailyTargetUpdatedAt,
            lastBackupAt: lastBackupAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ErrorQuestionsTableTableManager get errorQuestions =>
      $$ErrorQuestionsTableTableManager(_db, _db.errorQuestions);
  $$MistakeQuestionsTableTableManager get mistakeQuestions =>
      $$MistakeQuestionsTableTableManager(_db, _db.mistakeQuestions);
  $$ReviewCyclesTableTableManager get reviewCycles =>
      $$ReviewCyclesTableTableManager(_db, _db.reviewCycles);
  $$ReviewEventsTableTableManager get reviewEvents =>
      $$ReviewEventsTableTableManager(_db, _db.reviewEvents);
  $$MistakeAgainMarksTableTableManager get mistakeAgainMarks =>
      $$MistakeAgainMarksTableTableManager(_db, _db.mistakeAgainMarks);
  $$DailyPlansTableTableManager get dailyPlans =>
      $$DailyPlansTableTableManager(_db, _db.dailyPlans);
  $$DailyPlanMembersTableTableManager get dailyPlanMembers =>
      $$DailyPlanMembersTableTableManager(_db, _db.dailyPlanMembers);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
