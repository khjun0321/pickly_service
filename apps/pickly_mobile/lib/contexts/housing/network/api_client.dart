import 'package:dio/dio.dart';
import 'api_config.dart';

/// LH API 클라이언트
class ApiClient {
  late final Dio _dio;

  factory ApiClient.lh() {
    return ApiClient._internal(
      baseUrl: ApiConfig.lhBaseUrl,
      serviceKey: ApiConfig.lhServiceKey,
    );
  }

  ApiClient._internal({
    required String baseUrl,
    required String serviceKey,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      queryParameters: {'serviceKey': serviceKey},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // 로깅 인터셉터
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio get dio => _dio;
}
