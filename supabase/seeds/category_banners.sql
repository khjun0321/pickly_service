-- Category Banners Seed Data (v8.1 - Stable Version)
--
-- This file contains promotional banners for each benefit category.
-- Banners are displayed in the mobile app's category detail screens.

-- Insert category banners with slug-based category lookup
DO $$
DECLARE
  housing_id UUID;
  welfare_id UUID;
  education_id UUID;
  employment_id UUID;
  health_id UUID;
  culture_id UUID;
BEGIN
  -- Get category IDs using slug (unique identifier)
  SELECT id INTO housing_id FROM benefit_categories WHERE slug = 'housing';
  SELECT id INTO welfare_id FROM benefit_categories WHERE slug = 'welfare';
  SELECT id INTO education_id FROM benefit_categories WHERE slug = 'education';
  SELECT id INTO employment_id FROM benefit_categories WHERE slug = 'employment';
  SELECT id INTO health_id FROM benefit_categories WHERE slug = 'health';
  SELECT id INTO culture_id FROM benefit_categories WHERE slug = 'culture';

  -- Insert sample banners for each category
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
