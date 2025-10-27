-- ================================================================
-- Migration: Update benefit_banners schema to match Flutter app model
-- File: 20251024000007_update_benefit_banners_schema.sql
-- Description: Add subtitle, background_color fields for Flutter integration
-- ================================================================

-- Add missing fields to benefit_banners table
ALTER TABLE benefit_banners
ADD COLUMN IF NOT EXISTS subtitle TEXT,
ADD COLUMN IF NOT EXISTS background_color VARCHAR(9) DEFAULT '#E3F2FD';

-- Update existing banners to have default subtitle and background color
UPDATE benefit_banners
SET subtitle = '지금 바로 확인하세요'
WHERE subtitle IS NULL;

-- Add comments
COMMENT ON COLUMN benefit_banners.subtitle IS '배너 부제목/설명 텍스트';
COMMENT ON COLUMN benefit_banners.background_color IS '배너 배경색 (hex format: #RRGGBB 또는 #AARRGGBB)';

-- Completion log
DO $$
BEGIN
    RAISE NOTICE 'Migration 20251024000007_update_benefit_banners_schema.sql completed successfully';
    RAISE NOTICE 'Added subtitle and background_color columns to benefit_banners table';
    RAISE NOTICE 'Schema now matches Flutter CategoryBanner model';
END $$;
