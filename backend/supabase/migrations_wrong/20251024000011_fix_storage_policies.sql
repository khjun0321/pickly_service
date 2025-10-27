-- Fix storage policies for benefit-images bucket
-- Allow ALL users (including anon) to upload during development

-- Drop existing policies
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access" ON storage.objects;

-- Allow anyone to upload to benefit-images bucket (for development)
CREATE POLICY "Allow all uploads to benefit-images"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'benefit-images');

-- Allow anyone to update files in benefit-images bucket
CREATE POLICY "Allow all updates to benefit-images"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'benefit-images');

-- Allow anyone to delete from benefit-images bucket
CREATE POLICY "Allow all deletes from benefit-images"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'benefit-images');

-- Allow public read access
CREATE POLICY "Allow public read access to benefit-images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'benefit-images');

-- Also update benefit_banners RLS to allow all operations during development
DROP POLICY IF EXISTS "Enable all operations for authenticated users" ON benefit_banners;
DROP POLICY IF EXISTS "Enable read access for anon users" ON benefit_banners;

-- Allow all operations for everyone (development mode)
CREATE POLICY "Allow all operations for everyone"
ON benefit_banners
FOR ALL
TO public
USING (true)
WITH CHECK (true);
