# Banner Integration Guide

## Quick Start

### 1. Setup Supabase Database

Execute the SQL schema file in your Supabase SQL editor:

```bash
# Copy the schema file content
/Users/kwonhyunjun/Desktop/pickly_service/docs/backend/supabase-schema.sql
```

This will create:
- `category_banners` table
- Indexes for performance
- RLS policies for security
- Helper functions for queries
- Views for analytics
- Seed data for development

### 2. Configure Environment

Add your Supabase credentials to `.env`:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### 3. Install Dependencies

Add to `pubspec.yaml` if not already present:

```yaml
dependencies:
  freezed_annotation: ^2.4.1
  supabase_flutter: ^2.0.0
  shared_preferences: ^2.2.2
  flutter_riverpod: ^2.4.9

dev_dependencies:
  freezed: ^2.4.5
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
```

Run:
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Initialize in Main App

```dart
import 'package:pickly_mobile/core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

## Usage Examples

### Display Banners in Benefits Screen

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_mobile/features/banners/providers/banner_providers.dart';
import 'package:pickly_mobile/features/banners/models/banner_model.dart';

class BenefitsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final bannersAsync = ref.watch(categoryBannersProvider(selectedCategory));

    return bannersAsync.when(
      data: (banners) {
        if (banners.isEmpty) {
          return Center(child: Text('No banners available'));
        }

        return BannerCarousel(banners: banners);
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading banners: $error'),
      ),
    );
  }
}
```

### Track Banner Impressions

```dart
class BannerWidget extends ConsumerWidget {
  final BannerModel banner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Track impression when banner is displayed
    useEffect(() {
      final tracking = ref.read(bannerTrackingProvider);
      tracking.trackImpression(banner.id);
      return null;
    }, [banner.id]);

    return GestureDetector(
      onTap: () => _handleBannerTap(context, ref),
      child: BannerCard(banner: banner),
    );
  }

  Future<void> _handleBannerTap(BuildContext context, WidgetRef ref) async {
    final tracking = ref.read(bannerTrackingProvider);

    // Track click
    final success = await tracking.trackClick(banner.id);

    if (success && banner.hasAction) {
      // Navigate based on action type
      _handleBannerAction(context, banner);
    }
  }

  void _handleBannerAction(BuildContext context, BannerModel banner) {
    switch (banner.actionType) {
      case BannerActionType.internalLink:
        context.push(banner.actionUrl!);
        break;
      case BannerActionType.externalLink:
        launchUrl(Uri.parse(banner.actionUrl!));
        break;
      case BannerActionType.deepLink:
        // Handle deep link
        break;
      case BannerActionType.none:
        break;
    }
  }
}
```

### Real-time Updates

```dart
class LiveBannersWidget extends ConsumerWidget {
  final BannerCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersStream = ref.watch(bannerStreamProvider(category));

    return bannersStream.when(
      data: (banners) => BannerList(banners: banners),
      loading: () => LoadingIndicator(),
      error: (error, stack) => ErrorWidget(error: error),
    );
  }
}
```

### Prefetch Banners

```dart
class AppInitializer {
  static Future<void> initialize(WidgetRef ref) async {
    // Prefetch all banners for faster access
    final cacheController = ref.read(bannerCacheProvider);
    await cacheController.prefetchAll();
  }
}
```

### Pull to Refresh

```dart
class BannersListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        final cacheController = ref.read(bannerCacheProvider);
        await cacheController.refreshSelected();
      },
      child: BannersList(),
    );
  }
}
```

### Category Selection

```dart
class CategoryTabs extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: BannerCategory.values.length,
      itemBuilder: (context, index) {
        final category = BannerCategory.values[index];
        final isSelected = category == selectedCategory;

        return TabButton(
          label: category.displayName,
          icon: category.iconPath,
          isSelected: isSelected,
          onTap: () {
            // Update selected category
            ref.read(selectedCategoryProvider.notifier).state = category;
          },
        );
      },
    );
  }
}
```

## Admin Panel Queries

### Create a New Banner

```sql
INSERT INTO category_banners (
  category_id,
  title,
  subtitle,
  image_url,
  background_color,
  action_type,
  action_url,
  display_order,
  is_active,
  start_date,
  end_date
) VALUES (
  'popular',
  '신규 혜택 런칭',
  '지금 바로 신청하세요',
  'https://cdn.example.com/banner-image.jpg',
  '#FF6B35',
  'internal_link',
  '/benefits/new-launch',
  0,
  true,
  NOW(),
  NOW() + INTERVAL '30 days'
);
```

### Update Banner

```sql
UPDATE category_banners
SET
  title = '업데이트된 제목',
  is_active = false
WHERE id = 'banner-uuid';
```

### View Analytics

```sql
-- Get banner performance
SELECT
  id,
  title,
  category_id,
  impression_count,
  click_count,
  ROUND((click_count::DECIMAL / NULLIF(impression_count, 0)::DECIMAL) * 100, 2) as ctr_percentage
FROM category_banners
WHERE category_id = 'popular'
ORDER BY click_count DESC;

-- Get category summary
SELECT * FROM banner_analytics;

-- Get top performing banners
SELECT * FROM active_category_banners
WHERE impression_count > 100
ORDER BY ctr_percentage DESC
LIMIT 10;
```

### Schedule Banners

```sql
-- Set banner to activate in the future
UPDATE category_banners
SET
  start_date = '2025-11-01 00:00:00+00',
  end_date = '2025-11-30 23:59:59+00'
WHERE id = 'banner-uuid';

-- View scheduled banners
SELECT * FROM scheduled_banners;
```

### Deactivate Expired Banners

```sql
-- Manual deactivation
UPDATE category_banners
SET is_active = false
WHERE end_date < NOW() AND is_active = true;

-- Or use the function
SELECT auto_deactivate_expired_banners();
```

## Testing

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pickly_mobile/features/banners/repositories/mock_banner_repository.dart';

void main() {
  group('BannerRepository', () {
    late MockBannerRepository repository;

    setUp(() {
      repository = MockBannerRepository();
    });

    test('should fetch banners by category', () async {
      final banners = await repository.getBannersByCategory(
        BannerCategory.popular,
      );

      expect(banners, isNotEmpty);
      expect(banners.first.categoryId, BannerCategory.popular);
    });

    test('should track impressions', () async {
      final banner = (await repository.getBannersByCategory(
        BannerCategory.popular,
      )).first;

      await repository.recordImpression(banner.id);

      expect(repository.getImpressionCount(banner.id), 1);
    });
  });
}
```

### Integration Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('should display banners', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Navigate to benefits screen
    await tester.tap(find.text('혜택'));
    await tester.pumpAndSettle();

    // Verify banners are displayed
    expect(find.byType(AdvertisementBanner), findsWidgets);
  });
}
```

## Performance Best Practices

1. **Prefetch on App Start**
   ```dart
   await cacheController.prefetchAll();
   ```

2. **Use Memory Cache for Frequently Accessed Categories**
   - Memory cache TTL: 5 minutes
   - Local cache TTL: 1 hour

3. **Batch Analytics Tracking**
   ```dart
   tracking.trackMultipleImpressions(bannerIds);
   ```

4. **Lazy Load Images**
   ```dart
   CachedNetworkImage(
     imageUrl: banner.imageUrl,
     placeholder: (context, url) => LoadingPlaceholder(),
   );
   ```

5. **Optimize Real-time Subscriptions**
   - Only subscribe to visible categories
   - Unsubscribe when not in view

## Troubleshooting

### Banners Not Loading

1. Check Supabase connection
   ```dart
   print(SupabaseService.instance.isInitialized);
   ```

2. Verify RLS policies allow public read access

3. Check network connectivity

4. Fall back to mock data
   ```dart
   final repository = MockBannerRepository();
   ```

### Real-time Updates Not Working

1. Verify Supabase Realtime is enabled
2. Check subscription status
3. Ensure proper channel cleanup

### Cache Issues

```dart
// Clear cache
await cacheController.clearAll();

// Force refresh
await cacheController.refreshCategory(category);
```

## Migration Checklist

- [ ] Execute SQL schema in Supabase
- [ ] Add environment variables
- [ ] Install dependencies
- [ ] Run build_runner
- [ ] Initialize Supabase in main.dart
- [ ] Update benefits screen to use providers
- [ ] Add banner tracking
- [ ] Test with mock data
- [ ] Test with real Supabase data
- [ ] Deploy to production

## Support

For issues or questions:
1. Check the main documentation: `/docs/backend/banner-integration-design.md`
2. Review Supabase schema: `/docs/backend/supabase-schema.sql`
3. Contact backend team
