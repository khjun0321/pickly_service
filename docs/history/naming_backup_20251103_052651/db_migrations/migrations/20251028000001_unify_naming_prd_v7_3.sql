-- =============================================
-- 🔄 PRD v7.3 Naming Unification Migration
-- =============================================
-- Date: 2025-10-28
-- Purpose: Align all table columns with PRD v7.3 naming conventions
--
-- Changes:
-- 1. benefit_categories: name → title, display_order → sort_order
-- 2. category_banners: category_id → benefit_category_id, link_url → link_target,
--    display_order → sort_order, + link_type, - start_date, - end_date
-- 3. announcement_types: category_id → benefit_category_id, display_order → sort_order
-- 4. announcements: announcement_type → type_id, image_url → thumbnail_url
-- =============================================

-- Step 1: benefit_categories
ALTER TABLE IF EXISTS benefit_categories
  RENAME COLUMN name TO title;

ALTER TABLE IF EXISTS benefit_categories
  RENAME COLUMN display_order TO sort_order;

-- Step 2: category_banners
ALTER TABLE IF EXISTS category_banners
  RENAME COLUMN category_id TO benefit_category_id;

ALTER TABLE IF EXISTS category_banners
  RENAME COLUMN link_url TO link_target;

ALTER TABLE IF EXISTS category_banners
  RENAME COLUMN display_order TO sort_order;

-- Add link_type column (ENUM: internal, external, none)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_name = 'category_banners' AND column_name = 'link_type') THEN
    ALTER TABLE category_banners
      ADD COLUMN link_type TEXT DEFAULT 'none' CHECK (link_type IN ('internal', 'external', 'none'));
  END IF;
END $$;

-- Drop deprecated columns
ALTER TABLE IF EXISTS category_banners
  DROP COLUMN IF EXISTS start_date,
  DROP COLUMN IF EXISTS end_date;

-- Step 3 & 4: announcements tables
-- NOTE: Skipped for now - announcements table uses legacy structure
-- with category_id/subcategory_id instead of announcement_types + type_id
-- These tables need a full schema restructure, not just column renames.
-- Will be handled in a separate migration when the new announcement system is implemented.

-- =============================================
-- Update Foreign Key constraints
-- =============================================

-- Drop old FK constraints
ALTER TABLE IF EXISTS category_banners
  DROP CONSTRAINT IF EXISTS category_banners_category_id_fkey;

-- Recreate FK constraints with new column names
ALTER TABLE category_banners
  ADD CONSTRAINT category_banners_benefit_category_id_fkey
  FOREIGN KEY (benefit_category_id)
  REFERENCES benefit_categories(id)
  ON DELETE CASCADE;

-- =============================================
-- Update Indexes (if any)
-- =============================================

-- Recreate indexes with new column names
DROP INDEX IF EXISTS idx_category_banners_category_id;
CREATE INDEX IF NOT EXISTS idx_category_banners_benefit_category_id
  ON category_banners(benefit_category_id);

-- =============================================
-- Comments for documentation
-- =============================================

COMMENT ON COLUMN benefit_categories.title IS 'Category name (e.g., 인기, 주거, 교육) - PRD v7.3';
COMMENT ON COLUMN benefit_categories.sort_order IS 'Display order in UI - PRD v7.3';

COMMENT ON COLUMN benefit_categories.title IS 'Category name (e.g., 인기, 주거, 교육) - PRD v7.3';
COMMENT ON COLUMN benefit_categories.sort_order IS 'Display order in UI - PRD v7.3';

COMMENT ON COLUMN category_banners.benefit_category_id IS 'FK to benefit_categories - PRD v7.3';
COMMENT ON COLUMN category_banners.link_target IS 'URL or route when banner is clicked - PRD v7.3';
COMMENT ON COLUMN category_banners.link_type IS 'Type of link: internal, external, or none - PRD v7.3';
COMMENT ON COLUMN category_banners.sort_order IS 'Display order in carousel - PRD v7.3';
