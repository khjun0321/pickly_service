# Category-Specific Advertisement Banner Architecture

## Document Information
- **Version**: 1.0.0
- **Created**: 2025-10-16
- **Status**: Design Proposal
- **Target Feature**: Category-specific advertisement banners in Benefits screen

## Table of Contents
1. [Overview](#overview)
2. [Architecture Diagram](#architecture-diagram)
3. [Data Model](#data-model)
4. [State Management](#state-management)
5. [Repository Layer](#repository-layer)
6. [File Structure](#file-structure)
7. [Implementation Phases](#implementation-phases)
8. [API Specifications](#api-specifications)
9. [Migration Strategy](#migration-strategy)

---

## Overview

### Problem Statement
Currently, the `BenefitsScreen` displays a hardcoded advertisement banner that is the same across all 9 category tabs (인기, 주거, 교육, 지원, 교통, 복지, 의류, 식품, 문화). We need a scalable solution that:

- Displays different banners for each category
- Supports multiple banners per category with pagination
- Allows backend management through admin panel (백오피스)
- Provides seamless integration with Supabase
- Follows Flutter best practices (Riverpod + Repository pattern)

### Solution Approach
Implement a **three-layer architecture**:
1. **Data Layer**: Supabase database with `category_banners` table
2. **Domain Layer**: Repository pattern with Riverpod state management
3. **Presentation Layer**: Category-aware banner carousel widget

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                        │
│                                                                   │
│  ┌──────────────────┐         ┌─────────────────────────────┐  │
│  │ BenefitsScreen   │────────>│ CategoryBannerCarousel      │  │
│  │ (Tab Controller) │         │ (Widget)                    │  │
│  └──────────────────┘         └─────────────────────────────┘  │
│           │                              │                       │
│           │                              │ ref.watch()          │
│           ▼                              ▼                       │
└───────────────────────────────────────────────────────────────────┘
            │                              │
            │                              │
┌───────────────────────────────────────────────────────────────────┐
│                         DOMAIN LAYER                              │
│                    (Riverpod State Management)                    │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  categoryBannersProvider                                │    │
│  │  - FamilyAsyncNotifier<List<CategoryBanner>, String>   │    │
│  │  - Fetches banners by category code                     │    │
│  │  - Caches data automatically                            │    │
│  │  - Supports realtime updates                            │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                    │
│                              │ uses                              │
│                              ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  categoryBannerRepositoryProvider                       │    │
│  │  - Provider<CategoryBannerRepository?>                  │    │
│  │  - Null if Supabase not initialized                     │    │
│  │  - Mock data fallback support                           │    │
│  └─────────────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────────────┘
                              │
                              │ queries
                              ▼
┌───────────────────────────────────────────────────────────────────┐
│                          DATA LAYER                               │
│                      (Supabase + Repository)                      │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  CategoryBannerRepository                               │    │
│  │  + fetchBannersByCategory(categoryCode)                 │    │
│  │  + fetchActiveBanners()                                 │    │
│  │  + subscribeToBanners(categoryCode)                     │    │
│  │  + trackBannerClick(bannerId)                           │    │
│  │  + trackBannerImpression(bannerId)                      │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                    │
│                              │ CRUD operations                    │
│                              ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Supabase Database                                      │    │
│  │  Table: category_banners                                │    │
│  │  - id (uuid, PK)                                        │    │
│  │  - category_code (text)                                 │    │
│  │  - title (text)                                         │    │
│  │  - subtitle (text)                                      │    │
│  │  - image_url (text)                                     │    │
│  │  - background_color (text)                              │    │
│  │  - action_url (text)                                    │    │
│  │  - sort_order (integer)                                 │    │
│  │  - is_active (boolean)                                  │    │
│  │  - start_date, end_date (timestamptz)                   │    │
│  │  - created_at, updated_at (timestamptz)                 │    │
│  └─────────────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────────────┘
```

### Component Interaction Flow

```
User Action Flow:
1. User selects category tab → Updates selectedCategoryIndex state
2. BenefitsScreen passes categoryCode to CategoryBannerCarousel
3. CategoryBannerCarousel watches categoryBannersProvider(categoryCode)
4. Provider checks cache → Cache miss triggers repository fetch
5. Repository queries Supabase with category filter
6. Banners returned → State updated → UI rebuilds with carousel
7. User swipes banner → PageController updates current index
8. User taps banner → Track click analytics → Navigate to action_url

Realtime Update Flow:
1. Admin updates banner in 백오피스 (Supabase Dashboard/Custom Admin)
2. Supabase triggers realtime event
3. Repository subscription receives event
4. Provider auto-refreshes data
5. UI rebuilds with updated banners (seamless)
```

---

## Data Model

### Primary Model: CategoryBanner

```dart
/// Category-specific advertisement banner model
///
/// Represents a promotional banner displayed in the Benefits screen
/// for a specific category tab. Supports time-based scheduling and
/// analytics tracking.
@immutable
class CategoryBanner {
  /// Unique identifier (UUID from Supabase)
  final String id;

  /// Category code (e.g., 'popular', 'housing', 'education')
  /// Maps to category tabs in BenefitsScreen
  final String categoryCode;

  /// Main banner title (supports multi-line with \n)
  final String title;

  /// Subtitle text (additional context)
  final String subtitle;

  /// Image URL for banner background/decoration
  /// Optional - can use solid color only
  final String? imageUrl;

  /// Background color in hex format (e.g., '#074D43')
  /// Defaults to dark green if not specified
  final String backgroundColor;

  /// Deep link or external URL for banner tap action
  /// Examples: '/policy/123', 'https://example.com'
  final String actionUrl;

  /// Display order within category (ascending)
  final int sortOrder;

  /// Whether banner is currently active and visible
  final bool isActive;

  /// Optional scheduled start date (null = immediate)
  final DateTime? startDate;

  /// Optional scheduled end date (null = no expiration)
  final DateTime? endDate;

  /// Analytics: Click count (readonly from API)
  final int clickCount;

  /// Analytics: Impression count (readonly from API)
  final int impressionCount;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  const CategoryBanner({
    required this.id,
    required this.categoryCode,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.backgroundColor,
    required this.actionUrl,
    required this.sortOrder,
    required this.isActive,
    this.startDate,
    this.endDate,
    this.clickCount = 0,
    this.impressionCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor from Supabase JSON
  factory CategoryBanner.fromJson(Map<String, dynamic> json) {
    return CategoryBanner(
      id: json['id'] as String,
      categoryCode: json['category_code'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['image_url'] as String?,
      backgroundColor: json['background_color'] as String? ?? '#074D43',
      actionUrl: json['action_url'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      clickCount: json['click_count'] as int? ?? 0,
      impressionCount: json['impression_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase operations
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_code': categoryCode,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'background_color': backgroundColor,
      'action_url': actionUrl,
      'sort_order': sortOrder,
      'is_active': isActive,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'click_count': clickCount,
      'impression_count': impressionCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if banner is currently within scheduled period
  bool get isScheduledActive {
    final now = DateTime.now();

    // Check start date
    if (startDate != null && now.isBefore(startDate!)) {
      return false;
    }

    // Check end date
    if (endDate != null && now.isAfter(endDate!)) {
      return false;
    }

    return true;
  }

  /// Check if banner should be displayed (active + scheduled)
  bool get shouldDisplay => isActive && isScheduledActive;

  /// Create a copy with optional field overrides
  CategoryBanner copyWith({
    String? id,
    String? categoryCode,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? backgroundColor,
    String? actionUrl,
    int? sortOrder,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    int? clickCount,
    int? impressionCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryBanner(
      id: id ?? this.id,
      categoryCode: categoryCode ?? this.categoryCode,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      actionUrl: actionUrl ?? this.actionUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      clickCount: clickCount ?? this.clickCount,
      impressionCount: impressionCount ?? this.impressionCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryBanner && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CategoryBanner(id: $id, categoryCode: $categoryCode, '
        'title: $title, isActive: $isActive, shouldDisplay: $shouldDisplay)';
  }
}
```

### Category Code Constants

```dart
/// Category codes matching BenefitsScreen tabs
class CategoryCodes {
  static const String popular = 'popular';      // 인기
  static const String housing = 'housing';      // 주거
  static const String education = 'education';  // 교육
  static const String support = 'support';      // 지원
  static const String transport = 'transport';  // 교통
  static const String welfare = 'welfare';      // 복지
  static const String clothing = 'clothing';    // 의류
  static const String food = 'food';            // 식품
  static const String culture = 'culture';      // 문화

  /// All category codes
  static const List<String> all = [
    popular,
    housing,
    education,
    support,
    transport,
    welfare,
    clothing,
    food,
    culture,
  ];

  /// Get category code by index (matches BenefitsScreen tab order)
  static String byIndex(int index) {
    if (index < 0 || index >= all.length) {
      return popular; // Default fallback
    }
    return all[index];
  }

  /// Get display name for category code
  static String displayName(String code) {
    const names = {
      popular: '인기',
      housing: '주거',
      education: '교육',
      support: '지원',
      transport: '교통',
      welfare: '복지',
      clothing: '의류',
      food: '식품',
      culture: '문화',
    };
    return names[code] ?? code;
  }
}
```

---

## State Management

### Provider Architecture (Riverpod)

```dart
/// Provider for category banner repository
///
/// Returns null if Supabase is not initialized
/// (allows graceful fallback to mock data)
final categoryBannerRepositoryProvider = Provider<CategoryBannerRepository?>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);

  if (supabase.isInitialized && supabase.client != null) {
    return CategoryBannerRepository(client: supabase.client!);
  }

  return null;
});

/// AsyncNotifier for managing category banners with realtime updates
///
/// Automatically fetches banners for a specific category and subscribes
/// to realtime updates from Supabase.
class CategoryBannersNotifier extends FamilyAsyncNotifier<List<CategoryBanner>, String> {
  RealtimeChannel? _channel;

  @override
  Future<List<CategoryBanner>> build(String categoryCode) async {
    // Clean up channel when provider is disposed
    ref.onDispose(() {
      _channel?.unsubscribe();
    });

    // Setup realtime subscription
    _setupRealtimeSubscription(categoryCode);

    // Fetch initial data
    return _fetchBanners(categoryCode);
  }

  /// Fetch banners from repository or use mock data
  Future<List<CategoryBanner>> _fetchBanners(String categoryCode) async {
    final repository = ref.read(categoryBannerRepositoryProvider);

    // Fallback to mock data if Supabase not available
    if (repository == null) {
      debugPrint('ℹ️ Supabase not initialized, using mock banner data');
      return _getMockBanners(categoryCode);
    }

    try {
      final banners = await repository.fetchBannersByCategory(categoryCode);

      // Filter to only show banners that should be displayed
      final visibleBanners = banners
          .where((banner) => banner.shouldDisplay)
          .toList();

      if (visibleBanners.isEmpty) {
        debugPrint('⚠️ No active banners for $categoryCode, using mock data');
        return _getMockBanners(categoryCode);
      }

      debugPrint('✅ Loaded ${visibleBanners.length} banners for $categoryCode');
      return visibleBanners;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching banners for $categoryCode: $e');
      debugPrint('Stack trace: $stackTrace');
      return _getMockBanners(categoryCode);
    }
  }

  /// Setup realtime subscription for banner updates
  void _setupRealtimeSubscription(String categoryCode) {
    final repository = ref.read(categoryBannerRepositoryProvider);

    if (repository == null) {
      debugPrint('ℹ️ Skipping realtime subscription - Supabase not initialized');
      return;
    }

    try {
      _channel = repository.subscribeToBanners(
        categoryCode: categoryCode,
        onInsert: (banner) {
          debugPrint('🔔 Realtime INSERT: Banner ${banner.id} for $categoryCode');
          refresh();
        },
        onUpdate: (banner) {
          debugPrint('🔔 Realtime UPDATE: Banner ${banner.id} for $categoryCode');
          refresh();
        },
        onDelete: (id) {
          debugPrint('🔔 Realtime DELETE: Banner $id for $categoryCode');
          refresh();
        },
      );
      debugPrint('✅ Realtime subscription established for $categoryCode banners');
    } catch (e, stackTrace) {
      debugPrint('⚠️ Failed to setup realtime subscription: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Manually refresh banners
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchBanners(arg));
  }

  /// Mock banners for offline/development mode
  List<CategoryBanner> _getMockBanners(String categoryCode) {
    final now = DateTime.now();
    return [
      CategoryBanner(
        id: 'mock-${categoryCode}-1',
        categoryCode: categoryCode,
        title: '${CategoryCodes.displayName(categoryCode)} 혜택 확인하고\n선물 받자',
        subtitle: '지금 바로 확인해보세요.',
        imageUrl: 'https://placehold.co/132x132',
        backgroundColor: '#074D43',
        actionUrl: '/benefits/$categoryCode/detail',
        sortOrder: 1,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryBanner(
        id: 'mock-${categoryCode}-2',
        categoryCode: categoryCode,
        title: '당첨 후기 작성하고\n포인트 받자',
        subtitle: '경험을 함께 나누어 주세요.',
        imageUrl: 'https://placehold.co/132x132',
        backgroundColor: '#2563EB',
        actionUrl: '/reviews/write',
        sortOrder: 2,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}

/// Provider for category banners (family)
final categoryBannersProvider = AsyncNotifierProvider.family<
  CategoryBannersNotifier,
  List<CategoryBanner>,
  String
>(CategoryBannersNotifier.new);

/// Convenience provider to get banners as simple list
final categoryBannersListProvider = Provider.family<List<CategoryBanner>, String>(
  (ref, categoryCode) {
    final asyncBanners = ref.watch(categoryBannersProvider(categoryCode));
    return asyncBanners.maybeWhen(
      data: (banners) => banners,
      orElse: () => [],
    );
  },
);

/// Provider to track current banner index for a category
final categoryBannerIndexProvider = StateProvider.family<int, String>(
  (ref, categoryCode) => 0,
);
```

---

## Repository Layer

### CategoryBannerRepository

```dart
/// Repository for managing category banner data from Supabase
///
/// Handles:
/// - Fetching banners by category
/// - Fetching all active banners
/// - Realtime subscriptions for banner updates
/// - Analytics tracking (clicks, impressions)
class CategoryBannerRepository {
  final SupabaseClient _client;
  static const String _tableName = 'category_banners';
  static const String _analyticsTable = 'banner_analytics';

  CategoryBannerRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Fetch all active banners for a specific category
  ///
  /// Returns banners ordered by sort_order (ascending)
  /// Only returns banners where is_active = true
  Future<List<CategoryBanner>> fetchBannersByCategory(String categoryCode) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('category_code', categoryCode)
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => CategoryBanner.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw CategoryBannerException(
        'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e, stackTrace) {
      throw CategoryBannerException(
        'Failed to fetch category banners: $e',
        stackTrace: stackTrace,
      );
    }
  }

  /// Fetch all active banners across all categories
  ///
  /// Useful for pre-caching or admin views
  Future<List<CategoryBanner>> fetchAllActiveBanners() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('is_active', true)
          .order('category_code', ascending: true)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((json) => CategoryBanner.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw CategoryBannerException(
        'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e, stackTrace) {
      throw CategoryBannerException(
        'Failed to fetch all banners: $e',
        stackTrace: stackTrace,
      );
    }
  }

  /// Fetch a single banner by ID
  Future<CategoryBanner?> fetchBannerById(String id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return CategoryBanner.fromJson(response);
    } on PostgrestException catch (e) {
      throw CategoryBannerException(
        'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e, stackTrace) {
      throw CategoryBannerException(
        'Failed to fetch banner: $e',
        stackTrace: stackTrace,
      );
    }
  }

  /// Subscribe to realtime changes for a specific category
  ///
  /// Returns a RealtimeChannel for managing the subscription
  RealtimeChannel subscribeToBanners({
    required String categoryCode,
    void Function(CategoryBanner banner)? onInsert,
    void Function(CategoryBanner banner)? onUpdate,
    void Function(String id)? onDelete,
  }) {
    final channel = _client.channel('category_banners_$categoryCode');

    // Filter to only receive events for this category
    final filter = 'category_code=eq.$categoryCode';

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: _tableName,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'category_code',
        value: categoryCode,
      ),
      callback: (payload) {
        if (onInsert != null) {
          try {
            final banner = CategoryBanner.fromJson(
              payload.newRecord as Map<String, dynamic>,
            );
            onInsert(banner);
          } catch (e) {
            debugPrint('Error processing insert event: $e');
          }
        }
      },
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: _tableName,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'category_code',
        value: categoryCode,
      ),
      callback: (payload) {
        if (onUpdate != null) {
          try {
            final banner = CategoryBanner.fromJson(
              payload.newRecord as Map<String, dynamic>,
            );
            onUpdate(banner);
          } catch (e) {
            debugPrint('Error processing update event: $e');
          }
        }
      },
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.delete,
      schema: 'public',
      table: _tableName,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'category_code',
        value: categoryCode,
      ),
      callback: (payload) {
        if (onDelete != null) {
          final id = payload.oldRecord['id'] as String?;
          if (id != null) {
            onDelete(id);
          }
        }
      },
    );

    channel.subscribe();
    return channel;
  }

  /// Track banner click (analytics)
  ///
  /// Increments click_count and records event in analytics table
  Future<void> trackBannerClick(String bannerId, {String? userId}) async {
    try {
      // Increment click count
      await _client.rpc('increment_banner_clicks', params: {
        'banner_id': bannerId,
      });

      // Record detailed analytics event
      await _client.from(_analyticsTable).insert({
        'banner_id': bannerId,
        'user_id': userId,
        'event_type': 'click',
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Tracked click for banner $bannerId');
    } catch (e, stackTrace) {
      // Don't throw - analytics failure shouldn't break UX
      debugPrint('⚠️ Failed to track banner click: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Track banner impression (analytics)
  ///
  /// Increments impression_count when banner is displayed
  Future<void> trackBannerImpression(String bannerId, {String? userId}) async {
    try {
      // Increment impression count
      await _client.rpc('increment_banner_impressions', params: {
        'banner_id': bannerId,
      });

      // Record detailed analytics event
      await _client.from(_analyticsTable).insert({
        'banner_id': bannerId,
        'user_id': userId,
        'event_type': 'impression',
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Tracked impression for banner $bannerId');
    } catch (e, stackTrace) {
      // Don't throw - analytics failure shouldn't break UX
      debugPrint('⚠️ Failed to track banner impression: $e');
    }
  }
}
```

### Exception Handling

```dart
/// Custom exception for category banner operations
class CategoryBannerException implements Exception {
  final String message;
  final String? code;
  final String? details;
  final StackTrace? stackTrace;

  CategoryBannerException(
    this.message, {
    this.code,
    this.details,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('CategoryBannerException: $message');
    if (code != null) buffer.write(' (Code: $code)');
    if (details != null) buffer.write('\nDetails: $details');
    return buffer.toString();
  }
}
```

---

## File Structure

```
apps/pickly_mobile/lib/
├── contexts/
│   └── benefits/
│       ├── models/
│       │   ├── category_banner.dart              # CategoryBanner model
│       │   └── category_codes.dart               # Category code constants
│       ├── repositories/
│       │   └── category_banner_repository.dart   # Repository implementation
│       ├── providers/
│       │   └── category_banner_provider.dart     # Riverpod providers
│       └── exceptions/
│           └── category_banner_exception.dart    # Custom exception
│
├── features/
│   └── benefits/
│       ├── screens/
│       │   └── benefits_screen.dart              # Main screen (updated)
│       └── widgets/
│           ├── category_banner_carousel.dart     # New banner carousel widget
│           └── category_banner_card.dart         # Individual banner card
│
packages/pickly_design_system/lib/
└── widgets/
    └── banners/
        └── advertisement_banner.dart             # Base banner widget (reused)

supabase/
├── migrations/
│   └── 20251016000000_create_category_banners.sql
└── functions/
    ├── increment_banner_clicks.sql
    └── increment_banner_impressions.sql
```

### File Naming Conventions

1. **Models**: Singular noun, snake_case (`category_banner.dart`)
2. **Repositories**: Model name + `_repository.dart` suffix
3. **Providers**: Model name + `_provider.dart` suffix
4. **Widgets**: Feature name + `_widget_type.dart` (`category_banner_carousel.dart`)
5. **Exceptions**: Model name + `_exception.dart` suffix

---

## Implementation Phases

### Phase 1: Foundation (Week 1)
**Goal**: Set up data layer and basic infrastructure

**Tasks**:
1. Create Supabase migration for `category_banners` table
2. Create database functions for analytics tracking
3. Implement `CategoryBanner` model with tests
4. Implement `CategoryCodes` constants
5. Create `CategoryBannerException` class

**Deliverables**:
- [ ] Supabase migration file
- [ ] Model classes with comprehensive tests
- [ ] Database functions (RPC)

### Phase 2: Repository & State Management (Week 1-2)
**Goal**: Implement repository pattern and Riverpod providers

**Tasks**:
1. Implement `CategoryBannerRepository` with all methods
2. Write repository unit tests (mock Supabase client)
3. Implement Riverpod providers (`categoryBannersProvider`, etc.)
4. Add realtime subscription logic
5. Create mock data for offline mode

**Deliverables**:
- [ ] Repository implementation with tests
- [ ] Riverpod providers with proper lifecycle management
- [ ] Mock data fallback system

### Phase 3: UI Components (Week 2)
**Goal**: Build presentation layer widgets

**Tasks**:
1. Create `CategoryBannerCarousel` widget
2. Create `CategoryBannerCard` widget (wrapper for `AdvertisementBanner`)
3. Add PageView with indicator dots
4. Implement auto-swipe timer (optional)
5. Add analytics tracking on view/click

**Deliverables**:
- [ ] Carousel widget with smooth animations
- [ ] Banner card with tap handling
- [ ] Analytics integration

### Phase 4: Integration (Week 2)
**Goal**: Integrate banner system into BenefitsScreen

**Tasks**:
1. Update `BenefitsScreen` to use `CategoryBannerCarousel`
2. Pass category code based on selected tab
3. Handle loading/error states gracefully
4. Test all 9 categories
5. Performance optimization (caching, lazy loading)

**Deliverables**:
- [ ] Fully integrated banner system
- [ ] Smooth category switching
- [ ] Error handling UI

### Phase 5: Backend Admin (Week 3)
**Goal**: Enable backend management

**Tasks**:
1. Design admin UI mockups (백오피스)
2. Create Supabase policies for admin access
3. Build admin CRUD screens (can use Supabase dashboard initially)
4. Add banner scheduling controls
5. Add analytics dashboard

**Deliverables**:
- [ ] Admin panel for banner management
- [ ] Row-level security policies
- [ ] Analytics dashboard

### Phase 6: Testing & Optimization (Week 3)
**Goal**: Ensure quality and performance

**Tasks**:
1. Write widget tests for all components
2. Integration tests for banner flow
3. Performance profiling (minimize rebuilds)
4. Accessibility testing
5. Documentation updates

**Deliverables**:
- [ ] Comprehensive test suite (>85% coverage)
- [ ] Performance benchmarks
- [ ] Updated documentation

---

## API Specifications

### Supabase Database Schema

```sql
-- Migration: 20251016000000_create_category_banners.sql

-- Create category_banners table
CREATE TABLE IF NOT EXISTS category_banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_code TEXT NOT NULL,
  title TEXT NOT NULL,
  subtitle TEXT NOT NULL,
  image_url TEXT,
  background_color TEXT NOT NULL DEFAULT '#074D43',
  action_url TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  click_count INTEGER NOT NULL DEFAULT 0,
  impression_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index for efficient queries
CREATE INDEX idx_category_banners_category ON category_banners(category_code);
CREATE INDEX idx_category_banners_active ON category_banners(is_active);
CREATE INDEX idx_category_banners_sort ON category_banners(category_code, sort_order);

-- Create banner_analytics table
CREATE TABLE IF NOT EXISTS banner_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  banner_id UUID NOT NULL REFERENCES category_banners(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  event_type TEXT NOT NULL, -- 'click' or 'impression'
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_banner_analytics_banner ON banner_analytics(banner_id);
CREATE INDEX idx_banner_analytics_user ON banner_analytics(user_id);
CREATE INDEX idx_banner_analytics_created ON banner_analytics(created_at DESC);

-- Function to increment click count
CREATE OR REPLACE FUNCTION increment_banner_clicks(banner_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE category_banners
  SET click_count = click_count + 1,
      updated_at = NOW()
  WHERE id = banner_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to increment impression count
CREATE OR REPLACE FUNCTION increment_banner_impressions(banner_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE category_banners
  SET impression_count = impression_count + 1,
      updated_at = NOW()
  WHERE id = banner_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_category_banners_updated_at
BEFORE UPDATE ON category_banners
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) policies
ALTER TABLE category_banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE banner_analytics ENABLE ROW LEVEL SECURITY;

-- Public read access for active banners
CREATE POLICY "Public users can view active banners"
ON category_banners FOR SELECT
USING (is_active = true);

-- Admin full access (adjust based on your auth setup)
CREATE POLICY "Admins can manage banners"
ON category_banners
USING (auth.jwt() ->> 'role' = 'admin');

-- Users can insert their own analytics events
CREATE POLICY "Users can insert analytics"
ON banner_analytics FOR INSERT
WITH CHECK (true);

-- Admins can view all analytics
CREATE POLICY "Admins can view analytics"
ON banner_analytics FOR SELECT
USING (auth.jwt() ->> 'role' = 'admin');
```

### Sample Data (Seed)

```sql
-- Insert sample banners for each category
INSERT INTO category_banners (category_code, title, subtitle, image_url, background_color, action_url, sort_order, is_active) VALUES
-- Popular category (인기)
('popular', '당첨 후기 작성하고\n선물 받자', '경험을 함께 나누어 주세요.', 'https://placehold.co/132x132', '#074D43', '/reviews/write', 1, true),
('popular', '인기 정책 모아보기', '지금 가장 핫한 혜택 확인', 'https://placehold.co/132x132', '#2563EB', '/policies/popular', 2, true),

-- Housing category (주거)
('housing', '청년 전세자금 지원', '최대 1억원 저금리 대출', 'https://placehold.co/132x132', '#059669', '/policies/housing/1', 1, true),
('housing', '신혼부부 주거 지원', '월세 보증금 지원 받기', 'https://placehold.co/132x132', '#7C3AED', '/policies/housing/2', 2, true),

-- Education category (교육)
('education', '학자금 대출 신청', '등록금 걱정 끝', 'https://placehold.co/132x132', '#DC2626', '/policies/education/1', 1, true),
('education', '직업훈련 지원금', '배우면서 돈도 받자', 'https://placehold.co/132x132', '#EA580C', '/policies/education/2', 2, true),

-- Support category (지원)
('support', '청년 창업 지원', '사업 시작 자금 지원', 'https://placehold.co/132x132', '#0891B2', '/policies/support/1', 1, true),

-- Transport category (교통)
('transport', '대중교통 할인카드', '교통비 50% 절약', 'https://placehold.co/132x132', '#15803D', '/policies/transport/1', 1, true),

-- Welfare category (복지)
('welfare', '건강검진 지원', '무료 건강검진 받기', 'https://placehold.co/132x132', '#BE185D', '/policies/welfare/1', 1, true),

-- Clothing category (의류)
('clothing', '교복 구입비 지원', '중고등학생 가정 지원', 'https://placehold.co/132x132', '#4F46E5', '/policies/clothing/1', 1, true),

-- Food category (식품)
('food', '급식비 지원', '학생 급식비 무료', 'https://placehold.co/132x132', '#16A34A', '/policies/food/1', 1, true),

-- Culture category (문화)
('culture', '영화 관람권 지원', '월 2회 무료 관람', 'https://placehold.co/132x132', '#9333EA', '/policies/culture/1', 1, true);
```

---

## Migration Strategy

### From Current Implementation

**Current State**:
```dart
// BenefitsScreen - Line 106-112
const AdvertisementBanner(
  title: '당첨 후기 작성하고\n선물 받자',
  subtitle: '경험을 함께 나누어 주세요.',
  imageUrl: 'https://placehold.co/132x132',
  currentIndex: 1,
  totalCount: 8,
),
```

**Target State**:
```dart
// BenefitsScreen - Updated
CategoryBannerCarousel(
  categoryCode: CategoryCodes.byIndex(_selectedCategoryIndex),
),
```

### Migration Steps

1. **Phase 1**: Deploy database schema (no app changes)
   - Run Supabase migration
   - Populate sample data
   - Test database queries manually

2. **Phase 2**: Add repository layer (backend only)
   - Deploy repository code
   - Deploy providers
   - No UI changes yet (still using hardcoded banner)

3. **Phase 3**: Soft launch (feature flag)
   - Add `CategoryBannerCarousel` widget
   - Keep old banner as fallback
   - Use feature flag to enable for testing

4. **Phase 4**: Full rollout
   - Remove hardcoded banner
   - Enable dynamic banners for all users
   - Monitor analytics and performance

5. **Phase 5**: Optimization
   - Add caching layer
   - Optimize database queries
   - Fine-tune realtime subscriptions

---

## Architecture Decision Records (ADRs)

### ADR-001: Use Riverpod Family for Category-Based State

**Status**: Accepted

**Context**: Need to manage banner state for 9 different categories efficiently

**Decision**: Use `AsyncNotifierProvider.family` with category code as parameter

**Rationale**:
- Automatic caching per category
- Efficient state management (only fetch when needed)
- Clean disposal of unused providers
- Built-in loading/error states

**Consequences**:
- Slightly more complex provider setup
- Better performance (no unnecessary fetches)
- Cleaner code organization

### ADR-002: Fallback to Mock Data Instead of Error States

**Status**: Accepted

**Context**: Offline mode and Supabase initialization delays

**Decision**: Always show mock banners when Supabase unavailable

**Rationale**:
- Better user experience (no blank screens)
- Allows development without Supabase connection
- Graceful degradation

**Consequences**:
- Need to maintain mock data
- Potential confusion in development
- Need clear logging to distinguish mock vs real data

### ADR-003: Repository Pattern Over Direct Supabase Calls

**Status**: Accepted

**Context**: Need abstraction layer for data access

**Decision**: Implement repository pattern with interface

**Rationale**:
- Easier to test (can mock repository)
- Centralized error handling
- Potential for multiple data sources
- Follows existing codebase patterns

**Consequences**:
- More boilerplate code
- Better testability
- Consistent with RegionRepository pattern

### ADR-004: Analytics as Non-Blocking Background Tasks

**Status**: Accepted

**Context**: Need to track banner performance

**Decision**: Analytics calls never throw exceptions, fail silently

**Rationale**:
- Analytics failure shouldn't break UX
- Better user experience
- Reduced error noise

**Consequences**:
- Potential data loss on failures
- Need monitoring for analytics health
- Simpler error handling in UI

### ADR-005: Realtime Updates via Supabase Subscriptions

**Status**: Accepted

**Context**: Need fresh banner data without app restart

**Decision**: Use Supabase realtime subscriptions per category

**Rationale**:
- Instant updates when admin changes banners
- Better user experience
- Leverages Supabase built-in feature

**Consequences**:
- Increased websocket connections
- Need proper cleanup on dispose
- Potential performance impact with many categories

---

## Quality Attributes

### Performance
- **Target**: Banner load < 500ms on 4G connection
- **Strategy**: Aggressive caching, image optimization
- **Metrics**: Time to first banner paint

### Scalability
- **Target**: Support 100+ banners per category
- **Strategy**: Pagination, lazy loading
- **Metrics**: Database query time, memory usage

### Reliability
- **Target**: 99.9% uptime for banner service
- **Strategy**: Mock data fallback, error boundaries
- **Metrics**: Error rate, fallback activation rate

### Maintainability
- **Target**: Add new category in < 1 hour
- **Strategy**: Category code constants, consistent patterns
- **Metrics**: Lines of code changed, test coverage

### Security
- **Target**: Zero unauthorized banner modifications
- **Strategy**: RLS policies, admin-only write access
- **Metrics**: Failed auth attempts, policy violations

---

## Testing Strategy

### Unit Tests
```dart
// Test CategoryBanner model
test('CategoryBanner.shouldDisplay returns false when not scheduled', () {
  final banner = CategoryBanner(
    // ... fields
    startDate: DateTime.now().add(Duration(days: 1)),
  );
  expect(banner.shouldDisplay, false);
});

// Test repository
test('fetchBannersByCategory returns sorted banners', () async {
  final repository = CategoryBannerRepository(client: mockClient);
  final banners = await repository.fetchBannersByCategory('popular');
  expect(banners, isNotEmpty);
  expect(banners.first.sortOrder, lessThan(banners.last.sortOrder));
});
```

### Widget Tests
```dart
testWidgets('CategoryBannerCarousel displays banners', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        categoryBannersProvider('popular').overrideWith(
          (ref) => mockBanners,
        ),
      ],
      child: MaterialApp(
        home: CategoryBannerCarousel(categoryCode: 'popular'),
      ),
    ),
  );

  expect(find.text('당첨 후기 작성하고'), findsOneWidget);
});
```

### Integration Tests
```dart
testWidgets('Switching category updates banners', (tester) async {
  await tester.pumpWidget(MyApp());

  // Tap housing category
  await tester.tap(find.text('주거'));
  await tester.pumpAndSettle();

  // Verify housing banner appears
  expect(find.text('청년 전세자금 지원'), findsOneWidget);
});
```

---

## Monitoring & Analytics

### Key Metrics to Track

1. **Banner Performance**
   - Click-through rate (CTR) per category
   - Impression count per banner
   - Time to load banners

2. **User Behavior**
   - Category view distribution
   - Banner swipe rate
   - Action URL navigation rate

3. **Technical Health**
   - Repository error rate
   - Fallback activation rate
   - Realtime subscription failures
   - Database query latency

### Dashboard Queries

```sql
-- Banner CTR by category
SELECT
  cb.category_code,
  cb.title,
  cb.click_count,
  cb.impression_count,
  ROUND((cb.click_count::float / NULLIF(cb.impression_count, 0)) * 100, 2) as ctr_percent
FROM category_banners cb
WHERE cb.is_active = true
ORDER BY ctr_percent DESC;

-- Top performing banners (last 7 days)
SELECT
  cb.title,
  cb.category_code,
  COUNT(CASE WHEN ba.event_type = 'click' THEN 1 END) as clicks,
  COUNT(CASE WHEN ba.event_type = 'impression' THEN 1 END) as impressions
FROM category_banners cb
LEFT JOIN banner_analytics ba ON ba.banner_id = cb.id
WHERE ba.created_at > NOW() - INTERVAL '7 days'
GROUP BY cb.id, cb.title, cb.category_code
ORDER BY clicks DESC
LIMIT 10;
```

---

## Future Enhancements

### Phase 2 Features (Post-Launch)

1. **A/B Testing**
   - Variant support per banner
   - Automated winner selection
   - Statistical significance tracking

2. **Personalization**
   - User-specific banner recommendations
   - Behavioral targeting
   - ML-based relevance scoring

3. **Rich Media**
   - Video banners
   - Animated GIFs
   - Interactive elements

4. **Advanced Scheduling**
   - Recurring schedules (weekdays only, etc.)
   - Timezone-aware scheduling
   - Event-triggered banners

5. **Performance Optimization**
   - Image CDN integration
   - Prefetching adjacent categories
   - Service worker caching

---

## Appendix

### Category Code Mapping Table

| Index | Category Code | Display Name (KR) | Icon Path |
|-------|--------------|------------------|-----------|
| 0 | `popular` | 인기 | `assets/icons/fire.svg` |
| 1 | `housing` | 주거 | `assets/icons/home.svg` |
| 2 | `education` | 교육 | `assets/icons/school.svg` |
| 3 | `support` | 지원 | `assets/icons/dollar.svg` |
| 4 | `transport` | 교통 | `assets/icons/bus.svg` |
| 5 | `welfare` | 복지 | `assets/icons/happy_apt.svg` |
| 6 | `clothing` | 의류 | `assets/icons/shirts.svg` |
| 7 | `food` | 식품 | `assets/icons/rice.svg` |
| 8 | `culture` | 문화 | `assets/icons/speaker.svg` |

### Related Documentation

- [Component Structure Guide](/docs/architecture/component-structure-guide.md)
- [Supabase Integration Guide](/docs/supabase/integration-guide.md)
- [Riverpod Best Practices](/docs/state-management/riverpod-patterns.md)
- [Design System - Banner Components](/packages/pickly_design_system/docs/banners.md)

### Contact

For questions or clarifications about this architecture:
- Technical Lead: [Your Name]
- Product Owner: [Product Manager Name]
- Architecture Review: [Team Channel]

---

**Document Status**: ✅ Ready for Review
**Next Review Date**: 2025-10-23
**Approval Required From**: Tech Lead, Product Manager
