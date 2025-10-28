-- Benefit Categories Seed Data (v8.1 - Stable Version)
--
-- This file contains the 9 main benefit categories for Pickly.
-- Categories are displayed in the mobile app's benefits screen.
--
-- Categories (in order):
-- 0. 인기 (Popular - curated benefits)
-- 1. 주거 (Housing)
-- 2. 교육 (Education)
-- 3. 건강 (Health)
-- 4. 교통 (Transportation)
-- 5. 복지 (Welfare)
-- 6. 취업 (Employment)
-- 7. 지원 (Support/Subsidies)
-- 8. 문화 (Culture)

-- Insert benefit categories with proper slug-based conflict resolution
INSERT INTO benefit_categories (
  title,
  slug,
  description,
  icon_url,
  sort_order,
  is_active,
  parent_id
) VALUES
  ('인기', 'popular', '가장 인기있는 혜택 모음', NULL, 0, true, NULL),
  ('주거', 'housing', '주거 관련 혜택 및 지원', NULL, 1, true, NULL),
  ('교육', 'education', '교육 관련 혜택 및 지원', NULL, 2, true, NULL),
  ('건강', 'health', '건강 관련 혜택 및 지원', NULL, 3, true, NULL),
  ('교통', 'transportation', '교통비 지원 및 할인', NULL, 4, true, NULL),
  ('복지', 'welfare', '복지 관련 혜택 및 지원', NULL, 5, true, NULL),
  ('취업', 'employment', '취업 관련 혜택 및 지원', NULL, 6, true, NULL),
  ('지원', 'support', '각종 지원금 및 보조금', NULL, 7, true, NULL),
  ('문화', 'culture', '문화 관련 혜택 및 지원', NULL, 8, true, NULL)
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  sort_order = EXCLUDED.sort_order,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

-- Verify insertion
DO $$
DECLARE
  category_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO category_count FROM benefit_categories WHERE is_active = true;

  IF category_count >= 9 THEN
    RAISE NOTICE '✅ Benefit categories seeded successfully: % categories', category_count;
  ELSE
    RAISE WARNING '⚠️  Expected at least 9 benefit categories but found %', category_count;
  END IF;
END $$;
