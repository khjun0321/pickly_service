-- Add subcategories for benefit_categories
-- This migration adds parent_id column and subcategories for housing, education, employment, etc.

-- Add parent_id column to benefit_categories
ALTER TABLE benefit_categories
ADD COLUMN IF NOT EXISTS parent_id UUID REFERENCES benefit_categories(id) ON DELETE CASCADE;

-- Create index for parent_id
CREATE INDEX IF NOT EXISTS idx_benefit_categories_parent ON benefit_categories(parent_id);

COMMENT ON COLUMN benefit_categories.parent_id IS 'Parent category ID for subcategories (NULL for top-level categories)';

DO $$
DECLARE
    housing_id UUID;
    education_id UUID;
    employment_id UUID;
    welfare_id UUID;
    health_id UUID;
    culture_id UUID;
BEGIN
    -- Get parent category IDs
    SELECT id INTO housing_id FROM benefit_categories WHERE slug = 'housing';
    SELECT id INTO education_id FROM benefit_categories WHERE slug = 'education';
    SELECT id INTO employment_id FROM benefit_categories WHERE slug = 'employment';
    SELECT id INTO welfare_id FROM benefit_categories WHERE slug = 'welfare';
    SELECT id INTO health_id FROM benefit_categories WHERE slug = 'health';
    SELECT id INTO culture_id FROM benefit_categories WHERE slug = 'culture';

    -- 주거 하위 카테고리
    INSERT INTO benefit_categories (parent_id, name, slug, description, display_order) VALUES
    (housing_id, '행복주택', 'housing-happiness', '청년, 신혼부부, 대학생을 위한 공공임대주택', 1),
    (housing_id, '국민임대주택', 'housing-public', '저소득 무주택 가구를 위한 장기 공공임대주택', 2),
    (housing_id, '영구임대주택', 'housing-permanent', '생계급여 수급자 등을 위한 영구임대주택', 3),
    (housing_id, '매입임대주택', 'housing-purchased', '기존 주택을 매입하여 저렴하게 임대', 4),
    (housing_id, '신혼희망타운', 'housing-newlywed', '신혼부부를 위한 주거 지원', 5)
    ON CONFLICT (slug) DO NOTHING;

    -- 교육 하위 카테고리
    INSERT INTO benefit_categories (parent_id, name, slug, description, display_order) VALUES
    (education_id, '장학금', 'education-scholarship', '학비 지원 및 장학금 프로그램', 1),
    (education_id, '직업훈련', 'education-training', '직업 능력 개발 및 훈련 프로그램', 2),
    (education_id, '평생교육', 'education-lifelong', '성인 대상 평생교육 프로그램', 3),
    (education_id, '학자금대출', 'education-loan', '학자금 대출 및 상환 지원', 4)
    ON CONFLICT (slug) DO NOTHING;

    -- 취업 하위 카테고리
    INSERT INTO benefit_categories (parent_id, name, slug, description, display_order) VALUES
    (employment_id, '청년취업', 'employment-youth', '청년 취업 지원 및 인턴십', 1),
    (employment_id, '창업지원', 'employment-startup', '창업 자금 및 컨설팅 지원', 2),
    (employment_id, '재취업지원', 'employment-reemployment', '경력단절자 재취업 지원', 3),
    (employment_id, '고용장려금', 'employment-incentive', '고용 창출 장려금 및 지원', 4)
    ON CONFLICT (slug) DO NOTHING;

    -- 복지 하위 카테고리
    INSERT INTO benefit_categories (parent_id, name, slug, description, display_order) VALUES
    (welfare_id, '생활지원', 'welfare-living', '생계비 및 생활 지원', 1),
    (welfare_id, '아동복지', 'welfare-child', '아동 양육 및 돌봄 지원', 2),
    (welfare_id, '노인복지', 'welfare-senior', '어르신 생활 및 의료 지원', 3),
    (welfare_id, '장애인복지', 'welfare-disabled', '장애인 생활 및 활동 지원', 4)
    ON CONFLICT (slug) DO NOTHING;

    -- 건강 하위 카테고리
    INSERT INTO benefit_categories (parent_id, name, slug, description, display_order) VALUES
    (health_id, '건강검진', 'health-checkup', '무료 건강검진 프로그램', 1),
    (health_id, '의료비지원', 'health-medical', '의료비 및 치료비 지원', 2),
    (health_id, '예방접종', 'health-vaccination', '무료 예방접종 지원', 3),
    (health_id, '정신건강', 'health-mental', '정신건강 상담 및 치료 지원', 4)
    ON CONFLICT (slug) DO NOTHING;

    -- 문화 하위 카테고리
    INSERT INTO benefit_categories (parent_id, name, slug, description, display_order) VALUES
    (culture_id, '공연·전시', 'culture-performance', '공연 및 전시 할인 혜택', 1),
    (culture_id, '체육시설', 'culture-sports', '체육시설 이용 지원', 2),
    (culture_id, '도서관', 'culture-library', '도서관 및 독서 프로그램', 3),
    (culture_id, '여행·관광', 'culture-travel', '여행 및 관광 지원', 4)
    ON CONFLICT (slug) DO NOTHING;

END $$;

COMMENT ON COLUMN benefit_categories.parent_id IS 'Parent category ID for subcategories';
