-- ================================================================
-- Migration: Update benefit categories to match admin design
-- File: 20251024000003_update_benefit_categories.sql
-- Description: Add missing categories and update display order
-- ================================================================

-- Add missing categories (인기, 지원, 교통, 식품)
INSERT INTO benefit_categories (name, slug, description, display_order) VALUES
  ('인기', 'popular', '인기 있는 혜택 모음', 1),
  ('지원', 'support', '생활지원 관련 혜택 (긴급지원, 생계지원 등)', 5),
  ('교통', 'transportation', '교통 관련 혜택 (교통비지원, 대중교통 할인 등)', 6),
  ('식품', 'food', '식품 관련 혜택 (식비지원, 급식지원 등)', 8)
ON CONFLICT (slug) DO NOTHING;

-- Update display_order to match screenshot order:
-- 1. 인기, 2. 주거, 3. 교육, 4. 지원, 5. 교통, 6. 복지, 7. 취업, 8. 식품
UPDATE benefit_categories SET display_order = 1 WHERE slug = 'popular';
UPDATE benefit_categories SET display_order = 2 WHERE slug = 'housing';
UPDATE benefit_categories SET display_order = 3 WHERE slug = 'education';
UPDATE benefit_categories SET display_order = 4 WHERE slug = 'employment';
UPDATE benefit_categories SET display_order = 5 WHERE slug = 'support';
UPDATE benefit_categories SET display_order = 6 WHERE slug = 'transportation';
UPDATE benefit_categories SET display_order = 7 WHERE slug = 'welfare';
UPDATE benefit_categories SET display_order = 8 WHERE slug = 'food';

-- Keep health and culture but set lower priority (in case they're needed)
UPDATE benefit_categories SET display_order = 9 WHERE slug = 'health';
UPDATE benefit_categories SET display_order = 10 WHERE slug = 'culture';

-- Completion log
DO $$
BEGIN
    RAISE NOTICE 'Migration 20251024000003_update_benefit_categories.sql completed successfully';
    RAISE NOTICE 'Added categories: 인기, 지원, 교통, 식품';
    RAISE NOTICE 'Updated display order to match admin design';
END $$;
