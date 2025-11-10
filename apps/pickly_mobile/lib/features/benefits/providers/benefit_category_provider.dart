/// Benefit Category Provider
///
/// Manages benefit category data using Riverpod with realtime streams.
/// PRD v9.6.1 Phase 3: Realtime Sync Implementation
/// PRD v9.10.0: Added subcategory providers for hierarchical filtering
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_mobile/contexts/benefit/models/benefit_category.dart';
import 'package:pickly_mobile/contexts/benefit/models/benefit_subcategory.dart';
import 'package:pickly_mobile/contexts/benefit/repositories/benefit_repository.dart';

// ==================== Realtime Streams (v9.6.1 Phase 3) ====================

/// StreamProvider for watching benefit categories in realtime
///
/// This provider:
/// - Creates a realtime stream from Supabase benefit_categories table
/// - Automatically updates UI when Admin modifies categories
/// - Maintains loading and error states
/// - Filters only active categories
/// - Maintains display_order sorting
///
/// Usage:
/// ```dart
/// // In your widget
/// final categoriesAsync = ref.watch(benefitCategoriesStreamProvider);
///
/// categoriesAsync.when(
///   data: (categories) => CircleTabBar(categories: categories),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
///
/// The stream will automatically emit updates when:
/// - Admin creates a new category
/// - Admin updates category name/icon/order
/// - Admin deletes a category
/// - Admin activates/deactivates a category
final benefitCategoriesStreamProvider = StreamProvider<List<BenefitCategory>>((ref) {
  final repository = ref.watch(benefitRepositoryProvider);
  debugPrint('🌊 [Stream Provider] Starting benefit categories stream');
  return repository.watchCategories();
});

/// Provider to get categories list from stream
///
/// This is a convenience provider that extracts the data from AsyncValue
/// and returns an empty list if loading or error.
///
/// Use this when you need a non-nullable list and don't need to
/// differentiate between loading/error states.
final categoriesStreamListProvider = Provider<List<BenefitCategory>>((ref) {
  final asyncCategories = ref.watch(benefitCategoriesStreamProvider);
  return asyncCategories.maybeWhen(
    data: (categories) {
      debugPrint('📋 [Categories Stream] Loaded ${categories.length} categories');
      return categories;
    },
    orElse: () {
      debugPrint('⚠️ [Categories Stream] No data available (loading or error)');
      return [];
    },
  );
});

/// Provider to check if stream is currently loading
///
/// Returns:
/// - `true` if data is being fetched
/// - `false` if data is loaded or in error state
final categoriesStreamLoadingProvider = Provider<bool>((ref) {
  final asyncCategories = ref.watch(benefitCategoriesStreamProvider);
  return asyncCategories.isLoading;
});

/// Provider to get stream error state
///
/// Returns:
/// - `null` if no error occurred
/// - Error object if fetch failed
final categoriesStreamErrorProvider = Provider<Object?>((ref) {
  final asyncCategories = ref.watch(benefitCategoriesStreamProvider);
  return asyncCategories.error;
});

/// Provider to get a specific category by ID from stream
///
/// Parameters:
/// - [id]: Category UUID
///
/// Returns:
/// - [BenefitCategory] if found
/// - `null` if not found or data not yet loaded
///
/// Example:
/// ```dart
/// final category = ref.watch(categoryStreamByIdProvider('category-id'));
/// if (category != null) {
///   CategoryDetailPage(category: category);
/// }
/// ```
final categoryStreamByIdProvider = Provider.family<BenefitCategory?, String>((ref, id) {
  final categories = ref.watch(categoriesStreamListProvider);
  try {
    return categories.firstWhere((category) => category.id == id);
  } catch (e) {
    debugPrint('⚠️ [Category Stream] Category not found: $id');
    return null;
  }
});

/// Provider to get a specific category by slug from stream
///
/// Parameters:
/// - [slug]: Category slug (e.g., 'housing', 'education')
///
/// Returns:
/// - [BenefitCategory] if found
/// - `null` if not found or data not yet loaded
///
/// Example:
/// ```dart
/// final category = ref.watch(categoryStreamBySlugProvider('housing'));
/// if (category != null) {
///   CategoryPage(category: category);
/// }
/// ```
final categoryStreamBySlugProvider = Provider.family<BenefitCategory?, String>((ref, slug) {
  final categories = ref.watch(categoriesStreamListProvider);
  try {
    return categories.firstWhere((category) => category.slug == slug);
  } catch (e) {
    debugPrint('⚠️ [Category Stream] Category not found for slug: $slug');
    return null;
  }
});

/// Provider to get the count of active categories
///
/// Returns the number of active categories available.
///
/// Example:
/// ```dart
/// final count = ref.watch(categoriesStreamCountProvider);
/// Text('$count categories available');
/// ```
final categoriesStreamCountProvider = Provider<int>((ref) {
  final categories = ref.watch(categoriesStreamListProvider);
  return categories.length;
});

/// Provider to check if any categories exist in stream
///
/// Returns:
/// - `true` if at least one category exists
/// - `false` if no categories or data not loaded
///
/// Example:
/// ```dart
/// final hasCategories = ref.watch(hasCategoriesStreamProvider);
/// if (hasCategories) {
///   CategoriesSection();
/// } else {
///   EmptyCategoriesPlaceholder();
/// }
/// ```
final hasCategoriesStreamProvider = Provider<bool>((ref) {
  final categories = ref.watch(categoriesStreamListProvider);
  return categories.isNotEmpty;
});

/// Provider to get category slugs as a list
///
/// Returns list of all active category slugs.
/// Useful for navigation or filtering.
///
/// Example:
/// ```dart
/// final slugs = ref.watch(categoryStreamSlugsProvider);
/// for (final slug in slugs) {
///   CategoryTab(slug: slug);
/// }
/// ```
final categoryStreamSlugsProvider = Provider<List<String>>((ref) {
  final categories = ref.watch(categoriesStreamListProvider);
  return categories.map((category) => category.slug).toList();
});

/// Provider to get category IDs as a list
///
/// Returns list of all active category IDs.
/// Useful for filtering announcements or banners.
///
/// Example:
/// ```dart
/// final ids = ref.watch(categoryStreamIdsProvider);
/// for (final id in ids) {
///   AnnouncementsForCategory(categoryId: id);
/// }
/// ```
final categoryStreamIdsProvider = Provider<List<String>>((ref) {
  final categories = ref.watch(categoriesStreamListProvider);
  return categories.map((category) => category.id).toList();
});

// ==================== Subcategory Providers (PRD v9.10.0) ====================

/// Provider for fetching subcategories by parent category
/// Returns Future<List<BenefitSubcategory>>
///
/// Usage:
/// ```dart
/// final subcategoriesAsync = ref.watch(subcategoriesByCategoryProvider(categoryId));
/// subcategoriesAsync.when(
///   data: (subs) => SubcategoryChips(subcategories: subs),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final subcategoriesByCategoryProvider =
    FutureProvider.family<List<BenefitSubcategory>, String>((ref, categoryId) async {
  final repository = ref.watch(benefitRepositoryProvider);
  return repository.fetchSubcategoriesByCategory(categoryId, onlyActive: true);
});

/// Provider for streaming subcategories with Realtime updates
/// Returns Stream<List<BenefitSubcategory>>
///
/// Usage:
/// ```dart
/// final subcategoriesStream = ref.watch(subcategoriesStreamProvider(categoryId));
/// subcategoriesStream.when(
///   data: (subs) => SubcategoryList(subcategories: subs),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final subcategoriesStreamProvider =
    StreamProvider.family<List<BenefitSubcategory>, String>((ref, categoryId) {
  final repository = ref.watch(benefitRepositoryProvider);
  debugPrint('🌊 [Subcategory Stream] Starting stream for category: $categoryId');
  return repository.streamSubcategoriesByCategory(categoryId, onlyActive: true);
});

/// Provider for all subcategories grouped by category
/// Returns Future<Map<String, List<BenefitSubcategory>>>
///
/// Usage:
/// ```dart
/// final allSubcategoriesAsync = ref.watch(allSubcategoriesGroupedProvider);
/// allSubcategoriesAsync.when(
///   data: (grouped) {
///     for (final categoryId in grouped.keys) {
///       final subs = grouped[categoryId]!;
///       // Build UI for each category's subcategories
///     }
///   },
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final allSubcategoriesGroupedProvider =
    FutureProvider<Map<String, List<BenefitSubcategory>>>((ref) async {
  final repository = ref.watch(benefitRepositoryProvider);
  debugPrint('📦 [Subcategories Grouped] Fetching all subcategories grouped by category');
  return repository.fetchAllSubcategoriesGrouped(onlyActive: true);
});

/// State provider for selected subcategory IDs (multi-select) - DEPRECATED
/// This was the old global provider. Use selectedSubcategoryIdsForCategoryProvider instead.
@Deprecated('Use selectedSubcategoryIdsForCategoryProvider instead')
class SelectedSubcategoryIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  void clear() {
    state = {};
  }
}

@Deprecated('Use selectedSubcategoryIdsForCategoryProvider instead')
final selectedSubcategoryIdsProvider = NotifierProvider<SelectedSubcategoryIdsNotifier, Set<String>>(
  SelectedSubcategoryIdsNotifier.new,
);

// ==================== Category-Specific Selection State (PRD v9.10.1) ====================

/// Provider for category-specific subcategory selection state
///
/// Implementation: Uses Map<categoryId, Set<subcategoryId>> to track selections per category
/// This ensures that selecting filters in "주거" category doesn't affect "교육" category, etc.
final selectedSubcategoryIdsForCategoryProvider =
    Provider.family<Set<String>, String>((ref, categoryId) {
  // Watch the global selection map and return this category's selections
  final allSelections = ref.watch(subcategorySelectionsMapProvider);
  return allSelections[categoryId] ?? <String>{};
});

/// Global map of selections by category ID
/// Format: Map<categoryId, Set<subcategoryId>>
class SubcategorySelectionsNotifier extends Notifier<Map<String, Set<String>>> {
  @override
  Map<String, Set<String>> build() => {};

  /// Toggle selection for a subcategory within a specific category
  void toggle(String categoryId, String subcategoryId) {
    final categorySelections = state[categoryId] ?? <String>{};
    final newSelections = Set<String>.from(categorySelections);

    if (newSelections.contains(subcategoryId)) {
      newSelections.remove(subcategoryId);
      debugPrint('➖ [Selection] Category: $categoryId, Removed: $subcategoryId');
    } else {
      newSelections.add(subcategoryId);
      debugPrint('➕ [Selection] Category: $categoryId, Added: $subcategoryId');
    }

    state = {...state, categoryId: newSelections};
  }

  /// Clear all selections for a specific category
  void clear(String categoryId) {
    state = {...state, categoryId: <String>{}};
    debugPrint('🧹 [Selection] Cleared category: $categoryId');
  }

  /// Clear all selections for all categories
  void clearAll() {
    state = {};
    debugPrint('🧹 [Selection] Cleared all categories');
  }
}

final subcategorySelectionsMapProvider =
    NotifierProvider<SubcategorySelectionsNotifier, Map<String, Set<String>>>(
  SubcategorySelectionsNotifier.new,
);
