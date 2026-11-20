import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';

class ErrorQuestion {
  final String id;
  final String subject;
  final String question;
  final String myAnswer;
  final String correctAnswer;
  final String reason;
  final MasteryStatus masteryStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? lastSyncedAt;
  final bool needsSync;

  ErrorQuestion({
    required this.id,
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
    this.needsSync = false,
  });

  factory ErrorQuestion.create({
    required String subject,
    required String question,
    required String myAnswer,
    required String correctAnswer,
    required String reason,
    MasteryStatus masteryStatus = MasteryStatus.notMastered,
  }) {
    final now = DateTime.now();
    return ErrorQuestion(
      id: const Uuid().v4(),
      subject: subject,
      question: question,
      myAnswer: myAnswer,
      correctAnswer: correctAnswer,
      reason: reason,
      masteryStatus: masteryStatus,
      createdAt: now,
      updatedAt: now,
      needsSync: true,
    );
  }

  ErrorQuestion copyWith({
    String? id,
    String? subject,
    String? question,
    String? myAnswer,
    String? correctAnswer,
    String? reason,
    MasteryStatus? masteryStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    DateTime? lastSyncedAt,
    bool? needsSync,
  }) {
    return ErrorQuestion(
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'question': question,
      'my_answer': myAnswer,
      'correct_answer': correctAnswer,
      'reason': reason,
      'mastery_status': masteryStatus.apiValue,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt!.toUtc().toIso8601String(),
    };
  }

  factory ErrorQuestion.fromJson(Map<String, dynamic> json) {
    return ErrorQuestion(
      id: json['id'] as String,
      subject: json['subject'] as String,
      question: json['question'] as String,
      myAnswer: json['my_answer'] as String,
      correctAnswer: json['correct_answer'] as String,
      reason: json['reason'] as String,
      masteryStatus: MasteryStatusExtension.fromApiValue(json['mastery_status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
      lastSyncedAt: json['last_synced_at'] != null ? DateTime.parse(json['last_synced_at'] as String) : null,
    );
  }
}
