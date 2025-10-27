-- Update age_categories to match required 6 categories
-- (유아, 어린이, 청소년, 청년, 중년, 노년)

-- Clear existing data
TRUNCATE age_categories;

-- Insert the 6 required age categories with proper Korean names
INSERT INTO age_categories (title, description, icon_component, icon_url, min_age, max_age, sort_order, is_active) VALUES
('유아', '(0~7세) 영유아 및 미취학 아동', 'baby', 'packages/pickly_design_system/assets/icons/age_categories/baby.svg', 0, 7, 1, true),
('어린이', '(8~13세) 초등학생', 'kinder', 'packages/pickly_design_system/assets/icons/age_categories/kinder.svg', 8, 13, 2, true),
('청소년', '(14~19세) 중고등학생', 'young_man', 'packages/pickly_design_system/assets/icons/age_categories/young_man.svg', 14, 19, 3, true),
('청년', '(20~34세) 대학생, 취업준비생, 직장인', 'bride', 'packages/pickly_design_system/assets/icons/age_categories/bride.svg', 20, 34, 4, true),
('중년', '(35~49세) 중장년층', 'old_man', 'packages/pickly_design_system/assets/icons/age_categories/old_man.svg', 35, 49, 5, true),
('노년', '(50세 이상) 장년 및 어르신', 'wheel_chair', 'packages/pickly_design_system/assets/icons/age_categories/wheel_chair.svg', 50, NULL, 6, true)
ON CONFLICT DO NOTHING;

-- Verify user_profiles has selected_categories column
-- This should already exist from initial migration, but we ensure it here
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_profiles'
    AND column_name = 'selected_categories'
  ) THEN
    ALTER TABLE user_profiles
    ADD COLUMN selected_categories UUID[] DEFAULT '{}';
  END IF;
END $$;
