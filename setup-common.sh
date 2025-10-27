#!/bin/bash

# Pickly 온보딩 - 공통 에이전트 구조 자동 설정
# 모든 화면에 재사용 가능한 통합 시스템

set -e

echo "🚀 Pickly 온보딩 공통 구조 설정 시작"
echo "======================================"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# 1. 프로젝트 루트 확인
echo -e "${BLUE}📍 1. 프로젝트 루트 확인${NC}"
if [ ! -d "apps" ]; then
    echo "❌ pickly_service 루트에서 실행하세요"
    exit 1
fi
echo -e "${GREEN}✅ 확인 완료${NC}"

# 2. Git 브랜치
echo -e "\n${BLUE}📦 2. Git 브랜치 생성${NC}"
git checkout -b feature/onboarding-common-structure 2>/dev/null || \
git checkout feature/onboarding-common-structure
echo -e "${GREEN}✅ 브랜치 준비 완료${NC}"

# 3. 디렉토리 생성
echo -e "\n${BLUE}📁 3. 디렉토리 구조 생성${NC}"
mkdir -p .claude/agents/core
mkdir -p .claude/agents/specialists
mkdir -p .claude/workflows
mkdir -p .claude/screens
mkdir -p backend/supabase/migrations
echo -e "${GREEN}✅ 디렉토리 생성 완료${NC}"

# 4. 코디네이터
echo -e "\n${BLUE}🤖 4. 코디네이터 에이전트${NC}"
cat > .claude/agents/core/onboarding-coordinator.md << 'EOF'
---
name: pickly-onboarding-coordinator
type: coordinator
description: "모든 온보딩 화면 개발 총괄 - 설정 기반 자동화"
capabilities: [config_driven, code_generation, cross_platform]
priority: highest
memory: true
---

## 담당 화면
- 001: 개인정보 입력
- 002: 지역 선택
- 003: 연령/세대 선택
- 004: 소득 구간 선택
- 005: 관심 정책 선택

## 작동 방식
1. `.claude/screens/{screen_id}.json` 읽기
2. 설정 기반 코드 자동 생성
3. 공통 컴포넌트 최대 재사용

## 공통 패턴
- OnboardingHeader (진행률)
- Title + Subtitle
- NextButton (검증)
- 데이터 저장: user_profiles

## 화면 타입
- form: 텍스트 입력
- selection-list: 카드 선택
- map: 지도 선택
- slider: 범위 선택
EOF
echo -e "${GREEN}✅ 코디네이터 생성 완료${NC}"

# 5. 화면 빌더
echo -e "\n${BLUE}🎨 5. 화면 빌더 에이전트${NC}"
cat > .claude/agents/specialists/onboarding-screen-builder.md << 'EOF'
---
name: pickly-onboarding-screen-builder
type: specialist
description: "설정 파일 기반 온보딩 화면 자동 생성"
capabilities: [flutter_ui, config_parsing, component_reuse]
priority: high
---

## 역할
JSON 설정 → Flutter 화면 코드 생성

## 지원 UI 타입
1. selection-list: 카드 선택 (003, 005)
2. form: 폼 입력 (001)
3. map: 지도 (002)
4. slider: 슬라이더 (004)

## 공통 컴포넌트 재사용
```dart
OnboardingHeader(step, total)
NextButton(isEnabled, onPressed)
SelectionCard(title, description, icon)
```

## 생성 위치
lib/features/onboarding/screens/{name}_screen.dart
EOF
echo -e "${GREEN}✅ 화면 빌더 생성 완료${NC}"

# 6. 상태 관리자
echo -e "\n${BLUE}💾 6. 상태 관리자 에이전트${NC}"
cat > .claude/agents/specialists/onboarding-state-manager.md << 'EOF'
---
name: pickly-onboarding-state-manager
type: specialist
description: "온보딩 상태 관리 및 데이터 저장"
capabilities: [riverpod, state_management]
priority: high
---

## 역할
화면별 상태 관리 로직 자동 생성

## State 구조
```dart
class OnboardingState<T> {
  final List<T> items;
  final Set<String> selectedIds;
  final Map<String, dynamic> formData;
  final bool isLoading;
  
  bool get isValid; // 설정 기반 검증
}
```

## Controller 타입
- Selection Controller: 선택 관리
- Form Controller: 폼 관리

## 생성 위치
lib/features/onboarding/controllers/{name}_controller.dart
EOF
echo -e "${GREEN}✅ 상태 관리자 생성 완료${NC}"

# 7. DB 관리자
echo -e "\n${BLUE}🗄️  7. DB 관리자 에이전트${NC}"
cat > .claude/agents/specialists/onboarding-database-manager.md << 'EOF'
---
name: pickly-onboarding-database-manager
type: specialist
description: "온보딩 Supabase 스키마 관리"
capabilities: [database_design, supabase, realtime]
priority: highest
---

## 통합 스키마
- user_profiles: 사용자 선택 저장
- age_categories: 연령/세대 마스터
- regions: 지역 데이터
- policy_categories: 정책 카테고리

## RLS 정책
- 사용자: 자기 프로필만
- 마스터: 읽기 전용

## Realtime
- age_categories: 구독 필요
- policy_categories: 구독 필요
EOF
echo -e "${GREEN}✅ DB 관리자 생성 완료${NC}"

# 8. 백오피스 빌더
echo -e "\n${BLUE}🖥️  8. 백오피스 빌더 에이전트${NC}"
cat > .claude/agents/specialists/onboarding-admin-builder.md << 'EOF'
---
name: pickly-onboarding-admin-builder
type: specialist
description: "관리 가능 화면의 CRUD 페이지 생성"
capabilities: [react_ui, crud_operations, mui]
priority: medium
---

## 작동 조건
설정에 "manageable": true 있을 때만

## 생성 페이지
- 리스트 테이블 (MUI DataGrid)
- 추가/수정 Dialog
- 삭제 확인
- 순서 변경
- 활성화 토글
- Realtime 동기화

## 생성 위치
apps/admin/src/pages/{Name}Management.tsx
EOF
echo -e "${GREEN}✅ 백오피스 빌더 생성 완료${NC}"

# 9. 통합 테스터
echo -e "\n${BLUE}🧪 9. 통합 테스터 에이전트${NC}"
cat > .claude/agents/specialists/onboarding-integration-tester.md << 'EOF'
---
name: pickly-onboarding-integration-tester
type: specialist
description: "온보딩 전체 플로우 테스트"
capabilities: [integration_testing, e2e_testing]
priority: high
---

## 테스트 시나리오
1. 전체 플로우: 001→002→003→004→005
2. 화면별 검증 로직
3. Realtime 동기화 (003, 005)
4. 뒤로가기 복원

## 테스트 위치
test/features/onboarding/integration_test.dart
EOF
echo -e "${GREEN}✅ 통합 테스터 생성 완료${NC}"

# 10. 워크플로우
echo -e "\n${BLUE}⚙️  10. 통합 워크플로우${NC}"
cat > .claude/workflows/onboarding-universal.yml << 'EOF'
name: pickly-onboarding-universal
coordinator: pickly-onboarding-coordinator
parallel: true
memory: true

screens:
  - id: "001"
    config: ".claude/screens/001-personal-info.json"
  - id: "002"
    config: ".claude/screens/002-region-select.json"
  - id: "003"
    config: ".claude/screens/003-age-category.json"
  - id: "004"
    config: ".claude/screens/004-income-level.json"
  - id: "005"
    config: ".claude/screens/005-interests.json"

phase_database:
  - agent: onboarding-database-manager
    goal: "통합 스키마 생성"

phase_common:
  - agent: onboarding-screen-builder
    goal: "공통 위젯 생성"
  - agent: onboarding-state-manager
    goal: "공통 Repository"

phase_screens:
  parallel: true
  for_each: screens
  tasks:
    - agent: onboarding-screen-builder
      goal: "화면 생성 (${screen.id})"
    - agent: onboarding-state-manager
      goal: "상태 관리 (${screen.id})"
    - agent: onboarding-admin-builder
      goal: "백오피스 (manageable인 경우)"

phase_testing:
  - agent: onboarding-integration-tester
    goal: "전체 플로우 테스트"

validation:
  code_quality:
    - flutter analyze: 0 errors
  performance:
    - 화면 전환 < 300ms
  testing:
    - 커버리지 > 80%
EOF
echo -e "${GREEN}✅ 워크플로우 생성 완료${NC}"

# 11. 화면 설정 파일들
echo -e "\n${BLUE}📄 11. 화면 설정 파일 생성${NC}"

# 003: 연령/세대 선택
cat > .claude/screens/003-age-category.json << 'EOF'
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
    "filters": { "is_active": true },
    "orderBy": "sort_order",
    "saveField": "selected_categories"
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
    "previous": "/onboarding/002-region",
    "next": "/onboarding/004-income"
  },
  
  "admin": {
    "manageable": true,
    "crudPage": "AgeCategoryManagement"
  }
}
EOF

# 001: 개인정보
cat > .claude/screens/001-personal-info.json << 'EOF'
{
  "id": "001",
  "name": "personal-info",
  "title": "기본 정보를 입력해주세요",
  "subtitle": "정확한 정책 추천을 위해 필요합니다",
  "step": 1,
  "totalSteps": 5,
  
  "dataSource": {
    "table": "user_profiles",
    "type": "form",
    "saveFields": ["name", "age", "gender"]
  },
  
  "ui": {
    "type": "form",
    "fields": [
      {
        "name": "name",
        "type": "text",
        "label": "이름",
        "required": true
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
  },
  
  "validation": {
    "allFieldsRequired": true
  },
  
  "navigation": {
    "next": "/onboarding/002-region"
  },
  
  "admin": {
    "manageable": false
  }
}
EOF

echo -e "${GREEN}✅ 화면 설정 파일 생성 완료${NC}"

# 12. DB 스키마
echo -e "\n${BLUE}🗄️  12. 데이터베이스 스키마${NC}"
cat > backend/supabase/migrations/$(date +%Y%m%d%H%M%S)_onboarding_schema.sql << 'EOF'
-- 사용자 프로필 (통합)
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) UNIQUE,
  
  -- 001: 개인정보
  name TEXT,
  age INTEGER,
  gender TEXT,
  
  -- 002: 지역
  region_sido TEXT,
  region_sigungu TEXT,
  
  -- 003: 연령/세대
  selected_categories UUID[],
  
  -- 004: 소득
  income_level TEXT,
  
  -- 005: 관심 정책
  interest_policies UUID[],
  
  -- 메타
  onboarding_completed BOOLEAN DEFAULT false,
  onboarding_step INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 연령/세대 카테고리 (003)
CREATE TABLE IF NOT EXISTS age_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  icon_component TEXT NOT NULL,
  icon_url TEXT,
  min_age INTEGER,
  max_age INTEGER,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 자동 업데이트 트리거
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER age_categories_updated
  BEFORE UPDATE ON age_categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER user_profiles_updated
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE age_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own profile"
  ON user_profiles FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "Anyone views active categories"
  ON age_categories FOR SELECT
  USING (is_active = true);

CREATE POLICY "Admins manage categories"
  ON age_categories FOR ALL
  USING (
    auth.jwt() ->> 'role' = 'admin' OR
    auth.jwt() -> 'user_metadata' ->> 'role' = 'admin'
  );

-- 초기 데이터
INSERT INTO age_categories (title, description, icon_component, min_age, max_age, sort_order) VALUES
('청년', '(만 19세-39세) 대학생, 취업준비생, 직장인', 'young_man', 19, 39, 1),
('신혼부부·예비부부', '결혼 예정 또는 결혼 7년이내', 'bride', NULL, NULL, 2),
('육아중인 부모', '영유아~초등 자녀 양육 중', 'baby', NULL, NULL, 3),
('다자녀 가구', '자녀 2명 이상 양육중', 'kinder', NULL, NULL, 4),
('어르신', '만 65세 이상', 'old_man', 65, NULL, 5),
('장애인', '장애인 등록 대상', 'wheel_chair', NULL, NULL, 6)
ON CONFLICT DO NOTHING;
EOF
echo -e "${GREEN}✅ DB 스키마 생성 완료${NC}"

# 13. Git 커밋
echo -e "\n${BLUE}💾 13. Git 커밋${NC}"
git add .claude/ backend/supabase/
git commit -m "feat: add common onboarding agent structure

- 공통 에이전트 6개
- 통합 워크플로우
- 화면 설정 시스템 (JSON)
- 재사용 가능한 구조
" 2>/dev/null || echo "Already committed"
echo -e "${GREEN}✅ 커밋 완료${NC}"

# 완료
echo -e "\n${GREEN}======================================"
echo "✨ 공통 구조 설정 완료!"
echo "======================================${NC}"

echo -e "\n📝 다음 단계:"
echo ""
echo "1️⃣  DB 설정:"
echo "   cd backend/supabase"
echo "   supabase start"
echo "   supabase db reset"
echo ""
echo "2️⃣  Claude Flow 실행:"
echo "   claude-flow orchestrate --workflow .claude/workflows/onboarding-universal.yml"
echo ""
echo "3️⃣  특정 화면만:"
echo "   claude-flow orchestrate --workflow .claude/workflows/onboarding-universal.yml --screen 003"
echo ""
echo "4️⃣  새 화면 추가:"
echo "   nano .claude/screens/006-new-screen.json"
echo "   워크플로우 yml에 추가"
echo ""
echo -e "${BLUE}📚 자세한 내용은 artifact를 참고하세요!${NC}"