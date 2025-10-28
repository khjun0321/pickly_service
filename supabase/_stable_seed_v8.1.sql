-- ================================================================
-- Pickly STABLE Seed Data (v8.1 - Manual Execution Only)
-- ================================================================
--
-- ⚠️  DO NOT AUTO-EXECUTE ⚠️
-- This file is for MANUAL seeding only to prevent rollback issues.
--
-- Usage:
--   psql -U postgres -d postgres -f _stable_seed_v8.1.sql
--   OR manually copy-paste into Supabase SQL editor
--
-- Protected by:
--   - .claudeignore (prevents Claude overwrites)
--   - Manual execution only (no automatic seeding)
--   - Git branch isolation (feature/fix-stable-v8.1)
--
-- ================================================================

-- ================================================================
-- 1️⃣ ADMIN ACCOUNT (STABLE)
-- ================================================================

DO $$
DECLARE
  admin_user_id UUID;
  admin_exists BOOLEAN;
BEGIN
  -- Check if admin account already exists
  SELECT EXISTS (
    SELECT 1 FROM auth.users WHERE email = 'admin@pickly.com'
  ) INTO admin_exists;

  IF admin_exists THEN
    RAISE NOTICE 'ℹ️  Admin account already exists (admin@pickly.com)';
  ELSE
    -- Create admin user in auth.users
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
    RETURNING id INTO admin_user_id;

    RAISE NOTICE '✅ Admin account created successfully';
    RAISE NOTICE '   Email: admin@pickly.com';
    RAISE NOTICE '   Password: admin1234';
    RAISE NOTICE '   ⚠️  Change this password in production!';
  END IF;

EXCEPTION
  WHEN others THEN
    RAISE WARNING '❌ Failed to create admin account: %', SQLERRM;
    RAISE NOTICE 'ℹ️  Continuing with seed data...';
END $$;

-- ================================================================
-- 2️⃣ AGE CATEGORIES (6 STABLE CATEGORIES - LOCKED)
-- ================================================================

-- STABLE AGE CATEGORIES - DO NOT MODIFY
-- These 6 categories are the single source of truth for v8.1

INSERT INTO age_categories (
  title,
  description,
  icon_component,
  icon_url,
  min_age,
  max_age,
  sort_order,
  is_active
) VALUES
  (
    '청년',
    '(만 19세-39세) 대학생, 취업준비생, 직장인',
    'bride',
    'packages/pickly_design_system/assets/icons/age_categories/bride.svg',
    19,
    39,
    1,
    true
  ),
  (
    '신혼부부·예비부부',
    '결혼 예정 또는 결혼 7년이내',
    'young_man',
    'packages/pickly_design_system/assets/icons/age_categories/young_man.svg',
    NULL,
    NULL,
    2,
    true
  ),
  (
    '육아중인 부모',
    '영유아~초등 자녀 양육 중',
    'baby',
    'packages/pickly_design_system/assets/icons/age_categories/baby.svg',
    NULL,
    NULL,
    3,
    true
  ),
  (
    '다자녀 가구',
    '자녀 2명 이상 양육중',
    'kinder',
    'packages/pickly_design_system/assets/icons/age_categories/kinder.svg',
    NULL,
    NULL,
    4,
    true
  ),
  (
    '어르신',
    '만 65세 이상',
    'old_man',
    'packages/pickly_design_system/assets/icons/age_categories/old_man.svg',
    65,
    NULL,
    5,
    true
  ),
  (
    '장애인',
    '장애인 등록 대상',
    'wheel_chair',
    'packages/pickly_design_system/assets/icons/age_categories/wheel_chair.svg',
    NULL,
    NULL,
    6,
    true
  )
ON CONFLICT (title) DO UPDATE SET
  description = EXCLUDED.description,
  icon_component = EXCLUDED.icon_component,
  icon_url = EXCLUDED.icon_url,
  min_age = EXCLUDED.min_age,
  max_age = EXCLUDED.max_age,
  sort_order = EXCLUDED.sort_order,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

-- Verify insertion
DO $$
DECLARE
  category_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO category_count FROM age_categories WHERE is_active = true;

  IF category_count = 6 THEN
    RAISE NOTICE '✅ Age categories seeded successfully: 6 categories';
  ELSE
    RAISE WARNING '⚠️  Expected 6 age categories but found %', category_count;
  END IF;
END $$;

-- ================================================================
-- 3️⃣ BENEFIT CATEGORIES (9 MAIN CATEGORIES)
-- ================================================================

INSERT INTO benefit_categories (
  title,
  slug,
  description,
  icon_url,
  sort_order,
  is_active,
  parent_id
) VALUES
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
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  sort_order = EXCLUDED.sort_order,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

-- Verify benefit categories
DO $$
DECLARE
  category_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO category_count FROM benefit_categories WHERE is_active = true;

  IF category_count >= 9 THEN
    RAISE NOTICE '✅ Benefit categories seeded successfully: % categories', category_count;
  ELSE
    RAISE WARNING '⚠️  Expected at least 9 benefit categories but found %', category_count;
  END IF;
END $$;

-- ================================================================
-- 4️⃣ CATEGORY BANNERS (12 SAMPLE BANNERS)
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
  -- Get category IDs using slug
  SELECT id INTO housing_id FROM benefit_categories WHERE slug = 'housing';
  SELECT id INTO welfare_id FROM benefit_categories WHERE slug = 'welfare';
  SELECT id INTO education_id FROM benefit_categories WHERE slug = 'education';
  SELECT id INTO employment_id FROM benefit_categories WHERE slug = 'employment';
  SELECT id INTO health_id FROM benefit_categories WHERE slug = 'health';
  SELECT id INTO culture_id FROM benefit_categories WHERE slug = 'culture';

  -- Insert sample banners
  INSERT INTO category_banners (
    benefit_category_id,
    title,
    subtitle,
    image_url,
    link_type,
    link_target,
    sort_order,
    is_active
  ) VALUES
    -- 주거 배너
    (housing_id, '청년 주거 지원', '월세 최대 30만원 지원', 'https://picsum.photos/seed/housing1/800/400', 'internal', '/benefits/housing/youth-housing', 0, true),
    (housing_id, '전세자금 대출', '무이자 전세자금 대출 안내', 'https://picsum.photos/seed/housing2/800/400', 'internal', '/benefits/housing/jeonse-loan', 1, true),

    -- 복지 배너
    (welfare_id, '다자녀 가구 혜택', '자녀 3명 이상 가구 지원', 'https://picsum.photos/seed/welfare1/800/400', 'internal', '/benefits/welfare/multi-child', 0, true),
    (welfare_id, '어르신 복지', '65세 이상 종합 복지 안내', 'https://picsum.photos/seed/welfare2/800/400', 'internal', '/benefits/welfare/senior', 1, true),

    -- 교육 배너
    (education_id, '학자금 지원', '대학생 등록금 지원 프로그램', 'https://picsum.photos/seed/education1/800/400', 'internal', '/benefits/education/scholarship', 0, true),
    (education_id, '직업 훈련', '무료 직업훈련 과정 안내', 'https://picsum.photos/seed/education2/800/400', 'internal', '/benefits/education/training', 1, true),

    -- 취업 배너
    (employment_id, '청년 일자리', '청년 취업 지원금 최대 300만원', 'https://picsum.photos/seed/employment1/800/400', 'internal', '/benefits/employment/youth-job', 0, true),
    (employment_id, '창업 지원', '초기 창업자 지원 프로그램', 'https://picsum.photos/seed/employment2/800/400', 'internal', '/benefits/employment/startup', 1, true),

    -- 건강 배너
    (health_id, '건강검진 지원', '무료 종합 건강검진', 'https://picsum.photos/seed/health1/800/400', 'internal', '/benefits/health/checkup', 0, true),
    (health_id, '의료비 지원', '저소득층 의료비 지원 안내', 'https://picsum.photos/seed/health2/800/400', 'internal', '/benefits/health/medical', 1, true),

    -- 문화 배너
    (culture_id, '문화누리카드', '연간 11만원 문화비 지원', 'https://picsum.photos/seed/culture1/800/400', 'internal', '/benefits/culture/card', 0, true),
    (culture_id, '공연 할인', '청년 공연 50% 할인', 'https://picsum.photos/seed/culture2/800/400', 'internal', '/benefits/culture/performance', 1, true)
  ON CONFLICT DO NOTHING;

  RAISE NOTICE '✅ Category banners seeded successfully';

EXCEPTION
  WHEN others THEN
    RAISE WARNING '❌ Failed to seed category banners: %', SQLERRM;
END $$;

-- ================================================================
-- ✅ STABLE SEEDING COMPLETE
-- ================================================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '================================================================';
  RAISE NOTICE '✅ Pickly v8.1 STABLE Seed Completed Successfully!';
  RAISE NOTICE '================================================================';
  RAISE NOTICE '';
  RAISE NOTICE '🔒 PROTECTION STATUS:';
  RAISE NOTICE '   • This file is protected by .claudeignore';
  RAISE NOTICE '   • Manual execution only (no automatic seeding)';
  RAISE NOTICE '   • Git branch isolation: feature/fix-stable-v8.1';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Data Summary:';
  RAISE NOTICE '   • Admin account: admin@pickly.com (password: admin1234)';
  RAISE NOTICE '   • Age categories: 6 categories (LOCKED)';
  RAISE NOTICE '   • Benefit categories: 9 categories';
  RAISE NOTICE '   • Category banners: 12 sample banners';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  Remember to change admin password in production!';
  RAISE NOTICE '================================================================';
END $$;
