import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pickly_mobile/contexts/user/models/region.dart';
import 'package:pickly_mobile/contexts/user/exceptions/region_exception.dart';

/// Repository for managing region data from Supabase
///
/// Handles:
/// - Fetching active regions
/// - Saving user's selected regions
/// - Fetching user's selected regions
/// - Realtime subscriptions for region updates
/// - Error handling and data validation
class RegionRepository {
  final SupabaseClient _client;
  static const String _tableName = 'regions';
  static const String _userRegionsTable = 'user_regions';

  RegionRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Fetches all active regions ordered by sort_order
  ///
  /// Returns a list of [Region] objects
  /// Throws [RegionException] on error
  Future<List<Region>> fetchActiveRegions() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => Region.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw RegionException(
        'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e, stackTrace) {
      throw RegionException(
        'Failed to fetch regions: $e',
        stackTrace: stackTrace,
      );
    }
  }

  /// Fetches a single region by ID
  ///
  /// Returns [Region] if found, null otherwise
  /// Throws [RegionException] on error
  Future<Region?> fetchRegionById(String id) async {
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

      return Region.fromJson(response);
    } on PostgrestException catch (e) {
      throw RegionException(
        'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e, stackTrace) {
      throw RegionException(
        'Failed to fetch region: $e',
        stackTrace: stackTrace,
      );
    }
  }

  /// Saves user's selected regions to the database
  ///
  /// Replaces any existing region selections for the user.
  /// Uses a transaction to ensure consistency.
  ///
  /// Parameters:
  /// - [userId]: The user's ID
  /// - [regionIds]: List of selected region IDs
  ///
  /// Throws [RegionException] on error
  Future<void> saveUserRegions(String userId, List<String> regionIds) async {
    try {
      // First, delete existing user regions
      await _client
          .from(_userRegionsTable)
          .delete()
          .eq('user_id', userId);

      // Then insert new selections
      if (regionIds.isNotEmpty) {
        final userRegions = regionIds.map((regionId) => {
          'user_id': userId,
          'region_id': regionId,
          'created_at': DateTime.now().toIso8601String(),
        }).toList();

        await _client
            .from(_userRegionsTable)
            .insert(userRegions);
      }
    } on PostgrestException catch (e) {
      throw RegionException(
        'Database error while saving user regions: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e, stackTrace) {
      throw RegionException(
        'Failed to save user regions: $e',
        stackTrace: stackTrace,
      );
    }
  }

  /// Fetches user's selected regions
  ///
  /// Returns a list of [Region] objects that the user has selected.
  /// Returns empty list if user has no selected regions.
  ///
  /// Throws [RegionException] on error
  Future<List<Region>> fetchUserRegions(String userId) async {
    try {
      final response = await _client
          .from(_userRegionsTable)
          .select('region_id, regions(*)')
          .eq('user_id', userId);

      return (response as List)
          .map((item) {
            final regionData = item['regions'] as Map<String, dynamic>;
            return Region.fromJson(regionData);
          })
          .toList();
    } on PostgrestException catch (e) {
      throw RegionException(
        'Database error while fetching user regions: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e, stackTrace) {
      throw RegionException(
        'Failed to fetch user regions: $e',
        stackTrace: stackTrace,
      );
    }
  }

  /// Subscribes to realtime changes in regions
  ///
  /// Returns a [RealtimeChannel] for managing the subscription
  /// Call [RealtimeChannel.unsubscribe()] to stop listening
  ///
  /// Example:
  /// ```dart
  /// final channel = repository.subscribeToRegions(
  ///   onInsert: (region) => print('New: ${region.name}'),
  ///   onUpdate: (region) => print('Updated: ${region.name}'),
  ///   onDelete: (id) => print('Deleted: $id'),
  /// );
  ///
  /// // Later...
  /// await channel.unsubscribe();
  /// ```
  RealtimeChannel subscribeToRegions({
    void Function(Region region)? onInsert,
    void Function(Region region)? onUpdate,
    void Function(String id)? onDelete,
  }) {
    final channel = _client.channel('regions_changes');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: _tableName,
      callback: (payload) {
        if (onInsert != null) {
          try {
            final region = Region.fromJson(
              payload.newRecord as Map<String, dynamic>,
            );
            onInsert(region);
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
            final region = Region.fromJson(
              payload.newRecord as Map<String, dynamic>,
            );
            onUpdate(region);
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

  /// Validates that a list of region IDs exist in the database
  ///
  /// Returns true if all IDs are valid and active
  /// Throws [RegionException] on error
  Future<bool> validateRegionIds(List<String> regionIds) async {
    if (regionIds.isEmpty) {
      return true;
    }

    try {
      final response = await _client
          .from(_tableName)
          .select('id')
          .inFilter('id', regionIds)
          .eq('is_active', true);

      final validIds = (response as List)
          .map((item) => item['id'] as String)
          .toSet();

      return validIds.length == regionIds.length;
    } on PostgrestException catch (e) {
      throw RegionException(
        'Database error while validating region IDs: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e, stackTrace) {
      throw RegionException(
        'Failed to validate region IDs: $e',
        stackTrace: stackTrace,
      );
    }
  }

  /// Returns mock data for testing when Supabase is not available
  ///
  /// This provides 17 Korean regions in display order.
  /// Used as fallback during development or when offline.
  List<Region> getMockRegions() {
    final now = DateTime.now();
    final mockData = [
      {'code': 'NATIONWIDE', 'name': '전국', 'sortOrder': 0},
      {'code': 'SEOUL', 'name': '서울', 'sortOrder': 1},
      {'code': 'GYEONGGI', 'name': '경기', 'sortOrder': 2},
      {'code': 'INCHEON', 'name': '인천', 'sortOrder': 3},
      {'code': 'GANGWON', 'name': '강원', 'sortOrder': 4},
      {'code': 'CHUNGNAM', 'name': '충남', 'sortOrder': 5},
      {'code': 'CHUNGBUK', 'name': '충북', 'sortOrder': 6},
      {'code': 'DAEJEON', 'name': '대전', 'sortOrder': 7},
      {'code': 'SEJONG', 'name': '세종', 'sortOrder': 8},
      {'code': 'GYEONGNAM', 'name': '경남', 'sortOrder': 9},
      {'code': 'GYEONGBUK', 'name': '경북', 'sortOrder': 10},
      {'code': 'DAEGU', 'name': '대구', 'sortOrder': 11},
      {'code': 'JEONNAM', 'name': '전남', 'sortOrder': 12},
      {'code': 'JEONBUK', 'name': '전북', 'sortOrder': 13},
      {'code': 'GWANGJU', 'name': '광주', 'sortOrder': 14},
      {'code': 'ULSAN', 'name': '울산', 'sortOrder': 15},
      {'code': 'BUSAN', 'name': '부산', 'sortOrder': 16},
      {'code': 'JEJU', 'name': '제주', 'sortOrder': 17},
    ];

    return mockData.map((data) {
      return Region(
        id: 'mock-${data['code']}',
        code: data['code'] as String,
        name: data['name'] as String,
        sortOrder: data['sortOrder'] as int,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );
    }).toList();
  }
}
