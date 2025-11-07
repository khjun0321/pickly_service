-- Migration: PRD v8.1 Synchronization
-- Description: Sync announcements table with PRD v8.1 specifications
-- Date: 2025-10-30
-- Version: v8.1

-- ================================================================
-- 1. Add missing columns to announcements table
-- ================================================================

-- Add deadline_date for D-day calculation
ALTER TABLE announcements
ADD COLUMN IF NOT EXISTS deadline_date DATE;

-- Add content for detailed announcement information
ALTER TABLE announcements
ADD COLUMN IF NOT EXISTS content TEXT;

-- Add region for location filtering
ALTER TABLE announcements
ADD COLUMN IF NOT EXISTS region TEXT;

-- Add application dates
ALTER TABLE announcements
ADD COLUMN IF NOT EXISTS application_start_date TIMESTAMP WITH TIME ZONE;

ALTER TABLE announcements
ADD COLUMN IF NOT EXISTS application_end_date TIMESTAMP WITH TIME ZONE;

-- ================================================================
-- 2. Add CHECK constraints
-- ================================================================

-- Drop existing constraints if they exist
ALTER TABLE announcements
DROP CONSTRAINT IF EXISTS check_deadline_date;

ALTER TABLE announcements
DROP CONSTRAINT IF EXISTS check_display_priority;

ALTER TABLE announcements
DROP CONSTRAINT IF EXISTS check_views_count;

-- Add new constraints
ALTER TABLE announcements
ADD CONSTRAINT check_deadline_date
CHECK (deadline_date IS NULL OR (application_end_date IS NOT NULL AND deadline_date >= application_end_date::date));

ALTER TABLE announcements
ADD CONSTRAINT check_display_priority
CHECK (display_priority >= 0);

ALTER TABLE announcements
ADD CONSTRAINT check_views_count
CHECK (views_count >= 0);

-- Update status check constraint to include 'upcoming'
ALTER TABLE announcements
DROP CONSTRAINT IF EXISTS announcements_status_check;

ALTER TABLE announcements
ADD CONSTRAINT announcements_status_check
CHECK (status IN ('recruiting', 'closed', 'upcoming', 'draft'));

-- ================================================================
-- 3. Create indexes for performance optimization
-- ================================================================

-- Region-based search optimization
CREATE INDEX IF NOT EXISTS idx_announcements_region
ON announcements(region);

-- Deadline-based sorting optimization
CREATE INDEX IF NOT EXISTS idx_announcements_deadline
ON announcements(deadline_date) WHERE deadline_date IS NOT NULL;

-- Home screen display optimization (composite index)
CREATE INDEX IF NOT EXISTS idx_announcements_home_display
ON announcements(is_home_visible, display_priority) WHERE is_home_visible = true;

-- View count sorting optimization
CREATE INDEX IF NOT EXISTS idx_announcements_views
ON announcements(views_count DESC);

-- Created at sorting optimization
CREATE INDEX IF NOT EXISTS idx_announcements_created_at
ON announcements(created_at DESC);

-- ================================================================
-- 4. Update search_vector trigger function
-- ================================================================

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS update_announcements_search_vector ON announcements;

-- Create/Replace trigger function for search_vector
CREATE OR REPLACE FUNCTION update_announcements_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('pg_catalog.simple', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('pg_catalog.simple', COALESCE(NEW.content, '')), 'B') ||
        setweight(to_tsvector('pg_catalog.simple', COALESCE(NEW.subtitle, '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER update_announcements_search_vector
BEFORE INSERT OR UPDATE OF title, content, subtitle
ON announcements
FOR EACH ROW
EXECUTE FUNCTION update_announcements_search_vector();

-- ================================================================
-- 5. Backfill search_vector for existing records
-- ================================================================

-- Update search_vector for all existing records
UPDATE announcements
SET search_vector =
    setweight(to_tsvector('pg_catalog.simple', COALESCE(title, '')), 'A') ||
    setweight(to_tsvector('pg_catalog.simple', COALESCE(content, '')), 'B') ||
    setweight(to_tsvector('pg_catalog.simple', COALESCE(subtitle, '')), 'C');

-- ================================================================
-- 6. Update benefit_categories with v8.1 fields
-- ================================================================

-- Add slug column if not exists
ALTER TABLE benefit_categories
ADD COLUMN IF NOT EXISTS slug TEXT;

-- Add description column if not exists
ALTER TABLE benefit_categories
ADD COLUMN IF NOT EXISTS description TEXT;

-- Add icon_name column if not exists
ALTER TABLE benefit_categories
ADD COLUMN IF NOT EXISTS icon_name TEXT;

-- Generate slug from title for existing categories
UPDATE benefit_categories
SET slug = LOWER(REGEXP_REPLACE(title, '[^a-zA-Z0-9가-힣]+', '-', 'g'))
WHERE slug IS NULL;

-- Add unique constraint to slug
ALTER TABLE benefit_categories
DROP CONSTRAINT IF EXISTS unique_category_slug;

ALTER TABLE benefit_categories
ADD CONSTRAINT unique_category_slug UNIQUE (slug);

-- ================================================================
-- 7. Update category_banners with v8.1 fields
-- ================================================================

-- Add background_color column if not exists
ALTER TABLE category_banners
ADD COLUMN IF NOT EXISTS background_color TEXT DEFAULT '#FFFFFF';

-- Rename benefit_category_id to category_id (if needed)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'category_banners'
        AND column_name = 'benefit_category_id'
    ) THEN
        -- Drop existing FK constraint
        ALTER TABLE category_banners
        DROP CONSTRAINT IF EXISTS category_banners_benefit_category_id_fkey;

        -- Rename column
        ALTER TABLE category_banners
        RENAME COLUMN benefit_category_id TO category_id;

        -- Recreate FK constraint
        ALTER TABLE category_banners
        ADD CONSTRAINT category_banners_category_id_fkey
        FOREIGN KEY (category_id)
        REFERENCES benefit_categories(id)
        ON DELETE CASCADE;
    END IF;
END $$;

-- Rename sort_order to display_order (if needed)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'category_banners'
        AND column_name = 'sort_order'
    ) THEN
        ALTER TABLE category_banners
        RENAME COLUMN sort_order TO display_order;
    END IF;
END $$;

-- Rename link_target to link_url (if needed)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'category_banners'
        AND column_name = 'link_target'
    ) THEN
        ALTER TABLE category_banners
        RENAME COLUMN link_target TO link_url;
    END IF;
END $$;

-- ================================================================
-- 8. Add comments for documentation
-- ================================================================

COMMENT ON COLUMN announcements.deadline_date IS 'D-day calculation date - PRD v8.1';
COMMENT ON COLUMN announcements.content IS 'Detailed announcement content - PRD v8.1';
COMMENT ON COLUMN announcements.region IS 'Geographic region (서울/경기/etc.) - PRD v8.1';
COMMENT ON COLUMN announcements.application_start_date IS 'Application period start - PRD v8.1';
COMMENT ON COLUMN announcements.application_end_date IS 'Application period end - PRD v8.1';
COMMENT ON COLUMN announcements.is_home_visible IS 'Display on home screen - PRD v8.1';
COMMENT ON COLUMN announcements.display_priority IS 'Home screen display order - PRD v8.1';
COMMENT ON COLUMN announcements.views_count IS 'View count tracking - PRD v8.1';
COMMENT ON COLUMN announcements.tags IS 'Tags for categorization - PRD v8.1';
COMMENT ON COLUMN announcements.search_vector IS 'Full-text search vector - PRD v8.1';

COMMENT ON COLUMN benefit_categories.slug IS 'URL-friendly identifier - PRD v8.1';
COMMENT ON COLUMN benefit_categories.description IS 'Category description - PRD v8.1';
COMMENT ON COLUMN benefit_categories.icon_name IS 'Icon identifier - PRD v8.1';

COMMENT ON COLUMN category_banners.background_color IS 'Banner background color (hex) - PRD v8.1';

-- ================================================================
-- Migration complete
-- ================================================================

-- Log migration success
DO $$
BEGIN
    RAISE NOTICE '✅ PRD v8.1 migration completed successfully';
    RAISE NOTICE '📊 Updated tables: announcements, benefit_categories, category_banners';
    RAISE NOTICE '🔍 Added full-text search with search_vector trigger';
    RAISE NOTICE '📅 Added deadline_date for D-day calculations';
    RAISE NOTICE '📝 Added content field for detailed information';
    RAISE NOTICE '🌍 Added region field for location filtering';
    RAISE NOTICE '📆 Added application date range fields';
    RAISE NOTICE '🏷️  Enhanced tags system';
    RAISE NOTICE '👁️  Enhanced views_count tracking';
    RAISE NOTICE '🏠 Enhanced home screen visibility controls';
END $$;
