-- ============================================
-- Pickly Service - Category Banners Schema
-- ============================================
-- Version: 1.0.0
-- Description: Database schema for category-specific advertisement banners
-- Author: Backend Team
-- Date: 2025-10-16
-- ============================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- Main Table: category_banners
-- ============================================
CREATE TABLE IF NOT EXISTS category_banners (
  -- Primary identification
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Category information
  category_id VARCHAR(20) NOT NULL,

  -- Banner content
  title VARCHAR(100) NOT NULL,
  subtitle VARCHAR(200),
  image_url TEXT NOT NULL,
  background_color VARCHAR(7) DEFAULT '#FF6B35',

  -- Action configuration
  action_type VARCHAR(20) DEFAULT 'internal_link',
  action_url TEXT,

  -- Display settings
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,

  -- Scheduling
  start_date TIMESTAMP WITH TIME ZONE,
  end_date TIMESTAMP WITH TIME ZONE,

  -- Analytics
  impression_count INTEGER DEFAULT 0,
  click_count INTEGER DEFAULT 0,

  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Constraints
  CONSTRAINT valid_category CHECK (
    category_id IN (
      'popular',        -- 인기
      'housing',        -- 주거
      'education',      -- 교육
      'support',        -- 지원
      'transportation', -- 교통
      'welfare',        -- 복지
      'clothing',       -- 의류
      'food',           -- 식품
      'culture'         -- 문화
    )
  ),
  CONSTRAINT valid_action_type CHECK (
    action_type IN ('internal_link', 'external_link', 'deep_link', 'none')
  ),
  CONSTRAINT valid_dates CHECK (
    start_date IS NULL OR end_date IS NULL OR start_date <= end_date
  ),
  CONSTRAINT valid_display_order CHECK (display_order >= 0),
  CONSTRAINT valid_impression_count CHECK (impression_count >= 0),
  CONSTRAINT valid_click_count CHECK (click_count >= 0)
);

-- ============================================
-- Indexes for Performance
-- ============================================

-- Index for category-based queries
CREATE INDEX IF NOT EXISTS idx_category_banners_category
  ON category_banners(category_id);

-- Index for active status filtering
CREATE INDEX IF NOT EXISTS idx_category_banners_active
  ON category_banners(is_active);

-- Composite index for ordered category queries
CREATE INDEX IF NOT EXISTS idx_category_banners_category_order
  ON category_banners(category_id, display_order)
  WHERE is_active = true;

-- Index for date-based filtering
CREATE INDEX IF NOT EXISTS idx_category_banners_dates
  ON category_banners(start_date, end_date)
  WHERE is_active = true;

-- Index for analytics queries
CREATE INDEX IF NOT EXISTS idx_category_banners_analytics
  ON category_banners(impression_count, click_count);

-- ============================================
-- Triggers
-- ============================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_category_banners_updated_at
  BEFORE UPDATE ON category_banners
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Validate dates on insert/update
CREATE OR REPLACE FUNCTION validate_banner_dates()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if banner is active but has expired
  IF NEW.is_active = true AND NEW.end_date IS NOT NULL AND NEW.end_date < NOW() THEN
    RAISE EXCEPTION 'Cannot activate banner with expired end_date';
  END IF;

  -- Check if banner has future start date but is active
  IF NEW.is_active = true AND NEW.start_date IS NOT NULL AND NEW.start_date > NOW() THEN
    RAISE WARNING 'Banner is active but has future start_date';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_category_banners_dates
  BEFORE INSERT OR UPDATE ON category_banners
  FOR EACH ROW
  EXECUTE FUNCTION validate_banner_dates();

-- ============================================
-- Views
-- ============================================

-- View: Active banners with computed analytics
CREATE OR REPLACE VIEW active_category_banners AS
SELECT
  id,
  category_id,
  title,
  subtitle,
  image_url,
  background_color,
  action_type,
  action_url,
  display_order,
  is_active,
  start_date,
  end_date,
  impression_count,
  click_count,
  CASE
    WHEN impression_count > 0 THEN
      ROUND((click_count::DECIMAL / impression_count::DECIMAL) * 100, 2)
    ELSE 0
  END as ctr_percentage,
  created_at,
  updated_at
FROM category_banners
WHERE is_active = true
  AND (start_date IS NULL OR start_date <= NOW())
  AND (end_date IS NULL OR end_date >= NOW())
ORDER BY category_id, display_order;

-- View: Banner analytics by category
CREATE OR REPLACE VIEW banner_analytics AS
SELECT
  category_id,
  COUNT(*) as total_banners,
  COUNT(*) FILTER (WHERE is_active = true) as active_banners,
  SUM(impression_count) as total_impressions,
  SUM(click_count) as total_clicks,
  CASE
    WHEN SUM(impression_count) > 0 THEN
      ROUND((SUM(click_count)::DECIMAL / SUM(impression_count)::DECIMAL) * 100, 2)
    ELSE 0
  END as avg_ctr_percentage,
  MAX(updated_at) as last_updated
FROM category_banners
GROUP BY category_id
ORDER BY total_clicks DESC;

-- View: Scheduled banners (upcoming and expired)
CREATE OR REPLACE VIEW scheduled_banners AS
SELECT
  id,
  category_id,
  title,
  start_date,
  end_date,
  is_active,
  CASE
    WHEN start_date > NOW() THEN 'scheduled'
    WHEN end_date < NOW() THEN 'expired'
    ELSE 'active'
  END as schedule_status
FROM category_banners
WHERE start_date IS NOT NULL OR end_date IS NOT NULL
ORDER BY
  CASE
    WHEN start_date > NOW() THEN start_date
    WHEN end_date < NOW() THEN end_date
    ELSE NOW()
  END;

-- ============================================
-- Functions
-- ============================================

-- Function: Get active banners for a specific category
CREATE OR REPLACE FUNCTION get_active_banners(p_category_id VARCHAR)
RETURNS TABLE (
  id UUID,
  category_id VARCHAR,
  title VARCHAR,
  subtitle VARCHAR,
  image_url TEXT,
  background_color VARCHAR,
  action_type VARCHAR,
  action_url TEXT,
  display_order INTEGER,
  impression_count INTEGER,
  click_count INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    cb.id,
    cb.category_id,
    cb.title,
    cb.subtitle,
    cb.image_url,
    cb.background_color,
    cb.action_type,
    cb.action_url,
    cb.display_order,
    cb.impression_count,
    cb.click_count
  FROM category_banners cb
  WHERE cb.category_id = p_category_id
    AND cb.is_active = true
    AND (cb.start_date IS NULL OR cb.start_date <= NOW())
    AND (cb.end_date IS NULL OR cb.end_date >= NOW())
  ORDER BY cb.display_order ASC;
END;
$$ LANGUAGE plpgsql STABLE;

-- Function: Get all active banners grouped by category
CREATE OR REPLACE FUNCTION get_all_active_banners()
RETURNS TABLE (
  category_id VARCHAR,
  banners JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    cb.category_id,
    jsonb_agg(
      jsonb_build_object(
        'id', cb.id,
        'title', cb.title,
        'subtitle', cb.subtitle,
        'imageUrl', cb.image_url,
        'backgroundColor', cb.background_color,
        'actionType', cb.action_type,
        'actionUrl', cb.action_url,
        'displayOrder', cb.display_order
      ) ORDER BY cb.display_order
    ) as banners
  FROM category_banners cb
  WHERE cb.is_active = true
    AND (cb.start_date IS NULL OR cb.start_date <= NOW())
    AND (cb.end_date IS NULL OR cb.end_date >= NOW())
  GROUP BY cb.category_id;
END;
$$ LANGUAGE plpgsql STABLE;

-- Function: Increment banner impression count
CREATE OR REPLACE FUNCTION increment_banner_impression(p_banner_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE category_banners
  SET impression_count = impression_count + 1,
      updated_at = NOW()
  WHERE id = p_banner_id;
END;
$$ LANGUAGE plpgsql;

-- Function: Increment banner click count
CREATE OR REPLACE FUNCTION increment_banner_click(p_banner_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE category_banners
  SET click_count = click_count + 1,
      updated_at = NOW()
  WHERE id = p_banner_id;
END;
$$ LANGUAGE plpgsql;

-- Function: Batch increment impressions
CREATE OR REPLACE FUNCTION batch_increment_impressions(p_banner_ids UUID[])
RETURNS VOID AS $$
BEGIN
  UPDATE category_banners
  SET impression_count = impression_count + 1,
      updated_at = NOW()
  WHERE id = ANY(p_banner_ids);
END;
$$ LANGUAGE plpgsql;

-- Function: Get banner performance metrics
CREATE OR REPLACE FUNCTION get_banner_metrics(p_banner_id UUID)
RETURNS TABLE (
  id UUID,
  title VARCHAR,
  category_id VARCHAR,
  impression_count INTEGER,
  click_count INTEGER,
  ctr_percentage NUMERIC,
  days_active INTEGER,
  avg_impressions_per_day NUMERIC,
  avg_clicks_per_day NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    cb.id,
    cb.title,
    cb.category_id,
    cb.impression_count,
    cb.click_count,
    CASE
      WHEN cb.impression_count > 0 THEN
        ROUND((cb.click_count::DECIMAL / cb.impression_count::DECIMAL) * 100, 2)
      ELSE 0
    END as ctr_percentage,
    GREATEST(EXTRACT(DAY FROM NOW() - cb.created_at)::INTEGER, 1) as days_active,
    ROUND(
      cb.impression_count::DECIMAL /
      GREATEST(EXTRACT(DAY FROM NOW() - cb.created_at), 1),
      2
    ) as avg_impressions_per_day,
    ROUND(
      cb.click_count::DECIMAL /
      GREATEST(EXTRACT(DAY FROM NOW() - cb.created_at), 1),
      2
    ) as avg_clicks_per_day
  FROM category_banners cb
  WHERE cb.id = p_banner_id;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================
-- Row Level Security (RLS)
-- ============================================

-- Enable RLS
ALTER TABLE category_banners ENABLE ROW LEVEL SECURITY;

-- Policy: Public users can view active banners
CREATE POLICY "Public can view active banners"
  ON category_banners
  FOR SELECT
  USING (
    is_active = true
    AND (start_date IS NULL OR start_date <= NOW())
    AND (end_date IS NULL OR end_date >= NOW())
  );

-- Policy: Authenticated admins can manage all banners
CREATE POLICY "Admins can manage all banners"
  ON category_banners
  FOR ALL
  USING (
    auth.role() = 'authenticated'
    AND auth.jwt() ->> 'role' = 'admin'
  );

-- Policy: Allow analytics updates (impressions and clicks)
CREATE POLICY "Allow analytics tracking"
  ON category_banners
  FOR UPDATE
  USING (true)
  WITH CHECK (
    -- Only allow updating analytics fields
    (OLD.id = NEW.id) AND
    (OLD.category_id = NEW.category_id) AND
    (OLD.title = NEW.title) AND
    (OLD.subtitle = NEW.subtitle) AND
    (OLD.image_url = NEW.image_url) AND
    (OLD.background_color = NEW.background_color) AND
    (OLD.action_type = NEW.action_type) AND
    (OLD.action_url = NEW.action_url) AND
    (OLD.display_order = NEW.display_order) AND
    (OLD.is_active = NEW.is_active) AND
    (OLD.start_date = NEW.start_date) AND
    (OLD.end_date = NEW.end_date)
  );

-- ============================================
-- Seed Data (Development)
-- ============================================

-- Insert sample banners for each category
INSERT INTO category_banners (category_id, title, subtitle, image_url, background_color, action_type, action_url, display_order, is_active)
VALUES
  -- Popular category (인기)
  ('popular', '당첨 후기 작성하고 선물 받자', '경험을 함께 나누어 주세요.', 'https://placehold.co/132x132', '#FF6B35', 'internal_link', '/reviews/create', 0, true),
  ('popular', '지금 가장 인기있는 혜택', '놓치지 마세요!', 'https://placehold.co/132x132', '#4ECDC4', 'internal_link', '/benefits/trending', 1, true),

  -- Housing category (주거)
  ('housing', '청년 전세대출 신청하기', '최대 2억원 지원', 'https://placehold.co/132x132', '#95E1D3', 'internal_link', '/housing/loan', 0, true),
  ('housing', '신혼부부 주거 지원', '합리적인 내 집 마련', 'https://placehold.co/132x132', '#F38181', 'internal_link', '/housing/newlywed', 1, true),

  -- Education category (교육)
  ('education', '무료 코딩 교육 수강하기', '취업까지 책임지는 부트캠프', 'https://placehold.co/132x132', '#AA96DA', 'external_link', 'https://education.example.com', 0, true),
  ('education', '자격증 취득 지원 사업', '응시료 100% 환급', 'https://placehold.co/132x132', '#FCBAD3', 'internal_link', '/education/certificate', 1, true),

  -- Support category (지원)
  ('support', '청년 구직활동 지원금', '월 50만원 최대 6개월', 'https://placehold.co/132x132', '#FFFFD2', 'internal_link', '/support/job-search', 0, true),
  ('support', '소상공인 창업 지원금', '최대 1000만원 지원', 'https://placehold.co/132x132', '#A8D8EA', 'internal_link', '/support/startup', 1, true),

  -- Transportation category (교통)
  ('transportation', '대중교통 정기권 할인', '최대 30% 할인 혜택', 'https://placehold.co/132x132', '#FFB6B9', 'internal_link', '/transportation/pass', 0, true),

  -- Welfare category (복지)
  ('welfare', '건강검진 무료 지원', '30세 이상 누구나', 'https://placehold.co/132x132', '#BAE1FF', 'internal_link', '/welfare/health', 0, true),

  -- Clothing category (의류)
  ('clothing', '명품 아울렛 특가전', '최대 70% 할인', 'https://placehold.co/132x132', '#FFEAA7', 'external_link', 'https://outlet.example.com', 0, true),

  -- Food category (식품)
  ('food', '농산물 직거래 장터', '신선한 식재료 직배송', 'https://placehold.co/132x132', '#DFE6E9', 'internal_link', '/food/market', 0, true),

  -- Culture category (문화)
  ('culture', '공연 티켓 50% 할인', '청년 문화패스 혜택', 'https://placehold.co/132x132', '#FD79A8', 'internal_link', '/culture/tickets', 0, true)
ON CONFLICT DO NOTHING;

-- ============================================
-- Maintenance Procedures
-- ============================================

-- Procedure: Auto-deactivate expired banners
CREATE OR REPLACE FUNCTION auto_deactivate_expired_banners()
RETURNS INTEGER AS $$
DECLARE
  affected_count INTEGER;
BEGIN
  UPDATE category_banners
  SET is_active = false,
      updated_at = NOW()
  WHERE is_active = true
    AND end_date IS NOT NULL
    AND end_date < NOW();

  GET DIAGNOSTICS affected_count = ROW_COUNT;
  RETURN affected_count;
END;
$$ LANGUAGE plpgsql;

-- Procedure: Reset analytics for a banner
CREATE OR REPLACE FUNCTION reset_banner_analytics(p_banner_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE category_banners
  SET impression_count = 0,
      click_count = 0,
      updated_at = NOW()
  WHERE id = p_banner_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- Comments for Documentation
-- ============================================

COMMENT ON TABLE category_banners IS 'Stores category-specific advertisement banners for the benefits screen';
COMMENT ON COLUMN category_banners.category_id IS 'Category identifier: popular, housing, education, support, transportation, welfare, clothing, food, culture';
COMMENT ON COLUMN category_banners.action_type IS 'Type of action when banner is tapped: internal_link, external_link, deep_link, none';
COMMENT ON COLUMN category_banners.display_order IS 'Order in which banners are displayed within a category (lower = higher priority)';
COMMENT ON COLUMN category_banners.impression_count IS 'Number of times the banner was displayed to users';
COMMENT ON COLUMN category_banners.click_count IS 'Number of times the banner was clicked by users';

-- ============================================
-- Grant Permissions
-- ============================================

-- Grant access to authenticated users
GRANT SELECT ON category_banners TO authenticated;
GRANT SELECT ON active_category_banners TO authenticated;
GRANT SELECT ON banner_analytics TO authenticated;
GRANT SELECT ON scheduled_banners TO authenticated;

-- Grant execute permissions on functions
GRANT EXECUTE ON FUNCTION get_active_banners(VARCHAR) TO authenticated;
GRANT EXECUTE ON FUNCTION get_all_active_banners() TO authenticated;
GRANT EXECUTE ON FUNCTION increment_banner_impression(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION increment_banner_click(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_banner_metrics(UUID) TO authenticated;

-- ============================================
-- End of Schema
-- ============================================
