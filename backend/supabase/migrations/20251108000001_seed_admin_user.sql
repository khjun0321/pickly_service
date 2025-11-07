-- ============================================================================
-- Migration: 20251108000001_seed_admin_user.sql
-- Version: PRD v9.9.0 Hotfix
-- Purpose: Create development admin account if missing
--
-- Credentials:
-- Email: admin@pickly.com
-- Password: pickly2025!
--
-- This migration is idempotent and safe to run multiple times.
-- ============================================================================

DO $$
DECLARE
  admin_user_id uuid;
BEGIN
  -- Check if admin user already exists
  SELECT id INTO admin_user_id
  FROM auth.users
  WHERE email = 'admin@pickly.com';

  -- Only create if doesn't exist
  IF admin_user_id IS NULL THEN
    -- Generate new UUID for admin user
    admin_user_id := gen_random_uuid();

    -- Insert into auth.users table
    INSERT INTO auth.users (
      id,
      instance_id,
      email,
      encrypted_password,
      email_confirmed_at,
      created_at,
      updated_at,
      confirmation_sent_at,
      raw_app_meta_data,
      raw_user_meta_data,
      aud,
      role,
      is_super_admin
    ) VALUES (
      admin_user_id,
      '00000000-0000-0000-0000-000000000000',
      'admin@pickly.com',
      crypt('pickly2025!', gen_salt('bf')),  -- bcrypt password hash
      now(),  -- Email confirmed immediately
      now(),
      now(),
      now(),
      jsonb_build_object(
        'provider', 'email',
        'providers', array['email']
      ),
      jsonb_build_object(
        'role', 'admin',
        'full_name', 'Admin User'
      ),
      'authenticated',
      'authenticated',
      false
    );

    -- Insert into auth.identities table (required for email/password auth)
    -- Note: 'email' column is generated, so we don't insert it
    INSERT INTO auth.identities (
      provider_id,
      user_id,
      identity_data,
      provider,
      last_sign_in_at,
      created_at,
      updated_at
    ) VALUES (
      admin_user_id::text,  -- provider_id must match user_id for email provider
      admin_user_id,
      jsonb_build_object(
        'sub', admin_user_id::text,
        'email', 'admin@pickly.com',
        'email_verified', true,
        'provider', 'email'
      ),
      'email',
      now(),
      now(),
      now()
    );

    RAISE NOTICE '✅ Admin user created successfully: admin@pickly.com';
    RAISE NOTICE '📧 Email: admin@pickly.com';
    RAISE NOTICE '🔑 Password: pickly2025!';
    RAISE NOTICE '👤 User ID: %', admin_user_id;
  ELSE
    RAISE NOTICE '⚠️  Admin user already exists: admin@pickly.com (ID: %)', admin_user_id;
  END IF;

  -- Verify user was created/exists
  PERFORM 1 FROM auth.users WHERE email = 'admin@pickly.com';

  IF FOUND THEN
    RAISE NOTICE '✅ Admin user verification: PASS';
  ELSE
    RAISE EXCEPTION 'Admin user creation failed!';
  END IF;
END $$;

-- Grant necessary permissions (if needed)
-- Note: Supabase handles most permissions automatically

-- Log completion
DO $$
BEGIN
  RAISE NOTICE '╔═══════════════════════════════════════════╗';
  RAISE NOTICE '║  ✅ Migration 20251108000001 Complete     ║';
  RAISE NOTICE '║  📧 Admin: admin@pickly.com               ║';
  RAISE NOTICE '║  🔑 Password: pickly2025!                 ║';
  RAISE NOTICE '║  ⚙️  Purpose: Dev admin account seed      ║';
  RAISE NOTICE '╚═══════════════════════════════════════════╝';
END $$;
