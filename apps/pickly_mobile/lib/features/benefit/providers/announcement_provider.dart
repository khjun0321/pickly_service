import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../contexts/benefit/models/announcement.dart';
import '../../../contexts/benefit/repositories/announcement_repository.dart';

part 'announcement_provider.g.dart';

/// 카테고리별 공고 목록 Provider
@riverpod
Future<List<Announcement>> announcementsByCategory(
  AnnouncementsByCategoryRef ref,
  String categoryId,
) async {
  final repository = ref.watch(announcementRepositoryProvider);
  return repository.getAnnouncementsByCategory(categoryId);
}

/// 공고 상세 Provider
@riverpod
Future<Announcement> announcementDetail(
  AnnouncementDetailRef ref,
  String announcementId,
) async {
  final repository = ref.watch(announcementRepositoryProvider);
  return repository.getAnnouncementById(announcementId);
}

/// 공고 실시간 스트림 Provider
@riverpod
Stream<List<Announcement>> announcementsStream(
  AnnouncementsStreamRef ref,
  String categoryId,
) {
  final repository = ref.watch(announcementRepositoryProvider);
  return repository.watchAnnouncementsByCategory(categoryId);
}

/// 공고 검색 Provider
@riverpod
Future<List<Announcement>> searchAnnouncements(
  SearchAnnouncementsRef ref, {
  required String query,
  String? categoryId,
}) async {
  final repository = ref.watch(announcementRepositoryProvider);
  return repository.searchAnnouncements(query, categoryId: categoryId);
}

/// 인기 공고 Provider
@riverpod
Future<List<Announcement>> popularAnnouncements(
  PopularAnnouncementsRef ref, {
  String? categoryId,
  int limit = 10,
}) async {
  final repository = ref.watch(announcementRepositoryProvider);
  return repository.getPopularAnnouncements(
    categoryId: categoryId,
    limit: limit,
  );
}
