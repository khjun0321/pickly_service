import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/age_category.dart';

/// Repository for managing age category data with Supabase and local caching
///
/// Features:
/// - Fetches age categories from Supabase
/// - Saves and retrieves user selections
/// - Local caching with SharedPreferences
/// - Comprehensive error handling
class AgeCategoryRepository {
  final SupabaseClient _client;
  final SharedPreferences? _prefs;

  static const String _tableName = 'age_categories';
  static const String _userProfilesTable = 'user_profiles';
  static const String _cacheKey = 'cached_age_categories';
  static const String _userSelectionKey = 'user_selected_categories';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const Duration _cacheExpiration = Duration(hours: 24);

  AgeCategoryRepository({
    SupabaseClient? client,
    SharedPreferences? prefs,
  })  : _client = client ?? Supabase.instance.client,
        _prefs = prefs;

  /// Fetches all active age categories ordered by sort_order
  ///
  /// Returns cached data if available and not expired, otherwise fetches from Supabase
  /// Throws [AgeCategoryException] on error
  Future<List<AgeCategory>> fetchAll() async {
    try {
      // Try to get from cache first
      final cachedCategories = await _getCachedCategories();
      if (cachedCategories != null && cachedCategories.isNotEmpty) {
        return cachedCategories;
      }

      // Fetch from Supabase
      final response = await _client
          .from(_tableName)
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final categories = (response as List)
          .map((json) => AgeCategory.fromJson(json as Map<String, dynamic>))
          .toList();

      // Cache the results
      await _cacheCategories(categories);

      return categories;
    } on PostgrestException catch (e) {
      throw AgeCategoryException(
        'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      throw AgeCategoryException(
        'Failed to fetch age categories: $e',
      );
    }
  }

  /// Saves user's selected category IDs to Supabase and local storage
  ///
  /// Updates the user_profiles table with selected categories
  /// Also caches the selection locally for offline access
  /// Throws [AgeCategoryException] on error
  Future<void> saveUserSelection(List<String> categoryIds) async {
    if (categoryIds.isEmpty) {
      throw AgeCategoryException('Category IDs cannot be empty');
    }

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw AgeCategoryException('User not authenticated');
      }

      // Check if profile exists
      final existing = await _client
          .from(_userProfilesTable)
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        // Update existing profile
        await _client
            .from(_userProfilesTable)
            .update({
              'selected_categories': categoryIds,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId);
      } else {
        // Insert new profile
        await _client.from(_userProfilesTable).insert({
          'user_id': userId,
          'selected_categories': categoryIds,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      // Cache locally
      await _cacheUserSelection(categoryIds);
    } on PostgrestException catch (e) {
      throw AgeCategoryException(
        'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      throw AgeCategoryException(
        'Failed to save user selection: $e',
      );
    }
  }

  /// Retrieves user's selected category IDs
  ///
  /// Returns cached selection if available, otherwise fetches from Supabase
  /// Returns empty list if no selection exists
  /// Throws [AgeCategoryException] on error
  Future<List<String>> getUserSelection() async {
    try {
      // Try cache first
      final cachedSelection = await _getCachedUserSelection();
      if (cachedSelection != null && cachedSelection.isNotEmpty) {
        return cachedSelection;
      }

      // Fetch from Supabase
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final response = await _client
          .from(_userProfilesTable)
          .select('selected_categories')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null || response['selected_categories'] == null) {
        return [];
      }

      final categoryIds = List<String>.from(
        response['selected_categories'] as List,
      );

      // Cache the result
      await _cacheUserSelection(categoryIds);

      return categoryIds;
    } on PostgrestException catch (e) {
      throw AgeCategoryException(
        'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      throw AgeCategoryException(
        'Failed to get user selection: $e',
      );
    }
  }

  /// Fetches a single age category by ID
  ///
  /// Returns [AgeCategory] if found, null otherwise
  /// Throws [AgeCategoryException] on error
  Future<AgeCategory?> fetchCategoryById(String id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', id)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return AgeCategory.fromJson(response);
    } on PostgrestException catch (e) {
      throw AgeCategoryException(
        'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      throw AgeCategoryException(
        'Failed to fetch age category: $e',
      );
    }
  }

  /// Validates that a list of category IDs exist in the database
  ///
  /// Returns true if all IDs are valid and active
  /// Throws [AgeCategoryException] on error
  Future<bool> validateCategoryIds(List<String> categoryIds) async {
    if (categoryIds.isEmpty) {
      return true;
    }

    try {
      final response = await _client
          .from(_tableName)
          .select('id')
          .inFilter('id', categoryIds)
          .eq('is_active', true);

      final validIds = (response as List)
          .map((item) => item['id'] as String)
          .toSet();

      return validIds.length == categoryIds.length;
    } on PostgrestException catch (e) {
      throw AgeCategoryException(
        'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      throw AgeCategoryException(
        'Failed to validate category IDs: $e',
      );
    }
  }

  /// Clears all cached data
  Future<void> clearCache() async {
    if (_prefs == null) return;

    await _prefs.remove(_cacheKey);
    await _prefs.remove(_cacheTimestampKey);
    await _prefs.remove(_userSelectionKey);
  }

  // Private helper methods for caching

  Future<List<AgeCategory>?> _getCachedCategories() async {
    if (_prefs == null) return null;

    final timestamp = _prefs.getInt(_cacheTimestampKey);
    if (timestamp == null) return null;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (DateTime.now().difference(cacheTime) > _cacheExpiration) {
      // Cache expired
      await _prefs.remove(_cacheKey);
      await _prefs.remove(_cacheTimestampKey);
      return null;
    }

    final cachedJson = _prefs.getString(_cacheKey);
    if (cachedJson == null) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(cachedJson);
      return jsonList
          .map((json) => AgeCategory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Cache corrupted, remove it
      await _prefs.remove(_cacheKey);
      await _prefs.remove(_cacheTimestampKey);
      return null;
    }
  }

  Future<void> _cacheCategories(List<AgeCategory> categories) async {
    if (_prefs == null) return;

    final jsonList = categories.map((cat) => cat.toJson()).toList();
    await _prefs.setString(_cacheKey, jsonEncode(jsonList));
    await _prefs.setInt(
      _cacheTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<String>?> _getCachedUserSelection() async {
    if (_prefs == null) return null;

    final cachedJson = _prefs.getString(_userSelectionKey);
    if (cachedJson == null) return null;

    try {
      final List<dynamic> jsonList = jsonDecode(cachedJson);
      return jsonList.cast<String>();
    } catch (e) {
      // Cache corrupted, remove it
      await _prefs.remove(_userSelectionKey);
      return null;
    }
  }

  Future<void> _cacheUserSelection(List<String> categoryIds) async {
    if (_prefs == null) return;
    await _prefs.setString(_userSelectionKey, jsonEncode(categoryIds));
  }
}

/// Custom exception for age category operations
class AgeCategoryException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AgeCategoryException(
    this.message, {
    this.code,
    this.details,
  });

  @override
  String toString() {
    final buffer = StringBuffer('AgeCategoryException: $message');
    if (code != null) {
      buffer.write(' (code: $code)');
    }
    if (details != null) {
      buffer.write(' - Details: $details');
    }
    return buffer.toString();
  }
}
