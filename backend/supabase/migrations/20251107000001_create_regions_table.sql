-- Migration: Create regions table for Korean regional data
-- Version: PRD v9.8.2 (Phase 6.3)
-- Date: 2025-11-07
-- Purpose: Fix RegionException by creating missing regions table

-- Create regions table
CREATE TABLE IF NOT EXISTS public.regions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text UNIQUE NOT NULL, -- e.g., 'SEOUL', 'GYEONGGI'
  name text NOT NULL, -- e.g., '서울', '경기'
  sort_order integer NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Add comment to table
COMMENT ON TABLE public.regions IS 'Korean regions for user location filtering (PRD v9.8.2)';
COMMENT ON COLUMN public.regions.code IS 'Unique region code in English (e.g., SEOUL, GYEONGGI)';
COMMENT ON COLUMN public.regions.name IS 'Display name in Korean (e.g., 서울, 경기)';
COMMENT ON COLUMN public.regions.sort_order IS 'Display order (0 = first, higher = later)';

-- Create index for common queries (active regions sorted by order)
CREATE INDEX IF NOT EXISTS idx_regions_active_sort
ON public.regions (is_active, sort_order)
WHERE is_active = true;

-- Create index for code lookup
CREATE INDEX IF NOT EXISTS idx_regions_code
ON public.regions (code);

-- Enable Row Level Security
ALTER TABLE public.regions ENABLE ROW LEVEL SECURITY;

-- Create policy allowing public read access to active regions
CREATE POLICY "Public read access for regions"
ON public.regions
FOR SELECT
TO public
USING (is_active = true);

-- Create policy allowing authenticated users to manage regions
-- (Admin users will need this for CRUD operations)
CREATE POLICY "Authenticated users can manage regions"
ON public.regions
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);
