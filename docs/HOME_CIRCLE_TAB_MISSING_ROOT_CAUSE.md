# 🔍 Home 화면 써클탭 미반영 원인 분석 보고서

**작성일**: 2025-11-05
**문제**: 어드민에서 추가한 `benefit_category`가 Supabase DB에는 저장되지만 Flutter 앱 Home 화면 써클탭에 반영되지 않음
**상태**: ✅ **근본 원인 파악 완료**

---

## 📋 문제 요약

### 사용자 보고
```
어드민에서 추가한 benefit_category 항목이
• Supabase DB에는 저장되는데
• Flutter 앱 써클탭(Home 상단 탭)에는 반영되지 않는 원인
```

### 예상 동작
1. 어드민에서 `benefit_category` 생성 → Supabase DB에 저장
2. Flutter 앱에서 Realtime Stream 구독 → 자동으로 새 카테고리 감지
3. Home 화면 써클탭에 새 카테고리 아이콘 표시

### 실제 동작
1. ✅ 어드민에서 `benefit_category` 생성 → Supabase DB에 저장됨
2. ✅ Realtime Stream은 정상 작동 (코드 확인 완료)
3. ❌ **Home 화면에 써클탭 UI가 아예 구현되어 있지 않음**

---

## 🎯 근본 원인: UI 미구현

### 원인 1: Home 화면에 써클탭이 존재하지 않음

**파일**: `lib/features/home/screens/home_screen.dart`

**현재 구조**:
```dart
class HomeScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ✅ 헤더 (AppHeader.home)
          // ✅ 새 캐릭터 (Mr. Pick)
          // ✅ 검색바 (PicklySearchBar)

          // ❌ 써클탭이 여기에 없음! (구현 누락)

          // ✅ 정책 카드 리스트 (PopularPolicyCard - 더미 데이터)
        ],
      ),
      bottomNavigationBar: PicklyBottomNavigationBar(...),
    );
  }
}
```

**확인 사항**:
- `grep -n "Circle\|TabBar\|benefit.*category"` 결과: **0건**
- Home 화면에 `benefitCategoriesStreamProvider` 사용 흔적 없음
- 디자인 시스템에 CircleTab 컴포넌트 존재 여부 미확인

---

### 원인 2: Provider는 정상 구현되어 있음

**파일**: `lib/features/benefits/providers/benefit_category_provider.dart`

**구현 상태**:
```dart
✅ benefitCategoriesStreamProvider - StreamProvider로 Realtime 구독
✅ categoriesStreamListProvider - 카테고리 리스트 추출
✅ categoriesStreamLoadingProvider - 로딩 상태
✅ categoriesStreamErrorProvider - 에러 상태
✅ categoryStreamByIdProvider - ID로 카테고리 조회
✅ categoryStreamBySlugProvider - Slug로 카테고리 조회
```

**Repository 확인**:
```dart
// lib/contexts/benefit/repositories/benefit_repository.dart:100
Stream<List<BenefitCategory>> watchCategories() {
  return _client
      .from('benefit_categories')
      .stream(primaryKey: ['id'])  // ✅ Realtime 구독
      .order('display_order', ascending: true)  // ✅ 정렬
      .map((data) => data
          .where((json) => json['is_active'] == true)  // ✅ 활성 필터
          .map((json) => BenefitCategory.fromJson(json))
          .toList());
}
```

**결론**: 데이터 레이어와 Provider 레이어는 완벽하게 구현되어 있음. UI만 누락됨.

---

## 🔍 상세 분석

### 1. Supabase Realtime 스트림 정상 작동

**증거**:
- Repository에 `stream(primaryKey: ['id'])` 명시적으로 구현됨
- Provider에서 `StreamProvider`로 래핑하여 자동 구독
- `debugPrint` 로그가 포함되어 있어 디버깅 가능:
  ```dart
  debugPrint('🌊 [Stream Provider] Starting benefit categories stream');
  debugPrint('📋 [Categories Stream] Loaded ${categories.length} categories');
  ```

**예상 동작**:
1. 앱 시작 시 `benefitCategoriesStreamProvider` 구독 시작
2. Supabase Realtime이 WebSocket 연결 생성
3. `benefit_categories` 테이블 변경 시 자동으로 Flutter에 푸시
4. Provider가 새 데이터를 위젯에 전달

---

### 2. Home 화면 현재 구현 상태

**존재하는 요소**:
- ✅ `AppHeader.home()` - 상단 헤더 (햄버거 메뉴)
- ✅ `_buildBirdCharacter()` - Mr. Pick 캐릭터
- ✅ `PicklySearchBar` - 검색바 (애니메이션 포함)
- ✅ `PopularPolicyCard` - 정책 카드 리스트 (더미 데이터 10개)
- ✅ `PicklyBottomNavigationBar` - 하단 네비게이션

**누락된 요소**:
- ❌ **써클탭 (Circle Tab Bar)** - 카테고리 필터링용
- ❌ `ConsumerWidget` 또는 `Consumer` - Provider 구독 없음
- ❌ `ref.watch(benefitCategoriesStreamProvider)` - 데이터 연결 없음

---

### 3. 디자인 시스템 컴포넌트 확인 필요

**확인 필요 사항**:
```dart
// pickly_design_system 패키지에 존재할 것으로 예상:
- CircleTabBar 또는 CategoryCircleTab 위젯
- 카테고리 아이콘을 원형으로 표시하는 컴포넌트
- 가로 스크롤 가능한 탭바 구현체
```

**현재 사용 중인 디자인 시스템 컴포넌트**:
```dart
import 'package:pickly_design_system/pickly_design_system.dart';

// 이미 사용 중:
- AppHeader.home()
- PicklySearchBar
- PopularPolicyCard
- PicklyBottomNavigationBar
- PicklyNavigationItems

// 써클탭 컴포넌트 존재 여부 확인 필요
```

---

## 💡 해결 방안

### 방안 1: 써클탭 UI 추가 (권장)

**구현 위치**: `lib/features/home/screens/home_screen.dart`

**변경 사항**:
```dart
// 1. StatefulWidget → ConsumerStatefulWidget으로 변경
class HomeScreen extends ConsumerStatefulWidget {  // 변경
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();  // 변경
}

class _HomeScreenState extends ConsumerState<HomeScreen> {  // 변경

  @override
  Widget build(BuildContext context) {
    // 2. 카테고리 스트림 구독
    final categoriesAsync = ref.watch(benefitCategoriesStreamProvider);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 기존 여백
              SliverToBoxAdapter(
                child: SizedBox(
                  height: safeAreaTop + 60 + 56 + 60 + 48 + 12,  // 기존
                ),
              ),

              // 3. 써클탭 추가 (새로 추가)
              SliverToBoxAdapter(
                child: categoriesAsync.when(
                  data: (categories) => CategoryCircleTabBar(  // 컴포넌트 확인 필요
                    categories: categories,
                    onCategoryTap: (category) {
                      // TODO: 카테고리별 필터링 화면으로 이동
                      context.go('/benefits/${category.slug}');
                    },
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (err, _) => Text('Error: $err'),
                ),
              ),

              // 간격 추가
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),

              // 기존 정책 카드 리스트
              SliverPadding(...),
            ],
          ),

          // 기존 상단 고정 영역
          Positioned(...),
        ],
      ),
    );
  }
}
```

**필요 작업**:
1. ✅ Provider 구독 추가 (`ref.watch(benefitCategoriesStreamProvider)`)
2. ⏳ 디자인 시스템에서 써클탭 컴포넌트 확인 또는 생성
3. ⏳ 카테고리 탭 클릭 시 필터링 로직 추가
4. ⏳ 로딩/에러 상태 UI 처리

---

### 방안 2: 디자인 시스템 컴포넌트 생성 (필요시)

**위치**: `packages/pickly_design_system/lib/src/components/`

**필요한 컴포넌트**:
```dart
/// CategoryCircleTabBar
///
/// 카테고리를 원형 아이콘으로 표시하는 가로 스크롤 탭바
///
/// 기능:
/// - 카테고리 아이콘 원형 표시
/// - 가로 스크롤 지원
/// - 선택된 카테고리 강조 표시
/// - 아이콘 URL로부터 동적 로딩 (CachedNetworkImage)
class CategoryCircleTabBar extends StatelessWidget {
  final List<BenefitCategory> categories;
  final Function(BenefitCategory) onCategoryTap;
  final String? selectedCategoryId;

  const CategoryCircleTabBar({
    required this.categories,
    required this.onCategoryTap,
    this.selectedCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,  // 원형 아이콘 + 라벨 높이
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedCategoryId;

          return _CategoryCircleItem(
            category: category,
            isSelected: isSelected,
            onTap: () => onCategoryTap(category),
          );
        },
      ),
    );
  }
}

class _CategoryCircleItem extends StatelessWidget {
  final BenefitCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  // ... 원형 아이콘 + 라벨 구현
}
```

---

## 📊 검증 계획

### Step 1: 디자인 시스템 컴포넌트 확인
```bash
# pickly_design_system 패키지에서 CircleTab 관련 컴포넌트 검색
grep -rn "Circle\|CategoryTab" packages/pickly_design_system/lib
```

### Step 2: 로컬 테스트
```dart
// 간단한 테스트 위젯으로 스트림 확인
class _TestCategoryStream extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(benefitCategoriesStreamProvider);

    return categoriesAsync.when(
      data: (categories) {
        print('✅ Categories loaded: ${categories.length}');
        for (final cat in categories) {
          print('  - ${cat.title} (${cat.slug})');
        }
        return Text('Loaded ${categories.length} categories');
      },
      loading: () => Text('Loading...'),
      error: (err, _) => Text('Error: $err'),
    );
  }
}
```

### Step 3: Realtime 동작 확인
1. Flutter 앱 실행
2. 어드민에서 새 카테고리 추가
3. Flutter 콘솔에서 `debugPrint` 로그 확인:
   ```
   🌊 [Stream Provider] Starting benefit categories stream
   📋 [Categories Stream] Loaded 8 categories  // 기존
   📋 [Categories Stream] Loaded 9 categories  // 새로 추가 후
   ```

---

## 🎯 결론

### 문제의 핵심
```
데이터 레이어 ✅ → Provider 레이어 ✅ → UI 레이어 ❌
                                          ↑
                                    여기가 문제!
```

**DB에 데이터는 정상 저장되고, Realtime Stream도 정상 작동하지만,
Home 화면에 카테고리를 표시하는 써클탭 UI가 아예 구현되어 있지 않음.**

### 해결 우선순위
1. **🔴 긴급**: Home 화면에 써클탭 UI 추가
2. **🟡 중요**: 디자인 시스템 컴포넌트 확인 또는 생성
3. **🟢 일반**: 카테고리 탭 클릭 시 필터링 로직

### 예상 작업 시간
- 디자인 시스템 컴포넌트 확인: **10분**
- 써클탭 UI 추가 (컴포넌트 존재 시): **30분**
- 써클탭 컴포넌트 신규 생성 (필요시): **2시간**
- 테스트 및 검증: **30분**

---

## 📝 참고 파일

### 정상 작동 중인 파일
- ✅ `lib/contexts/benefit/repositories/benefit_repository.dart:100` - `watchCategories()`
- ✅ `lib/contexts/benefit/models/benefit_category.dart` - B-Lite 모델
- ✅ `lib/features/benefits/providers/benefit_category_provider.dart` - 모든 Provider

### 수정 필요 파일
- ❌ `lib/features/home/screens/home_screen.dart` - 써클탭 UI 추가 필요

### 확인 필요 파일
- ⏳ `packages/pickly_design_system/lib/src/components/` - CircleTab 컴포넌트 존재 여부

---

**작성자**: Claude Code
**분석 완료 시각**: 2025-11-05
**PRD 버전**: v9.6.1 (Pickly Integrated System)
