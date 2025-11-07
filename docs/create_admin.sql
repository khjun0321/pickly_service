-- Create admin user with proper auth schema
DELETE FROM auth.users WHERE email = 'admin@pickly.com';
DELETE FROM auth.identities WHERE provider_id IN (
  SELECT id::text FROM auth.users WHERE email = 'admin@pickly.com'
);

-- Insert admin user
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
  'admin@pickly.com',
  crypt('pickly2025!', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{"role":"admin","full_name":"Admin User"}'::jsonb,
  now(),
  now(),
  '',
  '',
  '',
  ''
) RETURNING id, email;

-- Insert identity
INSERT INTO auth.identities (
  provider_id,
  user_id,
  identity_data,
  provider,
  last_sign_in_at,
  created_at,
  updated_at
) SELECT
  id::text,
  id,
  jsonb_build_object(
    'sub', id::text,
    'email', 'admin@pickly.com',
    'email_verified', true,
    'provider', 'email'
  ),
  'email',
  now(),
  now(),
  now()
FROM auth.users WHERE email = 'admin@pickly.com';
