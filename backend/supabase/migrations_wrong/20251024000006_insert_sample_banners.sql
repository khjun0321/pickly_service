-- ================================================================
-- Migration: Insert sample banners for all benefit categories
-- File: 20251024000006_insert_sample_banners.sql
-- Description: Add multiple sample banners with display order for each category
-- ================================================================

-- First, get all parent category IDs
DO $$
DECLARE
    popular_id UUID;
    housing_id UUID;
    education_id UUID;
    employment_id UUID;
    support_id UUID;
    transportation_id UUID;
    welfare_id UUID;
    food_id UUID;
BEGIN
    -- Get category IDs
    SELECT id INTO popular_id FROM benefit_categories WHERE slug = 'popular' AND parent_id IS NULL;
    SELECT id INTO housing_id FROM benefit_categories WHERE slug = 'housing' AND parent_id IS NULL;
    SELECT id INTO education_id FROM benefit_categories WHERE slug = 'education' AND parent_id IS NULL;
    SELECT id INTO employment_id FROM benefit_categories WHERE slug = 'employment' AND parent_id IS NULL;
    SELECT id INTO support_id FROM benefit_categories WHERE slug = 'support' AND parent_id IS NULL;
    SELECT id INTO transportation_id FROM benefit_categories WHERE slug = 'transportation' AND parent_id IS NULL;
    SELECT id INTO welfare_id FROM benefit_categories WHERE slug = 'welfare' AND parent_id IS NULL;
    SELECT id INTO food_id FROM benefit_categories WHERE slug = 'food' AND parent_id IS NULL;

    -- Insert banners for 인기 (Popular) category
    IF popular_id IS NOT NULL THEN
        INSERT INTO benefit_banners (category_id, title, image_url, link_url, display_order, is_active) VALUES
        (popular_id, '🔥 인기 혜택 TOP 1', 'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?w=1200&h=400&fit=crop', NULL, 0, true),
        (popular_id, '✨ 놓치면 후회할 혜택', 'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=1200&h=400&fit=crop', NULL, 1, true),
        (popular_id, '💰 최대 지원금 혜택', 'https://images.unsplash.com/photo-1553729459-efe14ef6055d?w=1200&h=400&fit=crop', NULL, 2, true)
        ON CONFLICT DO NOTHING;
        RAISE NOTICE 'Added 3 banners for 인기 category';
    END IF;

    -- Insert banners for 주거 (Housing) category
    IF housing_id IS NOT NULL THEN
        INSERT INTO benefit_banners (category_id, title, image_url, link_url, display_order, is_active) VALUES
        (housing_id, '주거 혜택 배너 1 - 행복주택', 'https://placehold.co/1200x400/10B981/FFFFFF/png?text=Housing+Banner+1', 'https://example.com/housing1', 0, true),
        (housing_id, '주거 혜택 배너 2 - 국민임대', 'https://placehold.co/1200x400/059669/FFFFFF/png?text=Housing+Banner+2', 'https://example.com/housing2', 1, true),
        (housing_id, '주거 혜택 배너 3 - 전세임대', 'https://placehold.co/1200x400/047857/FFFFFF/png?text=Housing+Banner+3', 'https://example.com/housing3', 2, true),
        (housing_id, '주거 혜택 배너 4 - 청년 특별공급', 'https://placehold.co/1200x400/065F46/FFFFFF/png?text=Housing+Banner+4', 'https://example.com/housing4', 3, true)
        ON CONFLICT DO NOTHING;
        RAISE NOTICE 'Added 4 banners for 주거 category';
    END IF;

    -- Insert banners for 교육 (Education) category
    IF education_id IS NOT NULL THEN
        INSERT INTO benefit_banners (category_id, title, image_url, link_url, display_order, is_active) VALUES
        (education_id, '교육 혜택 배너 1 - 학자금 지원', 'https://placehold.co/1200x400/3B82F6/FFFFFF/png?text=Education+Banner+1', 'https://example.com/education1', 0, true),
        (education_id, '교육 혜택 배너 2 - 국가장학금', 'https://placehold.co/1200x400/2563EB/FFFFFF/png?text=Education+Banner+2', 'https://example.com/education2', 1, true),
        (education_id, '교육 혜택 배너 3 - 교육비 지원', 'https://placehold.co/1200x400/1D4ED8/FFFFFF/png?text=Education+Banner+3', 'https://example.com/education3', 2, true)
        ON CONFLICT DO NOTHING;
        RAISE NOTICE 'Added 3 banners for 교육 category';
    END IF;

    -- Insert banners for 취업 (Employment) category
    IF employment_id IS NOT NULL THEN
        INSERT INTO benefit_banners (category_id, title, image_url, link_url, display_order, is_active) VALUES
        (employment_id, '취업 혜택 배너 1 - 청년 일자리', 'https://placehold.co/1200x400/F59E0B/FFFFFF/png?text=Employment+Banner+1', 'https://example.com/employment1', 0, true),
        (employment_id, '취업 혜택 배너 2 - 직업훈련', 'https://placehold.co/1200x400/D97706/FFFFFF/png?text=Employment+Banner+2', 'https://example.com/employment2', 1, true),
        (employment_id, '취업 혜택 배너 3 - 취업성공패키지', 'https://placehold.co/1200x400/B45309/FFFFFF/png?text=Employment+Banner+3', 'https://example.com/employment3', 2, true),
        (employment_id, '취업 혜택 배너 4 - 청년추가고용장려금', 'https://placehold.co/1200x400/92400E/FFFFFF/png?text=Employment+Banner+4', 'https://example.com/employment4', 3, true)
        ON CONFLICT DO NOTHING;
        RAISE NOTICE 'Added 4 banners for 취업 category';
    END IF;

    -- Insert banners for 지원 (Support) category
    IF support_id IS NOT NULL THEN
        INSERT INTO benefit_banners (category_id, title, image_url, link_url, display_order, is_active) VALUES
        (support_id, '지원 혜택 배너 1 - 생활지원', 'https://placehold.co/1200x400/8B5CF6/FFFFFF/png?text=Support+Banner+1', 'https://example.com/support1', 0, true),
        (support_id, '지원 혜택 배너 2 - 긴급복지', 'https://placehold.co/1200x400/7C3AED/FFFFFF/png?text=Support+Banner+2', 'https://example.com/support2', 1, true),
        (support_id, '지원 혜택 배너 3 - 저소득층 지원', 'https://placehold.co/1200x400/6D28D9/FFFFFF/png?text=Support+Banner+3', 'https://example.com/support3', 2, true)
        ON CONFLICT DO NOTHING;
        RAISE NOTICE 'Added 3 banners for 지원 category';
    END IF;

    -- Insert banners for 교통 (Transportation) category
    IF transportation_id IS NOT NULL THEN
        INSERT INTO benefit_banners (category_id, title, image_url, link_url, display_order, is_active) VALUES
        (transportation_id, '교통 혜택 배너 1 - 대중교통 할인', 'https://placehold.co/1200x400/06B6D4/FFFFFF/png?text=Transportation+Banner+1', 'https://example.com/transportation1', 0, true),
        (transportation_id, '교통 혜택 배너 2 - 청년 교통카드', 'https://placehold.co/1200x400/0891B2/FFFFFF/png?text=Transportation+Banner+2', 'https://example.com/transportation2', 1, true),
        (transportation_id, '교통 혜택 배너 3 - 유류비 지원', 'https://placehold.co/1200x400/0E7490/FFFFFF/png?text=Transportation+Banner+3', 'https://example.com/transportation3', 2, true)
        ON CONFLICT DO NOTHING;
        RAISE NOTICE 'Added 3 banners for 교통 category';
    END IF;

    -- Insert banners for 복지 (Welfare) category
    IF welfare_id IS NOT NULL THEN
        INSERT INTO benefit_banners (category_id, title, image_url, link_url, display_order, is_active) VALUES
        (welfare_id, '복지 혜택 배너 1 - 기초생활보장', 'https://placehold.co/1200x400/EF4444/FFFFFF/png?text=Welfare+Banner+1', 'https://example.com/welfare1', 0, true),
        (welfare_id, '복지 혜택 배너 2 - 장애인 복지', 'https://placehold.co/1200x400/DC2626/FFFFFF/png?text=Welfare+Banner+2', 'https://example.com/welfare2', 1, true),
        (welfare_id, '복지 혜택 배너 3 - 노인 복지', 'https://placehold.co/1200x400/B91C1C/FFFFFF/png?text=Welfare+Banner+3', 'https://example.com/welfare3', 2, true),
        (welfare_id, '복지 혜택 배너 4 - 아동 복지', 'https://placehold.co/1200x400/991B1B/FFFFFF/png?text=Welfare+Banner+4', 'https://example.com/welfare4', 3, true)
        ON CONFLICT DO NOTHING;
        RAISE NOTICE 'Added 4 banners for 복지 category';
    END IF;

    -- Insert banners for 식품 (Food) category
    IF food_id IS NOT NULL THEN
        INSERT INTO benefit_banners (category_id, title, image_url, link_url, display_order, is_active) VALUES
        (food_id, '식품 혜택 배너 1 - 농산물 할인', 'https://placehold.co/1200x400/84CC16/FFFFFF/png?text=Food+Banner+1', 'https://example.com/food1', 0, true),
        (food_id, '식품 혜택 배너 2 - 급식 지원', 'https://placehold.co/1200x400/65A30D/FFFFFF/png?text=Food+Banner+2', 'https://example.com/food2', 1, true),
        (food_id, '식품 혜택 배너 3 - 식품 바우처', 'https://placehold.co/1200x400/4D7C0F/FFFFFF/png?text=Food+Banner+3', 'https://example.com/food3', 2, true)
        ON CONFLICT DO NOTHING;
        RAISE NOTICE 'Added 3 banners for 식품 category';
    END IF;

END $$;

-- Completion log
DO $$
BEGIN
    RAISE NOTICE 'Migration 20251024000006_insert_sample_banners.sql completed successfully';
    RAISE NOTICE 'Added sample banners for all 8 benefit categories with display order';
    RAISE NOTICE 'Total: 27+ banners across all categories';
END $$;
