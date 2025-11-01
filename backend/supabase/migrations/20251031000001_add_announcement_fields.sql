-- ============================================
-- Add missing fields to announcements table
-- Date: 2025-10-31
-- Purpose: Support Admin UI filtering and D-Day calculation
-- Reference: /docs/development/admin_material_missing_fields.md
-- ============================================

-- 1. Add region field for filtering
ALTER TABLE announcements
ADD COLUMN IF NOT EXISTS region varchar(50);

COMMENT ON COLUMN announcements.region IS '지역 (서울, 경기, 인천, 부산, 대구, 광주, 대전, 울산, 세종, 전국 등)';

-- 2. Add application date fields for D-Day calculation
ALTER TABLE announcements
ADD COLUMN IF NOT EXISTS application_start_date timestamp with time zone,
ADD COLUMN IF NOT EXISTS application_end_date timestamp with time zone;

COMMENT ON COLUMN announcements.application_start_date IS '신청 시작일';
COMMENT ON COLUMN announcements.application_end_date IS '신청 마감일 (D-Day 계산 기준)';

-- 3. Rename views_count to view_count (for consistency with Admin UI)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'announcements'
    AND column_name = 'views_count'
  ) THEN
    ALTER TABLE announcements RENAME COLUMN views_count TO view_count;
  END IF;
END $$;

COMMENT ON COLUMN announcements.view_count IS '조회수 (Admin UI에서 인기순 정렬에 사용)';

-- 4. Update status check constraint to include 'upcoming'
ALTER TABLE announcements DROP CONSTRAINT IF EXISTS announcements_status_check;
ALTER TABLE announcements
ADD CONSTRAINT announcements_status_check
CHECK (status IN ('recruiting', 'closed', 'draft', 'upcoming'));

COMMENT ON CONSTRAINT announcements_status_check ON announcements IS
  '상태: recruiting(모집중), closed(마감), draft(임시저장), upcoming(예정)';

-- 5. Add index for filtering by region
CREATE INDEX IF NOT EXISTS idx_announcements_region
ON announcements(region)
WHERE region IS NOT NULL;

-- 6. Add index for sorting by application_end_date (D-Day calculation)
CREATE INDEX IF NOT EXISTS idx_announcements_deadline
ON announcements(application_end_date)
WHERE application_end_date IS NOT NULL;

-- 7. Add index for sorting by view_count (popularity)
CREATE INDEX IF NOT EXISTS idx_announcements_view_count
ON announcements(view_count DESC)
WHERE view_count > 0;

-- ============================================
-- Optional: Set default values for existing data
-- ============================================

-- Uncomment if you want to set default values for existing announcements
/*
UPDATE announcements
SET
  region = '전국',
  application_start_date = COALESCE(application_start_date, created_at),
  application_end_date = COALESCE(application_end_date, created_at + interval '30 days')
WHERE region IS NULL OR application_start_date IS NULL OR application_end_date IS NULL;
*/

-- ============================================
-- Migration complete!
-- ============================================

COMMENT ON TABLE announcements IS 'Pickly 혜택 공고 - v8.5 (지역 필터, D-Day 계산 지원)';
