# Category Banner Architecture - Quick Reference

## Overview
This document provides a quick reference for implementing category-specific advertisement banners in the Benefits screen.

## Architecture at a Glance

```
┌─────────────────────────────────────────────────────────────┐
│                    3-LAYER ARCHITECTURE                      │
├─────────────────────────────────────────────────────────────┤
│ PRESENTATION  │ CategoryBannerCarousel Widget                │
│               │ - Displays banners for selected category      │
│               │ - PageView with indicators                    │
│               │ - Handles user interactions                   │
├─────────────────────────────────────────────────────────────┤
│ DOMAIN        │ Riverpod Providers + Repository              │
│               │ - categoryBannersProvider(categoryCode)       │
│               │ - Automatic caching & realtime updates       │
│               │ - Mock data fallback                          │
├─────────────────────────────────────────────────────────────┤
│ DATA          │ Supabase Database + Repository Pattern       │
│               │ - category_banners table                      │
│               │ - banner_analytics table                      │
│               │ - RLS policies for security                   │
└─────────────────────────────────────────────────────────────┘
```

## Key Files to Create

### 1. Data Models
**Location**: `lib/contexts/benefits/models/`

- `category_banner.dart` - Main banner data model
- `category_codes.dart` - Category constants (popular, housing, etc.)

### 2. Repository
**Location**: `lib/contexts/benefits/repositories/`

- `category_banner_repository.dart` - Data access layer
  - `fetchBannersByCategory(categoryCode)`
  - `trackBannerClick(bannerId)`
  - `subscribeToBanners(categoryCode)`

### 3. Providers
**Location**: `lib/contexts/benefits/providers/`

- `category_banner_provider.dart` - Riverpod state management
  - `categoryBannersProvider` (Family)
  - `categoryBannersListProvider`
  - `categoryBannerIndexProvider`

### 4. UI Widgets
**Location**: `lib/features/benefits/widgets/`

- `category_banner_carousel.dart` - Banner carousel
- `category_banner_card.dart` - Individual banner (wraps AdvertisementBanner)

### 5. Database Migration
**Location**: `supabase/migrations/`

- `20251016000000_create_category_banners.sql`

### 6. Exceptions
**Location**: `lib/contexts/benefits/exceptions/`

- `category_banner_exception.dart`

## Database Schema (Simplified)

```sql
-- category_banners table
CREATE TABLE category_banners (
  id UUID PRIMARY KEY,
  category_code TEXT NOT NULL,        -- 'popular', 'housing', etc.
  title TEXT NOT NULL,                -- "당첨 후기 작성하고\n선물 받자"
  subtitle TEXT NOT NULL,             -- "경험을 함께 나누어 주세요."
  image_url TEXT,                     -- Optional image
  background_color TEXT DEFAULT '#074D43',
  action_url TEXT NOT NULL,           -- Deep link or URL
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  start_date TIMESTAMPTZ,             -- Optional scheduling
  end_date TIMESTAMPTZ,
  click_count INTEGER DEFAULT 0,
  impression_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_category_banners_category ON category_banners(category_code);
CREATE INDEX idx_category_banners_active ON category_banners(is_active);
CREATE INDEX idx_category_banners_sort ON category_banners(category_code, sort_order);
```

## Usage Example

### In BenefitsScreen

**Before** (Hardcoded):
```dart
const AdvertisementBanner(
  title: '당첨 후기 작성하고\n선물 받자',
  subtitle: '경험을 함께 나누어 주세요.',
  imageUrl: 'https://placehold.co/132x132',
  currentIndex: 1,
  totalCount: 8,
),
```

**After** (Dynamic):
```dart
CategoryBannerCarousel(
  categoryCode: CategoryCodes.byIndex(_selectedCategoryIndex),
),
```

### Category Banner Carousel Widget

```dart
class CategoryBannerCarousel extends ConsumerStatefulWidget {
  final String categoryCode;

  const CategoryBannerCarousel({
    required this.categoryCode,
    super.key,
  });

  @override
  ConsumerState<CategoryBannerCarousel> createState() =>
    _CategoryBannerCarouselState();
}

class _CategoryBannerCarouselState
    extends ConsumerState<CategoryBannerCarousel> {

  late PageController _pageController;

  @override
  Widget build(BuildContext context) {
    // Watch banners for current category
    final bannersAsync = ref.watch(
      categoryBannersProvider(widget.categoryCode)
    );

    return bannersAsync.when(
      loading: () => const BannerSkeleton(),
      error: (err, stack) => const EmptyBanner(),
      data: (banners) {
        if (banners.isEmpty) return const EmptyBanner();

        return SizedBox(
          height: 80,
          child: PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: (index) {
              // Track impression
              _trackImpression(banners[index].id);
            },
            itemBuilder: (context, index) {
              final banner = banners[index];
              return GestureDetector(
                onTap: () => _handleBannerTap(banner),
                child: AdvertisementBanner(
                  title: banner.title,
                  subtitle: banner.subtitle,
                  imageUrl: banner.imageUrl,
                  backgroundColor: _parseColor(banner.backgroundColor),
                  currentIndex: index + 1,
                  totalCount: banners.length,
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _handleBannerTap(CategoryBanner banner) {
    // Track click
    ref.read(categoryBannerRepositoryProvider)
      ?.trackBannerClick(banner.id);

    // Navigate to action URL
    context.push(banner.actionUrl);
  }

  void _trackImpression(String bannerId) {
    ref.read(categoryBannerRepositoryProvider)
      ?.trackBannerImpression(bannerId);
  }
}
```

## Category Code Mapping

| Tab Index | Category Code | Display Name |
|-----------|--------------|--------------|
| 0 | `popular` | 인기 |
| 1 | `housing` | 주거 |
| 2 | `education` | 교육 |
| 3 | `support` | 지원 |
| 4 | `transport` | 교통 |
| 5 | `welfare` | 복지 |
| 6 | `clothing` | 의류 |
| 7 | `food` | 식품 |
| 8 | `culture` | 문화 |

**Usage**:
```dart
final categoryCode = CategoryCodes.byIndex(_selectedCategoryIndex);
// Returns: 'popular', 'housing', 'education', etc.
```

## Provider Pattern

```dart
// Provider for repository (null-safe for offline mode)
final categoryBannerRepositoryProvider =
  Provider<CategoryBannerRepository?>((ref) {
    final supabase = ref.watch(supabaseServiceProvider);
    return supabase.isInitialized
      ? CategoryBannerRepository(client: supabase.client!)
      : null;
  });

// Family provider for banners by category
final categoryBannersProvider = AsyncNotifierProvider.family<
  CategoryBannersNotifier,
  List<CategoryBanner>,
  String
>(CategoryBannersNotifier.new);

// Convenience provider for simple list access
final categoryBannersListProvider =
  Provider.family<List<CategoryBanner>, String>(
    (ref, categoryCode) {
      final asyncBanners = ref.watch(
        categoryBannersProvider(categoryCode)
      );
      return asyncBanners.maybeWhen(
        data: (banners) => banners,
        orElse: () => [],
      );
    },
  );
```

## Implementation Checklist

### Phase 1: Foundation
- [ ] Create Supabase migration file
- [ ] Deploy migration to Supabase
- [ ] Insert sample data for testing
- [ ] Create `CategoryBanner` model
- [ ] Create `CategoryCodes` constants
- [ ] Create `CategoryBannerException`
- [ ] Write model unit tests

### Phase 2: Repository & State
- [ ] Implement `CategoryBannerRepository`
- [ ] Add repository methods (fetch, track, subscribe)
- [ ] Write repository unit tests (mock Supabase)
- [ ] Create Riverpod providers
- [ ] Add realtime subscription logic
- [ ] Create mock data function
- [ ] Write provider tests

### Phase 3: UI Components
- [ ] Create `CategoryBannerCarousel` widget
- [ ] Create `CategoryBannerCard` widget
- [ ] Add PageView with indicators
- [ ] Implement analytics tracking
- [ ] Add loading/error states
- [ ] Write widget tests

### Phase 4: Integration
- [ ] Update `BenefitsScreen` to use carousel
- [ ] Pass category code based on tab
- [ ] Test all 9 categories
- [ ] Handle edge cases (no data, errors)
- [ ] Performance optimization
- [ ] Integration tests

### Phase 5: Backend Admin
- [ ] Design admin UI mockups
- [ ] Create RLS policies
- [ ] Build CRUD screens (or use Supabase dashboard)
- [ ] Add scheduling controls
- [ ] Create analytics dashboard

### Phase 6: Testing & Launch
- [ ] Comprehensive unit tests (>85% coverage)
- [ ] Widget tests for all components
- [ ] Integration tests for full flow
- [ ] Performance profiling
- [ ] Accessibility testing
- [ ] Documentation updates
- [ ] Soft launch with feature flag
- [ ] Monitor metrics
- [ ] Full rollout

## Testing Examples

### Unit Test (Model)
```dart
test('CategoryBanner.shouldDisplay checks scheduling', () {
  final future = DateTime.now().add(Duration(days: 1));
  final banner = CategoryBanner(
    id: '1',
    categoryCode: 'popular',
    title: 'Test',
    subtitle: 'Test',
    backgroundColor: '#000000',
    actionUrl: '/test',
    sortOrder: 1,
    isActive: true,
    startDate: future,  // Starts tomorrow
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  expect(banner.shouldDisplay, false);
});
```

### Widget Test
```dart
testWidgets('CategoryBannerCarousel shows banners', (tester) async {
  final mockBanners = [
    CategoryBanner(/* ... */),
    CategoryBanner(/* ... */),
  ];

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        categoryBannersProvider('popular').overrideWith(
          (ref) => AsyncValue.data(mockBanners),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: CategoryBannerCarousel(categoryCode: 'popular'),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
  expect(find.byType(AdvertisementBanner), findsOneWidget);
});
```

## Performance Considerations

1. **Caching**: Riverpod family providers automatically cache per category
2. **Lazy Loading**: Banners only fetched when category is viewed
3. **Image Optimization**: Use CDN and appropriate image sizes
4. **Realtime**: One subscription per active category (cleanup on dispose)
5. **Analytics**: Non-blocking background calls
6. **Database**: Indexed queries for fast lookups

## Key Design Decisions

1. **Repository Pattern**: Follows existing codebase pattern (RegionRepository)
2. **Mock Data Fallback**: Always show content, even offline
3. **Family Provider**: Efficient per-category state management
4. **Scheduled Banners**: Support time-based visibility
5. **Analytics Tracking**: Built-in click/impression tracking
6. **Realtime Updates**: Instant banner updates from admin panel

## Sample Data for Testing

```sql
-- Insert test banner for popular category
INSERT INTO category_banners (
  category_code,
  title,
  subtitle,
  image_url,
  background_color,
  action_url,
  sort_order
) VALUES (
  'popular',
  '당첨 후기 작성하고\n선물 받자',
  '경험을 함께 나누어 주세요.',
  'https://placehold.co/132x132',
  '#074D43',
  '/reviews/write',
  1
);
```

## Monitoring Queries

```sql
-- Banner performance by category
SELECT
  category_code,
  COUNT(*) as banner_count,
  SUM(click_count) as total_clicks,
  SUM(impression_count) as total_impressions,
  ROUND(
    AVG(CASE
      WHEN impression_count > 0
      THEN (click_count::float / impression_count) * 100
      ELSE 0
    END),
    2
  ) as avg_ctr
FROM category_banners
WHERE is_active = true
GROUP BY category_code
ORDER BY total_clicks DESC;
```

## References

- Full Architecture Document: `/docs/architecture/category-banner-architecture.md`
- Component Structure Guide: `/docs/architecture/component-structure-guide.md`
- Existing Region Provider: `/lib/features/onboarding/providers/region_provider.dart`
- Existing Region Repository: `/lib/contexts/user/repositories/region_repository.dart`

## Support

For questions or issues:
1. Check the full architecture document
2. Review existing Region provider/repository implementations
3. Consult team channel for architectural decisions

---

**Status**: Ready for Implementation
**Estimated Effort**: 2-3 weeks (1 developer)
**Risk Level**: Low (follows established patterns)
