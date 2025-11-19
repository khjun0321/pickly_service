-- Migration: Create user_regions junction table
-- Version: PRD v9.8.2 (Phase 6.3)
-- Date: 2025-11-07
-- Purpose: Store user's selected regions for personalized filtering

-- Create user_regions junction table
CREATE TABLE IF NOT EXISTS public.user_regions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  region_id uuid NOT NULL REFERENCES public.regions(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, region_id)
);

-- Add comment to table
COMMENT ON TABLE public.user_regions IS 'Junction table storing users selected regions for benefit filtering (PRD v9.8.2)';
COMMENT ON COLUMN public.user_regions.user_id IS 'Reference to auth.users - user who selected this region';
COMMENT ON COLUMN public.user_regions.region_id IS 'Reference to public.regions - the selected region';

-- Create index for user lookup (most common query pattern)
CREATE INDEX IF NOT EXISTS idx_user_regions_user_id
ON public.user_regions (user_id);

-- Create index for region lookup (for admin analytics)
CREATE INDEX IF NOT EXISTS idx_user_regions_region_id
ON public.user_regions (region_id);

-- Enable Row Level Security
ALTER TABLE public.user_regions ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can only manage their own region selections
CREATE POLICY "Users can manage their own regions"
ON public.user_regions
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Create policy: Admin users can read all user regions (for analytics)
-- Note: Admin check should be added here when admin roles are implemented
-- For now, users can only see their own data via the USING clause above
