#!/bin/bash

# Pickly 문서 자동 업데이트 스크립트
# 공통 구조 방식에 맞게 docs/ 폴더 재구성

set -e

echo "📚 Pickly 문서 업데이트 시작"
echo "=============================="

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# 1. 문서 디렉토리 확인
echo -e "${BLUE}📁 1. 문서 디렉토리 확인${NC}"
if [ ! -d "docs" ]; then
    mkdir -p docs
fi
echo -e "${GREEN}✅ 확인 완료${NC}"

# 2. 문서 구조 생성
echo -e "\n${BLUE}📂 2. 문서 구조 생성${NC}"
mkdir -p docs/development
mkdir -p docs/architecture
mkdir -p docs/guides
mkdir -p docs/api
echo -e "${GREEN}✅ 구조 생성 완료${NC}"

# 3. 온보딩 개발 가이드 (신규)
echo -e "\n${BLUE}📝 3. 온보딩 개발 가이드 생성${NC}"
cat > docs/development/onboarding-development-guide.md << 'EOF'
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
EOF
echo -e "${GREEN}✅ 온보딩 개발 가이드 생성 완료${NC}"

# 4. 아키텍처 문서 업데이트
echo -e "\n${BLUE}🏗️  4. 아키텍처 문서 업데이트${NC}"
cat > docs/architecture/common-agent-architecture.md << 'EOF'
# 공통 에이전트 아키텍처

> **재사용 가능한 에이전트 구조**

---

## 개요

Pickly는 **공통 에이전트 + 설정 기반** 개발 방식을 사용합니다.

### 기존 방식 (화면별 개별)
```
화면 1개 = 에이전트 6개 × 워크플로우 1개
→ 화면 5개 = 30개 파일 관리 ❌
```

### 현재 방식 (공통 + 설정)
```
에이전트 6개 (공통) + 설정 파일 N개
→ 화면 5개 = 11개 파일 관리 ✅
```

---

## 에이전트 목록

### 1. onboarding-coordinator (코디네이터)
- **역할**: 전체 온보딩 개발 총괄
- **위치**: `.claude/agents/core/`
- **작업**: 설정 읽고 → 에이전트 조율

### 2. onboarding-screen-builder (화면 생성)
- **역할**: UI 코드 자동 생성
- **위치**: `.claude/agents/specialists/`
- **입력**: JSON 설정
- **출력**: Flutter 화면 코드

### 3. onboarding-state-manager (상태 관리)
- **역할**: Controller + Repository 생성
- **출력**: Riverpod Provider

### 4. onboarding-database-manager (DB)
- **역할**: Supabase 스키마 관리
- **출력**: 마이그레이션 SQL

### 5. onboarding-admin-builder (백오피스)
- **역할**: React CRUD 페이지 생성
- **조건**: manageable: true인 경우만

### 6. onboarding-integration-tester (테스트)
- **역할**: E2E 테스트 자동 생성

---

## 워크플로우 구조

```yaml
name: onboarding-universal
coordinator: onboarding-coordinator

# 화면 목록 (여기만 수정!)
screens:
  - id: "003"
    config: ".claude/screens/003-age-category.json"

# Phase 1: DB
phase_database:
  - agent: database-manager

# Phase 2: 공통 컴포넌트
phase_common:
  - agent: screen-builder
  - agent: state-manager

# Phase 3: 화면별 (병렬!)
phase_screens:
  parallel: true
  for_each: screens
  tasks:
    - agent: screen-builder
    - agent: state-manager
    - agent: admin-builder (조건부)

# Phase 4: 테스트
phase_testing:
  - agent: integration-tester
```

---

## 데이터 흐름

```
1. JSON 설정 파일 작성
   ↓
2. Coordinator가 읽기
   ↓
3. 에이전트들에게 분배 (병렬)
   ├─ Screen Builder → Flutter 화면
   ├─ State Manager → Controller
   ├─ DB Manager → 스키마 (필요 시)
   └─ Admin Builder → 백오피스 (조건부)
   ↓
4. Tester가 검증
   ↓
5. 완료!
```

---

## 장점

### 1. 코드 중복 제거
- 공통 컴포넌트 한 번만 작성
- 화면별 차이점만 설정

### 2. 빠른 개발
- JSON 10분 vs 코드 2시간
- 70% 시간 절감

### 3. 일관성
- 모든 화면이 같은 패턴
- 유지보수 쉬움

### 4. 확장성
- 새 UI 타입 추가 용이
- 새 화면 추가 간단

---

## 확장 방법

### 새 UI 타입 추가

**예**: "carousel" 타입 추가

1. Screen Builder에 템플릿 추가
2. 설정에서 사용:
```json
{
  "ui": {
    "type": "carousel",
    "autoPlay": true
  }
}
```

### 새 데이터 소스 타입

**예**: "graphql" 타입

1. State Manager에 로직 추가
2. 설정에서 사용:
```json
{
  "dataSource": {
    "type": "graphql",
    "endpoint": "...",
    "query": "..."
  }
}
```

---

## 참고 문서

- [온보딩 개발 가이드](../development/onboarding-development-guide.md)
- [설정 파일 스키마](../api/screen-config-schema.md)
EOF
echo -e "${GREEN}✅ 아키텍처 문서 생성 완료${NC}"

# 5. 설정 파일 스키마 문서
echo -e "\n${BLUE}📋 5. 설정 파일 스키마 문서${NC}"
cat > docs/api/screen-config-schema.md << 'EOF'
# 화면 설정 파일 스키마

> **온보딩 화면 JSON 설정 스키마 정의**

---

## 기본 구조

```typescript
interface ScreenConfig {
  // 필수
  id: string;                    // "001", "002" 등
  name: string;                  // "personal-info", "age-category" 등
  title: string;                 // 화면 제목
  step: number;                  // 현재 단계 (1부터 시작)
  totalSteps: number;            // 전체 단계 수
  
  // 데이터
  dataSource: DataSource;        // 데이터 소스 설정
  
  // UI
  ui: UIConfig;                  // UI 타입 및 설정
  
  // 검증
  validation: ValidationConfig;  // 검증 규칙
  
  // 네비게이션
  navigation: NavigationConfig;  // 화면 전환
  
  // 선택
  subtitle?: string;             // 부제목
  admin?: AdminConfig;           // 백오피스 설정
  analytics?: AnalyticsConfig;   // 분석 설정
}
```

---

## DataSource

```typescript
interface DataSource {
  table: string;                 // Supabase 테이블명
  type: 'realtime' | 'static' | 'form';
  
  // realtime/static 전용
  filters?: Record<string, any>; // WHERE 조건
  orderBy?: string;              // ORDER BY 필드
  
  // 저장 설정
  saveField?: string;            // 단일 필드
  saveFields?: string[];         // 복수 필드 (form)
}
```

**예시**:
```json
{
  "dataSource": {
    "table": "age_categories",
    "type": "realtime",
    "filters": { "is_active": true },
    "orderBy": "sort_order",
    "saveField": "selected_categories"
  }
}
```

---

## UIConfig

### selection-list

```typescript
interface SelectionListUI {
  type: 'selection-list';
  component: 'SelectionCard';
  selectionMode: 'single' | 'multiple';
  itemLayout: 'icon-card' | 'text-only';
  spacing?: number;              // 기본값: 12
  padding?: number;              // 기본값: 16
}
```

### form

```typescript
interface FormUI {
  type: 'form';
  fields: FormField[];
}

interface FormField {
  name: string;
  type: 'text' | 'number' | 'radio' | 'checkbox' | 'date';
  label: string;
  placeholder?: string;
  required?: boolean;
  
  // text 전용
  maxLength?: number;
  
  // number 전용
  min?: number;
  max?: number;
  
  // radio/checkbox 전용
  options?: Array<{
    value: string;
    label: string;
  }>;
}
```

### map

```typescript
interface MapUI {
  type: 'map';
  mapProvider: 'naver' | 'kakao' | 'google';
  fallback: 'list';
  initialZoom?: number;
}
```

### slider

```typescript
interface SliderUI {
  type: 'slider';
  min: number;
  max: number;
  divisions?: number;
  labels?: string[];
  showValue?: boolean;
}
```

---

## ValidationConfig

```typescript
interface ValidationConfig {
  // selection-list 전용
  minSelection?: number;
  maxSelection?: number;
  
  // form 전용
  allFieldsRequired?: boolean;
  
  // 공통
  errorMessage: string;
  customValidator?: string;      // 함수 이름
}
```

---

## NavigationConfig

```typescript
interface NavigationConfig {
  previous?: string;             // 이전 화면 경로
  next?: string;                 // 다음 화면 경로
  onBack?: 'saveProgress' | 'discard';
  onNext?: 'validateAndSave' | 'save';
  canSkip?: boolean;             // 건너뛰기 가능 여부
}
```

---

## AdminConfig

```typescript
interface AdminConfig {
  manageable: boolean;           // CRUD 페이지 생성 여부
  crudPage?: string;             // 페이지 컴포넌트명
  permissions?: string[];        // 권한 (기본값: ['admin'])
  features?: {
    create?: boolean;
    read?: boolean;
    update?: boolean;
    delete?: boolean;
    reorder?: boolean;           // 순서 변경
    toggleActive?: boolean;      // 활성화 토글
  };
}
```

---

## AnalyticsConfig

```typescript
interface AnalyticsConfig {
  trackSelection?: boolean;      // 선택 추적
  eventName?: string;            // 이벤트명
  customProperties?: Record<string, any>;
}
```

---

## 전체 예시

```json
{
  "id": "003",
  "name": "age-category",
  "title": "현재 연령 및 세대 기준을 선택해주세요",
  "subtitle": "나에게 맞는 정책과 혜택에 대해 안내해드려요",
  "step": 3,
  "totalSteps": 5,
  
  "dataSource": {
    "table": "age_categories",
    "type": "realtime",
    "filters": {
      "is_active": true
    },
    "orderBy": "sort_order",
    "saveField": "selected_categories"
  },
  
  "ui": {
    "type": "selection-list",
    "component": "SelectionCard",
    "selectionMode": "multiple",
    "itemLayout": "icon-card",
    "spacing": 12,
    "padding": 16
  },
  
  "validation": {
    "minSelection": 1,
    "errorMessage": "최소 1개 이상 선택해주세요"
  },
  
  "navigation": {
    "previous": "/onboarding/002-region",
    "next": "/onboarding/004-income",
    "onBack": "saveProgress",
    "onNext": "validateAndSave",
    "canSkip": false
  },
  
  "admin": {
    "manageable": true,
    "crudPage": "AgeCategoryManagement",
    "permissions": ["admin"],
    "features": {
      "create": true,
      "read": true,
      "update": true,
      "delete": true,
      "reorder": true,
      "toggleActive": true
    }
  },
  
  "analytics": {
    "trackSelection": true,
    "eventName": "onboarding_age_category_selected"
  }
}
```

---

## 검증 방법

```bash
# JSON 문법 검증
jq . .claude/screens/003-age-category.json

# 스키마 검증 (선택)
npx ajv-cli validate \
  -s docs/api/screen-config-schema.json \
  -d .claude/screens/*.json
```
EOF
echo -e "${GREEN}✅ 스키마 문서 생성 완료${NC}"

# 6. README 업데이트
echo -e "\n${BLUE}📄 6. README 업데이트${NC}"
cat > docs/README.md << 'EOF'
# Pickly 문서

> **프로젝트 문서 허브**

---

## 📚 문서 목록

### 개발 가이드
- [온보딩 화면 개발 가이드](development/onboarding-development-guide.md) ⭐
  - 공통 에이전트 + 설정 기반 개발 방식
  - 새 화면 추가 방법
  - UI 타입별 설정

### 아키텍처
- [공통 에이전트 아키텍처](architecture/common-agent-architecture.md) ⭐
  - 재사용 가능한 구조
  - 에이전트 목록
  - 워크플로우 설명

### API & 스키마
- [화면 설정 파일 스키마](api/screen-config-schema.md) ⭐
  - JSON 설정 정의
  - 타입별 옵션
  - 전체 예시

### 프로젝트 문서
- [PRD (Product Requirements Document)](PRD.md)
  - 제품 요구사항 정의
  - 기능 목록
  - 로드맵

---

## 🚀 빠른 시작

### 새 온보딩 화면 추가하기

1. **설정 파일 작성**
```bash
nano .claude/screens/006-new-screen.json
```

2. **워크플로우 등록**
```yaml
# .claude/workflows/onboarding-universal.yml
screens:
  - id: "006"
    config: ".claude/screens/006-new-screen.json"
```

3. **실행**
```bash
claude-flow orchestrate \
  --workflow .claude/workflows/onboarding-universal.yml \
  --screen 006
```

자세한 내용은 [온보딩 화면 개발 가이드](development/onboarding-development-guide.md) 참고!

---

## 📖 학습 경로

### 초보자
1. [온보딩 개발 가이드](development/onboarding-development-guide.md) 읽기
2. 003 화면 설정 파일 분석
3. 새 화면 하나 만들어보기

### 중급자
1. [공통 에이전트 아키텍처](architecture/common-agent-architecture.md) 이해
2. 커스텀 UI 타입 추가
3. 에이전트 로직 확장

### 고급자
1. 새 에이전트 작성
2. 워크플로우 최적화
3. 병렬 처리 개선

---

## 🔗 외부 링크

- [GitHub Repository](https://github.com/kwonhyunjun/pickly-service)
- [Figma Design](https://www.figma.com/design/xOpx8v3FiYmCxSLkj9sgcu/pickly)
- [Supabase Docs](https://supabase.com/docs)
- [Claude Flow](https://docs.anthropic.com/claude/docs/claude-flow)

---

## 💡 기여하기

문서 개선 아이디어가 있으신가요?

1. 이슈 생성
2. PR 제출
3. 또는 팀에 직접 제안

모든 기여를 환영합니다! 🎉
EOF
echo -e "${GREEN}✅ README 생성 완료${NC}"

# 7. Git 커밋
echo -e "\n${BLUE}💾 7. 문서 커밋${NC}"
git add docs/
git commit -m "docs: update documentation for common agent structure

- 온보딩 개발 가이드 (신규)
- 공통 에이전트 아키텍처 (신규)
- 화면 설정 스키마 (신규)
- README 업데이트
" 2>/dev/null || echo "Already committed or no changes"
echo -e "${GREEN}✅ 커밋 완료${NC}"

# 완료
echo -e "\n${GREEN}=============================="
echo "✨ 문서 업데이트 완료!"
echo "==============================${NC}"

echo -e "\n📚 생성된 문서:"
echo "  ✅ docs/development/onboarding-development-guide.md"
echo "  ✅ docs/architecture/common-agent-architecture.md"
echo "  ✅ docs/api/screen-config-schema.md"
echo "  ✅ docs/README.md"
echo ""
echo "📖 문서 확인:"
echo "  cat docs/README.md"
echo ""
echo "🌐 또는 브라우저에서 보기:"
echo "  open docs/README.md  # Mac"
echo "  start docs/README.md  # Windows"