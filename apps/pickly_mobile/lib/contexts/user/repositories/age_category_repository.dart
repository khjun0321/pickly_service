import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/age_category.dart';

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
