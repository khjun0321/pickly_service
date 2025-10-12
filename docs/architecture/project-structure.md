# Pickly Mobile 프로젝트 구조 상세 문서

> **마지막 업데이트**: 2025.10.12 (v5.4)
> **대상 독자**: 신규 개발자, 아키텍트, 코드 리뷰어

---

## 📌 목차

1. [개요](#개요)
2. [모노레포 구조](#모노레포-구조)
3. [Feature-First 조직화](#feature-first-조직화)
4. [모듈 경계](#모듈-경계)
5. [의존성 다이어그램](#의존성-다이어그램)
6. [파일 명명 규칙](#파일-명명-규칙)
7. [내비게이션 전략](#내비게이션-전략)
8. [상태 관리](#상태-관리)
9. [테스트 전략](#테스트-전략)

---

## 개요

Pickly Mobile은 **Domain-Driven Design (DDD)**과 **Clean Architecture** 원칙을 따르는 Flutter 모바일 애플리케이션입니다. 프로젝트는 모노레포 구조로 구성되며, 명확한 모듈 경계와 의존성 규칙을 통해 확장 가능하고 유지보수하기 쉬운 코드베이스를 유지합니다.

### 핵심 원칙

1. **명확한 관심사 분리**: Contexts (도메인), Features (UI), Core (인프라)
2. **단방향 의존성**: Features → Contexts → Core
3. **재사용성**: Design System을 통한 공통 컴포넌트 관리
4. **테스트 가능성**: 계층별 독립적인 테스트 작성 가능
5. **확장성**: 새로운 Feature 추가 시 기존 코드에 영향 최소화

---

## 모노레포 구조

Pickly 프로젝트는 Melos를 사용한 모노레포로 구성됩니다.

```
pickly_service/                           # 루트 디렉토리
│
├─ apps/                                  # 애플리케이션 모듈
│  └─ pickly_mobile/                      # Flutter 모바일 앱
│     ├─ lib/                             # 소스 코드
│     ├─ test/                            # 테스트 코드
│     ├─ assets/                          # 로컬 에셋 (앱 전용)
│     ├─ pubspec.yaml                     # 앱 의존성
│     └─ README.md                        # 앱 문서
│
├─ packages/                              # 공유 패키지
│  └─ pickly_design_system/               # 디자인 시스템
│     ├─ lib/                             # 위젯, 테마, 토큰
│     ├─ assets/                          # 공유 에셋
│     │  ├─ icons/                        # Figma 아이콘
│     │  ├─ images/                       # 공통 이미지
│     │  └─ fonts/                        # 커스텀 폰트
│     ├─ test/                            # 위젯 테스트
│     └─ pubspec.yaml                     # 패키지 의존성
│
├─ backend/                               # 백엔드 관련 파일
│  └─ supabase/                           # Supabase 설정
│     ├─ migrations/                      # DB 마이그레이션
│     ├─ seed.sql                         # 초기 데이터
│     └─ config.toml                      # Supabase 설정
│
├─ docs/                                  # 프로젝트 문서
│  ├─ PRD.md                              # 제품 요구사항 문서
│  ├─ architecture/                       # 아키텍처 문서
│  │  ├─ project-structure.md             # 본 문서
│  │  └─ import-conventions.md            # Import 규칙
│  ├─ development/                        # 개발 가이드
│  └─ api/                                # API 문서
│
├─ .claude/                               # Claude Flow AI 시스템
│  ├─ agents/                             # AI 에이전트 정의
│  ├─ workflows/                          # 워크플로우
│  └─ screens/                            # 화면 설정 JSON
│
├─ scripts/                               # 자동화 스크립트
│  ├─ setup-common.sh                     # 프로젝트 초기 설정
│  └─ setup-docs.sh                       # 문서 생성
│
├─ examples/                              # 예제 및 참조 코드
│  └─ onboarding/                         # 온보딩 예제
│
├─ melos.yaml                             # 모노레포 설정
├─ package.json                           # NPM 스크립트 (Claude Flow)
└─ README.md                              # 프로젝트 개요
```

### 각 디렉토리 역할

#### `apps/pickly_mobile/`
- **목적**: 사용자가 사용하는 실제 모바일 애플리케이션
- **특징**:
  - Flutter 프레임워크 기반
  - `packages/pickly_design_system` 의존
  - Supabase를 통한 백엔드 연동
  - Riverpod를 통한 상태 관리

#### `packages/pickly_design_system/`
- **목적**: 재사용 가능한 UI 컴포넌트와 디자인 토큰 제공
- **특징**:
  - Flutter 위젯 의존성 없음 (독립 패키지)
  - Figma 디자인 시스템과 1:1 매핑
  - 여러 앱에서 공유 가능 (확장성)

#### `backend/supabase/`
- **목적**: 백엔드 로직 및 데이터베이스 스키마 관리
- **특징**:
  - PostgreSQL 마이그레이션
  - Row Level Security (RLS) 정책
  - Edge Functions (서버리스, 미래)

#### `docs/`
- **목적**: 프로젝트 전반의 문서화
- **특징**:
  - PRD (제품 요구사항)
  - 아키텍처 가이드
  - 개발 가이드
  - API 스키마

#### `.claude/`
- **목적**: AI 기반 자동화 개발 시스템
- **특징**:
  - 6개 전문 에이전트 정의
  - 화면별 JSON 설정 기반 자동 생성
  - 병렬 처리로 개발 속도 70% 향상

---

## Feature-First 조직화

### `apps/pickly_mobile/lib/` 구조

```
lib/
├─ main.dart                              # 앱 진입점
│
├─ core/                                  # 공통 인프라 (전역 설정)
│  ├─ router.dart                         # GoRouter 라우팅 설정
│  ├─ theme/                              # 앱 테마 (Design System 기반)
│  │  ├─ theme.dart
│  │  ├─ pickly_colors.dart
│  │  ├─ pickly_typography.dart
│  │  └─ pickly_spacing.dart
│  └─ services/                           # 공통 서비스
│     └─ supabase_service.dart            # Supabase 초기화
│
├─ contexts/                              # 도메인 계층 (비즈니스 로직)
│  └─ user/                               # User 도메인
│     ├─ models/                          # 도메인 모델
│     │  ├─ user_profile.dart
│     │  └─ age_category.dart
│     └─ repositories/                    # 데이터 접근
│        ├─ user_repository.dart
│        └─ age_category_repository.dart
│
└─ features/                              # 프레젠테이션 계층 (UI)
   ├─ onboarding/                         # 온보딩 Feature
   │  ├─ screens/                         # 화면 파일
   │  │  ├─ splash_screen.dart
   │  │  └─ age_category_screen.dart
   │  ├─ providers/                       # 상태 관리 (Riverpod)
   │  │  └─ age_category_provider.dart
   │  └─ widgets/                         # 기능별 위젯
   │     ├─ onboarding_header.dart        # 온보딩 전용 헤더
   │     └─ widgets.dart                  # 배럴 파일
   │
   ├─ feed/                               # 정책 피드 Feature (미래)
   │  ├─ screens/
   │  ├─ providers/
   │  └─ widgets/
   │
   └─ search/                             # 검색 Feature (미래)
      ├─ screens/
      ├─ providers/
      └─ widgets/
```

### Feature 구조 템플릿

새로운 Feature를 추가할 때 다음 구조를 따릅니다:

```
features/{feature_name}/
├─ screens/                               # 화면 파일
│  ├─ {screen_name}_screen.dart
│  └─ ...
├─ providers/                             # 상태 관리
│  ├─ {provider_name}_provider.dart
│  └─ ...
├─ widgets/                               # 기능별 위젯
│  ├─ {widget_name}.dart
│  └─ widgets.dart                        # 배럴 파일
└─ README.md                              # Feature 설명 (선택)
```

---

## 모듈 경계

### 1. Core (공통 인프라)

**위치**: `lib/core/`

**역할**:
- 앱 전역 설정 (라우팅, 테마, 서비스)
- 공통 유틸리티 함수
- 환경 변수 관리

**의존성 규칙**:
- ✅ **독립적**: 다른 모듈에 의존하지 않음
- ❌ **금지**: Contexts, Features 참조 금지

**주요 파일**:
- `router.dart`: GoRouter 기반 앱 내비게이션 설정
- `theme/`: Material 3 기반 커스텀 테마
- `services/supabase_service.dart`: Supabase 초기화 및 설정

**예시**:
```dart
// lib/core/router.dart
final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding/age-category',
      builder: (context, state) => const AgeCategoryScreen(),
    ),
  ],
);
```

---

### 2. Contexts (도메인 계층)

**위치**: `lib/contexts/{domain}/`

**역할**:
- 비즈니스 로직 캡슐화
- 데이터 모델 정의 (`models/`)
- 외부 데이터 소스와의 인터페이스 (`repositories/`)

**의존성 규칙**:
- ✅ **허용**: Core 참조, 다른 Contexts 참조
- ❌ **금지**: Features 참조 금지 (UI 의존성 없음)

**특징**:
- **순수 Dart 코드**: Flutter 위젯 사용 금지
- **재사용성**: 여러 Feature에서 공유 가능
- **테스트 용이성**: UI 없이 독립적으로 테스트 가능

**예시**:
```dart
// lib/contexts/user/models/age_category.dart
class AgeCategory {
  final String id;
  final String title;
  final String description;
  final String iconUrl;

  const AgeCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
  });
}

// lib/contexts/user/repositories/age_category_repository.dart
class AgeCategoryRepository {
  final SupabaseClient _supabase;

  AgeCategoryRepository(this._supabase);

  Future<List<AgeCategory>> fetchCategories() async {
    final response = await _supabase
        .from('age_categories')
        .select()
        .order('sort_order');

    return (response as List)
        .map((json) => AgeCategory.fromJson(json))
        .toList();
  }
}
```

---

### 3. Features (프레젠테이션 계층)

**위치**: `lib/features/{feature}/`

**역할**:
- 사용자 인터페이스 구현 (`screens/`, `widgets/`)
- 사용자 인터랙션 처리
- Contexts의 데이터를 화면에 표시 (`providers/`)

**의존성 규칙**:
- ✅ **허용**: Contexts, Core, Design System 참조
- ❌ **금지**: 다른 Feature 직접 참조 금지

**특징**:
- **Riverpod Provider**: 상태 관리 및 비즈니스 로직 연결
- **위젯 분리**: 재사용 가능한 위젯은 `widgets/` 폴더로
- **화면 독립성**: 각 화면은 독립적으로 동작

**예시**:
```dart
// lib/features/onboarding/providers/age_category_provider.dart
@riverpod
class AgeCategoryProvider extends _$AgeCategoryProvider {
  @override
  Future<List<AgeCategory>> build() async {
    final repository = ref.watch(ageCategoryRepositoryProvider);
    return await repository.fetchCategories();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

// lib/features/onboarding/screens/age_category_screen.dart
class AgeCategoryScreen extends ConsumerWidget {
  const AgeCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(ageCategoryProvider);

    return Scaffold(
      body: categoriesAsync.when(
        data: (categories) => _buildCategoryList(categories),
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }
}
```

---

### 4. Design System (공통 디자인)

**위치**: `packages/pickly_design_system/`

**역할**:
- 재사용 가능한 UI 컴포넌트 제공
- Figma 디자인 시스템과 1:1 매핑
- 일관된 디자인 토큰 (색상, 타이포그래피, 간격)

**의존성 규칙**:
- ✅ **독립적**: Flutter SDK에만 의존
- ❌ **금지**: 앱 특정 로직 포함 금지

**주요 컴포넌트** (v5.3):
- **Buttons**: `PicklyButton.primary()`, `PicklyButton.secondary()`
- **Cards**: `SelectionListItem` (v5.3부터 Design System으로 이동)
- **Typography**: `PicklyTypography.titleLarge`, etc.
- **Colors**: `BrandColors.primary`, `TextColors.primary`, etc.
- **Spacing**: `Spacing.xs`, `Spacing.md`, `Spacing.lg`, etc.

**예시**:
```dart
// packages/pickly_design_system/lib/widgets/buttons/pickly_button.dart
class PicklyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;

  const PicklyButton.primary({
    required this.text,
    required this.onPressed,
  }) : variant = ButtonVariant.primary;

  const PicklyButton.secondary({
    required this.text,
    required this.onPressed,
  }) : variant = ButtonVariant.secondary;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: variant == ButtonVariant.primary
            ? BrandColors.primary
            : BrandColors.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(text, style: PicklyTypography.buttonLarge),
    );
  }
}
```

---

## 의존성 다이어그램

### 전체 의존성 흐름

```
┌─────────────────────────────────────────────────┐
│             User Interface (UI)                 │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │     Features (Screens, Widgets)          │  │
│  │  - onboarding/                           │  │
│  │  - feed/                                 │  │
│  │  - search/                               │  │
│  └────────────┬────────────┬────────────────┘  │
│               │            │                    │
└───────────────┼────────────┼────────────────────┘
                │            │
                ↓            ↓
┌───────────────────────┐ ┌─────────────────────┐
│  Design System        │ │  Contexts (Domain)  │
│  - Buttons            │ │  - user/            │
│  - Cards              │ │  - policy/          │
│  - Typography         │ │  - filter/          │
└───────────────────────┘ └──────────┬──────────┘
                                     │
                                     ↓
                          ┌──────────────────────┐
                          │  Core (Infrastructure)│
                          │  - Router            │
                          │  - Theme             │
                          │  - Services          │
                          └──────────┬───────────┘
                                     │
                                     ↓
                          ┌──────────────────────┐
                          │  External Services   │
                          │  - Supabase          │
                          │  - Shared Preferences│
                          └──────────────────────┘
```

### 허용되는 의존성

```
✅ Features → Contexts
✅ Features → Core
✅ Features → Design System
✅ Contexts → Core
✅ Contexts → Other Contexts (단, 순환 참조 금지)
✅ Core → External Services
```

### 금지되는 의존성

```
❌ Contexts → Features (UI 의존성 금지)
❌ Core → Contexts (인프라가 도메인에 의존 금지)
❌ Core → Features (인프라가 UI에 의존 금지)
❌ Features → Other Features (직접 참조 금지)
❌ Design System → App-specific logic (독립성 유지)
```

### 예시: 순환 참조 방지

```dart
// ❌ 잘못된 예시: 순환 참조
// lib/contexts/user/models/user.dart
import 'package:pickly_mobile/contexts/policy/models/policy.dart'; // User → Policy

// lib/contexts/policy/models/policy.dart
import 'package:pickly_mobile/contexts/user/models/user.dart'; // Policy → User (순환!)

// ✅ 올바른 예시: 단방향 의존성
// lib/contexts/user/models/user.dart
class User {
  final String id;
  final String name;
  // Policy 참조 없음
}

// lib/contexts/policy/models/policy.dart
import 'package:pickly_mobile/contexts/user/models/user.dart'; // Policy → User (단방향)

class Policy {
  final String id;
  final User creator; // User 모델 사용
}
```

---

## 파일 명명 규칙

### 일반 원칙

1. **소문자 + 언더스코어**: `age_category_screen.dart`
2. **명확한 접미사 사용**: 파일 역할을 명시
3. **단수형 사용**: 모델은 단수형 (`user.dart`, `policy.dart`)
4. **복수형 사용**: 리스트나 그룹 (`colors.dart`, `constants.dart`)

### 파일 유형별 명명 규칙

| 유형 | 패턴 | 예시 |
|------|------|------|
| **모델** | `{name}.dart` | `age_category.dart`, `user_profile.dart` |
| **Repository** | `{name}_repository.dart` | `age_category_repository.dart`, `user_repository.dart` |
| **화면** | `{name}_screen.dart` | `age_category_screen.dart`, `splash_screen.dart` |
| **Provider** | `{name}_provider.dart` | `age_category_provider.dart`, `onboarding_provider.dart` |
| **위젯** | `{name}.dart` 또는 `{name}_widget.dart` | `onboarding_header.dart`, `selection_list_item.dart` |
| **서비스** | `{name}_service.dart` | `supabase_service.dart`, `storage_service.dart` |
| **테스트** | `{name}_test.dart` | `age_category_screen_test.dart` |

### 디렉토리 명명

- **소문자 + 언더스코어**: `age_categories/`
- **복수형 사용**: `models/`, `repositories/`, `screens/`
- **도메인 이름**: `user/`, `policy/`, `filter/`

---

## 내비게이션 전략

### GoRouter 기반 선언적 라우팅

Pickly는 **GoRouter**를 사용하여 선언적이고 타입 안전한 라우팅을 구현합니다.

**위치**: `lib/core/router.dart`

**주요 개념**:
1. **경로 기반 라우팅**: URL 경로로 화면 식별
2. **Deep Linking 지원**: URL을 통해 앱 내 특정 화면으로 직접 이동
3. **타입 안전성**: 경로 파라미터 타입 검증
4. **중첩 라우팅**: 탭바, 네비게이션 바 등 복잡한 UI 구조 지원

### 라우팅 구조

```dart
// lib/core/router.dart
final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Onboarding Flow
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding/start',
      builder: (context, state) => const StartScreen(),
    ),
    GoRoute(
      path: '/onboarding/age-category',
      builder: (context, state) => const AgeCategoryScreen(),
    ),

    // Main App Flow
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        // Nested routes
        GoRoute(
          path: 'feed',
          builder: (context, state) => const FeedScreen(),
        ),
        GoRoute(
          path: 'search',
          builder: (context, state) => const SearchScreen(),
        ),
      ],
    ),

    // Detail screens
    GoRoute(
      path: '/policy/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PolicyDetailScreen(policyId: id);
      },
    ),
  ],
);
```

### 네비게이션 패턴

**1. 단순 이동** (`context.go()`):
```dart
// 화면 이동 (스택 교체)
context.go('/onboarding/age-category');
```

**2. 스택에 추가** (`context.push()`):
```dart
// 화면 추가 (뒤로가기 가능)
context.push('/policy/123');
```

**3. 뒤로가기** (`context.pop()`):
```dart
// 이전 화면으로
context.pop();
```

**4. 파라미터 전달**:
```dart
// URL 파라미터
context.go('/policy/${policyId}');

// 쿼리 파라미터
context.go('/search?query=주거지원');
```

---

## 상태 관리

### Riverpod 기반 상태 관리

Pickly는 **Riverpod**를 사용하여 선언적이고 테스트 가능한 상태 관리를 구현합니다.

**주요 개념**:
1. **Provider**: 상태의 단일 진실 공급원
2. **ConsumerWidget**: Provider를 구독하는 위젯
3. **AsyncValue**: 비동기 작업 상태 관리 (loading, data, error)
4. **Code Generation**: 보일러플레이트 코드 자동 생성

### Provider 구조

```
features/{feature}/providers/
├─ {entity}_provider.dart                # 주요 상태 관리
├─ {entity}_repository_provider.dart     # Repository 제공
└─ {entity}_state.dart                   # 상태 모델 (필요시)
```

### 예시: AgeCategoryProvider

```dart
// lib/features/onboarding/providers/age_category_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_mobile/contexts/user/repositories/age_category_repository.dart';

part 'age_category_provider.g.dart';

@riverpod
AgeCategoryRepository ageCategoryRepository(AgeCategoryRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AgeCategoryRepository(supabase);
}

@riverpod
class AgeCategory extends _$AgeCategory {
  @override
  Future<List<AgeCategoryModel>> build() async {
    final repository = ref.watch(ageCategoryRepositoryProvider);
    return await repository.fetchCategories();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> selectCategory(String categoryId) async {
    // 카테고리 선택 로직
  }
}
```

### 위젯에서 Provider 사용

```dart
// lib/features/onboarding/screens/age_category_screen.dart
class AgeCategoryScreen extends ConsumerWidget {
  const AgeCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider 구독
    final categoriesAsync = ref.watch(ageCategoryProvider);

    return Scaffold(
      body: categoriesAsync.when(
        // 데이터 로드 성공
        data: (categories) => ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return SelectionListItem(
              title: category.title,
              description: category.description,
              onTap: () {
                // Provider 메서드 호출
                ref.read(ageCategoryProvider.notifier).selectCategory(category.id);
              },
            );
          },
        ),
        // 로딩 중
        loading: () => const CircularProgressIndicator(),
        // 에러 발생
        error: (error, stack) => ErrorWidget(error),
      ),
    );
  }
}
```

---

## 테스트 전략

### 테스트 계층

Pickly는 **테스트 피라미드** 전략을 따릅니다:

```
        ┌─────────────────┐
        │  E2E Tests      │ (소수)
        │  (Integration)  │
        ├─────────────────┤
        │  Widget Tests   │ (중간)
        │  (UI Logic)     │
        ├─────────────────┤
        │  Unit Tests     │ (다수)
        │  (Business)     │
        └─────────────────┘
```

### 1. Unit Tests (단위 테스트)

**대상**: Contexts (모델, Repository)

**목적**: 비즈니스 로직 검증

**위치**: `test/contexts/{domain}/`

**예시**:
```dart
// test/contexts/user/repositories/age_category_repository_test.dart
void main() {
  late AgeCategoryRepository repository;
  late MockSupabaseClient mockSupabase;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    repository = AgeCategoryRepository(mockSupabase);
  });

  group('AgeCategoryRepository', () {
    test('fetchCategories returns list of categories', () async {
      // Arrange
      when(() => mockSupabase.from('age_categories').select())
          .thenAnswer((_) async => mockCategoryData);

      // Act
      final categories = await repository.fetchCategories();

      // Assert
      expect(categories, isA<List<AgeCategory>>());
      expect(categories.length, 6);
    });

    test('fetchCategories throws exception on error', () async {
      // Arrange
      when(() => mockSupabase.from('age_categories').select())
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => repository.fetchCategories(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
```

### 2. Widget Tests (위젯 테스트)

**대상**: Features (화면, 위젯)

**목적**: UI 로직 및 사용자 인터랙션 검증

**위치**: `test/features/{feature}/`

**예시**:
```dart
// test/features/onboarding/screens/age_category_screen_test.dart
void main() {
  testWidgets('displays categories when data is loaded', (tester) async {
    // Arrange
    final container = ProviderContainer(
      overrides: [
        ageCategoryProvider.overrideWith((ref) async => mockCategories),
      ],
    );

    // Act
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('청소년 (13~18세)'), findsOneWidget);
    expect(find.byType(SelectionListItem), findsNWidgets(6));
  });

  testWidgets('shows loading indicator while fetching', (tester) async {
    // Arrange
    final container = ProviderContainer(
      overrides: [
        ageCategoryProvider.overrideWith((ref) async {
          await Future.delayed(const Duration(seconds: 1));
          return mockCategories;
        }),
      ],
    );

    // Act
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      ),
    );

    // Assert (로딩 상태)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Act (데이터 로드 완료)
    await tester.pumpAndSettle();

    // Assert (데이터 표시)
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(SelectionListItem), findsNWidgets(6));
  });
}
```

### 3. Integration Tests (통합 테스트)

**대상**: 전체 사용자 플로우

**목적**: End-to-End 시나리오 검증

**위치**: `integration_test/`

**예시**:
```dart
// integration_test/onboarding_flow_test.dart
void main() {
  testWidgets('complete onboarding flow', (tester) async {
    // Arrange
    await tester.pumpWidget(const PicklyApp());

    // Act: Splash 화면 확인
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Act: 온보딩 시작
    expect(find.byType(StartScreen), findsOneWidget);
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();

    // Act: 연령 카테고리 선택
    expect(find.byType(AgeCategoryScreen), findsOneWidget);
    await tester.tap(find.text('청년 (19~34세)'));
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    // Assert: 다음 화면으로 이동
    expect(find.byType(RegionSelectionScreen), findsOneWidget);
  });
}
```

### 테스트 커버리지 목표

- **Unit Tests**: 80% 이상 (Contexts)
- **Widget Tests**: 60% 이상 (Features)
- **Integration Tests**: 주요 사용자 플로우 커버

---

## 부록

### A. 디렉토리 생성 스크립트

새로운 Feature를 추가할 때 사용하는 스크립트:

```bash
#!/bin/bash
# scripts/create_feature.sh

FEATURE_NAME=$1

if [ -z "$FEATURE_NAME" ]; then
  echo "Usage: ./scripts/create_feature.sh <feature_name>"
  exit 1
fi

mkdir -p "apps/pickly_mobile/lib/features/$FEATURE_NAME/screens"
mkdir -p "apps/pickly_mobile/lib/features/$FEATURE_NAME/providers"
mkdir -p "apps/pickly_mobile/lib/features/$FEATURE_NAME/widgets"
mkdir -p "apps/pickly_mobile/test/features/$FEATURE_NAME"

echo "✅ Feature '$FEATURE_NAME' structure created!"
```

### B. Import 순서 예시

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter SDK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. 외부 패키지
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 4. Design System
import 'package:pickly_design_system/pickly_design_system.dart';

// 5. Contexts (도메인 모델)
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_mobile/contexts/user/repositories/age_category_repository.dart';

// 6. Features/Core
import 'package:pickly_mobile/features/onboarding/providers/age_category_provider.dart';
import 'package:pickly_mobile/features/onboarding/widgets/onboarding_header.dart';
import 'package:pickly_mobile/core/router.dart';
```

### C. 자주 묻는 질문 (FAQ)

**Q: Feature 간에 위젯을 공유하고 싶은데 어떻게 하나요?**

A: Design System으로 이동시키세요. 두 개 이상의 Feature에서 사용되는 위젯은 `packages/pickly_design_system/`로 이동합니다.

**Q: Context에서 다른 Context를 참조해도 되나요?**

A: 네, 가능합니다. 단, 순환 참조를 피해야 합니다. 예: User → Policy (O), Policy → User (단방향 유지)

**Q: 테스트 파일은 어디에 두나요?**

A: `test/` 폴더에 `lib/`과 동일한 구조로 생성합니다. 예: `lib/features/onboarding/screens/splash_screen.dart` → `test/features/onboarding/screens/splash_screen_test.dart`

**Q: 상대 경로를 사용할 수 없나요?**

A: 아니요, 모든 import는 절대 경로(`package:`)를 사용해야 합니다. IDE 자동 완성 및 리팩토링 도구와의 호환성을 위해 필수입니다.

---

## 변경 이력

### v5.4 (2025.10.12)
- 프로젝트 구조 상세 문서 신규 작성
- 모노레포 구조 설명 추가
- Feature-First 조직화 가이드
- 의존성 다이어그램 추가
- 테스트 전략 상세화

---

✍️ 이 문서는 Pickly Mobile 프로젝트의 아키텍처와 구조를 설명합니다.
신규 개발자는 본 문서를 먼저 읽고 개발을 시작하시기 바랍니다.
