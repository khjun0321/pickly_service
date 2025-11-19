-- Seed data for Pickly onboarding flow
-- This file contains initial data for development and testing

-- Age Categories (6 standard categories)
-- This seed file is for reference and testing purposes

-- ================================================================
-- 고정 관리자 계정 (Admin Account)
-- ================================================================
-- 이메일: admin@pickly.com
-- 비밀번호: admin1234
--
-- 주의: 이 계정은 개발용입니다. 프로덕션에서는 반드시 변경하세요!
-- ================================================================

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

-- Test user profiles (for development)
-- Uncomment if you need test data

-- INSERT INTO user_profiles (user_id, name, age, gender, selected_categories, onboarding_step, onboarding_completed) VALUES
-- (uuid_generate_v4(), 'Test User 1', 25, 'male', ARRAY[]::UUID[], 3, false),
-- (uuid_generate_v4(), 'Test User 2', 35, 'female', ARRAY[]::UUID[], 1, false)
-- ON CONFLICT DO NOTHING;

-- ================================================================
-- Category Banners (카테고리 배너)
-- ================================================================
-- 각 복지 카테고리별 프로모션 배너 데이터
-- 모바일 앱의 혜택 화면에서 표시됩니다
-- ================================================================

-- Category banners are optional - skipping for now
-- Can be added later through admin UI
