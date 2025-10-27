# DB 리팩토링 v2.0 완료 보고서

## 📊 작업 개요
- 기간: 2025.10.27
- 브랜치: feature/refactor-db-schema
- 목표: Phase 1 MVP에 맞는 DB 구조 정리

## ✅ 완료된 작업

### 1. DB 스키마 단순화
- Before: 12개 이상의 복잡한 테이블
- After: 8개 테이블 (Phase 1 범위)

**허용된 테이블 (8개):**
```
✅ age_categories          (연령 카테고리)
✅ user_profiles           (사용자 프로필)
✅ benefit_categories      (혜택 카테고리)
✅ benefit_subcategories   (혜택 서브카테고리)
✅ announcements           (공고 - 통합됨!)
✅ announcement_sections   (공고 섹션 - 모듈식)
✅ announcement_tabs       (공고 탭 - 평형별)
✅ category_banners        (카테고리 배너)
```

### 2. 테이블 변경

**통합:**
- `benefit_announcements` → `announcements` (통합)

**추가:**
- `announcement_sections` (모듈식 섹션 시스템)
- `announcement_tabs` (평형별 탭 시스템)

**삭제:**
- `announcement_ai_chats` (Phase 2로 이동)
- `announcement_comments` (Phase 2로 이동)
- `announcement_unit_types` (announcement_tabs로 대체)
- 기타 Phase 2 이후 테이블들

### 3. 코드 동기화

**Flutter Repository:**
```dart
// apps/pickly_mobile/lib/contexts/benefit/repositories/announcement_repository.dart
// Before: .from('benefit_announcements')
// After:  .from('announcements')

// apps/pickly_mobile/lib/contexts/benefit/models/announcement.dart
// 추가 필드: isHomeVisible, displayPriority
```

**백오피스 API:**
```typescript
// apps/pickly_admin/src/api/announcements.ts
// 테이블명: 'benefit_announcements' → 'announcements'
// 타입명: BenefitAnnouncement → Announcement (12개 파일)
```

**TypeScript 타입:**
```bash
# Supabase CLI로 자동 생성
supabase gen types typescript --local > database.ts
# 574줄의 정확한 타입 정의
```

### 4. 에이전트 제약

**PRD v7.0 업데이트:**
- 8개 허용 테이블 명시
- Phase 1 범위 제한
- Breaking Changes 경고

**Agent 제약 추가:**
- `.claude/agents/specialists/onboarding-database-manager.md`
  - 새 테이블 생성 금지
  - Repository 패턴만 허용
- `.claude/agents/core/onboarding-coordinator.md`
  - PRD 검증 책임
  - 게이트키퍼 역할

## ⚠️ 알려진 이슈 (59개 타입 에러)

### 원인 분석

**1. announcements 테이블 필드 불일치 (주요 원인)**
```typescript
// 컴포넌트에서 사용하는 필드 (DB에 없음)
- application_period_start
- application_period_end
- application_start_date
- application_end_date
- move_in_date
- min_age, max_age
- income_requirement
- household_requirement
```

**2. category_banners 컬럼명 불일치**
```typescript
// DB: link_url
// 코드: action_url

// DB에 없음
- background_color
```

**3. 사용하지 않는 변수들 (경고)**
```typescript
- uploadingImage (MultiBannerManager.tsx)
- updateMutation (BannerManager-integration-example.tsx)
- customFields (DynamicColumns.tsx)
```

### 해결 방법

**Option A: DB 마이그레이션 (추천)**
```sql
-- announcements 테이블에 필드 추가
ALTER TABLE announcements
  ADD COLUMN application_period_start timestamptz,
  ADD COLUMN application_period_end timestamptz;

-- category_banners 컬럼명 변경
ALTER TABLE category_banners
  RENAME COLUMN link_url TO action_url;
```

**Option B: 컴포넌트 코드 수정**
- 사용하지 않는 필드 제거
- 컬럼명 통일

**결정:**
별도 브랜치 (`fix/admin-field-mismatch`)에서 처리 예정

## 📂 변경된 파일들

### 백엔드 (2개)
```
backend/supabase/migrations/20251027000001_correct_schema.sql (신규)
backend/supabase/migrations_wrong/ (백업, 12개 파일)
```

### Flutter (4개)
```
apps/pickly_mobile/lib/contexts/benefit/repositories/announcement_repository.dart
apps/pickly_mobile/lib/contexts/benefit/models/announcement.dart
apps/pickly_mobile/lib/contexts/benefit/models/announcement.g.dart (자동생성)
apps/pickly_mobile/lib/contexts/benefit/models/announcement.freezed.dart (자동생성)
```

### 백오피스 (11개)
```
apps/pickly_admin/src/api/announcements.ts
apps/pickly_admin/src/components/benefits/AnnouncementTable.tsx
apps/pickly_admin/src/components/benefits/INTEGRATION_EXAMPLE.tsx
apps/pickly_admin/src/components/benefits/InlineEditCell.tsx
apps/pickly_admin/src/components/benefits/SortableRow.tsx
apps/pickly_admin/src/components/shared/FileUploader.example.tsx
apps/pickly_admin/src/pages/benefits/BenefitAnnouncementForm.tsx
apps/pickly_admin/src/pages/benefits/BenefitAnnouncementList.tsx
apps/pickly_admin/src/pages/benefits/BenefitCategoryPage.tsx
apps/pickly_admin/src/pages/benefits/BenefitManagementPage.tsx
apps/pickly_admin/src/types/database.ts ⭐ (Supabase 자동생성)
```

### 문서 (3개)
```
PRD.md
.claude/agents/specialists/onboarding-database-manager.md
.claude/agents/core/onboarding-coordinator.md
```

## 🎯 다음 단계

### 1. PR 생성 및 리뷰
```
제목: [Refactor] DB 스키마 v2.0 - Phase 1 MVP 구조
라벨: refactor, breaking-change, backend
```

### 2. 남은 타입 에러 해결
```
브랜치: fix/admin-field-mismatch
작업: DB 마이그레이션 또는 컴포넌트 수정
예상 시간: 1-2시간
```

### 3. Phase 1 기능 완성
- 온보딩 플로우 완성
- 공고 목록/상세 화면
- LH 공공임대 API 연동
- 관리자 백오피스 CRUD

## 📊 성과 지표

### 코드 품질 개선
- **테이블 수**: 12+ → 8개 (33% 감소)
- **타입 정확도**: 수동 → Supabase 자동생성 (100% 정확)
- **유지보수성**: 복잡한 구조 → 단순한 MVP 구조

### 개발 속도 향상
- **타입 동기화**: 수동 → CLI 자동화
- **에이전트 제약**: 무분별한 테이블 생성 방지
- **코드 리뷰**: PRD 기반 검증 체계

## 🔗 관련 링크
- [PRD v7.0](../PRD.md)
- [DB 스키마](../backend/supabase/migrations/20251027000001_correct_schema.sql)
- [GitHub PR](https://github.com/khjun0321/pickly_service/pull/new/feature/refactor-db-schema)

---

**작성자**: Claude Code + 권현준
**작성일**: 2025.10.27
**버전**: v2.0
