/// Announcement Repository
///
/// Handles all database operations for announcements and announcement types using Supabase.
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pickly_mobile/features/benefits/models/announcement.dart';
import 'package:pickly_mobile/features/benefits/models/announcement_type.dart';

/// Repository for announcement and announcement type data operations
///
/// Responsibilities:
/// - Fetch announcements and announcement types from Supabase
/// - Map database records to domain models
/// - Handle filtering by category, type, and status
/// - Handle error cases gracefully
class AnnouncementRepository {
  final SupabaseClient _supabase;

  AnnouncementRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  // ==================== Announcement Types ====================

  /// Fetch all active announcement types for a specific category
  ///
  /// Parameters:
  /// - [categoryId]: UUID or slug of the benefit category
  ///
  /// Returns list of [AnnouncementType] ordered by sort_order.
  /// Only returns active types (is_active = true).
  ///
  /// Throws:
  /// - [PostgrestException] if database query fails
  Future<List<AnnouncementType>> fetchAnnouncementTypesByCategory(
      String categoryId) async {
    try {
      debugPrint('📡 Fetching announcement types for category: $categoryId');

      final response = await _supabase
          .from('announcement_types')
          .select('''
            id,
            benefit_category_id,
            title,
            description,
            sort_order,
            is_active,
            created_at,
            updated_at
          ''')
          .eq('benefit_category_id', categoryId)
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      debugPrint(
          '✅ Fetched ${response.length} announcement types for category $categoryId');

      return (response as List)
          .map((json) => AnnouncementType.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching announcement types: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Fetch all active announcement types
  ///
  /// Returns list of all [AnnouncementType] ordered by sort_order.
  /// Only returns active types (is_active = true).
  ///
  /// Throws:
  /// - [PostgrestException] if database query fails
  Future<List<AnnouncementType>> fetchAllAnnouncementTypes() async {
    try {
      debugPrint('📡 Fetching all announcement types from Supabase...');

      final response = await _supabase
          .from('announcement_types')
          .select('''
            id,
            benefit_category_id,
            title,
            description,
            sort_order,
            is_active,
            created_at,
            updated_at
          ''')
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      debugPrint('✅ Fetched ${response.length} announcement types');

      return (response as List)
          .map((json) => AnnouncementType.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching announcement types: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ==================== Announcements ====================

  /// Fetch announcements by type ID
  ///
  /// Parameters:
  /// - [typeId]: UUID of the announcement type
  /// - [status]: Optional status filter ('open', 'closed', 'upcoming')
  ///
  /// Returns list of [Announcement] ordered by priority then posted_date DESC.
  ///
  /// Throws:
  /// - [PostgrestException] if database query fails
  Future<List<Announcement>> fetchAnnouncementsByType(String typeId,
      {String? status}) async {
    try {
      debugPrint('📡 Fetching announcements for type: $typeId, status: $status');

      var query = _supabase
          .from('announcements')
          .select('''
            id,
            type_id,
            title,
            organization,
            region,
            thumbnail_url,
            posted_date,
            status,
            is_priority,
            detail_url,
            created_at,
            updated_at
          ''')
          .eq('type_id', typeId);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query
          .order('is_priority', ascending: false)
          .order('posted_date', ascending: false);

      debugPrint(
          '✅ Fetched ${response.length} announcements for type $typeId');

      return (response as List)
          .map((json) => Announcement.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching announcements by type: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Fetch all announcements with optional filters
  ///
  /// Parameters:
  /// - [status]: Optional status filter ('open', 'closed', 'upcoming')
  /// - [priorityOnly]: If true, only fetch priority announcements
  ///
  /// Returns list of [Announcement] ordered by priority then posted_date DESC.
  ///
  /// Throws:
  /// - [PostgrestException] if database query fails
  Future<List<Announcement>> fetchAllAnnouncements(
      {String? status, bool priorityOnly = false}) async {
    try {
      debugPrint(
          '📡 Fetching all announcements (status: $status, priority: $priorityOnly)');

      var query = _supabase.from('announcements').select('''
            id,
            type_id,
            title,
            organization,
            region,
            thumbnail_url,
            posted_date,
            status,
            is_priority,
            detail_url,
            created_at,
            updated_at
          ''');

      if (status != null) {
        query = query.eq('status', status);
      }

      if (priorityOnly) {
        query = query.eq('is_priority', true);
      }

      final response = await query
          .order('is_priority', ascending: false)
          .order('posted_date', ascending: false);

      debugPrint('✅ Fetched ${response.length} announcements');

      return (response as List)
          .map((json) => Announcement.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching all announcements: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Fetch announcement by ID
  ///
  /// Parameters:
  /// - [id]: Announcement UUID
  ///
  /// Returns [Announcement] if found, null otherwise.
  Future<Announcement?> fetchAnnouncementById(String id) async {
    try {
      debugPrint('📡 Fetching announcement by ID: $id');

      final response = await _supabase
          .from('announcements')
          .select('''
            id,
            type_id,
            title,
            organization,
            region,
            thumbnail_url,
            posted_date,
            status,
            is_priority,
            detail_url,
            created_at,
            updated_at
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ Announcement not found: $id');
        return null;
      }

      debugPrint('✅ Fetched announcement: $id');

      return Announcement.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching announcement by ID: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Fetch announcements with full details (joins with announcement_types)
  ///
  /// Uses the v_announcements_full view for optimized queries.
  ///
  /// Parameters:
  /// - [categoryId]: Optional category UUID filter
  /// - [status]: Optional status filter
  /// - [limit]: Maximum number of results (default 20)
  ///
  /// Returns list of maps with announcement + type data
  Future<List<Map<String, dynamic>>> fetchAnnouncementsWithDetails({
    String? categoryId,
    String? status,
    int limit = 20,
  }) async {
    try {
      debugPrint(
          '📡 Fetching announcements with details (category: $categoryId, status: $status)');

      var query = _supabase.from('v_announcements_full').select();

      if (categoryId != null) {
        query = query.eq('benefit_category_id', categoryId);
      }

      if (status != null) {
        query = query.eq('announcement_status', status);
      }

      final response = await query
          .order('is_priority', ascending: false)
          .order('posted_date', ascending: false)
          .limit(limit);

      debugPrint('✅ Fetched ${response.length} announcements with details');

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching announcements with details: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
