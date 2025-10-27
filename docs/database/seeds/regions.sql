-- Seed Data: regions.sql
-- Description: Insert Korean administrative regions (17 total)
-- Author: System Architect
-- Date: 2025-10-13

-- ============================================================================
-- SEED REGIONS DATA
-- ============================================================================

-- Clear existing data (for development/testing environments)
-- CAUTION: Comment out in production if preserving data
-- DELETE FROM public.user_regions;
-- DELETE FROM public.regions;

-- Insert Korean regions in display order
-- Note: "전국" (Nationwide) is first, followed by regions in conventional order

INSERT INTO public.regions (code, name, sort_order, is_active) VALUES
    ('nationwide', '전국', 0, true),         -- Nationwide
    ('seoul', '서울', 1, true),              -- Seoul
    ('busan', '부산', 2, true),              -- Busan
    ('daegu', '대구', 3, true),              -- Daegu
    ('incheon', '인천', 4, true),            -- Incheon
    ('gwangju', '광주', 5, true),            -- Gwangju
    ('daejeon', '대전', 6, true),            -- Daejeon
    ('ulsan', '울산', 7, true),              -- Ulsan
    ('sejong', '세종', 8, true),             -- Sejong
    ('gyeonggi', '경기', 9, true),           -- Gyeonggi
    ('gangwon', '강원', 10, true),           -- Gangwon
    ('chungbuk', '충북', 11, true),          -- North Chungcheong
    ('chungnam', '충남', 12, true),          -- South Chungcheong
    ('jeonbuk', '전북', 13, true),           -- North Jeolla
    ('jeonnam', '전남', 14, true),           -- South Jeolla
    ('gyeongbuk', '경북', 15, true),         -- North Gyeongsang
    ('gyeongnam', '경남', 16, true),         -- South Gyeongsang
    ('jeju', '제주', 17, true)               -- Jeju
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify all regions were inserted
DO $$
DECLARE
    region_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO region_count FROM public.regions WHERE is_active = true;

    IF region_count = 18 THEN
        RAISE NOTICE 'SUCCESS: All 18 regions inserted correctly';
    ELSE
        RAISE WARNING 'WARNING: Expected 18 regions, but found %', region_count;
    END IF;
END $$;

-- Display inserted regions
SELECT
    code,
    name,
    sort_order,
    is_active,
    created_at
FROM public.regions
ORDER BY sort_order;

-- ============================================================================
-- SAMPLE DATA FOR TESTING (Optional - Comment out for production)
-- ============================================================================

-- Create sample test user profile (requires existing user in auth.users)
-- Uncomment and modify user_id for testing

/*
-- Sample: Create test user profile
INSERT INTO public.user_profiles (
    id,
    onboarding_completed
) VALUES (
    '00000000-0000-0000-0000-000000000001'::UUID, -- Replace with actual test user ID
    false
) ON CONFLICT (id) DO NOTHING;

-- Sample: Add region selections for test user
INSERT INTO public.user_regions (user_id, region_id)
SELECT
    '00000000-0000-0000-0000-000000000001'::UUID,
    id
FROM public.regions
WHERE code IN ('seoul', 'gyeonggi', 'incheon')
ON CONFLICT (user_id, region_id) DO NOTHING;

-- Verify test data
SELECT
    up.id as user_id,
    up.onboarding_completed,
    r.code,
    r.name
FROM public.user_profiles up
LEFT JOIN public.user_regions ur ON up.id = ur.user_id
LEFT JOIN public.regions r ON ur.region_id = r.id
WHERE up.id = '00000000-0000-0000-0000-000000000001'::UUID;
*/

-- ============================================================================
-- SEED COMPLETE
-- ============================================================================

ANALYZE public.regions;
ANALYZE public.user_regions;
ANALYZE public.user_profiles;
