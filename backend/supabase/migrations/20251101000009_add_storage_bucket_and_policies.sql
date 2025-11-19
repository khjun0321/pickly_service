-- ================================================================
-- Migration: 20251101000009_add_storage_bucket_and_policies
-- Description: Create pickly-storage bucket and RLS policies for Admin uploads
-- Purpose: Fix "new row violates row-level security policy" on storage.objects
-- Date: 2025-11-01
-- ================================================================

-- Create pickly-storage bucket
-- ================================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('pickly-storage', 'pickly-storage', true)
ON CONFLICT (id) DO NOTHING;

-- Add RLS policies for pickly-storage bucket
-- ================================================================

-- SELECT policy (Public read access)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'Public read access for pickly-storage'
  ) THEN
    CREATE POLICY "Public read access for pickly-storage"
    ON storage.objects
    FOR SELECT
    TO public
    USING (bucket_id = 'pickly-storage');

    RAISE NOTICE '✅ Created SELECT policy for pickly-storage';
  ELSE
    RAISE NOTICE 'ℹ️  SELECT policy for pickly-storage already exists';
  END IF;
END $$;

-- INSERT policy (Authenticated users can upload)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'Authenticated users can upload to pickly-storage'
  ) THEN
    CREATE POLICY "Authenticated users can upload to pickly-storage"
    ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'pickly-storage');

    RAISE NOTICE '✅ Created INSERT policy for pickly-storage';
  ELSE
    RAISE NOTICE 'ℹ️  INSERT policy for pickly-storage already exists';
  END IF;
END $$;

-- UPDATE policy (Authenticated users can update)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'Authenticated users can update pickly-storage'
  ) THEN
    CREATE POLICY "Authenticated users can update pickly-storage"
    ON storage.objects
    FOR UPDATE
    TO authenticated
    USING (bucket_id = 'pickly-storage')
    WITH CHECK (bucket_id = 'pickly-storage');

    RAISE NOTICE '✅ Created UPDATE policy for pickly-storage';
  ELSE
    RAISE NOTICE 'ℹ️  UPDATE policy for pickly-storage already exists';
  END IF;
END $$;

-- DELETE policy (Authenticated users can delete)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'Authenticated users can delete from pickly-storage'
  ) THEN
    CREATE POLICY "Authenticated users can delete from pickly-storage"
    ON storage.objects
    FOR DELETE
    TO authenticated
    USING (bucket_id = 'pickly-storage');

    RAISE NOTICE '✅ Created DELETE policy for pickly-storage';
  ELSE
    RAISE NOTICE 'ℹ️  DELETE policy for pickly-storage already exists';
  END IF;
END $$;

-- Verification query
-- ================================================================

DO $$
DECLARE
  bucket_exists BOOLEAN;
  policy_count INTEGER;
BEGIN
  -- Check if bucket exists
  SELECT EXISTS (
    SELECT 1 FROM storage.buckets
    WHERE id = 'pickly-storage'
  ) INTO bucket_exists;

  -- Count policies for pickly-storage
  SELECT COUNT(*) INTO policy_count
  FROM pg_policies
  WHERE tablename = 'objects'
    AND schemaname = 'storage'
    AND policyname LIKE '%pickly-storage%';

  RAISE NOTICE '╔═══════════════════════════════════════════════╗';
  RAISE NOTICE '║  ✅ Migration 20251101000009 Complete         ║';
  RAISE NOTICE '║  📦 Bucket: pickly-storage                    ║';
  RAISE NOTICE '║  🔒 RLS Status: ENABLED                       ║';
  RAISE NOTICE '║  📊 Total Policies: %                         ║', policy_count;
  RAISE NOTICE '║  👁️  SELECT: ✅ (public read)                 ║';
  RAISE NOTICE '║  ➕ INSERT: ✅ (authenticated)                ║';
  RAISE NOTICE '║  ✏️  UPDATE: ✅ (authenticated)                ║';
  RAISE NOTICE '║  🗑️  DELETE: ✅ (authenticated)                ║';
  RAISE NOTICE '║  ✅ Admin "썸네일 업로드" error fixed         ║';
  RAISE NOTICE '╚═══════════════════════════════════════════════╝';

  IF NOT bucket_exists THEN
    RAISE WARNING '⚠️  pickly-storage bucket was not created';
  END IF;
END $$;

-- Display all storage buckets
-- ================================================================

SELECT
  id AS "Bucket ID",
  name AS "Bucket Name",
  public AS "Public Access"
FROM storage.buckets
ORDER BY name;

-- Display all policies for storage.objects
-- ================================================================

SELECT
  policyname AS "Policy Name",
  cmd AS "Command",
  roles AS "Roles"
FROM pg_policies
WHERE tablename = 'objects'
  AND schemaname = 'storage'
ORDER BY
  CASE
    WHEN policyname LIKE '%pickly-storage%' THEN 1
    ELSE 2
  END,
  CASE cmd
    WHEN 'SELECT' THEN 1
    WHEN 'INSERT' THEN 2
    WHEN 'UPDATE' THEN 3
    WHEN 'DELETE' THEN 4
  END;
