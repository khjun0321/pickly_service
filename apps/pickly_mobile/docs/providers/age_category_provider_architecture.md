# Age Category Provider - 아키텍처 다이어그램

## 📐 전체 시스템 아키텍처

```
┌─────────────────────────────────────────────────────────────────┐
│                         UI Layer (Widgets)                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   ListView  │  │ CategoryCard│  │ ErrorWidget │             │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘             │
└─────────┼─────────────────┼─────────────────┼───────────────────┘
          │                 │                 │
          │   ref.watch()   │                 │
          ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Provider Layer (Riverpod)                       │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │         ageCategoryProvider (Core AsyncNotifier)           │ │
│  │         - AsyncValue<List<AgeCategory>>                    │ │
│  │         - refresh(), retry()                               │ │
│  └────────────────────┬───────────────────────────────────────┘ │
│                       │                                          │
│                       │ provides data to                         │
│                       ▼                                          │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │          Convenience Providers (Computed)                │   │
│  │  ┌───────────────────────────────────────────────────┐  │   │
│  │  │ ageCategoriesListProvider                         │  │   │
│  │  │ → List<AgeCategory> (never null)                 │  │   │
│  │  └───────────────────────────────────────────────────┘  │   │
│  │  ┌───────────────────────────────────────────────────┐  │   │
│  │  │ ageCategoriesLoadingProvider                      │  │   │
│  │  │ → bool (isLoading)                                │  │   │
│  │  └───────────────────────────────────────────────────┘  │   │
│  │  ┌───────────────────────────────────────────────────┐  │   │
│  │  │ ageCategoriesErrorProvider                        │  │   │
│  │  │ → Object? (error or null)                         │  │   │
│  │  └───────────────────────────────────────────────────┘  │   │
│  │  ┌───────────────────────────────────────────────────┐  │   │
│  │  │ ageCategoryByIdProvider (Family)                  │  │   │
│  │  │ → AgeCategory? (lookup by ID)                     │  │   │
│  │  └───────────────────────────────────────────────────┘  │   │
│  │  ┌───────────────────────────────────────────────────┐  │   │
│  │  │ validateCategoryIdsProvider (Family)              │  │   │
│  │  │ → Future<bool> (validation)                       │  │   │
│  │  └───────────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          │ uses
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Repository Layer                               │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │         ageCategoryRepositoryProvider                      │ │
│  │         ↓                                                  │ │
│  │    AgeCategoryRepository                                   │ │
│  │    - fetchActiveCategories()                               │ │
│  │    - fetchCategoryById()                                   │ │
│  │    - subscribeToCategories()                               │ │
│  │    - validateCategoryIds()                                 │ │
│  └────────────────────┬───────────────────────────────────────┘ │
└─────────────────────────┼───────────────────────────────────────┘
                          │
                          │ uses
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Data Layer                                     │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │         supabaseServiceProvider                            │ │
│  │         ↓                                                  │ │
│  │    SupabaseClient                                          │ │
│  │    ├─ from('age_categories')                              │ │
│  │    ├─ .select()                                            │ │
│  │    ├─ .eq('is_active', true)                              │ │
│  │    └─ .order('sort_order')                                │ │
│  └────────────────────┬───────────────────────────────────────┘ │
└─────────────────────────┼───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Supabase Database                              │
│                   Table: age_categories                          │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Columns:                                                   │ │
│  │  - id (uuid, PK)                                           │ │
│  │  - title (text)                                            │ │
│  │  - description (text)                                      │ │
│  │  - icon_component (text)                                   │ │
│  │  - icon_url (text, nullable)                              │ │
│  │  - min_age (int, nullable)                                │ │
│  │  - max_age (int, nullable)                                │ │
│  │  - sort_order (int)                                        │ │
│  │  - is_active (bool)                                        │ │
│  │  - created_at (timestamp)                                  │ │
│  │  - updated_at (timestamp)                                  │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  🔔 Realtime Channel: "age_categories_changes"                  │
│     - INSERT events → refresh()                                 │
│     - UPDATE events → refresh()                                 │
│     - DELETE events → refresh()                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 데이터 흐름 상세

### 1. 초기 로딩 시퀀스

```
User Opens App
      │
      ▼
┌─────────────────────┐
│ Widget.build()      │
│ ref.watch(          │
│   ageCategoryProvider│
│ )                   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ AsyncNotifier       │
│ .build() called     │
│ (only once)         │
└──────────┬──────────┘
           │
           ├─────────────────┐
           │                 │
           ▼                 ▼
┌──────────────────┐  ┌─────────────────────┐
│ setupRealtime    │  │ _fetchCategories()  │
│ Subscription     │  │                     │
└──────────────────┘  └──────────┬──────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
              Supabase OK?              Supabase ✗?
                    │                         │
                    ▼                         ▼
        ┌─────────────────────┐   ┌─────────────────────┐
        │ Repository          │   │ _getMockCategories()│
        │ .fetchActive()      │   │                     │
        └──────────┬──────────┘   └──────────┬──────────┘
                   │                         │
                   ▼                         │
        ┌─────────────────────┐             │
        │ Supabase DB Query   │             │
        │ SELECT * FROM ...   │             │
        └──────────┬──────────┘             │
                   │                         │
                   └────────┬────────────────┘
                            │
                            ▼
                ┌─────────────────────┐
                │ List<AgeCategory>   │
                │ returned            │
                └──────────┬──────────┘
                           │
                           ▼
                ┌─────────────────────┐
                │ State = AsyncValue  │
                │   .data(categories) │
                └──────────┬──────────┘
                           │
                           ▼
                ┌─────────────────────┐
                │ Widget rebuilds     │
                │ with data           │
                └─────────────────────┘
```

---

### 2. Realtime 업데이트 시퀀스

```
Admin Updates DB
      │
      ▼
┌─────────────────────┐
│ Supabase DB         │
│ UPDATE age_categories│
│ SET title = '...'   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Realtime Channel    │
│ broadcasts          │
│ PostgresChange      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Repository          │
│ subscribeToCategories│
│ onUpdate callback   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ AgeCategoryNotifier │
│ .refresh()          │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ State =             │
│ AsyncValue.loading()│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ _fetchCategories()  │
│ re-executed         │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Fresh data loaded   │
│ State updated       │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ UI auto-rebuilds    │
│ with latest data    │
└─────────────────────┘
```

---

### 3. 에러 복구 시퀀스

```
Network Error Occurs
      │
      ▼
┌─────────────────────┐
│ Repository throws   │
│ AgeCategoryException│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ _fetchCategories()  │
│ catch block         │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Log error           │
│ debugPrint('⚠️ ...')│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ _getMockCategories()│
│ return fallback     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ State =             │
│ AsyncValue.data(    │
│   mockCategories)   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ UI shows data       │
│ (user unaware of    │
│  error)             │
└──────────┬──────────┘
           │
           ▼
     User sees content
   (graceful degradation)
```

---

## 🎨 Provider 사용 패턴 맵

### UI에서의 Provider 선택 가이드

```
┌─────────────────────────────────────────────────────────────────┐
│                   "어떤 Provider를 써야 하나?"                    │
└─────────────────────────────────────────────────────────────────┘

필요한 것                          →  사용할 Provider
─────────────────────────────────────────────────────────────────

📋 전체 카테고리 리스트             →  ageCategoriesListProvider
   - 간단한 ListView
   - 로딩/에러 신경 안씀
   - 항상 non-null 리스트 보장

🔄 로딩/에러 상태까지 필요         →  ageCategoryProvider
   - .when() 사용
   - 로딩 스피너 표시
   - 에러 UI 표시

⏳ 로딩 중인지만 확인               →  ageCategoriesLoadingProvider
   - boolean 값만 필요
   - if (isLoading) ...

❌ 에러 발생 여부 확인               →  ageCategoriesErrorProvider
   - 에러 객체 접근
   - 에러 메시지 표시

🔍 특정 ID로 카테고리 찾기          →  ageCategoryByIdProvider(id)
   - 단일 카테고리 조회
   - 상세 페이지

✅ ID 유효성 검증                   →  validateCategoryIdsProvider(ids)
   - 폼 제출 전 검증
   - 다음 단계 진행 가능 여부

🔄 수동 새로고침                    →  ref.read().notifier.refresh()
   - Pull-to-refresh
   - 수동 동기화

🔁 에러 후 재시도                   →  ref.read().notifier.retry()
   - "다시 시도" 버튼
   - 에러 복구
```

---

## 🧩 Provider 조합 패턴

### 패턴 1: 로딩 + 리스트 (가장 일반적)

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final isLoading = ref.watch(ageCategoriesLoadingProvider);
  final categories = ref.watch(ageCategoriesListProvider);

  if (isLoading && categories.isEmpty) {
    return LoadingShimmer();
  }

  return ListView.builder(
    itemCount: categories.length,
    itemBuilder: (context, index) => CategoryCard(categories[index]),
  );
}
```

### 패턴 2: 완전한 상태 처리

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final categoriesAsync = ref.watch(ageCategoryProvider);

  return categoriesAsync.when(
    data: (categories) => CategoryGrid(categories),
    loading: () => CircularProgressIndicator(),
    error: (error, stack) => ErrorWidget(
      error: error,
      onRetry: () => ref.read(ageCategoryProvider.notifier).retry(),
    ),
  );
}
```

### 패턴 3: 에러 우선 처리

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final error = ref.watch(ageCategoriesErrorProvider);
  final categories = ref.watch(ageCategoriesListProvider);

  if (error != null) {
    return ErrorBanner(
      error: error,
      onDismiss: () => ref.read(ageCategoryProvider.notifier).retry(),
    );
  }

  return CategoryList(categories);
}
```

### 패턴 4: 검증과 네비게이션

```dart
onPressed: () async {
  final selectedIds = ['id1', 'id2'];

  final isValid = await ref.read(
    validateCategoryIdsProvider(selectedIds).future,
  );

  if (isValid) {
    Navigator.push(context, NextScreen());
  } else {
    showErrorDialog('유효하지 않은 카테고리 선택');
  }
}
```

---

## 🔐 메모리 안전성 다이어그램

```
┌─────────────────────────────────────────────────────────────────┐
│                    Provider Lifecycle                            │
└─────────────────────────────────────────────────────────────────┘

Widget Created
      │
      ▼
┌─────────────────────┐
│ Provider attached   │
│ to ProviderScope    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ build() called      │
│ - Setup realtime    │
│ - Fetch data        │
│ - Register onDispose│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Provider active     │
│ - Listening to DB   │
│ - Serving data      │
└──────────┬──────────┘
           │
           ▼
Widget Disposed
      │
      ▼
┌─────────────────────┐
│ ref.onDispose()     │
│ triggered           │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ _channel?.          │
│ unsubscribe()       │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Realtime connection │
│ closed              │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Memory freed        │
│ ✅ No leaks         │
└─────────────────────┘

Important: Riverpod automatically manages lifecycle!
- No manual dispose needed for providers
- ref.onDispose() ensures cleanup
- Widget rebuild optimization built-in
```

---

## 📦 의존성 그래프

```
ageCategoryProvider
    │
    ├─ depends on ──→ ageCategoryRepositoryProvider
    │                       │
    │                       └─ depends on ──→ supabaseServiceProvider
    │                                              │
    │                                              └─ SupabaseClient
    │
    ├─ provides to ──→ ageCategoriesListProvider
    │
    ├─ provides to ──→ ageCategoriesLoadingProvider
    │
    ├─ provides to ──→ ageCategoriesErrorProvider
    │
    ├─ provides to ──→ ageCategoryByIdProvider (Family)
    │
    └─ provides to ──→ validateCategoryIdsProvider (Family)
                              │
                              └─ also depends on ──→ ageCategoryRepositoryProvider
```

---

## 🎯 성능 최적화 포인트

```
┌─────────────────────────────────────────────────────────────────┐
│                  Performance Optimization Points                 │
└─────────────────────────────────────────────────────────────────┘

1. Rebuild Minimization
   ────────────────────────────────────────
   ❌ ref.watch(ageCategoryProvider)
      → rebuilds on every state change

   ✅ ref.watch(ageCategoriesListProvider)
      → rebuilds only when list actually changes

   ✅ ref.watch(ageCategoryProvider.select((value) =>
         value.maybeWhen(data: (d) => d.length, orElse: () => 0)
      ))
      → rebuilds only when length changes


2. Subscription Management
   ────────────────────────────────────────
   ✅ Single realtime channel per provider
   ✅ Automatic unsubscribe on dispose
   ✅ No duplicate subscriptions


3. Data Fetching
   ────────────────────────────────────────
   ✅ Fetch only once on initialization
   ✅ Refresh only on:
      - User action (pull-to-refresh)
      - Realtime event
      - Manual retry
   ✅ No automatic polling


4. State Management
   ────────────────────────────────────────
   ✅ AsyncValue caching
   ✅ Immutable data structures
   ✅ Efficient equality checks (by ID)


5. Error Handling
   ────────────────────────────────────────
   ✅ Graceful fallback (mock data)
   ✅ No infinite retry loops
   ✅ User always sees content
```

---

이 아키텍처는 **확장 가능하고, 유지보수가 쉬우며, 성능이 최적화된** 구조입니다.
