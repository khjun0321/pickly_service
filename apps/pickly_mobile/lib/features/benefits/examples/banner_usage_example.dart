/// Example Usage of Category Banner System
///
/// This file demonstrates how to use the CategoryBanner model and providers
/// in your Flutter widgets.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_mobile/features/benefits/models/category_banner.dart';
import 'package:pickly_mobile/features/benefits/providers/category_banner_provider.dart';

/// Example 1: Basic banner display with loading states
class BannerListExample extends ConsumerWidget {
  const BannerListExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(categoryBannerProvider);

    return bannersAsync.when(
      data: (banners) => ListView.builder(
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return BannerCard(banner: banner);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            ElevatedButton(
              onPressed: () {
                ref.read(categoryBannerProvider.notifier).retry();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 2: Category-specific banners
class CategoryBannersExample extends ConsumerWidget {
  final String categoryId;

  const CategoryBannersExample({
    required this.categoryId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get banners for specific category
    final banners = ref.watch(bannersByCategoryProvider(categoryId));

    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: BannerCard(banner: banner),
          );
        },
      ),
    );
  }
}

/// Example 3: Conditional banner display
class ConditionalBannerExample extends ConsumerWidget {
  final String categoryId;

  const ConditionalBannerExample({
    required this.categoryId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if category has banners before rendering
    final hasBanners = ref.watch(hasBannersProvider(categoryId));
    final bannerCount = ref.watch(bannerCountProvider(categoryId));

    if (!hasBanners) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '프로모션 ($bannerCount)',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        CategoryBannersExample(categoryId: categoryId),
      ],
    );
  }
}

/// Example 4: Banner card widget
class BannerCard extends StatelessWidget {
  final CategoryBanner banner;

  const BannerCard({
    required this.banner,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: banner.getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.network(
                banner.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: banner.getBackgroundColor(),
                  );
                },
              ),
            ),
            // Content overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      banner.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      banner.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 5: Pull-to-refresh
class RefreshableBannerList extends ConsumerWidget {
  const RefreshableBannerList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(categoryBannerProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(categoryBannerProvider.notifier).refresh();
      },
      child: bannersAsync.when(
        data: (banners) => ListView.builder(
          itemCount: banners.length,
          itemBuilder: (context, index) {
            final banner = banners[index];
            return BannerCard(banner: banner);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ListView(
          children: [
            Center(
              child: Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 6: Get banner by ID
class BannerDetailExample extends ConsumerWidget {
  final String bannerId;

  const BannerDetailExample({
    required this.bannerId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banner = ref.watch(bannerByIdProvider(bannerId));

    if (banner == null) {
      return const Center(child: Text('Banner not found'));
    }

    return Scaffold(
      appBar: AppBar(title: Text(banner.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                banner.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              banner.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              banner.subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Handle banner action (navigation, deep link, etc.)
                debugPrint('Banner action: ${banner.actionUrl}');
              },
              child: const Text('자세히 보기'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 7: Check loading state
class LoadingStateExample extends ConsumerWidget {
  const LoadingStateExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(bannersLoadingProvider);
    final banners = ref.watch(bannersListProvider);

    return Column(
      children: [
        if (isLoading)
          const LinearProgressIndicator()
        else
          const SizedBox(height: 4),
        Expanded(
          child: ListView.builder(
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return BannerCard(banner: banner);
            },
          ),
        ),
      ],
    );
  }
}
