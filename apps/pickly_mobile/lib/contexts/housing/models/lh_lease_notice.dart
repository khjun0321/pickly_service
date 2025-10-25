/// LH 분양임대공고문 모델
///
/// 공공데이터포털 API 응답을 파싱합니다.
class LhLeaseNotice {
  final String? noticeId;           // 공고 ID
  final String? noticeTitle;        // 공고 제목
  final String? noticeDate;         // 공고일
  final String? applyStartDate;     // 신청 시작일
  final String? applyEndDate;       // 신청 종료일
  final String? resultDate;         // 당첨자 발표일
  final String? moveInDate;         // 입주 예정일
  final String? housingSector;      // 주택 구분 (행복주택, 국민임대 등)
  final String? region;             // 지역
  final String? detailAddress;      // 상세 주소
  final int? totalSupply;           // 총 공급 호수
  final String? recruitmentType;    // 모집 구분 (예비입주자 모집 등)
  final String? noticeUrl;          // 공고문 URL

  LhLeaseNotice({
    this.noticeId,
    this.noticeTitle,
    this.noticeDate,
    this.applyStartDate,
    this.applyEndDate,
    this.resultDate,
    this.moveInDate,
    this.housingSector,
    this.region,
    this.detailAddress,
    this.totalSupply,
    this.recruitmentType,
    this.noticeUrl,
  });

  /// JSON에서 모델 생성
  ///
  /// 공공데이터포털 API 응답 구조에 맞춰 파싱합니다.
  /// 실제 API 응답을 확인한 후 필드명을 정확히 매칭해야 합니다.
  factory LhLeaseNotice.fromJson(Map<String, dynamic> json) {
    return LhLeaseNotice(
      noticeId: json['PAN_ID']?.toString(),
      noticeTitle: json['PAN_NM']?.toString(),
      noticeDate: json['PAN_NT_ST_DT']?.toString(),
      applyStartDate: json['RCRIT_PBLANC_DE']?.toString(),
      applyEndDate: json['SUBSCRPT_RCEPT_ENDDE']?.toString(),
      resultDate: json['PRZWNER_PRESNATN_DE']?.toString(),
      moveInDate: json['MVNPREARNGE']?.toString(),
      housingSector: json['AIS_TP_CD_NM']?.toString(),
      region: json['CNP_CD_NM']?.toString(),
      detailAddress: json['SPECLT_RDN_EARTH_AT']?.toString(),
      totalSupply: json['TOT_SUPLY_HSHLDCO'] != null
          ? int.tryParse(json['TOT_SUPLY_HSHLDCO'].toString())
          : null,
      recruitmentType: json['RCRIT_PBLANC_NM']?.toString(),
      noticeUrl: json['PAN_URL']?.toString(),
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'noticeId': noticeId,
      'noticeTitle': noticeTitle,
      'noticeDate': noticeDate,
      'applyStartDate': applyStartDate,
      'applyEndDate': applyEndDate,
      'resultDate': resultDate,
      'moveInDate': moveInDate,
      'housingSector': housingSector,
      'region': region,
      'detailAddress': detailAddress,
      'totalSupply': totalSupply,
      'recruitmentType': recruitmentType,
      'noticeUrl': noticeUrl,
    };
  }

  @override
  String toString() {
    return 'LhLeaseNotice(title: $noticeTitle, region: $region, applyStartDate: $applyStartDate)';
  }
}

/// LH API 응답 래퍼
///
/// 공공데이터포털 API는 보통 다음 구조로 응답합니다:
/// ```json
/// {
///   "response": {
///     "header": {
///       "resultCode": "00",
///       "resultMsg": "NORMAL SERVICE"
///     },
///     "body": {
///       "items": [...],
///       "numOfRows": 10,
///       "pageNo": 1,
///       "totalCount": 50
///     }
///   }
/// }
/// ```
class LhApiResponse<T> {
  final String resultCode;
  final String resultMsg;
  final List<T> items;
  final int totalCount;
  final int pageNo;
  final int numOfRows;

  LhApiResponse({
    required this.resultCode,
    required this.resultMsg,
    required this.items,
    required this.totalCount,
    required this.pageNo,
    required this.numOfRows,
  });

  bool get isSuccess => resultCode == '00';

  factory LhApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final response = json['response'] ?? json;
    final header = response['header'] ?? {};
    final body = response['body'] ?? {};

    final itemsList = body['items'] ?? [];
    final items = (itemsList is List)
        ? itemsList.map((item) => fromJsonT(item as Map<String, dynamic>)).toList()
        : <T>[];

    return LhApiResponse(
      resultCode: header['resultCode']?.toString() ?? '99',
      resultMsg: header['resultMsg']?.toString() ?? 'Unknown error',
      items: items,
      totalCount: body['totalCount'] ?? 0,
      pageNo: body['pageNo'] ?? 1,
      numOfRows: body['numOfRows'] ?? 10,
    );
  }
}
