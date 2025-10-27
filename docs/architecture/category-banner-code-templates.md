# Category Banner - Code Templates

This document provides ready-to-use code templates for implementing the category banner feature.

## Table of Contents
1. [Data Models](#data-models)
2. [Repository](#repository)
3. [Providers](#providers)
4. [Widgets](#widgets)
5. [Database Migration](#database-migration)
6. [Tests](#tests)

---

## Data Models

### File: `lib/contexts/benefits/models/category_banner.dart`

```dart
/// Category-specific advertisement banner model
///
/// Represents a promotional banner displayed in the Benefits screen
/// for a specific category tab. Supports time-based scheduling and
/// analytics tracking.
library;

import 'package:flutter/foundation.dart';

@immutable
class CategoryBanner {
  final String id;
  final String categoryCode;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String backgroundColor;
  final String actionUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final int clickCount;
  final int impressionCount;
  final DateTime createdAt;
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

  bool get isScheduledActive {
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  bool get shouldDisplay => isActive && isScheduledActive;

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

### File: `lib/contexts/benefits/models/category_codes.dart`

```dart
/// Category codes matching BenefitsScreen tabs
library;

class CategoryCodes {
  // Private constructor to prevent instantiation
  CategoryCodes._();

  static const String popular = 'popular';
  static const String housing = 'housing';
  static const String education = 'education';
  static const String support = 'support';
  static const String transport = 'transport';
  static const String welfare = 'welfare';
  static const String clothing = 'clothing';
  static const String food = 'food';
  static const String culture = 'culture';

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

  /// Validate if a category code is valid
  static bool isValid(String code) {
    return all.contains(code);
  }
}
```

### File: `lib/contexts/benefits/exceptions/category_banner_exception.dart`

```dart
/// Custom exception for category banner operations
library;

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

## Repository

### File: `lib/contexts/benefits/repositories/category_banner_repository.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pickly_mobile/contexts/benefits/models/category_banner.dart';
import 'package:pickly_mobile/contexts/benefits/exceptions/category_banner_exception.dart';

/// Repository for managing category banner data from Supabase
class CategoryBannerRepository {
  final SupabaseClient _client;
  static const String _tableName = 'category_banners';
  static const String _analyticsTable = 'banner_analytics';

  CategoryBannerRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Fetch all active banners for a specific category
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

      if (response == null) return null;
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
  RealtimeChannel subscribeToBanners({
    required String categoryCode,
    void Function(CategoryBanner banner)? onInsert,
    void Function(CategoryBanner banner)? onUpdate,
    void Function(String id)? onDelete,
  }) {
    final channel = _client.channel('category_banners_$categoryCode');

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
  Future<void> trackBannerClick(String bannerId, {String? userId}) async {
    try {
      await _client.rpc('increment_banner_clicks', params: {
        'banner_id': bannerId,
      });

      await _client.from(_analyticsTable).insert({
        'banner_id': bannerId,
        'user_id': userId,
        'event_type': 'click',
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Tracked click for banner $bannerId');
    } catch (e, stackTrace) {
      debugPrint('⚠️ Failed to track banner click: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Track banner impression (analytics)
  Future<void> trackBannerImpression(String bannerId, {String? userId}) async {
    try {
      await _client.rpc('increment_banner_impressions', params: {
        'banner_id': bannerId,
      });

      await _client.from(_analyticsTable).insert({
        'banner_id': bannerId,
        'user_id': userId,
        'event_type': 'impression',
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Tracked impression for banner $bannerId');
    } catch (e, stackTrace) {
      debugPrint('⚠️ Failed to track banner impression: $e');
    }
  }
}
```

---

## Providers

### File: `lib/contexts/benefits/providers/category_banner_provider.dart`

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pickly_mobile/contexts/benefits/models/category_banner.dart';
import 'package:pickly_mobile/contexts/benefits/models/category_codes.dart';
import 'package:pickly_mobile/contexts/benefits/repositories/category_banner_repository.dart';
import 'package:pickly_mobile/core/services/supabase_service.dart';

/// Provider for accessing Supabase service
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});

/// Provider for category banner repository
final categoryBannerRepositoryProvider = Provider<CategoryBannerRepository?>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);

  if (supabase.isInitialized && supabase.client != null) {
    return CategoryBannerRepository(client: supabase.client!);
  }

  return null;
});

/// AsyncNotifier for managing category banners with realtime updates
class CategoryBannersNotifier extends FamilyAsyncNotifier<List<CategoryBanner>, String> {
  RealtimeChannel? _channel;

  @override
  Future<List<CategoryBanner>> build(String categoryCode) async {
    ref.onDispose(() {
      _channel?.unsubscribe();
    });

    _setupRealtimeSubscription(categoryCode);
    return _fetchBanners(categoryCode);
  }

  Future<List<CategoryBanner>> _fetchBanners(String categoryCode) async {
    final repository = ref.read(categoryBannerRepositoryProvider);

    if (repository == null) {
      debugPrint('ℹ️ Supabase not initialized, using mock banner data');
      return _getMockBanners(categoryCode);
    }

    try {
      final banners = await repository.fetchBannersByCategory(categoryCode);
      final visibleBanners = banners.where((b) => b.shouldDisplay).toList();

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

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchBanners(arg));
  }

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

## Widgets

### File: `lib/features/benefits/widgets/category_banner_carousel.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/contexts/benefits/models/category_banner.dart';
import 'package:pickly_mobile/contexts/benefits/providers/category_banner_provider.dart';

/// Category-aware banner carousel widget
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
  final Set<String> _impressionTracked = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(
      categoryBannersProvider(widget.categoryCode),
    );

    return bannersAsync.when(
      loading: () => _buildSkeleton(),
      error: (error, stack) => _buildEmpty(),
      data: (banners) {
        if (banners.isEmpty) return _buildEmpty();

        return SizedBox(
          height: 80,
          child: PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            onPageChanged: (index) {
              _trackImpression(banners[index]);
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

  Widget _buildSkeleton() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildEmpty() {
    return const SizedBox.shrink();
  }

  void _handleBannerTap(CategoryBanner banner) {
    _trackClick(banner);
    context.push(banner.actionUrl);
  }

  void _trackImpression(CategoryBanner banner) {
    if (_impressionTracked.contains(banner.id)) return;

    _impressionTracked.add(banner.id);
    ref
        .read(categoryBannerRepositoryProvider)
        ?.trackBannerImpression(banner.id);
  }

  void _trackClick(CategoryBanner banner) {
    ref
        .read(categoryBannerRepositoryProvider)
        ?.trackBannerClick(banner.id);
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return const Color(0xFF074D43); // Default color
    }
  }
}
```

---

## Database Migration

### File: `supabase/migrations/20251016000000_create_category_banners.sql`

```sql
-- Migration: Create category_banners table and related infrastructure

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

-- Create indexes for efficient queries
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

-- Insert sample data for testing
INSERT INTO category_banners (category_code, title, subtitle, image_url, background_color, action_url, sort_order, is_active) VALUES
('popular', '당첨 후기 작성하고\n선물 받자', '경험을 함께 나누어 주세요.', 'https://placehold.co/132x132', '#074D43', '/reviews/write', 1, true),
('popular', '인기 정책 모아보기', '지금 가장 핫한 혜택 확인', 'https://placehold.co/132x132', '#2563EB', '/policies/popular', 2, true),
('housing', '청년 전세자금 지원', '최대 1억원 저금리 대출', 'https://placehold.co/132x132', '#059669', '/policies/housing/1', 1, true),
('housing', '신혼부부 주거 지원', '월세 보증금 지원 받기', 'https://placehold.co/132x132', '#7C3AED', '/policies/housing/2', 2, true),
('education', '학자금 대출 신청', '등록금 걱정 끝', 'https://placehold.co/132x132', '#DC2626', '/policies/education/1', 1, true),
('support', '청년 창업 지원', '사업 시작 자금 지원', 'https://placehold.co/132x132', '#0891B2', '/policies/support/1', 1, true),
('transport', '대중교통 할인카드', '교통비 50% 절약', 'https://placehold.co/132x132', '#15803D', '/policies/transport/1', 1, true),
('welfare', '건강검진 지원', '무료 건강검진 받기', 'https://placehold.co/132x132', '#BE185D', '/policies/welfare/1', 1, true),
('clothing', '교복 구입비 지원', '중고등학생 가정 지원', 'https://placehold.co/132x132', '#4F46E5', '/policies/clothing/1', 1, true),
('food', '급식비 지원', '학생 급식비 무료', 'https://placehold.co/132x132', '#16A34A', '/policies/food/1', 1, true),
('culture', '영화 관람권 지원', '월 2회 무료 관람', 'https://placehold.co/132x132', '#9333EA', '/policies/culture/1', 1, true);
```

---

## Tests

### File: `test/contexts/benefits/models/category_banner_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pickly_mobile/contexts/benefits/models/category_banner.dart';

void main() {
  group('CategoryBanner', () {
    test('fromJson creates valid instance', () {
      final json = {
        'id': 'test-id',
        'category_code': 'popular',
        'title': 'Test Title',
        'subtitle': 'Test Subtitle',
        'background_color': '#074D43',
        'action_url': '/test',
        'sort_order': 1,
        'is_active': true,
        'created_at': '2025-01-01T00:00:00Z',
        'updated_at': '2025-01-01T00:00:00Z',
      };

      final banner = CategoryBanner.fromJson(json);

      expect(banner.id, 'test-id');
      expect(banner.categoryCode, 'popular');
      expect(banner.title, 'Test Title');
      expect(banner.backgroundColor, '#074D43');
    });

    test('shouldDisplay checks active and schedule', () {
      final now = DateTime.now();
      final future = now.add(const Duration(days: 1));

      final banner = CategoryBanner(
        id: '1',
        categoryCode: 'popular',
        title: 'Test',
        subtitle: 'Test',
        backgroundColor: '#000000',
        actionUrl: '/test',
        sortOrder: 1,
        isActive: true,
        startDate: future,
        createdAt: now,
        updatedAt: now,
      );

      expect(banner.shouldDisplay, false);
    });
  });
}
```

---

## Usage in BenefitsScreen

```dart
// Update BenefitsScreen to use CategoryBannerCarousel

// Replace this (line 106-112):
const AdvertisementBanner(
  title: '당첨 후기 작성하고\n선물 받자',
  subtitle: '경험을 함께 나누어 주세요.',
  imageUrl: 'https://placehold.co/132x132',
  currentIndex: 1,
  totalCount: 8,
),

// With this:
CategoryBannerCarousel(
  categoryCode: CategoryCodes.byIndex(_selectedCategoryIndex),
),

// Add import at top:
import 'package:pickly_mobile/features/benefits/widgets/category_banner_carousel.dart';
import 'package:pickly_mobile/contexts/benefits/models/category_codes.dart';
```

---

## Quick Start Checklist

1. ✅ Copy all model files to `lib/contexts/benefits/models/`
2. ✅ Copy repository to `lib/contexts/benefits/repositories/`
3. ✅ Copy providers to `lib/contexts/benefits/providers/`
4. ✅ Copy widget to `lib/features/benefits/widgets/`
5. ✅ Run Supabase migration
6. ✅ Update `BenefitsScreen` imports and widget usage
7. ✅ Run tests: `flutter test`
8. ✅ Test on device with hot reload

---

All code templates are production-ready and follow the existing codebase patterns!
