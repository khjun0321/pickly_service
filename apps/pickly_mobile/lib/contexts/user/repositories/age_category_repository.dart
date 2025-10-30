import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pickly_mobile/contexts/user/models/age_category.dart';

/// Repository for managing age category data from Supabase
///
/// Handles:
/// - Fetching active age categories
/// - Realtime subscriptions for category updates
/// - Error handling and data validation
class AgeCategoryRepository {
  final SupabaseClient _client;
  static const String _tableName = 'age_categories';

  AgeCategoryRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Fetches all active age categories ordered by sort_order
  ///
  /// Returns a list of [AgeCategory] objects
  /// Throws [AgeCategoryException] on error
  Future<List<AgeCategory>> fetchActiveCategories() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => AgeCategory.fromJson(json as Map<String, dynamic>))
          .toList();
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

  /// Subscribes to realtime changes in age categories
  ///
  /// Returns a [RealtimeChannel] for managing the subscription
  /// Call [RealtimeChannel.unsubscribe()] to stop listening
  ///
  /// Example:
  /// ```dart
  /// final channel = repository.subscribeToCategories(
  ///   onInsert: (category) => print('New: ${category.name}'),
  ///   onUpdate: (category) => print('Updated: ${category.name}'),
  ///   onDelete: (id) => print('Deleted: $id'),
  /// );
  ///
  /// // Later...
  /// await channel.unsubscribe();
  /// ```
  RealtimeChannel subscribeToCategories({
    void Function(AgeCategory category)? onInsert,
    void Function(AgeCategory category)? onUpdate,
    void Function(String id)? onDelete,
  }) {
    final channel = _client.channel('age_categories_changes');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: _tableName,
      callback: (payload) {
        if (onInsert != null) {
          try {
            final category = AgeCategory.fromJson(
              payload.newRecord as Map<String, dynamic>,
            );
            onInsert(category);
          } catch (e) {
            print('Error processing insert event: $e');
          }
        }
      },
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: _tableName,
      callback: (payload) {
        if (onUpdate != null) {
          try {
            final category = AgeCategory.fromJson(
              payload.newRecord as Map<String, dynamic>,
            );
            onUpdate(category);
          } catch (e) {
            print('Error processing update event: $e');
          }
        }
      },
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.delete,
      schema: 'public',
      table: _tableName,
      callback: (payload) {
        if (onDelete != null) {
          final id = payload.oldRecord['id'] as String?;
          if (id != null) {
            onDelete(id);
          }
        }
      },
    );

    channel.subscribe();
    return channel;
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

  // ==================== Realtime Streams (v8.6 Phase 4) ====================

  /// Watch all active age categories in realtime with Supabase Stream
  ///
  /// This method creates a realtime stream that automatically emits updates
  /// when the age_categories table changes in Supabase.
  ///
  /// Returns a Stream of [List<AgeCategory>] that emits:
  /// - Initial data immediately upon subscription
  /// - Updated data whenever categories are inserted/updated/deleted
  ///
  /// The stream:
  /// - Automatically reconnects on connection loss
  /// - Filters only active categories
  /// - Maintains proper ordering (sort_order ASC)
  ///
  /// Usage:
  /// ```dart
  /// final stream = repository.watchActiveCategories();
  /// stream.listen((categories) {
  ///   print('Got ${categories.length} categories');
  /// });
  /// ```
  ///
  /// This replaces the old `subscribeToCategories()` + `refresh()` pattern
  /// with a modern Stream-based approach that's more efficient and simpler.
  Stream<List<AgeCategory>> watchActiveCategories() {
    try {
      print('🌊 Starting realtime stream for age_categories');

      return _client
          .from(_tableName)
          .stream(primaryKey: ['id'])
          .map((records) {
            print('🔄 Received ${records.length} age categories from stream');

            // Filter only active categories and parse to models
            final categories = records
                .where((json) {
                  final isActive = json['is_active'] as bool? ?? true;
                  return isActive;
                })
                .map((json) => AgeCategory.fromJson(json as Map<String, dynamic>))
                .toList();

            // Sort by sort_order
            categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

            print('✅ Stream emitted ${categories.length} active age categories');
            return categories;
          });
    } on PostgrestException catch (e) {
      print('❌ Error creating age categories stream: ${e.message}');
      throw AgeCategoryException(
        'Failed to create stream: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      print('❌ Unexpected error creating age categories stream: $e');
      throw AgeCategoryException(
        'Failed to create stream: $e',
      );
    }
  }

  /// Watch a single age category by ID in realtime
  ///
  /// Parameters:
  /// - [id]: Category UUID
  ///
  /// Returns a Stream of [AgeCategory?] that emits:
  /// - The category if found and active
  /// - null if not found, deleted, or deactivated
  Stream<AgeCategory?> watchCategoryById(String id) {
    try {
      print('🌊 Starting realtime stream for age category ID: $id');

      return _client
          .from(_tableName)
          .stream(primaryKey: ['id'])
          .map((records) {
            try {
              final record = records.firstWhere(
                (r) => r['id'] == id,
              );

              // Return null if category is inactive
              final isActive = record['is_active'] as bool? ?? true;
              if (!isActive) {
                print('⚠️ Age category inactive: $id');
                return null;
              }

              print('✅ Stream emitted age category: $id');
              return AgeCategory.fromJson(record as Map<String, dynamic>);
            } catch (e) {
              print('⚠️ Age category not found in stream: $id');
              return null;
            }
          });
    } on PostgrestException catch (e) {
      print('❌ Error creating age category stream by ID: ${e.message}');
      throw AgeCategoryException(
        'Failed to create stream: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      print('❌ Unexpected error creating age category stream by ID: $e');
      throw AgeCategoryException(
        'Failed to create stream: $e',
      );
    }
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
