-- ================================================================
-- Migration: 20251101000002_create_announcement_types
-- Description: Create announcement_types table for Admin form
-- Purpose: Fix "공고유형 추가" error in Admin
-- Date: 2025-11-01
-- ================================================================

-- Create announcement_types table
-- ================================

CREATE TABLE IF NOT EXISTS public.announcement_types (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  title text NOT NULL,
  description text,
  sort_order integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Create indexes for performance
-- ================================

CREATE INDEX IF NOT EXISTS idx_announcement_types_sort_order
ON public.announcement_types(sort_order)
WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_announcement_types_is_active
ON public.announcement_types(is_active);

-- Insert default seed data
-- ================================

INSERT INTO public.announcement_types (title, description, sort_order, is_active)
VALUES
  ('주거지원', '주거 관련 공고 유형', 1, true),
  ('취업지원', '청년 및 구직자 대상 지원정책', 2, true),
  ('교육지원', '교육 및 장학 관련 공고', 3, true),
  ('건강지원', '의료 및 복지 관련 공고', 4, true),
  ('기타', '기타 혜택 유형', 5, true)
ON CONFLICT (id) DO NOTHING;

-- Enable Row Level Security (RLS)
-- ================================

ALTER TABLE public.announcement_types ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- ================================

-- Public read access for active announcement types
CREATE POLICY "Public users can read active announcement types"
ON public.announcement_types
FOR SELECT
USING (is_active = true);

-- Admin full access (placeholder - adjust based on your auth setup)
CREATE POLICY "Admin users have full access to announcement types"
ON public.announcement_types
FOR ALL
USING (true)
WITH CHECK (true);

-- Create trigger for updated_at
-- ================================

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

-- Success message
-- ================================

DO $$
BEGIN
  RAISE NOTICE '╔════════════════════════════════════════════╗';
  RAISE NOTICE '║  ✅ Migration 20251101000002 Complete      ║';
  RAISE NOTICE '║  📋 Table: announcement_types              ║';
  RAISE NOTICE '║  🌱 Seed Data: 5 default types inserted   ║';
  RAISE NOTICE '║  🔒 RLS: Enabled with policies             ║';
  RAISE NOTICE '╚════════════════════════════════════════════╝';
END $$;
