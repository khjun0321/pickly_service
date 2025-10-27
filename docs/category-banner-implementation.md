# Category Banner Implementation

## Overview

This document describes the implementation of category-specific advertisement banners for the Pickly benefits feature. The system provides data models, state management providers, and mock data for displaying promotional banners across different benefit categories.

## Architecture

### Directory Structure

```
lib/features/benefits/
├── models/
│   └── category_banner.dart          # Banner data model
├── providers/
│   ├── category_banner_provider.dart # Riverpod state management
│   └── mock_banner_data.dart         # Mock data for development
└── examples/
    └── banner_usage_example.dart     # Usage examples and widgets
```

## Components

### 1. CategoryBanner Model

**Location:** `/apps/pickly_mobile/lib/features/benefits/models/category_banner.dart`

Immutable data model representing a category-specific banner with the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Unique identifier (UUID) |
| `categoryId` | String | Associated category (e.g., 'popular', 'housing') |
| `title` | String | Banner title text |
| `subtitle` | String | Banner subtitle/description |
| `imageUrl` | String | Image URL for banner visual |
| `backgroundColor` | String | Background color (hex format) |
| `actionUrl` | String | Action URL when tapped |
| `displayOrder` | int | Display priority (lower = higher) |
| `isActive` | bool | Whether banner is visible |
| `createdAt` | DateTime | Creation timestamp |
| `updatedAt` | DateTime | Last update timestamp |

**Key Methods:**
- `fromJson()` - Creates instance from Supabase JSON
- `toJson()` - Converts to JSON for Supabase operations
- `copyWith()` - Creates copy with field overrides
- `getBackgroundColor()` - Converts hex color to Flutter Color

**Example:**
```dart
final banner = CategoryBanner(
  id: 'banner-1',
  categoryId: 'popular',
  title: '청년도약계좌',
  subtitle: '월 최대 70만원 저축 시 정부지원금',
  imageUrl: 'https://example.com/banner.jpg',
  backgroundColor: '#2196F3',
  actionUrl: '/policies/youth-account',
  displayOrder: 1,
  isActive: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Use background color in widgets
Container(color: banner.getBackgroundColor());
```

### 2. CategoryBannerProvider

**Location:** `/apps/pickly_mobile/lib/features/benefits/providers/category_banner_provider.dart`

Riverpod-based state management for banner data using `AsyncNotifier` pattern.

**Main Provider:**
```dart
final categoryBannerProvider = AsyncNotifierProvider<
  CategoryBannerNotifier,
  List<CategoryBanner>
>();
```

**Features:**
- Async data loading with loading/error states
- In-memory caching
- Manual refresh capability
- Fallback to mock data
- Future-ready for Supabase integration

**Available Providers:**

| Provider | Returns | Use Case |
|----------|---------|----------|
| `categoryBannerProvider` | `AsyncValue<List<CategoryBanner>>` | All banners with loading states |
| `bannersByCategoryProvider(categoryId)` | `List<CategoryBanner>` | Filtered banners for category |
| `bannersListProvider` | `List<CategoryBanner>` | All banners as simple list |
| `bannersLoadingProvider` | `bool` | Loading state check |
| `bannersErrorProvider` | `Object?` | Error state |
| `bannerByIdProvider(id)` | `CategoryBanner?` | Single banner by ID |
| `bannerCountProvider(categoryId)` | `int` | Count of banners in category |
| `hasBannersProvider(categoryId)` | `bool` | Check if category has banners |
| `categoriesWithBannersProvider` | `List<String>` | All category IDs with banners |

**Usage Examples:**

```dart
// Watch all banners
final bannersAsync = ref.watch(categoryBannerProvider);
bannersAsync.when(
  data: (banners) => BannerList(banners),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
);

// Get category-specific banners
final popularBanners = ref.watch(bannersByCategoryProvider('popular'));

// Check if category has banners
final hasBanners = ref.watch(hasBannersProvider('housing'));

// Refresh data
ref.read(categoryBannerProvider.notifier).refresh();
```

### 3. MockBannerData

**Location:** `/apps/pickly_mobile/lib/features/benefits/providers/mock_banner_data.dart`

Static mock data provider for development and testing.

**Available Categories:**
- `popular` - 인기 (3 banners)
- `housing` - 주거 (3 banners)
- `education` - 교육 (2 banners)
- `support` - 지원 (3 banners)
- `transportation` - 교통 (2 banners)
- `welfare` - 복지 (3 banners)

**Total:** 16 mock banners across 6 categories

**Methods:**
```dart
// Get all mock banners
List<CategoryBanner> banners = MockBannerData.getAllBanners();

// Get banners for specific category
List<CategoryBanner> popularBanners =
  MockBannerData.getBannersByCategory('popular');

// Get available category IDs
List<String> categories = MockBannerData.getAvailableCategories();

// Get banner count for category
int count = MockBannerData.getBannerCount('housing');
```

## Usage Examples

### Basic Banner List

```dart
class BannerListScreen extends ConsumerWidget {
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
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### Category-Specific Banners

```dart
class CategoryBannersWidget extends ConsumerWidget {
  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banners = ref.watch(bannersByCategoryProvider(categoryId));

    if (banners.isEmpty) {
      return SizedBox.shrink();
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: banners.length,
        itemBuilder: (context, index) {
          return BannerCard(banner: banners[index]);
        },
      ),
    );
  }
}
```

### Pull-to-Refresh

```dart
RefreshIndicator(
  onRefresh: () async {
    await ref.read(categoryBannerProvider.notifier).refresh();
  },
  child: BannerList(),
);
```

### Conditional Display

```dart
class ConditionalBanner extends ConsumerWidget {
  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBanners = ref.watch(hasBannersProvider(categoryId));

    if (!hasBanners) {
      return SizedBox.shrink();
    }

    return CategoryBannersWidget(categoryId: categoryId);
  }
}
```

## Code Standards

### Design Patterns
- ✅ Follows existing project patterns (AgeCategory, Region models)
- ✅ Uses Riverpod AsyncNotifier for state management
- ✅ Immutable data models with copyWith support
- ✅ JSON serialization for Supabase compatibility
- ✅ Comprehensive documentation and examples

### Best Practices
- ✅ No freezed dependency (consistent with project)
- ✅ Regular classes with manual serialization
- ✅ Defensive programming (try-catch, fallbacks)
- ✅ Debug logging for development
- ✅ Type-safe null handling
- ✅ Clean separation of concerns

### Code Quality
- ✅ All files pass Flutter analyzer with no issues
- ✅ Follows Dart style guide
- ✅ Comprehensive inline documentation
- ✅ Example usage in doc comments
- ✅ Error handling with graceful degradation

## Future Integration

### Supabase Backend

When ready to integrate with Supabase, follow this pattern:

```dart
// 1. Create repository
class CategoryBannerRepository {
  final SupabaseClient client;

  Future<List<CategoryBanner>> fetchActiveBanners() async {
    final response = await client
      .from('category_banners')
      .select()
      .eq('is_active', true)
      .order('display_order');

    return (response as List)
      .map((json) => CategoryBanner.fromJson(json))
      .toList();
  }
}

// 2. Update provider to use repository
Future<List<CategoryBanner>> _fetchBanners() async {
  final repository = ref.read(categoryBannerRepositoryProvider);

  if (repository == null) {
    return MockBannerData.getAllBanners();
  }

  try {
    return await repository.fetchActiveBanners();
  } catch (e) {
    // Fallback to mock data
    return MockBannerData.getAllBanners();
  }
}
```

### Database Schema

Suggested Supabase table structure:

```sql
CREATE TABLE category_banners (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category_id VARCHAR(50) NOT NULL,
  title VARCHAR(100) NOT NULL,
  subtitle VARCHAR(200) NOT NULL,
  image_url TEXT NOT NULL,
  background_color VARCHAR(7) NOT NULL,
  action_url TEXT NOT NULL,
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_category_banners_category ON category_banners(category_id);
CREATE INDEX idx_category_banners_active ON category_banners(is_active);
```

## Testing

### Unit Tests (Suggested)

```dart
void main() {
  group('CategoryBanner', () {
    test('fromJson creates valid instance', () {
      final json = {
        'id': 'test-1',
        'category_id': 'popular',
        'title': 'Test Banner',
        // ... other fields
      };

      final banner = CategoryBanner.fromJson(json);
      expect(banner.id, 'test-1');
      expect(banner.categoryId, 'popular');
    });

    test('getBackgroundColor parses hex correctly', () {
      final banner = CategoryBanner(
        // ... fields
        backgroundColor: '#2196F3',
      );

      final color = banner.getBackgroundColor();
      expect(color.value, 0xFF2196F3);
    });
  });
}
```

## Files Created

### Production Code
1. `/apps/pickly_mobile/lib/features/benefits/models/category_banner.dart` (5,059 bytes)
2. `/apps/pickly_mobile/lib/features/benefits/providers/category_banner_provider.dart` (7,009 bytes)
3. `/apps/pickly_mobile/lib/features/benefits/providers/mock_banner_data.dart` (9,416 bytes)

### Documentation
4. `/apps/pickly_mobile/lib/features/benefits/examples/banner_usage_example.dart` (7+ examples)
5. `/docs/category-banner-implementation.md` (this file)

## Summary

✅ **Complete Implementation**
- Fully functional data model with JSON serialization
- Comprehensive Riverpod provider system
- Rich mock data across 6 categories (16 banners)
- 7 detailed usage examples
- Production-ready code quality

✅ **Project Consistency**
- Follows existing patterns from AgeCategory/Region models
- Uses same provider structure as other features
- No additional dependencies required
- Consistent code style and documentation

✅ **Developer Experience**
- Clear documentation with examples
- Easy to integrate into existing screens
- Simple API with multiple convenience providers
- Ready for future Supabase integration

The category banner system is now ready to be integrated into the benefits screens!
