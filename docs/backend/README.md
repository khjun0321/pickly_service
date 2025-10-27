# Category Banner Backend Integration

## Overview

Complete backend integration system for category-specific advertisement banners in the Pickly mobile application. This system supports 9 benefit categories with dynamic, scheduled banners managed through a Supabase backend.

## Documentation Structure

```
docs/backend/
├── README.md                          # This file
├── banner-integration-design.md       # Complete architecture documentation
├── supabase-schema.sql               # Database schema and setup
└── integration-guide.md              # Quick start and usage guide
```

## Quick Links

- **Architecture Design**: [`banner-integration-design.md`](/Users/kwonhyunjun/Desktop/pickly_service/docs/backend/banner-integration-design.md)
- **Database Schema**: [`supabase-schema.sql`](/Users/kwonhyunjun/Desktop/pickly_service/docs/backend/supabase-schema.sql)
- **Integration Guide**: [`integration-guide.md`](/Users/kwonhyunjun/Desktop/pickly_service/docs/backend/integration-guide.md)

## Features

### Core Functionality
- ✅ Category-specific banner management (9 categories)
- ✅ Scheduled banners with start/end dates
- ✅ Priority-based banner ordering
- ✅ Active/inactive status control
- ✅ Click-through tracking and analytics
- ✅ Real-time updates via Supabase subscriptions

### Technical Features
- ✅ Three-tier caching (Memory → Local Storage → Supabase)
- ✅ Automatic cache invalidation
- ✅ Graceful degradation on network errors
- ✅ Mock data provider for offline development
- ✅ Repository pattern for clean architecture
- ✅ Riverpod state management integration
- ✅ Row Level Security (RLS) policies

## Architecture

```
┌─────────────────────────────────────────┐
│         UI Layer (Widgets)              │
│  - BenefitsScreen                       │
│  - AdvertisementBanner                  │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│      State Management (Riverpod)        │
│  - categoryBannersProvider              │
│  - bannerTrackingProvider               │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│       Service Layer                     │
│  - BannerService                        │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│    Repository Layer                     │
│  - SupabaseBannerRepository             │
│  - MockBannerRepository                 │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Data Sources                    │
│  - Supabase (Remote)                    │
│  - SharedPreferences (Local Cache)      │
└─────────────────────────────────────────┘
```

## File Structure

### Backend Documentation
```
docs/backend/
├── README.md                                    # Overview (this file)
├── banner-integration-design.md                 # Architecture & design
├── supabase-schema.sql                         # Database schema
└── integration-guide.md                        # Implementation guide
```

### Flutter Implementation
```
lib/features/banners/
├── models/
│   └── banner_model.dart                       # Data models (Freezed)
├── repositories/
│   ├── banner_repository.dart                  # Repository interface
│   ├── supabase_banner_repository.dart         # Supabase implementation
│   └── mock_banner_repository.dart             # Mock implementation
├── services/
│   └── banner_service.dart                     # Business logic layer
└── providers/
    └── banner_providers.dart                   # Riverpod providers
```

## Database Schema

### Main Table: `category_banners`

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| category_id | VARCHAR(20) | Category identifier |
| title | VARCHAR(100) | Banner main text |
| subtitle | VARCHAR(200) | Banner secondary text |
| image_url | TEXT | Banner image URL |
| background_color | VARCHAR(7) | Hex color code |
| action_type | VARCHAR(20) | Action on tap |
| action_url | TEXT | Navigation target |
| display_order | INTEGER | Display priority |
| is_active | BOOLEAN | Active status |
| start_date | TIMESTAMP | Schedule start |
| end_date | TIMESTAMP | Schedule end |
| impression_count | INTEGER | View count |
| click_count | INTEGER | Click count |
| created_at | TIMESTAMP | Creation time |
| updated_at | TIMESTAMP | Last update |

### Categories

1. `popular` - 인기
2. `housing` - 주거
3. `education` - 교육
4. `support` - 지원
5. `transportation` - 교통
6. `welfare` - 복지
7. `clothing` - 의류
8. `food` - 식품
9. `culture` - 문화

## Getting Started

### 1. Database Setup

Execute the SQL schema in Supabase:

```bash
# File: docs/backend/supabase-schema.sql
# Copy content to Supabase SQL Editor and execute
```

### 2. Environment Configuration

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### 3. Flutter Dependencies

```yaml
dependencies:
  freezed_annotation: ^2.4.1
  supabase_flutter: ^2.0.0
  shared_preferences: ^2.2.2
  flutter_riverpod: ^2.4.9
```

### 4. Generate Code

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Initialize Supabase

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(ProviderScope(child: MyApp()));
}
```

## Usage Example

```dart
class BenefitsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = BannerCategory.popular;
    final bannersAsync = ref.watch(categoryBannersProvider(category));

    return bannersAsync.when(
      data: (banners) => BannerCarousel(banners: banners),
      loading: () => LoadingIndicator(),
      error: (error, _) => ErrorWidget(error: error),
    );
  }
}
```

## API Reference

### Repository Methods

```dart
// Fetch banners
Future<List<BannerModel>> getBannersByCategory(BannerCategory category)
Future<Map<BannerCategory, List<BannerModel>>> getAllActiveBanners()

// Analytics
Future<void> recordImpression(String bannerId)
Future<void> recordClick(String bannerId)

// Cache management
Future<List<BannerModel>> refreshBanners(BannerCategory category)
Future<void> prefetchAllBanners()
Future<void> clearCache()

// Real-time
Stream<List<BannerModel>> watchBannersByCategory(BannerCategory category)
```

### Riverpod Providers

```dart
// Data providers
categoryBannersProvider(BannerCategory)          // Banners by category
allBannersProvider                               // All banners
bannerByIdProvider(String)                       // Single banner
selectedCategoryBannersProvider                  // Current category banners

// Stream providers
bannerStreamProvider(BannerCategory)             // Real-time updates

// State providers
selectedCategoryProvider                         // Current category

// Controller providers
bannerTrackingProvider                           // Track impressions/clicks
bannerCacheProvider                             // Cache operations
bannerValidationProvider                        // Validate banners
```

## Caching Strategy

### Three-Tier Cache

1. **Memory Cache** (5 minutes TTL)
   - Fast in-memory storage
   - Cleared on app restart

2. **Local Storage** (1 hour TTL)
   - SharedPreferences persistence
   - Survives app restarts

3. **Remote (Supabase)**
   - Source of truth
   - Real-time updates

### Cache Flow

```
Request → Memory Cache (hit) → Return
         ↓ (miss)
       Local Cache (hit) → Update Memory → Return
         ↓ (miss)
       Supabase (fetch) → Update Local & Memory → Return
```

## Analytics

### Tracked Metrics

- **Impressions**: Banner view count
- **Clicks**: Banner tap count
- **CTR**: Click-through rate (clicks/impressions × 100)
- **Category Performance**: Aggregated metrics per category

### Supabase Functions

```sql
-- Get active banners for category
SELECT * FROM get_active_banners('popular');

-- Track impression
SELECT increment_banner_impression('banner-uuid');

-- Track click
SELECT increment_banner_click('banner-uuid');

-- Get analytics
SELECT * FROM banner_analytics;
```

## Admin Operations

### Create Banner

```sql
INSERT INTO category_banners (
  category_id, title, subtitle, image_url,
  background_color, action_type, action_url,
  display_order, is_active
) VALUES (
  'popular', 'New Banner', 'Description',
  'https://example.com/image.jpg',
  '#FF6B35', 'internal_link', '/destination',
  0, true
);
```

### Schedule Banner

```sql
UPDATE category_banners
SET
  start_date = '2025-11-01 00:00:00+00',
  end_date = '2025-11-30 23:59:59+00'
WHERE id = 'banner-uuid';
```

### View Performance

```sql
SELECT
  id, title, impression_count, click_count,
  ROUND((click_count::DECIMAL / NULLIF(impression_count, 0)) * 100, 2) as ctr
FROM category_banners
ORDER BY ctr DESC;
```

## Security

### Row Level Security (RLS)

```sql
-- Public read access (active banners only)
CREATE POLICY "Public can view active banners"
  ON category_banners FOR SELECT
  USING (is_active = true AND ...);

-- Admin full access
CREATE POLICY "Admins can manage all banners"
  ON category_banners FOR ALL
  USING (auth.jwt() ->> 'role' = 'admin');

-- Analytics tracking allowed
CREATE POLICY "Allow analytics tracking"
  ON category_banners FOR UPDATE
  USING (true) WITH CHECK (...);
```

## Performance Optimization

1. **Database Indexes**
   - Category + Display Order
   - Active Status
   - Date Ranges

2. **Lazy Loading**
   - Load banners per category
   - Prefetch adjacent categories

3. **Image Optimization**
   - CDN for images
   - Progressive loading
   - Local caching

4. **Connection Pooling**
   - Supabase connection reuse
   - Batch operations

## Testing

### Mock Data

Use `MockBannerRepository` for development without Supabase:

```dart
final repository = MockBannerRepository();
final banners = await repository.getBannersByCategory(
  BannerCategory.popular,
);
```

### Unit Tests

```dart
test('should fetch banners by category', () async {
  final banners = await repository.getBannersByCategory(
    BannerCategory.popular,
  );
  expect(banners, isNotEmpty);
});
```

### Integration Tests

```dart
testWidgets('should display banners', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.byType(AdvertisementBanner), findsWidgets);
});
```

## Troubleshooting

### Common Issues

1. **Banners not loading**
   - Verify Supabase connection
   - Check RLS policies
   - Review network logs

2. **Real-time updates not working**
   - Enable Supabase Realtime
   - Check subscription status
   - Verify channel cleanup

3. **Cache issues**
   - Clear cache: `cacheController.clearAll()`
   - Force refresh: `cacheController.refreshCategory()`

### Debugging

```dart
// Check Supabase status
print(SupabaseService.instance.isInitialized);

// Check repository type
print(ref.read(bannerRepositoryProvider).runtimeType);

// Check cache
final timestamp = await repository.getCacheTimestamp(category);
print('Cache age: ${DateTime.now().difference(timestamp!)}');
```

## Migration Checklist

- [ ] Execute SQL schema in Supabase
- [ ] Configure environment variables
- [ ] Install Flutter dependencies
- [ ] Generate Freezed models
- [ ] Initialize Supabase in main.dart
- [ ] Update UI to use providers
- [ ] Implement banner tracking
- [ ] Test with mock data
- [ ] Test with real Supabase
- [ ] Deploy to production

## Next Steps

1. **Immediate**: Execute database schema
2. **Development**: Test with mock data
3. **Integration**: Connect to Supabase
4. **Testing**: Verify real-time updates
5. **Production**: Deploy and monitor

## Support Resources

- **Architecture**: See [`banner-integration-design.md`](/Users/kwonhyunjun/Desktop/pickly_service/docs/backend/banner-integration-design.md)
- **Schema**: See [`supabase-schema.sql`](/Users/kwonhyunjun/Desktop/pickly_service/docs/backend/supabase-schema.sql)
- **Guide**: See [`integration-guide.md`](/Users/kwonhyunjun/Desktop/pickly_service/docs/backend/integration-guide.md)
- **Supabase Docs**: https://supabase.com/docs
- **Riverpod Docs**: https://riverpod.dev

## Contributing

When adding new features:

1. Update data models in `banner_model.dart`
2. Add repository methods
3. Update service layer
4. Create new providers
5. Update SQL schema if needed
6. Document changes

## License

Internal use only - Pickly Service

---

**Last Updated**: 2025-10-16
**Version**: 1.0.0
**Author**: Backend Team
