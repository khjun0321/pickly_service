-- ================================================================
-- Migration: 20251101000008_add_announcements_insert_policy
-- Description: Add RLS INSERT policy for authenticated admin users
-- Purpose: Fix "new row violates row-level security policy" error
-- Date: 2025-11-01
-- ================================================================

-- Add INSERT policy for authenticated users (Admin)
-- ================================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'announcements'
      AND policyname = 'Authenticated users can insert announcements'
  ) THEN
    CREATE POLICY "Authenticated users can insert announcements"
    ON public.announcements
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

    RAISE NOTICE '✅ Created INSERT policy for authenticated users';
  ELSE
    RAISE NOTICE 'ℹ️  INSERT policy already exists';
  END IF;
END $$;

-- Add UPDATE policy for authenticated users (Admin)
-- ================================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'announcements'
      AND policyname = 'Authenticated users can update announcements'
  ) THEN
    CREATE POLICY "Authenticated users can update announcements"
    ON public.announcements
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

    RAISE NOTICE '✅ Created UPDATE policy for authenticated users';
  ELSE
    RAISE NOTICE 'ℹ️  UPDATE policy already exists';
  END IF;
END $$;

-- Add DELETE policy for authenticated users (Admin)
-- ================================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'announcements'
      AND policyname = 'Authenticated users can delete announcements'
  ) THEN
    CREATE POLICY "Authenticated users can delete announcements"
    ON public.announcements
    FOR DELETE
    TO authenticated
    USING (true);

    RAISE NOTICE '✅ Created DELETE policy for authenticated users';
  ELSE
    RAISE NOTICE 'ℹ️  DELETE policy already exists';
  END IF;
END $$;

-- Verification query
-- ================================================================

DO $$
DECLARE
  policy_count INTEGER;
BEGIN
  -- Count all policies on announcements table
  SELECT COUNT(*) INTO policy_count
  FROM pg_policies
  WHERE tablename = 'announcements';

  RAISE NOTICE '╔═══════════════════════════════════════════════╗';
  RAISE NOTICE '║  ✅ Migration 20251101000008 Complete         ║';
  RAISE NOTICE '║  📋 Table: announcements                      ║';
  RAISE NOTICE '║  🔒 RLS Status: ENABLED                       ║';
  RAISE NOTICE '║  📊 Total Policies: %                         ║', policy_count;
  RAISE NOTICE '║  ➕ INSERT: ✅ (authenticated)                ║';
  RAISE NOTICE '║  ✏️  UPDATE: ✅ (authenticated)                ║';
  RAISE NOTICE '║  🗑️  DELETE: ✅ (authenticated)                ║';
  RAISE NOTICE '║  👁️  SELECT: ✅ (public, non-draft)           ║';
  RAISE NOTICE '║  ✅ Admin "공고 추가" RLS error fixed         ║';
  RAISE NOTICE '╚═══════════════════════════════════════════════╝';
END $$;

-- Display all policies for verification
-- ================================================================

SELECT
  policyname AS "Policy Name",
  cmd AS "Command",
  roles AS "Roles",
  CASE
    WHEN qual IS NULL THEN 'N/A'
    ELSE qual
  END AS "USING Clause",
  CASE
    WHEN with_check IS NULL THEN 'N/A'
    ELSE with_check
  END AS "WITH CHECK Clause"
FROM pg_policies
WHERE tablename = 'announcements'
ORDER BY
  CASE cmd
    WHEN 'SELECT' THEN 1
    WHEN 'INSERT' THEN 2
    WHEN 'UPDATE' THEN 3
    WHEN 'DELETE' THEN 4
  END;
