-- ================================================================
-- Migration: Create benefit-images storage bucket
-- File: 20251024000004_create_benefit_images_bucket.sql
-- Description: Create public storage bucket for benefit banners and images
-- ================================================================

-- Create benefit-images bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('benefit-images', 'benefit-images', true)
ON CONFLICT (id) DO NOTHING;

-- Allow public read access
CREATE POLICY "Public read access for benefit images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'benefit-images');

-- Allow authenticated users to upload
CREATE POLICY "Authenticated users can upload benefit images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'benefit-images');

-- Allow authenticated users to update their uploads
CREATE POLICY "Authenticated users can update benefit images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'benefit-images')
WITH CHECK (bucket_id = 'benefit-images');

-- Allow authenticated users to delete
CREATE POLICY "Authenticated users can delete benefit images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'benefit-images');

-- Completion log
DO $$
BEGIN
    RAISE NOTICE 'Migration 20251024000004_create_benefit_images_bucket.sql completed successfully';
    RAISE NOTICE 'Created public storage bucket: benefit-images';
    RAISE NOTICE 'Set up RLS policies for authenticated uploads and public reads';
END $$;
