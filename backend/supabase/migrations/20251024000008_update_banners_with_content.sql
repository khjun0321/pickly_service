-- ================================================================
-- Migration: Update banners with proper content and styling
-- File: 20251024000008_update_banners_with_content.sql
-- Description: Add subtitles, colors, and better image URLs for all banners
-- ================================================================

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

    -- Clear existing banners
    DELETE FROM benefit_banners;

    -- Insert banners for 인기 (Popular) - Vibrant colors
    IF popular_id IS NOT NULL THEN
        INSERT INTO benefit_banners (category_id, title, subtitle, image_url, link_url, background_color, display_order, is_active) VALUES
        (popular_id, '🔥 인기 혜택 TOP 1', '놓치면 후회할 청년 지원금', 'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?w=1200&h=400&fit=crop&q=80', NULL, '#4F46E5', 0, true),
        (popular_id, '✨ 놓치면 후회할 혜택', '최대 300만원 지원', 'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=1200&h=400&fit=crop&q=80', NULL, '#7C3AED', 1, true),
        (popular_id, '💰 최대 지원금 혜택', '신청 마감 임박!', 'https://images.unsplash.com/photo-1553729459-efe14ef6055d?w=1200&h=400&fit=crop&q=80', NULL, '#EC4899', 2, true);
        RAISE NOTICE 'Added 3 banners for 인기 category';
    END IF;

    -- Insert banners for 주거 (Housing) - Green/Blue tones
    IF housing_id IS NOT NULL THEN
        INSERT INTO benefit_banners (category_id, title, subtitle, image_url, link_url, background_color, display_order, is_active) VALUES
        (housing_id, '🏠 행복주택 입주자 모집', '청년·신혼부부 우선 공급', 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=1200&h=400&fit=crop&q=80', NULL, '#10B981', 0, true),
        (housing_id, '🌟 국민임대주택 특별공급', '저렴한 임대료로 안정된 생활', 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=1200&h=400&fit=crop&q=80', NULL, '#059669', 1, true),
        (housing_id, '💙 전세임대 지원사업', '최대 1억 2천만원 지원', 'https://images.unsplash.com/photo-1582407947304-fd86f028f716?w=1200&h=400&fit=crop&q=80', NULL, '#047857', 2, true),
        (housing_id, '🎁 청년 특별공급', '내 집 마련의 기회', 'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=1200&h=400&fit=crop&q=80', NULL, '#065F46', 3, true);
        RAISE NOTICE 'Added 4 banners for 주거 category';
    END IF;

    -- Insert banners for 교육 (Education) - Blue tones
    IF education_id IS NOT NULL THEN
        INSERT INTO benefit_banners (category_id, title, subtitle, image_url, link_url, background_color, display_order, is_active) VALUES
        (education_id, '📚 학자금 대출 이자 지원', '부담 없이 학업에 집중', 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=1200&h=400&fit=crop&q=80', NULL, '#3B82F6', 0, true),
        (education_id, '🎓 국가장학금 신청', '등록금 걱정 끝!', 'https://images.unsplash.com/photo-1427504494785-3a9ca7044f45?w=1200&h=400&fit=crop&q=80', NULL, '#2563EB', 1, true),
        (education_id, '✏️ 교육비 지원사업', '자녀 교육비 최대 100% 지원', 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=1200&h=400&fit=crop&q=80', NULL, '#1D4ED8', 2, true);
        RAISE NOTICE 'Added 3 banners for 교육 category';
    END IF;

    -- Insert banners for 취업 (Employment) - Orange/Yellow tones
    IF employment_id IS NOT NULL THEN
        INSERT INTO benefit_banners (category_id, title, subtitle, image_url, link_url, background_color, display_order, is_active) VALUES
        (employment_id, '💼 청년 일자리 지원', '취업 성공의 첫걸음', 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=1200&h=400&fit=crop&q=80', NULL, '#F59E0B', 0, true),
        (employment_id, '🎯 직업훈련 무료 지원', '전문 기술 습득의 기회', 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=1200&h=400&fit=crop&q=80', NULL, '#D97706', 1, true),
        (employment_id, '📈 취업성공패키지', '맞춤형 취업 지원', 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=1200&h=400&fit=crop&q=80', NULL, '#B45309', 2, true),
        (employment_id, '🚀 청년추가고용장려금', '신규 채용 기업 인센티브', 'https://images.unsplash.com/photo-1600880292203-757bb62b4baf?w=1200&h=400&fit=crop&q=80', NULL, '#92400E', 3, true);
        RAISE NOTICE 'Added 4 banners for 취업 category';
    END IF;

    -- Insert banners for 지원 (Support) - Purple tones
    IF support_id IS NOT NULL THEN
        INSERT INTO benefit_banners (category_id, title, subtitle, image_url, link_url, background_color, display_order, is_active) VALUES
        (support_id, '🤝 생활지원금 신청', '어려운 이웃을 위한 지원', 'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=1200&h=400&fit=crop&q=80', NULL, '#8B5CF6', 0, true),
        (support_id, '⚡ 긴급복지 지원', '위기 상황 즉시 지원', 'https://images.unsplash.com/photo-1532629345422-7515f3d16bb6?w=1200&h=400&fit=crop&q=80', NULL, '#7C3AED', 1, true),
        (support_id, '💜 저소득층 생계지원', '안정적인 생활 보장', 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=1200&h=400&fit=crop&q=80', NULL, '#6D28D9', 2, true);
        RAISE NOTICE 'Added 3 banners for 지원 category';
    END IF;

    -- Insert banners for 교통 (Transportation) - Cyan tones
    IF transportation_id IS NOT NULL THEN
        INSERT INTO benefit_banners (category_id, title, subtitle, image_url, link_url, background_color, display_order, is_active) VALUES
        (transportation_id, '🚇 대중교통 할인', '알뜰교통카드로 최대 30% 할인', 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=1200&h=400&fit=crop&q=80', NULL, '#06B6D4', 0, true),
        (transportation_id, '💳 청년 교통카드', '매월 최대 5만원 교통비 지원', 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=1200&h=400&fit=crop&q=80', NULL, '#0891B2', 1, true),
        (transportation_id, '⛽ 유류비 지원 사업', '택시·화물차 유류비 절감', 'https://images.unsplash.com/photo-1615906655593-ad0386982a0f?w=1200&h=400&fit=crop&q=80', NULL, '#0E7490', 2, true);
        RAISE NOTICE 'Added 3 banners for 교통 category';
    END IF;

    -- Insert banners for 복지 (Welfare) - Red tones
    IF welfare_id IS NOT NULL THEN
        INSERT INTO benefit_banners (category_id, title, subtitle, image_url, link_url, background_color, display_order, is_active) VALUES
        (welfare_id, '❤️ 기초생활보장', '생계·의료·주거·교육 지원', 'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?w=1200&h=400&fit=crop&q=80', NULL, '#EF4444', 0, true),
        (welfare_id, '♿ 장애인 복지 혜택', '자립생활 지원 서비스', 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=1200&h=400&fit=crop&q=80', NULL, '#DC2626', 1, true),
        (welfare_id, '👴 노인 복지 서비스', '행복한 노후생활 지원', 'https://images.unsplash.com/photo-1581579438747-1dc8d17bbce4?w=1200&h=400&fit=crop&q=80', NULL, '#B91C1C', 2, true),
        (welfare_id, '👶 아동 복지 지원', '건강한 성장을 위한 지원', 'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=1200&h=400&fit=crop&q=80', NULL, '#991B1B', 3, true);
        RAISE NOTICE 'Added 4 banners for 복지 category';
    END IF;

    -- Insert banners for 식품 (Food) - Lime/Green tones
    IF food_id IS NOT NULL THEN
        INSERT INTO benefit_banners (category_id, title, subtitle, image_url, link_url, background_color, display_order, is_active) VALUES
        (food_id, '🥬 농산물 할인 혜택', '신선한 농산물 저렴하게', 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1200&h=400&fit=crop&q=80', NULL, '#84CC16', 0, true),
        (food_id, '🍱 급식비 지원', '학생 급식비 100% 지원', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=1200&h=400&fit=crop&q=80', NULL, '#65A30D', 1, true),
        (food_id, '🎫 식품 바우처', '건강한 먹거리 구매 지원', 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=1200&h=400&fit=crop&q=80', NULL, '#4D7C0F', 2, true);
        RAISE NOTICE 'Added 3 banners for 식품 category';
    END IF;

END $$;

-- Completion log
DO $$
BEGIN
    RAISE NOTICE 'Migration 20251024000008_update_banners_with_content.sql completed successfully';
    RAISE NOTICE 'Updated all banners with subtitles, colors, and quality images from Unsplash';
    RAISE NOTICE 'Total: 27 banners with complete content';
END $$;
