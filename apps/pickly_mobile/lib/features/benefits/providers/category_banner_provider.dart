/// Category Banner Provider
///
/// Manages category-specific banner data using Riverpod.
/// Handles fetching, caching, and state management for banners.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_mobile/features/benefits/models/category_banner.dart';
import 'package:pickly_mobile/features/benefits/providers/mock_banner_data.dart';
import 'package:pickly_mobile/features/benefits/repositories/category_banner_repository.dart';

/// Provider for CategoryBannerRepository instance
final categoryBannerRepositoryProvider = Provider<CategoryBannerRepository>((ref) {
  return CategoryBannerRepository();
});

/// AsyncNotifier for managing category banners
///
/// This provider:
/// - Loads all banners on initialization
/// - Caches banners in memory
/// - Falls back to mock data if Supabase fails
/// - Supports manual refresh
/// - Handles loading and error states
class CategoryBannerNotifier extends AsyncNotifier<List<CategoryBanner>> {
  @override
  Future<List<CategoryBanner>> build() async {
    return _fetchBanners();
  }

  /// Fetch banners from data source
  ///
  /// Strategy:
  /// 1. Fetch from Supabase database
  /// 2. Fallback to mock data if error occurs
  /// 3. Graceful error handling
  Future<List<CategoryBanner>> _fetchBanners() async {
    try {
      final repository = ref.read(categoryBannerRepositoryProvider);
      final banners = await repository.fetchActiveBanners();
      debugPrint('✅ Loaded ${banners.length} category banners from Supabase');
      return banners;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching banners from Supabase: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('⚠️ Falling back to mock data');
      // Fallback to mock data
      return MockBannerData.getAllBanners();
    }
  }

  /// Manually refresh banners from the data source
  ///
  /// This method:
  /// 1. Sets state to loading
  /// 2. Re-fetches banners
  /// 3. Updates state with new data or error
  ///
  /// Useful for:
  /// - Pull-to-refresh functionality
  /// - Retrying after an error
  /// - Manual data synchronization
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchBanners());
  }

  /// Retry fetching banners after an error
  ///
  /// Convenience method that calls [refresh].
  Future<void> retry() async {
    debugPrint('🔄 Retrying banner fetch...');
    await refresh();
  }
}

/// Main provider for category banners
///
/// Usage:
/// ```dart
/// // Watch all banners
/// final bannersAsync = ref.watch(categoryBannerProvider);
/// bannersAsync.when(
///   data: (banners) => BannerList(banners),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => ErrorWidget(error),
/// );
/// ```
final categoryBannerProvider = AsyncNotifierProvider<CategoryBannerNotifier, List<CategoryBanner>>(
  () => CategoryBannerNotifier(),
);

/// Provider to get banners for a specific category
///
/// Returns:
/// - Empty list `[]` if loading, error, or category has no banners
/// - List of [CategoryBanner] sorted by sortOrder
///
/// Example:
/// ```dart
/// final popularBanners = ref.watch(bannersByCategoryProvider('popular'));
/// if (popularBanners.isNotEmpty) {
///   BannerCarousel(banners: popularBanners);
/// }
/// ```
final bannersByCategoryProvider = Provider.family<List<CategoryBanner>, String>((ref, categoryId) {
  final asyncBanners = ref.watch(categoryBannerProvider);

  return asyncBanners.maybeWhen(
    data: (banners) {
      final filtered = banners
          .where((banner) => banner.benefitCategoryId == categoryId && banner.isActive)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      debugPrint('🎯 [Banner Filter] Category: $categoryId, Found: ${filtered.length} banners');
      if (filtered.isEmpty) {
        debugPrint('⚠️ [Banner Filter] No banners for category: $categoryId');
        debugPrint('   Available categories: ${banners.map((b) => b.benefitCategoryId).toSet().join(", ")}');
      }

      return filtered;
    },
    orElse: () {
      debugPrint('⚠️ [Banner Filter] No data available for category: $categoryId');
      return [];
    },
  );
});

/// Provider to get all banners as a simple list
///
/// Returns:
/// - Empty list `[]` if loading or error
/// - Full list of [CategoryBanner] when data is available
///
/// Use this when you need a non-nullable list and don't need to
/// differentiate between loading/error states.
final bannersListProvider = Provider<List<CategoryBanner>>((ref) {
  final asyncBanners = ref.watch(categoryBannerProvider);
  return asyncBanners.maybeWhen(
    data: (banners) => banners,
    orElse: () => [],
  );
});

/// Provider to check if banners are currently loading
///
/// Returns:
/// - `true` if data is being fetched
/// - `false` if data is loaded or in error state
final bannersLoadingProvider = Provider<bool>((ref) {
  final asyncBanners = ref.watch(categoryBannerProvider);
  return asyncBanners.isLoading;
});

/// Provider to get the current error state
///
/// Returns:
/// - `null` if no error occurred
/// - Error object if fetch failed
final bannersErrorProvider = Provider<Object?>((ref) {
  final asyncBanners = ref.watch(categoryBannerProvider);
  return asyncBanners.error;
});

/// Provider to get a specific banner by ID
///
/// Returns:
/// - [CategoryBanner] if found
/// - `null` if not found or data not yet loaded
///
/// Example:
/// ```dart
/// final banner = ref.watch(bannerByIdProvider('mock-popular-1'));
/// if (banner != null) {
///   BannerDetailPage(banner: banner);
/// }
/// ```
final bannerByIdProvider = Provider.family<CategoryBanner?, String>((ref, id) {
  final banners = ref.watch(bannersListProvider);
  try {
    return banners.firstWhere((banner) => banner.id == id);
  } catch (e) {
    return null;
  }
});

/// Provider to get the count of banners for a specific category
///
/// Returns the number of active banners in the category.
///
/// Example:
/// ```dart
/// final count = ref.watch(bannerCountProvider('popular'));
/// Text('$count banners available');
/// ```
final bannerCountProvider = Provider.family<int, String>((ref, categoryId) {
  return ref.watch(bannersByCategoryProvider(categoryId)).length;
});

/// Provider to check if a category has any banners
///
/// Returns:
/// - `true` if category has at least one active banner
/// - `false` if category has no banners or data not loaded
///
/// Example:
/// ```dart
/// final hasBanners = ref.watch(hasBannersProvider('popular'));
/// if (hasBanners) {
///   BannerSection();
/// } else {
///   EmptyBannerPlaceholder();
/// }
/// ```
final hasBannersProvider = Provider.family<bool, String>((ref, categoryId) {
  return ref.watch(bannersByCategoryProvider(categoryId)).isNotEmpty;
});

/// Provider to get all available category IDs that have banners
///
/// Returns list of category IDs that have at least one active banner.
///
/// Example:
/// ```dart
/// final categories = ref.watch(categoriesWithBannersProvider);
/// for (final categoryId in categories) {
///   CategorySection(categoryId);
/// }
/// ```
final categoriesWithBannersProvider = Provider<List<String>>((ref) {
  final banners = ref.watch(bannersListProvider);
  return banners
      .where((banner) => banner.isActive)
      .map((banner) => banner.benefitCategoryId)
      .toSet()
      .toList();
});

// ==================== Realtime Streams (v8.6 Phase 2) ====================

/// StreamProvider for watching category banners in realtime
///
/// This provider:
/// - Creates a realtime stream from Supabase category_banners table
/// - Automatically updates UI when Admin modifies banners
/// - Maintains loading and error states
/// - Filters only active banners
/// - Maintains sort order
///
/// Usage:
/// ```dart
/// // In your widget
/// final bannersAsync = ref.watch(categoryBannersStreamProvider);
///
/// bannersAsync.when(
///   data: (banners) => BannerCarousel(banners: banners),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
///
/// The stream will automatically emit updates when:
/// - Admin creates a new banner
/// - Admin updates banner title/image/order
/// - Admin deletes a banner
/// - Admin activates/deactivates a banner
final categoryBannersStreamProvider = StreamProvider<List<CategoryBanner>>((ref) {
  final repository = ref.watch(categoryBannerRepositoryProvider);
  debugPrint('🌊 [Stream Provider] Starting category banners stream');
  return repository.watchActiveBanners();
});

/// StreamProvider for watching banners for a specific category
///
/// Parameters:
/// - [categoryId]: UUID of the benefit category
///
/// Returns a stream of banners filtered by category
final bannersStreamByCategoryProvider = StreamProvider.family<List<CategoryBanner>, String>((ref, categoryId) {
  final repository = ref.watch(categoryBannerRepositoryProvider);
  debugPrint('🌊 [Stream Provider] Starting banners stream for category: $categoryId');
  return repository.watchBannersForCategory(categoryId);
});

/// StreamProvider for watching a single banner by ID
///
/// Parameters:
/// - [id]: Banner UUID
///
/// Returns a stream of the banner (or null if not found/deleted/inactive)
final bannerStreamByIdProvider = StreamProvider.family<CategoryBanner?, String>((ref, id) {
  final repository = ref.watch(categoryBannerRepositoryProvider);
  debugPrint('🌊 [Stream Provider] Starting banner stream for ID: $id');
  return repository.watchBannerById(id);
});

/// StreamProvider for watching banners by category slug
///
/// Parameters:
/// - [slug]: Category slug (e.g., 'popular', 'housing')
///
/// Returns a stream of banners for the category
final bannersStreamBySlugProvider = StreamProvider.family<List<CategoryBanner>, String>((ref, slug) {
  final repository = ref.watch(categoryBannerRepositoryProvider);
  debugPrint('🌊 [Stream Provider] Starting banners stream for slug: $slug');
  return repository.watchBannersBySlug(slug);
});

/// Provider to get banners list from stream
///
/// This is a convenience provider that extracts the data from AsyncValue
/// and returns an empty list if loading or error.
final bannersStreamListProvider = Provider<List<CategoryBanner>>((ref) {
  final asyncBanners = ref.watch(categoryBannersStreamProvider);
  return asyncBanners.maybeWhen(
    data: (banners) => banners,
    orElse: () => [],
  );
});

/// Provider to check if stream is currently loading
final bannersStreamLoadingProvider = Provider<bool>((ref) {
  final asyncBanners = ref.watch(categoryBannersStreamProvider);
  return asyncBanners.isLoading;
});

/// Provider to get stream error state
final bannersStreamErrorProvider = Provider<Object?>((ref) {
  final asyncBanners = ref.watch(categoryBannersStreamProvider);
  return asyncBanners.error;
});

/// Provider to get banners for a specific category from stream
///
/// This is a derived provider that filters banners from the main stream.
/// Use this if you already have the main stream active and want to filter
/// by category without creating a new database subscription.
final bannersStreamFilteredByCategoryProvider = Provider.family<List<CategoryBanner>, String>((ref, categoryId) {
  final banners = ref.watch(bannersStreamListProvider);
  final filtered = banners
      .where((banner) => banner.benefitCategoryId == categoryId && banner.isActive)
      .toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  debugPrint('🎯 [Banner Stream Filter] Category: $categoryId, Found: ${filtered.length} banners');
  return filtered;
});

/// Provider to get banner count from stream
final bannersStreamCountProvider = Provider<int>((ref) {
  final banners = ref.watch(bannersStreamListProvider);
  return banners.length;
});

/// Provider to check if any banners exist in stream
final hasBannersStreamProvider = Provider<bool>((ref) {
  final banners = ref.watch(bannersStreamListProvider);
  return banners.isNotEmpty;
});

/// Provider to get categories that have banners from stream
final categoriesWithBannersStreamProvider = Provider<List<String>>((ref) {
  final banners = ref.watch(bannersStreamListProvider);
  return banners
      .where((banner) => banner.isActive)
      .map((banner) => banner.benefitCategoryId)
      .toSet()
      .toList();
});
