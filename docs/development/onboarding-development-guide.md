# 온보딩 화면 개발 가이드

> **공통 에이전트 + 설정 기반 개발 방식**

---

## 🎯 개요

Pickly의 온보딩 화면은 **설정 파일 기반**으로 개발됩니다.
새로운 화면을 추가할 때 JSON 설정 파일만 작성하면, Claude Flow가 나머지를 자동으로 생성합니다.

---

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

| ID | 화면명 | UI 타입 | Realtime | 백오피스 | 상태 |
|----|--------|---------|----------|----------|------|
| 001 | 개인정보 | form | ❌ | ❌ | 📝 설계 완료 |
| 002 | 지역선택 | map | ❌ | ❌ | 📝 설계 완료 |
| 003 | 연령/세대 | selection-list | ✅ | ✅ | ✅ 구현 완료 |
| 004 | 소득구간 | slider | ❌ | ❌ | 📅 대기 중 |
| 005 | 관심정책 | selection-list | ✅ | ✅ | 📅 대기 중 |

**범례**:
- ✅ 구현 완료: 코드 작성 및 테스트 완료
- 🔄 진행 중: 현재 개발 중
- 📝 설계 완료: JSON 설정 파일 작성 완료
- 📅 대기 중: 구현 예정

---

## 💡 개발 팁

### 새 화면 추가 시 체크리스트

- [ ] `.claude/screens/{id}-{name}.json` 작성
- [ ] 워크플로우 yml에 등록
- [ ] DB 테이블 필요 시 마이그레이션 추가
- [ ] `user_profiles` 테이블에 저장 필드 추가 (필요 시)
- [ ] Claude Flow 실행
- [ ] 테스트 확인
- [ ] 라우팅 연결 확인

### 공통 컴포넌트 재사용

직접 구현하지 말고 공통 위젯 사용:

```dart
// ✅ 좋은 예
OnboardingHeader(currentStep: 3, totalSteps: 5)
NextButton(isEnabled: controller.isValid, onPressed: ...)

// ❌ 나쁜 예
Container(/* 헤더 직접 구현 */)
```

### SelectionListItem 사용 예시

**003 화면 (연령/세대 선택)**에서 사용된 실제 예시:

```dart
import 'package:pickly_mobile/features/onboarding/widgets/selection_list_item.dart';

// 기본 사용법
SelectionListItem(
  iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/young_man.svg',
  title: '청년',
  description: '만 19세 ~ 34세',
  isSelected: selectedIds.contains(category.id),
  onTap: () => controller.toggleSelection(category.id),
)

// 아이콘 없이 사용
SelectionListItem(
  title: '옵션 제목',
  description: '옵션 설명',
  isSelected: isSelected,
  onTap: onSelect,
)

// 비활성화 상태
SelectionListItem(
  title: '사용 불가',
  enabled: false,
  isSelected: false,
)
```

**주요 속성**:
- `iconUrl`: SVG 아이콘 경로 (선택사항)
- `icon`: Material Icon (iconUrl이 없을 때 대체)
- `title`: 제목 (필수)
- `description`: 설명 (선택사항)
- `isSelected`: 선택 상태 (기본값: false)
- `onTap`: 탭 콜백
- `enabled`: 활성화 여부 (기본값: true)

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
