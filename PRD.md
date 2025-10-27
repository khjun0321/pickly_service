# 📄 Pickly PRD (Flutter Mobile + Claude Flow - v7.0)

> **AI 자동화 기반 개발 시스템**
> 마지막 업데이트: 2025.10.27

---

## ⚠️ **에이전트 제약 사항 (CRITICAL)**

### **절대 금지 사항**

❌ **Phase 1 MVP에 없는 테이블 생성 절대 금지**
❌ **LH API 연동 금지** (Phase 2 이후)
❌ **AI 챗봇/댓글 시스템 금지** (Phase 3)
❌ **자동 데이터 수집 금지**
❌ **사용자 승인 없이 새 테이블 생성 금지**

### **허용된 작업**

✅ 온보딩 관련: `age_categories`, `user_profiles`
✅ 혜택 관련: `benefit_categories`, `benefit_subcategories`
✅ 공고 관련: `announcements`, `announcement_sections`, `announcement_tabs`
✅ 배너 관련: `category_banners`
✅ 기존 테이블 CRUD 코드 작성
✅ Repository 패턴 구현

### **의심스러우면**

> "이 테이블이 PRD Phase 1에 명시되어 있나요?"
> "사용자 승인을 받았나요?"

**답이 "아니오"면 → 작업 중단하고 사용자에게 질문!**

---

## 1. 프로젝트 개요

### 제품 정의
Pickly는 복잡한 정부 정책/혜택 공고문을 **개인 맞춤형으로 큐레이션**하여, 누구나 쉽게 혜택을 확인하고 신청할 수 있도록 돕는 **모바일 정책 정보 서비스**입니다.

### 문제 정의
- 정책 정보가 여러 기관 사이트에 흩어져 있음
- 공고문이 길고 전문 용어가 많아 이해하기 어려움
- 내 상황에 맞는 정책을 찾기 어려움
- 신청 방법과 마감일을 놓치기 쉬움

### 핵심 가치 제안
1. **개인화**: 사용자 정보 기반 맞춤형 정책 추천
2. **단순화**: 복잡한 정책을 이해하기 쉽게 요약
3. **접근성**: 모바일에서 언제 어디서나 확인
4. **실용성**: 신청까지 원스톱 지원

---

## 2. 핵심 기능

### 모바일 앱 (사용자용)

**MVP (Phase 1 - 2개월)**

**온보딩 & 개인화**
- 거주 지역 선택
- 연령 카테고리 선택 (청년, 중장년, 노년 등)
- 관심 카테고리 선택

**혜택 피드 (메인)**
- 상단 써클 탭: 인기, 주거, 교육, 건강, 교통, 복지, 취업, 지원, 문화
- 카테고리별 배너 (동적)
- 서브 필터 (바텀시트): 전체공고, 행복주택, 국민임대 등
- 공고 리스트 카드 (썸네일 + 제목 + 기관 + 상태)

**공고 상세** ✅ (v7.2 구현 완료)
- 모듈식 섹션 구성 (announcement_sections)
  - basic_info: 기본 정보
  - schedule: 일정
  - eligibility: 신청 자격
  - housing_info: 단지 정보
  - location: 위치
  - attachments: 첨부 파일
- TabBar UI (announcement_tabs 기반)
  - 평형별 정보 (16A 청년, 신혼부부 등)
  - 평면도 이미지 표시
  - 공급 호수, 소득 조건 표시
- 외부 공고문 링크
- 캐시 무효화 (상세 화면 진입 시)

**검색 & 필터**
- 키워드 검색
- 조건별 필터 (지역, 연령, 카테고리)

**Phase 2 (3-4개월 후)** - MVP 이후
- 북마크 & 공유
- 푸시 알림 (마감 임박, 신규 정책)
- AI 자동 분석 (PDF → 구조화)

**Phase 3 (5-6개월 후)** - Phase 2 이후
- 커뮤니티 (댓글, Q&A)
- AI 챗봇
- 신청 현황 트래킹

### 백오피스 (관리자용)

**MVP (Phase 1 - 2개월)**

**연령 카테고리 관리** ✅ (v7.2 구현 완료)
- 카테고리 CRUD (Create, Read, Update, Delete)
- SVG 아이콘 업로드 (Supabase Storage)
- 이름, 표시 순서, 나이 범위 설정
- TypeScript 타입 안전성 보장

**혜택 카테고리 관리**
- 카테고리 CRUD (주거, 교육, 건강...)
- 서브 카테고리 관리 (행복주택, 국민임대...)

**공고 관리** ✅ (v7.2 구현 완료)
- 기본 정보 입력
  - 제목, 부제목, 기관명, 카테고리/서브카테고리
  - 썸네일 업로드 (선택, 없으면 기본 이미지)
  - 외부 링크
  - 상태 (recruiting/closed/draft)
  - 노출 설정 (is_featured, is_home_visible, display_priority)
- 섹션 관리 (announcement_sections)
  - 섹션 타입 선택 (basic_info, schedule, eligibility, housing_info, location, attachments)
  - JSONB 기반 유연한 콘텐츠 구조
  - display_order로 순서 제어
  - is_visible 토글
- 탭 관리 (announcement_tabs)
  - 탭 추가/수정/삭제 (16A 청년, 신혼부부 등)
  - 평면도 이미지 업로드 (floor_plan_image_url)
  - 공급 호수 (supply_count), 소득 조건 (income_conditions JSONB)
  - age_category_id 연동
  - display_order로 탭 순서 제어

**배너 관리**
- 카테고리별 배너 등록
- 이미지 업로드
- 노출 순서 관리

**사용자 관리**
- 사용자 목록 조회
- 통계 확인

---

## 3. 데이터베이스 스키마 (Phase 1 MVP)

### ✅ 허용된 테이블 (8개만!)

#### **1. 사용자 & 온보딩**
```sql
-- 연령 카테고리
age_categories (
  id, name, display_order, icon_path,
  age_min, age_max, created_at, updated_at
)

-- 사용자 프로필
user_profiles (
  id, email, age, region, household_type,
  income_level, interests[], created_at
)
```

#### **2. 혜택 카테고리**
```sql
-- 혜택 카테고리 (주거, 교육...)
benefit_categories (
  id, name, slug, description, icon_url,
  display_order, is_active, created_at, updated_at
)

-- 서브 카테고리 (행복주택, 국민임대...)
benefit_subcategories (
  id, category_id, name, slug,
  display_order, is_active, created_at
)
```

#### **3. 공고 시스템**
```sql
-- 공고 기본 정보
announcements (
  id, title, subtitle, organization,
  category_id, subcategory_id,
  thumbnail_url,           -- 직접 업로드 or NULL
  external_url,            -- 원본 공고문 링크
  status,                  -- recruiting, closed, draft
  is_featured,             -- 인기 탭 노출
  is_home_visible,         -- 홈 화면 노출
  display_priority,
  views_count, tags[], search_vector,
  created_at, updated_at
)

-- 공고 섹션 (모듈식)
announcement_sections (
  id, announcement_id,
  section_type,            -- basic_info, schedule, eligibility,
                           -- housing_info, location, attachments
  title,
  content (JSONB),         -- 유연한 구조
  display_order, is_visible,
  created_at, updated_at
)

-- 공고 탭 (평형별)
announcement_tabs (
  id, announcement_id,
  tab_name,                -- "16A 청년", "신혼부부"
  age_category_id,
  unit_type,               -- "16㎡"
  floor_plan_image_url,    -- 평면도 (직접 업로드!)
  supply_count,            -- 공급 호수
  income_conditions (JSONB),
  additional_info (JSONB),
  display_order,
  created_at
)
```

#### **4. 배너**
```sql
-- 카테고리별 배너
category_banners (
  id, category_id,
  title, subtitle, image_url, link_url,
  display_order, is_active,
  start_date, end_date,
  created_at, updated_at
)
```

### ❌ 금지된 테이블들

```
❌ announcement_ai_chats      (Phase 3 - AI 챗봇)
❌ announcement_comments      (Phase 3 - 커뮤니티)
❌ announcement_files         (announcement_sections로 통합)
❌ announcement_unit_types    (announcement_tabs로 통합)
❌ benefit_announcements      (announcements로 통합)
❌ announcements (LH 전용)    (일반 announcements만 사용)
❌ storage_folders            (Phase 2)
❌ display_order_history      (불필요)
❌ 기타 PRD에 없는 모든 테이블
```

---

## 4. 기술 스택

### Frontend
- **Flutter**: 모바일 앱
  - Riverpod (상태 관리)
  - GoRouter (라우팅)
  - Supabase Client (백엔드 연동)

- **React**: 백오피스
  - TypeScript
  - MUI (Material-UI)
  - TanStack Query (서버 상태)
  - React Hook Form (폼 관리)

### Backend
- **Supabase**
  - PostgreSQL (데이터베이스)
  - Auth (인증)
  - Storage (이미지 업로드)
  - RLS (Row Level Security)

### DevOps
- GitHub Actions (CI/CD)
- Vercel (백오피스 배포)

---

## 5. 개발 방법론

### Claude Flow 사용 시 필수 규칙

#### **1. 작업 전 체크리스트**
```
□ PRD Phase 1에 명시된 기능인가?
□ 필요한 테이블이 허용 목록에 있는가?
□ 사용자 승인을 받았는가?
```

#### **2. 에이전트 역할 분담**
- **Coordinator**: 작업 계획 수립 (PRD 확인 필수!)
- **Screen Builder**: Flutter UI 생성
- **State Manager**: Riverpod Provider
- **Database Manager**: Repository 생성 (테이블 생성 금지!)
- **Integration Tester**: 테스트 코드

#### **3. 워크플로우**
```
1. Coordinator가 PRD 확인
2. 허용된 테이블만 사용 확인
3. 의심스러우면 사용자에게 질문
4. 승인 후 작업 시작
5. 생성 코드 검증
6. 테스트
```

---

## 6. 중요 원칙

### **1. 점진적 개발**
- Phase 1 완성 후 Phase 2 시작
- Phase 2 완성 후 Phase 3 시작
- 한 번에 여러 Phase 작업 금지

### **2. 수동 우선**
- 자동화보다 수동 제어 우선
- 백오피스에서 직접 입력
- AI 자동 파싱은 Phase 2 이후

### **3. 모듈식 구조**
- 공고는 섹션 조합으로 구성
- 백오피스에서 자유롭게 조합
- 앱에서 동적 렌더링

### **4. 에러 방어**
- 저장 전 검증
- 에러 메시지 명확히
- 되돌리기 기능
- 자동 백업

---

## 7. 버전 히스토리

### v7.2 (2025.10.27) - 공고 상세 및 관리자 기능 통합 🎯
- **공고 상세 시스템 구현**:
  - Announcement Tabs (평형별 정보) 지원
  - Section 기반 커스텀 콘텐츠 렌더링
  - TabBar UI 구현 (announcement_tabs 연동)
  - 캐시 무효화 전략 적용
- **관리자 인터페이스 개선**:
  - 연령 카테고리 관리 (CRUD + SVG 업로드)
  - Announcement Types 관리
  - Storage 업로드 절차 문서화
  - TypeScript 타입 안전성 강화
- **문서화**:
  - [공고 상세 명세](docs/prd/announcement-detail-spec.md)
  - [관리자 기능 가이드](docs/prd/admin-features.md)
  - [DB 스키마 v2](docs/database/schema-v2.md)
  - [테스팅 가이드 업데이트](docs/development/testing-guide.md)
- **Phase 2 연기**: Phase 2 기능들을 phase2_disabled/로 이동

### v7.1 (2025.10.27) - 백오피스 TypeScript 에러 대청소 🎉
- **98개 → 12개 에러 해결** (88% 감소, 2.5시간 소요)
- **문서화 완료**: 백오피스 개발 가이드 + 트러블슈팅 가이드
- **핵심 수정**:
  - DB 스키마 불일치 해결 (icon→icon_url, sort_order→display_order, background_color 제거)
  - 미사용 코드 정리 (TS6133 에러)
  - Null 처리 개선 (?? 연산자 일관성)
  - 중복 파일 제거 (BannerManager.tsx)
- **파일 변경**: +228 / -756 (코드 -528 lines)
- 관련 문서:
  - [백오피스 개발 가이드](docs/prd/admin-development-guide.md)
  - [TypeScript 에러 트러블슈팅](docs/troubleshooting/admin-typescript-errors.md)

### v7.0 (2025.10.27) - DB 스키마 재구성 ⭐
- **에이전트 제약 추가** (금지/허용 명확화)
- **DB 스키마 단순화** (8개 테이블만)
- **모듈식 공고 시스템** 도입
- 잘못된 테이블 제거 (benefit_announcements 등)

### v5.0 (2025.10.07)
- Claude Flow 도입
- Supabase 설정

---

## 부록: 에이전트 가이드

### Database Manager 에이전트에게

**당신의 역할:**
- 기존 테이블에 대한 Repository 생성
- CRUD 메서드 구현
- 테스트 코드 작성

**절대 하지 말 것:**
- 새 테이블 생성 (사용자 승인 없이)
- 마이그레이션 파일 작성
- Storage bucket 생성
- Edge Functions 생성

**의심스러우면:**
> "이 작업이 PRD Phase 1에 명시되어 있나요?"

### Coordinator 에이전트에게

**당신의 책임:**
- PRD를 **항상** 먼저 읽기
- Phase 1 범위 확인
- 다른 에이전트 작업 검증
- 의심스러운 작업 사용자에게 질문

**작업 승인 전 확인:**
```
1. PRD에 명시되어 있는가?
2. Phase 1 범위인가?
3. 허용된 테이블만 사용하는가?
4. 새 테이블 생성 요청이 있는가? → 거부!
```

---

**이 PRD는 Claude Flow 에이전트들의 가이드이자 제약입니다.**
**모든 에이전트는 이 문서를 준수해야 합니다.**
