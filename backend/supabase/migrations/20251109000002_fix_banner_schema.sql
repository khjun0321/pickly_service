-- =========================================================
-- Migration: 20251109000002_fix_banner_schema.sql
-- Purpose: Fix category_banners schema (benefit_category_id → category_slug)
-- PRD: v9.9.4 - Banner Schema Fix
-- =========================================================

-- 1️⃣ Check if table exists, if not skip
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name = 'category_banners'
  ) THEN

    -- 2️⃣ Add category_slug column if it doesn't exist
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
      AND table_name = 'category_banners'
      AND column_name = 'category_slug'
    ) THEN
      ALTER TABLE public.category_banners
      ADD COLUMN category_slug TEXT;
    END IF;

    -- 3️⃣ Migrate data from benefit_category_id to category_slug (if benefit_category_id exists)
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
      AND table_name = 'category_banners'
      AND column_name = 'benefit_category_id'
    ) THEN
      -- Map category IDs to slugs
      UPDATE public.category_banners cb
      SET category_slug = bc.slug
      FROM public.benefit_categories bc
      WHERE cb.benefit_category_id = bc.id
        AND cb.category_slug IS NULL;

      -- 4️⃣ Drop old column
      ALTER TABLE public.category_banners
      DROP COLUMN IF EXISTS benefit_category_id;
    END IF;

    -- 5️⃣ Add index on category_slug for performance
    CREATE INDEX IF NOT EXISTS idx_category_banners_slug
    ON public.category_banners(category_slug);

  END IF;
END $$;

-- Verification
SELECT 'category_banners schema updated successfully' AS status;
