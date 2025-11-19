-- Create Storage Buckets for v7.3 Benefit Management System
-- This migration creates 4 public storage buckets with RLS policies

-- =====================================================
-- 1. Create Buckets
-- =====================================================

-- pickly-storage (age categories icons)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'pickly-storage',
  'pickly-storage',
  true,
  5242880, -- 5MB
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml']
)
ON CONFLICT (id) DO NOTHING;

-- benefit-banners (carousel banners)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'benefit-banners',
  'benefit-banners',
  true,
  5242880, -- 5MB
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml']
)
ON CONFLICT (id) DO NOTHING;

-- benefit-thumbnails (announcement thumbnails)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'benefit-thumbnails',
  'benefit-thumbnails',
  true,
  3145728, -- 3MB
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- benefit-icons (category icons)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'benefit-icons',
  'benefit-icons',
  true,
  1048576, -- 1MB
  ARRAY['image/png', 'image/svg+xml', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 2. RLS Policies - Public Upload & Read
-- =====================================================

-- pickly-storage policies
DROP POLICY IF EXISTS "public_upload_pickly_storage" ON storage.objects;
CREATE POLICY "public_upload_pickly_storage"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'pickly-storage');

DROP POLICY IF EXISTS "public_read_pickly_storage" ON storage.objects;
CREATE POLICY "public_read_pickly_storage"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'pickly-storage');

DROP POLICY IF EXISTS "public_update_pickly_storage" ON storage.objects;
CREATE POLICY "public_update_pickly_storage"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'pickly-storage')
WITH CHECK (bucket_id = 'pickly-storage');

DROP POLICY IF EXISTS "public_delete_pickly_storage" ON storage.objects;
CREATE POLICY "public_delete_pickly_storage"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'pickly-storage');

-- benefit-banners policies
DROP POLICY IF EXISTS "public_upload_benefit_banners" ON storage.objects;
CREATE POLICY "public_upload_benefit_banners"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'benefit-banners');

DROP POLICY IF EXISTS "public_read_benefit_banners" ON storage.objects;
CREATE POLICY "public_read_benefit_banners"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'benefit-banners');

DROP POLICY IF EXISTS "public_update_benefit_banners" ON storage.objects;
CREATE POLICY "public_update_benefit_banners"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'benefit-banners')
WITH CHECK (bucket_id = 'benefit-banners');

DROP POLICY IF EXISTS "public_delete_benefit_banners" ON storage.objects;
CREATE POLICY "public_delete_benefit_banners"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'benefit-banners');

-- benefit-thumbnails policies
DROP POLICY IF EXISTS "public_upload_benefit_thumbnails" ON storage.objects;
CREATE POLICY "public_upload_benefit_thumbnails"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'benefit-thumbnails');

DROP POLICY IF EXISTS "public_read_benefit_thumbnails" ON storage.objects;
CREATE POLICY "public_read_benefit_thumbnails"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'benefit-thumbnails');

DROP POLICY IF EXISTS "public_update_benefit_thumbnails" ON storage.objects;
CREATE POLICY "public_update_benefit_thumbnails"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'benefit-thumbnails')
WITH CHECK (bucket_id = 'benefit-thumbnails');

DROP POLICY IF EXISTS "public_delete_benefit_thumbnails" ON storage.objects;
CREATE POLICY "public_delete_benefit_thumbnails"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'benefit-thumbnails');

-- benefit-icons policies
DROP POLICY IF EXISTS "public_upload_benefit_icons" ON storage.objects;
CREATE POLICY "public_upload_benefit_icons"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'benefit-icons');

DROP POLICY IF EXISTS "public_read_benefit_icons" ON storage.objects;
CREATE POLICY "public_read_benefit_icons"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'benefit-icons');

DROP POLICY IF EXISTS "public_update_benefit_icons" ON storage.objects;
CREATE POLICY "public_update_benefit_icons"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'benefit-icons')
WITH CHECK (bucket_id = 'benefit-icons');

DROP POLICY IF EXISTS "public_delete_benefit_icons" ON storage.objects;
CREATE POLICY "public_delete_benefit_icons"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'benefit-icons');

-- Summary
DO $$
BEGIN
  RAISE NOTICE '================================================';
  RAISE NOTICE '✅ Storage Buckets Created';
  RAISE NOTICE '================================================';
  RAISE NOTICE 'Created 4 public storage buckets:';
  RAISE NOTICE '  - pickly-storage (5MB limit)';
  RAISE NOTICE '  - benefit-banners (5MB limit)';
  RAISE NOTICE '  - benefit-thumbnails (3MB limit)';
  RAISE NOTICE '  - benefit-icons (1MB limit)';
  RAISE NOTICE '';
  RAISE NOTICE 'Configured RLS policies for public access (INSERT, SELECT, UPDATE, DELETE)';
  RAISE NOTICE '================================================';
END $$;
