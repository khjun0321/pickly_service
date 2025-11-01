-- ================================================================
-- Migration: 20251101000003_create_announcement_tabs
-- Description: Create announcement_tabs table for Admin form
-- Purpose: Fix missing table error in AnnouncementTypesPage
-- Date: 2025-11-01
-- ================================================================

-- Create announcement_tabs table
-- ================================

CREATE TABLE IF NOT EXISTS public.announcement_tabs (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  announcement_id uuid NOT NULL REFERENCES public.announcements(id) ON DELETE CASCADE,
  age_category_id uuid REFERENCES public.age_categories(id) ON DELETE SET NULL,
  tab_name text NOT NULL,
  unit_type text,
  supply_count integer,
  floor_plan_image_url text,
  income_conditions jsonb DEFAULT '[]'::jsonb,
  additional_info jsonb DEFAULT '{}'::jsonb,
  display_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Add column comments for documentation
-- ======================================

COMMENT ON TABLE public.announcement_tabs IS 'Announcement type tabs/sections (e.g., age-based housing units)';
COMMENT ON COLUMN public.announcement_tabs.announcement_id IS 'Foreign key to announcements table';
COMMENT ON COLUMN public.announcement_tabs.age_category_id IS 'Optional age category filter (e.g., 청년, 신혼부부)';
COMMENT ON COLUMN public.announcement_tabs.tab_name IS 'Display name for the tab';
COMMENT ON COLUMN public.announcement_tabs.unit_type IS 'Housing unit type (e.g., "전용 59㎡")';
COMMENT ON COLUMN public.announcement_tabs.supply_count IS 'Number of units available';
COMMENT ON COLUMN public.announcement_tabs.floor_plan_image_url IS 'URL to floor plan image';
COMMENT ON COLUMN public.announcement_tabs.income_conditions IS 'JSON array of income requirements';
COMMENT ON COLUMN public.announcement_tabs.additional_info IS 'JSON object with images, PDFs, extra notes';
COMMENT ON COLUMN public.announcement_tabs.display_order IS 'Tab display order (ascending)';

-- Create indexes for performance
-- ================================

CREATE INDEX IF NOT EXISTS idx_announcement_tabs_announcement_id
ON public.announcement_tabs(announcement_id);

CREATE INDEX IF NOT EXISTS idx_announcement_tabs_age_category_id
ON public.announcement_tabs(age_category_id)
WHERE age_category_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_announcement_tabs_display_order
ON public.announcement_tabs(announcement_id, display_order);

-- Enable Row Level Security (RLS)
-- ================================

ALTER TABLE public.announcement_tabs ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- ================================

-- Public read access
CREATE POLICY "Public users can read announcement tabs"
ON public.announcement_tabs
FOR SELECT
USING (true);

-- Authenticated users can manage tabs
CREATE POLICY "Authenticated users can insert announcement tabs"
ON public.announcement_tabs
FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Authenticated users can update announcement tabs"
ON public.announcement_tabs
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Authenticated users can delete announcement tabs"
ON public.announcement_tabs
FOR DELETE
TO authenticated
USING (true);

-- Create trigger for updated_at
-- ================================

CREATE OR REPLACE FUNCTION update_announcement_tabs_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_announcement_tabs_updated_at
BEFORE UPDATE ON public.announcement_tabs
FOR EACH ROW
EXECUTE FUNCTION update_announcement_tabs_updated_at();

-- Success message
-- ================================

DO $$
BEGIN
  RAISE NOTICE '╔════════════════════════════════════════════╗';
  RAISE NOTICE '║  ✅ Migration 20251101000003 Complete      ║';
  RAISE NOTICE '║  📋 Table: announcement_tabs               ║';
  RAISE NOTICE '║  🔗 Foreign Keys: announcements, age_cats  ║';
  RAISE NOTICE '║  🔒 RLS: Enabled with policies             ║';
  RAISE NOTICE '╚════════════════════════════════════════════╝';
END $$;
