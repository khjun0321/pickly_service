-- Migration: Improve Admin RLS Policies with Helper Function
-- Date: 2025-11-03
-- PRD: v9.6.1 - Pickly Integrated System
-- Purpose: Refactor RLS policies to use a reusable helper function for admin checking

-- =====================================================
-- Create Admin Helper Function
-- =====================================================

-- Function to check if current authenticated user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM auth.users
    WHERE id = auth.uid()
    AND email = 'admin@pickly.com'
  );
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

-- Add function comment
COMMENT ON FUNCTION public.is_admin() IS 'Returns true if the current authenticated user is admin@pickly.com. Used in RLS policies for admin access control.';

-- =====================================================
-- Update RLS Policies to Use Helper Function
-- =====================================================

-- Drop existing admin policies (from previous migration)
DROP POLICY IF EXISTS "Admin can insert benefit_categories" ON public.benefit_categories;
DROP POLICY IF EXISTS "Admin can update benefit_categories" ON public.benefit_categories;
DROP POLICY IF EXISTS "Admin can delete benefit_categories" ON public.benefit_categories;

-- Policy 1: Admin INSERT (simplified with helper function)
CREATE POLICY "Admin can insert benefit_categories"
ON public.benefit_categories
FOR INSERT
TO authenticated
WITH CHECK (public.is_admin());

-- Policy 2: Admin UPDATE (simplified with helper function)
CREATE POLICY "Admin can update benefit_categories"
ON public.benefit_categories
FOR UPDATE
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Policy 3: Admin DELETE (simplified with helper function)
CREATE POLICY "Admin can delete benefit_categories"
ON public.benefit_categories
FOR DELETE
TO authenticated
USING (public.is_admin());

-- =====================================================
-- Benefits of This Approach
-- =====================================================
/*
1. **Reusability**: is_admin() can be used across multiple tables
2. **Performance**: Function is STABLE, so PostgreSQL can cache results within a transaction
3. **Maintainability**: Admin logic centralized in one place
4. **Clarity**: Policies are more readable with is_admin() vs inline EXISTS query
5. **Security**: SECURITY DEFINER ensures consistent execution context
*/

-- =====================================================
-- Verification
-- =====================================================

DO $$
BEGIN
  -- Check helper function exists
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc
    WHERE proname = 'is_admin'
    AND pronamespace = 'public'::regnamespace
  ) THEN
    RAISE EXCEPTION 'Helper function is_admin() not created';
  END IF;

  -- Check all policies exist
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'benefit_categories'
    AND policyname = 'Admin can insert benefit_categories'
  ) THEN
    RAISE EXCEPTION 'Admin INSERT policy not created';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'benefit_categories'
    AND policyname = 'Admin can update benefit_categories'
  ) THEN
    RAISE EXCEPTION 'Admin UPDATE policy not created';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'benefit_categories'
    AND policyname = 'Admin can delete benefit_categories'
  ) THEN
    RAISE EXCEPTION 'Admin DELETE policy not created';
  END IF;

  RAISE NOTICE 'Admin helper function and RLS policies updated successfully';
END $$;

-- =====================================================
-- Expected Policies (Total: 4)
-- =====================================================
-- 1. Public can view active categories (SELECT, public)
-- 2. Admin can insert benefit_categories (INSERT, authenticated, is_admin())
-- 3. Admin can update benefit_categories (UPDATE, authenticated, is_admin())
-- 4. Admin can delete benefit_categories (DELETE, authenticated, is_admin())

-- =====================================================
-- Usage Example
-- =====================================================
/*
-- Check if current user is admin (from client)
SELECT public.is_admin();

-- Query policies
SELECT policyname, cmd, with_check, qual
FROM pg_policies
WHERE tablename = 'benefit_categories'
ORDER BY cmd, policyname;
*/

-- =====================================================
-- Future Enhancement: Extend for Multiple Admins
-- =====================================================
/*
-- If you need multiple admin users in the future, create an admin_users table:

CREATE TABLE IF NOT EXISTS public.admin_users (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES auth.users(id)
);

-- Then update the helper function:
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_users
    WHERE user_id = auth.uid()
  );
$$;
*/
