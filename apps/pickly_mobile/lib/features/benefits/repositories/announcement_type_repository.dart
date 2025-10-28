/// Announcement Type Repository (v7.3)
///
/// Provides data access methods for announcement types.
/// Handles Supabase queries for announcement type management.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement_type.dart';

/// Repository for announcement type data operations.
class AnnouncementTypeRepository {
  final SupabaseClient _client;

  /// Creates an [AnnouncementTypeRepository] with the given Supabase client.
  AnnouncementTypeRepository(this._client);

  /// Fetches all announcement types for a given category.
  ///
  /// Returns only active types ordered by sort_order.
  /// Throws an exception if the query fails.
  Future<List<AnnouncementType>> getTypesByCategory(
    String categoryId, {
    bool includeInactive = false,
  }) async {
    try {
      var query = _client
          .from('announcement_types')
          .select()
          .eq('benefit_category_id', categoryId);

      if (!includeInactive) {
        query = query.eq('is_active', true);
      }

      final response = await query.order('sort_order', ascending: true);

      return (response as List)
          .map((json) => AnnouncementType.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch announcement types: $e');
    }
  }

  /// Fetches all announcement types across all categories.
  ///
  /// Useful for admin interfaces or global filtering.
  Future<List<AnnouncementType>> getAllTypes({
    bool includeInactive = false,
  }) async {
    try {
      var query = _client.from('announcement_types').select();

      if (!includeInactive) {
        query = query.eq('is_active', true);
      }

      final response = await query
          .order('benefit_category_id')
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => AnnouncementType.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all announcement types: $e');
    }
  }

  /// Fetches a single announcement type by ID.
  Future<AnnouncementType> getTypeById(String id) async {
    try {
      final response = await _client
          .from('announcement_types')
          .select()
          .eq('id', id)
          .single();

      return AnnouncementType.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch announcement type: $e');
    }
  }

  /// Creates a new announcement type.
  ///
  /// Returns the created announcement type with server-generated fields.
  Future<AnnouncementType> createType(AnnouncementType type) async {
    try {
      final response = await _client
          .from('announcement_types')
          .insert(type.toJson())
          .select()
          .single();

      return AnnouncementType.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create announcement type: $e');
    }
  }

  /// Updates an existing announcement type.
  Future<AnnouncementType> updateType(AnnouncementType type) async {
    try {
      final response = await _client
          .from('announcement_types')
          .update(type.toJson())
          .eq('id', type.id)
          .select()
          .single();

      return AnnouncementType.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update announcement type: $e');
    }
  }

  /// Deletes an announcement type by ID.
  Future<void> deleteType(String id) async {
    try {
      await _client.from('announcement_types').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete announcement type: $e');
    }
  }

  /// Gets the count of announcements for each type in a category.
  ///
  /// Returns a map of type ID to announcement count.
  Future<Map<String, int>> getAnnouncementCountsByCategory(
    String categoryId,
  ) async {
    try {
      final types = await getTypesByCategory(categoryId);
      final Map<String, int> counts = {};

      for (final type in types) {
        final response = await _client
            .from('announcements')
            .select('id')
            .eq('type_id', type.id)
            .count();

        counts[type.id] = response.count;
      }

      return counts;
    } catch (e) {
      throw Exception('Failed to fetch announcement counts: $e');
    }
  }
}
