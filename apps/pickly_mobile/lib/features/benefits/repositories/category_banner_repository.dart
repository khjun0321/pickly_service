/// Category Banner Repository
///
/// Handles all database operations for category banners using Supabase.
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pickly_mobile/features/benefits/models/category_banner.dart';

/// Repository for category banner data operations
///
/// Responsibilities:
/// - Fetch banners from Supabase
/// - Map database records to domain models
/// - Handle error cases gracefully
class CategoryBannerRepository {
  final SupabaseClient _supabase;

  CategoryBannerRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Fetch all active banners from the database with category slug
  ///
  /// Returns list of [CategoryBanner] ordered by sort_order.
  /// Only returns active banners (is_active = true).
  ///
  /// Note: This method performs a JOIN with benefit_categories to get the slug.
  ///
  /// Throws:
  /// - [PostgrestException] if database query fails
  Future<List<CategoryBanner>> fetchActiveBanners() async {
    try {
      debugPrint('📡 Fetching active banners from Supabase...');

      // Use a raw query to join with benefit_categories and get the slug
      final response = await _supabase
          .from('category_banners')
          .select('''
            id,
            benefit_category_id,
            title,
            subtitle,
            image_url,
            link_type,
            link_target,
            background_color,
            sort_order,
            is_active,
            created_at,
            updated_at,
            benefit_categories!inner(slug)
          ''')
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      debugPrint('✅ Fetched ${response.length} active banners from database');

      return (response as List)
          .map((json) {
            // Extract slug from the nested benefit_categories object
            final categorySlug = json['benefit_categories'] != null
                ? (json['benefit_categories'] as Map)['slug'] as String
                : '';

            return CategoryBanner(
              id: json['id'] as String,
              benefitCategoryId: categorySlug, // Use slug instead of UUID
              title: json['title'] as String,
              subtitle: json['subtitle'] as String?,
              imageUrl: json['image_url'] as String,
              backgroundColor: json['background_color'] as String?,
              linkType: json['link_type'] as String? ?? 'none',
              linkTarget: json['link_target'] as String?,
              sortOrder: json['sort_order'] as int? ?? 0,
              isActive: json['is_active'] as bool? ?? true,
              createdAt: DateTime.parse(json['created_at'] as String),
              updatedAt: DateTime.parse(json['updated_at'] as String),
            );
          })
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching banners: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Fetch banners for a specific category
  ///
  /// Parameters:
  /// - [categoryId]: UUID of the benefit category
  ///
  /// Returns list of [CategoryBanner] for the specified category,
  /// ordered by sort_order.
  ///
  /// Throws:
  /// - [PostgrestException] if database query fails
  Future<List<CategoryBanner>> fetchBannersForCategory(String categoryId) async {
    try {
      debugPrint('📡 Fetching banners for category: $categoryId');

      final response = await _supabase
          .from('category_banners')
          .select('''
            id,
            benefit_category_id,
            title,
            subtitle,
            image_url,
            link_type,
            link_target,
            background_color,
            sort_order,
            is_active,
            created_at,
            updated_at
          ''')
          .eq('benefit_category_id', categoryId)
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      debugPrint('✅ Fetched ${response.length} banners for category $categoryId');

      return (response as List)
          .map((json) => CategoryBanner(
                id: json['id'] as String,
                benefitCategoryId: json['benefit_category_id'] as String,
                title: json['title'] as String,
                subtitle: json['subtitle'] as String?,
                imageUrl: json['image_url'] as String,
                backgroundColor: json['background_color'] as String?,
                linkType: json['link_type'] as String? ?? 'none',
                linkTarget: json['link_target'] as String?,
                sortOrder: json['sort_order'] as int? ?? 0,
                isActive: json['is_active'] as bool? ?? true,
                createdAt: DateTime.parse(json['created_at'] as String),
                updatedAt: DateTime.parse(json['updated_at'] as String),
              ))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching banners for category: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get banner by ID
  ///
  /// Parameters:
  /// - [id]: Banner UUID
  ///
  /// Returns [CategoryBanner] if found, null otherwise.
  Future<CategoryBanner?> fetchBannerById(String id) async {
    try {
      debugPrint('📡 Fetching banner by ID: $id');

      final response = await _supabase
          .from('category_banners')
          .select('''
            id,
            benefit_category_id,
            title,
            subtitle,
            image_url,
            link_type,
            link_target,
            background_color,
            sort_order,
            is_active,
            created_at,
            updated_at
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ Banner not found: $id');
        return null;
      }

      debugPrint('✅ Fetched banner: $id');

      return CategoryBanner(
        id: response['id'] as String,
        benefitCategoryId: response['benefit_category_id'] as String,
        title: response['title'] as String,
        subtitle: response['subtitle'] as String?,
        imageUrl: response['image_url'] as String,
        backgroundColor: response['background_color'] as String?,
        linkType: response['link_type'] as String? ?? 'none',
        linkTarget: response['link_target'] as String?,
        sortOrder: response['sort_order'] as int? ?? 0,
        isActive: response['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(response['created_at'] as String),
        updatedAt: DateTime.parse(response['updated_at'] as String),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching banner by ID: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get category ID by slug
  ///
  /// Helper method to convert category slug (e.g., 'popular', 'housing')
  /// to category UUID for banner queries.
  ///
  /// Parameters:
  /// - [slug]: Category slug (e.g., 'popular', 'housing', 'education')
  ///
  /// Returns category UUID if found, null otherwise.
  Future<String?> getCategoryIdBySlug(String slug) async {
    try {
      debugPrint('📡 Getting category ID for slug: $slug');

      final response = await _supabase
          .from('benefit_categories')
          .select('id')
          .eq('slug', slug)
          .isFilter('parent_id', null)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ Category not found for slug: $slug');
        return null;
      }

      final categoryId = response['id'] as String;
      debugPrint('✅ Found category ID: $categoryId for slug: $slug');

      return categoryId;
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting category ID: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Fetch banners by category slug
  ///
  /// Convenience method that combines slug-to-ID lookup and banner fetch.
  ///
  /// Parameters:
  /// - [slug]: Category slug (e.g., 'popular', 'housing')
  ///
  /// Returns list of [CategoryBanner] for the category.
  /// Returns empty list if category not found.
  Future<List<CategoryBanner>> fetchBannersBySlug(String slug) async {
    try {
      final categoryId = await getCategoryIdBySlug(slug);
      if (categoryId == null) {
        debugPrint('⚠️ Cannot fetch banners: category not found for slug $slug');
        return [];
      }

      return await fetchBannersForCategory(categoryId);
    } catch (e) {
      debugPrint('❌ Error fetching banners by slug: $e');
      return [];
    }
  }

  // ==================== Realtime Streams (v8.6 Phase 2) ====================

  /// Watch all active banners in realtime with Supabase Stream
  ///
  /// This method creates a realtime stream that automatically emits updates
  /// when the category_banners table changes in Supabase.
  ///
  /// Returns a Stream of [List<CategoryBanner>] that emits:
  /// - Initial data immediately upon subscription
  /// - Updated data whenever banners are inserted/updated/deleted
  ///
  /// The stream:
  /// - Automatically reconnects on connection loss
  /// - Maintains proper ordering (sort_order ASC)
  /// - Filters only active banners
  /// - Includes category slug via JOIN
  ///
  /// Usage:
  /// ```dart
  /// final stream = repository.watchActiveBanners();
  /// stream.listen((banners) {
  ///   print('Got ${banners.length} banners');
  /// });
  /// ```
  ///
  /// Note: Supabase stream() doesn't support JOIN operations directly,
  /// so we need to fetch category slugs separately for each banner.
  Stream<List<CategoryBanner>> watchActiveBanners() {
    try {
      debugPrint('🌊 Starting realtime stream for category banners');

      return _supabase
          .from('category_banners')
          .stream(primaryKey: ['id'])
          .asyncMap((records) async {
            debugPrint('🔄 Received ${records.length} banners from stream');

            // Parse all records to CategoryBanner objects
            final banners = <CategoryBanner>[];

            for (final json in records) {
              try {
                // Check if banner is active
                final isActive = json['is_active'] as bool? ?? true;
                if (!isActive) continue;

                // Fetch category slug for this banner
                final categoryId = json['benefit_category_id'] as String;
                final categoryResponse = await _supabase
                    .from('benefit_categories')
                    .select('slug')
                    .eq('id', categoryId)
                    .maybeSingle();

                final categorySlug = categoryResponse != null
                    ? (categoryResponse['slug'] as String)
                    : categoryId; // Fallback to ID if slug not found

                final banner = CategoryBanner(
                  id: json['id'] as String,
                  benefitCategoryId: categorySlug,
                  title: json['title'] as String,
                  subtitle: json['subtitle'] as String?,
                  imageUrl: json['image_url'] as String,
                  backgroundColor: json['background_color'] as String?,
                  linkType: json['link_type'] as String? ?? 'none',
                  linkTarget: json['link_target'] as String?,
                  sortOrder: json['sort_order'] as int? ?? 0,
                  isActive: isActive,
                  createdAt: DateTime.parse(json['created_at'] as String),
                  updatedAt: DateTime.parse(json['updated_at'] as String),
                );

                banners.add(banner);
              } catch (e) {
                debugPrint('⚠️ Error parsing banner: $e');
                continue;
              }
            }

            // Sort by sort_order
            banners.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

            debugPrint('✅ Stream emitted ${banners.length} active banners');
            return banners;
          });
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating banners stream: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Watch banners for a specific category in realtime
  ///
  /// Parameters:
  /// - [categoryId]: UUID of the benefit category
  ///
  /// Returns a Stream of [List<CategoryBanner>] filtered by category
  ///
  /// Note: This method filters all banners in-memory. For better performance
  /// with large datasets, consider using database-side filtering if available.
  Stream<List<CategoryBanner>> watchBannersForCategory(String categoryId) {
    try {
      debugPrint('🌊 Starting realtime stream for category banners: $categoryId');

      return _supabase
          .from('category_banners')
          .stream(primaryKey: ['id'])
          .map((records) {
            final banners = records
                .where((json) {
                  final isActive = json['is_active'] as bool? ?? true;
                  final bannerId = json['benefit_category_id'] as String;
                  return isActive && bannerId == categoryId;
                })
                .map((json) => CategoryBanner(
                      id: json['id'] as String,
                      benefitCategoryId: json['benefit_category_id'] as String,
                      title: json['title'] as String,
                      subtitle: json['subtitle'] as String?,
                      imageUrl: json['image_url'] as String,
                      backgroundColor: json['background_color'] as String?,
                      linkType: json['link_type'] as String? ?? 'none',
                      linkTarget: json['link_target'] as String?,
                      sortOrder: json['sort_order'] as int? ?? 0,
                      isActive: json['is_active'] as bool? ?? true,
                      createdAt: DateTime.parse(json['created_at'] as String),
                      updatedAt: DateTime.parse(json['updated_at'] as String),
                    ))
                .toList();

            // Sort by sort_order
            banners.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

            debugPrint('✅ Stream emitted ${banners.length} banners for category $categoryId');
            return banners;
          });
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating category banners stream: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Watch a single banner by ID in realtime
  ///
  /// Parameters:
  /// - [id]: Banner UUID
  ///
  /// Returns a Stream of [CategoryBanner?] that emits:
  /// - The banner if found and active
  /// - null if not found, deleted, or deactivated
  Stream<CategoryBanner?> watchBannerById(String id) {
    try {
      debugPrint('🌊 Starting realtime stream for banner ID: $id');

      return _supabase
          .from('category_banners')
          .stream(primaryKey: ['id'])
          .map((records) {
            try {
              final record = records.firstWhere(
                (r) => r['id'] == id,
              );

              // Return null if banner is inactive
              final isActive = record['is_active'] as bool? ?? true;
              if (!isActive) {
                debugPrint('⚠️ Banner inactive: $id');
                return null;
              }

              debugPrint('✅ Stream emitted banner: $id');
              return CategoryBanner(
                id: record['id'] as String,
                benefitCategoryId: record['benefit_category_id'] as String,
                title: record['title'] as String,
                subtitle: record['subtitle'] as String?,
                imageUrl: record['image_url'] as String,
                backgroundColor: record['background_color'] as String?,
                linkType: record['link_type'] as String? ?? 'none',
                linkTarget: record['link_target'] as String?,
                sortOrder: record['sort_order'] as int? ?? 0,
                isActive: isActive,
                createdAt: DateTime.parse(record['created_at'] as String),
                updatedAt: DateTime.parse(record['updated_at'] as String),
              );
            } catch (e) {
              debugPrint('⚠️ Banner not found in stream: $id');
              return null;
            }
          });
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating banner stream by ID: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Watch banners by category slug in realtime
  ///
  /// Convenience method that watches banners for a category identified by slug.
  ///
  /// Parameters:
  /// - [slug]: Category slug (e.g., 'popular', 'housing')
  ///
  /// Returns a Stream of [List<CategoryBanner>] for the category.
  /// Emits empty list if category not found.
  Stream<List<CategoryBanner>> watchBannersBySlug(String slug) async* {
    try {
      final categoryId = await getCategoryIdBySlug(slug);
      if (categoryId == null) {
        debugPrint('⚠️ Cannot watch banners: category not found for slug $slug');
        yield [];
        return;
      }

      yield* watchBannersForCategory(categoryId);
    } catch (e) {
      debugPrint('❌ Error watching banners by slug: $e');
      yield [];
    }
  }
}
