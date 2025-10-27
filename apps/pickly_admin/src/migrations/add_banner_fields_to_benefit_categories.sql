-- Add banner fields to benefit_categories table
-- Migration: Add banner_image_url and banner_link_url columns

ALTER TABLE benefit_categories
ADD COLUMN IF NOT EXISTS banner_image_url TEXT,
ADD COLUMN IF NOT EXISTS banner_link_url TEXT;

-- Add comments for documentation
COMMENT ON COLUMN benefit_categories.banner_image_url IS 'URL of the banner image stored in Supabase Storage (banners/{category_id}/)';
COMMENT ON COLUMN benefit_categories.banner_link_url IS 'URL to navigate when banner is clicked (optional)';

-- Create storage bucket if it doesn't exist (run this in Supabase Dashboard or via SQL)
-- INSERT INTO storage.buckets (id, name, public)
-- VALUES ('pickly-storage', 'pickly-storage', true)
-- ON CONFLICT (id) DO NOTHING;

-- Create storage policy for banner uploads (public read access)
-- CREATE POLICY "Public banner images are publicly accessible"
-- ON storage.objects FOR SELECT
-- USING (bucket_id = 'pickly-storage' AND (storage.foldername(name))[1] = 'banners');

-- Create storage policy for authenticated uploads
-- CREATE POLICY "Authenticated users can upload banners"
-- ON storage.objects FOR INSERT
-- WITH CHECK (bucket_id = 'pickly-storage' AND (storage.foldername(name))[1] = 'banners' AND auth.role() = 'authenticated');

-- Create storage policy for authenticated updates
-- CREATE POLICY "Authenticated users can update banners"
-- ON storage.objects FOR UPDATE
-- USING (bucket_id = 'pickly-storage' AND (storage.foldername(name))[1] = 'banners' AND auth.role() = 'authenticated');
