-- =====================================================
-- PRD v9.6 Schema Alignment: category_banners
-- =====================================================
-- Date: 2025-11-02
-- Purpose: Align category_banners with PRD v9.6 naming standards
--
-- Changes:
-- 1. Rename display_order -> sort_order (PRD v9.6 Section 6: "정렬 sort_order 모든 리스트 공통")
--
-- Reference: /docs/prd/PRD_v9.6_Pickly_Integrated_System_UPDATED.md
-- =====================================================

-- Step 1: Rename display_order to sort_order
ALTER TABLE category_banners
  RENAME COLUMN display_order TO sort_order;

-- Step 2: Add comment for documentation
COMMENT ON COLUMN category_banners.sort_order IS 'Display order (PRD v9.6 standard: sort_order not display_order)';

-- =====================================================
-- Verification Query
-- =====================================================
-- Run this to verify the migration:
-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_name = 'category_banners'
-- ORDER BY ordinal_position;
