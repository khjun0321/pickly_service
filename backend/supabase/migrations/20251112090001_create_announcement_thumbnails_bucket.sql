-- ============================================
-- Migration: Create announcement-thumbnails Storage Bucket
-- PRD v9.12.0 - Announcement Thumbnails Storage
-- Purpose: Create Storage bucket for announcement thumbnail images
-- Date: 2025-11-12
-- ============================================

-- ============================================
-- 1️⃣ Create announcement-thumbnails bucket
-- ============================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'announcement-thumbnails',
  'announcement-thumbnails',
  true,                                      -- Public read access
  5242880,                                   -- 5MB file size limit
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']::text[]
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']::text[];

-- ============================================
-- 2️⃣ RLS Policies for announcement-thumbnails bucket
-- ============================================

-- Policy 1: Public read access (anyone can view thumbnails)
DROP POLICY IF EXISTS "thumbs read public" ON storage.objects;
CREATE POLICY "thumbs read public"
  ON storage.objects
  FOR SELECT
  TO public
  USING (bucket_id = 'announcement-thumbnails');

-- Policy 2: Authenticated users can upload thumbnails
DROP POLICY IF EXISTS "thumbs write auth" ON storage.objects;
CREATE POLICY "thumbs write auth"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'announcement-thumbnails'
    AND auth.role() = 'authenticated'
  );

-- Policy 3: Authenticated users can update thumbnails
DROP POLICY IF EXISTS "thumbs update auth" ON storage.objects;
CREATE POLICY "thumbs update auth"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'announcement-thumbnails'
    AND auth.role() = 'authenticated'
  );

-- Policy 4: Authenticated users can delete thumbnails
DROP POLICY IF EXISTS "thumbs delete auth" ON storage.objects;
CREATE POLICY "thumbs delete auth"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'announcement-thumbnails'
    AND auth.role() = 'authenticated'
  );

-- ============================================
-- 3️⃣ Helper Function: Generate thumbnail path
-- ============================================

CREATE OR REPLACE FUNCTION public.generate_thumbnail_path(
  announcement_id UUID,
  file_extension TEXT DEFAULT 'jpg'
)
RETURNS TEXT AS $$
BEGIN
  RETURN announcement_id::TEXT || '/' || extract(epoch from now())::BIGINT || '.' || file_extension;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION public.generate_thumbnail_path(UUID, TEXT) IS
'Generate unique thumbnail file path: {announcement_id}/{timestamp}.{ext}';

-- ============================================
-- ✅ Storage Bucket Configuration Complete
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '==============================================';
  RAISE NOTICE '✅ Announcement Thumbnails Storage Complete';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '📦 Bucket Created:';
  RAISE NOTICE '   - ID: announcement-thumbnails';
  RAISE NOTICE '   - Public: true (read access)';
  RAISE NOTICE '   - Max Size: 5MB';
  RAISE NOTICE '   - MIME Types: JPEG, PNG, WebP';
  RAISE NOTICE '🔒 RLS Policies:';
  RAISE NOTICE '   - Public: SELECT (read)';
  RAISE NOTICE '   - Authenticated: INSERT, UPDATE, DELETE (write)';
  RAISE NOTICE '🔧 Helper Function:';
  RAISE NOTICE '   - generate_thumbnail_path()';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '📝 Usage Example:';
  RAISE NOTICE '   Storage path: announcements/{id}/{timestamp}.jpg';
  RAISE NOTICE '   Public URL: https://...supabase.co/storage/v1/object/public/announcement-thumbnails/...';
  RAISE NOTICE '==============================================';
END $$;
