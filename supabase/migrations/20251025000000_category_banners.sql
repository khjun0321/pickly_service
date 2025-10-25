-- Category Banners Table
-- Promotional banners for each benefit category
-- Used in the mobile app benefits screen to highlight featured content

CREATE TABLE IF NOT EXISTS category_banners (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category_id UUID NOT NULL REFERENCES benefit_categories(id) ON DELETE CASCADE,
  title VARCHAR(100) NOT NULL,
  subtitle VARCHAR(200),
  image_url TEXT NOT NULL,
  background_color VARCHAR(20) DEFAULT '#E3F2FD',
  action_url TEXT,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_category_banners_category ON category_banners(category_id);
CREATE INDEX idx_category_banners_active ON category_banners(is_active) WHERE is_active = true;
CREATE INDEX idx_category_banners_order ON category_banners(display_order);

-- Auto-update timestamp trigger
CREATE TRIGGER update_category_banners_updated_at
  BEFORE UPDATE ON category_banners
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RLS Policies
ALTER TABLE category_banners ENABLE ROW LEVEL SECURITY;

-- Public can view active banners
CREATE POLICY "Public can view active banners"
  ON category_banners FOR SELECT
  TO public
  USING (is_active = true);

-- Admins can manage all banners (permissive for development)
CREATE POLICY "Admins can manage banners"
  ON category_banners FOR ALL
  TO public
  USING (true)
  WITH CHECK (true);

-- Comments
COMMENT ON TABLE category_banners IS 'Promotional banners for benefit categories in the mobile app';
COMMENT ON COLUMN category_banners.category_id IS 'Reference to benefit_categories table';
COMMENT ON COLUMN category_banners.background_color IS 'Hex color code for banner background (e.g., #E3F2FD)';
COMMENT ON COLUMN category_banners.display_order IS 'Order in which banners appear (lower = higher priority)';
