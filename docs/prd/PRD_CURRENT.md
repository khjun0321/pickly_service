# 📄 PRD v9.6 FINAL — Pickly 통합 혜택·홈·API 관리 시스템 (상세본)

**버전:** v9.6 FINAL ✅
**작성일:** 2025-11-02
**최종 업데이트:** 2025-11-02 (Phase 2 Complete)
**작성자:** (PM: 사용자)
**대상:** Flutter App(현재 버전), Web Admin, Supabase, Claude Code, Windsurf
**우선순위:** 🔴 Critical
**구현 상태:** ✅ **Phase 2 COMPLETE - Production Ready** (Home, Categories, Subcategories, Banners, Announcements, Tabs)
**중요:** 이 문서(v9.6 FINAL)가 **기존 v8.x, 테스트 로그, ADMIN_… 문서보다 우선**이다.
**중요2:** Flutter 앱은 **지금 UI 그대로 유지**한다. *"앱 잘 되어있는데 바꾸지 마"* 조건이 최상위다.
**중요3:** Claude Code/에이전트는 **반드시 이 문서만** 다시 읽고 작업한다. (이전 PRD는 참고 금지)

---

## 1. 서비스 목적

Pickly는 **공공 API 데이터를 자동 수집 → 어드민에서 워싱 → Flutter 앱 실시간 반영**하는 혜택 큐레이션 플랫폼이다.

- 데이터는 **공공 API에서 자동으로 수집**된다.
- 어드민은 그 데이터를 **우리 앱 구조에 맞게 워싱(보정)** 한다.
- 워싱된 데이터는 **Flutter 앱에 실시간 반영**된다.
- 홈 탭에서는 **혜택/커뮤니티/운영 콘텐츠**를 **섞어서** 보여준다.
- 우리는 **카테고리(묶는 단위)** 와 **하위분류(실제 공고가 붙는 단위)** 를 **분리**해서 운영한다.
- 앞으로 API가 **계속 늘어날 것**이기 때문에, **벽을 세우고(스키마 고정) 파이프를 연결(매핑 계층 분리)** 해둬야 한다.

---

## 2. 가장 중요한 약속

1. **앱은 절대 깨지면 안 된다.**
   - Flutter 앱에서 **이미 쓰고 있는 컬럼명, 구조는 바꾸지 않는다.**
   - 앱에서 이미 쓰고 있는 화면(홈/혜택/커뮤니티/AI/마이)은 그대로 유지한다.
   - 앱의 “혜택 탭 구조: 상단 써클탭 → 배너 → 필터(지역/연령/하위분류) → 공고 리스트” 이 구조는 **필수**다.

2. **어드민은 앱과 똑같은 플로우로 관리한다.**
   - 앱 하단: `[홈][혜택][커뮤니티][AI][마이페이지]`
   - 어드민 메뉴도: `홈 관리 / 혜택 관리 / 커뮤니티 관리 / AI 도구 / 사용자·권한` 으로 맞춘다.

3. **명명 통일 없이 마음대로 바꾸지 말 것.**
   - 예전에 `posted_date`, `type_id` 같은 거 **마음대로 썼다가** Supabase가 “그 컬럼 없어”라고 한 문제 있었다.
   - 이제 **공식 명명만** 쓴다.

4. **카테고리별 UI 필드를 전부 통일해서는 안 된다.**
   - “행복주택”과 “취업훈련”은 필드가 다르다.
   - 공통 필드 + 템플릿 필드 2단으로 간다.
   - 공통 필드는 DB에, 템플릿 필드는 JSON/별도 탭에.

---

## 3. 현재 앱 구조 (사용자 기준)

하단 네비게이션 구성:  
**[홈] [혜택] [커뮤니티] [AI] [마이페이지]**

- **홈**: 인기 커뮤니티 글, 운영 콘텐츠, 추천 공고, 인기 공고, 검색  
- **혜택**: 써클탭(대분류) → 배너 → 필터 → 리스트 → 상세 템플릿  
- **커뮤니티**: 탭형, 댓글, 글쓰기, 인기글 노출  
- **AI**: 공고문 분석, 자격조건 확인  
- **마이페이지**: 프로필, 설정, 로그인 관리

---

## 4. 어드민(Web) 구조

### 4.1 홈 관리
- 섹션 블록별 관리 (자동/수동 혼합)
  - 인기 커뮤니티 자동 수집
  - 운영진 추천 콘텐츠 수동 업로드 (이미지/제목/링크)
  - 인기 공고 자동 노출 (조회수, is_priority 기준)
  - 섹션 순서 및 노출 여부 변경 가능

### 4.2 혜택 관리
1. **대분류 (benefit_categories)**  
   - “주거/취업/교육/건강…” 등  
   - SVG 업로드, 제목/순서/활성 관리 가능
2. **하위분류 (benefit_subcategories)**  
   - “행복주택/공공임대/청년일자리…”  
   - 각 대분류 하위로 연결, 추가/삭제/수정 가능
3. **배너 (category_banners)**  
   - 외부 링크 / 내부 페이지 이동 / 순서 변경
4. **공고 (announcements)**  
   - API 수집 → 워싱 → 편집  
   - 공통 필드 + 템플릿 필드 구조  
   - 썸네일 업로드 / 평형 탭 / 모집군 관리  
   - “청년형/신혼부부형/고령자형” 같은 탭 구조 지원
5. **공고 탭 (announcement_tabs)**  
   - 전용면적, 세대수, 보증금, 월세 등 입력  
   - 탭 순서 지정 / is_default 설정

### 4.3 API 관리
- api_sources 테이블 기반 관리
- 매핑 UI: “이 API → 이 하위분류”
- 로그, 수집 성공/실패 기록
- 수동 재수집 버튼

### 4.4 권한/계정
- 관리자 전용 계정 (super_admin, content_admin, api_admin)
- SSO(Naver/Kakao) 로그인 가능

---

## 5. DB 스키마 (요약)

| 테이블 | 설명 |
|--------|------|
| benefit_categories | 대분류 (주거/취업/교육 등) |
| benefit_subcategories | 하위분류 (행복주택 등) |
| announcements | 공고 본문 (앱 실시간 반영 대상) |
| announcement_tabs | 세부 모집군/평형 탭 |
| category_banners | 배너 관리 |
| age_categories | 연령대 필터 |
| api_sources | API 매핑 관리 |
| raw_announcements | 원본 API 수집 로그 |

---

## 6. 명명 규칙 (강제)

| 목적 | 필드명 |
|------|--------|
| 신청시작 | application_start_date |
| 신청마감 | application_end_date |
| 대분류 FK | category_id |
| 하위분류 FK | subcategory_id |
| 이미지 | *_url |
| 노출여부 | is_active |
| 우선노출 | is_priority |
| 원본데이터 | raw_payload |
| 정렬 | sort_order |

❌ 금지: posted_date, type_id, display_order

---

## 7. 앱 ↔ DB 맵핑

| 앱 화면 | DB 테이블 |
|----------|------------|
| 홈 상단 배너 | category_banners |
| 상단 카테고리 | benefit_categories |
| 필터 | benefit_subcategories, age_categories |
| 혜택 리스트 | announcements |
| 혜택 상세 | announcements, announcement_tabs |
| 이미지 출력 | Supabase Storage |
| 로그인/권한 | Supabase Auth |

---

## 8. 오류 예방 및 원인

1. 어드민 폼에 type_id 남아있으면 DB 400 에러 발생  
2. posted_date 필드 참조 시 에러  
3. subcategory_id 누락 시 앱에서 리스트 안뜸  
4. API 매핑 누락 시 앱 비노출  
5. 템플릿 미구현 시 UI 깨짐  
6. 권한 누락 시 Supabase RLS 차단 발생

---

## 9. 명명 통일 상태

✅ `application_start_date` 사용 중  
✅ `subcategory_id` 적용  
✅ `is_priority`, `is_active`, `sort_order` 일괄 적용  
✅ `thumbnail_url` 추가  
✅ `status` ENUM 값 표준화 (recruiting, closed, upcoming, draft)

---

## 10. 파이프라인 구조

```
[공공 API]
 ↓
 raw_announcements
 ↓
 워싱 및 매핑
 ↓
 announcements + announcement_tabs
 ↓
 Supabase Realtime
 ↓
 Flutter 앱 실시간 반영
```

---

## 11. 구현 상태 및 작업 리스트

### ✅ 완료 (Phase 1-3)
- ✅ PRD 교체 (Claude Code v9.6 FINAL 기준)
- ✅ Announcement 폼 컬럼 교체 (application_start_date, subcategory_id, status)
- ✅ 썸네일 업로드 storage 연결 (benefit-thumbnails bucket)
- ✅ 하위분류 관리 화면 완성 (icon upload, sort_order)
- ✅ announcement_tabs 편집기 (탭 CRUD, floor plan upload, JSONB fields, reordering)
- ✅ 홈 섹션 관리 (3 sections + banner management, ImageUploader integration)
- ✅ 카테고리/하위분류/배너 관리 (전체 CRUD with image upload)
- ✅ 노출 on/off 스위치 (is_active toggle across all pages)
- ✅ 정렬 순서 관리 (sort_order for lists, display_order for tabs)
- ✅ 100% QA 테스트 완료 (91 tests passed)

### 🟠 진행 중 (Phase 4 - 향후 작업)
- ⏳ API 매핑 UI (api_sources table management)
- ⏳ 수집 로그 뷰어 (api_collection_logs)
- ⏳ 매핑 규칙 편집기 (mapping_config JSONB editor)

### 🟢 예정 (Phase 5 - 향후 작업)
- ⏳ Role + SSO (permission matrix, OAuth providers)
- ⏳ 사용자 관리 강화 (role assignment UI)
- ⏳ 커뮤니티 관리 (향후 통합)

---

## 12. 기존 문서 처리

- v8.x, ADMIN_*, TEST_LOG 등은 `/docs/history/` 로 이동  
- Claude Code는 `/docs/prd/v9.6/` 만 읽도록 고정

---

## 13. 향후 개선 방향

- **확장성**: 새 복지유형 추가 시 DB 변경 없이 subcategory 확장  
- **안정성**: DB 스키마 고정, 파이프 분리  
- **UI 일관성**: Flutter 앱은 변경 금지, Admin만 확장  
- **보안**: Admin 전용 Role, Supabase RLS + SSO 적용  
- **API UI 구성**: 매핑·로그·재수집 가능화

---

## 14. Claude Code 실행 명령

```
claude-code task create --title "Pickly Admin v9.6 구조 및 명명 정합성 반영" --description "
공식 PRD는 /docs/prd/PRD_v9.6_Pickly_Integrated_System.md 입니다.

1. 어드민 Announcement 폼 필드 정리
2. benefit_subcategories SVG 업로드 필드 추가
3. announcement_tabs 편집기 구성
4. category_banners on/off + 정렬
5. API 매핑 관리 UI 구현
6. Flutter 앱은 그대로 유지, 필드명만 정합성 적용
" --auto-execute
```

---

## 15. 최종 요약

- **서비스 목표**: 공공데이터 자동수집 + 실시간 개인화 반영  
- **핵심 구조**: 벽(DB 고정) + 파이프(API ↔ 워싱 ↔ 앱)  
- **앱 탭 구성**: 홈 / 혜택 / 커뮤니티 / AI / 마이페이지  
- **명명 통일**: posted_date, type_id 제거  
- **확장성**: 신규 API 추가, 템플릿 분리로 대응  
- **보안/권한**: Supabase RLS + SSO  
- **UI 변경 불가**, 어드민 확장만 허용
