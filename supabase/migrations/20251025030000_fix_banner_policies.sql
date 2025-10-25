-- Fix category_banners RLS policies for admin access
-- Allow all users (including anon) to manage banners

-- Drop existing policies
DROP POLICY IF EXISTS "Public read access to banners" ON category_banners;
DROP POLICY IF EXISTS "Authenticated users can manage banners" ON category_banners;

-- Create new policies
-- Public can read all banners
CREATE POLICY "Anyone can read banners"
ON category_banners FOR SELECT
USING (true);

-- Anyone can insert banners (for admin backoffice)
CREATE POLICY "Anyone can insert banners"
ON category_banners FOR INSERT
WITH CHECK (true);

-- Anyone can update banners
CREATE POLICY "Anyone can update banners"
ON category_banners FOR UPDATE
USING (true);

-- Anyone can delete banners
CREATE POLICY "Anyone can delete banners"
ON category_banners FOR DELETE
USING (true);

COMMENT ON TABLE category_banners IS 'Category banners for mobile app - Admin managed only';
