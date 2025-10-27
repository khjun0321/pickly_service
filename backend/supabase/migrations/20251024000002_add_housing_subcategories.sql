-- ================================================================
-- Migration: Add housing sub-categories
-- File: 20251024000002_add_housing_subcategories.sql
-- Description: Add parent_id column and sub-categories for housing
-- ================================================================

-- Add parent_id column to benefit_categories for hierarchical structure
ALTER TABLE benefit_categories
ADD COLUMN IF NOT EXISTS parent_id UUID REFERENCES benefit_categories(id) ON DELETE CASCADE;

-- Add custom_fields column for dynamic form fields
ALTER TABLE benefit_categories
ADD COLUMN IF NOT EXISTS custom_fields JSONB DEFAULT '[]'::jsonb;

-- Get the housing category ID and insert sub-categories
DO $$
DECLARE
  v_housing_id UUID;
BEGIN
  -- Get housing category ID
  SELECT id INTO v_housing_id
  FROM benefit_categories
  WHERE slug = 'housing';

  -- Insert sub-categories for housing
  INSERT INTO benefit_categories (name, slug, parent_id, description, display_order, custom_fields) VALUES
    ('행복주택', 'happy-housing', v_housing_id, 'LH 행복주택 공고', 1, '[
      {"key": "unit_count", "label": "조합수", "type": "number"},
      {"key": "location", "label": "위치", "type": "text"},
      {"key": "supply_type", "label": "공급 유형", "type": "select", "options": ["임대", "분양"]}
    ]'::jsonb),
    ('국민임대주택', 'national-rental', v_housing_id, 'LH 국민임대주택 공고', 2, '[
      {"key": "unit_count", "label": "조합수", "type": "number"},
      {"key": "location", "label": "위치", "type": "text"}
    ]'::jsonb),
    ('영구임대주택', 'permanent-rental', v_housing_id, 'LH 영구임대주택 공고', 3, '[
      {"key": "unit_count", "label": "조합수", "type": "number"},
      {"key": "location", "label": "위치", "type": "text"}
    ]'::jsonb),
    ('매입임대주택', 'purchased-rental', v_housing_id, 'LH 매입임대주택 공고', 4, '[
      {"key": "unit_count", "label": "조합수", "type": "number"},
      {"key": "location", "label": "위치", "type": "text"}
    ]'::jsonb),
    ('신혼희망타운', 'newlywed-hope', v_housing_id, 'LH 신혼희망타운 공고', 5, '[
      {"key": "unit_count", "label": "조합수", "type": "number"},
      {"key": "location", "label": "위치", "type": "text"}
    ]'::jsonb)
  ON CONFLICT (slug) DO NOTHING;

END $$;

-- Completion log
DO $$
BEGIN
    RAISE NOTICE 'Migration 20251024000002_add_housing_subcategories.sql completed successfully';
    RAISE NOTICE 'Added 5 housing sub-categories: 행복주택, 국민임대주택, 영구임대주택, 매입임대주택, 신혼희망타운';
END $$;
