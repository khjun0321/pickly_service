# Admin Material UI - 누락된 DB 필드 분석

## 📋 문서 정보

- **작성일**: 2025-10-31
- **목적**: BenefitAnnouncementList 리팩터링을 위한 DB 스키마 확인
- **상세 계획**: [admin_material_refactoring_plan.md](./admin_material_refactoring_plan.md)

---

## ❌ 현재 `announcements` 테이블 스키마

**파일**: `backend/supabase/migrations/20251027000001_correct_schema.sql`

```sql
CREATE TABLE announcements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  -- 기본 정보
  title text NOT NULL,
  subtitle text,
  organization text NOT NULL,

  -- 카테고리
  category_id uuid REFERENCES benefit_categories(id),
  subcategory_id uuid REFERENCES benefit_subcategories(id),

  -- 썸네일
  thumbnail_url text,

  -- 외부 링크
  external_url text,

  -- 상태
  status text NOT NULL DEFAULT 'recruiting' CHECK (status IN ('recruiting', 'closed', 'draft')),

  -- 노출 설정
  is_featured boolean DEFAULT false,
  is_home_visible boolean DEFAULT false,
  display_priority integer DEFAULT 0,

  -- 메타 데이터
  views_count integer DEFAULT 0,
  tags text[],
  search_vector tsvector,

  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);
```

---

## ⚠️ 누락된 필드

### 1. `region` (지역)

**목적**: 지역별 필터링 (서울, 경기, 인천, 부산...)

**타입**: `text` or `varchar(50)`

**예시 값**:
- "서울"
- "경기"
- "인천"
- "부산"
- "대구"
- "전국"

---

### 2. `application_start_date` (신청 시작일)

**목적**: 신청 기간 표시

**타입**: `timestamp with time zone`

**예시**: `2025-11-01 00:00:00+09`

---

### 3. `application_end_date` (신청 마감일)

**목적**: D-Day 계산 기준

**타입**: `timestamp with time zone`

**예시**: `2025-11-15 23:59:59+09`

---

### 4. `view_count` vs `views_count` 혼란

**현재**: `views_count integer DEFAULT 0`

**사용 중**: BenefitAnnouncementList.tsx에서 `view_count` 참조

**결정**:
- Option 1: DB 필드명을 `view_count`로 변경 (권장)
- Option 2: 코드에서 `views_count`로 변경

---

## ✅ 추가해야 할 마이그레이션

### 파일: `backend/supabase/migrations/20251031000001_add_announcement_fields.sql`

```sql
-- ============================================
-- Add missing fields to announcements table
-- Date: 2025-10-31
-- Purpose: Support Admin UI filtering and D-Day calculation
-- ============================================

-- 1. Add region field
ALTER TABLE announcements
ADD COLUMN region varchar(50);

COMMENT ON COLUMN announcements.region IS '지역 (서울, 경기, 인천, 부산, 전국 등)';

-- 2. Add application dates
ALTER TABLE announcements
ADD COLUMN application_start_date timestamp with time zone,
ADD COLUMN application_end_date timestamp with time zone;

COMMENT ON COLUMN announcements.application_start_date IS '신청 시작일';
COMMENT ON COLUMN announcements.application_end_date IS '신청 마감일 (D-Day 계산 기준)';

-- 3. Rename views_count to view_count (for consistency)
ALTER TABLE announcements
RENAME COLUMN views_count TO view_count;

COMMENT ON COLUMN announcements.view_count IS '조회수';

-- 4. Add index for filtering by region
CREATE INDEX idx_announcements_region ON announcements(region)
WHERE region IS NOT NULL;

-- 5. Add index for sorting by application_end_date
CREATE INDEX idx_announcements_deadline ON announcements(application_end_date)
WHERE application_end_date IS NOT NULL;

-- 6. Update status check constraint to include 'upcoming'
ALTER TABLE announcements DROP CONSTRAINT IF EXISTS announcements_status_check;
ALTER TABLE announcements
ADD CONSTRAINT announcements_status_check
CHECK (status IN ('recruiting', 'closed', 'draft', 'upcoming'));

COMMENT ON CONSTRAINT announcements_status_check ON announcements IS
  '상태: recruiting(모집중), closed(마감), draft(임시저장), upcoming(예정)';

-- ============================================
-- Migration complete!
-- ============================================
```

---

## 📊 필드 사용 사례

### 1. region 필드

**Admin UI (BenefitAnnouncementList)**:
```typescript
// 필터링
const filteredAnnouncements = announcements.filter((a) =>
  regionFilter === 'all' || a.region === regionFilter
)

// 지역 목록 추출
const regions = [...new Set(announcements.map(a => a.region).filter(Boolean))]
```

**예시 데이터**:
```typescript
{
  id: "uuid",
  title: "서울시 청년 행복주택",
  region: "서울",
  // ...
}
```

---

### 2. application_start_date / application_end_date

**Admin UI (BenefitAnnouncementList)**:
```typescript
// D-Day 계산
import { differenceInDays } from 'date-fns'

function calculateDDay(endDate: string | null) {
  if (!endDate) return null
  const dDay = differenceInDays(new Date(endDate), new Date())
  return dDay
}

// DataGrid 컬럼
{
  field: 'd_day',
  headerName: 'D-Day',
  renderCell: (params) => {
    const dDay = calculateDDay(params.row.application_end_date)
    return dDay !== null ? <Chip label={`D-${dDay}`} /> : '-'
  }
}
```

**예시 데이터**:
```typescript
{
  id: "uuid",
  title: "경기도 행복주택",
  application_start_date: "2025-11-01T00:00:00+09:00",
  application_end_date: "2025-11-15T23:59:59+09:00",
  // ...
}
```

---

### 3. view_count 정렬

**Admin UI (BenefitAnnouncementList)**:
```typescript
// 인기순 정렬
const sortedAnnouncements = announcements.sort((a, b) =>
  (b.view_count || 0) - (a.view_count || 0)
)

// DataGrid 컬럼
{
  field: 'view_count',
  headerName: '조회수',
  width: 100,
  align: 'center',
  valueFormatter: (value) => value?.toLocaleString() || '0',
}
```

---

## 🎯 다음 단계

### 1. 마이그레이션 실행

```bash
# 로컬 Supabase
cd backend
npx supabase db reset

# 또는 개발/프로덕션
npx supabase db push
```

### 2. 타입 재생성

```bash
# Supabase 타입 자동 생성
npx supabase gen types typescript --local > apps/pickly_admin/src/types/database.ts
```

### 3. API 함수 업데이트

```typescript
// apps/pickly_admin/src/api/announcements.ts
export interface AnnouncementFilters {
  category_id?: string
  status?: string
  region?: string          // ✅ 추가
  is_active?: boolean
  is_featured?: boolean
  search?: string
}

export async function fetchAnnouncements(filters?: AnnouncementFilters) {
  let query = supabase.from('announcements').select('*')

  if (filters?.region) {
    query = query.eq('region', filters.region)  // ✅ 추가
  }

  // ...
}
```

### 4. Admin UI 구현

**BenefitAnnouncementList.tsx**:
- region 필터 드롭다운 추가
- application_end_date 기반 D-Day 계산
- view_count 기반 인기순 정렬

---

## ⚠️ 기존 데이터 마이그레이션 (선택사항)

만약 기존 공고 데이터가 있다면:

```sql
-- 기존 공고에 기본값 설정
UPDATE announcements
SET
  region = '전국',
  application_start_date = created_at,
  application_end_date = created_at + interval '30 days'
WHERE region IS NULL;
```

---

## 📚 참고 문서

- **마이그레이션 가이드**: https://supabase.com/docs/guides/database/migrations
- **타입 생성**: https://supabase.com/docs/guides/api/generating-types
- **date-fns**: https://date-fns.org/v3.0.0/docs/differenceInDays

---

## 📝 체크리스트

- [ ] 마이그레이션 파일 생성
- [ ] 로컬에서 마이그레이션 테스트
- [ ] Supabase 타입 재생성
- [ ] API 함수 업데이트
- [ ] Admin UI 구현
- [ ] 기존 데이터 마이그레이션 (필요 시)
- [ ] 테스트 (필터, 정렬, D-Day 계산)

---

**작성 완료 - 2025-10-31**
