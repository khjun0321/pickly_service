import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../contexts/benefit/models/announcement.dart';
import '../../../contexts/benefit/models/announcement_tab.dart';
import '../../../contexts/benefit/models/announcement_section.dart';
import '../../../contexts/benefit/repositories/announcement_repository.dart';

part 'announcement_provider.g.dart';

/// 카테고리별 공고 목록 Provider
@riverpod
Future<List<Announcement>> announcementsByCategory(
  ref,
  String categoryId,
) async {
  final repository = ref.watch(announcementRepositoryProvider);
  return repository.getAnnouncementsByCategory(categoryId);
}

/// 공고 상세 Provider
/// 캐시 무효화: keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch
@Riverpod(keepAlive: false)
Future<Announcement> announcementDetail(
  ref,
  String announcementId,
) async {
  final repository = ref.watch(announcementRepositoryProvider);
  final announcement = await repository.getAnnouncementById(announcementId);

  // updated_at을 기준으로 캐시 무효화 체크
  // Riverpod의 AutoDispose를 사용하여 화면을 벗어나면 자동으로 dispose
  return announcement;
}

/// 공고 실시간 스트림 Provider
@riverpod
Stream<List<Announcement>> announcementsStream(
  ref,
  String categoryId,
) {
  final repository = ref.watch(announcementRepositoryProvider);
  return repository.watchAnnouncementsByCategory(categoryId);
}

/// 공고 검색 Provider
@riverpod
Future<List<Announcement>> searchAnnouncements(
  ref, {
  required String query,
  String? categoryId,
}) async {
  final repository = ref.watch(announcementRepositoryProvider);
  return repository.searchAnnouncements(query, categoryId: categoryId);
}

/// 인기 공고 Provider
@riverpod
Future<List<Announcement>> popularAnnouncements(
  ref, {
  String? categoryId,
  int limit = 10,
}) async {
  final repository = ref.watch(announcementRepositoryProvider);
  return repository.getPopularAnnouncements(
    categoryId: categoryId,
    limit: limit,
  );
}

/// 공고 탭 목록 Provider (평형별/연령별)
/// keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch
@Riverpod(keepAlive: false)
Future<List<AnnouncementTab>> announcementTabs(
  ref,
  String announcementId,
) async {
  final repository = ref.watch(announcementRepositoryProvider);
  return repository.getAnnouncementTabs(announcementId);
}

/// 공고 섹션 목록 Provider (모듈식)
/// keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch
@Riverpod(keepAlive: false)
Future<List<AnnouncementSection>> announcementSections(
  ref,
  String announcementId,
) async {
  final repository = ref.watch(announcementRepositoryProvider);
  return repository.getAnnouncementSections(announcementId);
}
