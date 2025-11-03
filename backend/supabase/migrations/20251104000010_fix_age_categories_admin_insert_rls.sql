-- Migration: Fix RLS Policy for Admin INSERT on age_categories
-- PRD: v9.6.1 Alignment
-- Date: 2025-11-04
-- Issue: Admin INSERT operations fail due to missing WITH CHECK clause
--
-- Problem:
-- The existing "Admins manage categories" policy only has USING clause.
-- For INSERT operations, PostgreSQL requires WITH CHECK clause.
--
-- Solution:
-- Drop and recreate the policy with proper WITH CHECK clause
-- Use is_admin() helper function for consistency

-- Drop existing policy
DROP POLICY IF EXISTS "Admins manage categories" ON age_categories;

-- Create new policy with both USING and WITH CHECK clauses
-- USING: Controls which rows admin can SELECT/UPDATE/DELETE
-- WITH CHECK: Controls which rows admin can INSERT/UPDATE
CREATE POLICY "Admins manage categories"
  ON age_categories
  FOR ALL
  TO authenticated
  USING (
    -- Admin can view/modify any row
    public.is_admin()
  )
  WITH CHECK (
    -- Admin can insert/update any row
    public.is_admin()
  );

-- Verify policy was created
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
    AND tablename = 'age_categories'
    AND policyname = 'Admins manage categories'
  ) THEN
    RAISE EXCEPTION 'Failed to create admin policy for age_categories';
  END IF;

  RAISE NOTICE '✅ Admin RLS policy for age_categories updated successfully';
END $$;

-- Test the policy (this will only work if run as admin user)
-- Uncomment to test after migration:
-- INSERT INTO age_categories (title, description, icon_component, min_age, max_age, sort_order)
-- VALUES ('테스트 카테고리', '테스트 설명', 'test_icon', 0, 99, 100);
-- DELETE FROM age_categories WHERE title = '테스트 카테고리';
