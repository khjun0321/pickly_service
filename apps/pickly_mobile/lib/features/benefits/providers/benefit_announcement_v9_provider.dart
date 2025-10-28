/// Benefit Announcement Provider (v9.0)
///
/// Manages benefit announcements with Supabase + Riverpod
/// Fetches announcements per detail/policy
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pickly_mobile/features/benefits/models/benefit_announcement.dart';

/// Supabase client provider
final _supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider to fetch announcements for a specific detail (policy)
///
/// Usage:
/// ```dart
/// final announcements = ref.watch(announcementsByDetailProvider(detailId));
/// ```
final announcementsByDetailProvider =
    FutureProvider.family<List<BenefitAnnouncement>, String>((ref, detailId) async {
  try {
    final supabase = ref.read(_supabaseProvider);
    debugPrint('📡 Fetching announcements for detail: $detailId');

    final response = await supabase
        .from('benefit_announcements')
        .select()
        .eq('benefit_detail_id', detailId)
        .eq('status', 'published')
        .order('display_order', ascending: true)
        .order('created_at', ascending: false);

    final announcements = (response as List)
        .map((json) => BenefitAnnouncement.fromJson(json))
        .toList();

    debugPrint('✅ Loaded ${announcements.length} announcements for detail $detailId');
    return announcements;
  } catch (e, stackTrace) {
    debugPrint('❌ Error fetching announcements: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
});

/// Provider to fetch featured announcements (for homepage)
final featuredAnnouncementsProvider =
    FutureProvider<List<BenefitAnnouncement>>((ref) async {
  try {
    final supabase = ref.read(_supabaseProvider);
    debugPrint('📡 Fetching featured announcements');

    final response = await supabase
        .from('benefit_announcements')
        .select()
        .eq('status', 'published')
        .eq('is_featured', true)
        .order('display_order', ascending: true)
        .limit(10);

    final announcements = (response as List)
        .map((json) => BenefitAnnouncement.fromJson(json))
        .toList();

    debugPrint('✅ Loaded ${announcements.length} featured announcements');
    return announcements;
  } catch (e, stackTrace) {
    debugPrint('❌ Error fetching featured announcements: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
});

/// Provider to fetch announcements by category (all details)
final announcementsByCategoryProvider =
    FutureProvider.family<List<BenefitAnnouncement>, String>((ref, categoryId) async {
  try {
    final supabase = ref.read(_supabaseProvider);
    debugPrint('📡 Fetching announcements for category: $categoryId');

    final response = await supabase
        .from('benefit_announcements')
        .select()
        .eq('category_id', categoryId)
        .eq('status', 'published')
        .order('display_order', ascending: true)
        .order('created_at', ascending: false);

    final announcements = (response as List)
        .map((json) => BenefitAnnouncement.fromJson(json))
        .toList();

    debugPrint('✅ Loaded ${announcements.length} announcements for category $categoryId');
    return announcements;
  } catch (e, stackTrace) {
    debugPrint('❌ Error fetching category announcements: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
});

/// Provider to get a single announcement by ID
final announcementByIdProvider =
    FutureProvider.family<BenefitAnnouncement?, String>((ref, announcementId) async {
  try {
    final supabase = ref.read(_supabaseProvider);
    debugPrint('📡 Fetching announcement by ID: $announcementId');

    final response = await supabase
        .from('benefit_announcements')
        .select()
        .eq('id', announcementId)
        .maybeSingle();

    if (response == null) {
      debugPrint('⚠️ Announcement not found: $announcementId');
      return null;
    }

    return BenefitAnnouncement.fromJson(response);
  } catch (e, stackTrace) {
    debugPrint('❌ Error fetching announcement by ID: $e');
    debugPrint('Stack trace: $stackTrace');
    return null;
  }
});
