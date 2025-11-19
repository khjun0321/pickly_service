-- ================================================================
-- Migration: 20251101000004_create_announcement_unit_types
-- Description: Create announcement_unit_types table for Admin form
-- Purpose: Fix missing table error in announcements API
-- Date: 2025-11-01
-- ================================================================

-- Create announcement_unit_types table
-- ======================================

CREATE TABLE IF NOT EXISTS public.announcement_unit_types (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  announcement_id uuid NOT NULL REFERENCES public.announcements(id) ON DELETE CASCADE,
  unit_type text NOT NULL,                    -- 예: "전용 59㎡", "일반형"
  supply_area numeric(10,2),                   -- 공급면적 (㎡)
  exclusive_area numeric(10,2),               -- 전용면적 (㎡)
  supply_count integer,                        -- 공급 수량
  monthly_rent integer,                        -- 월세 (원)
  deposit integer,                             -- 보증금 (원)
  maintenance_fee integer,                     -- 관리비 (원)
  floor_info text,                             -- 층 정보 (예: "5~15층")
  direction text,                              -- 방향 (예: "남향", "동남향")
  room_structure text,                         -- 방 구조 (예: "3룸", "복층")
  additional_info jsonb DEFAULT '{}'::jsonb,   -- 추가 정보 (JSON)
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Add column comments for documentation
-- ======================================

COMMENT ON TABLE public.announcement_unit_types IS 'Housing unit type details for announcements (LH-style)';
COMMENT ON COLUMN public.announcement_unit_types.announcement_id IS 'Foreign key to announcements table';
COMMENT ON COLUMN public.announcement_unit_types.unit_type IS 'Unit type name (e.g., "전용 59㎡")';
COMMENT ON COLUMN public.announcement_unit_types.supply_area IS 'Total supply area in square meters';
COMMENT ON COLUMN public.announcement_unit_types.exclusive_area IS 'Exclusive area in square meters';
COMMENT ON COLUMN public.announcement_unit_types.supply_count IS 'Number of units available for this type';
COMMENT ON COLUMN public.announcement_unit_types.monthly_rent IS 'Monthly rent in KRW';
COMMENT ON COLUMN public.announcement_unit_types.deposit IS 'Security deposit in KRW';
COMMENT ON COLUMN public.announcement_unit_types.maintenance_fee IS 'Monthly maintenance fee in KRW';
COMMENT ON COLUMN public.announcement_unit_types.floor_info IS 'Floor range (e.g., "5~15층")';
COMMENT ON COLUMN public.announcement_unit_types.direction IS 'Unit direction (e.g., "남향")';
COMMENT ON COLUMN public.announcement_unit_types.room_structure IS 'Room layout (e.g., "3룸", "복층")';
COMMENT ON COLUMN public.announcement_unit_types.additional_info IS 'Extra metadata in JSON format';
COMMENT ON COLUMN public.announcement_unit_types.sort_order IS 'Display order (ascending)';

-- Create indexes for performance
-- ================================

CREATE INDEX IF NOT EXISTS idx_announcement_unit_types_announcement_id
ON public.announcement_unit_types(announcement_id);

CREATE INDEX IF NOT EXISTS idx_announcement_unit_types_sort_order
ON public.announcement_unit_types(announcement_id, sort_order);

-- Enable Row Level Security (RLS)
-- ================================

ALTER TABLE public.announcement_unit_types ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- ================================

-- Public read access
CREATE POLICY "Public users can read unit types"
ON public.announcement_unit_types
FOR SELECT
USING (true);

-- Authenticated users can manage unit types
CREATE POLICY "Authenticated users can insert unit types"
ON public.announcement_unit_types
FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Authenticated users can update unit types"
ON public.announcement_unit_types
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Authenticated users can delete unit types"
ON public.announcement_unit_types
FOR DELETE
TO authenticated
USING (true);

-- Create trigger for updated_at
-- ================================

CREATE OR REPLACE FUNCTION update_announcement_unit_types_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_announcement_unit_types_updated_at
BEFORE UPDATE ON public.announcement_unit_types
FOR EACH ROW
EXECUTE FUNCTION update_announcement_unit_types_updated_at();

-- Success message
-- ================================

DO $$
BEGIN
  RAISE NOTICE '╔════════════════════════════════════════════╗';
  RAISE NOTICE '║  ✅ Migration 20251101000004 Complete      ║';
  RAISE NOTICE '║  📋 Table: announcement_unit_types         ║';
  RAISE NOTICE '║  🏠 Purpose: LH-style unit specifications  ║';
  RAISE NOTICE '║  🔒 RLS: Enabled with policies             ║';
  RAISE NOTICE '╚════════════════════════════════════════════╝';
END $$;
