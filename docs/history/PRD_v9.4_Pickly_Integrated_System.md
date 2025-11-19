# 📄 PRD v9.4 — Pickly 통합 혜택관리 시스템
**작성일:** 2025-11-02  
**작성자:** (서비스 PM: 사용자)  
**적용 범위:** Flutter App (UI 변경 금지), Web Admin, Supabase, API 파이프라인  
**우선순위:** 🔴 Critical  
**중요:** 이 문서(v9.4)가 기존 v8.x / ADMIN_LOG / TEST_DOC보다 **최우선**이다.  
**Claude Code에게:** 반드시 `/docs/prd/PRD_v9.4_Pickly_Integrated_System.md` 만 참조하게 하라.

---

## 서비스 개요
Pickly는 공공 API 데이터를 자동 수집 → 어드민에서 워싱 → Flutter 앱 실시간 반영하는 혜택 큐레이션 플랫폼이다.

### 목적
- 공공 데이터 자동수집
- 카테고리 기반 큐레이션 (주거/취업/건강 등)
- 실시간 동기화 및 확장성 확보

---

## 앱 구조
**하단 네비게이션:** 홈 / 혜택 / 커뮤니티 / AI / 마이페이지  
- 앱 UI는 현재 버전 유지 (Flutter 수정 금지)

### 홈
- 인기 커뮤니티 글, 추천 공고, 인기 공고, 수동 콘텐츠 노출  
- 어드민에서 순서/노출 제어

### 혜택
- 상단 써클탭(대분류) → 배너 → 하단 필터(지역/연령/하위분류) → 공고 리스트  
- 공고 클릭 → 상세 템플릿 (주거형/탭형 구조)

---

## 어드민 구조
[홈 관리]
- 인기 커뮤니티 / 추천 공고 / 수동 콘텐츠 업로드

[혜택 관리]
- 대분류 (benefit_categories)
- 하위분류 (benefit_subcategories)
- 배너 (category_banners)
- 공고 (announcements) - 워싱/썸네일/탬플릿/탭 관리

[API 관리]
- API 소스 / 로그 / 매핑 / 재수집

[AI 도구]
- 공고문 분석 / 필드 매핑 결과

[권한]
- 관리자 계정 / Role / SSO (Kakao, Naver)

---

## DB 구조 핵심
### benefit_categories (대분류)
- id, title, icon_url, sort_order, is_active

### benefit_subcategories (하위분류)
- id, category_id, title, description, icon_url, sort_order, is_active

### announcements (공고)
- id, category_id, subcategory_id, title, organization, region, application_start_date, application_end_date, status, is_priority, detail_url, thumbnail_url, raw_payload

### announcement_tabs (공고탭)
- id, announcement_id, household_type, tab_name, deposit_amount, monthly_rent, unit_count, display_order, is_default

### raw_announcements / category_banners / age_categories / api_sources
- 원본 수집, 배너, 연령 필터, API 상태 관리

---

## 명명 통일 규칙
- 날짜: application_start_date, application_end_date  
- 이미지: *_url  
- 대분류/하위: category_id, subcategory_id  
- 비활성화: is_active  
- 우선노출: is_priority  

❌ posted_date, type_id 사용 금지

---

## 템플릿 구조
- 카테고리별 템플릿: housing / job / edu / health  
- DB는 공통 필드 유지, UI는 템플릿 분리
- 어드민에서 템플릿 선택 가능

---

## 보안 / 권한
- Admin 전용 계정만 수정 가능  
- 일반 유저는 읽기 전용  
- Supabase RLS + SSO(Naver/Kakao)

---

## API 파이프라인
[공공 API]
 ↓ 자동수집 (raw_announcements)
 ↓ 워싱 (announcements + tabs)
 ↓ 어드민 보정
 ↓ Realtime Stream
 ↓ Flutter 앱 실시간 반영

---

## 해야 할 작업 리스트
🔴 즉시:
- PRD 교체 (Claude Code에 v9.4 강제 읽히기)
- 공고 폼 컬럼 교체 (type_id → subcategory_id, posted_date → application_start_date)
- 썸네일 업로드 연동

🟠 이번주:
- 하위분류 관리 UI 완성
- API 매핑 관리화면 구축
- announcement_tabs 편집기 완성

🟢 다음주:
- 홈 섹션 관리 / Role 기반 접근 / SSO 연동

---

## Claude Code 전달용 지침
✅ 현재 프로젝트의 공식 PRD는 PRD_v9.4_Pickly_Integrated_System.md 이다.  
🔄 이 문서를 재파싱하고, 이전 v8.x 문서 기반의 구조/명명은 모두 폐기한다.  
🧩 Admin 기능 구현 시, DB 필드는 반드시 본 문서의 명세에 맞춘다.  
🚫 type_id, posted_date 등의 컬럼 참조 금지.  
📡 Supabase 파이프라인은 raw_announcements → announcements 순으로 작동해야 한다.
