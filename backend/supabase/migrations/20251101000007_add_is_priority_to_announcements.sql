-- ================================================================
-- Migration: 20251101000007_add_is_priority_to_announcements
-- Description: Add is_priority column for pinning announcements
-- Purpose: Fix Admin "공고 추가" error - is_priority column missing
-- Date: 2025-11-01
-- ================================================================

-- Add is_priority column
-- ================================

ALTER TABLE public.announcements
ADD COLUMN IF NOT EXISTS is_priority boolean DEFAULT false;

COMMENT ON COLUMN public.announcements.is_priority
IS 'Priority flag for pinning announcements to top of list (우선 표시/상단 고정)';

-- Create index for priority announcements
-- ================================

CREATE INDEX IF NOT EXISTS idx_announcements_is_priority
ON public.announcements(is_priority)
WHERE is_priority = true;

-- Update existing announcements (all set to non-priority by default)
-- ================================

UPDATE public.announcements
SET is_priority = false
WHERE is_priority IS NULL;

-- Set NOT NULL constraint
-- ================================

ALTER TABLE public.announcements
ALTER COLUMN is_priority SET NOT NULL;

-- Verification query
-- ================================

DO $$
DECLARE
  is_priority_exists BOOLEAN;
  total_rows INTEGER;
  priority_rows INTEGER;
BEGIN
  -- Check if column exists
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'announcements'
      AND column_name = 'is_priority'
  ) INTO is_priority_exists;

  SELECT COUNT(*) INTO total_rows FROM public.announcements;
  SELECT COUNT(*) INTO priority_rows FROM public.announcements WHERE is_priority = true;

  -- Report results
  IF is_priority_exists THEN
    RAISE NOTICE '╔═══════════════════════════════════════════════╗';
    RAISE NOTICE '║  ✅ Migration 20251101000007 Complete         ║';
    RAISE NOTICE '║  📋 Table: announcements                      ║';
    RAISE NOTICE '║  ➕ Added: is_priority (BOOLEAN NOT NULL)     ║';
    RAISE NOTICE '║  📌 Default: false                            ║';
    RAISE NOTICE '║  🔧 Total rows: %                             ║', total_rows;
    RAISE NOTICE '║  ⭐ Priority announcements: %                 ║', priority_rows;
    RAISE NOTICE '║  ✅ Admin "우선 표시" toggle enabled          ║';
    RAISE NOTICE '╚═══════════════════════════════════════════════╝';
  ELSE
    RAISE WARNING '⚠️  is_priority column creation failed';
  END IF;
END $$;
