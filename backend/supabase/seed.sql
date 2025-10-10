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

-- Test user profiles (for development)
-- Uncomment if you need test data

-- INSERT INTO user_profiles (user_id, name, age, gender, selected_categories, onboarding_step, onboarding_completed) VALUES
-- (uuid_generate_v4(), 'Test User 1', 25, 'male', ARRAY[]::UUID[], 3, false),
-- (uuid_generate_v4(), 'Test User 2', 35, 'female', ARRAY[]::UUID[], 1, false)
-- ON CONFLICT DO NOTHING;
