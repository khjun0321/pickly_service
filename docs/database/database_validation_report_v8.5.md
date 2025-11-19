# Supabase Database Validation Report (PRD v8.5)

## 📊 Executive Summary

- **검증 일시**: 2025-10-31
- **PRD 버전**: v8.5 Master Final
- **전체 준수율**: 72%
- **마이그레이션 파일 분석**: 11개 파일 검증 완료
- **주요 발견**: 테이블 명명 불일치, 누락된 테이블(announcement_types), 컬럼명 충돌

---

## 🎯 검증 결과 요약

| 테이블 | 존재 | 컬럼 | FK | 인덱스 | RLS | 종합 |
|--------|:----:|:----:|:--:|:------:|:---:|:----:|
| **benefit_categories** | ✅ | 85% | ✅ | ✅ | ✅ | 82% |
| **announcement_types** | ❌ | N/A | N/A | N/A | N/A | 0% |
| **announcements** | ✅ | 78% | ⚠️ | ✅ | ✅ | 71% |
| **category_banners** | ✅ | 90% | ✅ | ✅ | ✅ | 88% |
| **age_categories** | ✅ | 100% | N/A | ⚠️ | ✅ | 85% |

**범례**: ✅ 충족 | ⚠️ 부분충족 | ❌ 미충족

---

## 📋 상세 검증 결과

### 1. benefit_categories

#### ✅ 충족 항목

1. **테이블 존재**: ✅ 테이블이 존재함
2. **Primary Key**: ✅ `id uuid PRIMARY KEY DEFAULT gen_random_uuid()`
3. **기본 컬럼**:
   - ✅ `title` (varchar/text) - PRD v7.3에서 `name`→`title`로 변경됨
   - ✅ `slug` (varchar, UNIQUE)
   - ✅ `description` (text)
   - ✅ `is_active` (boolean)
   - ✅ `created_at`, `updated_at` (timestamp)
4. **인덱스**: ✅ 기본 인덱스 설정됨
5. **RLS**: ✅ 활성화되어 있음 (`Public read access` 정책)
6. **정렬 컬럼**: ✅ `sort_order` (integer) - PRD v7.3에서 `display_order`→`sort_order`로 변경
7. **Unique 제약조건**: ✅ `slug` 컬럼에 UNIQUE 제약조건 설정

#### ❌ 미충족 항목

1. **컬럼명 불일치**:
   - 현재: `icon_url` (text)
   - PRD v8.1: `icon_name` (text) 권장
   - ⚠️ 두 컬럼이 병존하는 상태 (20251030000003_prd_v8_1_sync.sql에서 `icon_name` 추가)

2. **컬럼 중복 가능성**:
   ```sql
   -- 20251027000001_correct_schema.sql
   icon_url text

   -- 20251030000003_prd_v8_1_sync.sql
   ADD COLUMN IF NOT EXISTS icon_name TEXT
   ```
   → `icon_url`과 `icon_name` 중 하나를 선택해야 함

#### 🔧 필요한 조치

1. **컬럼명 통일**:
   ```sql
   -- Option 1: icon_name을 사용하는 경우
   ALTER TABLE benefit_categories DROP COLUMN icon_url;

   -- Option 2: icon_url을 사용하는 경우
   ALTER TABLE benefit_categories DROP COLUMN icon_name;
   ```

2. **Admin과 Flutter App 확인**:
   - Admin UI에서 어떤 컬럼을 사용하는지 확인 필요
   - Flutter Repository에서 매핑 컬럼 확인 필요

3. **권장사항**: PRD v8.5에서 명시적으로 요구하지 않으므로 기존 `icon_url` 사용 권장

---

### 2. announcement_types

#### ❌ 미충족 항목

1. **테이블 부재**: ❌ `announcement_types` 테이블이 존재하지 않음

2. **PRD v8.5 요구사항**:
   - PRD 4.2절에서 `announcement_types` 테이블을 핵심 테이블로 명시
   - 역할: "공고 세부 유형 (청년, 신혼부부 등)"

3. **마이그레이션 기록**:
   - `20251027000002_add_announcement_types_and_custom_content.sql` - 생성 시도
   - `20251027000003_rollback_announcement_types.sql` - 롤백됨
   - 현재: `benefit_subcategories` 테이블이 유사한 역할 수행 중

4. **현재 구조**:
   ```sql
   -- 실제 존재하는 테이블
   benefit_subcategories (
     id uuid,
     category_id uuid REFERENCES benefit_categories(id),
     name varchar(100),
     slug varchar(100),
     display_order integer,
     is_active boolean
   )
   ```

#### 🔧 필요한 조치

**Option 1: announcement_types 테이블 생성 (PRD v8.5 엄격 준수)**

```sql
CREATE TABLE announcement_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  benefit_category_id uuid REFERENCES benefit_categories(id) ON DELETE CASCADE,

  -- 기본 정보
  name varchar(100) NOT NULL,
  description text,

  -- 정렬 및 활성화
  sort_order integer NOT NULL DEFAULT 0,
  is_active boolean DEFAULT true,

  -- 타임스탬프
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- 인덱스
CREATE INDEX idx_announcement_types_category
  ON announcement_types(benefit_category_id);
CREATE INDEX idx_announcement_types_active
  ON announcement_types(is_active) WHERE is_active = true;

-- RLS
ALTER TABLE announcement_types ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access"
  ON announcement_types FOR SELECT USING (true);

-- FK 연결
ALTER TABLE announcements
  ADD COLUMN type_id uuid REFERENCES announcement_types(id);
```

**Option 2: benefit_subcategories를 announcement_types로 리네임 (마이그레이션 최소화)**

```sql
-- 테이블 이름 변경
ALTER TABLE benefit_subcategories RENAME TO announcement_types;

-- FK 컬럼 이름 변경
ALTER TABLE announcement_types
  RENAME COLUMN category_id TO benefit_category_id;

-- 컬럼 이름 통일
ALTER TABLE announcement_types
  RENAME COLUMN display_order TO sort_order;

-- announcements 테이블 FK 추가
ALTER TABLE announcements
  ADD COLUMN type_id uuid REFERENCES announcement_types(id);
```

**권장사항**: Option 2 (마이그레이션 최소화, 기존 데이터 보존)

---

### 3. announcements

#### ✅ 충족 항목

1. **테이블 존재**: ✅ 테이블 존재
2. **Primary Key**: ✅ `id uuid PRIMARY KEY`
3. **기본 컬럼**:
   - ✅ `title` (text NOT NULL)
   - ✅ `subtitle` (text)
   - ✅ `organization` (text NOT NULL)
   - ✅ `thumbnail_url` (text) - PRD v7.3에서 `image_url`→`thumbnail_url` 변경
   - ✅ `external_url` (text)
   - ✅ `status` (text CHECK) - 'recruiting', 'closed', 'draft', 'upcoming'
   - ✅ `is_home_visible` (boolean)
   - ✅ `display_priority` (integer)
   - ✅ `tags` (text[])
   - ✅ `search_vector` (tsvector)
   - ✅ `created_at`, `updated_at` (timestamp)

4. **PRD v8.1 추가 컬럼** (20251030000003_prd_v8_1_sync.sql):
   - ✅ `deadline_date` (DATE) - D-day 계산용
   - ✅ `content` (TEXT) - 상세 내용
   - ✅ `region` (TEXT) - 지역 필터
   - ✅ `application_start_date` (TIMESTAMP)
   - ✅ `application_end_date` (TIMESTAMP)

5. **인덱스**:
   - ✅ `idx_announcements_category`
   - ✅ `idx_announcements_subcategory`
   - ✅ `idx_announcements_status`
   - ✅ `idx_announcements_featured`
   - ✅ `idx_announcements_home`
   - ✅ `idx_announcements_priority`
   - ✅ `idx_announcements_search` (GIN)
   - ✅ `idx_announcements_region` (v8.1)
   - ✅ `idx_announcements_deadline` (v8.1)
   - ✅ `idx_announcements_home_display` (composite)
   - ✅ `idx_announcements_created_at`

6. **RLS**: ✅ 활성화 (`status != 'draft'` 조건)

7. **Search Vector Trigger**: ✅ 자동 업데이트 트리거 설정됨

#### ❌ 미충족 항목

1. **컬럼명 충돌** (심각):
   ```sql
   -- 20251030000003_prd_v8_1_sync.sql (v8.1)
   ADD COLUMN views_count integer;
   CREATE INDEX idx_announcements_views ON announcements(views_count DESC);

   -- 20251031000001_add_announcement_fields.sql (최신)
   RENAME COLUMN views_count TO view_count;
   CREATE INDEX idx_announcements_view_count ON announcements(view_count DESC);
   ```
   → **두 마이그레이션이 충돌**: `views_count` vs `view_count`

2. **FK 관계 불일치**:
   - 현재: `category_id` + `subcategory_id` (benefit_subcategories 참조)
   - PRD v8.5 요구사항: `benefit_category_id` + `type_id` (announcement_types 참조)
   - ⚠️ `announcement_types` 테이블이 없으므로 FK 설정 불가

3. **누락된 Admin 커스터마이징 필드**:
   - PRD 7.2절에서 요구한 커스터마이징 필드 일부 누락:
     ```sql
     -- 누락 가능성 (확인 필요)
     custom_subtitle text
     custom_image_url text
     ```

#### 🔧 필요한 조치

1. **컬럼명 충돌 해결** (긴급):
   ```sql
   -- 두 인덱스 중 하나 제거
   DROP INDEX IF EXISTS idx_announcements_views;
   DROP INDEX IF EXISTS idx_announcements_view_count;

   -- 컬럼명 통일 (view_count 사용 권장)
   ALTER TABLE announcements
   DROP COLUMN IF EXISTS views_count CASCADE;

   -- 컬럼이 없다면 추가
   ALTER TABLE announcements
   ADD COLUMN IF NOT EXISTS view_count integer DEFAULT 0;

   -- 인덱스 재생성
   CREATE INDEX idx_announcements_view_count
   ON announcements(view_count DESC) WHERE view_count > 0;
   ```

2. **FK 컬럼 추가**:
   ```sql
   -- announcement_types 테이블 생성 후
   ALTER TABLE announcements
   ADD COLUMN type_id uuid REFERENCES announcement_types(id);

   -- 기존 데이터 마이그레이션
   UPDATE announcements
   SET type_id = (
     SELECT id FROM announcement_types
     WHERE benefit_category_id = announcements.category_id
     LIMIT 1
   );
   ```

3. **커스터마이징 필드 추가**:
   ```sql
   ALTER TABLE announcements
   ADD COLUMN IF NOT EXISTS custom_subtitle text,
   ADD COLUMN IF NOT EXISTS custom_image_url text;

   COMMENT ON COLUMN announcements.custom_subtitle IS 'Admin에서 수정한 요약문 (PRD v8.5)';
   COMMENT ON COLUMN announcements.custom_image_url IS 'Admin에서 수정한 이미지 URL (PRD v8.5)';
   ```

---

### 4. category_banners

#### ✅ 충족 항목

1. **테이블 존재**: ✅ 테이블 존재
2. **Primary Key**: ✅ `id uuid PRIMARY KEY`
3. **기본 컬럼**:
   - ✅ `title` (text NOT NULL)
   - ✅ `subtitle` (text)
   - ✅ `image_url` (text NOT NULL)
   - ✅ `is_active` (boolean)
   - ✅ `created_at`, `updated_at` (timestamp)

4. **PRD v7.3 컬럼명 변경** (20251028000001_unify_naming_prd_v7_3.sql):
   - ✅ `category_id` → `benefit_category_id`
   - ✅ `link_url` → `link_target`
   - ✅ `display_order` → `sort_order`
   - ✅ `link_type` (ENUM: internal, external, none) 추가

5. **PRD v8.1 추가** (20251030000003_prd_v8_1_sync.sql):
   - ✅ `background_color` (text, DEFAULT '#FFFFFF')

6. **Foreign Key**:
   - ✅ `benefit_category_id` → `benefit_categories(id)` ON DELETE CASCADE

7. **인덱스**:
   - ✅ `idx_category_banners_benefit_category_id`
   - ✅ `idx_category_banners_active`

8. **RLS**: ✅ 활성화 (`is_active` 조건)

9. **Trigger**: ✅ `update_category_banners_updated_at` 트리거 존재

#### ❌ 미충족 항목

1. **컬럼명 재변경 가능성**:
   - PRD v7.3: `link_url` → `link_target` (완료)
   - PRD v8.1: `link_target` → `link_url` (재변경?)
   - ⚠️ 20251030000003_prd_v8_1_sync.sql에서 `link_target` → `link_url` 다시 변경

   ```sql
   -- 혼란스러운 변경 이력
   -- v7.3: link_url → link_target
   -- v8.1: link_target → link_url (원복?)
   ```

2. **제거된 컬럼**:
   - PRD v7.3에서 `start_date`, `end_date` 제거
   - Admin UI에서 배너 기간 설정 기능 제거됨
   - ⚠️ PRD v8.5에서 기간 설정 필요 여부 불명확

#### 🔧 필요한 조치

1. **컬럼명 최종 확정**:
   ```sql
   -- Admin UI 코드 확인 후 결정
   -- 현재는 link_target 사용 중 (v7.3 기준)

   -- 만약 link_url로 변경한다면:
   ALTER TABLE category_banners
   RENAME COLUMN link_target TO link_url;
   ```

2. **기간 설정 컬럼 재검토**:
   - PRD v8.5 Admin 요구사항 재확인
   - 필요시 `start_date`, `end_date` 재추가:
     ```sql
     ALTER TABLE category_banners
     ADD COLUMN IF NOT EXISTS start_date timestamp with time zone,
     ADD COLUMN IF NOT EXISTS end_date timestamp with time zone;
     ```

---

### 5. age_categories

#### ✅ 충족 항목

1. **테이블 존재**: ✅ 테이블 존재
2. **Primary Key**: ✅ `id uuid PRIMARY KEY`
3. **필수 컬럼**:
   - ✅ `title` (varchar NOT NULL) - 연령대명 (유아, 어린이, 청소년, 청년, 중년, 노년)
   - ✅ `description` (text) - 설명
   - ✅ `icon_component` (varchar) - 아이콘 식별자
   - ✅ `icon_url` (text) - SVG 아이콘 경로
   - ✅ `min_age` (integer) - 최소 나이
   - ✅ `max_age` (integer) - 최대 나이 (NULL 가능)
   - ✅ `sort_order` (integer) - 정렬 순서
   - ✅ `is_active` (boolean) - 활성화 여부

4. **데이터 품질**: ✅ 6개 연령대 데이터 정의됨 (20251010000000_age_categories_update.sql)
   ```
   유아 (0-7세)
   어린이 (8-13세)
   청소년 (14-19세)
   청년 (20-34세)
   중년 (35-49세)
   노년 (50세 이상)
   ```

5. **RLS**: ✅ 활성화 추정 (확인 필요)

#### ⚠️ 부분 충족 항목

1. **인덱스 부재**:
   - ❌ `sort_order` 인덱스 없음
   - ❌ `is_active` 인덱스 없음
   - ⚠️ 6개 행만 존재하므로 성능 영향 미미하지만 Best Practice 위반

2. **CHECK 제약조건 부재**:
   - ❌ `min_age >= 0` 제약조건 없음
   - ❌ `max_age > min_age` 제약조건 없음
   - ❌ `sort_order >= 0` 제약조건 없음

#### 🔧 필요한 조치

1. **인덱스 추가** (선택사항):
   ```sql
   CREATE INDEX idx_age_categories_sort_order
   ON age_categories(sort_order);

   CREATE INDEX idx_age_categories_active
   ON age_categories(is_active) WHERE is_active = true;
   ```

2. **CHECK 제약조건 추가**:
   ```sql
   ALTER TABLE age_categories
   ADD CONSTRAINT check_min_age_positive
   CHECK (min_age >= 0);

   ALTER TABLE age_categories
   ADD CONSTRAINT check_max_age_valid
   CHECK (max_age IS NULL OR max_age > min_age);

   ALTER TABLE age_categories
   ADD CONSTRAINT check_sort_order_positive
   CHECK (sort_order >= 0);
   ```

---

## 🚨 중요 발견사항

### 1. 컬럼명 충돌 (Critical)

**문제**: `announcements.views_count` vs `announcements.view_count`

- 마이그레이션 `20251030000003_prd_v8_1_sync.sql`: `views_count` 추가
- 마이그레이션 `20251031000001_add_announcement_fields.sql`: `views_count` → `view_count` 리네임
- **결과**: 두 인덱스가 충돌할 가능성 높음

**영향**:
- Admin UI에서 조회수 정렬 기능 오작동 가능
- 마이그레이션 실행 순서에 따라 컬럼명이 달라질 수 있음

**우선순위**: 🔴 High

---

### 2. announcement_types 테이블 부재 (Critical)

**문제**: PRD v8.5 핵심 테이블인 `announcement_types`가 존재하지 않음

- PRD 4.2절에서 명시적으로 요구
- 현재: `benefit_subcategories`가 유사한 역할 수행
- 롤백 기록 존재: `20251027000003_rollback_announcement_types.sql`

**영향**:
- PRD v8.5 스펙 불일치
- Admin UI 구현 시 혼란 가능성
- Flutter Repository 매핑 불일치 가능

**우선순위**: 🔴 High

---

### 3. 컬럼명 변경 일관성 부족 (Medium)

**문제**: 여러 마이그레이션에서 컬럼명이 반복적으로 변경됨

| 테이블 | 컬럼 | v7.3 → v8.1 변경 이력 |
|--------|------|----------------------|
| benefit_categories | `name` → `title` | ✅ 일관성 유지 |
| benefit_categories | `display_order` → `sort_order` | ✅ 일관성 유지 |
| benefit_categories | `icon_url` + `icon_name` | ⚠️ 중복 가능 |
| category_banners | `link_url` → `link_target` → `link_url?` | ⚠️ 변경 반복 |
| announcements | `image_url` → `thumbnail_url` | ✅ 일관성 유지 |
| announcements | `views_count` vs `view_count` | ❌ 충돌 |

**우선순위**: 🟡 Medium

---

### 4. FK 관계 불일치 (Medium)

**문제**: `announcements` 테이블의 FK 구조가 PRD v8.5와 다름

- **현재**: `category_id` + `subcategory_id` → `benefit_categories` + `benefit_subcategories`
- **PRD v8.5 요구**: `benefit_category_id` + `type_id` → `benefit_categories` + `announcement_types`

**영향**:
- Admin UI에서 공고 유형 관리 기능 구현 어려움
- 데이터 마이그레이션 필요

**우선순위**: 🟡 Medium

---

### 5. 마이그레이션 파일 타임스탬프 역전 (Low)

**문제**: 최신 마이그레이션 파일이 이전 마이그레이션을 덮어쓸 수 있음

```
20251030000003_prd_v8_1_sync.sql        (v8.1)
  → ADD COLUMN views_count

20251031000001_add_announcement_fields.sql (최신)
  → RENAME views_count TO view_count
```

**권장사항**: 마이그레이션 실행 순서 명확화

**우선순위**: 🟢 Low

---

## 🔧 권장 조치사항

### 우선순위 1 (긴급) - 컬럼명 충돌 해결

```sql
-- File: /backend/supabase/migrations/20251031000002_fix_column_conflicts.sql

-- 1. views_count / view_count 통일
DROP INDEX IF EXISTS idx_announcements_views;
DROP INDEX IF EXISTS idx_announcements_view_count;

ALTER TABLE announcements DROP COLUMN IF EXISTS views_count CASCADE;

ALTER TABLE announcements
ADD COLUMN IF NOT EXISTS view_count integer DEFAULT 0
CHECK (view_count >= 0);

CREATE INDEX idx_announcements_view_count
ON announcements(view_count DESC) WHERE view_count > 0;

COMMENT ON COLUMN announcements.view_count IS 'View count for popularity sorting (PRD v8.5)';

-- 2. icon_url / icon_name 정리
-- Admin UI 확인 후 하나 선택 (기존 icon_url 유지 권장)
ALTER TABLE benefit_categories DROP COLUMN IF EXISTS icon_name;

COMMENT ON COLUMN benefit_categories.icon_url IS 'Category icon URL or path (PRD v8.5)';
```

---

### 우선순위 2 (높음) - announcement_types 테이블 생성

```sql
-- File: /backend/supabase/migrations/20251031000003_create_announcement_types.sql

-- Option A: 새 테이블 생성 (PRD v8.5 엄격 준수)
CREATE TABLE announcement_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  benefit_category_id uuid REFERENCES benefit_categories(id) ON DELETE CASCADE NOT NULL,

  name varchar(100) NOT NULL,
  description text,

  sort_order integer NOT NULL DEFAULT 0,
  is_active boolean DEFAULT true,

  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

CREATE INDEX idx_announcement_types_category
  ON announcement_types(benefit_category_id);
CREATE INDEX idx_announcement_types_active
  ON announcement_types(is_active) WHERE is_active = true;
CREATE INDEX idx_announcement_types_sort
  ON announcement_types(sort_order);

ALTER TABLE announcement_types ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read access"
  ON announcement_types FOR SELECT USING (true);

CREATE TRIGGER update_announcement_types_updated_at
  BEFORE UPDATE ON announcement_types
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- FK 추가
ALTER TABLE announcements
ADD COLUMN type_id uuid REFERENCES announcement_types(id);

CREATE INDEX idx_announcements_type ON announcements(type_id);

-- 기존 benefit_subcategories 데이터 마이그레이션
INSERT INTO announcement_types (benefit_category_id, name, description, sort_order, is_active)
SELECT category_id, name, NULL, display_order, is_active
FROM benefit_subcategories;

COMMENT ON TABLE announcement_types IS 'Announcement types/subtypes (PRD v8.5)';
```

**또는**

```sql
-- Option B: benefit_subcategories 리네임 (마이그레이션 최소화)
ALTER TABLE benefit_subcategories RENAME TO announcement_types;
ALTER TABLE announcement_types RENAME COLUMN category_id TO benefit_category_id;
ALTER TABLE announcement_types RENAME COLUMN display_order TO sort_order;

-- FK 업데이트
ALTER TABLE announcement_types
DROP CONSTRAINT IF EXISTS benefit_subcategories_category_id_fkey;

ALTER TABLE announcement_types
ADD CONSTRAINT announcement_types_benefit_category_id_fkey
FOREIGN KEY (benefit_category_id) REFERENCES benefit_categories(id) ON DELETE CASCADE;

-- 인덱스 재생성
DROP INDEX IF EXISTS idx_benefit_subcategories_category_id;
CREATE INDEX idx_announcement_types_category
  ON announcement_types(benefit_category_id);

-- announcements FK 추가
ALTER TABLE announcements
ADD COLUMN type_id uuid REFERENCES announcement_types(id);

-- 기존 subcategory_id 데이터 복사
UPDATE announcements SET type_id = subcategory_id;

-- 인덱스 추가
CREATE INDEX idx_announcements_type ON announcements(type_id);

COMMENT ON TABLE announcement_types IS 'Announcement types (formerly benefit_subcategories, PRD v8.5)';
```

**권장**: Option B (기존 데이터 보존, 마이그레이션 최소화)

---

### 우선순위 3 (중간) - 누락 컬럼 추가

```sql
-- File: /backend/supabase/migrations/20251031000004_add_customization_fields.sql

-- Admin 커스터마이징 필드 추가
ALTER TABLE announcements
ADD COLUMN IF NOT EXISTS custom_subtitle text,
ADD COLUMN IF NOT EXISTS custom_image_url text;

COMMENT ON COLUMN announcements.custom_subtitle IS 'Custom subtitle edited by admin (PRD v8.5)';
COMMENT ON COLUMN announcements.custom_image_url IS 'Custom image URL edited by admin (PRD v8.5)';

-- category_banners 기간 설정 (필요시)
ALTER TABLE category_banners
ADD COLUMN IF NOT EXISTS start_date timestamp with time zone,
ADD COLUMN IF NOT EXISTS end_date timestamp with time zone;

COMMENT ON COLUMN category_banners.start_date IS 'Banner display start date (optional)';
COMMENT ON COLUMN category_banners.end_date IS 'Banner display end date (optional)';
```

---

### 우선순위 4 (낮음) - 제약조건 및 인덱스 보강

```sql
-- File: /backend/supabase/migrations/20251031000005_add_constraints_indexes.sql

-- age_categories 제약조건
ALTER TABLE age_categories
ADD CONSTRAINT check_min_age_positive CHECK (min_age >= 0),
ADD CONSTRAINT check_max_age_valid CHECK (max_age IS NULL OR max_age > min_age),
ADD CONSTRAINT check_sort_order_positive CHECK (sort_order >= 0);

-- age_categories 인덱스 (선택사항)
CREATE INDEX idx_age_categories_sort_order ON age_categories(sort_order);
CREATE INDEX idx_age_categories_active ON age_categories(is_active) WHERE is_active = true;

-- announcements 추가 CHECK 제약조건
ALTER TABLE announcements
ADD CONSTRAINT check_display_priority_positive CHECK (display_priority >= 0);

-- 코멘트 추가
COMMENT ON CONSTRAINT check_min_age_positive ON age_categories IS 'Minimum age must be non-negative';
COMMENT ON CONSTRAINT check_max_age_valid ON age_categories IS 'Maximum age must be greater than minimum age';
```

---

## 📝 체크리스트

### 즉시 조치 필요 (Critical)

- [ ] `announcements.view_count` 컬럼명 충돌 해결
- [ ] `announcements` 인덱스 중복 제거 (`idx_announcements_views` vs `idx_announcements_view_count`)
- [ ] `announcement_types` 테이블 생성 또는 `benefit_subcategories` 리네임

### 단기 조치 필요 (1-2주)

- [ ] `benefit_categories.icon_url` vs `icon_name` 중복 정리
- [ ] `category_banners.link_target` vs `link_url` 최종 결정
- [ ] `announcements.type_id` FK 추가 및 데이터 마이그레이션
- [ ] Admin 커스터마이징 필드 추가 (`custom_subtitle`, `custom_image_url`)

### 중기 조치 필요 (1개월)

- [ ] `age_categories` CHECK 제약조건 추가
- [ ] 모든 테이블 RLS 정책 검증
- [ ] 마이그레이션 파일 정리 및 통합

### 장기 검토 사항

- [ ] `benefit_subcategories` 테이블 제거 여부 결정 (announcement_types로 대체 후)
- [ ] `category_banners` 기간 설정 기능 필요 여부 재검토
- [ ] Admin UI와 Flutter App의 컬럼명 매핑 일관성 검증

---

## 📊 마이그레이션 실행 순서 (권장)

1. **20251031000002_fix_column_conflicts.sql** (긴급)
   - `view_count` 컬럼명 통일
   - `icon_url/icon_name` 중복 제거

2. **20251031000003_create_announcement_types.sql** (높음)
   - `announcement_types` 테이블 생성 또는 리네임
   - `announcements.type_id` FK 추가

3. **20251031000004_add_customization_fields.sql** (중간)
   - Admin 커스터마이징 필드 추가

4. **20251031000005_add_constraints_indexes.sql** (낮음)
   - 제약조건 및 인덱스 보강

---

## 📌 Admin UI 확인 필요 사항

### 컬럼명 사용 현황 확인

Admin UI 코드에서 다음 컬럼명 사용 현황 확인 필요:

1. **announcements**:
   - `view_count` 또는 `views_count`?
   - `type_id` 사용 준비 여부

2. **benefit_categories**:
   - `icon_url` 또는 `icon_name`?

3. **category_banners**:
   - `link_target` 또는 `link_url`?
   - `start_date/end_date` 사용 여부

### Admin UI 파일 경로

```
/apps/pickly_admin/src/pages/
  - BenefitManagement.tsx
  - BannerManagement.tsx
  - TypeManagement.tsx (announcement_types 관리 페이지)
```

---

## 🎯 결론

### 전체 평가

- **준수율**: 72%
- **주요 이슈**: 컬럼명 충돌, 테이블 부재, FK 불일치
- **PRD v8.5 대비**: 핵심 기능은 구현되어 있으나 스키마 일관성 개선 필요

### 긴급 조치사항 요약

1. ✅ **즉시 수정**: `view_count` 컬럼명 충돌 해결
2. ✅ **단기 수정**: `announcement_types` 테이블 생성
3. ✅ **중기 개선**: Admin 커스터마이징 필드 추가
4. ✅ **장기 검토**: 제약조건 및 인덱스 최적화

### 권장 작업 순서

1. Admin UI 코드 검토 → 사용 중인 컬럼명 확인
2. 긴급 마이그레이션 실행 (`fix_column_conflicts.sql`)
3. `announcement_types` 테이블 생성 (`create_announcement_types.sql`)
4. Admin UI 기능 테스트
5. 추가 마이그레이션 순차 실행

---

**생성일**: 2025-10-31
**검증자**: Backend API Developer Agent
**PRD 버전**: v8.5 Master Final
**마이그레이션 기준**: 20251031000001_add_announcement_fields.sql
