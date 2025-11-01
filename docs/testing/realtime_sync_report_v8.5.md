# Realtime Synchronization Validation Report (PRD v8.5)

## 📊 Executive Summary

- **검증 일시**: 2025-10-31
- **검증 방법**: 정적 코드 분석 (Static Code Analysis)
- **전체 평가**: 25% (Realtime 준비도)
- **상태**: ❌ **실시간 동기화 미구현** - 모든 테이블이 폴링(Polling) 방식 사용

## 🚨 Critical Finding

**Flutter 앱의 모든 데이터 소스가 Future 기반 폴링 방식으로 구현되어 있으며, Supabase Realtime 기능을 전혀 사용하지 않고 있습니다.**

- ✅ Supabase Realtime 활성화됨 (`config.toml`)
- ✅ RLS 정책 Public Read Access 설정됨
- ❌ **Repository에 Stream 메서드 없음** (Future만 존재)
- ❌ **Provider가 AsyncNotifier 사용** (StreamProvider 아님)
- ❌ **실시간 동기화 불가능**

## 🎯 검증 결과 요약

| 테이블 | Supabase Realtime | RLS Policy | Repository Stream | Provider Stream | UI AsyncValue | 실시간 동기화 | 종합 |
|--------|-------------------|------------|-------------------|-----------------|---------------|---------------|------|
| **announcements** | ✅ | ✅ | ❌ | ❌ | ⚠️ | ❌ | **25%** |
| **category_banners** | ✅ | ✅ | ❌ | ❌ | ⚠️ | ❌ | **25%** |
| **benefit_categories** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | **20%** |
| **age_categories** | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | **80%** |

### 평가 기준:
- ✅ **완료/지원**: 100% 구현
- ⚠️ **부분 지원**: AsyncValue 패턴은 있으나 Future 기반 (Stream 아님)
- ❌ **미지원**: 미구현 또는 잘못된 구현

---

## 📋 상세 검증 결과

### 1. announcements (공고)

#### ✅ Supabase Realtime 설정
**파일**: `/backend/supabase/config.toml`
```toml
[realtime]
enabled = true
```

**결과**: Realtime 기능 활성화됨

---

#### ✅ RLS Policy
**파일**: `/backend/supabase/migrations/20251027000001_correct_schema.sql`
```sql
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access" ON announcements FOR SELECT USING (status != 'draft');
```

**결과**: Public Read Access 정책 존재 (draft 제외한 모든 공고 읽기 가능)

---

#### ❌ Flutter Repository - Stream 메서드 없음

**파일**: `/apps/pickly_mobile/lib/features/benefits/repositories/announcement_repository.dart`

**현재 구현 (Future 기반)**:
```dart
class AnnouncementRepository {
  final SupabaseClient _supabase;

  // ❌ Future 메서드만 존재 (Stream 없음)
  Future<List<Announcement>> fetchAllAnnouncements({
    String? status,
    bool priorityOnly = false
  }) async {
    final response = await _supabase
        .from('announcements')
        .select('''...''')
        .order('is_priority', ascending: false);

    return (response as List)
        .map((json) => Announcement.fromJson(json))
        .toList();
  }
}
```

**문제점**:
- ❌ `.stream()` 메서드 사용 없음
- ❌ `.channel()` Realtime 구독 없음
- ❌ 단순 HTTP GET 요청만 수행 (일회성 폴링)

**필요한 구현**:
```dart
// ✅ 올바른 Realtime Stream 구현 예시
Stream<List<Announcement>> watchAnnouncements() {
  return _supabase
      .from('announcements')
      .stream(primaryKey: ['id'])
      .map((data) => data.map((json) => Announcement.fromJson(json)).toList());
}
```

---

#### ❌ Riverpod Provider - AsyncNotifier 사용 (StreamProvider 아님)

**파일**: `/apps/pickly_mobile/lib/features/benefits/providers/announcement_provider.dart`

**현재 구현**:
```dart
// ❌ AsyncNotifier (Future 기반, Stream 아님)
class AnnouncementNotifier extends AsyncNotifier<List<Announcement>> {
  @override
  Future<List<Announcement>> build() async {
    return _fetchAnnouncements();  // Future 반환
  }

  Future<List<Announcement>> _fetchAnnouncements() async {
    final repository = ref.read(announcementRepositoryProvider);
    final announcements = await repository.fetchAllAnnouncements();  // HTTP 요청
    return announcements;
  }
}

final announcementProvider = AsyncNotifierProvider<AnnouncementNotifier, List<Announcement>>(
  () => AnnouncementNotifier(),
);
```

**문제점**:
- ❌ `AsyncNotifier` 사용 (일회성 데이터 로드)
- ❌ `StreamProvider` 또는 `StreamNotifier` 사용 안 함
- ❌ Admin 수정 시 자동 갱신 불가능
- ⚠️ 수동 `refresh()` 호출 필요 (pull-to-refresh)

**필요한 구현**:
```dart
// ✅ 올바른 StreamProvider 구현
@riverpod
Stream<List<Announcement>> watchAnnouncements(WatchAnnouncementsRef ref) {
  return ref.watch(announcementRepositoryProvider).watchAnnouncements();
}
```

---

#### ⚠️ UI - AsyncValue 패턴 사용 (하지만 Future 기반)

**파일**: `/apps/pickly_mobile/lib/features/benefits/screens/benefits_screen.dart`

**현재 구현**:
```dart
final announcementsAsync = ref.watch(announcementProvider);  // AsyncValue<List<Announcement>>

announcementsAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => ErrorWidget(err),
  data: (announcements) => ListView.builder(...),
);
```

**상태**:
- ✅ `AsyncValue` 패턴 사용 (loading, error, data 처리)
- ⚠️ **하지만 Future 기반이므로 실시간 갱신 없음**
- ❌ Admin 수정 → Flutter UI 자동 반영 불가능
- ⚠️ 앱 재시작 또는 수동 refresh 시에만 갱신

---

#### 📊 예상 성능 (현재 구현)

**현재 구현 (Future 폴링 방식)**:
```
Admin 수정 (0ms)
  → Supabase DB Update (50-100ms)
  → ❌ Flutter는 변경사항 모름
  → ❌ 사용자가 수동으로 Pull-to-Refresh 필요
  → Repository Future 호출 (100-300ms)
  → UI Rebuild (16-33ms)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total: 수동 액션 필요 (실시간 동기화 불가능)
```

**평가**: ❌ **실시간 동기화 미지원**

---

#### 🚨 발견된 문제

**Critical**:
1. ❌ Repository에 Stream 메서드 없음
2. ❌ Provider가 AsyncNotifier 사용 (StreamProvider 필요)
3. ❌ 실시간 동기화 완전 불가능
4. ❌ Admin 수정사항이 앱에 자동으로 반영되지 않음

---

### 2. category_banners (카테고리 배너)

#### ✅ Supabase Realtime 설정
- Realtime 활성화: ✅

#### ✅ RLS Policy
**파일**: `/backend/supabase/migrations/20251027000001_correct_schema.sql`
```sql
ALTER TABLE category_banners ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access" ON category_banners FOR SELECT USING (is_active);
```

**결과**: Active 배너만 Public Read 가능

---

#### ❌ Flutter Repository - Stream 메서드 없음

**파일**: `/apps/pickly_mobile/lib/features/benefits/repositories/category_banner_repository.dart`

**현재 구현**:
```dart
class CategoryBannerRepository {
  final SupabaseClient _supabase;

  // ❌ Future 메서드만 존재
  Future<List<CategoryBanner>> fetchActiveBanners() async {
    final response = await _supabase
        .from('category_banners')
        .select('''...''')
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return (response as List)
        .map((json) => CategoryBanner(...))
        .toList();
  }
}
```

**문제점**:
- ❌ Stream 메서드 없음
- ❌ Realtime 구독 없음

---

#### ❌ Riverpod Provider - AsyncNotifier 사용

**파일**: `/apps/pickly_mobile/lib/features/benefits/providers/category_banner_provider.dart`

**현재 구현**:
```dart
class CategoryBannerNotifier extends AsyncNotifier<List<CategoryBanner>> {
  @override
  Future<List<CategoryBanner>> build() async {
    return _fetchBanners();  // Future 반환
  }

  Future<List<CategoryBanner>> _fetchBanners() async {
    final repository = ref.read(categoryBannerRepositoryProvider);
    final banners = await repository.fetchActiveBanners();  // Future
    return banners;
  } catch (e) {
    // Fallback to mock data
    return MockBannerData.getAllBanners();
  }
}
```

**문제점**:
- ❌ AsyncNotifier 사용 (Stream 아님)
- ⚠️ Mock data fallback 존재
- ❌ 실시간 동기화 불가능

---

#### ⚠️ UI - AsyncValue 사용 (Future 기반)

**파일**: `/apps/pickly_mobile/lib/features/benefits/screens/benefits_screen.dart` (lines 279-349)

```dart
Consumer(
  builder: (context, ref, child) {
    final categoryId = _getCategoryId(_selectedCategoryIndex);
    final banners = ref.watch(bannersByCategoryProvider(categoryId));  // Future 기반

    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return PageView.builder(...);  // 배너 표시
  },
)
```

**상태**:
- ✅ Consumer 패턴 사용
- ⚠️ Future 기반이므로 실시간 갱신 없음

---

#### 📊 예상 성능

**평가**: ❌ **실시간 동기화 미지원**

---

### 3. benefit_categories (혜택 카테고리)

#### ✅ Supabase Realtime 설정
- Realtime 활성화: ✅

#### ✅ RLS Policy
**파일**: `/backend/supabase/migrations/20251027000001_correct_schema.sql`
```sql
ALTER TABLE benefit_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access" ON benefit_categories FOR SELECT USING (true);
```

---

#### ❌ Flutter Repository - 존재하지 않음

**검색 결과**:
- `/apps/pickly_mobile/lib/contexts/benefit/models/benefit_category.dart` (모델만 존재)
- ❌ Repository 파일 없음
- ❌ 직접 Supabase 쿼리를 호출하는 것으로 추정

**문제점**:
- ❌ Repository 계층 자체가 없음
- ❌ 데이터 소스 추상화 없음
- ❌ Stream 구현 불가능

---

#### ❌ Riverpod Provider - 존재하지 않음

**검색 결과**:
- `benefit_category_provider.dart` 파일 없음
- ❌ Provider 없음

**문제점**:
- ❌ 상태 관리 없음
- ❌ Realtime 구독 불가능

---

#### ❌ UI - 사용되지 않음

**파일**: `/apps/pickly_mobile/lib/features/benefits/screens/benefits_screen.dart`

**발견된 패턴**:
```dart
// Hardcoded categories (lines 126-136)
final List<Map<String, String>> _categories = [
  {'label': '인기', 'icon': 'assets/icons/popular.svg'},
  {'label': '주거', 'icon': 'assets/icons/housing.svg'},
  {'label': '교육', 'icon': 'assets/icons/education.svg'},
  // ... 하드코딩된 카테고리 목록
];
```

**상태**:
- ❌ 하드코딩된 카테고리 사용
- ❌ Supabase `benefit_categories` 테이블 전혀 사용 안 함
- ❌ Admin에서 카테고리 추가/수정해도 앱에 반영 불가능

---

#### 📊 예상 성능

**평가**: ❌ **미구현** (Repository, Provider, UI 연동 모두 없음)

---

### 4. age_categories (연령 카테고리)

#### ✅ Supabase Realtime 설정
- Realtime 활성화: ✅

#### ✅ RLS Policy
**파일**: `/backend/supabase/migrations/20251007035747_onboarding_schema.sql`
```sql
ALTER TABLE age_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone views active categories"
ON age_categories FOR SELECT
USING (is_active = true);
```

---

#### ✅ Flutter Repository - Realtime 구독 구현됨!

**파일**: `/apps/pickly_mobile/lib/contexts/user/repositories/age_category_repository.dart`

**구현 코드**:
```dart
class AgeCategoryRepository {
  final SupabaseClient _client;

  // ✅ Realtime 구독 메서드 존재!
  RealtimeChannel subscribeToCategories({
    void Function(AgeCategory category)? onInsert,
    void Function(AgeCategory category)? onUpdate,
    void Function(String id)? onDelete,
  }) {
    final channel = _client.channel('age_categories_changes');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'age_categories',
      callback: (payload) {
        if (onInsert != null) {
          final category = AgeCategory.fromJson(payload.newRecord);
          onInsert(category);
        }
      },
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'age_categories',
      callback: (payload) {
        if (onUpdate != null) {
          final category = AgeCategory.fromJson(payload.newRecord);
          onUpdate(category);
        }
      },
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.delete,
      schema: 'public',
      table: 'age_categories',
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
}
```

**결과**: ✅ **Realtime 구독 구현 완료** (INSERT, UPDATE, DELETE 모두 감지)

---

#### ✅ Riverpod Provider - Realtime 연동됨

**파일**: `/apps/pickly_mobile/lib/features/onboarding/providers/age_category_provider.dart`

**구현 코드**:
```dart
class AgeCategoryNotifier extends AsyncNotifier<List<AgeCategory>> {
  RealtimeChannel? _channel;

  @override
  Future<List<AgeCategory>> build() async {
    // ✅ Dispose 시 채널 정리
    ref.onDispose(() {
      _channel?.unsubscribe();
    });

    // ✅ Realtime 구독 설정
    _setupRealtimeSubscription();

    // 초기 데이터 로드
    return _fetchCategories();
  }

  // ✅ Realtime 구독 설정
  void _setupRealtimeSubscription() {
    final repository = ref.read(ageCategoryRepositoryProvider);

    if (repository == null) {
      debugPrint('ℹ️ Skipping realtime subscription - Supabase not initialized');
      return;
    }

    try {
      _channel = repository.subscribeToCategories(
        onInsert: (category) {
          debugPrint('🔔 Realtime INSERT: ${category.title}');
          refresh();  // ✅ 자동 갱신
        },
        onUpdate: (category) {
          debugPrint('🔔 Realtime UPDATE: ${category.title}');
          refresh();  // ✅ 자동 갱신
        },
        onDelete: (id) {
          debugPrint('🔔 Realtime DELETE: $id');
          refresh();  // ✅ 자동 갱신
        },
      );
      debugPrint('✅ Realtime subscription established for age_categories');
    } catch (e) {
      debugPrint('⚠️ Failed to setup realtime subscription: $e');
    }
  }
}
```

**결과**: ✅ **Realtime 이벤트 발생 시 자동 refresh()** 호출

---

#### ✅ UI - AsyncValue 패턴 사용

**파일**: `/apps/pickly_mobile/lib/features/benefits/screens/benefits_screen.dart`

```dart
final selectedAgeCategory = ageCategoryId != null
    ? ref.watch(ageCategoryByIdProvider(ageCategoryId))
    : null;
```

**결과**: ✅ AsyncValue 패턴 적용

---

#### ⚠️ 한계점: AsyncNotifier + Manual Refresh

**현재 구현의 문제**:
```dart
// Realtime 이벤트 발생 시
onUpdate: (category) {
  refresh();  // ⚠️ 전체 리스트 다시 fetch (비효율적)
}
```

**개선 필요**:
- ⚠️ 전체 리스트를 다시 fetch하는 대신, 변경된 항목만 업데이트해야 함
- ⚠️ `StreamNotifier` 또는 `StreamProvider` 사용 권장

---

#### 📊 예상 성능 (age_categories)

**이론적 지연 시간**:
```
Admin 수정 (0ms)
  → Supabase DB Update (50-100ms)
  → Realtime Event Broadcast (50-200ms)
  → Flutter Repository Receive (10-50ms)
  → Provider refresh() 호출 (0ms)
  → Repository fetchActiveCategories() (100-300ms)  ⚠️ 비효율적
  → AsyncNotifier setState (10-50ms)
  → UI Rebuild (16-33ms)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total: 236-733ms (평균 ~485ms)
```

**평가**: ⚠️ **실시간 동기화 가능하나 비효율적** (전체 리스트 재조회)

---

## 🚨 발견된 이슈

### Critical (즉시 수정 필요)

1. **❌ announcements 테이블 실시간 동기화 불가능**
   - Repository: Future 메서드만 존재 (Stream 없음)
   - Provider: AsyncNotifier 사용 (StreamProvider 필요)
   - 영향: Admin 공고 수정 시 앱에 실시간 반영 불가능

2. **❌ category_banners 테이블 실시간 동기화 불가능**
   - Repository: Future 메서드만 존재
   - Provider: AsyncNotifier 사용
   - 영향: Admin 배너 수정 시 앱 홈 화면에 실시간 반영 불가능

3. **❌ benefit_categories 테이블 완전 미구현**
   - Repository 없음
   - Provider 없음
   - UI에서 하드코딩된 카테고리 사용
   - 영향: Admin에서 카테고리 추가/수정 불가능

### Warning (개선 권장)

4. **⚠️ age_categories Realtime 구현 비효율적**
   - Realtime 이벤트 발생 시 전체 리스트 재조회
   - 권장: Stream 기반으로 변경하여 증분 업데이트

5. **⚠️ Mock Data Fallback 과다 사용**
   - category_banners, age_categories에 Mock Data 존재
   - 권장: 개발 환경과 프로덕션 환경 명확히 분리

---

## 🔧 권장 개선사항

### 우선순위 1 (High) - announcements 실시간 동기화 구현

#### Step 1: Repository에 Stream 메서드 추가

**파일**: `/apps/pickly_mobile/lib/features/benefits/repositories/announcement_repository.dart`

```dart
class AnnouncementRepository {
  // ✅ 추가: Realtime Stream 메서드
  Stream<List<Announcement>> watchAnnouncements({String? status}) {
    var query = _supabase
        .from('announcements')
        .stream(primaryKey: ['id']);

    return query.map((data) {
      var announcements = data
          .map((json) => Announcement.fromJson(json))
          .toList();

      // 필터링 적용
      if (status != null) {
        announcements = announcements.where((a) => a.status == status).toList();
      }

      // 정렬 (priority DESC, posted_date DESC)
      announcements.sort((a, b) {
        final priorityCompare = b.isPriority ? 1 : (a.isPriority ? -1 : 0);
        if (priorityCompare != 0) return priorityCompare;
        return b.postedDate.compareTo(a.postedDate);
      });

      return announcements;
    });
  }
}
```

#### Step 2: Provider를 StreamProvider로 변경

**파일**: `/apps/pickly_mobile/lib/features/benefits/providers/announcement_provider.dart`

```dart
// ✅ StreamProvider 사용
@riverpod
Stream<List<Announcement>> watchAnnouncements(WatchAnnouncementsRef ref) {
  return ref.watch(announcementRepositoryProvider).watchAnnouncements();
}

// ✅ 상태별 필터링 Provider
@riverpod
Stream<List<Announcement>> watchAnnouncementsByStatus(
  WatchAnnouncementsByStatusRef ref,
  String status,
) {
  return ref.watch(announcementRepositoryProvider).watchAnnouncements(status: status);
}
```

#### Step 3: UI에서 StreamProvider 사용

**파일**: `/apps/pickly_mobile/lib/features/benefits/screens/benefits_screen.dart`

```dart
// ✅ StreamProvider watch
final announcementsAsync = ref.watch(watchAnnouncementsProvider);

announcementsAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => ErrorWidget(err),
  data: (announcements) => ListView.builder(
    itemCount: announcements.length,
    itemBuilder: (context, index) {
      final announcement = announcements[index];
      return AnnouncementCard(announcement: announcement);
    },
  ),
);
```

**예상 효과**:
- ✅ Admin 수정 시 0.5초 이내 Flutter UI 자동 갱신
- ✅ Pull-to-refresh 불필요
- ✅ 서버 폴링 부하 감소

---

### 우선순위 2 (High) - category_banners 실시간 동기화 구현

#### Repository Stream 메서드 추가

```dart
class CategoryBannerRepository {
  // ✅ 추가
  Stream<List<CategoryBanner>> watchActiveBanners() {
    return _supabase
        .from('category_banners')
        .stream(primaryKey: ['id'])
        .map((data) {
          return data
              .where((json) => json['is_active'] == true)
              .map((json) => CategoryBanner.fromJson(json))
              .toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        });
  }

  Stream<List<CategoryBanner>> watchBannersForCategory(String categoryId) {
    return _supabase
        .from('category_banners')
        .stream(primaryKey: ['id'])
        .map((data) {
          return data
              .where((json) =>
                json['benefit_category_id'] == categoryId &&
                json['is_active'] == true
              )
              .map((json) => CategoryBanner.fromJson(json))
              .toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        });
  }
}
```

#### Provider 변경

```dart
@riverpod
Stream<List<CategoryBanner>> watchCategoryBanners(WatchCategoryBannersRef ref) {
  return ref.watch(categoryBannerRepositoryProvider).watchActiveBanners();
}

@riverpod
Stream<List<CategoryBanner>> watchBannersByCategory(
  WatchBannersByCategoryRef ref,
  String categoryId,
) {
  return ref.watch(categoryBannerRepositoryProvider)
      .watchBannersForCategory(categoryId);
}
```

---

### 우선순위 3 (Medium) - benefit_categories 구현

#### Repository 생성

**새 파일**: `/apps/pickly_mobile/lib/contexts/benefit/repositories/benefit_category_repository.dart`

```dart
class BenefitCategoryRepository {
  final SupabaseClient _supabase;

  BenefitCategoryRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Stream<List<BenefitCategory>> watchActiveCategories() {
    return _supabase
        .from('benefit_categories')
        .stream(primaryKey: ['id'])
        .map((data) {
          return data
              .where((json) => json['is_active'] == true && json['parent_id'] == null)
              .map((json) => BenefitCategory.fromJson(json))
              .toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        });
  }
}
```

#### Provider 생성

**새 파일**: `/apps/pickly_mobile/lib/contexts/benefit/providers/benefit_category_provider.dart`

```dart
@riverpod
Stream<List<BenefitCategory>> watchBenefitCategories(
  WatchBenefitCategoriesRef ref,
) {
  return ref.watch(benefitCategoryRepositoryProvider).watchActiveCategories();
}
```

#### UI 하드코딩 제거

**파일**: `/apps/pickly_mobile/lib/features/benefits/screens/benefits_screen.dart`

```dart
// ❌ 기존 하드코딩 제거
// final List<Map<String, String>> _categories = [...]

// ✅ Provider에서 동적으로 로드
final categoriesAsync = ref.watch(watchBenefitCategoriesProvider);

categoriesAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => ErrorWidget(err),
  data: (categories) => ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: categories.length,
    itemBuilder: (context, index) {
      final category = categories[index];
      final isActive = _selectedCategoryIndex == index;

      return TabCircleWithLabel(
        iconPath: category.iconUrl,
        label: category.title,
        state: isActive ? TabCircleWithLabelState.active : TabCircleWithLabelState.default_,
        onTap: () {
          setState(() {
            _selectedCategoryIndex = index;
          });
        },
      );
    },
  ),
);
```

---

### 우선순위 4 (Low) - age_categories Stream 최적화

**현재**: Realtime 이벤트 → `refresh()` → 전체 리스트 재조회

**개선**: Stream 기반으로 변경

```dart
class AgeCategoryRepository {
  // ✅ Stream 메서드 추가
  Stream<List<AgeCategory>> watchActiveCategories() {
    return _client
        .from('age_categories')
        .stream(primaryKey: ['id'])
        .map((data) {
          return data
              .where((json) => json['is_active'] == true)
              .map((json) => AgeCategory.fromJson(json))
              .toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        });
  }
}
```

```dart
// Provider 변경
@riverpod
Stream<List<AgeCategory>> watchAgeCategories(WatchAgeCategoriesRef ref) {
  return ref.watch(ageCategoryRepositoryProvider).watchActiveCategories();
}
```

---

## 📊 성능 예측 요약

### 현재 상태 (Future 기반 폴링)

| 항목 | 현재 구현 | 예상 지연 | 평가 |
|------|----------|----------|------|
| Admin → DB | HTTP POST/PUT | 50-100ms | ✅ |
| DB → Realtime Event | Supabase Broadcast | N/A | ❌ **미사용** |
| Event → Repository | N/A | N/A | ❌ **미사용** |
| Repository → UI | 수동 Pull-to-Refresh | ∞ (사용자 액션 필요) | ❌ |
| **Total** | **수동 갱신만 가능** | **∞** | ❌ **실시간 동기화 불가** |

### 개선 후 예상 성능 (Stream 기반 Realtime)

| 항목 | 개선된 구현 | 예상 지연 | 평가 |
|------|------------|----------|------|
| Admin → DB | HTTP POST/PUT | 50-100ms | ✅ |
| DB → Realtime Event | Supabase WebSocket Broadcast | 50-200ms | ✅ |
| Event → Repository | Stream emit | 10-50ms | ✅ |
| Repository → Provider | StreamProvider update | 10-50ms | ✅ |
| Provider → UI | Widget rebuild | 16-33ms | ✅ |
| **Total** | **자동 실시간 동기화** | **136-433ms** | ✅ **우수** |

**개선 효과**:
- ✅ **평균 ~300ms 이내 자동 갱신**
- ✅ **사용자 액션 불필요**
- ✅ **서버 폴링 부하 제거**
- ✅ **PRD v8.5 요구사항 충족**

---

## ✅ 체크리스트

### 인프라 (Supabase)
- [x] Realtime 활성화 (`config.toml`)
- [x] RLS Public Read 정책 설정
- [x] `announcements` 테이블 Realtime 준비
- [x] `category_banners` 테이블 Realtime 준비
- [x] `benefit_categories` 테이블 Realtime 준비
- [x] `age_categories` 테이블 Realtime 준비

### Flutter 구현
- [ ] ❌ `announcements` Repository Stream 메서드
- [ ] ❌ `announcements` StreamProvider
- [ ] ❌ `category_banners` Repository Stream 메서드
- [ ] ❌ `category_banners` StreamProvider
- [ ] ❌ `benefit_categories` Repository 생성
- [ ] ❌ `benefit_categories` StreamProvider 생성
- [x] ✅ `age_categories` Repository Realtime 구독 (단, 비효율적)
- [ ] ⚠️ `age_categories` Stream 기반으로 최적화 필요

### UI 연동
- [ ] ❌ BenefitsScreen AsyncValue 패턴 적용
- [ ] ❌ 하드코딩된 카테고리 제거
- [ ] ❌ Stream 기반 배너 표시
- [ ] ❌ Stream 기반 공고 목록 표시

### 에러 핸들링
- [ ] ❌ Stream 에러 핸들링 구현
- [ ] ❌ 연결 끊김 시 재연결 로직
- [ ] ❌ 메모리 누수 방지 (autoDispose)

---

## 🎯 최종 평가

### Realtime 준비도: 25%

| 구성 요소 | 준비도 | 설명 |
|-----------|--------|------|
| **Supabase 인프라** | 100% | ✅ Realtime 활성화, RLS 정책 완료 |
| **Flutter Repository** | 10% | ❌ Stream 메서드 거의 없음 (age_categories만 구독 코드 있음) |
| **Riverpod Provider** | 10% | ❌ StreamProvider 사용 안 함 (AsyncNotifier만 사용) |
| **UI 연동** | 30% | ⚠️ AsyncValue 패턴은 있으나 Future 기반 |

### 예상 성능: ❌ **실시간 동기화 불가능**

**현재 상태**:
- ❌ Admin 수정 → Flutter 앱 자동 갱신 **불가능**
- ⚠️ 사용자가 수동으로 Pull-to-Refresh 해야 함
- ❌ PRD v8.5 요구사항 **미충족**

**개선 후 예상**:
- ✅ Admin 수정 → 0.3초 이내 Flutter 앱 자동 갱신
- ✅ 사용자 액션 불필요
- ✅ PRD v8.5 요구사항 완전 충족

### PRD v8.5 준수: 25%

| PRD 요구사항 | 준수 여부 | 상태 |
|-------------|----------|------|
| 실시간 동기화 (announcements) | ❌ | 미구현 |
| 실시간 배너 (category_banners) | ❌ | 미구현 |
| 동적 카테고리 (benefit_categories) | ❌ | 완전 미구현 (하드코딩) |
| 연령 카테고리 (age_categories) | ⚠️ | 부분 구현 (비효율적) |

---

## 📝 다음 단계

### 1주차 (High Priority)
1. ✅ `announcements` Repository Stream 메서드 추가
2. ✅ `announcements` StreamProvider 구현
3. ✅ BenefitsScreen UI Stream 연동
4. ✅ `category_banners` Repository Stream 메서드 추가
5. ✅ `category_banners` StreamProvider 구현

### 2주차 (Medium Priority)
6. ✅ `benefit_categories` Repository 생성
7. ✅ `benefit_categories` StreamProvider 생성
8. ✅ UI 하드코딩 제거 및 동적 로딩
9. ✅ `age_categories` Stream 기반 최적화

### 3주차 (Integration & Testing)
10. ✅ 통합 테스트 (Admin → Flutter 실시간 동기화)
11. ✅ 에러 핸들링 강화
12. ✅ 성능 벤치마크
13. ✅ 문서화

---

## 🔍 참고 자료

### Supabase Realtime 공식 문서
- [Realtime with Flutter](https://supabase.com/docs/guides/realtime/flutter)
- [Postgres Changes](https://supabase.com/docs/guides/realtime/postgres-changes)

### Flutter Riverpod Stream 패턴
- [StreamProvider](https://riverpod.dev/docs/providers/stream_provider)
- [AsyncValue](https://riverpod.dev/docs/concepts/async_values)

### 프로젝트 참고 파일
- ✅ `/apps/pickly_mobile/lib/contexts/user/repositories/age_category_repository.dart` (Realtime 구독 예시)
- ✅ `/apps/pickly_mobile/lib/features/onboarding/providers/age_category_provider.dart` (Realtime 연동 예시)

---

## 📌 결론

**현재 시스템은 Supabase Realtime 인프라는 준비되어 있으나, Flutter 앱이 Future 기반 폴링 방식으로만 구현되어 있어 실시간 동기화가 불가능합니다.**

**모든 테이블에 대해 Stream 기반 Repository + StreamProvider 패턴으로 재구현이 필요하며, 특히 `announcements`와 `category_banners`가 최우선 과제입니다.**

**PRD v8.5 요구사항을 충족하려면 최소 2-3주의 개발 기간이 필요할 것으로 예상됩니다.**

---

**Generated**: 2025-10-31
**Validated by**: QA Testing Agent (Claude Code)
**PRD Version**: v8.5
