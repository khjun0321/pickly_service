import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('서버 응답이 없습니다. 잠시 후 다시 시도해주세요.');
      case DioExceptionType.badResponse:
        return ApiException(
          '오류가 발생했습니다. (코드: ${error.response?.statusCode})',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return ApiException('요청이 취소되었습니다.');
      default:
        return ApiException('네트워크 연결을 확인해주세요.');
    }
  }

  @override
  String toString() => message;
}
