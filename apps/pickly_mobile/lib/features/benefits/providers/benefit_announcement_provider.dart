import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_mobile/contexts/benefit/models/announcement.dart';
import 'package:pickly_mobile/contexts/benefit/repositories/announcement_repository.dart';

/// Provider for announcements by category
final announcementsByCategoryProvider = FutureProvider.family<List<Announcement>, String>((ref, categoryId) async {
  final repository = ref.watch(announcementRepositoryProvider);
  return repository.getAnnouncementsByCategory(categoryId);
});

/// Provider for popular/featured announcements
final featuredAnnouncementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final repository = ref.watch(announcementRepositoryProvider);
  return repository.getPopularAnnouncements(limit: 10);
});

/// Provider for a single announcement
final announcementByIdProvider = FutureProvider.family<Announcement?, String>((ref, id) async {
  final repository = ref.watch(announcementRepositoryProvider);
  try {
    return await repository.getAnnouncementById(id);
  } catch (e) {
    return null;
  }
});
