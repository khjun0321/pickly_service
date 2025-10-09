import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/age_category.dart';
import '../../../repositories/age_category_repository.dart';
import '../../../core/services/supabase_service.dart';

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
  Future<List<AgeCategory>> _fetchCategories() async {
    try {
      final repository = ref.read(ageCategoryRepositoryProvider);

      // If repository is available (Supabase initialized), use it
      if (repository != null) {
        return await repository.fetchActiveCategories();
      }

      // Otherwise, return mock data for offline/development mode
      debugPrint('⚠️ Supabase not available, using mock age category data');
      return _getMockCategories();
    } on AgeCategoryException {
      // If Supabase fails, fallback to mock data
      debugPrint('⚠️ Supabase error, falling back to mock data');
      return _getMockCategories();
    } catch (e, stackTrace) {
      debugPrint('Error fetching age categories: $e');
      debugPrint('Stack trace: $stackTrace');
      // Fallback to mock data instead of throwing
      return _getMockCategories();
    }
  }

  /// Get mock age categories for offline/development mode
  List<AgeCategory> _getMockCategories() {
    final now = DateTime.now();
    return [
      AgeCategory(
        id: 'mock-1',
        title: '청년',
        description: '(만 19-34세) 대학생, 취업준비생, 직장인',
        iconComponent: 'youth',
        iconUrl: 'https://placeholder.com/icon1.png',
        minAge: 19,
        maxAge: 34,
        sortOrder: 1,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      AgeCategory(
        id: 'mock-2',
        title: '중장년',
        description: '(만 35-49세) 경력직, 중견 직장인',
        iconComponent: 'middle_age',
        iconUrl: 'https://placeholder.com/icon2.png',
        minAge: 35,
        maxAge: 49,
        sortOrder: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      AgeCategory(
        id: 'mock-3',
        title: '장년',
        description: '(만 50-64세) 은퇴 준비 세대',
        iconComponent: 'senior',
        iconUrl: 'https://placeholder.com/icon3.png',
        minAge: 50,
        maxAge: 64,
        sortOrder: 3,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      AgeCategory(
        id: 'mock-4',
        title: '노년',
        description: '(만 65세 이상) 노후 생활',
        iconComponent: 'elderly',
        iconUrl: 'https://placeholder.com/icon4.png',
        minAge: 65,
        maxAge: null,
        sortOrder: 4,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Setup realtime subscription for age_categories table
  void _setupRealtimeSubscription() {
    final repository = ref.read(ageCategoryRepositoryProvider);

    // Only subscribe if repository is available
    if (repository != null) {
      _channel = repository.subscribeToCategories(
        onInsert: (_) => refresh(),
        onUpdate: (_) => refresh(),
        onDelete: (_) => refresh(),
      );
    }
  }

  /// Manually refresh categories
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchCategories());
  }

  /// Retry after error
  Future<void> retry() async {
    await refresh();
  }
}

/// Provider for age categories with AsyncNotifier
final ageCategoryProvider = AsyncNotifierProvider<AgeCategoryNotifier, List<AgeCategory>>(
  () => AgeCategoryNotifier(),
);

/// Convenience provider to get categories as a simple list (loading state handled)
final ageCategoriesListProvider = Provider<List<AgeCategory>>((ref) {
  final asyncCategories = ref.watch(ageCategoryProvider);
  return asyncCategories.maybeWhen(
    data: (categories) => categories,
    orElse: () => [],
  );
});

/// Provider to check if categories are loading
final ageCategoriesLoadingProvider = Provider<bool>((ref) {
  final asyncCategories = ref.watch(ageCategoryProvider);
  return asyncCategories.isLoading;
});

/// Provider to get error state
final ageCategoriesErrorProvider = Provider<Object?>((ref) {
  final asyncCategories = ref.watch(ageCategoryProvider);
  return asyncCategories.error;
});

/// Provider to get a specific category by ID
final ageCategoryByIdProvider = Provider.family<AgeCategory?, String>((ref, id) {
  final categories = ref.watch(ageCategoriesListProvider);
  try {
    return categories.firstWhere((cat) => cat.id == id);
  } catch (e) {
    return null;
  }
});

/// Provider to validate a list of category IDs
final validateCategoryIdsProvider = FutureProvider.family<bool, List<String>>((ref, ids) async {
  final repository = ref.read(ageCategoryRepositoryProvider);

  // If repository not available, just check if IDs exist in current categories
  if (repository == null) {
    final categories = ref.read(ageCategoriesListProvider);
    final categoryIds = categories.map((c) => c.id).toSet();
    return ids.every((id) => categoryIds.contains(id));
  }

  return await repository.validateCategoryIds(ids);
});
