-- ============================================
-- Migration: Create benefit-images and benefit-documents Storage Buckets
-- PRD v9.15.0 - Benefit Announcement Storage
-- Purpose: Create Storage buckets for benefit announcement files
-- Date: 2025-11-15
-- ============================================

-- ============================================
-- 1️⃣ Create benefit-images bucket
-- ============================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'benefit-images',
  'benefit-images',
  true,                                      -- Public read access
  10485760,                                  -- 10MB file size limit
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif']::text[]
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 10485760,
  allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif']::text[];

-- ============================================
-- 2️⃣ Create benefit-documents bucket
-- ============================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'benefit-documents',
  'benefit-documents',
  true,                                      -- Public read access
  20971520,                                  -- 20MB file size limit
  ARRAY['application/pdf']::text[]
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 20971520,
  allowed_mime_types = ARRAY['application/pdf']::text[];

-- ============================================
-- 3️⃣ RLS Policies for benefit-images bucket
-- ============================================

-- Policy 1: Public read access (anyone can view images)
DROP POLICY IF EXISTS "benefit images read public" ON storage.objects;
CREATE POLICY "benefit images read public"
  ON storage.objects
  FOR SELECT
  TO public
  USING (bucket_id = 'benefit-images');

-- Policy 2: Authenticated users can upload images
DROP POLICY IF EXISTS "benefit images write auth" ON storage.objects;
CREATE POLICY "benefit images write auth"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'benefit-images'
    AND auth.role() = 'authenticated'
  );

-- Policy 3: Authenticated users can update images
DROP POLICY IF EXISTS "benefit images update auth" ON storage.objects;
CREATE POLICY "benefit images update auth"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'benefit-images'
    AND auth.role() = 'authenticated'
  );

-- Policy 4: Authenticated users can delete images
DROP POLICY IF EXISTS "benefit images delete auth" ON storage.objects;
CREATE POLICY "benefit images delete auth"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'benefit-images'
    AND auth.role() = 'authenticated'
  );

-- ============================================
-- 4️⃣ RLS Policies for benefit-documents bucket
-- ============================================

-- Policy 1: Public read access (anyone can view PDFs)
DROP POLICY IF EXISTS "benefit docs read public" ON storage.objects;
CREATE POLICY "benefit docs read public"
  ON storage.objects
  FOR SELECT
  TO public
  USING (bucket_id = 'benefit-documents');

-- Policy 2: Authenticated users can upload documents
DROP POLICY IF EXISTS "benefit docs write auth" ON storage.objects;
CREATE POLICY "benefit docs write auth"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'benefit-documents'
    AND auth.role() = 'authenticated'
  );

-- Policy 3: Authenticated users can update documents
DROP POLICY IF EXISTS "benefit docs update auth" ON storage.objects;
CREATE POLICY "benefit docs update auth"
  ON storage.objects
  FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'benefit-documents'
    AND auth.role() = 'authenticated'
  );

-- Policy 4: Authenticated users can delete documents
DROP POLICY IF EXISTS "benefit docs delete auth" ON storage.objects;
CREATE POLICY "benefit docs delete auth"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'benefit-documents'
    AND auth.role() = 'authenticated'
  );

-- ============================================
-- ✅ Storage Buckets Configuration Complete
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '==============================================';
  RAISE NOTICE '✅ Benefit Storage Buckets Created';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '📦 Bucket 1: benefit-images';
  RAISE NOTICE '   - Public: true (read access)';
  RAISE NOTICE '   - Max Size: 10MB';
  RAISE NOTICE '   - MIME Types: JPEG, PNG, WebP, GIF';
  RAISE NOTICE '   - Folders: thumbnails/, floor-plans/';
  RAISE NOTICE '';
  RAISE NOTICE '📦 Bucket 2: benefit-documents';
  RAISE NOTICE '   - Public: true (read access)';
  RAISE NOTICE '   - Max Size: 20MB';
  RAISE NOTICE '   - MIME Types: PDF';
  RAISE NOTICE '   - Folders: pdfs/';
  RAISE NOTICE '';
  RAISE NOTICE '🔒 RLS Policies:';
  RAISE NOTICE '   - Public: SELECT (read)';
  RAISE NOTICE '   - Authenticated: INSERT, UPDATE, DELETE (write)';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '📝 Usage Example:';
  RAISE NOTICE '   Thumbnail: benefit-images/thumbnails/{timestamp}.jpg';
  RAISE NOTICE '   Floor Plan: benefit-images/floor-plans/{timestamp}.png';
  RAISE NOTICE '   PDF: benefit-documents/pdfs/{timestamp}.pdf';
  RAISE NOTICE '==============================================';
END $$;
