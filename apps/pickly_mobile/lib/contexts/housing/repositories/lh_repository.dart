import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/errors/api_exception.dart';
import '../models/lh_lease_notice.dart';

/// LH 한국토지주택공사 API Repository
///
/// 분양/임대 공고 정보를 조회합니다.
class LhRepository {
  late final ApiClient _client;

  LhRepository() {
    _client = ApiClient.lh();
  }

  /// 분양임대공고문 목록 조회
  ///
  /// [pageNo] 페이지 번호 (기본값: 1)
  /// [numOfRows] 한 페이지 결과 수 (기본값: 10)
  /// [region] 지역 필터 (예: '서울특별시')
  /// [housingSector] 주택 구분 필터 (예: '행복주택')
  Future<LhApiResponse<LhLeaseNotice>> getLeaseNotices({
    int pageNo = 1,
    int numOfRows = 10,
    String? region,
    String? housingSector,
  }) async {
    try {
      final queryParams = {
        'pageNo': pageNo.toString(),
        'numOfRows': numOfRows.toString(),
        if (region != null) 'CNP_CD_NM': region,
        if (housingSector != null) 'AIS_TP_CD_NM': housingSector,
      };

      final response = await _client.dio.get(
        ApiConfig.lhLeaseNoticeInfo,
        queryParameters: queryParams,
      );

      return LhApiResponse.fromJson(
        response.data,
        (json) => LhLeaseNotice.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  /// 공고 상세 조회
  ///
  /// [noticeId] 공고 ID
  Future<LhLeaseNotice> getLeaseNoticeDetail(String noticeId) async {
    try {
      final response = await _client.dio.get(
        ApiConfig.lhLeaseNoticeInfo,
        queryParameters: {
          'PAN_ID': noticeId,
        },
      );

      final apiResponse = LhApiResponse.fromJson(
        response.data,
        (json) => LhLeaseNotice.fromJson(json),
      );

      if (apiResponse.items.isEmpty) {
        throw ApiException('공고를 찾을 수 없습니다.');
      }

      return apiResponse.items.first;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  /// 지역별 공고 조회
  ///
  /// [region] 지역명 (예: '서울특별시', '경기도')
  Future<LhApiResponse<LhLeaseNotice>> getLeaseNoticesByRegion(
    String region, {
    int pageNo = 1,
    int numOfRows = 10,
  }) async {
    return getLeaseNotices(
      pageNo: pageNo,
      numOfRows: numOfRows,
      region: region,
    );
  }

  /// 주택 유형별 공고 조회
  ///
  /// [housingSector] 주택 구분 (예: '행복주택', '국민임대')
  Future<LhApiResponse<LhLeaseNotice>> getLeaseNoticesByType(
    String housingSector, {
    int pageNo = 1,
    int numOfRows = 10,
  }) async {
    return getLeaseNotices(
      pageNo: pageNo,
      numOfRows: numOfRows,
      housingSector: housingSector,
    );
  }

  /// 현재 신청 가능한 공고 조회
  ///
  /// 신청 기간이 현재 날짜를 포함하는 공고만 반환합니다.
  Future<LhApiResponse<LhLeaseNotice>> getCurrentAvailableNotices({
    int pageNo = 1,
    int numOfRows = 10,
  }) async {
    final response = await getLeaseNotices(
      pageNo: pageNo,
      numOfRows: numOfRows,
    );

    // 클라이언트 측에서 필터링
    final now = DateTime.now();
    final filteredItems = response.items.where((notice) {
      if (notice.applyStartDate == null || notice.applyEndDate == null) {
        return false;
      }

      try {
        final startDate = DateTime.parse(notice.applyStartDate!);
        final endDate = DateTime.parse(notice.applyEndDate!);
        return now.isAfter(startDate) && now.isBefore(endDate);
      } catch (e) {
        return false;
      }
    }).toList();

    return LhApiResponse(
      resultCode: response.resultCode,
      resultMsg: response.resultMsg,
      items: filteredItems,
      totalCount: filteredItems.length,
      pageNo: response.pageNo,
      numOfRows: response.numOfRows,
    );
  }
}
