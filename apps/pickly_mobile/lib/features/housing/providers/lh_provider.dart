import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../contexts/housing/repositories/lh_repository.dart';
import '../../../contexts/housing/models/lh_lease_notice.dart';

/// LH Repository Provider
final lhRepositoryProvider = Provider<LhRepository>((ref) {
  return LhRepository();
});

/// LH 공고 목록 Provider
///
/// 사용 예시:
/// ```dart
/// final notices = ref.watch(lhLeaseNoticesProvider);
/// ```
final lhLeaseNoticesProvider = FutureProvider.autoDispose
    .family<LhApiResponse<LhLeaseNotice>, LhNoticeParams>((ref, params) async {
  final repository = ref.watch(lhRepositoryProvider);
  return repository.getLeaseNotices(
    pageNo: params.pageNo,
    numOfRows: params.numOfRows,
    region: params.region,
    housingSector: params.housingSector,
  );
});

/// LH 공고 상세 Provider
///
/// 사용 예시:
/// ```dart
/// final notice = ref.watch(lhLeaseNoticeDetailProvider('noticeId'));
/// ```
final lhLeaseNoticeDetailProvider = FutureProvider.autoDispose
    .family<LhLeaseNotice, String>((ref, noticeId) async {
  final repository = ref.watch(lhRepositoryProvider);
  return repository.getLeaseNoticeDetail(noticeId);
});

/// 지역별 공고 Provider
final lhLeaseNoticesByRegionProvider = FutureProvider.autoDispose
    .family<LhApiResponse<LhLeaseNotice>, String>((ref, region) async {
  final repository = ref.watch(lhRepositoryProvider);
  return repository.getLeaseNoticesByRegion(region);
});

/// 주택 유형별 공고 Provider
final lhLeaseNoticesByTypeProvider = FutureProvider.autoDispose
    .family<LhApiResponse<LhLeaseNotice>, String>((ref, housingSector) async {
  final repository = ref.watch(lhRepositoryProvider);
  return repository.getLeaseNoticesByType(housingSector);
});

/// LH 공고 검색 파라미터
class LhNoticeParams {
  final int pageNo;
  final int numOfRows;
  final String? region;
  final String? housingSector;

  const LhNoticeParams({
    this.pageNo = 1,
    this.numOfRows = 10,
    this.region,
    this.housingSector,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LhNoticeParams &&
        other.pageNo == pageNo &&
        other.numOfRows == numOfRows &&
        other.region == region &&
        other.housingSector == housingSector;
  }

  @override
  int get hashCode {
    return Object.hash(pageNo, numOfRows, region, housingSector);
  }
}
