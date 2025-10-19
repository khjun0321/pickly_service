/// Category Banner Provider
///
/// Manages category-specific banner data using Riverpod.
/// Handles fetching, caching, and state management for banners.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_mobile/features/benefits/models/category_banner.dart';
import 'package:pickly_mobile/features/benefits/providers/mock_banner_data.dart';

/// AsyncNotifier for managing category banners
///
/// This provider:
/// - Loads all banners on initialization
/// - Caches banners in memory
/// - Falls back to mock data (currently no Supabase integration)
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
  /// 1. Currently uses mock data for development
  /// 2. Future: Will integrate with Supabase when backend is ready
  /// 3. Graceful error handling with fallback to mock data
  Future<List<CategoryBanner>> _fetchBanners() async {
    try {
      // Simulate network delay for realistic testing
      await Future.delayed(const Duration(milliseconds: 300));

      // TODO: Replace with Supabase fetch when backend is ready
      // final repository = ref.read(categoryBannerRepositoryProvider);
      // final banners = await repository.fetchActiveBanners();

      final banners = MockBannerData.getAllBanners();
      debugPrint('✅ Loaded ${banners.length} category banners (mock data)');
      return banners;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching banners: $e');
      debugPrint('Stack trace: $stackTrace');
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
/// - List of [CategoryBanner] sorted by displayOrder
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
      return banners
          .where((banner) => banner.categoryId == categoryId && banner.isActive)
          .toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    },
    orElse: () => [],
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
      .map((banner) => banner.categoryId)
      .toSet()
      .toList();
});
