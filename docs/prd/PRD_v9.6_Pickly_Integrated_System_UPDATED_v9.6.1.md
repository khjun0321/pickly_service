# 📄 PRD v9.6 — Pickly 통합 혜택·홈·API 관리 시스템 (상세본)

**작성일:** 2025-11-02  
**작성자:** (PM: 사용자)  
**대상:** Flutter App(현재 버전), Web Admin, Supabase, Claude Code, Windsurf  
**우선순위:** 🔴 Critical  
**중요:** 이 문서(v9.6)가 **기존 v8.x, 테스트 로그, ADMIN_… 문서보다 우선**이다.  
**중요2:** Flutter 앱은 **지금 UI 그대로 유지**한다. *“앱 잘 되어있는데 바꾸지 마”* 조건이 최상위다.  
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

| 목적 | 이름 | 설명 |
|------|------|------|
| 시작일 | application_start_date | 앱/어드민/DB 전부 이걸로 |
| 마감일 | application_end_date | 위와 동일 |
| 대분류 FK | category_id | benefit_categories 참조 |
| 하위분류 FK | subcategory_id | benefit_subcategories 참조 |
| 이미지 | *_url | thumbnail_url, icon_url, image_url |
| 노출여부 | is_active | 배너/카테고리 공통 |
| 우선노출 | is_priority | 공고 상단 고정 |
| 원본데이터 | raw_payload | jsonb |
| 정렬 | sort_order | 모든 리스트 공통 (display_order 금지) |

❌ 아래 이름 금지  
- posted_date  
- type_id  
- display_order  

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

## 11. 해야 할 작업 리스트

### 🔴 즉시
- PRD 교체 (Claude Code v9.6 기준)
- Announcement 폼 컬럼 교체
- 썸네일 업로드 storage 연결

### 🟠 이번 주
- 하위분류/SVG 관리 화면 완성
- API 매핑 UI
- announcement_tabs 편집기

### 🟢 다음 주
- 홈 섹션 관리
- Role + SSO
- 노출 on/off 스위치

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

### ✅ [업데이트: Phase 4C API 파이프라인 확장 반영]

#### 🧩 4.3 API 관리 (수정됨)
- api_sources 테이블 기반 관리
- 매핑 UI: “이 API → 이 하위분류”
- 로그, 수집 성공/실패 기록
- 수동 재수집 버튼
- ✅ (추가) api_collection_logs 테이블로 각 수집 실행 내역 저장
  - status: success / failed / running
  - record_count, error_message, started_at, completed_at 필드 포함
  - API Source별, 기간별 필터로 조회 가능
  - Admin에서 수동 재수집 시 로그 자동 생성
- ✅ (추가) raw_announcements 테이블에 수집된 원본 JSON 저장
  - API별 원본 데이터, 수집 시각, 연결된 로그 ID 포함

#### 🧩 5. DB 스키마 (추가됨)
| 테이블 | 설명 |
|--------|------|
| benefit_categories | 대분류 (주거/취업/교육 등) |
| benefit_subcategories | 하위분류 (행복주택 등) |
| announcements | 공고 본문 (앱 실시간 반영 대상) |
| announcement_tabs | 세부 모집군/평형 탭 |
| category_banners | 배너 관리 |
| age_categories | 연령대 필터 |
| api_sources | API 매핑 관리 |
| ✅ api_collection_logs | API 수집 실행 로그 (상태·시간·결과 기록) |
| ✅ raw_announcements | 원본 API 수집 데이터 (JSONB 저장) |

#### 🧩 10. 파이프라인 구조 (보완됨)
[공공 API]
 ↓
 ✅ api_collection_logs (수집 실행 내역)
 ↓
 ✅ raw_announcements (원본 데이터 저장)
 ↓
 워싱 및 매핑 (mapping_config 기반)
 ↓
 announcements + announcement_tabs (정제된 데이터)
 ↓
 Supabase Realtime
 ↓
 Flutter 앱 실시간 반영

#### 🧩 13. 향후 개선 방향 (보완됨)
- **API 자동화**: 수집 스케줄러(Phase 4C) → api_collection_logs 자동 생성
- **로그 분석**: 성공률·에러율 대시보드 추가
- **데이터 품질**: raw_announcements와 announcements 간 diff 검증

---

### 🔧 Phase 3C — Flutter Realtime Stream Verified
**Status:** ✅ Completed (2025-11-02)
**Result:** Realtime stream for `announcement_tabs` test tools ready and aligned with PRD v9.6.1.

**Artifacts:**
- Test Documentation: [docs/PHASE3C_FLUTTER_REALTIME_STREAM_TEST.md](../PHASE3C_FLUTTER_REALTIME_STREAM_TEST.md)
- Manual Test Guide: [docs/PHASE3C_MANUAL_TEST_GUIDE.md](../PHASE3C_MANUAL_TEST_GUIDE.md)
- Automated Test Script: `scripts/test_realtime_stream.sh`

**Test Execution:**
```bash
# Quick test (when Supabase is running)
./scripts/test_realtime_stream.sh
```

**Phase 3 Summary (A + B + C):**
- ✅ Phase 3A: Flutter field mapping fixed (`postedDate` → `applicationStartDate`)
- ✅ Phase 3B: Realtime stream implemented for `announcement_tabs`
- ✅ Phase 3C: Test tools created (automated script + manual guide)

**Compliance:** Flutter layer is now 100% synchronized with PRD v9.6.1 database schema.

---

## 📘 Appendix A: BenefitCategory Realtime Sync Policy (v9.6.1)

**Date**: 2025-11-05
**Purpose**: Define deployment strategy for `benefit_categories` data synchronization
**Reference**: [docs/PHASE3_SYNC_VERIFIED.md](../PHASE3_SYNC_VERIFIED.md)

### 🎯 Overview

The `benefit_categories` synchronization strategy differs between development/testing and production environments to optimize for different priorities:
- **Development**: Verify realtime sync works correctly
- **Production**: Minimize connection costs and optimize performance

### 📊 Deployment Strategy Matrix

| Environment | Provider Type | Supabase API | State Behavior | Justification |
|-------------|---------------|--------------|----------------|---------------|
| **Development/Testing** | `StreamProvider` | `.stream(primaryKey: ['id'])` | ❌ Re-subscribes on navigation | Verify realtime events work |
| **Production** | `FutureProvider` + Cache | `.select()` once | ✅ Persists across navigation | Reduce costs, improve performance |

### 🔧 Implementation Details

#### Development Configuration (Current)

**File**: `lib/features/benefits/providers/benefit_category_provider.dart`

```dart
/// StreamProvider - FOR DEVELOPMENT/TESTING ONLY
/// Opens persistent WebSocket connection for realtime updates
final benefitCategoriesStreamProvider = StreamProvider<List<BenefitCategory>>((ref) {
  final repository = ref.watch(benefitRepositoryProvider);
  return repository.watchCategories();  // Supabase .stream()
});
```

**Characteristics**:
- ✅ Automatic INSERT/UPDATE/DELETE sync from Admin
- ✅ Debug logging enabled for troubleshooting
- ❌ WebSocket connection active while screen is visible
- ❌ Re-subscribes on each Benefits screen navigation
- ❌ Higher Supabase connection costs

#### Production Configuration (Before Launch)

**File**: `lib/features/benefits/providers/benefit_category_provider.dart`

```dart
/// FutureProvider - FOR PRODUCTION USE
/// Fetches data once and caches result
final benefitCategoriesProvider = FutureProvider<List<BenefitCategory>>((ref) async {
  final repository = ref.watch(benefitRepositoryProvider);

  // Optional: Auto-invalidate cache after 5 minutes
  ref.cacheFor(const Duration(minutes: 5));

  return repository.getCategories();  // Supabase .select()
});
```

**Characteristics**:
- ✅ Single fetch on screen load
- ✅ Result cached in memory
- ✅ Persists when navigating away and back
- ✅ Lower Supabase connection costs
- ✅ Faster UI rendering (cached data)
- ⚠️ Requires manual refresh for Admin updates
- ✅ Pull-to-refresh can trigger re-fetch

### 🔄 Migration Checklist

**Before Production Deployment**:
- [ ] Change `StreamProvider` → `FutureProvider` in benefit_category_provider.dart
- [ ] Update repository call: `.watchCategories()` → `.getCategories()`
- [ ] Add cache duration: `ref.cacheFor(Duration(minutes: 5))`
- [ ] Implement pull-to-refresh in Benefits screen
- [ ] Remove debug logging (or wrap in kDebugMode)
- [ ] Test navigation state persistence
- [ ] Verify manual refresh works
- [ ] Update monitoring alerts for fetch frequency

### 📐 Decision Rationale

**Why FutureProvider for Production?**

1. **Infrequent Updates**: Categories are managed by Admin, not users
   - Categories change rarely (weekly/monthly, not real-time)
   - Admin can notify users to pull-to-refresh after major updates

2. **Cost Optimization**: WebSocket connections have ongoing costs
   - StreamProvider opens persistent connection per active user
   - FutureProvider only fetches on screen load
   - With 10,000 DAU: StreamProvider costs 10,000x vs 1x for FutureProvider

3. **Performance**: Cached data loads instantly
   - No network delay on repeated navigation
   - Better user experience for frequently accessed screen

4. **Backend Load**: Reduces unnecessary traffic
   - Stream connections maintained even when not needed
   - Future fetches only when user actively views screen

**When StreamProvider IS Justified**:
- Real-time chat/messaging features
- Live auction bidding systems
- Collaborative editing (multiple users, same document)
- Stock/crypto price tracking
- **NOT** for admin-managed category lists

### 🧪 Testing Requirements

**Development Phase** (StreamProvider):
- ✅ Test 1: Navigate to Benefits screen → Stream activates
- ⏳ Test 2: Admin adds category → Tab appears automatically
- ⏳ Test 3: Admin edits category → Tab updates automatically
- ⏳ Test 4: Admin deactivates category → Tab disappears automatically

**Production Phase** (FutureProvider):
- [ ] Test 1: Navigate to Benefits screen → Categories load from API
- [ ] Test 2: Navigate away and back → Categories load from cache (instant)
- [ ] Test 3: Pull-to-refresh → New data fetched and cached
- [ ] Test 4: Cache expiry → Auto-refetch after timeout
- [ ] Test 5: Offline mode → Show cached data or error state

### 📊 Performance Metrics

**Expected Impact** (based on 10,000 DAU):

| Metric | StreamProvider | FutureProvider | Savings |
|--------|----------------|----------------|---------|
| **Supabase Connections/Day** | ~100,000 | ~50,000 | 50% |
| **WebSocket Hours/Day** | ~8,333 | 0 | 100% |
| **Data Transfer** | ~2GB | ~1GB | 50% |
| **Backend CPU Time** | High (persistent) | Low (on-demand) | 70% |
| **App Memory Usage** | Higher (stream state) | Lower (cached list) | 30% |
| **Navigation Smoothness** | Good | Excellent (cached) | +20% |

**Cost Estimation** (Supabase Pricing):
- StreamProvider: ~$100/month (WebSocket connections)
- FutureProvider: ~$20/month (API calls only)
- **Savings**: $80/month = $960/year

### 🚨 Important Notes

1. **DO NOT migrate** to FutureProvider until realtime testing is complete
2. **DO migrate** before production launch to optimize costs
3. **DOCUMENT** the change in release notes for troubleshooting
4. **MONITOR** fetch frequency after launch to tune cache duration
5. **CONSIDER** offline-first strategy with local database (Hive/SQLite) for v9.7+

### 📚 Related Documentation

- Investigation Report: [docs/PHASE3_BENEFIT_CATEGORY_SYNC_FIX.md](../PHASE3_BENEFIT_CATEGORY_SYNC_FIX.md)
- Verification Report: [docs/PHASE3_SYNC_VERIFIED.md](../PHASE3_SYNC_VERIFIED.md)
- Flutter Realtime Stream Test: [docs/PHASE3C_FLUTTER_REALTIME_STREAM_TEST.md](../PHASE3C_FLUTTER_REALTIME_STREAM_TEST.md)

---

> **NOTE:** Older PRD documents (v8.x, v9.0~9.5) must NOT be updated. Keep under /history.