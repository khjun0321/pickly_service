-- ================================================================
-- Migration: 20251101000005_add_benefit_category_id_to_announcement_types
-- Description: Add missing benefit_category_id foreign key column
-- Purpose: Fix Admin "공고유형 추가" 400/500 error
-- Date: 2025-11-01
-- ================================================================

-- Add benefit_category_id column
-- ================================

ALTER TABLE public.announcement_types
ADD COLUMN IF NOT EXISTS benefit_category_id uuid;

-- Add foreign key constraint
-- ================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'announcement_types_benefit_category_id_fkey'
      AND table_name = 'announcement_types'
  ) THEN
    ALTER TABLE public.announcement_types
    ADD CONSTRAINT announcement_types_benefit_category_id_fkey
    FOREIGN KEY (benefit_category_id)
    REFERENCES public.benefit_categories(id)
    ON DELETE CASCADE;
  END IF;
END $$;

-- Add comment
-- ================================

COMMENT ON COLUMN public.announcement_types.benefit_category_id
IS 'Foreign key to benefit_categories - announcement types belong to specific categories';

-- Create index for performance
-- ================================

CREATE INDEX IF NOT EXISTS idx_announcement_types_benefit_category_id
ON public.announcement_types(benefit_category_id)
WHERE benefit_category_id IS NOT NULL;

-- Migrate existing seed data
-- ================================

-- Assign to "popular" category if exists
UPDATE public.announcement_types
SET benefit_category_id = (
  SELECT id FROM public.benefit_categories
  WHERE slug = 'popular' AND is_active = true
  LIMIT 1
)
WHERE benefit_category_id IS NULL
  AND EXISTS (SELECT 1 FROM public.benefit_categories WHERE slug = 'popular' AND is_active = true);

-- If "popular" not found, use first active category
UPDATE public.announcement_types
SET benefit_category_id = (
  SELECT id FROM public.benefit_categories
  WHERE is_active = true
  ORDER BY sort_order
  LIMIT 1
)
WHERE benefit_category_id IS NULL
  AND EXISTS (SELECT 1 FROM public.benefit_categories WHERE is_active = true);

-- Set NOT NULL constraint after data migration
-- ================================

DO $$
DECLARE
  null_count INTEGER;
  total_rows INTEGER;
BEGIN
  -- Count NULL values
  SELECT COUNT(*) INTO null_count
  FROM public.announcement_types
  WHERE benefit_category_id IS NULL;

  SELECT COUNT(*) INTO total_rows
  FROM public.announcement_types;

  IF null_count > 0 THEN
    RAISE WARNING '⚠️  Found % of % rows with NULL benefit_category_id', null_count, total_rows;
    RAISE WARNING '⚠️  Skipping NOT NULL constraint. Please assign categories manually.';
  ELSIF total_rows = 0 THEN
    RAISE NOTICE 'ℹ️  No rows in announcement_types. Skipping NOT NULL constraint.';
  ELSE
    -- Safe to add NOT NULL constraint
    ALTER TABLE public.announcement_types
    ALTER COLUMN benefit_category_id SET NOT NULL;

    RAISE NOTICE '✅ benefit_category_id set to NOT NULL (all % rows have values)', total_rows;
  END IF;
END $$;

-- Success message
-- ================================

DO $$
BEGIN
  RAISE NOTICE '╔═══════════════════════════════════════════════╗';
  RAISE NOTICE '║  ✅ Migration 20251101000005 Complete         ║';
  RAISE NOTICE '║  📋 Table: announcement_types                 ║';
  RAISE NOTICE '║  ➕ Added Column: benefit_category_id         ║';
  RAISE NOTICE '║  🔗 Foreign Key: → benefit_categories(id)     ║';
  RAISE NOTICE '║  📊 Index: idx_announcement_types_category    ║';
  RAISE NOTICE '║  🔧 Fixed: Admin "공고유형 추가" error        ║';
  RAISE NOTICE '╚═══════════════════════════════════════════════╝';
END $$;
