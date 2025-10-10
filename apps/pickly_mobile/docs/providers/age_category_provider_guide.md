# Age Category Provider - 완벽 가이드

## 📋 개요

`age_category_provider.dart`는 Riverpod의 AsyncNotifier 패턴을 사용하여 연령 카테고리 데이터를 관리합니다.

### 주요 기능

✅ **Supabase 실시간 동기화** - INSERT/UPDATE/DELETE 자동 감지
✅ **오프라인 지원** - Supabase 미사용 시 Mock 데이터 사용
✅ **우아한 에러 처리** - 네트워크 오류 시 Fallback 데이터 제공
✅ **메모리 누수 방지** - Realtime 구독 자동 정리
✅ **최적화된 상태 관리** - 불필요한 rebuild 방지

---

## 🏗️ Provider 구조

### 1. Core Provider

```dart
final ageCategoryProvider = AsyncNotifierProvider<AgeCategoryNotifier, List<AgeCategory>>(
  () => AgeCategoryNotifier(),
);
```

**사용법:**
```dart
// Widget에서 사용
final categoriesAsync = ref.watch(ageCategoryProvider);

categoriesAsync.when(
  data: (categories) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
)
```

### 2. Convenience Providers

#### `ageCategoriesListProvider`
- **타입**: `Provider<List<AgeCategory>>`
- **반환값**: 항상 non-null 리스트 (로딩/에러 시 빈 리스트)
- **용도**: 간단한 리스트 표시

```dart
final categories = ref.watch(ageCategoriesListProvider);
// categories는 절대 null이 아님
```

#### `ageCategoriesLoadingProvider`
- **타입**: `Provider<bool>`
- **반환값**: 로딩 중이면 `true`
- **용도**: 로딩 인디케이터 표시

```dart
if (ref.watch(ageCategoriesLoadingProvider)) {
  return CircularProgressIndicator();
}
```

#### `ageCategoriesErrorProvider`
- **타입**: `Provider<Object?>`
- **반환값**: 에러 발생 시 에러 객체, 없으면 `null`
- **용도**: 에러 처리

```dart
final error = ref.watch(ageCategoriesErrorProvider);
if (error != null) {
  return ErrorMessage(error.toString());
}
```

### 3. Family Providers

#### `ageCategoryByIdProvider`
- **타입**: `Provider.family<AgeCategory?, String>`
- **파라미터**: 카테고리 ID
- **용도**: 특정 ID로 카테고리 조회

```dart
final category = ref.watch(ageCategoryByIdProvider('youth-id'));
if (category != null) {
  Text(category.title);
}
```

#### `validateCategoryIdsProvider`
- **타입**: `FutureProvider.family<bool, List<String>>`
- **파라미터**: 카테고리 ID 리스트
- **용도**: ID 유효성 검증

```dart
final isValid = await ref.read(
  validateCategoryIdsProvider(['id1', 'id2']).future
);
```

---

## 🔄 데이터 흐름

### 초기화 프로세스

```
┌─────────────────────────────────────────────┐
│ 1. AgeCategoryNotifier.build() 호출         │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│ 2. _setupRealtimeSubscription()             │
│    - Supabase 채널 구독                     │
│    - INSERT/UPDATE/DELETE 이벤트 리스닝     │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│ 3. _fetchCategories()                       │
│    ├─ Supabase 초기화? → DB에서 가져오기   │
│    ├─ Supabase 없음? → Mock 데이터 사용    │
│    └─ 에러 발생? → Mock 데이터 Fallback    │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│ 4. State 업데이트                           │
│    - AsyncValue.data(categories)            │
│    - UI 자동 rebuild                        │
└─────────────────────────────────────────────┘
```

### Realtime 업데이트 프로세스

```
┌─────────────────────────────────────────────┐
│ Supabase DB 변경 (INSERT/UPDATE/DELETE)     │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│ Realtime Channel 이벤트 수신                │
│    - onInsert(category)                     │
│    - onUpdate(category)                     │
│    - onDelete(id)                           │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│ refresh() 자동 호출                         │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│ _fetchCategories() 재실행                   │
│    → 최신 데이터로 State 업데이트           │
└─────────────────────────────────────────────┘
```

---

## 💡 사용 예제

### 예제 1: 기본 리스트 표시

```dart
class AgeCategoryListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(ageCategoryProvider);

    return categoriesAsync.when(
      data: (categories) {
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return ListTile(
              title: Text(category.title),
              subtitle: Text(category.description),
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('에러 발생: $error'),
            ElevatedButton(
              onPressed: () {
                ref.read(ageCategoryProvider.notifier).retry();
              },
              child: Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 예제 2: Pull-to-Refresh

```dart
class RefreshableAgeCategoryList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(ageCategoriesListProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(ageCategoryProvider.notifier).refresh();
      },
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return CategoryTile(categories[index]);
        },
      ),
    );
  }
}
```

### 예제 3: 로딩 상태와 에러 처리

```dart
class SmartAgeCategoryWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(ageCategoriesLoadingProvider);
    final error = ref.watch(ageCategoriesErrorProvider);
    final categories = ref.watch(ageCategoriesListProvider);

    if (isLoading && categories.isEmpty) {
      return LoadingShimmer();
    }

    if (error != null && categories.isEmpty) {
      return ErrorWidget(
        error: error,
        onRetry: () => ref.read(ageCategoryProvider.notifier).retry(),
      );
    }

    return CategoryGrid(categories);
  }
}
```

### 예제 4: 특정 카테고리 조회

```dart
class CategoryDetailPage extends ConsumerWidget {
  final String categoryId;

  const CategoryDetailPage({required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(ageCategoryByIdProvider(categoryId));

    if (category == null) {
      return Scaffold(
        body: Center(child: Text('카테고리를 찾을 수 없습니다')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: Column(
        children: [
          Image.network(category.iconUrl ?? ''),
          Text(category.description),
          Text('연령: ${category.minAge}-${category.maxAge}세'),
        ],
      ),
    );
  }
}
```

### 예제 5: 카테고리 ID 검증

```dart
class CategorySelectionForm extends ConsumerWidget {
  final List<String> selectedIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final validationAsync = ref.read(
          validateCategoryIdsProvider(selectedIds)
        );

        await validationAsync.when(
          data: (isValid) {
            if (isValid) {
              // 다음 단계로 진행
              Navigator.push(...);
            } else {
              // 에러 표시
              showDialog(...);
            }
          },
          loading: () => showLoadingDialog(),
          error: (error, stack) => showErrorDialog(error),
        );
      },
      child: Text('다음'),
    );
  }
}
```

---

## 🧪 테스트 가이드

### Provider 테스트 방법

```dart
void main() {
  test('should fetch categories successfully', () async {
    final container = ProviderContainer(
      overrides: [
        supabaseServiceProvider.overrideWithValue(mockSupabaseService),
      ],
    );

    final result = await container.read(ageCategoryProvider.future);

    expect(result, isA<List<AgeCategory>>());
    expect(result.length, greaterThan(0));

    container.dispose();
  });
}
```

### Mock 데이터 오버라이드

```dart
final mockCategoryProvider = AsyncNotifierProvider<AgeCategoryNotifier, List<AgeCategory>>(
  () => MockAgeCategoryNotifier(),
);

class MockAgeCategoryNotifier extends AgeCategoryNotifier {
  @override
  Future<List<AgeCategory>> build() async {
    return [
      AgeCategory(
        id: 'test-1',
        title: 'Test Category',
        // ...
      ),
    ];
  }
}
```

---

## 🐛 디버깅 팁

### 1. 로그 확인

Provider는 다양한 디버그 로그를 출력합니다:

- `ℹ️` - 정보 (Supabase 미사용 등)
- `✅` - 성공 (데이터 로드, 구독 성공)
- `⚠️` - 경고 (Fallback 사용)
- `❌` - 에러 (예상치 못한 문제)
- `🔔` - Realtime 이벤트
- `🔄` - Refresh/Retry 작업

### 2. Riverpod DevTools 사용

```dart
// main.dart
void main() {
  runApp(
    ProviderScope(
      observers: [ProviderLogger()],
      child: MyApp(),
    ),
  );
}

class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('[${provider.name ?? provider.runtimeType}] $newValue');
  }
}
```

### 3. State 검사

```dart
// 현재 상태 확인
final state = ref.read(ageCategoryProvider);

state.when(
  data: (data) => print('Data: ${data.length} items'),
  loading: () => print('Loading...'),
  error: (e, s) => print('Error: $e'),
);
```

---

## ⚠️ 주의사항

### 1. Provider 재사용

❌ **잘못된 사용:**
```dart
// 여러 곳에서 직접 notifier를 생성하지 마세요
final notifier1 = AgeCategoryNotifier();
final notifier2 = AgeCategoryNotifier();
```

✅ **올바른 사용:**
```dart
// 항상 Provider를 통해 접근하세요
final notifier = ref.read(ageCategoryProvider.notifier);
```

### 2. Dispose 처리

Provider는 자동으로 dispose되지만, 수동 구독 시 주의:

```dart
@override
void initState() {
  super.initState();

  // ❌ 잘못됨: 수동 구독은 메모리 누수 가능
  ref.read(ageCategoryProvider.notifier).refresh();
}

// ✅ 올바름: ref.listen 사용
@override
void initState() {
  super.initState();

  ref.listen(ageCategoryProvider, (previous, next) {
    // 자동으로 dispose됨
  });
}
```

### 3. Build 메서드에서의 Side Effect

❌ **잘못된 사용:**
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // build 메서드에서 refresh 호출하지 마세요
  ref.read(ageCategoryProvider.notifier).refresh();
  return ...;
}
```

✅ **올바른 사용:**
```dart
@override
void initState() {
  super.initState();

  // initState에서 호출하거나
  Future.microtask(() {
    ref.read(ageCategoryProvider.notifier).refresh();
  });
}

// 또는 버튼 클릭 시
onPressed: () {
  ref.read(ageCategoryProvider.notifier).refresh();
}
```

---

## 🚀 성능 최적화

### 1. 불필요한 Rebuild 방지

```dart
// ❌ 매번 rebuild됨
final categories = ref.watch(ageCategoryProvider).value ?? [];

// ✅ 데이터가 실제로 변경될 때만 rebuild
final categories = ref.watch(ageCategoriesListProvider);
```

### 2. Select를 사용한 부분 구독

```dart
// 특정 필드만 watch
final categoryCount = ref.watch(
  ageCategoriesListProvider.select((categories) => categories.length)
);
```

### 3. AutoDispose 사용

현재 Provider는 항상 활성 상태지만, 필요시 AutoDispose 사용:

```dart
final tempCategoryProvider = AsyncNotifierProvider.autoDispose<
  AgeCategoryNotifier,
  List<AgeCategory>
>(
  () => AgeCategoryNotifier(),
);
```

---

## 📚 관련 파일

- **Provider**: `lib/features/onboarding/providers/age_category_provider.dart`
- **Repository**: `lib/contexts/user/repositories/age_category_repository.dart`
- **Model**: `lib/contexts/user/models/age_category.dart`
- **Tests**: `test/features/onboarding/providers/age_category_provider_test.dart`

---

## 🔗 참고 자료

- [Riverpod 공식 문서](https://riverpod.dev)
- [AsyncNotifier 가이드](https://riverpod.dev/docs/concepts/about_code_generation)
- [Supabase Realtime](https://supabase.com/docs/guides/realtime)
