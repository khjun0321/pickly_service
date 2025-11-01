-- Create storage buckets for PRD v7.3 Benefit Management System
-- Buckets: benefit-banners, benefit-thumbnails, benefit-icons

-- Create benefit-banners bucket (카테고리 배너 이미지)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'benefit-banners',
  'benefit-banners',
  true,
  5242880, -- 5MB in bytes
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']::text[]
)
ON CONFLICT (id) DO NOTHING;

-- Create benefit-thumbnails bucket (공고 썸네일 이미지)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'benefit-thumbnails',
  'benefit-thumbnails',
  true,
  3145728, -- 3MB in bytes
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']::text[]
)
ON CONFLICT (id) DO NOTHING;

-- Create benefit-icons bucket (혜택 카테고리 아이콘)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'benefit-icons',
  'benefit-icons',
  true,
  1048576, -- 1MB in bytes
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/svg+xml', 'image/webp']::text[]
)
ON CONFLICT (id) DO NOTHING;

-- RLS Policies for benefit-banners
-- Public read access
CREATE POLICY "Public read access for benefit-banners"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'benefit-banners');

-- Authenticated users can upload
CREATE POLICY "Authenticated users can upload benefit-banners"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'benefit-banners');

-- Authenticated users can update
CREATE POLICY "Authenticated users can update benefit-banners"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'benefit-banners');

-- Authenticated users can delete
CREATE POLICY "Authenticated users can delete benefit-banners"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'benefit-banners');

-- RLS Policies for benefit-thumbnails
CREATE POLICY "Public read access for benefit-thumbnails"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'benefit-thumbnails');

CREATE POLICY "Authenticated users can upload benefit-thumbnails"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'benefit-thumbnails');

CREATE POLICY "Authenticated users can update benefit-thumbnails"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'benefit-thumbnails');

CREATE POLICY "Authenticated users can delete benefit-thumbnails"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'benefit-thumbnails');

-- RLS Policies for benefit-icons
CREATE POLICY "Public read access for benefit-icons"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'benefit-icons');

CREATE POLICY "Authenticated users can upload benefit-icons"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'benefit-icons');

CREATE POLICY "Authenticated users can update benefit-icons"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'benefit-icons');

CREATE POLICY "Authenticated users can delete benefit-icons"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'benefit-icons');
