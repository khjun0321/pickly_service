-- Cleanup duplicate RLS policies on category_banners

-- Drop old policies
DROP POLICY IF EXISTS "Public can view active banners" ON category_banners;
DROP POLICY IF EXISTS "Admins can manage banners" ON category_banners;

-- Ensure we have the simple policies for admin-only management
-- The "Anyone can..." policies were created in previous migration
-- This just cleans up the old conflicting policies

COMMENT ON TABLE category_banners IS 'Category banners - Admin backoffice only, RLS policies allow full access for development';
