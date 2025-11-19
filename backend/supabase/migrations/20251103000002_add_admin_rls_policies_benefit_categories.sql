-- Migration: Add Admin RLS Policies for benefit_categories
-- Date: 2025-11-03
-- PRD: v9.6.1 - Pickly Integrated System
-- Purpose: Allow admin@pickly.com to INSERT, UPDATE, DELETE benefit categories

-- =====================================================
-- RLS Policies for benefit_categories (Admin Access)
-- =====================================================

-- Policy 1: Admin can INSERT new categories
CREATE POLICY "Admin can insert benefit_categories"
ON public.benefit_categories
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.email = 'admin@pickly.com'
  )
);

-- Policy 2: Admin can UPDATE existing categories
CREATE POLICY "Admin can update benefit_categories"
ON public.benefit_categories
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.email = 'admin@pickly.com'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.email = 'admin@pickly.com'
  )
);

-- Policy 3: Admin can DELETE categories
CREATE POLICY "Admin can delete benefit_categories"
ON public.benefit_categories
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.email = 'admin@pickly.com'
  )
);

-- =====================================================
-- Verification
-- =====================================================

-- Verify all policies created
DO $$
BEGIN
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

  RAISE NOTICE 'All admin RLS policies for benefit_categories created successfully';
END $$;

-- =====================================================
-- Expected Policies (Total: 4)
-- =====================================================
-- 1. Public can view active categories (SELECT, public)
-- 2. Admin can insert benefit_categories (INSERT, authenticated)
-- 3. Admin can update benefit_categories (UPDATE, authenticated)
-- 4. Admin can delete benefit_categories (DELETE, authenticated)

-- =====================================================
-- Query to verify policies
-- =====================================================
-- SELECT policyname, cmd, roles
-- FROM pg_policies
-- WHERE tablename = 'benefit_categories'
-- ORDER BY cmd, policyname;
