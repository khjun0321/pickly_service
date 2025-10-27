-- =============================================================================
-- Pickly Service - Benefit Announcement System
-- Migration: 20251024000000_benefit_system.sql
-- Description: Create comprehensive benefit announcement database schema
-- =============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For text search optimization

-- =============================================================================
-- 1. BENEFIT CATEGORIES TABLE
-- Description: Stores benefit categories (주거, 복지, 교육, 취업, 건강, 문화)
-- =============================================================================
CREATE TABLE IF NOT EXISTS benefit_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    slug VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    icon_url TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT benefit_categories_name_not_empty CHECK (char_length(name) > 0),
    CONSTRAINT benefit_categories_slug_not_empty CHECK (char_length(slug) > 0),
    CONSTRAINT benefit_categories_display_order_positive CHECK (display_order >= 0)
);

-- Indexes for benefit_categories
CREATE INDEX idx_benefit_categories_slug ON benefit_categories(slug);
CREATE INDEX idx_benefit_categories_display_order ON benefit_categories(display_order);
CREATE INDEX idx_benefit_categories_active ON benefit_categories(is_active) WHERE is_active = TRUE;

-- Comments for benefit_categories
COMMENT ON TABLE benefit_categories IS '혜택 카테고리 테이블 (주거, 복지, 교육 등)';
COMMENT ON COLUMN benefit_categories.slug IS 'URL-friendly identifier for the category';
COMMENT ON COLUMN benefit_categories.display_order IS 'Order in which categories are displayed';

-- =============================================================================
-- 2. BENEFIT ANNOUNCEMENTS TABLE
-- Description: Main table for benefit announcements (공고)
-- =============================================================================
CREATE TABLE IF NOT EXISTS benefit_announcements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES benefit_categories(id) ON DELETE RESTRICT,

    -- Basic Information
    title VARCHAR(255) NOT NULL,
    subtitle VARCHAR(255),
    organization VARCHAR(255) NOT NULL, -- 주관 기관
    application_period_start DATE,
    application_period_end DATE,
    announcement_date DATE,

    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'closed', 'archived')),
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    views_count INTEGER NOT NULL DEFAULT 0,

    -- Content
    summary TEXT,
    thumbnail_url TEXT,
    external_url TEXT, -- Link to original announcement

    -- Metadata
    tags TEXT[], -- Array of tags for search
    search_vector TSVECTOR, -- Full-text search vector

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    published_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT benefit_announcements_title_not_empty CHECK (char_length(title) > 0),
    CONSTRAINT benefit_announcements_organization_not_empty CHECK (char_length(organization) > 0),
    CONSTRAINT benefit_announcements_views_positive CHECK (views_count >= 0),
    CONSTRAINT benefit_announcements_date_order CHECK (
        application_period_start IS NULL OR
        application_period_end IS NULL OR
        application_period_start <= application_period_end
    )
);

-- Indexes for benefit_announcements
CREATE INDEX idx_announcements_category ON benefit_announcements(category_id);
CREATE INDEX idx_announcements_status ON benefit_announcements(status);
CREATE INDEX idx_announcements_featured ON benefit_announcements(is_featured) WHERE is_featured = TRUE;
CREATE INDEX idx_announcements_published_at ON benefit_announcements(published_at DESC) WHERE status = 'published';
CREATE INDEX idx_announcements_application_period ON benefit_announcements(application_period_start, application_period_end);
CREATE INDEX idx_announcements_views ON benefit_announcements(views_count DESC);
CREATE INDEX idx_announcements_tags ON benefit_announcements USING GIN(tags);
CREATE INDEX idx_announcements_search ON benefit_announcements USING GIN(search_vector);

-- Comments for benefit_announcements
COMMENT ON TABLE benefit_announcements IS '혜택 공고 메인 정보 테이블';
COMMENT ON COLUMN benefit_announcements.status IS 'Announcement status: draft, published, closed, archived';
COMMENT ON COLUMN benefit_announcements.is_featured IS 'Whether the announcement is featured on homepage';
COMMENT ON COLUMN benefit_announcements.search_vector IS 'Full-text search vector for Korean/English search';

-- =============================================================================
-- 3. ANNOUNCEMENT UNIT TYPES TABLE
-- Description: Stores unit type information (평수별 정보) for housing announcements
-- =============================================================================
CREATE TABLE IF NOT EXISTS announcement_unit_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    announcement_id UUID NOT NULL REFERENCES benefit_announcements(id) ON DELETE CASCADE,

    -- Unit Information
    unit_type VARCHAR(50) NOT NULL, -- e.g., "59㎡", "84㎡"
    exclusive_area DECIMAL(10,2), -- 전용면적
    supply_area DECIMAL(10,2), -- 공급면적
    unit_count INTEGER, -- 세대수

    -- Pricing
    sale_price DECIMAL(15,2), -- 분양가
    deposit_amount DECIMAL(15,2), -- 보증금
    monthly_rent DECIMAL(15,2), -- 월세

    -- Additional Info
    room_layout VARCHAR(50), -- e.g., "3Bay", "4Bay"
    special_conditions TEXT,

    -- Metadata
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT unit_types_unit_type_not_empty CHECK (char_length(unit_type) > 0),
    CONSTRAINT unit_types_areas_positive CHECK (
        (exclusive_area IS NULL OR exclusive_area > 0) AND
        (supply_area IS NULL OR supply_area > 0)
    ),
    CONSTRAINT unit_types_prices_non_negative CHECK (
        (sale_price IS NULL OR sale_price >= 0) AND
        (deposit_amount IS NULL OR deposit_amount >= 0) AND
        (monthly_rent IS NULL OR monthly_rent >= 0)
    ),
    CONSTRAINT unit_types_count_positive CHECK (unit_count IS NULL OR unit_count > 0)
);

-- Indexes for announcement_unit_types
CREATE INDEX idx_unit_types_announcement ON announcement_unit_types(announcement_id);
CREATE INDEX idx_unit_types_display_order ON announcement_unit_types(announcement_id, display_order);
CREATE INDEX idx_unit_types_exclusive_area ON announcement_unit_types(exclusive_area);
CREATE INDEX idx_unit_types_pricing ON announcement_unit_types(sale_price, monthly_rent);

-- Comments for announcement_unit_types
COMMENT ON TABLE announcement_unit_types IS '공고별 평수 정보 테이블 (주거 카테고리용)';
COMMENT ON COLUMN announcement_unit_types.exclusive_area IS '전용면적 (㎡)';
COMMENT ON COLUMN announcement_unit_types.supply_area IS '공급면적 (㎡)';

-- =============================================================================
-- 4. ANNOUNCEMENT SECTIONS TABLE
-- Description: Custom sections for announcements (e.g., eligibility, documents)
-- =============================================================================
CREATE TABLE IF NOT EXISTS announcement_sections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    announcement_id UUID NOT NULL REFERENCES benefit_announcements(id) ON DELETE CASCADE,

    -- Section Information
    section_type VARCHAR(50) NOT NULL, -- e.g., "eligibility", "documents", "schedule"
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,

    -- Structured Data (JSON for flexibility)
    structured_data JSONB, -- For complex data structures (lists, tables, etc.)

    -- Metadata
    display_order INTEGER NOT NULL DEFAULT 0,
    is_visible BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT sections_title_not_empty CHECK (char_length(title) > 0),
    CONSTRAINT sections_content_not_empty CHECK (char_length(content) > 0)
);

-- Indexes for announcement_sections
CREATE INDEX idx_sections_announcement ON announcement_sections(announcement_id);
CREATE INDEX idx_sections_type ON announcement_sections(section_type);
CREATE INDEX idx_sections_display_order ON announcement_sections(announcement_id, display_order);
CREATE INDEX idx_sections_structured_data ON announcement_sections USING GIN(structured_data);

-- Comments for announcement_sections
COMMENT ON TABLE announcement_sections IS '공고별 커스텀 섹션 (자격요건, 구비서류 등)';
COMMENT ON COLUMN announcement_sections.section_type IS 'Type of section: eligibility, documents, schedule, benefits, etc.';
COMMENT ON COLUMN announcement_sections.structured_data IS 'JSON data for complex structures like lists and tables';

-- =============================================================================
-- 5. ANNOUNCEMENT COMMENTS TABLE (Future Expansion)
-- Description: User comments and discussions on announcements
-- =============================================================================
CREATE TABLE IF NOT EXISTS announcement_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    announcement_id UUID NOT NULL REFERENCES benefit_announcements(id) ON DELETE CASCADE,
    user_id UUID NOT NULL, -- References auth.users, but no FK to avoid dependency
    parent_comment_id UUID REFERENCES announcement_comments(id) ON DELETE CASCADE,

    -- Comment Content
    content TEXT NOT NULL,
    is_edited BOOLEAN NOT NULL DEFAULT FALSE,

    -- Moderation
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    is_reported BOOLEAN NOT NULL DEFAULT FALSE,
    moderation_status VARCHAR(20) DEFAULT 'pending' CHECK (moderation_status IN ('pending', 'approved', 'rejected')),

    -- Engagement
    likes_count INTEGER NOT NULL DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT comments_content_not_empty CHECK (char_length(content) > 0 OR is_deleted = TRUE),
    CONSTRAINT comments_likes_non_negative CHECK (likes_count >= 0)
);

-- Indexes for announcement_comments
CREATE INDEX idx_comments_announcement ON announcement_comments(announcement_id, created_at DESC);
CREATE INDEX idx_comments_user ON announcement_comments(user_id);
CREATE INDEX idx_comments_parent ON announcement_comments(parent_comment_id) WHERE parent_comment_id IS NOT NULL;
CREATE INDEX idx_comments_moderation ON announcement_comments(moderation_status, created_at);
CREATE INDEX idx_comments_active ON announcement_comments(announcement_id) WHERE is_deleted = FALSE;

-- Comments for announcement_comments
COMMENT ON TABLE announcement_comments IS '공고 댓글 테이블 (미래 확장용)';
COMMENT ON COLUMN announcement_comments.parent_comment_id IS 'For nested/threaded comments';

-- =============================================================================
-- 6. ANNOUNCEMENT AI CHATS TABLE (Future Expansion)
-- Description: AI chatbot conversations related to announcements
-- =============================================================================
CREATE TABLE IF NOT EXISTS announcement_ai_chats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    announcement_id UUID REFERENCES benefit_announcements(id) ON DELETE SET NULL,
    user_id UUID NOT NULL, -- References auth.users
    session_id UUID NOT NULL DEFAULT uuid_generate_v4(),

    -- Message Content
    role VARCHAR(20) NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,

    -- AI Metadata
    model_name VARCHAR(100),
    tokens_used INTEGER,
    response_time_ms INTEGER,

    -- Context
    context_data JSONB, -- Additional context for AI processing

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT ai_chats_content_not_empty CHECK (char_length(content) > 0),
    CONSTRAINT ai_chats_tokens_non_negative CHECK (tokens_used IS NULL OR tokens_used >= 0),
    CONSTRAINT ai_chats_response_time_positive CHECK (response_time_ms IS NULL OR response_time_ms > 0)
);

-- Indexes for announcement_ai_chats
CREATE INDEX idx_ai_chats_session ON announcement_ai_chats(session_id, created_at);
CREATE INDEX idx_ai_chats_user ON announcement_ai_chats(user_id, created_at DESC);
CREATE INDEX idx_ai_chats_announcement ON announcement_ai_chats(announcement_id) WHERE announcement_id IS NOT NULL;
CREATE INDEX idx_ai_chats_context ON announcement_ai_chats USING GIN(context_data);

-- Comments for announcement_ai_chats
COMMENT ON TABLE announcement_ai_chats IS 'AI 챗봇 대화 기록 (미래 확장용)';
COMMENT ON COLUMN announcement_ai_chats.session_id IS 'Groups messages in a conversation session';
COMMENT ON COLUMN announcement_ai_chats.context_data IS 'JSON data for AI context and metadata';

-- =============================================================================
-- FUNCTIONS AND TRIGGERS
-- =============================================================================

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Update search vector for announcements
CREATE OR REPLACE FUNCTION update_announcement_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('simple', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('simple', COALESCE(NEW.subtitle, '')), 'B') ||
        setweight(to_tsvector('simple', COALESCE(NEW.summary, '')), 'C') ||
        setweight(to_tsvector('simple', COALESCE(NEW.organization, '')), 'D') ||
        setweight(to_tsvector('simple', COALESCE(array_to_string(NEW.tags, ' '), '')), 'B');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_benefit_categories_updated_at
    BEFORE UPDATE ON benefit_categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_benefit_announcements_updated_at
    BEFORE UPDATE ON benefit_announcements
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_announcement_unit_types_updated_at
    BEFORE UPDATE ON announcement_unit_types
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_announcement_sections_updated_at
    BEFORE UPDATE ON announcement_sections
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_announcement_comments_updated_at
    BEFORE UPDATE ON announcement_comments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for search vector
CREATE TRIGGER update_announcements_search_vector
    BEFORE INSERT OR UPDATE OF title, subtitle, summary, organization, tags
    ON benefit_announcements
    FOR EACH ROW
    EXECUTE FUNCTION update_announcement_search_vector();

-- =============================================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================================

-- Enable RLS on all tables
ALTER TABLE benefit_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE benefit_announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_unit_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_ai_chats ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Public read access for published content

-- benefit_categories: All users can read active categories
CREATE POLICY "Public can view active categories"
    ON benefit_categories FOR SELECT
    USING (is_active = TRUE);

-- benefit_announcements: All users can read published announcements
CREATE POLICY "Public can view published announcements"
    ON benefit_announcements FOR SELECT
    USING (status = 'published');

-- announcement_unit_types: All users can read unit types of published announcements
CREATE POLICY "Public can view unit types of published announcements"
    ON announcement_unit_types FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM benefit_announcements
            WHERE benefit_announcements.id = announcement_unit_types.announcement_id
            AND benefit_announcements.status = 'published'
        )
    );

-- announcement_sections: All users can read visible sections of published announcements
CREATE POLICY "Public can view sections of published announcements"
    ON announcement_sections FOR SELECT
    USING (
        is_visible = TRUE AND
        EXISTS (
            SELECT 1 FROM benefit_announcements
            WHERE benefit_announcements.id = announcement_sections.announcement_id
            AND benefit_announcements.status = 'published'
        )
    );

-- announcement_comments: All users can read approved comments
CREATE POLICY "Public can view approved comments"
    ON announcement_comments FOR SELECT
    USING (
        is_deleted = FALSE AND
        moderation_status = 'approved'
    );

-- announcement_comments: Users can insert their own comments
CREATE POLICY "Users can insert their own comments"
    ON announcement_comments FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- announcement_comments: Users can update their own comments
CREATE POLICY "Users can update their own comments"
    ON announcement_comments FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- announcement_comments: Users can delete their own comments
CREATE POLICY "Users can delete their own comments"
    ON announcement_comments FOR DELETE
    USING (auth.uid() = user_id);

-- announcement_ai_chats: Users can only access their own chat sessions
CREATE POLICY "Users can view their own AI chats"
    ON announcement_ai_chats FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own AI chats"
    ON announcement_ai_chats FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- =============================================================================
-- INITIAL DATA INSERTION
-- =============================================================================

-- Insert initial 6 benefit categories
INSERT INTO benefit_categories (name, slug, description, display_order) VALUES
    ('주거', 'housing', '주거 관련 혜택 (임대, 분양, 주택구입 지원 등)', 1),
    ('복지', 'welfare', '복지 관련 혜택 (생활지원, 의료지원, 긴급지원 등)', 2),
    ('교육', 'education', '교육 관련 혜택 (학비지원, 장학금, 교육프로그램 등)', 3),
    ('취업', 'employment', '취업 관련 혜택 (취업지원, 직업훈련, 창업지원 등)', 4),
    ('건강', 'health', '건강 관련 혜택 (건강검진, 의료비지원, 예방접종 등)', 5),
    ('문화', 'culture', '문화 관련 혜택 (문화생활, 여가활동, 체육시설 이용 등)', 6)
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- UTILITY VIEWS
-- =============================================================================

-- View: Published announcements with category information
CREATE OR REPLACE VIEW v_published_announcements AS
SELECT
    a.*,
    c.name as category_name,
    c.slug as category_slug,
    CASE
        WHEN a.application_period_end IS NULL THEN NULL
        WHEN a.application_period_end >= CURRENT_DATE THEN 'active'
        ELSE 'expired'
    END as application_status
FROM benefit_announcements a
JOIN benefit_categories c ON a.category_id = c.id
WHERE a.status = 'published'
ORDER BY a.published_at DESC;

-- View: Featured announcements
CREATE OR REPLACE VIEW v_featured_announcements AS
SELECT * FROM v_published_announcements
WHERE is_featured = TRUE
ORDER BY published_at DESC
LIMIT 10;

-- View: Announcement statistics
CREATE OR REPLACE VIEW v_announcement_stats AS
SELECT
    c.name as category_name,
    c.slug as category_slug,
    COUNT(a.id) as total_announcements,
    COUNT(CASE WHEN a.status = 'published' THEN 1 END) as published_count,
    COUNT(CASE WHEN a.is_featured THEN 1 END) as featured_count,
    SUM(a.views_count) as total_views
FROM benefit_categories c
LEFT JOIN benefit_announcements a ON c.id = a.category_id
GROUP BY c.id, c.name, c.slug
ORDER BY c.display_order;

-- =============================================================================
-- GRANTS AND PERMISSIONS
-- =============================================================================

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Grant select on views to authenticated users
GRANT SELECT ON v_published_announcements TO anon, authenticated;
GRANT SELECT ON v_featured_announcements TO anon, authenticated;
GRANT SELECT ON v_announcement_stats TO anon, authenticated;

-- =============================================================================
-- MIGRATION COMPLETE
-- =============================================================================

COMMENT ON SCHEMA public IS 'Pickly Benefit Announcement System - Migration 20251024000000';

-- Log completion
DO $$
BEGIN
    RAISE NOTICE 'Migration 20251024000000_benefit_system.sql completed successfully';
    RAISE NOTICE 'Created 6 tables: benefit_categories, benefit_announcements, announcement_unit_types, announcement_sections, announcement_comments, announcement_ai_chats';
    RAISE NOTICE 'Inserted 6 initial categories: 주거, 복지, 교육, 취업, 건강, 문화';
    RAISE NOTICE 'Created 3 utility views: v_published_announcements, v_featured_announcements, v_announcement_stats';
    RAISE NOTICE 'Configured RLS policies for public read access and user-specific write access';
END $$;
