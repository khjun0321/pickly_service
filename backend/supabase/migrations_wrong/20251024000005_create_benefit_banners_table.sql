-- ================================================================
-- Migration: Create benefit_banners table for multiple banners
-- File: 20251024000005_create_benefit_banners_table.sql
-- Description: Support multiple banners per category
-- ================================================================

-- Create benefit_banners table
CREATE TABLE IF NOT EXISTS benefit_banners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES benefit_categories(id) ON DELETE CASCADE,

    -- Banner Information
    title VARCHAR(255),
    image_url TEXT NOT NULL,
    link_url TEXT,

    -- Display Settings
    display_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints
    CONSTRAINT banners_image_url_not_empty CHECK (char_length(image_url) > 0),
    CONSTRAINT banners_display_order_positive CHECK (display_order >= 0)
);

-- Indexes
CREATE INDEX idx_banners_category ON benefit_banners(category_id);
CREATE INDEX idx_banners_display_order ON benefit_banners(category_id, display_order);
CREATE INDEX idx_banners_active ON benefit_banners(is_active) WHERE is_active = TRUE;

-- Trigger for updated_at
CREATE TRIGGER update_benefit_banners_updated_at
    BEFORE UPDATE ON benefit_banners
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- RLS Policies
ALTER TABLE benefit_banners ENABLE ROW LEVEL SECURITY;

-- Public can view active banners
CREATE POLICY "Public can view active banners"
    ON benefit_banners FOR SELECT
    USING (is_active = TRUE);

-- Comments
COMMENT ON TABLE benefit_banners IS '혜택 카테고리별 배너 (여러 개 등록 가능)';
COMMENT ON COLUMN benefit_banners.display_order IS '배너 표시 순서 (작을수록 먼저 표시)';

-- Completion log
DO $$
BEGIN
    RAISE NOTICE 'Migration 20251024000005_create_benefit_banners_table.sql completed successfully';
    RAISE NOTICE 'Created benefit_banners table for multiple banners per category';
END $$;
