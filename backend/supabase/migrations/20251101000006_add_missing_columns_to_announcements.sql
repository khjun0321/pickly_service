-- ================================================================
-- Migration: 20251101000006_add_missing_columns_to_announcements
-- Description: Add missing columns to announcements table for Admin
-- Purpose: Fix "공고 추가" 500 error - detail_url and link_type missing
-- Date: 2025-11-01
-- ================================================================

-- Add detail_url column
-- ================================

ALTER TABLE public.announcements
ADD COLUMN IF NOT EXISTS detail_url text;

COMMENT ON COLUMN public.announcements.detail_url
IS 'External detail page URL for the announcement';

-- Add link_type column
-- ================================

ALTER TABLE public.announcements
ADD COLUMN IF NOT EXISTS link_type text DEFAULT 'none';

COMMENT ON COLUMN public.announcements.link_type
IS 'Link type: internal, external, or none';

-- Add check constraint for link_type
-- ================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.constraint_column_usage
    WHERE constraint_name = 'announcements_link_type_check'
      AND table_name = 'announcements'
  ) THEN
    ALTER TABLE public.announcements
    ADD CONSTRAINT announcements_link_type_check
    CHECK (link_type IN ('internal', 'external', 'none'));
  END IF;
END $$;

-- Create indexes for new columns
-- ================================

CREATE INDEX IF NOT EXISTS idx_announcements_link_type
ON public.announcements(link_type)
WHERE link_type != 'none';

-- Update existing rows (set default link_type)
-- ================================

UPDATE public.announcements
SET link_type = CASE
  WHEN external_url IS NOT NULL AND external_url != '' THEN 'external'
  ELSE 'none'
END
WHERE link_type IS NULL OR link_type = '';

-- Verification query
-- ================================

DO $$
DECLARE
  detail_url_exists BOOLEAN;
  link_type_exists BOOLEAN;
  total_rows INTEGER;
BEGIN
  -- Check if columns exist
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'announcements'
      AND column_name = 'detail_url'
  ) INTO detail_url_exists;

  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'announcements'
      AND column_name = 'link_type'
  ) INTO link_type_exists;

  SELECT COUNT(*) INTO total_rows FROM public.announcements;

  -- Report results
  IF detail_url_exists AND link_type_exists THEN
    RAISE NOTICE '╔═══════════════════════════════════════════════╗';
    RAISE NOTICE '║  ✅ Migration 20251101000006 Complete         ║';
    RAISE NOTICE '║  📋 Table: announcements                      ║';
    RAISE NOTICE '║  ➕ Added: detail_url (TEXT NULL)             ║';
    RAISE NOTICE '║  ➕ Added: link_type (TEXT DEFAULT ''none'')  ║';
    RAISE NOTICE '║  🔧 Updated: % existing rows                  ║', total_rows;
    RAISE NOTICE '║  ✅ Admin "공고 추가" error fixed             ║';
    RAISE NOTICE '╚═══════════════════════════════════════════════╝';
  ELSE
    RAISE WARNING '⚠️  Column creation may have failed:';
    IF NOT detail_url_exists THEN
      RAISE WARNING '   - detail_url column not found';
    END IF;
    IF NOT link_type_exists THEN
      RAISE WARNING '   - link_type column not found';
    END IF;
  END IF;
END $$;
