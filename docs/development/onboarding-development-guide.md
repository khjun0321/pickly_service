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

| ID | 화면명 | UI 타입 | Realtime | 백오피스 |
|----|--------|---------|----------|----------|
| 001 | 개인정보 | form | ❌ | ❌ |
| 002 | 지역선택 | map | ❌ | ❌ |
| 003 | 연령/세대 | selection-list | ✅ | ✅ |
| 004 | 소득구간 | slider | ❌ | ❌ |
| 005 | 관심정책 | selection-list | ✅ | ✅ |

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

## 📚 참고 문서

- [공통 에이전트 구조](../architecture/common-agent-architecture.md)
- [설정 파일 스키마](../api/screen-config-schema.md)
- [백오피스 개발](./admin-development-guide.md)
