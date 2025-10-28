-- Admin Account Seed Data (v8.1)
--
-- Creates a fixed admin account for development purposes.
--
-- ⚠️  SECURITY WARNING ⚠️
-- Email: admin@pickly.com
-- Password: admin1234
--
-- This account is for DEVELOPMENT ONLY.
-- Change the password immediately in production!

DO $$
DECLARE
  admin_user_id UUID;
BEGIN
  -- Create admin user in auth.users
  -- Password is hashed using Supabase's encryption (admin1234)
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    invited_at,
    confirmation_token,
    confirmation_sent_at,
    recovery_token,
    recovery_sent_at,
    email_change_token_new,
    email_change,
    email_change_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    created_at,
    updated_at,
    phone,
    phone_confirmed_at,
    phone_change,
    phone_change_token,
    phone_change_sent_at,
    email_change_token_current,
    email_change_confirm_status,
    banned_until,
    reauthentication_token,
    reauthentication_sent_at,
    is_sso_user,
    deleted_at
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'admin@pickly.com',
    crypt('admin1234', gen_salt('bf')),
    NOW(),
    NOW(),
    '',
    NOW(),
    '',
    NOW(),
    '',
    '',
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}',
    '{}',
    NULL,
    NOW(),
    NOW(),
    NULL,
    NULL,
    '',
    '',
    NOW(),
    '',
    0,
    NOW(),
    '',
    NOW(),
    false,
    NULL
  )
  ON CONFLICT (email) DO NOTHING
  RETURNING id INTO admin_user_id;

  -- Log the admin user creation
  IF admin_user_id IS NOT NULL THEN
    RAISE NOTICE '✅ Admin account created successfully';
    RAISE NOTICE '   Email: admin@pickly.com';
    RAISE NOTICE '   Password: admin1234';
    RAISE NOTICE '   ⚠️  Change this password in production!';
  ELSE
    RAISE NOTICE 'ℹ️  Admin account already exists';
  END IF;

EXCEPTION
  WHEN others THEN
    RAISE NOTICE '❌ Failed to create admin account: %', SQLERRM;
END $$;
