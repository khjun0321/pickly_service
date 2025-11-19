-- Pickly Seed Data: Benefit Subcategories
-- Purpose: Populate benefit_subcategories table with comprehensive filter options
-- PRD: v9.9.8 Benefit Subcategories Expansion
-- Date: 2025-11-08
--
-- Usage:
--   psql -U postgres -d postgres -f 03_benefit_subcategories.sql
--   OR via docker: docker exec supabase_db_supabase psql -U postgres -d postgres -f /docker-entrypoint-initdb.d/seed/03_benefit_subcategories.sql

-- ============================================================
-- IDEMPOTENT INSERT: Use category_id + slug unique constraint
-- ============================================================

-- Category UUIDs (from benefit_categories)
-- popular: acda5f72-8f5f-4efd-9311-9f7b7fe8ca0d
-- housing: 25829394-bfe3-43d9-a2c0-d7ee6c3d81bc
-- education: 8fe9c6e0-d479-4249-80ad-da259e1d7102
-- health: 2c2ecd65-8cdd-4885-bcbd-47cc5f185498
-- transportation: 8a3dd17e-13ae-4abf-beea-f8956b86a1bd
-- welfare: dc0d8105-8c90-4022-82d6-2b19c2d5104a
-- employment: c3138a81-c168-47b9-ba3e-0808b1c7eece
-- support: 71908337-a2bd-41a8-b34d-fb823402ce6b
-- culture: 3ae25143-47df-4c89-9927-3bbbf5d0694e

INSERT INTO public.benefit_subcategories (
  category_id,
  name,
  slug,
  sort_order,
  is_active,
  icon_url,
  icon_name
) VALUES
  -- ============================================================
  -- 주거 (Housing) - 5 subcategories
  -- ============================================================
  ('25829394-bfe3-43d9-a2c0-d7ee6c3d81bc', '행복주택', 'happy-housing', 1, true, NULL, NULL),
  ('25829394-bfe3-43d9-a2c0-d7ee6c3d81bc', '국민임대', 'public-rental', 2, true, NULL, NULL),
  ('25829394-bfe3-43d9-a2c0-d7ee6c3d81bc', '전세임대', 'lease-support', 3, true, NULL, NULL),
  ('25829394-bfe3-43d9-a2c0-d7ee6c3d81bc', '매입임대', 'purchased-rental', 4, true, NULL, NULL),
  ('25829394-bfe3-43d9-a2c0-d7ee6c3d81bc', '장기전세', 'long-term-lease', 5, true, NULL, NULL),

  -- ============================================================
  -- 교육 (Education) - 4 subcategories
  -- ============================================================
  ('8fe9c6e0-d479-4249-80ad-da259e1d7102', '대학 장학금', 'university-scholarship', 1, true, NULL, NULL),
  ('8fe9c6e0-d479-4249-80ad-da259e1d7102', '고등학생 지원', 'highschool-support', 2, true, NULL, NULL),
  ('8fe9c6e0-d479-4249-80ad-da259e1d7102', '유아 교육비', 'childcare-education', 3, true, NULL, NULL),
  ('8fe9c6e0-d479-4249-80ad-da259e1d7102', '학자금 대출', 'student-loan', 4, true, NULL, NULL),

  -- ============================================================
  -- 건강 (Health) - 4 subcategories
  -- ============================================================
  ('2c2ecd65-8cdd-4885-bcbd-47cc5f185498', '건강검진', 'health-checkup', 1, true, NULL, NULL),
  ('2c2ecd65-8cdd-4885-bcbd-47cc5f185498', '의료비 지원', 'medical-expense', 2, true, NULL, NULL),
  ('2c2ecd65-8cdd-4885-bcbd-47cc5f185498', '치과 지원', 'dental-support', 3, true, NULL, NULL),
  ('2c2ecd65-8cdd-4885-bcbd-47cc5f185498', '정신건강 지원', 'mental-health', 4, true, NULL, NULL),

  -- ============================================================
  -- 교통 (Transportation) - 3 subcategories
  -- ============================================================
  ('8a3dd17e-13ae-4abf-beea-f8956b86a1bd', '대중교통 할인', 'public-transport', 1, true, NULL, NULL),
  ('8a3dd17e-13ae-4abf-beea-f8956b86a1bd', '차량 구매 지원', 'vehicle-purchase', 2, true, NULL, NULL),
  ('8a3dd17e-13ae-4abf-beea-f8956b86a1bd', '유류비 지원', 'fuel-support', 3, true, NULL, NULL),

  -- ============================================================
  -- 복지 (Welfare) - 4 subcategories
  -- ============================================================
  ('dc0d8105-8c90-4022-82d6-2b19c2d5104a', '기초생활수급', 'basic-livelihood', 1, true, NULL, NULL),
  ('dc0d8105-8c90-4022-82d6-2b19c2d5104a', '긴급복지지원', 'emergency-welfare', 2, true, NULL, NULL),
  ('dc0d8105-8c90-4022-82d6-2b19c2d5104a', '아동수당', 'child-allowance', 3, true, NULL, NULL),
  ('dc0d8105-8c90-4022-82d6-2b19c2d5104a', '양육수당', 'childcare-allowance', 4, true, NULL, NULL),

  -- ============================================================
  -- 취업 (Employment) - 4 subcategories
  -- ============================================================
  ('c3138a81-c168-47b9-ba3e-0808b1c7eece', '직업훈련', 'job-training', 1, true, NULL, NULL),
  ('c3138a81-c168-47b9-ba3e-0808b1c7eece', '취업성공패키지', 'job-success-package', 2, true, NULL, NULL),
  ('c3138a81-c168-47b9-ba3e-0808b1c7eece', '청년내일채움공제', 'youth-tomorrow-fund', 3, true, NULL, NULL),
  ('c3138a81-c168-47b9-ba3e-0808b1c7eece', '일자리 매칭', 'job-matching', 4, true, NULL, NULL),

  -- ============================================================
  -- 지원 (Support) - 3 subcategories
  -- ============================================================
  ('71908337-a2bd-41a8-b34d-fb823402ce6b', '돌봄서비스', 'care-service', 1, true, NULL, NULL),
  ('71908337-a2bd-41a8-b34d-fb823402ce6b', '생활지원', 'living-support', 2, true, NULL, NULL),
  ('71908337-a2bd-41a8-b34d-fb823402ce6b', '법률지원', 'legal-support', 3, true, NULL, NULL),

  -- ============================================================
  -- 문화 (Culture) - 3 subcategories
  -- ============================================================
  ('3ae25143-47df-4c89-9927-3bbbf5d0694e', '문화누리카드', 'culture-card', 1, true, NULL, NULL),
  ('3ae25143-47df-4c89-9927-3bbbf5d0694e', '체육시설 이용', 'sports-facility', 2, true, NULL, NULL),
  ('3ae25143-47df-4c89-9927-3bbbf5d0694e', '공연/전시 할인', 'performance-exhibition', 3, true, NULL, NULL)

ON CONFLICT (category_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  sort_order = EXCLUDED.sort_order,
  is_active = EXCLUDED.is_active,
  icon_url = EXCLUDED.icon_url,
  icon_name = EXCLUDED.icon_name;

-- ============================================================
-- Clean up test data (if exists)
-- ============================================================
DELETE FROM public.benefit_subcategories
WHERE slug IN ('test', 'all', 'permanent-rental')
   OR name IN ('전체공고', 'test', '영구임대주택');

-- ============================================================
-- Verification Query
-- ============================================================
SELECT
  '✅ Benefit Subcategories Seed Complete' as status,
  COUNT(*) as total_count,
  COUNT(*) FILTER (WHERE is_active = true) as active_count
FROM public.benefit_subcategories;

-- Count by category
SELECT
  bc.title as category,
  COUNT(bs.id) as subcategory_count
FROM public.benefit_categories bc
LEFT JOIN public.benefit_subcategories bs ON bc.id = bs.category_id
WHERE bc.is_active = true
GROUP BY bc.title, bc.sort_order
ORDER BY bc.sort_order;

SELECT
  bc.title as category,
  bs.name as subcategory,
  bs.slug,
  bs.sort_order,
  bs.is_active
FROM public.benefit_subcategories bs
JOIN public.benefit_categories bc ON bs.category_id = bc.id
WHERE bc.is_active = true AND bs.is_active = true
ORDER BY bc.sort_order, bs.sort_order
LIMIT 10;
