import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pickly_mobile/contexts/user/models/region.dart';
import 'package:pickly_mobile/contexts/user/repositories/region_repository.dart';
import 'package:pickly_mobile/contexts/user/exceptions/region_exception.dart';
import 'package:pickly_mobile/core/services/supabase_service.dart';

/// Provider for accessing Supabase service
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});

/// Provider for region repository
final regionRepositoryProvider = Provider<RegionRepository?>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);

  // Only create repository if Supabase is properly initialized
  if (supabase.isInitialized && supabase.client != null) {
    return RegionRepository(client: supabase.client!);
  }

  // Return null if Supabase not available (will use mock data instead)
  return null;
});

/// AsyncNotifier for managing regions with realtime updates
class RegionNotifier extends AsyncNotifier<List<Region>> {
  RealtimeChannel? _channel;

  @override
  Future<List<Region>> build() async {
    // Clean up channel when provider is disposed
    ref.onDispose(() {
      _channel?.unsubscribe();
    });

    // Setup realtime subscription
    _setupRealtimeSubscription();

    // Fetch initial data
    return _fetchRegions();
  }

  /// Fetch regions from Supabase using repository
  /// Falls back to mock data if Supabase is not available
  ///
  /// Strategy:
  /// 1. If Supabase not initialized → Use mock data (offline mode)
  /// 2. If Supabase initialized → Try to fetch from DB
  /// 3. If network/DB error → Use mock data as fallback
  Future<List<Region>> _fetchRegions() async {
    final repository = ref.read(regionRepositoryProvider);

    // Case 1: Supabase not available (offline/development mode)
    if (repository == null) {
      debugPrint('ℹ️ Supabase not initialized, using mock region data');
      return _getMockRegions();
    }

    // Case 2: Supabase available - try to fetch from database
    try {
      final regions = await repository.fetchActiveRegions();

      // Validate we have data
      if (regions.isEmpty) {
        debugPrint('⚠️ No regions found in database, using mock data');
        return _getMockRegions();
      }

      debugPrint('✅ Successfully loaded ${regions.length} regions from Supabase');
      return regions;
    } on RegionException catch (e, stackTrace) {
      // Case 3: Database/network error - fallback to mock data
      debugPrint('⚠️ RegionException: ${e.message}');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('→ Using mock data as fallback');
      return _getMockRegions();
    } catch (e, stackTrace) {
      // Case 4: Unexpected error - fallback to mock data
      debugPrint('❌ Unexpected error fetching regions: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('→ Using mock data as fallback');
      return _getMockRegions();
    }
  }

  /// Get mock regions for offline/development mode
  /// Contains all 18 Korean regions (including nationwide)
  List<Region> _getMockRegions() {
    final now = DateTime.now();
    return [
      Region(
        id: 'mock-nationwide',
        code: 'nationwide',
        name: '전국',
        sortOrder: 1,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Region(
        id: 'mock-seoul',
        code: 'seoul',
        name: '서울',
        sortOrder: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Region(
        id: 'mock-gyeonggi',
        code: 'gyeonggi',
        name: '경기',
        sortOrder: 3,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Region(
        id: 'mock-incheon',
        code: 'incheon',
        name: '인천',
        sortOrder: 4,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Region(
        id: 'mock-busan',
        code: 'busan',
        name: '부산',
        sortOrder: 5,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Region(
        id: 'mock-daegu',
        code: 'daegu',
        name: '대구',
        sortOrder: 6,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Region(
        id: 'mock-gwangju',
        code: 'gwangju',
        name: '광주',
        sortOrder: 7,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Region(
        id: 'mock-daejeon',
        code: 'daejeon',
        name: '대전',
        sortOrder: 8,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Region(
        id: 'mock-ulsan',
        code: 'ulsan',
        name: '울산',
        sortOrder: 9,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Region(
        id: 'mock-sejong',
        code: 'sejong',
        name: '세종',
        sortOrder: 10,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Region(
        id: 'mock-gangwon',
        code: 'gangwon',
        name: '강원',
        sortOrder: 11,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Region(
        id: 'mock-chungbuk',
        code: 'chungbuk',
        name: '충북',
        sortOrder: 12,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Region(
        id: 'mock-chungnam',
        code: 'chungnam',
        name: '충남',
        sortOrder: 13,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Region(
        id: 'mock-jeonbuk',
        code: 'jeonbuk',
        name: '전북',
        sortOrder: 14,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Region(
        id: 'mock-jeonnam',
        code: 'jeonnam',
        name: '전남',
        sortOrder: 15,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Region(
        id: 'mock-gyeongbuk',
        code: 'gyeongbuk',
        name: '경북',
        sortOrder: 16,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Region(
        id: 'mock-gyeongnam',
        code: 'gyeongnam',
        name: '경남',
        sortOrder: 17,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Region(
        id: 'mock-jeju',
        code: 'jeju',
        name: '제주',
        sortOrder: 18,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Setup realtime subscription for regions table
  ///
  /// Subscribes to INSERT, UPDATE, and DELETE events and automatically
  /// refreshes the provider state when changes occur.
  ///
  /// Subscription is only active when Supabase is properly initialized.
  void _setupRealtimeSubscription() {
    final repository = ref.read(regionRepositoryProvider);

    // Only subscribe if repository is available (Supabase initialized)
    if (repository == null) {
      debugPrint('ℹ️ Skipping realtime subscription - Supabase not initialized');
      return;
    }

    try {
      _channel = repository.subscribeToRegions(
        onInsert: (region) {
          debugPrint('🔔 Realtime INSERT: ${region.name}');
          refresh();
        },
        onUpdate: (region) {
          debugPrint('🔔 Realtime UPDATE: ${region.name}');
          refresh();
        },
        onDelete: (id) {
          debugPrint('🔔 Realtime DELETE: $id');
          refresh();
        },
      );
      debugPrint('✅ Realtime subscription established for regions');
    } catch (e, stackTrace) {
      debugPrint('⚠️ Failed to setup realtime subscription: $e');
      debugPrint('Stack trace: $stackTrace');
      // Continue without realtime - provider will still work with manual refresh
    }
  }

  /// Manually refresh regions from the data source
  ///
  /// This method:
  /// 1. Sets state to loading
  /// 2. Re-fetches regions from Supabase (or mock data if offline)
  /// 3. Updates state with new data or error
  ///
  /// Useful for:
  /// - Pull-to-refresh functionality
  /// - Retrying after an error
  /// - Manual data synchronization
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchRegions());
  }

  /// Retry fetching regions after an error
  ///
  /// Convenience method that calls [refresh].
  /// Useful for error recovery UI (e.g., "Retry" button).
  Future<void> retry() async {
    debugPrint('🔄 Retrying region fetch...');
    await refresh();
  }
}

/// Provider for regions with AsyncNotifier
final regionProvider = AsyncNotifierProvider<RegionNotifier, List<Region>>(
  () => RegionNotifier(),
);

/// Convenience provider to get regions as a simple list
///
/// Returns:
/// - Empty list `[]` if data is loading or on error
/// - Full list of [Region] when data is available
///
/// Use this when you need a non-nullable list and don't need to
/// differentiate between loading/error states.
///
/// Example:
/// ```dart
/// final regions = ref.watch(regionsListProvider);
/// ListView.builder(
///   itemCount: regions.length,
///   itemBuilder: (context, index) => Text(regions[index].name),
/// )
/// ```
final regionsListProvider = Provider<List<Region>>((ref) {
  final asyncRegions = ref.watch(regionProvider);
  return asyncRegions.maybeWhen(
    data: (regions) => regions,
    orElse: () => [],
  );
});

/// Provider to check if regions are currently loading
///
/// Returns:
/// - `true` if data is being fetched (initial load or refresh)
/// - `false` if data is loaded or in error state
///
/// Example:
/// ```dart
/// final isLoading = ref.watch(regionsLoadingProvider);
/// if (isLoading) return CircularProgressIndicator();
/// ```
final regionsLoadingProvider = Provider<bool>((ref) {
  final asyncRegions = ref.watch(regionProvider);
  return asyncRegions.isLoading;
});

/// Provider to get the current error state
///
/// Returns:
/// - `null` if no error occurred
/// - Error object if fetch failed
///
/// Note: With current implementation, errors are gracefully handled
/// by falling back to mock data, so this will rarely be non-null.
///
/// Example:
/// ```dart
/// final error = ref.watch(regionsErrorProvider);
/// if (error != null) return ErrorWidget(error);
/// ```
final regionsErrorProvider = Provider<Object?>((ref) {
  final asyncRegions = ref.watch(regionProvider);
  return asyncRegions.error;
});

/// Provider to get a specific region by ID
///
/// Returns:
/// - [Region] if found
/// - `null` if not found or data not yet loaded
///
/// Example:
/// ```dart
/// final region = ref.watch(regionByIdProvider('seoul-id'));
/// if (region != null) {
///   Text(region.name);
/// }
/// ```
final regionByIdProvider = Provider.family<Region?, String>((ref, id) {
  final regions = ref.watch(regionsListProvider);
  try {
    return regions.firstWhere((region) => region.id == id);
  } catch (e) {
    return null;
  }
});

/// Provider to validate that a list of region IDs are all valid
///
/// Checks against:
/// - Supabase database (if available)
/// - Currently loaded regions (offline mode)
///
/// Returns:
/// - `true` if all IDs are valid and active
/// - `false` if any ID is invalid or inactive
///
/// Example:
/// ```dart
/// final isValid = await ref.read(
///   validateRegionIdsProvider(['seoul-id', 'busan-id']).future
/// );
/// if (!isValid) showError('Invalid region selection');
/// ```
final validateRegionIdsProvider = FutureProvider.family<bool, List<String>>((ref, ids) async {
  // Empty list is considered valid
  if (ids.isEmpty) {
    return true;
  }

  final repository = ref.read(regionRepositoryProvider);

  // If repository not available, validate against current regions
  if (repository == null) {
    final regions = ref.read(regionsListProvider);
    final regionIds = regions.map((r) => r.id).toSet();
    return ids.every((id) => regionIds.contains(id));
  }

  // Use repository for validation (checks database)
  try {
    return await repository.validateRegionIds(ids);
  } catch (e) {
    debugPrint('⚠️ Error validating region IDs: $e');
    // Fallback to local validation
    final regions = ref.read(regionsListProvider);
    final regionIds = regions.map((r) => r.id).toSet();
    return ids.every((id) => regionIds.contains(id));
  }
});

/// Notifier for managing selected region IDs
///
/// Multi-selection support using Set of String.
class RegionSelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  /// Toggle a region selection
  void toggleRegion(String regionId) {
    if (state.contains(regionId)) {
      state = {...state}..remove(regionId);
      debugPrint('🔄 Region deselected: $regionId (Total: ${state.length})');
    } else {
      state = {...state, regionId};
      debugPrint('✅ Region selected: $regionId (Total: ${state.length})');
    }
  }

  /// Clear all selections
  void clearSelections() {
    state = {};
    debugPrint('🗑️ All region selections cleared');
  }

  /// Set specific selections (useful for loading saved state)
  void setSelections(Set<String> regionIds) {
    state = regionIds;
    debugPrint('📥 Loaded ${regionIds.length} region selections');
  }
}

/// Provider for selected region IDs with multi-selection support
///
/// Example usage:
/// ```dart
/// // Toggle selection
/// ref.read(selectedRegionsStateProvider.notifier).toggleRegion(regionId);
///
/// // Get selected region IDs
/// final selectedIds = ref.watch(selectedRegionsStateProvider);
///
/// // Save selections
/// await saveRegionSelections(ref, userId);
/// ```
final selectedRegionsStateProvider = NotifierProvider<RegionSelectionNotifier, Set<String>>(
  () => RegionSelectionNotifier(),
);

/// Provider to get the count of selected regions
///
/// Returns the number of regions currently selected.
///
/// Example:
/// ```dart
/// final count = ref.watch(selectedRegionCountProvider);
/// Text('Selected: $count regions');
/// ```
final selectedRegionCountProvider = Provider<int>((ref) {
  return ref.watch(selectedRegionsStateProvider).length;
});

/// Provider to check if any regions are selected
///
/// Returns `true` if at least one region is selected, `false` otherwise.
///
/// Example:
/// ```dart
/// final hasSelections = ref.watch(hasRegionSelectionsProvider);
/// ElevatedButton(
///   onPressed: hasSelections ? () => submit() : null,
///   child: Text('Continue'),
/// );
/// ```
final hasRegionSelectionsProvider = Provider<bool>((ref) {
  return ref.watch(selectedRegionsStateProvider).isNotEmpty;
});

/// Provider to get full Region objects for selected IDs
///
/// Maps selected region IDs to full Region objects.
///
/// Returns:
/// - Empty list if no selections
/// - List of [Region] objects for selected IDs
///
/// Example:
/// ```dart
/// final selectedRegions = ref.watch(selectedRegionsProvider);
/// for (final region in selectedRegions) {
///   print(region.name);
/// }
/// ```
final selectedRegionsProvider = Provider<List<Region>>((ref) {
  final selectedIds = ref.watch(selectedRegionsStateProvider);
  final allRegions = ref.watch(regionsListProvider);

  return allRegions.where((region) => selectedIds.contains(region.id)).toList();
});

/// Helper function to save region selections to Supabase
///
/// This will:
/// 1. Delete any existing region selections for the user
/// 2. Insert new selections based on current state
///
/// Throws exception if repository is not available or save fails
Future<void> saveRegionSelections(WidgetRef ref, String userId) async {
  final selectedIds = ref.read(selectedRegionsStateProvider);

  if (selectedIds.isEmpty) {
    debugPrint('⚠️ No regions selected, skipping save');
    return;
  }

  final repository = ref.read(regionRepositoryProvider);

  if (repository == null) {
    debugPrint('⚠️ Repository not available, cannot save selections');
    throw Exception('RegionRepository not available');
  }

  try {
    debugPrint('💾 Saving ${selectedIds.length} region selections for user: $userId');
    await repository.saveUserRegions(userId, selectedIds.toList());
    debugPrint('✅ Successfully saved region selections');
  } catch (e, stackTrace) {
    debugPrint('❌ Failed to save region selections: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}
