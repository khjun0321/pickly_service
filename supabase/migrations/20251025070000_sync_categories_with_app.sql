-- Sync benefit categories with mobile app
-- App order: 인기, 주거, 교육, 지원, 교통, 복지, 취업, 건강, 문화

-- Add missing top-level categories
INSERT INTO benefit_categories (name, slug, description, icon_url, display_order, is_active, parent_id) VALUES
('인기', 'popular', '가장 인기있는 혜택 모음', NULL, 0, true, NULL),
('지원', 'support', '각종 지원금 및 보조금', NULL, 4, true, NULL),
('교통', 'transportation', '교통비 지원 및 할인', NULL, 5, true, NULL)
ON CONFLICT (slug) DO NOTHING;

-- Update display_order to match app sequence
-- 인기(0), 주거(1), 교육(2), 지원(3), 교통(4), 복지(5), 취업(6), 건강(7), 문화(8)
UPDATE benefit_categories SET display_order = 0 WHERE slug = 'popular' AND parent_id IS NULL;
UPDATE benefit_categories SET display_order = 1 WHERE slug = 'housing' AND parent_id IS NULL;
UPDATE benefit_categories SET display_order = 2 WHERE slug = 'education' AND parent_id IS NULL;
UPDATE benefit_categories SET display_order = 3 WHERE slug = 'support' AND parent_id IS NULL;
UPDATE benefit_categories SET display_order = 4 WHERE slug = 'transportation' AND parent_id IS NULL;
UPDATE benefit_categories SET display_order = 5 WHERE slug = 'welfare' AND parent_id IS NULL;
UPDATE benefit_categories SET display_order = 6 WHERE slug = 'employment' AND parent_id IS NULL;
UPDATE benefit_categories SET display_order = 7 WHERE slug = 'health' AND parent_id IS NULL;
UPDATE benefit_categories SET display_order = 8 WHERE slug = 'culture' AND parent_id IS NULL;

-- Verify
SELECT id, name, slug, display_order
FROM benefit_categories
WHERE parent_id IS NULL
ORDER BY display_order;
