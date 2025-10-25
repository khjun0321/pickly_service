-- Reorder benefit categories to match user's requested order
-- New order: 인기, 주거, 교육, 건강, 교통, 복지, 취업, 지원, 문화

UPDATE benefit_categories SET display_order = 0 WHERE slug = 'popular' AND parent_id IS NULL;
UPDATE benefit_categories SET display_order = 1 WHERE slug = 'housing' AND parent_id IS NULL;
UPDATE benefit_categories SET display_order = 2 WHERE slug = 'education' AND parent_id IS NULL;
UPDATE benefit_categories SET display_order = 3 WHERE slug = 'health' AND parent_id IS NULL;
UPDATE benefit_categories SET display_order = 4 WHERE slug = 'transportation' AND parent_id IS NULL;
UPDATE benefit_categories SET display_order = 5 WHERE slug = 'welfare' AND parent_id IS NULL;
UPDATE benefit_categories SET display_order = 6 WHERE slug = 'employment' AND parent_id IS NULL;
UPDATE benefit_categories SET display_order = 7 WHERE slug = 'support' AND parent_id IS NULL;
UPDATE benefit_categories SET display_order = 8 WHERE slug = 'culture' AND parent_id IS NULL;

-- Verify
SELECT display_order, name, slug
FROM benefit_categories
WHERE parent_id IS NULL
ORDER BY display_order;
