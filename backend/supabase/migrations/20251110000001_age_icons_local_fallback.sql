-- Pickly PRD v9.9.6 — Age Icons Local Asset Migration
-- Goal: Fix Invalid SVG Data by using local assets instead of Storage URLs
-- Date: 2025-11-10

-- ============================================================
-- 1. Delete test row (invalid data)
-- ============================================================
DELETE FROM public.age_categories WHERE title = 'test';

-- ============================================================
-- 2. Update icon_component to match CategoryIcon mapping
-- ============================================================
-- CategoryIcon uses lowercase keys: youth, newlywed, baby, parenting, senior, disabled
UPDATE public.age_categories
SET icon_component = CASE
  WHEN title = '청년' THEN 'youth'
  WHEN title = '신혼부부·예비부부' THEN 'newlywed'
  WHEN title = '육아중인 부모' THEN 'baby'
  WHEN title = '다자녀 가구' THEN 'parenting'
  WHEN title = '어르신' THEN 'senior'
  WHEN title = '장애인' THEN 'disabled'
  ELSE icon_component
END;

-- ============================================================
-- 3. Set icon_url to empty string to prioritize local assets
-- ============================================================
-- MediaResolver will use iconComponent for local asset path
-- Empty string prevents Storage URL from taking priority
UPDATE public.age_categories
SET icon_url = ''
WHERE icon_url IS NOT NULL;

-- ============================================================
-- 4. Verify results
-- ============================================================
-- Expected: 6 rows with empty icon_url and lowercase icon_component
SELECT id, title, icon_component, icon_url
FROM public.age_categories
ORDER BY sort_order;

-- ============================================================
-- Expected Output:
-- title              | icon_component | icon_url
-- -------------------+----------------+---------
-- 청년               | youth          |
-- 신혼부부·예비부부  | newlywed       |
-- 육아중인 부모      | baby           |
-- 다자녀 가구        | parenting      |
-- 어르신             | senior         |
-- 장애인             | disabled       |
-- ============================================================
