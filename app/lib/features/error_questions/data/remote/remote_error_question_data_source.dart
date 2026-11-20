import 'package:dio/dio.dart';

import '../../domain/models/error_question.dart';

class RemoteErrorQuestionDataSource {
  final Dio _dio;

  RemoteErrorQuestionDataSource(this._dio);

  Future<List<ErrorQuestion>> syncQuestions(List<ErrorQuestion> questions) async {
    try {
      final response = await _dio.post(
        '/api/v1/error-questions/sync',
        data: {
          'questions': questions.map((q) => q.toJson()).toList(),
        },
      );

      final syncedIds = List<String>.from(response.data['synced'] ?? []);
      return questions.where((q) => syncedIds.contains(q.id)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return [];
      }
      rethrow;
    }
  }

  Future<void> createQuestion(ErrorQuestion question) async {
    await _dio.post(
      '/api/v1/error-questions',
      data: question.toJson(),
    );
  }

  Future<void> updateQuestion(ErrorQuestion question) async {
    await _dio.put(
      '/api/v1/error-questions/${question.id}',
      data: question.toJson(),
    );
  }

  Future<void> deleteQuestion(String id) async {
    await _dio.delete('/api/v1/error-questions/$id');
  }
}
