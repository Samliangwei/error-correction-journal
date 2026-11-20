import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/error_question.dart';

final errorQuestionsProvider = FutureProvider.family<List<ErrorQuestion>, ErrorQuestionsFilter>(
  (ref, filter) async {
    final repository = ref.watch(errorQuestionRepositoryProvider);
    return await repository.getAll(
      subject: filter.subject,
      masteryStatus: filter.masteryStatus,
    );
  },
);

final errorQuestionDetailProvider = FutureProvider.family<ErrorQuestion?, String>(
  (ref, id) async {
    final repository = ref.watch(errorQuestionRepositoryProvider);
    return await repository.getById(id);
  },
);

class ErrorQuestionsFilter {
  final String? subject;
  final MasteryStatus? masteryStatus;

  const ErrorQuestionsFilter({
    this.subject,
    this.masteryStatus,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorQuestionsFilter &&
          runtimeType == other.runtimeType &&
          subject == other.subject &&
          masteryStatus == other.masteryStatus;

  @override
  int get hashCode => subject.hashCode ^ masteryStatus.hashCode;
}
