-- Pickly Seed Data: Benefit Categories
-- Purpose: Populate benefit_categories table with official 9 categories
-- PRD: v9.9.7 Seed Automation
-- Date: 2025-11-07
--
-- Usage:
--   psql -U postgres -d postgres -f 02_benefit_categories.sql
--   OR via docker: docker exec supabase_db_supabase psql -U postgres -d postgres -f /docker-entrypoint-initdb.d/seed/02_benefit_categories.sql

-- ============================================================
-- IDEMPOTENT INSERT: Use existing UUIDs to prevent duplicates
-- ============================================================

INSERT INTO public.benefit_categories (
  id,
  title,
  slug,
  description,
  icon_url,
  icon_name,
  sort_order,
  is_active,
  created_at,
  updated_at
) VALUES
  -- 1. 인기 (Popular)
  (
    'acda5f72-8f5f-4efd-9311-9f7b7fe8ca0d',
    '인기',
    'popular',
    '가장 많이 조회된 혜택',
    'popular.svg',
    NULL,
    1,
    true,
    NOW(),
    NOW()
  ),
  -- 2. 주거 (Housing)
  (
    '25829394-bfe3-43d9-a2c0-d7ee6c3d81bc',
    '주거',
    'housing',
    '주택, 전세, 월세 관련 지원',
    'housing.svg',
    NULL,
    2,
    true,
    NOW(),
    NOW()
  ),
  -- 3. 교육 (Education)
  (
    '8fe9c6e0-d479-4249-80ad-da259e1d7102',
    '교육',
    'education',
    '학비, 장학금, 교육비 지원',
    'education.svg',
    NULL,
    3,
    true,
    NOW(),
    NOW()
  ),
  -- 4. 건강 (Health)
  (
    '2c2ecd65-8cdd-4885-bcbd-47cc5f185498',
    '건강',
    'health',
    '의료비, 건강검진, 치료 지원',
    'health.svg',
    NULL,
    4,
    true,
    NOW(),
    NOW()
  ),
  -- 5. 교통 (Transportation)
  (
    '8a3dd17e-13ae-4abf-beea-f8956b86a1bd',
    '교통',
    'transportation',
    '대중교통, 차량 구매 지원',
    'transportation.svg',
    NULL,
    5,
    true,
    NOW(),
    NOW()
  ),
  -- 6. 복지 (Welfare)
  (
    'dc0d8105-8c90-4022-82d6-2b19c2d5104a',
    '복지',
    'welfare',
    '기초생활, 긴급지원, 복지서비스',
    'welfare.svg',
    NULL,
    6,
    true,
    NOW(),
    NOW()
  ),
  -- 7. 취업 (Employment)
  (
    'c3138a81-c168-47b9-ba3e-0808b1c7eece',
    '취업',
    'employment',
    '구직활동, 직업훈련, 취업지원',
    'employment.svg',
    NULL,
    7,
    true,
    NOW(),
    NOW()
  ),
  -- 8. 지원 (Support)
  (
    '71908337-a2bd-41a8-b34d-fb823402ce6b',
    '지원',
    'support',
    '생활지원, 돌봄서비스, 기타 혜택',
    'support.svg',
    NULL,
    8,
    true,
    NOW(),
    NOW()
  ),
  -- 9. 문화 (Culture)
  (
    '3ae25143-47df-4c89-9927-3bbbf5d0694e',
    '문화',
    'culture',
    '문화생활, 체육, 여가활동 지원',
    'culture.svg',
    NULL,
    9,
    true,
    NOW(),
    NOW()
  )
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  slug = EXCLUDED.slug,
  description = EXCLUDED.description,
  icon_url = EXCLUDED.icon_url,
  icon_name = EXCLUDED.icon_name,
  sort_order = EXCLUDED.sort_order,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

-- ============================================================
-- Clean up test data (if exists)
-- ============================================================
DELETE FROM public.benefit_categories
WHERE slug = 'test' OR title = 'test';

-- ============================================================
-- Verification Query
-- ============================================================
SELECT
  '✅ Benefit Categories Seed Complete' as status,
  COUNT(*) as total_count,
  COUNT(*) FILTER (WHERE is_active = true) as active_count
FROM public.benefit_categories;

SELECT id, title, slug, icon_url, sort_order, is_active
FROM public.benefit_categories
WHERE is_active = true
ORDER BY sort_order;
