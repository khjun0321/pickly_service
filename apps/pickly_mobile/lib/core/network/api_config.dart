// LH API 설정 (실제 정보 반영)
class ApiConfig {
  // 환경 설정
  static const bool isProduction = true;

  // === LH 한국토지주택공사 API ===
  static const String lhBaseUrl = 'https://apis.data.go.kr/B552555';
  static const String lhServiceKey = '2464c0e93735b87e2a66f4439535c9207396d3991ce9bdff236cebe7a76af28b';

  // LH API 엔드포인트
  static const String lhLeaseNoticeInfo = '/lhLeaseNoticeInfo1'; // 분양임대공고문 조회

  // API 공통 설정
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // === 복지 도메인 (미래) ===
  static const String bokjiroBaseUrl = 'https://api.bokjiro.go.kr';
  static const String bokjiroServiceKey = 'YOUR_BOKJIRO_KEY';

  // === 교육 도메인 (미래) ===
  static const String moeBaseUrl = 'https://api.moe.go.kr';
  static const String moeServiceKey = 'YOUR_MOE_KEY';

  // === 취업 도메인 (미래) ===
  static const String worknetBaseUrl = 'https://api.worknet.go.kr';
  static const String worknetServiceKey = 'YOUR_WORKNET_KEY';
}
