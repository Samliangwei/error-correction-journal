import '../models/error_question.dart';
import '../../../../core/constants/app_constants.dart';

abstract class ErrorQuestionRepository {
  Future<List<ErrorQuestion>> getAll({
    String? subject,
    MasteryStatus? masteryStatus,
  });

  Future<ErrorQuestion?> getById(String id);

  Future<void> create(ErrorQuestion question);

  Future<void> update(ErrorQuestion question);

  Future<void> delete(String id);

  Future<void> sync();

  Future<List<ErrorQuestion>> getPendingSync();
}
