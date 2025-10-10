import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_mobile/contexts/user/repositories/age_category_repository.dart';
import 'package:pickly_mobile/core/services/supabase_service.dart';

/// Provider for accessing Supabase service
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});

/// Provider for age category repository
final ageCategoryRepositoryProvider = Provider<AgeCategoryRepository?>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);

  // Only create repository if Supabase is properly initialized
  if (supabase.isInitialized && supabase.client != null) {
    return AgeCategoryRepository(client: supabase.client!);
  }

  // Return null if Supabase not available (will use mock data instead)
  return null;
});

/// AsyncNotifier for managing age categories with realtime updates
class AgeCategoryNotifier extends AsyncNotifier<List<AgeCategory>> {
  RealtimeChannel? _channel;

  @override
  Future<List<AgeCategory>> build() async {
    // Clean up channel when provider is disposed
    ref.onDispose(() {
      _channel?.unsubscribe();
    });

    // Setup realtime subscription
    _setupRealtimeSubscription();

    // Fetch initial data
    return _fetchCategories();
  }

  /// Fetch age categories from Supabase using repository
  /// Falls back to mock data if Supabase is not available
  ///
  /// Strategy:
  /// 1. If Supabase not initialized → Use mock data (offline mode)
  /// 2. If Supabase initialized → Try to fetch from DB
  /// 3. If network/DB error → Use mock data as fallback
  Future<List<AgeCategory>> _fetchCategories() async {
    final repository = ref.read(ageCategoryRepositoryProvider);

    // Case 1: Supabase not available (offline/development mode)
    if (repository == null) {
      debugPrint('ℹ️ Supabase not initialized, using mock age category data');
      return _getMockCategories();
    }

    // Case 2: Supabase available - try to fetch from database
    try {
      final categories = await repository.fetchActiveCategories();

      // Validate we have data
      if (categories.isEmpty) {
        debugPrint('⚠️ No age categories found in database, using mock data');
        return _getMockCategories();
      }

      debugPrint('✅ Successfully loaded ${categories.length} age categories from Supabase');
      return categories;
    } on AgeCategoryException catch (e, stackTrace) {
      // Case 3: Database/network error - fallback to mock data
      debugPrint('⚠️ AgeCategoryException: ${e.message}');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('→ Using mock data as fallback');
      return _getMockCategories();
    } catch (e, stackTrace) {
      // Case 4: Unexpected error - fallback to mock data
      debugPrint('❌ Unexpected error fetching age categories: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('→ Using mock data as fallback');
      return _getMockCategories();
    }
  }

  /// Get mock age categories for offline/development mode
  /// Icons are loaded from pickly_design_system package
  List<AgeCategory> _getMockCategories() {
    final now = DateTime.now();
    return [
      AgeCategory(
        id: 'mock-1',
        title: '청년',
        description: '만 19세-39세 대학생, 취업준비생, 직장인',
        iconComponent: 'youth',
        iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/young_man.svg',
        minAge: 19,
        maxAge: 39,
        sortOrder: 1,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      AgeCategory(
        id: 'mock-2',
        title: '신혼부부·예비부부',
        description: '결혼 예정 또는 결혼 7년이내',
        iconComponent: 'newlywed',
        iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/bride.svg',
        minAge: null,
        maxAge: null,
        sortOrder: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      AgeCategory(
        id: 'mock-3',
        title: '육아중인 부모',
        description: '영유아~초등 자녀 양육 중',
        iconComponent: 'parenting',
        iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/baby.svg',
        minAge: null,
        maxAge: null,
        sortOrder: 3,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      AgeCategory(
        id: 'mock-4',
        title: '다자녀 가구',
        description: '자녀 2명 이상 양육중',
        iconComponent: 'multi_child',
        iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/kinder.svg',
        minAge: null,
        maxAge: null,
        sortOrder: 4,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      AgeCategory(
        id: 'mock-5',
        title: '어르신',
        description: '만 65세 이상',
        iconComponent: 'elderly',
        iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/old_man.svg',
        minAge: 65,
        maxAge: null,
        sortOrder: 5,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      AgeCategory(
        id: 'mock-6',
        title: '장애인',
        description: '장애인 등록 대상',
        iconComponent: 'disability',
        iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/wheel_chair.svg',
        minAge: null,
        maxAge: null,
        sortOrder: 6,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Setup realtime subscription for age_categories table
  ///
  /// Subscribes to INSERT, UPDATE, and DELETE events and automatically
  /// refreshes the provider state when changes occur.
  ///
  /// Subscription is only active when Supabase is properly initialized.
  void _setupRealtimeSubscription() {
    final repository = ref.read(ageCategoryRepositoryProvider);

    // Only subscribe if repository is available (Supabase initialized)
    if (repository == null) {
      debugPrint('ℹ️ Skipping realtime subscription - Supabase not initialized');
      return;
    }

    try {
      _channel = repository.subscribeToCategories(
        onInsert: (category) {
          debugPrint('🔔 Realtime INSERT: ${category.title}');
          refresh();
        },
        onUpdate: (category) {
          debugPrint('🔔 Realtime UPDATE: ${category.title}');
          refresh();
        },
        onDelete: (id) {
          debugPrint('🔔 Realtime DELETE: $id');
          refresh();
        },
      );
      debugPrint('✅ Realtime subscription established for age_categories');
    } catch (e, stackTrace) {
      debugPrint('⚠️ Failed to setup realtime subscription: $e');
      debugPrint('Stack trace: $stackTrace');
      // Continue without realtime - provider will still work with manual refresh
    }
  }

  /// Manually refresh categories from the data source
  ///
  /// This method:
  /// 1. Sets state to loading
  /// 2. Re-fetches categories from Supabase (or mock data if offline)
  /// 3. Updates state with new data or error
  ///
  /// Useful for:
  /// - Pull-to-refresh functionality
  /// - Retrying after an error
  /// - Manual data synchronization
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchCategories());
  }

  /// Retry fetching categories after an error
  ///
  /// Convenience method that calls [refresh].
  /// Useful for error recovery UI (e.g., "Retry" button).
  Future<void> retry() async {
    debugPrint('🔄 Retrying age category fetch...');
    await refresh();
  }
}

/// Provider for age categories with AsyncNotifier
final ageCategoryProvider = AsyncNotifierProvider<AgeCategoryNotifier, List<AgeCategory>>(
  () => AgeCategoryNotifier(),
);

/// Convenience provider to get categories as a simple list
///
/// Returns:
/// - Empty list `[]` if data is loading or on error
/// - Full list of [AgeCategory] when data is available
///
/// Use this when you need a non-nullable list and don't need to
/// differentiate between loading/error states.
///
/// Example:
/// ```dart
/// final categories = ref.watch(ageCategoriesListProvider);
/// ListView.builder(
///   itemCount: categories.length,
///   itemBuilder: (context, index) => Text(categories[index].title),
/// )
/// ```
final ageCategoriesListProvider = Provider<List<AgeCategory>>((ref) {
  final asyncCategories = ref.watch(ageCategoryProvider);
  return asyncCategories.maybeWhen(
    data: (categories) => categories,
    orElse: () => [],
  );
});

/// Provider to check if categories are currently loading
///
/// Returns:
/// - `true` if data is being fetched (initial load or refresh)
/// - `false` if data is loaded or in error state
///
/// Example:
/// ```dart
/// final isLoading = ref.watch(ageCategoriesLoadingProvider);
/// if (isLoading) return CircularProgressIndicator();
/// ```
final ageCategoriesLoadingProvider = Provider<bool>((ref) {
  final asyncCategories = ref.watch(ageCategoryProvider);
  return asyncCategories.isLoading;
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
/// final error = ref.watch(ageCategoriesErrorProvider);
/// if (error != null) return ErrorWidget(error);
/// ```
final ageCategoriesErrorProvider = Provider<Object?>((ref) {
  final asyncCategories = ref.watch(ageCategoryProvider);
  return asyncCategories.error;
});

/// Provider to get a specific category by ID
///
/// Returns:
/// - [AgeCategory] if found
/// - `null` if not found or data not yet loaded
///
/// Example:
/// ```dart
/// final category = ref.watch(ageCategoryByIdProvider('youth-id'));
/// if (category != null) {
///   Text(category.title);
/// }
/// ```
final ageCategoryByIdProvider = Provider.family<AgeCategory?, String>((ref, id) {
  final categories = ref.watch(ageCategoriesListProvider);
  try {
    return categories.firstWhere((cat) => cat.id == id);
  } catch (e) {
    return null;
  }
});

/// Provider to validate that a list of category IDs are all valid
///
/// Checks against:
/// - Supabase database (if available)
/// - Currently loaded categories (offline mode)
///
/// Returns:
/// - `true` if all IDs are valid and active
/// - `false` if any ID is invalid or inactive
///
/// Example:
/// ```dart
/// final isValid = await ref.read(
///   validateCategoryIdsProvider(['youth-id', 'elderly-id']).future
/// );
/// if (!isValid) showError('Invalid category selection');
/// ```
final validateCategoryIdsProvider = FutureProvider.family<bool, List<String>>((ref, ids) async {
  // Empty list is considered valid
  if (ids.isEmpty) {
    return true;
  }

  final repository = ref.read(ageCategoryRepositoryProvider);

  // If repository not available, validate against current categories
  if (repository == null) {
    final categories = ref.read(ageCategoriesListProvider);
    final categoryIds = categories.map((c) => c.id).toSet();
    return ids.every((id) => categoryIds.contains(id));
  }

  // Use repository for validation (checks database)
  try {
    return await repository.validateCategoryIds(ids);
  } catch (e) {
    debugPrint('⚠️ Error validating category IDs: $e');
    // Fallback to local validation
    final categories = ref.read(ageCategoriesListProvider);
    final categoryIds = categories.map((c) => c.id).toSet();
    return ids.every((id) => categoryIds.contains(id));
  }
});
