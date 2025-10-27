# 온보딩 아키텍처

> **Contexts/Features 분리 구조와 공통 컴포넌트 설계**

---

## 📐 전체 구조

```
apps/pickly_mobile/lib/
├── contexts/              # 도메인 로직 (UI 독립적)
│   └── user/
│       ├── models/
│       │   ├── user_profile.dart
│       │   └── age_category.dart
│       └── repositories/
│           ├── user_repository.dart
│           └── age_category_repository.dart
│
├── features/              # UI 레이어
│   └── onboarding/
│       ├── screens/       # 화면 (Screen)
│       │   ├── splash_screen.dart
│       │   ├── onboarding_start_screen.dart
│       │   ├── onboarding_household_screen.dart
│       │   ├── onboarding_region_screen.dart
│       │   └── age_category_screen.dart
│       │
│       ├── widgets/       # 재사용 가능한 위젯
│       │   ├── selection_list_item.dart    # 리스트 선택 아이템
│       │   ├── selection_card.dart         # 카드 선택 아이템
│       │   ├── onboarding_header.dart      # 단계 표시 헤더
│       │   └── next_button.dart            # 다음 버튼
│       │
│       └── providers/     # 상태 관리 (Riverpod)
│           └── age_category_provider.dart
│
└── core/                  # 공통 설정
    ├── router.dart        # GoRouter 라우팅
    ├── theme.dart         # 디자인 토큰
    └── supabase_config.dart
```

---

## 🎯 아키텍처 핵심 원칙

### 1. Contexts/Features 분리

**Contexts (도메인 레이어)**:
- UI에 의존하지 않는 순수 비즈니스 로직
- 모델(Model), 리포지토리(Repository), 서비스(Service)
- 다른 플랫폼(웹, 데스크톱)에서도 재사용 가능

**Features (UI 레이어)**:
- 사용자 인터페이스와 상태 관리
- 화면(Screen), 위젯(Widget), Provider
- Flutter 프레임워크에 의존

**장점**:
```dart
// ✅ 좋은 예: 도메인 로직 재사용
class AgeCategoryRepository {
  // 어떤 UI에서든 사용 가능
  Future<List<AgeCategory>> getCategories() { ... }
}

// ❌ 나쁜 예: UI와 비즈니스 로직 혼재
class AgeCategoryScreen {
  Future<List<AgeCategory>> _fetchFromSupabase() { ... }  // Repository 역할
}
```

---

### 2. Provider 패턴 (Riverpod)

**상태 관리 계층**:

```dart
// 1. Repository Provider (도메인 레이어)
final ageCategoryRepositoryProvider = Provider<AgeCategoryRepository>((ref) {
  return AgeCategoryRepository(supabase: supabase);
});

// 2. Controller/Notifier Provider (UI 상태)
final ageCategoryControllerProvider =
    StateNotifierProvider<AgeCategoryController, AgeCategoryState>((ref) {
  final repository = ref.watch(ageCategoryRepositoryProvider);
  return AgeCategoryController(repository: repository);
});

// 3. UI에서 사용
class AgeCategoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ageCategoryControllerProvider);
    // ...
  }
}
```

**의존성 흐름**:
```
Screen → Controller Provider → Repository Provider → Supabase
   ↑           ↑                      ↑
  UI      상태 관리              도메인 로직
```

---

### 3. Widget 재사용 전략

**공통 위젯 설계 원칙**:

1. **단일 책임**: 하나의 위젯은 하나의 역할만
2. **속성 주입**: 상태를 외부에서 주입받음
3. **Stateless 우선**: 가능하면 상태 없는 위젯
4. **접근성 고려**: Semantics 위젯 활용

**예시: SelectionListItem**

```dart
/// ✅ 좋은 설계:
/// - 상태를 외부에서 주입 (isSelected)
/// - 콜백으로 동작 전달 (onTap)
/// - 재사용 가능한 속성 (icon, iconUrl, title, description)
class SelectionListItem extends StatelessWidget {
  const SelectionListItem({
    this.iconUrl,
    required this.title,
    this.description,
    this.isSelected = false,
    this.onTap,
    this.enabled = true,
  });

  // 위젯은 "어떻게 보일지"만 결정
  // "어떤 데이터를 가져올지"는 Provider가 결정
}
```

**사용 예시**:

```dart
// 003 화면에서 사용
SelectionListItem(
  iconUrl: 'assets/icons/young_man.svg',
  title: '청년',
  description: '만 19세 ~ 34세',
  isSelected: controller.isSelected(id),
  onTap: () => controller.toggle(id),
)

// 다른 화면에서도 동일하게 재사용
SelectionListItem(
  iconUrl: 'assets/icons/family.svg',
  title: '다자녀 가구',
  description: '자녀 2명 이상',
  isSelected: state.selectedFamilyTypes.contains('multi_child'),
  onTap: () => controller.selectFamilyType('multi_child'),
)
```

---

## 🎨 Figma Assets 통합 방식

### 디자인 토큰 → Flutter 코드 변환

**1. Figma 디자인 시스템**:
```
Figma Design
  └─ Age Categories (Component Set)
      ├─ Young Man (Icon)
      ├─ Bride (Icon)
      ├─ Baby (Icon)
      └─ ...
```

**2. JSON 설정 매핑**:
```json
{
  "figma": {
    "iconPath": "packages/pickly_design_system/assets/icons/age_categories/",
    "iconMapping": {
      "youth": "young_man.svg",      // DB 값 → 파일명
      "newlywed": "bride.svg",
      "parenting": "baby.svg"
    }
  }
}
```

**3. 자동 경로 변환**:
```dart
// DB에서 가져온 값: "youth"
// iconMapping 적용: "young_man.svg"
// 최종 경로: "packages/pickly_design_system/assets/icons/age_categories/young_man.svg"

final iconPath = figmaConfig.iconPath + figmaConfig.iconMapping[dbValue];
```

**4. SelectionListItem에서 렌더링**:
```dart
SelectionListItem(
  iconUrl: iconPath,  // 자동 변환된 경로
  title: category.name,
)
```

### 장점

- **일관성**: 모든 아이콘이 Figma 디자인과 동일
- **자동화**: JSON 수정만으로 아이콘 변경
- **확장성**: 새 아이콘 추가 시 매핑만 추가
- **타입 안전성**: 잘못된 경로는 빌드 타임에 발견

---

## 🔄 데이터 흐름

### 1. Realtime 구독 (003 화면 예시)

```dart
// 1. Repository에서 Stream 제공
class AgeCategoryRepository {
  Stream<List<AgeCategory>> watchCategories() {
    return supabase
      .from('age_categories')
      .stream(primaryKey: ['id'])
      .map((list) => list.map((json) => AgeCategory.fromJson(json)).toList());
  }
}

// 2. Provider에서 구독
final ageCategoryStreamProvider = StreamProvider<List<AgeCategory>>((ref) {
  final repository = ref.watch(ageCategoryRepositoryProvider);
  return repository.watchCategories();
});

// 3. UI에서 사용
class AgeCategoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(ageCategoryStreamProvider);

    return categoriesAsync.when(
      data: (categories) => ListView.builder(...),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

**흐름**:
```
Supabase DB 변경
    ↓
Repository Stream 발행
    ↓
Provider 상태 업데이트
    ↓
UI 자동 리렌더링
```

### 2. 사용자 선택 저장

```dart
// 1. Controller에서 선택 관리
class AgeCategoryController extends StateNotifier<AgeCategoryState> {
  void toggleSelection(String id) {
    final newSelection = Set<String>.from(state.selectedIds);
    if (newSelection.contains(id)) {
      newSelection.remove(id);
    } else {
      newSelection.add(id);
    }
    state = state.copyWith(selectedIds: newSelection);
  }

  Future<void> saveSelections() async {
    await repository.saveUserCategories(state.selectedIds);
    // 다음 화면으로 이동
  }
}

// 2. UI에서 사용
NextButton(
  isEnabled: controller.isValid,
  onPressed: () => controller.saveSelections(),
)
```

---

## 🧪 테스트 전략

### Widget 테스트

```dart
testWidgets('SelectionListItem shows selected state', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SelectionListItem(
          title: '청년',
          isSelected: true,
          onTap: () {},
        ),
      ),
    ),
  );

  // 체크마크가 표시되는지 확인
  expect(find.byIcon(Icons.check), findsOneWidget);
});
```

### Provider 테스트

```dart
test('AgeCategoryController toggles selection', () {
  final container = ProviderContainer();
  final controller = container.read(ageCategoryControllerProvider.notifier);

  controller.toggleSelection('youth');
  expect(
    container.read(ageCategoryControllerProvider).selectedIds,
    contains('youth'),
  );

  controller.toggleSelection('youth');
  expect(
    container.read(ageCategoryControllerProvider).selectedIds,
    isEmpty,
  );
});
```

---

## 📦 패키지 구조

### Design System 패키지

```
packages/pickly_design_system/
├── lib/
│   ├── src/
│   │   ├── colors.dart      # 컬러 토큰
│   │   ├── typography.dart  # 타이포그래피
│   │   ├── spacing.dart     # 간격 토큰
│   │   └── animations.dart  # 애니메이션
│   └── pickly_design_system.dart
│
└── assets/
    └── icons/
        ├── age_categories/
        │   ├── young_man.svg
        │   ├── bride.svg
        │   └── ...
        └── common/
```

**사용법**:
```dart
// 디자인 토큰 import
import 'package:pickly_design_system/pickly_design_system.dart';

// 색상 사용
color: BrandColors.primary

// 타이포그래피 사용
style: PicklyTypography.bodyMedium

// 간격 사용
padding: EdgeInsets.all(Spacing.lg)
```

---

## 🚀 확장 가이드

### 새 온보딩 화면 추가

1. **JSON 설정 작성**:
```bash
touch .claude/screens/006-preference.json
```

2. **필요한 경우 새 Repository 생성**:
```dart
// contexts/policy/repositories/policy_type_repository.dart
class PolicyTypeRepository {
  Future<List<PolicyType>> getTypes() { ... }
}
```

3. **Provider 생성**:
```dart
// features/onboarding/providers/preference_provider.dart
final preferenceProvider = ...;
```

4. **공통 위젯 재사용**:
```dart
// SelectionListItem, OnboardingHeader 등 활용
```

### 새 공통 위젯 추가

1. **features/onboarding/widgets/ 에 생성**
2. **재사용 가능하게 설계** (상태 주입 방식)
3. **widgets.dart에 export**
4. **문서화 (주석 추가)**

---

## 📚 참고 문서

- [온보딩 개발 가이드](../development/onboarding-development-guide.md)
- [공통 에이전트 아키텍처](./common-agent-architecture.md)
- [화면 설정 스키마](../api/screen-config-schema.md)
- [PRD (Product Requirements)](../PRD.md)

---

## 💡 모범 사례

### ✅ 권장

- Contexts에는 UI 의존성 없는 순수 로직만
- 공통 위젯 최대한 재사용
- Provider로 상태 관리 (setState 지양)
- JSON 설정 기반 화면 생성 우선

### ❌ 지양

- Screen에서 직접 DB 접근
- 중복된 위젯 생성 (공통 위젯 먼저 확인)
- 하드코딩된 아이콘 경로 (Figma 매핑 활용)
- 과도한 상태 관리 (필요한 것만)

---

**작성일**: 2025.10.11
**버전**: 1.0
**상태**: ✅ 완성
