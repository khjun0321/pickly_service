-- Age Categories Seed Data (v8.1 - Stable Version)
--
-- This file contains the definitive 6 age categories for Pickly.
-- These represent the target user groups for benefit filtering.
--
-- Categories:
-- 1. 청년 (Young adults: 19-39)
-- 2. 신혼부부·예비부부 (Newlyweds and couples planning marriage)
-- 3. 육아중인 부모 (Parents raising children)
-- 4. 다자녀 가구 (Multi-child families: 2+ children)
-- 5. 어르신 (Seniors: 65+)
-- 6. 장애인 (People with disabilities)

-- Clear existing data to prevent conflicts
TRUNCATE TABLE age_categories CASCADE;

-- Insert the 6 standard age categories
INSERT INTO age_categories (
  title,
  description,
  icon_component,
  icon_url,
  min_age,
  max_age,
  sort_order,
  is_active
) VALUES
  (
    '청년',
    '(만 19세-39세) 대학생, 취업준비생, 직장인',
    'bride',
    'packages/pickly_design_system/assets/icons/age_categories/bride.svg',
    19,
    39,
    1,
    true
  ),
  (
    '신혼부부·예비부부',
    '결혼 예정 또는 결혼 7년이내',
    'young_man',
    'packages/pickly_design_system/assets/icons/age_categories/young_man.svg',
    NULL,
    NULL,
    2,
    true
  ),
  (
    '육아중인 부모',
    '영유아~초등 자녀 양육 중',
    'baby',
    'packages/pickly_design_system/assets/icons/age_categories/baby.svg',
    NULL,
    NULL,
    3,
    true
  ),
  (
    '다자녀 가구',
    '자녀 2명 이상 양육중',
    'kinder',
    'packages/pickly_design_system/assets/icons/age_categories/kinder.svg',
    NULL,
    NULL,
    4,
    true
  ),
  (
    '어르신',
    '만 65세 이상',
    'old_man',
    'packages/pickly_design_system/assets/icons/age_categories/old_man.svg',
    65,
    NULL,
    5,
    true
  ),
  (
    '장애인',
    '장애인 등록 대상',
    'wheel_chair',
    'packages/pickly_design_system/assets/icons/age_categories/wheel_chair.svg',
    NULL,
    NULL,
    6,
    true
  )
ON CONFLICT (title) DO UPDATE SET
  description = EXCLUDED.description,
  icon_component = EXCLUDED.icon_component,
  icon_url = EXCLUDED.icon_url,
  min_age = EXCLUDED.min_age,
  max_age = EXCLUDED.max_age,
  sort_order = EXCLUDED.sort_order,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

-- Verify insertion
DO $$
DECLARE
  category_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO category_count FROM age_categories WHERE is_active = true;

  IF category_count = 6 THEN
    RAISE NOTICE '✅ Age categories seeded successfully: 6 categories';
  ELSE
    RAISE WARNING '⚠️  Expected 6 age categories but found %', category_count;
  END IF;
END $$;
