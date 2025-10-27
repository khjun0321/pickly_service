/// 공고 관련 예외
class AnnouncementException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AnnouncementException(this.message, [this.stackTrace]);

  @override
  String toString() => 'AnnouncementException: $message';
}

/// 공고를 찾을 수 없음
class AnnouncementNotFoundException extends AnnouncementException {
  const AnnouncementNotFoundException([String? message])
      : super(message ?? '공고를 찾을 수 없습니다.');
}

/// 네트워크 오류
class AnnouncementNetworkException extends AnnouncementException {
  const AnnouncementNetworkException([String? message])
      : super(message ?? '네트워크 오류가 발생했습니다.');
}
