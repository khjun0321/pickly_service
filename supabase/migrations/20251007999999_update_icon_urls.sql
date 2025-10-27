-- Update icon URLs for age categories to use SVG assets from design system

UPDATE age_categories
SET icon_url = 'packages/pickly_design_system/assets/icons/age_categories/young_man.svg'
WHERE icon_component = 'young_man';

UPDATE age_categories
SET icon_url = 'packages/pickly_design_system/assets/icons/age_categories/bride.svg'
WHERE icon_component = 'bride';

UPDATE age_categories
SET icon_url = 'packages/pickly_design_system/assets/icons/age_categories/baby.svg'
WHERE icon_component = 'baby';

UPDATE age_categories
SET icon_url = 'packages/pickly_design_system/assets/icons/age_categories/kinder.svg'
WHERE icon_component = 'kinder';

UPDATE age_categories
SET icon_url = 'packages/pickly_design_system/assets/icons/age_categories/old_man.svg'
WHERE icon_component = 'old_man';

UPDATE age_categories
SET icon_url = 'packages/pickly_design_system/assets/icons/age_categories/wheel_chair.svg'
WHERE icon_component = 'wheel_chair';
