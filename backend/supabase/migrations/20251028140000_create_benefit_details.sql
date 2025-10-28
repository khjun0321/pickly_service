-- ============================================
-- Benefit Details Table Migration
-- PRD v9.0 - Add benefit_details layer
-- ============================================
-- Date: 2025-10-28
-- Purpose: Create benefit_details table for policies/programs
--          (e.g., 행복주택, 국민임대주택, 영구임대주택)
--
-- Hierarchy:
-- benefit_categories (주거, 교육, etc.)
--   └── benefit_details (행복주택, 국민임대주택)
--       └── benefit_announcements (individual announcements)
-- ============================================

-- Create benefit_details table
CREATE TABLE IF NOT EXISTS benefit_details (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  benefit_category_id uuid NOT NULL REFERENCES benefit_categories(id) ON DELETE CASCADE,

  -- Basic info
  title varchar(100) NOT NULL,
  description text,
  icon_url text,

  -- Display settings
  sort_order integer NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,

  -- Metadata
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),

  -- Constraints
  CONSTRAINT benefit_details_title_not_empty CHECK (char_length(title) > 0),
  CONSTRAINT benefit_details_sort_order_positive CHECK (sort_order >= 0)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_benefit_details_category_id
  ON benefit_details(benefit_category_id);

CREATE INDEX IF NOT EXISTS idx_benefit_details_sort_order
  ON benefit_details(sort_order);

CREATE INDEX IF NOT EXISTS idx_benefit_details_is_active
  ON benefit_details(is_active) WHERE is_active = true;

-- Enable RLS
ALTER TABLE benefit_details ENABLE ROW LEVEL SECURITY;

-- Public read access policy
CREATE POLICY "Public read access" ON benefit_details
  FOR SELECT USING (is_active = true);

-- Admin write access (to be implemented with proper auth)
-- CREATE POLICY "Admin write access" ON benefit_details
--   FOR ALL USING (auth.role() = 'admin');

-- Create trigger for updated_at
CREATE TRIGGER update_benefit_details_updated_at
  BEFORE UPDATE ON benefit_details
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Add comments
COMMENT ON TABLE benefit_details IS 'Benefit policies/programs - PRD v9.0 (e.g., 행복주택, 국민임대주택)';
COMMENT ON COLUMN benefit_details.benefit_category_id IS 'FK to benefit_categories - parent category';
COMMENT ON COLUMN benefit_details.title IS 'Policy/program name (e.g., 행복주택, 국민임대주택)';
COMMENT ON COLUMN benefit_details.description IS 'Policy/program description';
COMMENT ON COLUMN benefit_details.icon_url IS 'Optional icon URL from benefit-icons bucket';
COMMENT ON COLUMN benefit_details.sort_order IS 'Display order in UI';
COMMENT ON COLUMN benefit_details.is_active IS 'Whether this policy is active/visible';

-- Insert sample data for 주거 category
DO $$
DECLARE
  housing_category_id uuid;
BEGIN
  -- Get 주거 category ID
  SELECT id INTO housing_category_id
  FROM benefit_categories
  WHERE slug = 'housing'
  LIMIT 1;

  -- Only insert if housing category exists
  IF housing_category_id IS NOT NULL THEN
    INSERT INTO benefit_details (benefit_category_id, title, description, sort_order) VALUES
      (housing_category_id, '행복주택', '대학생, 사회초년생, 신혼부부 등을 위한 공공임대주택', 1),
      (housing_category_id, '국민임대주택', '저소득층을 위한 장기 임대주택', 2),
      (housing_category_id, '영구임대주택', '기초생활수급자 등을 위한 영구 임대주택', 3)
    ON CONFLICT DO NOTHING;
  END IF;
END $$;

-- ============================================
-- Migration Complete
-- ============================================
