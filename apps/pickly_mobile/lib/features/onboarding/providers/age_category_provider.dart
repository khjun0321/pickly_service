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
final ageCategoryRepositoryProvider = Provider<AgeCategoryRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return AgeCategoryRepository(client: supabase.client);
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
  Future<List<AgeCategory>> _fetchCategories() async {
    try {
      final repository = ref.read(ageCategoryRepositoryProvider);
      return await repository.fetchActiveCategories();
    } on AgeCategoryException {
      rethrow;
    } catch (e, stackTrace) {
      // TODO: Replace with proper logging (e.g., logger package)
      debugPrint('Error fetching age categories: $e');
      debugPrint('Stack trace: $stackTrace');
      throw AgeCategoryException('Failed to load age categories');
    }
  }

  /// Setup realtime subscription for age_categories table
  void _setupRealtimeSubscription() {
    final repository = ref.read(ageCategoryRepositoryProvider);

    _channel = repository.subscribeToCategories(
      onInsert: (_) => refresh(),
      onUpdate: (_) => refresh(),
      onDelete: (_) => refresh(),
    );
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
  return await repository.validateCategoryIds(ids);
});
