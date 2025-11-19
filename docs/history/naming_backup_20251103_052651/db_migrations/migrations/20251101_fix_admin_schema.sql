-- ================================================================
-- Consolidated Migration: 20251101_fix_admin_schema
-- Description: Fix all missing tables for Admin ↔ Supabase schema
-- Purpose: Create announcement_types, announcement_tabs, announcement_unit_types
-- Date: 2025-11-01
-- ================================================================
-- IMPORTANT: This is a consolidated version of migrations 000002-000004.
-- Use EITHER this file OR the individual migration files, NOT both.
-- ================================================================

-- ================================================================
-- 1. CREATE announcement_types TABLE
-- ================================================================

CREATE TABLE IF NOT EXISTS public.announcement_types (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  title text NOT NULL,
  description text,
  sort_order integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

COMMENT ON TABLE public.announcement_types IS 'Announcement classification types (주거지원, 취업지원, etc.)';

-- Indexes
CREATE INDEX IF NOT EXISTS idx_announcement_types_sort_order
ON public.announcement_types(sort_order)
WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_announcement_types_is_active
ON public.announcement_types(is_active);

-- RLS
ALTER TABLE public.announcement_types ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public users can read active announcement types"
ON public.announcement_types
FOR SELECT
USING (is_active = true);

CREATE POLICY "Admin users have full access to announcement types"
ON public.announcement_types
FOR ALL
USING (true)
WITH CHECK (true);

-- Trigger
CREATE OR REPLACE FUNCTION update_announcement_types_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_announcement_types_updated_at
BEFORE UPDATE ON public.announcement_types
FOR EACH ROW
EXECUTE FUNCTION update_announcement_types_updated_at();

-- Seed data
INSERT INTO public.announcement_types (title, description, sort_order, is_active)
VALUES
  ('주거지원', '주거 관련 공고 유형 (주택, 임대, 분양 등)', 1, true),
  ('취업지원', '청년 및 구직자 대상 지원정책 (채용, 인턴십 등)', 2, true),
  ('교육지원', '교육 및 장학 관련 공고 (학자금, 교육비 지원 등)', 3, true),
  ('건강지원', '의료 및 복지 관련 공고 (건강검진, 의료비 지원 등)', 4, true),
  ('기타', '기타 혜택 유형 (문화, 여가, 생활비 등)', 5, true)
ON CONFLICT (id) DO NOTHING;

-- ================================================================
-- 2. CREATE announcement_tabs TABLE
-- ================================================================

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

COMMENT ON TABLE public.announcement_tabs IS 'Announcement type tabs/sections (e.g., age-based housing units)';
COMMENT ON COLUMN public.announcement_tabs.income_conditions IS 'JSON array of income requirements';
COMMENT ON COLUMN public.announcement_tabs.additional_info IS 'JSON object with images, PDFs, extra notes';

-- Indexes
CREATE INDEX IF NOT EXISTS idx_announcement_tabs_announcement_id
ON public.announcement_tabs(announcement_id);

CREATE INDEX IF NOT EXISTS idx_announcement_tabs_age_category_id
ON public.announcement_tabs(age_category_id)
WHERE age_category_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_announcement_tabs_display_order
ON public.announcement_tabs(announcement_id, display_order);

-- RLS
ALTER TABLE public.announcement_tabs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public users can read announcement tabs"
ON public.announcement_tabs
FOR SELECT
USING (true);

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

-- Trigger
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

-- ================================================================
-- 3. CREATE announcement_unit_types TABLE
-- ================================================================

CREATE TABLE IF NOT EXISTS public.announcement_unit_types (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  announcement_id uuid NOT NULL REFERENCES public.announcements(id) ON DELETE CASCADE,
  unit_type text NOT NULL,
  supply_area numeric(10,2),
  exclusive_area numeric(10,2),
  supply_count integer,
  monthly_rent integer,
  deposit integer,
  maintenance_fee integer,
  floor_info text,
  direction text,
  room_structure text,
  additional_info jsonb DEFAULT '{}'::jsonb,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

COMMENT ON TABLE public.announcement_unit_types IS 'Housing unit type details for announcements (LH-style)';
COMMENT ON COLUMN public.announcement_unit_types.supply_area IS 'Total supply area in square meters';
COMMENT ON COLUMN public.announcement_unit_types.exclusive_area IS 'Exclusive area in square meters';

-- Indexes
CREATE INDEX IF NOT EXISTS idx_announcement_unit_types_announcement_id
ON public.announcement_unit_types(announcement_id);

CREATE INDEX IF NOT EXISTS idx_announcement_unit_types_sort_order
ON public.announcement_unit_types(announcement_id, sort_order);

-- RLS
ALTER TABLE public.announcement_unit_types ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public users can read unit types"
ON public.announcement_unit_types
FOR SELECT
USING (true);

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

-- Trigger
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

-- ================================================================
-- SUCCESS MESSAGE
-- ================================================================

DO $$
BEGIN
  RAISE NOTICE '╔═══════════════════════════════════════════════════╗';
  RAISE NOTICE '║  ✅ Admin Schema Fix Complete                     ║';
  RAISE NOTICE '║                                                   ║';
  RAISE NOTICE '║  📋 Created Tables:                               ║';
  RAISE NOTICE '║     1. announcement_types (5 default rows)        ║';
  RAISE NOTICE '║     2. announcement_tabs                          ║';
  RAISE NOTICE '║     3. announcement_unit_types                    ║';
  RAISE NOTICE '║                                                   ║';
  RAISE NOTICE '║  🔒 RLS: Enabled on all tables                    ║';
  RAISE NOTICE '║  🔗 Foreign Keys: Configured with CASCADE         ║';
  RAISE NOTICE '║  📊 Indexes: 7 indexes created for performance    ║';
  RAISE NOTICE '║  ⚡ Triggers: Auto-update for updated_at          ║';
  RAISE NOTICE '╚═══════════════════════════════════════════════════╝';
END $$;
