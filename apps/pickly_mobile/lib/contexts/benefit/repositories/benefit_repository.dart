import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/announcement.dart';
import '../models/announcement_file.dart';
import '../models/benefit_category.dart';
import '../exceptions/announcement_exception.dart';

part 'benefit_repository.g.dart';

/// Benefit Repository Provider
@riverpod
BenefitRepository benefitRepository(Ref ref) {
  return BenefitRepository(Supabase.instance.client);
}

/// Comprehensive Benefit Repository with Realtime Streams
///
/// Provides stream-based data access for benefit announcements, categories,
/// and related resources using Supabase Realtime subscriptions.
class BenefitRepository {
  final SupabaseClient _client;

  // Stream caching to prevent duplicate subscriptions
  Stream<List<BenefitCategory>>? _cachedCategoriesStream;

  BenefitRepository(this._client);

  // ============================================================================
  // CATEGORIES
  // ============================================================================

  /// Get all active benefit categories
  ///
  /// Returns categories sorted by display_order in ascending order.
  /// Only returns active categories (is_active = true).
  Future<List<BenefitCategory>> getCategories() async {
    try {
      final response = await _client
          .from('benefit_categories')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => BenefitCategory.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AnnouncementNetworkException(e.message);
    } catch (e, stackTrace) {
      throw AnnouncementException(e.toString(), stackTrace);
    }
  }

  /// Get single category by ID
  Future<BenefitCategory> getCategoryById(String categoryId) async {
    try {
      final response = await _client
          .from('benefit_categories')
          .select()
          .eq('id', categoryId)
          .single();

      return BenefitCategory.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const AnnouncementNotFoundException();
      }
      throw AnnouncementNetworkException(e.message);
    } catch (e, stackTrace) {
      throw AnnouncementException(e.toString(), stackTrace);
    }
  }

  /// Get category by slug (URL-friendly identifier)
  Future<BenefitCategory?> getCategoryBySlug(String slug) async {
    try {
      final response = await _client
          .from('benefit_categories')
          .select()
          .eq('slug', slug)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;
      return BenefitCategory.fromJson(response);
    } on PostgrestException catch (e) {
      throw AnnouncementNetworkException(e.message);
    } catch (e, stackTrace) {
      throw AnnouncementException(e.toString(), stackTrace);
    }
  }

  /// Watch all active benefit categories with Realtime updates
  ///
  /// Returns a stream of active categories sorted by display_order.
  /// Automatically updates when Admin creates/updates/deletes categories.
  ///
  /// PRD v9.6.1 Phase 3: Realtime Sync Implementation (Step 3 - Provider Layer)
  /// Phase 6.3: Stream caching to prevent duplicate subscriptions
  ///
  /// Note: This is a simplified implementation for Provider layer integration.
  /// Full implementation with advanced filtering will be added in Step 4.
  Stream<List<BenefitCategory>> watchCategories() {
    // Return cached stream if already exists
    if (_cachedCategoriesStream != null) {
      print('🔄 [Stream Cache] Returning existing categories stream');
      return _cachedCategoriesStream!;
    }

    print('🌊 [BenefitRepository] Creating watchCategories() stream subscription');
    print('📡 [Supabase Realtime] Starting NEW stream on benefit_categories table');

    // Create and cache the stream
    _cachedCategoriesStream = _client
        .from('benefit_categories')
        .stream(primaryKey: ['id'])
        .order('sort_order', ascending: true)
        .handleError((error, stackTrace) {
          print('❌ [Stream Error] Supabase stream error: $error');
          print('   StackTrace: $stackTrace');
        })
        .map((data) {
          print('\n🔄 [Supabase Event] Stream received data update');
          print('📊 [Raw Data] Total rows received: ${data.length}');

          // Filter active categories
          final activeCategories = data
              .where((json) => json['is_active'] == true)
              .toList();

          print('✅ [Filtered] Active categories: ${activeCategories.length}');

          // Parse to model objects
          final categories = activeCategories
              .map((json) {
                try {
                  final category = BenefitCategory.fromJson(json as Map<String, dynamic>);
                  print('  ✓ Category: ${category.title} (${category.slug}) - order: ${category.sortOrder}');
                  return category;
                } catch (e, stackTrace) {
                  print('❌ [Parse Error] Failed to parse category: $e');
                  print('   Raw JSON: $json');
                  print('   StackTrace: $stackTrace');
                  rethrow;
                }
              })
              .toList();

          print('📋 [Final Result] Emitting ${categories.length} categories to stream subscribers\n');

          return categories;
        })
        .asBroadcastStream(); // Make stream shareable across multiple listeners

    return _cachedCategoriesStream!;
  }

  /// Dispose of cached streams (called when repository is no longer needed)
  void dispose() {
    _cachedCategoriesStream = null;
  }

  // ============================================================================
  // ANNOUNCEMENTS - STREAM BASED (REALTIME)
  // ============================================================================

  /// Watch announcements by category with Realtime updates
  ///
  /// Returns a stream of announcements filtered by category.
  /// Sorted by:
  /// 1. display_order (ascending) - Admin-controlled featured ordering
  /// 2. created_at (descending) - Most recent first
  ///
  /// Only includes published announcements without deleted_at timestamp.
  Stream<List<Announcement>> watchAnnouncementsByCategory(String categoryId) {
    return _client
        .from('benefit_announcements')
        .stream(primaryKey: ['id'])
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false)
        .map((data) => data
            .where((json) =>
                json['category_id'] == categoryId &&
                json['status'] == 'published')
            .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
            .toList());
  }

  /// Watch all published announcements (across all categories)
  ///
  /// Useful for home feed or general announcement listing.
  Stream<List<Announcement>> watchAllAnnouncements({
    int? limit,
    bool featuredOnly = false,
  }) {
    return _client
        .from('benefit_announcements')
        .stream(primaryKey: ['id'])
        .order('published_at', ascending: false)
        .map((data) {
          var announcements = data
              .where((json) {
                if (json['status'] != 'published') return false;
                if (featuredOnly && json['is_featured'] != true) return false;
                return true;
              })
              .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
              .toList();

          if (limit != null && announcements.length > limit) {
            return announcements.sublist(0, limit);
          }

          return announcements;
        });
  }

  /// Watch featured announcements with Realtime updates
  ///
  /// Returns only announcements marked as featured (is_featured = true).
  Stream<List<Announcement>> watchFeaturedAnnouncements({int limit = 10}) {
    return _client
        .from('benefit_announcements')
        .stream(primaryKey: ['id'])
        .order('published_at', ascending: false)
        .map((data) => data
            .where((json) =>
                json['status'] == 'published' &&
                json['is_featured'] == true)
            .take(limit)
            .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
            .toList());
  }

  // ============================================================================
  // ANNOUNCEMENTS - FUTURE BASED (ONE-TIME FETCH)
  // ============================================================================

  /// Get single announcement by ID
  ///
  /// Fetches announcement details including all metadata.
  /// Increments view count as a side effect.
  Future<Announcement> getAnnouncement(String id) async {
    try {
      final response = await _client
          .from('benefit_announcements')
          .select()
          .eq('id', id)
          .single();

      // Increment view count asynchronously (fire and forget)
      incrementViewCount(id);

      return Announcement.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const AnnouncementNotFoundException();
      }
      throw AnnouncementNetworkException(e.message);
    } catch (e, stackTrace) {
      throw AnnouncementException(e.toString(), stackTrace);
    }
  }

  /// Get announcements by category (one-time fetch)
  Future<List<Announcement>> getAnnouncementsByCategory(
    String categoryId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('benefit_announcements')
          .select()
          .eq('category_id', categoryId)
          .eq('status', 'published')
          .order('sort_order', ascending: true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AnnouncementNetworkException(e.message);
    } catch (e, stackTrace) {
      throw AnnouncementException(e.toString(), stackTrace);
    }
  }

  /// Search announcements with text query
  ///
  /// Searches across title, subtitle, and summary fields.
  Future<List<Announcement>> searchAnnouncements(
    String query, {
    String? categoryId,
    int limit = 50,
  }) async {
    try {
      var queryBuilder = _client
          .from('benefit_announcements')
          .select()
          .eq('status', 'published');

      if (categoryId != null) {
        queryBuilder = queryBuilder.eq('category_id', categoryId);
      }

      final response = await queryBuilder
          .or('title.ilike.%$query%,subtitle.ilike.%$query%,summary.ilike.%$query%')
          .order('published_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AnnouncementNetworkException(e.message);
    } catch (e, stackTrace) {
      throw AnnouncementException(e.toString(), stackTrace);
    }
  }

  /// Get popular announcements (by view count)
  Future<List<Announcement>> getPopularAnnouncements({
    int limit = 10,
    String? categoryId,
  }) async {
    try {
      var queryBuilder = _client
          .from('benefit_announcements')
          .select()
          .eq('status', 'published');

      if (categoryId != null) {
        queryBuilder = queryBuilder.eq('category_id', categoryId);
      }

      final response = await queryBuilder
          .order('views_count', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AnnouncementNetworkException(e.message);
    } catch (e, stackTrace) {
      throw AnnouncementException(e.toString(), stackTrace);
    }
  }

  // ============================================================================
  // ANNOUNCEMENT FILES
  // ============================================================================

  /// Get files associated with an announcement
  ///
  /// Note: This assumes files are stored in Supabase Storage with metadata
  /// tracked separately. Implementation may need adjustment based on actual
  /// storage structure.
  ///
  /// Returns files sorted by display_order.
  Future<List<AnnouncementFile>> getFiles(String announcementId) async {
    try {
      // TODO: Implement based on actual file storage structure
      // This is a placeholder implementation

      // Option 1: If using a separate announcement_files table
      // final response = await _client
      //     .from('announcement_files')
      //     .select()
      //     .eq('announcement_id', announcementId)
      //     .order('display_order', ascending: true);

      // Option 2: If using Supabase Storage directly
      // Query storage bucket for files related to announcement
      // final files = await _client.storage
      //     .from('announcement-files')
      //     .list(path: announcementId);

      // For now, return empty list until file storage is implemented
      return [];

      // Example implementation when files table exists:
      // return (response as List)
      //     .map((json) => AnnouncementFile.fromJson(json as Map<String, dynamic>))
      //     .toList();
    } on PostgrestException catch (e) {
      throw AnnouncementNetworkException(e.message);
    } catch (e, stackTrace) {
      throw AnnouncementException(e.toString(), stackTrace);
    }
  }

  /// Download or get URL for a specific file
  Future<String> getFileUrl(String fileId) async {
    try {
      // TODO: Implement based on actual file storage structure
      // This could return a signed URL from Supabase Storage

      // Example:
      // final fileRecord = await _client
      //     .from('announcement_files')
      //     .select('file_path')
      //     .eq('id', fileId)
      //     .single();
      //
      // final signedUrl = await _client.storage
      //     .from('announcement-files')
      //     .createSignedUrl(fileRecord['file_path'], 3600);
      //
      // return signedUrl;

      throw UnimplementedError('File storage not yet implemented');
    } on PostgrestException catch (e) {
      throw AnnouncementNetworkException(e.message);
    } catch (e, stackTrace) {
      throw AnnouncementException(e.toString(), stackTrace);
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Increment view count for an announcement
  ///
  /// This is called automatically when fetching announcement details.
  /// Failures are silently ignored to not impact user experience.
  Future<void> incrementViewCount(String announcementId) async {
    try {
      await _client.rpc('increment_announcement_view_count', params: {
        'announcement_id': announcementId,
      });
    } catch (e) {
      // Silently ignore view count increment failures
      // This should not impact user experience
      // Could log to analytics/monitoring service
    }
  }

  /// Get announcement count by category
  Future<int> getAnnouncementCount(String categoryId) async {
    try {
      final response = await _client
          .from('benefit_announcements')
          .select('id')
          .eq('category_id', categoryId)
          .eq('status', 'published')
          .count(CountOption.exact);

      return response.count;
    } on PostgrestException catch (e) {
      throw AnnouncementNetworkException(e.message);
    } catch (e, stackTrace) {
      throw AnnouncementException(e.toString(), stackTrace);
    }
  }

  /// Check if an announcement is currently accepting applications
  ///
  /// Note: Application period fields (applicationPeriodStart, applicationPeriodEnd)
  /// are not present in the current Announcement model.
  /// This method returns whether the announcement status is 'recruiting'.
  ///
  /// PRD v9.6.1: Status field alignment
  Future<bool> isAcceptingApplications(String announcementId) async {
    try {
      final announcement = await getAnnouncement(announcementId);

      // Check if status is 'recruiting' (모집중)
      return announcement.status == 'recruiting';
    } catch (e, stackTrace) {
      throw AnnouncementException(e.toString(), stackTrace);
    }
  }
}
