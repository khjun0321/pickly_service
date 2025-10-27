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
  /// Returns list of [CategoryBanner] ordered by display_order.
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
            category_id,
            title,
            subtitle,
            image_url,
            action_url,
            background_color,
            display_order,
            is_active,
            created_at,
            updated_at,
            benefit_categories!inner(slug)
          ''')
          .eq('is_active', true)
          .order('display_order', ascending: true);

      debugPrint('✅ Fetched ${response.length} active banners from database');

      return (response as List)
          .map((json) {
            // Extract slug from the nested benefit_categories object
            final categorySlug = json['benefit_categories'] != null
                ? (json['benefit_categories'] as Map)['slug'] as String
                : '';

            return CategoryBanner(
              id: json['id'] as String,
              categoryId: categorySlug, // Use slug instead of UUID
              title: json['title'] as String,
              subtitle: json['subtitle'] as String? ?? '',
              imageUrl: json['image_url'] as String,
              backgroundColor: json['background_color'] as String? ?? '#E3F2FD',
              actionUrl: json['action_url'] as String? ?? '',
              displayOrder: json['display_order'] as int? ?? 0,
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
  /// ordered by display_order.
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
            category_id,
            title,
            subtitle,
            image_url,
            action_url,
            background_color,
            display_order,
            is_active,
            created_at,
            updated_at
          ''')
          .eq('category_id', categoryId)
          .eq('is_active', true)
          .order('display_order', ascending: true);

      debugPrint('✅ Fetched ${response.length} banners for category $categoryId');

      return (response as List)
          .map((json) => CategoryBanner(
                id: json['id'] as String,
                categoryId: json['category_id'] as String,
                title: json['title'] as String,
                subtitle: json['subtitle'] as String? ?? '',
                imageUrl: json['image_url'] as String,
                backgroundColor: json['background_color'] as String? ?? '#E3F2FD',
                actionUrl: json['action_url'] as String? ?? '',
                displayOrder: json['display_order'] as int? ?? 0,
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
            category_id,
            title,
            subtitle,
            image_url,
            action_url,
            background_color,
            display_order,
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
        categoryId: response['category_id'] as String,
        title: response['title'] as String,
        subtitle: response['subtitle'] as String? ?? '',
        imageUrl: response['image_url'] as String,
        backgroundColor: response['background_color'] as String? ?? '#E3F2FD',
        actionUrl: response['action_url'] as String? ?? '',
        displayOrder: response['display_order'] as int? ?? 0,
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
}
