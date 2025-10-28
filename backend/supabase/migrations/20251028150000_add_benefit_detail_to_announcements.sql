-- ============================================
-- Add benefit_detail_id to benefit_announcements
-- PRD v9.0 - Tab-based announcement management
-- ============================================
-- Date: 2025-10-28
-- Purpose: Link announcements to specific benefit details (policies)
--          Enables tab-based filtering by policy (행복주택, 국민임대주택, etc.)
-- ============================================

-- Add benefit_detail_id column (nullable initially for backward compatibility)
ALTER TABLE benefit_announcements
ADD COLUMN IF NOT EXISTS benefit_detail_id uuid REFERENCES benefit_details(id) ON DELETE SET NULL;

-- Create index for efficient filtering
CREATE INDEX IF NOT EXISTS idx_benefit_announcements_detail_id
  ON benefit_announcements(benefit_detail_id);

-- Create composite index for category + detail queries
CREATE INDEX IF NOT EXISTS idx_benefit_announcements_category_detail
  ON benefit_announcements(category_id, benefit_detail_id);

-- Add comment
COMMENT ON COLUMN benefit_announcements.benefit_detail_id IS
  'FK to benefit_details - links announcement to specific policy (e.g., 행복주택, 국민임대주택)';

-- Update existing announcements to link to first detail of their category (optional migration helper)
-- This helps with data consistency but can be skipped if you want to manually assign
DO $$
DECLARE
  category_rec RECORD;
  first_detail_id uuid;
BEGIN
  -- For each category that has announcements
  FOR category_rec IN
    SELECT DISTINCT category_id
    FROM benefit_announcements
    WHERE benefit_detail_id IS NULL
  LOOP
    -- Get first detail for this category
    SELECT id INTO first_detail_id
    FROM benefit_details
    WHERE benefit_category_id = category_rec.category_id
    ORDER BY sort_order ASC
    LIMIT 1;

    -- Update announcements to link to first detail (if exists)
    IF first_detail_id IS NOT NULL THEN
      UPDATE benefit_announcements
      SET benefit_detail_id = first_detail_id
      WHERE category_id = category_rec.category_id
        AND benefit_detail_id IS NULL;

      RAISE NOTICE 'Linked announcements for category % to detail %', category_rec.category_id, first_detail_id;
    END IF;
  END LOOP;
END $$;

-- ============================================
-- Migration Complete
-- ============================================
COMMENT ON TABLE benefit_announcements IS
  'Benefit announcements linked to specific policies via benefit_detail_id (v9.0)';
