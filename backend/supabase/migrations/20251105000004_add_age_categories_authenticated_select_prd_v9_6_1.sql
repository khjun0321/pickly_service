-- Migration: Add Authenticated SELECT Policy for age_categories
-- Date: 2025-11-05
-- PRD: v9.6.1 Phase 5.2 - Age Categories Admin Access
-- Purpose: Allow authenticated users (Admin) to read ALL age_categories
--
-- ISSUE: age_categories has "Admins manage categories" ALL policy for public role
-- But Admin uses authenticated role, so they cannot SELECT age_categories!
-- Need to add authenticated SELECT policy like we did for benefit_categories.

-- =====================================================
-- Problem Analysis
-- =====================================================
/*
Current age_categories policies:
1. "Anyone views active categories" (SELECT, public) - only active categories
2. "Admins manage categories" (ALL, public) - admin operations

Issue:
- Admin logs in with authenticated role (not public!)
- Admin needs to SELECT ALL age_categories (including inactive)
- Only public SELECT policy exists (only shows active)
- No authenticated SELECT policy exists

Fix:
Add authenticated SELECT policy allowing Admin to read ALL age_categories
*/

-- =====================================================
-- Step 1: Add Authenticated SELECT Policy
-- =====================================================

CREATE POLICY "Authenticated users can view all age_categories"
ON public.age_categories
FOR SELECT
TO authenticated
USING (true);  -- Allow reading ALL age categories (including inactive)

-- =====================================================
-- Verification
-- =====================================================

DO $$
DECLARE
  authenticated_select_policies INTEGER;
  public_select_policies INTEGER;
BEGIN
  -- Count SELECT policies for authenticated
  SELECT COUNT(*) INTO authenticated_select_policies
  FROM pg_policies
  WHERE tablename = 'age_categories'
  AND cmd = 'SELECT'
  AND roles = '{authenticated}';

  -- Count SELECT policies for public
  SELECT COUNT(*) INTO public_select_policies
  FROM pg_policies
  WHERE tablename = 'age_categories'
  AND cmd = 'SELECT'
  AND roles = '{public}';

  -- Verify policies
  IF authenticated_select_policies = 0 THEN
    RAISE EXCEPTION '❌ age_categories authenticated SELECT policy not created';
  END IF;

  RAISE NOTICE '✅ age_categories: % authenticated SELECT policy', authenticated_select_policies;
  RAISE NOTICE '✅ age_categories: % public SELECT policy', public_select_policies;
  RAISE NOTICE '✅ All age_categories SELECT policies verified successfully';
END $$;

-- =====================================================
-- Expected Final RLS Policy Summary
-- =====================================================
/*
Table: age_categories (3 policies)
1. Anyone views active categories (SELECT, public) - Flutter app access
2. Admins manage categories (ALL, public) - legacy admin operations
3. Authenticated users can view all age_categories (SELECT, authenticated) ← NEW

Key Difference:
- Public SELECT: Only active rows (is_active = true) for Flutter app
- Authenticated SELECT: ALL rows (including inactive) for Admin management
*/

COMMENT ON TABLE age_categories IS 'PRD v9.6.1 - Phase 5.2: Authenticated SELECT policy added for admin read access';
