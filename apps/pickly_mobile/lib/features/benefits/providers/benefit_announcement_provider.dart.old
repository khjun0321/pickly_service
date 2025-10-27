import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_mobile/contexts/benefit/models/benefit_announcement.dart';
import 'package:pickly_mobile/contexts/benefit/repositories/benefit_announcement_repository.dart';

/// Repository provider
final benefitAnnouncementRepositoryProvider = Provider<BenefitAnnouncementRepository>((ref) {
  return BenefitAnnouncementRepository();
});

/// Provider for announcements by category
final announcementsByCategoryProvider = FutureProvider.family<List<BenefitAnnouncement>, String>((ref, categoryId) async {
  final repository = ref.watch(benefitAnnouncementRepositoryProvider);
  return repository.getAnnouncementsByCategory(categoryId: categoryId);
});

/// Provider for featured announcements
final featuredAnnouncementsProvider = FutureProvider<List<BenefitAnnouncement>>((ref) async {
  final repository = ref.watch(benefitAnnouncementRepositoryProvider);
  return repository.getFeaturedAnnouncements();
});

/// Provider for a single announcement
final announcementByIdProvider = FutureProvider.family<BenefitAnnouncement?, String>((ref, id) async {
  final repository = ref.watch(benefitAnnouncementRepositoryProvider);
  return repository.getAnnouncementById(id);
});
