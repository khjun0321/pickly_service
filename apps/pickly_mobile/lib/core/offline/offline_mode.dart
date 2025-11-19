/// Offline Mode Utility
///
/// Provides offline fallback capabilities for Supabase Stream data.
/// Uses SharedPreferences for local caching with automatic recovery.
///
/// Features:
/// - Automatic cache storage when Stream data arrives
/// - Instant fallback to cached data on network failure
/// - Auto-recovery when connection restored
/// - Configurable cache expiry
/// - Type-safe generic interface
///
/// Usage:
/// ```dart
/// final offlineMode = OfflineMode<List<Announcement>>();
///
/// // Save to cache
/// await offlineMode.save('announcements', announcements);
///
/// // Load from cache
/// final cached = await offlineMode.load('announcements');
///
/// // Check if cached data is stale
/// final isExpired = await offlineMode.isExpired('announcements', Duration(hours: 24));
/// ```
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline cache manager for Stream data
///
/// Generic type [T] represents the cached data type.
/// Supports JSON serialization via custom serializers.
class OfflineMode<T> {
  static const String _keyPrefix = 'offline_cache_';
  static const String _timestampSuffix = '_timestamp';

  /// Save data to offline cache
  ///
  /// Parameters:
  /// - [key]: Unique cache key (e.g., 'announcements', 'banners_popular')
  /// - [data]: Data to cache
  /// - [serializer]: Function to convert [T] to JSON-serializable object
  ///
  /// Example:
  /// ```dart
  /// await offlineMode.save(
  ///   'announcements',
  ///   announcements,
  ///   serializer: (list) => list.map((a) => a.toJson()).toList(),
  /// );
  /// ```
  Future<bool> save(
    String key,
    T data, {
    required dynamic Function(T) serializer,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(key);
      final timestampKey = _getTimestampKey(key);

      // Serialize data to JSON string
      final jsonData = serializer(data);
      final jsonString = jsonEncode(jsonData);

      // Save data and timestamp
      final saved = await prefs.setString(cacheKey, jsonString);
      final timestampSaved = await prefs.setInt(
        timestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      if (saved && timestampSaved) {
        debugPrint('💾 [Offline Cache] Saved: $key (${jsonString.length} bytes)');
        return true;
      }

      debugPrint('⚠️ [Offline Cache] Failed to save: $key');
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ [Offline Cache] Error saving $key: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Load data from offline cache
  ///
  /// Parameters:
  /// - [key]: Cache key
  /// - [deserializer]: Function to convert JSON object back to [T]
  ///
  /// Returns cached data or null if not found/invalid.
  ///
  /// Example:
  /// ```dart
  /// final announcements = await offlineMode.load(
  ///   'announcements',
  ///   deserializer: (json) => (json as List)
  ///       .map((item) => Announcement.fromJson(item))
  ///       .toList(),
  /// );
  /// ```
  Future<T?> load(
    String key, {
    required T Function(dynamic) deserializer,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(key);
      final jsonString = prefs.getString(cacheKey);

      if (jsonString == null) {
        debugPrint('ℹ️ [Offline Cache] No cached data for: $key');
        return null;
      }

      // Deserialize JSON string back to object
      final jsonData = jsonDecode(jsonString);
      final data = deserializer(jsonData);

      // Get cache age
      final age = await getCacheAge(key);
      debugPrint('📂 [Offline Cache] Loaded: $key (age: ${age?.inMinutes ?? 0} min)');

      return data;
    } catch (e, stackTrace) {
      debugPrint('❌ [Offline Cache] Error loading $key: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Check if cached data is expired
  ///
  /// Parameters:
  /// - [key]: Cache key
  /// - [maxAge]: Maximum allowed age (default: 24 hours)
  ///
  /// Returns true if data is older than [maxAge] or doesn't exist.
  Future<bool> isExpired(
    String key, {
    Duration maxAge = const Duration(hours: 24),
  }) async {
    try {
      final age = await getCacheAge(key);

      if (age == null) {
        return true; // No cache = expired
      }

      final expired = age > maxAge;
      if (expired) {
        debugPrint('⏰ [Offline Cache] Expired: $key (age: ${age.inHours}h, max: ${maxAge.inHours}h)');
      }

      return expired;
    } catch (e) {
      debugPrint('❌ [Offline Cache] Error checking expiry for $key: $e');
      return true; // Assume expired on error
    }
  }

  /// Get cache age
  ///
  /// Returns the Duration since data was cached, or null if not found.
  Future<Duration?> getCacheAge(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampKey = _getTimestampKey(key);
      final timestamp = prefs.getInt(timestampKey);

      if (timestamp == null) {
        return null;
      }

      final cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateTime.now().difference(cachedAt);
    } catch (e) {
      debugPrint('❌ [Offline Cache] Error getting cache age for $key: $e');
      return null;
    }
  }

  /// Clear cache for a specific key
  ///
  /// Returns true if successfully cleared.
  Future<bool> clear(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(key);
      final timestampKey = _getTimestampKey(key);

      final removed = await prefs.remove(cacheKey);
      await prefs.remove(timestampKey);

      if (removed) {
        debugPrint('🗑️ [Offline Cache] Cleared: $key');
      }

      return removed;
    } catch (e) {
      debugPrint('❌ [Offline Cache] Error clearing $key: $e');
      return false;
    }
  }

  /// Clear all offline caches
  ///
  /// Use with caution - this removes ALL cached data.
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      // Find all offline cache keys
      final cacheKeys = keys.where((k) => k.startsWith(_keyPrefix)).toList();

      // Remove all cache keys
      for (final key in cacheKeys) {
        await prefs.remove(key);
      }

      debugPrint('🗑️ [Offline Cache] Cleared all caches (${cacheKeys.length} keys)');
      return true;
    } catch (e) {
      debugPrint('❌ [Offline Cache] Error clearing all caches: $e');
      return false;
    }
  }

  /// Get cache statistics
  ///
  /// Returns information about all cached data.
  Future<Map<String, dynamic>> getStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      final cacheKeys = keys
          .where((k) => k.startsWith(_keyPrefix) && !k.endsWith(_timestampSuffix))
          .toList();

      final stats = <String, dynamic>{};
      int totalSize = 0;

      for (final fullKey in cacheKeys) {
        final key = fullKey.replaceFirst(_keyPrefix, '');
        final data = prefs.getString(fullKey);
        final age = await getCacheAge(key);

        if (data != null) {
          final size = data.length;
          totalSize += size;

          stats[key] = {
            'size_bytes': size,
            'age_minutes': age?.inMinutes ?? 0,
            'cached_at': age != null
                ? DateTime.now().subtract(age).toIso8601String()
                : 'unknown',
          };
        }
      }

      return {
        'total_caches': cacheKeys.length,
        'total_size_bytes': totalSize,
        'total_size_kb': (totalSize / 1024).toStringAsFixed(2),
        'caches': stats,
      };
    } catch (e) {
      debugPrint('❌ [Offline Cache] Error getting stats: $e');
      return {};
    }
  }

  // Private helper methods

  String _getCacheKey(String key) => '$_keyPrefix$key';
  String _getTimestampKey(String key) => '$_keyPrefix$key$_timestampSuffix';
}

/// Network connectivity helper
///
/// Provides simple network status checking without adding dependencies.
class NetworkStatus {
  /// Check if device is online
  ///
  /// Note: This is a simple heuristic. For production apps, consider
  /// using connectivity_plus package for more accurate detection.
  static Future<bool> isOnline() async {
    // TODO: Implement proper connectivity check
    // For now, assume online (Supabase client will handle errors)
    return true;
  }

  /// Simulate offline mode (for testing)
  static bool _forceOffline = false;

  static void setForceOffline(bool offline) {
    _forceOffline = offline;
    debugPrint('🔌 [Network] Force offline mode: $offline');
  }

  static bool get isForceOffline => _forceOffline;
}

/// Offline cache keys (constants for type safety)
class OfflineCacheKeys {
  static const String announcements = 'announcements';
  static const String announcementsActive = 'announcements_active';
  static const String categoryBanners = 'category_banners';
  static const String categoryBannersActive = 'category_banners_active';
  static const String ageCategories = 'age_categories';

  /// Get banner cache key for specific category
  static String bannersByCategory(String categoryId) =>
      'banners_category_$categoryId';

  /// Get banner cache key for specific slug
  static String bannersBySlug(String slug) => 'banners_slug_$slug';

  /// Get announcement cache key by ID
  static String announcementById(String id) => 'announcement_$id';

  /// Get banner cache key by ID
  static String bannerById(String id) => 'banner_$id';
}

/// Helper functions for common offline cache patterns
class OfflineModeHelpers {
  /// Save a list of items to cache
  static Future<bool> saveList<E>(
    String key,
    List<E> list, {
    required Map<String, dynamic> Function(E) toJson,
  }) async {
    final offlineMode = OfflineMode<List<E>>();
    return offlineMode.save(
      key,
      list,
      serializer: (data) => data.map((item) => toJson(item)).toList(),
    );
  }

  /// Load a list of items from cache
  static Future<List<E>?> loadList<E>(
    String key, {
    required E Function(Map<String, dynamic>) fromJson,
  }) async {
    final offlineMode = OfflineMode<List<E>>();
    return offlineMode.load(
      key,
      deserializer: (json) {
        return (json as List)
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
