-- Pickly Seed Data: Age Categories
-- Purpose: Populate age_categories table with official 6 categories
-- PRD: v9.9.7 Seed Automation
-- Date: 2025-11-07
--
-- Usage:
--   psql -U postgres -d postgres -f 01_age_categories.sql
--   OR via docker: docker exec supabase_db_supabase psql -U postgres -d postgres -f /docker-entrypoint-initdb.d/seed/01_age_categories.sql

-- ============================================================
-- IDEMPOTENT INSERT: Use existing UUIDs to prevent duplicates
-- ============================================================

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
) VALUES
  -- 1. 청년 (Youth)
  (
    'cd086d67-3b62-4471-8ffb-32943b406cdd',
    '청년',
    '(만 19세-39세) 대학생, 취업준비생, 직장인',
    'youth',
    '',
    19,
    39,
    1,
    true,
    NOW(),
    NOW()
  ),
  -- 2. 신혼부부·예비부부 (Newlywed / Pre-married)
  (
    'bbb0dd08-2370-441c-b258-868f1b267bbd',
    '신혼부부·예비부부',
    '결혼 7년 이내 또는 결혼 예정자',
    'newlywed',
    '',
    NULL,
    NULL,
    2,
    true,
    NOW(),
    NOW()
  ),
  -- 3. 육아중인 부모 (Parents with infants)
  (
    '796618c2-95fc-4e9f-ac5f-14bb25c7bab5',
    '육아중인 부모',
    '만 6세 미만 자녀를 둔 부모',
    'baby',
    '',
    NULL,
    NULL,
    3,
    true,
    NOW(),
    NOW()
  ),
  -- 4. 다자녀 가구 (Multi-child families)
  (
    '51538f62-a170-4b8d-95f8-83a6294dd4f8',
    '다자녀 가구',
    '자녀가 2명 이상인 가구',
    'parenting',
    '',
    NULL,
    NULL,
    4,
    true,
    NOW(),
    NOW()
  ),
  -- 5. 어르신 (Senior citizens)
  (
    '49d602bf-2c5f-486d-bf20-e766170a0514',
    '어르신',
    '(만 65세 이상) 고령자',
    'senior',
    '',
    65,
    NULL,
    5,
    true,
    NOW(),
    NOW()
  ),
  -- 6. 장애인 (Persons with disabilities)
  (
    '8d6472df-a63b-4397-8c9b-35368bf3bda4',
    '장애인',
    '장애인 등록증 소지자',
    'disabled',
    '',
    NULL,
    NULL,
    6,
    true,
    NOW(),
    NOW()
  )
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  icon_component = EXCLUDED.icon_component,
  icon_url = EXCLUDED.icon_url,
  min_age = EXCLUDED.min_age,
  max_age = EXCLUDED.max_age,
  sort_order = EXCLUDED.sort_order,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

-- ============================================================
-- Verification Query
-- ============================================================
SELECT
  '✅ Age Categories Seed Complete' as status,
  COUNT(*) as total_count,
  COUNT(*) FILTER (WHERE is_active = true) as active_count
FROM public.age_categories;

SELECT id, title, icon_component, min_age, max_age, sort_order, is_active
FROM public.age_categories
WHERE is_active = true
ORDER BY sort_order;

-- ============================================================
-- Icon Component Mapping Reference
-- ============================================================
-- youth      → young_man.svg      (청년)
-- newlywed   → bride.svg           (신혼부부·예비부부)
-- baby       → baby.svg            (육아중인 부모)
-- parenting  → family.svg          (다자녀 가구)
-- senior     → old_man.svg         (어르신)
-- disabled   → wheelchair.svg      (장애인)
--
-- These are resolved by CategoryIcon in:
-- packages/pickly_design_system/lib/widgets/images/category_icon.dart
--
-- Local asset path:
-- packages/pickly_design_system/assets/icons/age_categories/{filename}.svg
