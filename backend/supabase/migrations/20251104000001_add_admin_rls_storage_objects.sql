-- ============================================================================
-- Migration: Admin RLS Policy for Storage Objects (PRD v9.6.1 Alignment)
-- Created: 2025-11-04
-- Purpose: Enable admin users to upload/manage files in storage.objects
-- Ensures 'icons' bucket exists and applies proper RLS policies
-- ============================================================================

-- Step 1: Create 'icons' bucket if not exists
INSERT INTO storage.buckets (id, name, public)
VALUES ('icons', 'icons', true)
ON CONFLICT (id) DO NOTHING;

-- Step 2: Drop existing policies to avoid conflicts
DO $$
BEGIN
  -- Drop policies if they exist
  DROP POLICY IF EXISTS "Public can read icons" ON storage.objects;
  DROP POLICY IF EXISTS "Admin can insert storage objects" ON storage.objects;
  DROP POLICY IF EXISTS "Admin can update storage objects" ON storage.objects;
  DROP POLICY IF EXISTS "Admin can delete storage objects" ON storage.objects;
EXCEPTION
  WHEN insufficient_privilege THEN
    RAISE NOTICE 'Skipping policy drops due to insufficient privileges';
END $$;

-- Step 3: Create public read policy for icons bucket
CREATE POLICY "Public can read icons"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'icons');

-- Step 4: Create admin INSERT policy for storage uploads
CREATE POLICY "Admin can insert storage objects"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'icons' AND public.is_admin());

-- Step 5: Create admin UPDATE policy for storage modifications
CREATE POLICY "Admin can update storage objects"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'icons' AND public.is_admin())
WITH CHECK (bucket_id = 'icons' AND public.is_admin());

-- Step 6: Create admin DELETE policy for storage deletions
CREATE POLICY "Admin can delete storage objects"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'icons' AND public.is_admin());

-- ============================================================================
-- Verification Query
-- ============================================================================
-- Run this to verify policies are created:
--
-- SELECT
--   policyname,
--   cmd,
--   roles,
--   qual,
--   with_check
-- FROM pg_policies
-- WHERE tablename = 'objects'
--   AND schemaname = 'storage'
--   AND (policyname LIKE '%Admin%' OR policyname LIKE '%icons%');
--
-- Verify bucket:
-- SELECT id, name, public FROM storage.buckets WHERE id = 'icons';
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '╔═══════════════════════════════════════════════╗';
  RAISE NOTICE '║  ✅ Migration 20251104000001 Complete         ║';
  RAISE NOTICE '║  📦 Bucket: icons (public: true)              ║';
  RAISE NOTICE '║  🔒 RLS: policies configured                  ║';
  RAISE NOTICE '║  📊 Policies Created:                         ║';
  RAISE NOTICE '║    👁️  Public can read icons                  ║';
  RAISE NOTICE '║    ➕ Admin can insert storage objects        ║';
  RAISE NOTICE '║    ✏️  Admin can update storage objects        ║';
  RAISE NOTICE '║    🗑️  Admin can delete storage objects        ║';
  RAISE NOTICE '║  ✅ Admin SVG upload should now work          ║';
  RAISE NOTICE '╚═══════════════════════════════════════════════╝';
END $$;
