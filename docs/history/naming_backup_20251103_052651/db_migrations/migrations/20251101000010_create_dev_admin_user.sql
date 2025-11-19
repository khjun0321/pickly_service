-- ================================================================
-- Migration: 20251101000010_create_dev_admin_user
-- Description: Create dev@pickly.com admin user for testing
-- Purpose: Enable Admin login with authenticated role
-- Date: 2025-11-01
-- ================================================================

-- Insert dev@pickly.com user into auth.users
-- ================================================================

INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'dev@pickly.com',
  crypt('pickly2025!', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{}',
  now(),
  now(),
  '',
  '',
  '',
  ''
) ON CONFLICT DO NOTHING;

-- Insert identity record
-- ================================================================

INSERT INTO auth.identities (
  id,
  user_id,
  identity_data,
  provider,
  last_sign_in_at,
  created_at,
  updated_at
) SELECT
  gen_random_uuid(),
  id,
  jsonb_build_object('sub', id::text, 'email', 'dev@pickly.com'),
  'email',
  now(),
  now(),
  now()
FROM auth.users
WHERE email = 'dev@pickly.com'
  AND NOT EXISTS (
    SELECT 1 FROM auth.identities
    WHERE provider = 'email'
      AND user_id = (SELECT id FROM auth.users WHERE email = 'dev@pickly.com' LIMIT 1)
  );

-- Verification
-- ================================================================

DO $$
DECLARE
  user_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO user_count
  FROM auth.users
  WHERE email = 'dev@pickly.com' AND role = 'authenticated';

  IF user_count > 0 THEN
    RAISE NOTICE '╔═══════════════════════════════════════════════╗';
    RAISE NOTICE '║  ✅ Migration 20251101000010 Complete         ║';
    RAISE NOTICE '║  👤 User: dev@pickly.com                      ║';
    RAISE NOTICE '║  🔑 Password: pickly2025!                     ║';
    RAISE NOTICE '║  ✅ Role: authenticated                       ║';
    RAISE NOTICE '║  ✅ Email confirmed: YES                      ║';
    RAISE NOTICE '║  ✅ Ready for Admin login                     ║';
    RAISE NOTICE '╚═══════════════════════════════════════════════╝';
  ELSE
    RAISE WARNING '⚠️  User creation may have failed';
  END IF;
END $$;

-- Display created user
SELECT
  email,
  role,
  email_confirmed_at IS NOT NULL AS email_confirmed,
  created_at
FROM auth.users
WHERE email = 'dev@pickly.com';
