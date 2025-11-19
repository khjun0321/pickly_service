-- =====================================================
-- PRD v9.6 Schema Alignment: benefit_subcategories
-- =====================================================
-- Date: 2025-11-02
-- Purpose: Align benefit_subcategories with PRD v9.6 naming standards
--
-- Changes:
-- 1. Rename display_order -> sort_order (PRD v9.6 Section 6: "정렬 sort_order 모든 리스트 공통")
-- 2. Add icon_url field for SVG uploads (PRD v9.6 Section 4.2: "하위분류 SVG 업로드 필드 추가")
--
-- Reference: /docs/prd/PRD_v9.6_Pickly_Integrated_System_UPDATED.md
-- =====================================================

-- Step 1: Rename display_order to sort_order
ALTER TABLE benefit_subcategories
  RENAME COLUMN display_order TO sort_order;

-- Step 2: Add icon_url field for SVG uploads
ALTER TABLE benefit_subcategories
  ADD COLUMN icon_url text;

-- Step 3: Add icon_name field to track uploaded icon filename
ALTER TABLE benefit_subcategories
  ADD COLUMN icon_name text;

-- Step 4: Add comment for documentation
COMMENT ON COLUMN benefit_subcategories.sort_order IS 'Display order (PRD v9.6 standard: sort_order not display_order)';
COMMENT ON COLUMN benefit_subcategories.icon_url IS 'SVG icon URL from Supabase Storage (benefit-icons bucket)';
COMMENT ON COLUMN benefit_subcategories.icon_name IS 'Original filename of uploaded icon';

-- =====================================================
-- Verification Query
-- =====================================================
-- Run this to verify the migration:
-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_name = 'benefit_subcategories'
-- ORDER BY ordinal_position;
