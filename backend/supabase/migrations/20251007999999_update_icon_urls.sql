-- Update icon URLs for age categories to use SVG assets from design system

UPDATE age_categories
SET icon_url = 'packages/pickly_design_system/assets/icons/age_categories/baby.svg'
WHERE title = '영유아 (0~7세)';

UPDATE age_categories
SET icon_url = 'packages/pickly_design_system/assets/icons/age_categories/kinder.svg'
WHERE title = '아동 (8~13세)';

UPDATE age_categories
SET icon_url = 'packages/pickly_design_system/assets/icons/age_categories/young_man.svg'
WHERE title = '청소년 (14~19세)';

UPDATE age_categories
SET icon_url = 'packages/pickly_design_system/assets/icons/age_categories/bride.svg'
WHERE title = '청년 (20~34세)';

UPDATE age_categories
SET icon_url = 'packages/pickly_design_system/assets/icons/age_categories/old_man.svg'
WHERE title = '중년 (35~49세)';

UPDATE age_categories
SET icon_url = 'packages/pickly_design_system/assets/icons/age_categories/wheel_chair.svg'
WHERE title = '장년 (50세 이상)';
