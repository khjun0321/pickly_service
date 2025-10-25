-- Seed data for Pickly onboarding flow
-- This file contains initial data for development and testing

-- Age Categories (6 standard categories)
-- Note: These are also created in migration 20251010000000_age_categories_update.sql
-- This seed file is for reference and testing purposes

INSERT INTO age_categories (title, description, icon_component, icon_url, min_age, max_age, sort_order, is_active) VALUES
('유아', '(0~7세) 영유아 및 미취학 아동', 'baby', 'packages/pickly_design_system/assets/icons/age_categories/baby.svg', 0, 7, 1, true),
('어린이', '(8~13세) 초등학생', 'kinder', 'packages/pickly_design_system/assets/icons/age_categories/kinder.svg', 8, 13, 2, true),
('청소년', '(14~19세) 중고등학생', 'young_man', 'packages/pickly_design_system/assets/icons/age_categories/young_man.svg', 14, 19, 3, true),
('청년', '(20~34세) 대학생, 취업준비생, 직장인', 'bride', 'packages/pickly_design_system/assets/icons/age_categories/bride.svg', 20, 34, 4, true),
('중년', '(35~49세) 중장년층', 'old_man', 'packages/pickly_design_system/assets/icons/age_categories/old_man.svg', 35, 49, 5, true),
('노년', '(50세 이상) 장년 및 어르신', 'wheel_chair', 'packages/pickly_design_system/assets/icons/age_categories/wheel_chair.svg', 50, NULL, 6, true)
ON CONFLICT DO NOTHING;

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
-- Benefit Categories (혜택 카테고리)
-- ================================================================
-- Note: These are created in migration 20251025080000_reorder_categories.sql
-- App order: 인기, 주거, 교육, 건강, 교통, 복지, 취업, 지원, 문화
-- This seed ensures they exist in the correct order
-- ================================================================

INSERT INTO benefit_categories (name, slug, description, icon_url, display_order, is_active, parent_id) VALUES
('인기', 'popular', '가장 인기있는 혜택 모음', NULL, 0, true, NULL),
('주거', 'housing', '주거 관련 혜택 및 지원', NULL, 1, true, NULL),
('교육', 'education', '교육 관련 혜택 및 지원', NULL, 2, true, NULL),
('건강', 'health', '건강 관련 혜택 및 지원', NULL, 3, true, NULL),
('교통', 'transportation', '교통비 지원 및 할인', NULL, 4, true, NULL),
('복지', 'welfare', '복지 관련 혜택 및 지원', NULL, 5, true, NULL),
('취업', 'employment', '취업 관련 혜택 및 지원', NULL, 6, true, NULL),
('지원', 'support', '각종 지원금 및 보조금', NULL, 7, true, NULL),
('문화', 'culture', '문화 관련 혜택 및 지원', NULL, 8, true, NULL)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_order = EXCLUDED.display_order,
  is_active = EXCLUDED.is_active;

-- ================================================================
-- Category Banners (카테고리 배너)
-- ================================================================
-- 각 복지 카테고리별 프로모션 배너 데이터
-- 모바일 앱의 혜택 화면에서 표시됩니다
-- ================================================================

DO $$
DECLARE
    housing_id UUID;
    welfare_id UUID;
    education_id UUID;
    employment_id UUID;
    health_id UUID;
    culture_id UUID;
BEGIN
    -- Get category IDs
    SELECT id INTO housing_id FROM benefit_categories WHERE slug = 'housing';
    SELECT id INTO welfare_id FROM benefit_categories WHERE slug = 'welfare';
    SELECT id INTO education_id FROM benefit_categories WHERE slug = 'education';
    SELECT id INTO employment_id FROM benefit_categories WHERE slug = 'employment';
    SELECT id INTO health_id FROM benefit_categories WHERE slug = 'health';
    SELECT id INTO culture_id FROM benefit_categories WHERE slug = 'culture';

    -- Insert sample banners for each category
    INSERT INTO category_banners (category_id, title, subtitle, image_url, background_color, action_url, display_order, is_active) VALUES
    -- 주거 배너
    (housing_id, '청년 주거 지원', '월세 최대 30만원 지원', 'https://picsum.photos/seed/housing1/800/400', '#E3F2FD', '/benefits/housing/youth-housing', 1, true),
    (housing_id, '전세자금 대출', '무이자 전세자금 대출 안내', 'https://picsum.photos/seed/housing2/800/400', '#E8F5E9', '/benefits/housing/jeonse-loan', 2, true),

    -- 복지 배너
    (welfare_id, '다자녀 가구 혜택', '자녀 3명 이상 가구 지원', 'https://picsum.photos/seed/welfare1/800/400', '#FFF3E0', '/benefits/welfare/multi-child', 1, true),
    (welfare_id, '어르신 복지', '65세 이상 종합 복지 안내', 'https://picsum.photos/seed/welfare2/800/400', '#F3E5F5', '/benefits/welfare/senior', 2, true),

    -- 교육 배너
    (education_id, '학자금 지원', '대학생 등록금 지원 프로그램', 'https://picsum.photos/seed/education1/800/400', '#E1F5FE', '/benefits/education/scholarship', 1, true),
    (education_id, '직업 훈련', '무료 직업훈련 과정 안내', 'https://picsum.photos/seed/education2/800/400', '#FFF9C4', '/benefits/education/training', 2, true),

    -- 취업 배너
    (employment_id, '청년 일자리', '청년 취업 지원금 최대 300만원', 'https://picsum.photos/seed/employment1/800/400', '#E8EAF6', '/benefits/employment/youth-job', 1, true),
    (employment_id, '창업 지원', '초기 창업자 지원 프로그램', 'https://picsum.photos/seed/employment2/800/400', '#FCE4EC', '/benefits/employment/startup', 2, true),

    -- 건강 배너
    (health_id, '건강검진 지원', '무료 종합 건강검진', 'https://picsum.photos/seed/health1/800/400', '#F1F8E9', '/benefits/health/checkup', 1, true),
    (health_id, '의료비 지원', '저소득층 의료비 지원 안내', 'https://picsum.photos/seed/health2/800/400', '#E0F2F1', '/benefits/health/medical', 2, true),

    -- 문화 배너
    (culture_id, '문화누리카드', '연간 11만원 문화비 지원', 'https://picsum.photos/seed/culture1/800/400', '#F3E5F5', '/benefits/culture/card', 1, true),
    (culture_id, '공연 할인', '청년 공연 50% 할인', 'https://picsum.photos/seed/culture2/800/400', '#FFF3E0', '/benefits/culture/performance', 2, true)
    ON CONFLICT DO NOTHING;

    RAISE NOTICE '✅ Category banners inserted successfully';

EXCEPTION
    WHEN others THEN
        RAISE NOTICE '❌ Failed to insert category banners: %', SQLERRM;
END $$;
