-- Migration: 002_regions.sql
-- Description: Create regions table, user_regions junction table, and update users table for onboarding tracking
-- Author: System Architect
-- Date: 2025-10-13

-- ============================================================================
-- 1. CREATE REGIONS TABLE (Master Data)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.regions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    sort_order INTEGER NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT regions_code_check CHECK (char_length(code) >= 2 AND char_length(code) <= 50),
    CONSTRAINT regions_name_check CHECK (char_length(name) >= 1 AND char_length(name) <= 100),
    CONSTRAINT regions_sort_order_check CHECK (sort_order >= 0)
);

-- Add comments for documentation
COMMENT ON TABLE public.regions IS 'Master table for Korean administrative regions';
COMMENT ON COLUMN public.regions.id IS 'Unique identifier for the region';
COMMENT ON COLUMN public.regions.code IS 'Unique code identifier (e.g., seoul, gyeonggi)';
COMMENT ON COLUMN public.regions.name IS 'Korean display name (e.g., 서울, 경기)';
COMMENT ON COLUMN public.regions.sort_order IS 'Display order for UI (0-based)';
COMMENT ON COLUMN public.regions.is_active IS 'Whether the region is currently active/visible';

-- Create indexes for performance
CREATE INDEX idx_regions_code ON public.regions(code) WHERE is_active = true;
CREATE INDEX idx_regions_sort_order ON public.regions(sort_order) WHERE is_active = true;
CREATE INDEX idx_regions_is_active ON public.regions(is_active);

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_regions_updated_at
    BEFORE UPDATE ON public.regions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 2. CREATE USER_REGIONS TABLE (User Selections)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.user_regions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    region_id UUID NOT NULL REFERENCES public.regions(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Unique constraint: One user can select each region only once
    CONSTRAINT user_regions_unique UNIQUE(user_id, region_id)
);

-- Add comments
COMMENT ON TABLE public.user_regions IS 'Junction table storing user region selections';
COMMENT ON COLUMN public.user_regions.user_id IS 'Reference to authenticated user';
COMMENT ON COLUMN public.user_regions.region_id IS 'Reference to selected region';

-- Create indexes for performance
CREATE INDEX idx_user_regions_user_id ON public.user_regions(user_id);
CREATE INDEX idx_user_regions_region_id ON public.user_regions(region_id);
CREATE INDEX idx_user_regions_created_at ON public.user_regions(created_at DESC);

-- Composite index for efficient queries
CREATE INDEX idx_user_regions_user_region ON public.user_regions(user_id, region_id);

-- ============================================================================
-- 3. UPDATE USERS TABLE (Onboarding Tracking)
-- ============================================================================

-- Add onboarding tracking columns to users metadata
-- Note: Supabase uses auth.users table, so we create a profiles table instead
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    selected_age_category_id UUID REFERENCES public.age_categories(id) ON DELETE SET NULL,
    onboarding_completed BOOLEAN NOT NULL DEFAULT false,
    onboarding_completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT onboarding_completed_at_check CHECK (
        (onboarding_completed = true AND onboarding_completed_at IS NOT NULL) OR
        (onboarding_completed = false AND onboarding_completed_at IS NULL)
    )
);

-- Add comments
COMMENT ON TABLE public.user_profiles IS 'Extended user profile data including onboarding status';
COMMENT ON COLUMN public.user_profiles.id IS 'References auth.users.id (one-to-one relationship)';
COMMENT ON COLUMN public.user_profiles.selected_age_category_id IS 'User selected age category from onboarding step 1';
COMMENT ON COLUMN public.user_profiles.onboarding_completed IS 'Whether user has completed all onboarding steps';
COMMENT ON COLUMN public.user_profiles.onboarding_completed_at IS 'Timestamp when onboarding was completed';

-- Create indexes
CREATE INDEX idx_user_profiles_onboarding_completed ON public.user_profiles(onboarding_completed);
CREATE INDEX idx_user_profiles_age_category ON public.user_profiles(selected_age_category_id);

-- Updated_at trigger for user_profiles
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 4. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE public.regions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_regions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- =========================
-- REGIONS TABLE POLICIES
-- =========================

-- Everyone can read active regions (public data)
CREATE POLICY "Anyone can view active regions"
    ON public.regions
    FOR SELECT
    USING (is_active = true);

-- Only service role can insert/update/delete regions (admin only)
CREATE POLICY "Only service role can modify regions"
    ON public.regions
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- =========================
-- USER_REGIONS TABLE POLICIES
-- =========================

-- Users can view their own region selections
CREATE POLICY "Users can view their own region selections"
    ON public.user_regions
    FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own region selections
CREATE POLICY "Users can insert their own region selections"
    ON public.user_regions
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can delete their own region selections
CREATE POLICY "Users can delete their own region selections"
    ON public.user_regions
    FOR DELETE
    USING (auth.uid() = user_id);

-- Service role has full access
CREATE POLICY "Service role has full access to user_regions"
    ON public.user_regions
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- =========================
-- USER_PROFILES TABLE POLICIES
-- =========================

-- Users can view their own profile
CREATE POLICY "Users can view their own profile"
    ON public.user_profiles
    FOR SELECT
    USING (auth.uid() = id);

-- Users can insert their own profile (auto-created on signup)
CREATE POLICY "Users can insert their own profile"
    ON public.user_profiles
    FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update their own profile"
    ON public.user_profiles
    FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Service role has full access
CREATE POLICY "Service role has full access to user_profiles"
    ON public.user_profiles
    FOR ALL
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- ============================================================================
-- 5. HELPER FUNCTIONS
-- ============================================================================

-- Function to get user's selected regions
CREATE OR REPLACE FUNCTION get_user_regions(p_user_id UUID)
RETURNS TABLE (
    region_id UUID,
    region_code TEXT,
    region_name TEXT,
    sort_order INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id,
        r.code,
        r.name,
        r.sort_order
    FROM public.user_regions ur
    INNER JOIN public.regions r ON ur.region_id = r.id
    WHERE ur.user_id = p_user_id
      AND r.is_active = true
    ORDER BY r.sort_order;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to set user regions (replaces all existing selections)
CREATE OR REPLACE FUNCTION set_user_regions(
    p_user_id UUID,
    p_region_ids UUID[]
)
RETURNS void AS $$
BEGIN
    -- Delete existing selections
    DELETE FROM public.user_regions
    WHERE user_id = p_user_id;

    -- Insert new selections
    INSERT INTO public.user_regions (user_id, region_id)
    SELECT p_user_id, unnest(p_region_ids);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to complete onboarding
CREATE OR REPLACE FUNCTION complete_onboarding(
    p_user_id UUID,
    p_age_category_id UUID DEFAULT NULL
)
RETURNS void AS $$
BEGIN
    -- Update or insert user profile
    INSERT INTO public.user_profiles (
        id,
        selected_age_category_id,
        onboarding_completed,
        onboarding_completed_at
    )
    VALUES (
        p_user_id,
        p_age_category_id,
        true,
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        selected_age_category_id = COALESCE(EXCLUDED.selected_age_category_id, user_profiles.selected_age_category_id),
        onboarding_completed = true,
        onboarding_completed_at = NOW(),
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 6. AUTOMATIC USER PROFILE CREATION
-- ============================================================================

-- Trigger to automatically create user profile on signup
CREATE OR REPLACE FUNCTION create_user_profile_on_signup()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id)
    VALUES (NEW.id)
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION create_user_profile_on_signup();

-- ============================================================================
-- 7. PERFORMANCE OPTIMIZATION
-- ============================================================================

-- Analyze tables for query optimization
ANALYZE public.regions;
ANALYZE public.user_regions;
ANALYZE public.user_profiles;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
