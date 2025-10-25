import 'package:dio/dio.dart';
import 'api_config.dart';
import 'api_interceptor.dart';

/// API 클라이언트 팩토리
///
/// 각 도메인별로 독립적인 Dio 인스턴스를 생성합니다.
/// 모든 클라이언트는 자동으로 ApiInterceptor를 포함합니다.
class ApiClient {
  late final Dio _dio;

  /// LH 한국토지주택공사 API 클라이언트
  ///
  /// 사용 예시:
  /// ```dart
  /// final client = ApiClient.lh();
  /// final response = await client.dio.get('/lhLeaseNoticeInfo1');
  /// ```
  factory ApiClient.lh() {
    return ApiClient._internal(
      baseUrl: ApiConfig.lhBaseUrl,
      serviceKey: ApiConfig.lhServiceKey,
    );
  }

  /// 복지로 API 클라이언트 (미래)
  factory ApiClient.bokjiro() {
    return ApiClient._internal(
      baseUrl: ApiConfig.bokjiroBaseUrl,
      serviceKey: ApiConfig.bokjiroServiceKey,
    );
  }

  /// 교육부 API 클라이언트 (미래)
  factory ApiClient.moe() {
    return ApiClient._internal(
      baseUrl: ApiConfig.moeBaseUrl,
      serviceKey: ApiConfig.moeServiceKey,
    );
  }

  /// 워크넷 API 클라이언트 (미래)
  factory ApiClient.worknet() {
    return ApiClient._internal(
      baseUrl: ApiConfig.worknetBaseUrl,
      serviceKey: ApiConfig.worknetServiceKey,
    );
  }

  /// 내부 생성자
  ///
  /// 공통 설정을 적용한 Dio 인스턴스를 생성합니다.
  ApiClient._internal({
    required String baseUrl,
    required String serviceKey,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Accept': 'application/json',
        },
        queryParameters: {
          'serviceKey': serviceKey, // 공공데이터포털 인증키
        },
      ),
    );

    // 로깅 인터셉터 추가
    _dio.interceptors.add(ApiInterceptor());
  }

  /// Dio 인스턴스 getter
  Dio get dio => _dio;
}
