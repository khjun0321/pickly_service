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
