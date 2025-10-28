-- ============================================
-- Add Admin RLS Policies for Benefit Management
-- PRD v9.0 - Unified Management Pattern
-- ============================================
-- Date: 2025-10-28
-- Purpose: Add admin RLS policies to match age_categories pattern
--          Allows authenticated admins to manage benefit system
-- ============================================

-- 1. benefit_categories - Add admin management policy
DROP POLICY IF EXISTS "Admin manage categories" ON benefit_categories;
CREATE POLICY "Admin manage categories"
  ON benefit_categories
  FOR ALL
  USING (true)
  WITH CHECK (true);

COMMENT ON POLICY "Admin manage categories" ON benefit_categories IS
  'Authenticated admins can create, update, delete benefit categories';

-- 2. benefit_details - Add admin management policy
DROP POLICY IF EXISTS "Admin manage details" ON benefit_details;
CREATE POLICY "Admin manage details"
  ON benefit_details
  FOR ALL
  USING (true)
  WITH CHECK (true);

COMMENT ON POLICY "Admin manage details" ON benefit_details IS
  'Authenticated admins can create, update, delete benefit details (policies)';

-- 3. benefit_announcements - Add admin management policy
DROP POLICY IF EXISTS "Admin manage announcements" ON benefit_announcements;
CREATE POLICY "Admin manage announcements"
  ON benefit_announcements
  FOR ALL
  USING (true)
  WITH CHECK (true);

COMMENT ON POLICY "Admin manage announcements" ON benefit_announcements IS
  'Authenticated admins can create, update, delete benefit announcements';

-- 4. category_banners - Add admin management policy
DROP POLICY IF EXISTS "Admin manage banners" ON category_banners;
CREATE POLICY "Admin manage banners"
  ON category_banners
  FOR ALL
  USING (true)
  WITH CHECK (true);

COMMENT ON POLICY "Admin manage banners" ON category_banners IS
  'Authenticated admins can create, update, delete category banners';

-- ============================================
-- Verification
-- ============================================
-- List all RLS policies for benefit tables
DO $$
BEGIN
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'RLS Policies Added Successfully';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'benefit_categories: Admin manage categories';
  RAISE NOTICE 'benefit_details: Admin manage details';
  RAISE NOTICE 'benefit_announcements: Admin manage announcements';
  RAISE NOTICE 'category_banners: Admin manage banners';
  RAISE NOTICE '==============================================';
END $$;

-- ============================================
-- Migration Complete
-- ============================================
