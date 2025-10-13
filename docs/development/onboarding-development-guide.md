# 온보딩 화면 개발 가이드

> **공통 에이전트 + 설정 기반 개발 방식**

---

## 🎯 개요

Pickly의 온보딩 화면은 **설정 파일 기반**으로 개발됩니다.
새로운 화면을 추가할 때 JSON 설정 파일만 작성하면, Claude Flow가 나머지를 자동으로 생성합니다.

---

## 📁 프로젝트 구조 (2025.10.11 업데이트)

### 디렉토리 구조

```
lib/
├─ contexts/user/           # User Context (DDD)
│  ├─ models/
│  │  └─ age_category.dart  ✅ 공식 모델 위치 (contexts/user/models 사용)
│  └─ repositories/
│     └─ age_category_repository.dart
│
├─ features/onboarding/     # Onboarding Feature
│  ├─ screens/
│  │  ├─ splash_screen.dart
│  │  └─ age_category_screen.dart
│  ├─ providers/
│  │  └─ age_category_provider.dart  ✅ Riverpod AsyncNotifier
│  └─ widgets/
│     ├─ onboarding_header.dart      (온보딩 전용, 로컬)
│     └─ selection_list_item.dart    (온보딩 전용, 로컬)
│
├─ core/
│  ├─ router.dart           ✅ GoRouter 설정
│  └─ services/
│
└─ main.dart

packages/pickly_design_system/   # 공통 디자인 시스템
├─ lib/
│  ├─ pickly_design_system.dart  ✅ 메인 진입점 (모든 위젯 export)
│  └─ widgets/
│     ├─ buttons/
│     │  └─ pickly_button.dart
│     ├─ selection/
│     │  ├─ selection_list_item.dart  (v5.3+)
│     │  ├─ selection_checkmark.dart  (v5.6+)
│     │  └─ selection_chip.dart       (v5.7+)
│     ├─ indicators/
│     │  └─ progress_bar.dart
│     └─ app_header.dart
└─ assets/icons/
   └─ age_categories/       ✅ Figma 아이콘

examples/                   # 예제 및 참조 코드
└─ onboarding/
   └─ age_category_screen_example.dart
```

---

## 🧩 컴포넌트 구조 및 사용 규칙

### Import 규칙

**✅ 올바른 Import (권장 방식)**
```dart
// 모델 Import (contexts/user/models 사용 - 단일 진실 공급원)
import 'package:pickly_mobile/contexts/user/models/age_category.dart';

// Repository Import
import 'package:pickly_mobile/contexts/user/repositories/age_category_repository.dart';

// Provider Import
import 'package:pickly_mobile/features/onboarding/providers/age_category_provider.dart';

// ✅ Design System (단일 진입점 - 모든 공통 위젯)
import 'package:pickly_design_system/pickly_design_system.dart';

// 온보딩 전용 위젯 (로컬 위젯)
import 'package:pickly_mobile/features/onboarding/widgets/onboarding_header.dart';
```

**✅ 개별 Import도 가능 (필요시)**
```dart
// Design System 위젯 개별 Import
import 'package:pickly_design_system/widgets/buttons/pickly_button.dart';
import 'package:pickly_design_system/widgets/selection/selection_list_item.dart';
import 'package:pickly_design_system/widgets/selection/selection_checkmark.dart';
import 'package:pickly_design_system/widgets/selection/selection_chip.dart';
import 'package:pickly_design_system/widgets/indicators/progress_bar.dart';
import 'package:pickly_design_system/widgets/app_header.dart';
```

**❌ 잘못된 Import**
```dart
// ❌ 삭제된 중복 파일 (v5.2에서 제거됨)
import 'package:pickly_mobile/core/models/age_category.dart';

// ❌ 상대 경로 사용 금지 (절대 경로 사용 필수)
import '../models/age_category.dart';

// ❌ 제거된 미사용 컨트롤러
import '../providers/age_category_controller.dart';

// ❌ 삭제된 구 경로 (v5.3에서 Design System으로 이동됨)
import 'package:pickly_design_system/src/components/selection/selection_card.dart';
```

---

### 위젯 소스 구분

#### Design System (공통 위젯)

**항상 `pickly_design_system` 패키지에서 import**

**Selection 컴포넌트:**
- **SelectionListItem** (v5.3+) - 전체 너비 선택 리스트 아이템
  - 용도: 세로 리스트 레이아웃 (연령/세대 선택)
  - 특징: 아이콘 + 제목 + 설명 + 체크마크
  - 위치: `lib/widgets/selection/selection_list_item.dart`

- **SelectionCheckmark** (v5.6+) - 재사용 가능한 체크마크 컴포넌트
  - 용도: 선택 상태 표시 (단독 사용 가능)
  - 특징: 애니메이션, 크기 변형 지원
  - 위치: `lib/widgets/selection/selection_checkmark.dart`

- **SelectionChip** (v5.7+) - 컴팩트 칩 버튼
  - 용도: 가로 배치 선택 (지역, 필터, 태그)
  - 특징: Large/Small 변형, Wrap 레이아웃
  - 위치: `lib/widgets/selection/selection_chip.dart`

**기타 공통 컴포넌트:**
- **PicklyButton** - 기본 버튼 (Primary/Secondary 변형)
- **AppHeader** - 앱바 헤더 (뒤로가기, 메뉴 등)
- **ProgressBar** - 진행률 표시
- 기타 공통 UI 컴포넌트

#### 로컬 온보딩 위젯

**`lib/features/onboarding/widgets/`에 위치**

- **OnboardingHeader** - 온보딩 화면 전용 헤더
  - 용도: 온보딩 화면의 타이틀/서브타이틀 표시
  - 특징: 온보딩 화면에만 사용되는 특수 레이아웃

---

### 컴포넌트 사용 가이드

#### 1. 새 위젯 생성 전 체크리스트

새로운 위젯을 만들기 전 **반드시** 확인:

- [ ] Design System에 유사한 컴포넌트가 있는가?
- [ ] 기존 컴포넌트를 확장/변형할 수 있는가?
- [ ] 다른 화면에서도 재사용 가능한가?

**재사용 가능하면** → Design System에 추가
**온보딩 전용이면** → 로컬 위젯으로 생성

#### 2. 언제 Design System에 추가할까?

**Design System 추가 조건 (다음 중 하나라도 해당):**
- ✅ 2개 이상의 화면/기능에서 사용
- ✅ 기본 UI 패턴 (버튼, 카드, 칩, 입력 등)
- ✅ 앱 전체에서 일관성이 필요한 컴포넌트
- ✅ 디자인 시스템에 정의된 컴포넌트

**로컬 위젯으로 유지 조건:**
- ✅ 특정 기능에만 사용 (온보딩 전용 등)
- ✅ 비즈니스 로직에 강하게 결합
- ✅ 재사용 가능성 낮음

#### 3. Selection 컴포넌트 선택 가이드

| 컴포넌트 | 레이아웃 | 사용 시기 | 예시 화면 |
|---------|---------|----------|----------|
| **SelectionListItem** | 세로 리스트 (ListView) | 아이콘+설명이 필요한 옵션 | 연령/세대 선택 |
| **SelectionChip** | 가로 그리드 (Wrap) | 간단한 라벨, 다중 선택 | 지역 선택 |
| **SelectionCheckmark** | 단독 사용 | 커스텀 선택 UI 구현 | 커스텀 카드 |

**선택 기준:**
- 설명이 필요하면 → SelectionListItem
- 간단한 라벨만 → SelectionChip
- 커스텀 레이아웃 → SelectionCheckmark 단독 사용

---

### 파일 위치 원칙

1. **모델**: 항상 `lib/contexts/{domain}/models/`
2. **Repository**: 항상 `lib/contexts/{domain}/repositories/`
3. **화면**: `lib/features/{feature}/screens/`
4. **상태관리**: `lib/features/{feature}/providers/`
5. **공통 위젯**: `packages/pickly_design_system/lib/widgets/`
6. **기능별 위젯**: `lib/features/{feature}/widgets/`
7. **예제**: `examples/{feature}/`

---

### 실전 예시

#### 연령/세대 선택 화면 (SelectionListItem)

```dart
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/contexts/user/models/age_category.dart';

// ListView 기반 세로 레이아웃
ListView.separated(
  itemCount: categories.length,
  separatorBuilder: (context, index) => const SizedBox(height: 8),
  itemBuilder: (context, index) {
    final category = categories[index];
    return SelectionListItem(
      // SVG 아이콘 (Design System assets)
      iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/${category.iconComponent}.svg',
      title: category.name,           // '청년'
      description: category.description,  // '만 19세 ~ 34세'
      isSelected: _selectedId == category.id,
      onTap: () => _handleSelection(category.id),
    );
  },
)
```

#### 지역 선택 화면 (SelectionChip)

```dart
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/contexts/user/models/region.dart';

// Wrap 기반 가로 그리드 레이아웃
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: regions.map((region) {
    return SelectionChip(
      label: region.name,  // '서울', '부산' 등
      isSelected: _selectedIds.contains(region.id),
      size: ChipSize.large,
      onTap: () => _handleSelection(region.id),
    );
  }).toList(),
)
```

#### 커스텀 선택 UI (SelectionCheckmark)

```dart
import 'package:pickly_design_system/pickly_design_system.dart';

// 커스텀 카드에 체크마크 추가
GestureDetector(
  onTap: () => _handleSelect(item.id),
  child: Stack(
    children: [
      // 커스텀 카드 디자인
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
        child: Text(item.title),
      ),

      // 우측 상단에 체크마크
      Positioned(
        top: 8,
        right: 8,
        child: SelectionCheckmark(
          isSelected: isSelected,
          size: 20,
        ),
      ),
    ],
  ),
)
```

## 📋 새 화면 추가 방법

### 1단계: 설정 파일 작성

**경로**: `.claude/screens/{화면ID}-{화면명}.json`

**예시**: `.claude/screens/006-preference.json`

```json
{
  "id": "006",
  "name": "preference",
  "title": "선호하는 정책 유형을 선택해주세요",
  "subtitle": "맞춤 추천에 활용됩니다",
  "step": 6,
  "totalSteps": 6,
  
  "dataSource": {
    "table": "policy_types",
    "type": "realtime",
    "filters": { "is_active": true },
    "orderBy": "sort_order",
    "saveField": "preferred_policy_types"
  },
  
  "ui": {
    "type": "selection-list",
    "component": "SelectionCard",
    "selectionMode": "multiple",
    "itemLayout": "icon-card"
  },
  
  "validation": {
    "minSelection": 1,
    "errorMessage": "최소 1개 이상 선택해주세요"
  },
  
  "navigation": {
    "previous": "/onboarding/005-interests",
    "next": "/home"
  },
  
  "admin": {
    "manageable": true,
    "crudPage": "PolicyTypeManagement"
  }
}
```

### 2단계: 워크플로우 등록

**파일**: `.claude/workflows/onboarding-universal.yml`

```yaml
screens:
  # ... 기존 화면들
  - id: "006"
    config: ".claude/screens/006-preference.json"
```

### 3단계: 실행

```bash
# 특정 화면만
claude-flow orchestrate \
  --workflow .claude/workflows/onboarding-universal.yml \
  --screen 006

# 또는 전체
claude-flow orchestrate \
  --workflow .claude/workflows/onboarding-universal.yml
```

---

## 🎨 UI 타입별 설정

### 1. selection-list (카드 선택)

**사용 예**: 003 (연령/세대), 005 (관심 정책)

```json
{
  "ui": {
    "type": "selection-list",
    "component": "SelectionCard",
    "selectionMode": "multiple",  // 또는 "single"
    "itemLayout": "icon-card"
  }
}
```

**생성 결과**:
- ListView with SelectionCard
- Realtime 구독 (dataSource.type이 "realtime"인 경우)
- 다중/단일 선택 상태 관리

---

### 2. form (폼 입력)

**사용 예**: 001 (개인정보)

```json
{
  "ui": {
    "type": "form",
    "fields": [
      {
        "name": "name",
        "type": "text",
        "label": "이름",
        "required": true,
        "maxLength": 20
      },
      {
        "name": "age",
        "type": "number",
        "label": "나이",
        "required": true,
        "min": 1,
        "max": 120
      },
      {
        "name": "gender",
        "type": "radio",
        "label": "성별",
        "required": true,
        "options": [
          { "value": "male", "label": "남성" },
          { "value": "female", "label": "여성" }
        ]
      }
    ]
  }
}
```

**생성 결과**:
- Form + TextFormField
- 자동 검증 로직
- 포커스 관리

---

### 3. map (지도 선택)

**사용 예**: 002 (지역 선택)

```json
{
  "ui": {
    "type": "map",
    "mapProvider": "naver",
    "fallback": "list"
  }
}
```

---

### 4. slider (범위 선택)

**사용 예**: 004 (소득 구간)

```json
{
  "ui": {
    "type": "slider",
    "min": 0,
    "max": 100,
    "divisions": 5,
    "labels": ["기초생활", "저소득", "중위소득", "고소득"]
  }
}
```

---

## 🗄️ 데이터 소스 타입

### realtime (실시간 동기화)

관리자가 백오피스에서 수정하면 즉시 반영

```json
{
  "dataSource": {
    "table": "age_categories",
    "type": "realtime",
    "filters": { "is_active": true },
    "orderBy": "sort_order"
  }
}
```

**자동 생성**:
- Supabase Realtime 구독
- Stream 기반 상태 관리

---

### static (정적 데이터)

초기 로드 한 번만

```json
{
  "dataSource": {
    "table": "regions",
    "type": "static"
  }
}
```

---

### form (폼 전용)

DB 읽기 없음, 저장만

```json
{
  "dataSource": {
    "table": "user_profiles",
    "type": "form",
    "saveFields": ["name", "age", "gender"]
  }
}
```

---

## 🖥️ 백오피스 CRUD 자동 생성

설정에 `"manageable": true` 추가 시:

```json
{
  "admin": {
    "manageable": true,
    "crudPage": "AgeCategoryManagement",
    "features": {
      "create": true,
      "read": true,
      "update": true,
      "delete": true,
      "reorder": true,
      "toggleActive": true
    }
  }
}
```

**자동 생성 결과**:
- React 관리 페이지
- MUI DataGrid
- 추가/수정 Dialog
- 드래그앤드롭 순서 변경
- Realtime 동기화

---

## 🧪 테스트 자동 생성

모든 화면에 대해 자동으로 생성:

```dart
// test/features/onboarding/screens/{name}_screen_test.dart
testWidgets('Should display title and subtitle', ...);
testWidgets('Should validate before allowing next', ...);
testWidgets('Should save data on next button', ...);
```

---

## 📊 현재 온보딩 화면 목록

| ID | 화면명 | UI 타입 | Selection | Component | 상태 |
|----|--------|---------|-----------|-----------|------|
| 001 | 연령/세대 | selection-list | Single | SelectionListItem | ✅ 구현 완료 |
| 002 | 지역선택 | chip-grid | Multi | SelectionChip (v5.7) | ✅ 구현 완료 |
| 003 | TBD | - | - | - | 📅 대기 중 |
| 004 | TBD | - | - | - | 📅 대기 중 |
| 005 | TBD | - | - | - | 📅 대기 중 |

**범례**:
- ✅ 구현 완료: 코드 작성 및 테스트 완료
- 🔄 진행 중: 현재 개발 중
- 📝 설계 완료: JSON 설정 파일 작성 완료
- 📅 대기 중: 구현 예정

---

## 💡 Selection Patterns (Updated v5.5)

### Single vs Multi-Selection

**Policy**: Onboarding filters use **single-selection** pattern.

**Rationale**:
- Primary demographic filters (age, income) require one definitive answer
- Simplifies user decision-making
- Clearer data for personalization
- Better user experience for filtering

### Implementing Single Selection

**State Management:**
```dart
// ❌ Don't use Set for single selection
final Set<String> _selectedIds = {};

// ✅ Use nullable String
String? _selectedId;
```

**Selection Handler:**
```dart
void _handleSelection(String id) {
  setState(() {
    // Single selection: radio button behavior
    if (_selectedId == id) {
      _selectedId = null; // Deselect if clicking same
    } else {
      _selectedId = id; // Select new (auto-deselect previous)
    }
  });
}
```

**Validation:**
```dart
// ✅ Simple null check
if (_selectedId == null) {
  // No selection
  return;
}

// Button enable logic
onPressed: _selectedId != null ? _handleNext : null,
```

**UI Check:**
```dart
// In itemBuilder
final isSelected = _selectedId == item.id;

SelectionListItem(
  isSelected: isSelected,
  onTap: () => _handleSelection(item.id),
)
```

### When to Use Multi-Selection

Multi-selection should only be used for:
- Non-primary filters (preferences, interests)
- Optional selections where multiple choices are valid
- Must be explicitly approved by product team

### Visual Indicators

**Single Selection:**
- Use checkmark or radio button style
- Only one item marked at a time
- Clear visual feedback on selection change
- Consider adding radio button semantics for accessibility

**Multi Selection:**
- Use checkboxes
- Multiple items can have checkmarks
- Count indicator helpful (e.g., "3개 선택됨")

### Performance Considerations

**Single Selection Benefits:**
- Lighter state: `String?` (~16 bytes) vs `Set<String>` (~48+ bytes)
- Faster comparison: Direct equality `==` vs Set lookup `contains()`
- Less memory allocation: No Set object overhead
- Simpler code: Null check vs empty check

**Example Measurements:**
```dart
// Single selection: O(1) constant time
final isSelected = _selectedId == category.id;

// Multi selection: O(1) but with overhead
final isSelected = _selectedIds.contains(category.id);
```

---

## 💡 개발 팁

### 새 화면 추가 시 체크리스트

- [ ] `.claude/screens/{id}-{name}.json` 작성
- [ ] 워크플로우 yml에 등록
- [ ] DB 테이블 필요 시 마이그레이션 추가
- [ ] `user_profiles` 테이블에 저장 필드 추가 (필요 시)
- [ ] **선택 패턴 결정**: Single vs Multi (기본값: Single)
- [ ] Claude Flow 실행
- [ ] 테스트 확인
- [ ] 라우팅 연결 확인

### 공통 컴포넌트 재사용

직접 구현하지 말고 공통 위젯 사용:

```dart
// ✅ 좋은 예 - Design System 컴포넌트 사용
import 'package:pickly_design_system/pickly_design_system.dart';

PicklyButton.primary(
  text: '다음',
  onPressed: controller.isValid ? () => controller.save() : null,
)

SelectionListItem(
  title: '옵션',
  description: '설명',
  isSelected: true,
  onTap: () {},
)

SelectionChip(
  label: '서울',
  isSelected: true,
  onTap: () {},
)

// ❌ 나쁜 예 - 직접 구현 (Don't Repeat Yourself 위반)
Container(/* 헤더 직접 구현 */)
ElevatedButton(/* 버튼 직접 구현 */)
GestureDetector(/* 선택 카드 직접 구현 */)
```

---

## 🎨 Selection 컴포넌트 상세 가이드

### SelectionListItem (v5.3+)

**용도:** 세로 리스트 레이아웃, 아이콘과 설명이 포함된 선택 옵션

**실제 사용 화면:** 연령/세대 선택 (Step 1/5)

```dart
// Import
import 'package:pickly_design_system/pickly_design_system.dart';

// 기본 사용법 (아이콘 + 제목 + 설명)
SelectionListItem(
  iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/young_man.svg',
  title: '청년',
  description: '만 19세 ~ 34세',
  isSelected: _selectedId == category.id,
  onTap: () => _handleSelection(category.id),
)

// 아이콘 없이 사용
SelectionListItem(
  title: '옵션 제목',
  description: '옵션 설명',
  isSelected: isSelected,
  onTap: onSelect,
)

// Material Icon 사용
SelectionListItem(
  icon: Icons.home,
  title: '홈',
  isSelected: true,
  onTap: () {},
)

// 비활성화 상태
SelectionListItem(
  title: '사용 불가',
  enabled: false,
  isSelected: false,
)
```

**주요 속성:**
- `iconUrl`: SVG 아이콘 경로 (선택사항)
- `icon`: Material Icon (iconUrl이 없을 때 대체)
- `title`: 제목 (필수)
- `description`: 설명 (선택사항)
- `isSelected`: 선택 상태 (기본값: false)
- `onTap`: 탭 콜백
- `enabled`: 활성화 여부 (기본값: true)

**레이아웃:**
- 전체 너비 (width: double.infinity)
- 고정 높이 (72px)
- ListView.separated와 함께 사용

---

### SelectionChip (v5.7+)

**용도:** 가로 그리드 레이아웃, 간단한 라벨의 컴팩트 선택 옵션

**실제 사용 화면:** 지역 선택 (Step 2/5)

```dart
// Import
import 'package:pickly_design_system/pickly_design_system.dart';

// 기본 사용법 (Large - 기본값)
SelectionChip(
  label: '서울',
  isSelected: _selectedIds.contains('seoul'),
  onTap: () => _toggleRegion('seoul'),
)

// Small 변형 (컴팩트 UI)
SelectionChip(
  label: '주거',
  isSelected: _activeFilters.contains('housing'),
  size: ChipSize.small,
  onTap: () => _toggleFilter('housing'),
)

// Wrap으로 여러 칩 배치 (권장 패턴)
Wrap(
  spacing: 8,        // 가로 간격
  runSpacing: 8,     // 세로 간격
  children: regions.map((region) {
    return SelectionChip(
      label: region.name,
      isSelected: _selectedIds.contains(region.id),
      onTap: () => _toggleRegion(region.id),
    );
  }).toList(),
)

// 비활성화 상태
SelectionChip(
  label: '준비중',
  isSelected: false,
  enabled: false,
  onTap: null,
)
```

**주요 속성:**
- `label`: 칩에 표시될 텍스트 (필수)
- `isSelected`: 선택 상태 (필수)
- `size`: 칩 크기 (ChipSize.large | ChipSize.small)
- `onTap`: 탭 콜백
- `enabled`: 활성화 여부 (기본값: true)

**Size Variants:**
| Size | 폰트 크기 | 최소 높이 | 체크마크 | 용도 |
|------|----------|----------|---------|------|
| **large** | 16px | 48px | 20px | 메인 선택 (지역 선택) |
| **small** | 14px | 36px | 16px | 필터, 태그 |

**레이아웃:**
- 인라인 너비 (내용에 맞춤)
- Wrap 위젯과 함께 사용 (자동 줄바꿈)
- 가로 배치, 반응형

---

### SelectionCheckmark (v5.6+)

**용도:** 커스텀 선택 UI 구현 시 체크마크만 필요한 경우

```dart
// Import
import 'package:pickly_design_system/pickly_design_system.dart';

// 단독 사용
SelectionCheckmark(
  isSelected: true,
  size: 24,
)

// 커스텀 카드에 추가
GestureDetector(
  onTap: () => _handleSelect(item.id),
  child: Stack(
    children: [
      // 커스텀 카드 디자인
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
        child: Text(item.title),
      ),

      // 우측 상단에 체크마크
      Positioned(
        top: 8,
        right: 8,
        child: SelectionCheckmark(
          isSelected: isSelected,
          size: 20,
        ),
      ),
    ],
  ),
)
```

**주요 속성:**
- `isSelected`: 선택 상태 (필수)
- `size`: 체크마크 크기 (기본값: 24)

---

### 컴포넌트 비교표

| 특성 | SelectionListItem | SelectionChip | SelectionCheckmark |
|------|------------------|---------------|-------------------|
| **레이아웃** | 전체 너비, 세로 리스트 | 인라인, 가로 그리드 | 단독 사용 |
| **크기** | 고정 (72px 높이) | 2가지 (Large/Small) | 크기 조절 가능 |
| **아이콘** | SVG/Material Icon | 체크마크만 | 체크마크만 |
| **텍스트** | 제목 + 설명 | 라벨만 | 없음 |
| **Container** | ListView | Wrap | Stack/Custom |
| **Use Case** | 상세 옵션 선택 | 간단한 다중 선택 | 커스텀 UI |
| **예시 화면** | 연령/세대 선택 | 지역 선택 | - |

### 선택 기준 플로우차트

```
선택 컴포넌트가 필요한가?
  │
  ├─ 기존 디자인 패턴인가?
  │   │
  │   ├─ YES: 아이콘과 설명이 필요한가?
  │   │   │
  │   │   ├─ YES → SelectionListItem
  │   │   │         (연령/세대, 관심사 등)
  │   │   │
  │   │   └─ NO: 간단한 라벨만 필요한가?
  │   │       │
  │   │       ├─ YES → SelectionChip
  │   │       │         (지역, 필터, 태그)
  │   │       │
  │   │       └─ NO → 커스텀 UI 필요
  │   │
  │   └─ NO: 완전히 새로운 디자인인가?
  │       │
  │       └─ YES → SelectionCheckmark 단독 사용
  │                 (기존 컴포넌트에 체크마크만 추가)
  │
  └─ 디자인 시스템에 추가 검토 필요

---

## 🌏 Region Selection Implementation (v6.0)

### Overview

The Region Selection screen (Step 2/5) allows users to select multiple regions they're interested in for personalized policy recommendations.

**Key Characteristics:**
- **Selection Mode**: Multi-selection (unlike age category's single-selection)
- **Data**: 17 Korean regions
- **Component**: SelectionChip (v5.7)
- **Layout**: Wrap widget (3 chips per row)
- **Progress**: 2/5 (40%)

### Database Schema

**regions table:**
```sql
CREATE TABLE public.regions (
  id UUID PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,     -- 'seoul', 'busan', etc.
  name TEXT NOT NULL,             -- '서울', '부산', etc.
  name_en TEXT,                   -- 'Seoul', 'Busan', etc.
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true
);
```

**user_regions table** (many-to-many junction table):
```sql
CREATE TABLE public.user_regions (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  region_id UUID REFERENCES regions(id),
  UNIQUE(user_id, region_id)
);
```

### 17 Korean Regions

```
특별시/광역시 (7): 서울, 부산, 대구, 인천, 광주, 대전, 울산
특별자치시 (1): 세종
도 (8): 경기, 강원, 충북, 충남, 전북, 전남, 경북, 경남
특별자치도 (1): 제주
```

### Implementation Files

```
lib/
├── contexts/user/
│   ├── models/
│   │   └── region.dart                      # Freezed model
│   └── repositories/
│       └── region_repository.dart           # Supabase data access
│
└── features/onboarding/
    ├── providers/
    │   └── region_provider.dart             # Riverpod state
    └── screens/
        └── region_selection_screen.dart     # UI implementation
```

### Code Example

**Provider (Riverpod):**
```dart
final regionsProvider = FutureProvider<List<Region>>((ref) async {
  final repository = ref.watch(regionRepositoryProvider);
  return repository.fetchRegions();
});

final selectedRegionsProvider = StateNotifierProvider<SelectedRegionsNotifier, Set<String>>(
  (ref) => SelectedRegionsNotifier(),
);

class SelectedRegionsNotifier extends StateNotifier<Set<String>> {
  SelectedRegionsNotifier() : super({});

  void toggle(String regionId) {
    if (state.contains(regionId)) {
      state = {...state}..remove(regionId);
    } else {
      state = {...state, regionId};
    }
  }
}
```

**Screen (UI):**
```dart
Widget build(BuildContext context, WidgetRef ref) {
  final regionsAsync = ref.watch(regionsProvider);
  final selectedRegions = ref.watch(selectedRegionsProvider);

  return Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          // Title and subtitle
          Text('지역을 선택해주세요'),

          // Chip grid
          Expanded(
            child: regionsAsync.when(
              data: (regions) => SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: regions.map((region) {
                    return SelectionChip(
                      label: region.name,
                      isSelected: selectedRegions.contains(region.id),
                      size: ChipSize.large,
                      onTap: () => ref
                          .read(selectedRegionsProvider.notifier)
                          .toggle(region.id),
                    );
                  }).toList(),
                ),
              ),
              loading: () => CircularProgressIndicator(),
              error: (err, _) => Text('Error: $err'),
            ),
          ),

          // Progress (2/5) and Complete button
          LinearProgressIndicator(value: 0.4),
          PicklyButton.primary(
            text: '완료 (${selectedRegions.length}개 선택됨)',
            onPressed: selectedRegions.isNotEmpty
                ? () => _handleComplete(context, ref)
                : null,
          ),
        ],
      ),
    ),
  );
}
```

### Multi-Selection Pattern

**State Management:**
```dart
// ✅ Use Set<String> for multi-selection
final Set<String> selectedRegions = {};

void toggleRegion(String regionId) {
  if (selectedRegions.contains(regionId)) {
    selectedRegions.remove(regionId);
  } else {
    selectedRegions.add(regionId);
  }
}

// Validation
if (selectedRegions.isEmpty) {
  // Show error: "최소 1개 이상 선택해주세요"
}
```

**Button State:**
```dart
// Dynamic text showing selection count
PicklyButton.primary(
  text: selectedRegions.isEmpty
      ? '완료'
      : '완료 (${selectedRegions.length}개 선택됨)',
  onPressed: selectedRegions.isNotEmpty ? _handleComplete : null,
)
```

### Database Operations

**Save User Regions (Transactional):**
```dart
Future<void> saveUserRegions(String userId, List<String> regionIds) async {
  // Delete old selections
  await client.from('user_regions')
      .delete()
      .eq('user_id', userId);

  // Insert new selections
  if (regionIds.isNotEmpty) {
    final records = regionIds.map((regionId) => {
      'user_id': userId,
      'region_id': regionId,
    }).toList();

    await client.from('user_regions').insert(records);
  }
}
```

### Layout Pattern

**Wrap Widget for Responsive Chip Grid:**
```dart
Wrap(
  spacing: 8,           // Horizontal gap between chips
  runSpacing: 8,        // Vertical gap between rows
  alignment: WrapAlignment.start,
  children: regions.map((region) {
    return SelectionChip(
      label: region.name,
      isSelected: selectedRegions.contains(region.id),
      size: ChipSize.large,
      onTap: () => toggleRegion(region.id),
    );
  }).toList(),
)
```

**Benefits of Wrap:**
- Automatic line breaks (3 chips per row on standard phones)
- Responsive layout (adapts to different screen sizes)
- No manual row/column calculations needed
- Even spacing with `spacing` and `runSpacing`

### Testing Checklist

- [ ] All 17 regions load from database
- [ ] Multi-selection works (toggle on/off)
- [ ] Selection state updates correctly
- [ ] Complete button enables with 1+ selections
- [ ] Button text shows selection count
- [ ] Progress bar shows 40% (2/5)
- [ ] Selections persist to database
- [ ] RLS policies prevent unauthorized access
- [ ] Loading state shows spinner
- [ ] Error state shows message

### Documentation

- **Implementation**: `docs/implementation/v6.0-region-selection.md`
- **Database**: `docs/database/README.md`
- **Component**: `docs/implementation/v5.7-chip-component.md`

---

## 🎨 UI Layout Best Practices (Learned from v5.4.3)

### Center Alignment in Columns
When Column has `crossAxisAlignment: CrossAxisAlignment.start`, text won't center even with `textAlign: TextAlign.center`.

**Problem**: Parent container's cross-axis alignment overrides child text alignment.

**Solution**: Wrap with Container to force full width

```dart
// ❌ Doesn't work
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Center me',
        textAlign: TextAlign.center, // Ignored!
      ),
    ),
  ],
)

// ✅ Works correctly
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Container(
      width: double.infinity, // Forces full width
      padding: const EdgeInsets.all(16),
      child: Text(
        'Center me',
        textAlign: TextAlign.center, // Now works!
      ),
    ),
  ],
)
```

**Why**: The `crossAxisAlignment: CrossAxisAlignment.start` makes all children align to the start of the cross axis. The Text widget only takes up as much width as needed for its content, so `textAlign: TextAlign.center` centers text within that narrow width (no visible effect). By wrapping with `Container(width: double.infinity)`, we force the Text to span the full width, making center alignment visible.

### SafeArea Spacing Calculations
**Formula**: `Total Distance from Top = SafeArea Height + Manual Spacing`

When translating Figma measurements to Flutter:

1. **Measure in Figma**: Total distance from top edge to element
2. **Account for SafeArea**: Usually ~44px on iOS, varies on Android
3. **Calculate manual spacing**: Subtract SafeArea from total
4. **Apply in code**: Use `SizedBox(height: calculated_value)`

**Example from Age Category screen:**
```dart
// Figma spec: Title at 116px from top
// SafeArea: ~44px (automatic, device-specific)
// Manual spacing needed: 116px - 44px = 72px

Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea( // Adds ~44px top padding
      child: Column(
        children: [
          const SizedBox(height: 72), // Manual spacing
          Text('Title'), // Now at ~116px from top
        ],
      ),
    ),
  );
}
```

**Important Notes**:
- SafeArea height varies by device (notch, status bar)
- Always test on multiple devices
- Use MediaQuery.of(context).padding.top for exact SafeArea height
- Document Figma measurements in code comments

### Design Token Override Strategy

**When to use design tokens:**
```dart
// ✅ Standard spacing - use tokens
const SizedBox(height: Spacing.md)  // 12px
const EdgeInsets.all(Spacing.lg)    // 16px
```

**When to override with exact values:**
```dart
// ✅ Figma specifies non-standard value - use exact measurement
const SizedBox(height: 8) // Figma: 8px between cards
const EdgeInsets.only(top: 72) // Figma: 116px - 44px SafeArea
```

**Best Practices:**
1. **Prefer tokens**: Use `Spacing.xs`, `Spacing.sm`, `Spacing.md`, etc. when possible
2. **Document overrides**: Always add comment explaining Figma spec
3. **Consistency check**: Ensure similar UI patterns use same values
4. **Design system feedback**: If overrides are common, propose new token

**Example:**
```dart
// ❌ No explanation
separatorBuilder: (context, index) => const SizedBox(height: 8),

// ✅ Documented override
separatorBuilder: (context, index) => const SizedBox(height: 8), // Figma spec: 8px between selection cards

// ✅ Even better - with rationale
// Figma spec: 8px card spacing for compact list appearance
// Note: Different from Spacing.md (12px) intentionally
separatorBuilder: (context, index) => const SizedBox(height: 8),
```

### Flex Container Alignment Gotchas

**Column Alignment:**
- `crossAxisAlignment` affects horizontal alignment of children
- `mainAxisAlignment` affects vertical alignment of children
- Child widgets' alignment properties can be overridden by parent

**Common Issues:**

```dart
// Issue 1: Center alignment ignored
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Center(child: Text('Hello')), // Still appears at start!
  ],
)

// Solution: Use crossAxisAlignment at Column level
Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Text('Hello'), // Now centered
  ],
)

// Issue 2: Text alignment doesn't work
Row(
  children: [
    Text('Hello', textAlign: TextAlign.end), // Doesn't align
  ],
)

// Solution: Wrap with Expanded or Container
Row(
  children: [
    Expanded(
      child: Text('Hello', textAlign: TextAlign.end), // Works!
    ),
  ],
)
```

### Responsive Spacing

Consider responsive spacing for different screen sizes:

```dart
// ❌ Fixed spacing might look wrong on tablets
const SizedBox(height: 72)

// ✅ Responsive spacing based on screen size
SizedBox(height: MediaQuery.of(context).size.height * 0.1)

// ✅ Clamped responsive spacing (best of both)
SizedBox(
  height: (MediaQuery.of(context).size.height * 0.1).clamp(48.0, 96.0),
)
```

**When to use each approach:**
- **Fixed**: Phone-only apps with consistent layouts
- **Responsive**: Apps targeting tablets and phones
- **Clamped**: Best practice - responsive with sensible min/max

---

## 🆘 트러블슈팅

### Claude Flow가 실행 안 됨
```bash
# MCP 확인
claude mcp list

# 재등록
claude mcp add claude-flow "npx claude-flow@alpha mcp start"
```

### 생성된 코드에 에러
```bash
# 분석
flutter analyze

# 포맷
dart format .

# 테스트
flutter test
```

### 설정 파일 문법 오류
```bash
# JSON 검증
jq . .claude/screens/006-preference.json
```

---

## 🎨 Figma Assets 연동

Pickly는 Figma 디자인의 아이콘을 자동으로 Flutter 코드에 연결합니다.

### 설정 방법

화면 설정 JSON에 `figma` 섹션을 추가:

```json
{
  "figma": {
    "designUrl": "https://www.figma.com/design/xOpx8v3FiYmCxSLkj9sgcu/pickly?node-id=481-10088",
    "componentSet": "Age Categories",
    "iconPath": "packages/pickly_design_system/assets/icons/age_categories/",
    "iconMapping": {
      "youth": "young_man.svg",
      "newlywed": "bride.svg",
      "parenting": "baby.svg",
      "multi_child": "kinder.svg",
      "elderly": "old_man.svg",
      "disability": "wheel_chair.svg"
    }
  }
}
```

### 워크플로우

1. **Figma에서 아이콘 내보내기**:
   - SVG 형식으로 내보내기
   - 파일명: `young_man.svg`, `bride.svg` 등

2. **Design System에 배치**:
   ```bash
   # 아이콘 복사
   cp icons/*.svg packages/pickly_design_system/assets/icons/age_categories/
   ```

3. **JSON 설정에 매핑 추가**:
   - `iconMapping`에 `"DB 값": "파일명.svg"` 형태로 추가

4. **자동 처리**:
   - Screen Builder가 `iconComponent` → `iconUrl` 자동 변환
   - Provider가 Mock 데이터에 올바른 경로 포함
   - `SelectionListItem` 위젯이 자동으로 SVG 로드

### 실제 사용 예시 (003 화면)

```dart
// DB에서 가져온 데이터
final category = AgeCategory(
  id: '1',
  name: '청년',
  description: '만 19세 ~ 34세',
  iconComponent: 'youth', // DB 저장 값
);

// iconMapping을 통해 자동 변환
// 'youth' → 'packages/pickly_design_system/assets/icons/age_categories/young_man.svg'

// SelectionListItem에서 자동 표시
SelectionListItem(
  iconUrl: iconPath, // 자동 변환된 경로
  title: category.name,
  description: category.description,
)
```

### 아이콘 요구사항

- **형식**: SVG (권장), PNG도 가능
- **크기**: 32x32px (자동 조정됨)
- **색상**: 단색 (컬러필터 적용 가능)
- **명명**: 소문자, 언더스코어 사용 (`young_man.svg`)

---

## 📚 참고 문서

- [Figma Assets Guide](./figma-assets-guide.md) 🆕
- [공통 에이전트 구조](../architecture/common-agent-architecture.md)
- [설정 파일 스키마](../api/screen-config-schema.md)
- [백오피스 개발](./admin-development-guide.md)
