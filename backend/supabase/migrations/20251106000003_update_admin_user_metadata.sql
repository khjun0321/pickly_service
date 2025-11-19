-- ================================================================
-- Migration: 20251106000003_update_admin_user_metadata
-- Description: Add user_role='admin' to admin user accounts
-- PRD: v9.6.2 — Admin Metadata Setup
-- Date: 2025-11-06
-- ================================================================

-- Purpose:
-- Add user_role='admin' to app_metadata for admin accounts
-- This enables role-based RLS policies to recognize admin users

-- ================================================================
-- Step 1: Update Existing Admin Users
-- ================================================================

-- Update admin@pickly.com (if exists)
UPDATE auth.users
SET raw_app_meta_data =
  COALESCE(raw_app_meta_data, '{}'::jsonb) ||
  '{"user_role": "admin"}'::jsonb
WHERE email = 'admin@pickly.com';

-- Update dev@pickly.com (if exists)
UPDATE auth.users
SET raw_app_meta_data =
  COALESCE(raw_app_meta_data, '{}'::jsonb) ||
  '{"user_role": "admin"}'::jsonb
WHERE email = 'dev@pickly.com';

-- ================================================================
-- Step 2: Verification
-- ================================================================

DO $$
DECLARE
  admin_count INTEGER;
  admin_users TEXT;
BEGIN
  -- Count admin users
  SELECT COUNT(*) INTO admin_count
  FROM auth.users
  WHERE raw_app_meta_data->>'user_role' = 'admin';

  -- Get admin user emails
  SELECT string_agg(email, ', ') INTO admin_users
  FROM auth.users
  WHERE raw_app_meta_data->>'user_role' = 'admin';

  RAISE NOTICE '📊 Admin Users Configuration:';
  RAISE NOTICE '  Total admin users: %', admin_count;
  RAISE NOTICE '  Admin emails: %', COALESCE(admin_users, '(none)');

  IF admin_count = 0 THEN
    RAISE WARNING '⚠️ No admin users found! You may need to manually set user_role in Supabase Studio.';
  ELSE
    RAISE NOTICE '✅ Admin user metadata updated successfully';
  END IF;
END $$;

-- ================================================================
-- Manual Steps (if no admin users exist yet)
-- ================================================================
/*
If the verification above shows 0 admin users:

1. Go to Supabase Studio → Authentication → Users
2. Click on your admin user
3. Scroll to "App Metadata" section
4. Click "Edit"
5. Add the following JSON:
   {
     "user_role": "admin"
   }
6. Click "Save"

Alternatively, run this SQL after creating an admin user:
UPDATE auth.users
SET raw_app_meta_data = '{"user_role": "admin"}'::jsonb
WHERE email = 'your-admin@example.com';
*/

-- ================================================================
-- Test Query (Run after migration)
-- ================================================================
/*
-- Verify admin users
SELECT
  id,
  email,
  raw_app_meta_data->>'user_role' as role,
  created_at,
  email_confirmed_at
FROM auth.users
WHERE raw_app_meta_data->>'user_role' = 'admin';
*/
