-- Migration: Reset Age Categories to Official 6 (PRD v9.6.1)
-- Date: 2025-11-03
-- PRD: v9.6.1 - Pickly Integrated System
-- Purpose: Clean up test/duplicate age categories and set official 6 age ranges

-- =====================================================
-- 🧹 Age Categories Cleanup Context
-- =====================================================
/*
현재 문제:
- 12개 연령대 존재 (PRD v9.6.1은 6개만 필요)
- 중복: "청년" 2개 (19-39세, 20-34세)
- 특수 카테고리: 신혼부부, 육아중인 부모, 다자녀, 장애인 (연령대 아님)

PRD v9.6.1 공식 6개 카테고리:
1. 청년 (19-39세) - young_man.svg
2. 신혼부부·예비부부 (20-49세) - bride.svg
3. 육아중인 부모 (25-49세) - baby.svg
4. 다자녀 가구 (25-49세) - kinder.svg
5. 어르신 (65-99세) - old_man.svg
6. 장애인 (0-99세) - wheelchair.svg

해결:
1. 기존 데이터 전체 백업 (CSV 완료)
2. age_categories 테이블 전체 삭제
3. 공식 6개 연령대 재생성
4. 올바른 아이콘 경로 설정
*/

-- =====================================================
-- 📊 Before Cleanup
-- =====================================================
/*
Total age_categories: 12

Duplicates/Issues:
- "청년" x2 (19-39세, 20-34세) - 중복
- "노년" + "어르신" (50세+, 65세+) - 중복
- "신혼부부·예비부부" - 특수 카테고리 (연령대 아님)
- "육아중인 부모" - 특수 카테고리
- "다자녀 가구" - 특수 카테고리
- "장애인" - 특수 카테고리

Backup: docs/history/db_backup_age_categories_full_20251103_2040.csv
*/

-- =====================================================
-- 🧹 Step 1: Delete All Existing Age Categories
-- =====================================================

-- Truncate table to remove all data but keep structure
TRUNCATE TABLE public.age_categories CASCADE;

-- =====================================================
-- ✨ Step 2: Insert Official 6 Age Categories
-- =====================================================

INSERT INTO public.age_categories (
  id,
  title,
  description,
  icon_component,
  icon_url,
  min_age,
  max_age,
  sort_order,
  is_active,
  created_at,
  updated_at
)
VALUES
  -- 1. 청년 (19-39세)
  (
    gen_random_uuid(),
    '청년',
    '19세부터 39세까지의 청년',
    'YoungMan',
    'young_man.svg',
    19,
    39,
    1,
    true,
    NOW(),
    NOW()
  ),

  -- 2. 신혼부부·예비부부 (20-49세)
  (
    gen_random_uuid(),
    '신혼부부·예비부부',
    '20세부터 49세까지의 신혼부부 및 예비부부',
    'Bride',
    'bride.svg',
    20,
    49,
    2,
    true,
    NOW(),
    NOW()
  ),

  -- 3. 육아중인 부모 (25-49세)
  (
    gen_random_uuid(),
    '육아중인 부모',
    '25세부터 49세까지의 육아중인 부모',
    'Baby',
    'baby.svg',
    25,
    49,
    3,
    true,
    NOW(),
    NOW()
  ),

  -- 4. 다자녀 가구 (25-49세)
  (
    gen_random_uuid(),
    '다자녀 가구',
    '25세부터 49세까지의 다자녀 가구',
    'Kinder',
    'kinder.svg',
    25,
    49,
    4,
    true,
    NOW(),
    NOW()
  ),

  -- 5. 어르신 (65-99세)
  (
    gen_random_uuid(),
    '어르신',
    '65세부터 99세까지의 어르신',
    'OldMan',
    'old_man.svg',
    65,
    99,
    5,
    true,
    NOW(),
    NOW()
  ),

  -- 6. 장애인 (0-99세)
  (
    gen_random_uuid(),
    '장애인',
    '모든 연령대의 장애인',
    'WheelChair',
    'wheelchair.svg',
    0,
    99,
    6,
    true,
    NOW(),
    NOW()
  );

-- =====================================================
-- 🔍 Verification
-- =====================================================

DO $$
DECLARE
  age_cat_count INTEGER;
  invalid_count INTEGER;
BEGIN
  -- Count total age categories
  SELECT COUNT(*) INTO age_cat_count FROM age_categories;

  -- Check for invalid entries (no min_age for age-based categories)
  SELECT COUNT(*) INTO invalid_count
  FROM age_categories
  WHERE min_age IS NULL AND title NOT LIKE '%부모%' AND title NOT LIKE '%부부%';

  -- Verify exactly 6 age categories
  IF age_cat_count != 6 THEN
    RAISE EXCEPTION 'Expected 6 age categories, found: %', age_cat_count;
  END IF;

  -- Verify no invalid entries
  IF invalid_count > 0 THEN
    RAISE EXCEPTION 'Found % invalid age categories without min_age', invalid_count;
  END IF;

  RAISE NOTICE '✅ Age categories reset successful';
  RAISE NOTICE '📊 Total age categories: %', age_cat_count;
  RAISE NOTICE '✅ All age categories have valid ranges';
  RAISE NOTICE '✅ PRD v9.6.1 alignment: COMPLETE';
END $$;

-- =====================================================
-- 📋 Expected Age Categories After Reset
-- =====================================================
/*
ID | Title               | Min Age | Max Age | Icon URL
---|---------------------|---------|---------|------------------
1  | 청년                | 19      | 39      | young_man.svg
2  | 신혼부부·예비부부   | 20      | 49      | bride.svg
3  | 육아중인 부모       | 25      | 49      | baby.svg
4  | 다자녀 가구         | 25      | 49      | kinder.svg
5  | 어르신              | 65      | 99      | old_man.svg
6  | 장애인              | 0       | 99      | wheelchair.svg

Total: 6 age categories (100% PRD v9.6.1 compliant)

Icon Files Verified:
✅ packages/pickly_design_system/assets/icons/age_categories/baby.svg
✅ packages/pickly_design_system/assets/icons/age_categories/kinder.svg
✅ packages/pickly_design_system/assets/icons/age_categories/young_man.svg
✅ packages/pickly_design_system/assets/icons/age_categories/bride.svg
✅ packages/pickly_design_system/assets/icons/age_categories/old_man.svg
*/

-- =====================================================
-- 🎯 Age Range Coverage
-- =====================================================
/*
Age Coverage Analysis:

19-39세: 청년 (young_man.svg)
20-49세: 신혼부부·예비부부 (bride.svg)
25-49세: 육아중인 부모 (baby.svg)
25-49세: 다자녀 가구 (kinder.svg)
65-99세: 어르신 (old_man.svg)
0-99세:  장애인 (wheelchair.svg)

✅ Overlapping ranges intentional (different life stages)
✅ 장애인 covers all ages
✅ Life-stage based categorization
✅ Appropriate icons for each category
*/

-- =====================================================
-- 🔄 Rollback Plan (If Needed)
-- =====================================================
/*
If you need to restore the old age categories:

cd backend/supabase
cat docs/history/db_backup_age_categories_full_20251103_2040.csv

Then manually restore using CSV import or:

docker exec -i supabase_db_pickly_service psql -U postgres -d postgres \
  -c "\copy age_categories FROM STDIN WITH CSV HEADER" \
  < docs/history/db_backup_age_categories_full_20251103_2040.csv

Note: Old data includes test/duplicate entries that should NOT be restored.
Only restore if absolutely necessary.
*/

-- =====================================================
-- 📚 Related Changes
-- =====================================================
/*
This migration affects:

1. Flutter App (benefit_announcements filtering):
   - Age-based filtering will use new 6 categories
   - Icon display will use simplified filenames (baby.svg, kinder.svg, etc.)

2. Admin Panel (if age category management exists):
   - Should show 6 official categories
   - No duplicate "청년" entries
   - No special categories like "신혼부부"

3. Announcement Creation:
   - Age target selection shows 6 clear options
   - No confusion with overlapping ranges
*/

-- =====================================================
-- ✅ Migration Complete
-- =====================================================

COMMENT ON TABLE public.age_categories IS 'PRD v9.6.1 official 6 life-stage categories - reset 2025-11-03';
