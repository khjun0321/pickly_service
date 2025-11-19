-- Migration: Add Authenticated SELECT Policies for Admin Read Access
-- Date: 2025-11-05
-- PRD: v9.6.1 Phase 5.1 - Admin SELECT 정책 추가
-- Purpose: Allow authenticated users (Admin) to read ALL categories (including inactive)
--
-- CRITICAL FIX: Admin can INSERT/UPDATE/DELETE but cannot SELECT!
-- Phase 5 added write policies but forgot read policies for authenticated users.

-- =====================================================
-- Problem: Admin Cannot See Category Lists
-- =====================================================
/*
Current State After Phase 5:
- benefit_categories:
  ✅ Public SELECT: Active categories only (is_active = true)
  ❌ Authenticated SELECT: MISSING
  ✅ Authenticated INSERT/UPDATE/DELETE: Working

- benefit_subcategories:
  ✅ Public SELECT: Active subcategories only
  ❌ Authenticated SELECT: MISSING
  ✅ Authenticated INSERT/UPDATE/DELETE: Working

Result:
- Admin can CREATE categories (INSERT works)
- Admin can EDIT categories (UPDATE works)
- Admin can DELETE categories (DELETE works)
- Admin CANNOT SEE categories (SELECT missing) ← CRITICAL BUG

Fix:
Add authenticated SELECT policies that allow reading ALL rows (including inactive)
*/

-- =====================================================
-- Step 1: benefit_categories - Add Authenticated SELECT
-- =====================================================

CREATE POLICY "Authenticated users can view all benefit_categories"
ON public.benefit_categories
FOR SELECT
TO authenticated
USING (true);  -- Allow reading ALL categories (including inactive)

-- =====================================================
-- Step 2: benefit_subcategories - Add Authenticated SELECT
-- =====================================================

CREATE POLICY "Authenticated users can view all benefit_subcategories"
ON public.benefit_subcategories
FOR SELECT
TO authenticated
USING (true);  -- Allow reading ALL subcategories (including inactive)

-- =====================================================
-- Verification
-- =====================================================

DO $$
DECLARE
  benefit_categories_select_policies INTEGER;
  benefit_subcategories_select_policies INTEGER;
BEGIN
  -- Count SELECT policies for benefit_categories
  SELECT COUNT(*) INTO benefit_categories_select_policies
  FROM pg_policies
  WHERE tablename = 'benefit_categories'
  AND cmd = 'SELECT'
  AND roles = '{authenticated}';

  -- Count SELECT policies for benefit_subcategories
  SELECT COUNT(*) INTO benefit_subcategories_select_policies
  FROM pg_policies
  WHERE tablename = 'benefit_subcategories'
  AND cmd = 'SELECT'
  AND roles = '{authenticated}';

  -- Verify policies created
  IF benefit_categories_select_policies = 0 THEN
    RAISE EXCEPTION '❌ benefit_categories authenticated SELECT policy not created';
  END IF;

  IF benefit_subcategories_select_policies = 0 THEN
    RAISE EXCEPTION '❌ benefit_subcategories authenticated SELECT policy not created';
  END IF;

  RAISE NOTICE '✅ benefit_categories: % authenticated SELECT policy', benefit_categories_select_policies;
  RAISE NOTICE '✅ benefit_subcategories: % authenticated SELECT policy', benefit_subcategories_select_policies;
  RAISE NOTICE '✅ All authenticated SELECT policies verified successfully';
END $$;

-- =====================================================
-- Expected Final RLS Policy Summary
-- =====================================================
/*
Table: benefit_categories (6 policies)
1. Public can view active benefit_categories (SELECT, public)
2. Public read access (SELECT, public)
3. Authenticated users can view all benefit_categories (SELECT, authenticated) ← NEW
4. Admin can insert benefit_categories (INSERT, authenticated)
5. Admin can update benefit_categories (UPDATE, authenticated)
6. Admin can delete benefit_categories (DELETE, authenticated)

Table: benefit_subcategories (5 policies)
1. Public read access (SELECT, public)
2. Authenticated users can view all benefit_subcategories (SELECT, authenticated) ← NEW
3. Admin can insert benefit_subcategories (INSERT, authenticated)
4. Admin can update benefit_subcategories (UPDATE, authenticated)
5. Admin can delete benefit_subcategories (DELETE, authenticated)

Key Difference:
- Public SELECT: Only active rows (is_active = true)
- Authenticated SELECT: ALL rows (including inactive) for admin management
*/

-- =====================================================
-- Test Queries (Run after migration)
-- =====================================================

-- Test 1: Verify all policies exist
-- SELECT tablename, policyname, cmd, roles
-- FROM pg_policies
-- WHERE tablename IN ('benefit_categories', 'benefit_subcategories')
-- ORDER BY tablename, cmd, policyname;

-- Test 2: Count SELECT policies per role
-- SELECT tablename, roles, COUNT(*) as select_policy_count
-- FROM pg_policies
-- WHERE tablename IN ('benefit_categories', 'benefit_subcategories')
-- AND cmd = 'SELECT'
-- GROUP BY tablename, roles
-- ORDER BY tablename, roles;

COMMENT ON TABLE benefit_categories IS 'PRD v9.6.1 - Phase 5.1: Authenticated SELECT policy added for admin read access';
COMMENT ON TABLE benefit_subcategories IS 'PRD v9.6.1 - Phase 5.1: Authenticated SELECT policy added for admin read access';
