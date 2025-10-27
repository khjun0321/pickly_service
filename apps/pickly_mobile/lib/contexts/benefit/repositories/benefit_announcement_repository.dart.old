import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/benefit_announcement.dart';

/// Repository for benefit announcements
/// Handles all database operations for announcements
class BenefitAnnouncementRepository {
  final SupabaseClient _supabase;

  BenefitAnnouncementRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Get announcements by category ID
  /// Returns only published announcements, sorted by announcement_date descending
  Future<List<BenefitAnnouncement>> getAnnouncementsByCategory({
    required String categoryId,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('benefit_announcements')
          .select()
          .eq('category_id', categoryId)
          .eq('status', 'published')
          .order('announcement_date', ascending: false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => BenefitAnnouncement.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching announcements by category: $e');
      rethrow;
    }
  }

  /// Get announcement by ID
  Future<BenefitAnnouncement?> getAnnouncementById(String id) async {
    try {
      final response = await _supabase
          .from('benefit_announcements')
          .select()
          .eq('id', id)
          .single();

      return BenefitAnnouncement.fromJson(response);
    } catch (e) {
      print('❌ Error fetching announcement by ID: $e');
      return null;
    }
  }

  /// Get featured announcements
  Future<List<BenefitAnnouncement>> getFeaturedAnnouncements({
    int limit = 10,
  }) async {
    try {
      final response = await _supabase
          .from('benefit_announcements')
          .select()
          .eq('status', 'published')
          .eq('is_featured', true)
          .order('announcement_date', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => BenefitAnnouncement.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching featured announcements: $e');
      rethrow;
    }
  }

  /// Search announcements by text
  Future<List<BenefitAnnouncement>> searchAnnouncements({
    required String query,
    String? categoryId,
    int limit = 50,
  }) async {
    try {
      final response = await _supabase
          .from('benefit_announcements')
          .select()
          .eq('status', 'published')
          .eq('category_id', categoryId ?? '')
          .or('title.ilike.%$query%,organization.ilike.%$query%,summary.ilike.%$query%')
          .order('announcement_date', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => BenefitAnnouncement.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error searching announcements: $e');
      rethrow;
    }
  }

  /// Increment views count
  Future<void> incrementViewsCount(String id) async {
    try {
      await _supabase.rpc('increment_announcement_views', params: {'announcement_id': id});
    } catch (e) {
      print('⚠️ Error incrementing views count: $e');
      // Don't throw - views count is not critical
    }
  }
}
