import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class DioClient {
  late final Dio _dio;

  DioClient({required String baseUrl, String? apiKey}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConstants.networkTimeout,
        receiveTimeout: AppConstants.networkTimeout,
        headers: {
          'Content-Type': 'application/json',
          if (apiKey != null) 'X-API-Key': apiKey,
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  Dio get dio => _dio;
}
