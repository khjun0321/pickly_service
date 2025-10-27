-- ================================================================
-- Migration: Add display_order and banner fields for benefit system
-- File: 20251024000001_add_display_order_and_banner.sql
-- Description: Add missing fields for drag-and-drop and banner management
-- ================================================================

-- 1. Add display_order to benefit_announcements
ALTER TABLE benefit_announcements
ADD COLUMN IF NOT EXISTS display_order INTEGER NOT NULL DEFAULT 0;

-- Create index for display_order
CREATE INDEX IF NOT EXISTS idx_announcements_display_order
  ON benefit_announcements(category_id, display_order, created_at DESC);

-- 2. Add banner fields to benefit_categories
ALTER TABLE benefit_categories
ADD COLUMN IF NOT EXISTS banner_enabled BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS banner_image_url TEXT,
ADD COLUMN IF NOT EXISTS banner_link_url TEXT,
ADD COLUMN IF NOT EXISTS custom_fields JSONB DEFAULT '[]'::jsonb;

-- 3. Create RPC function for updating display orders
CREATE OR REPLACE FUNCTION update_display_orders(
  orders JSONB
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  order_item JSONB;
BEGIN
  -- Loop through each order update
  FOR order_item IN SELECT * FROM jsonb_array_elements(orders)
  LOOP
    UPDATE benefit_announcements
    SET
      display_order = (order_item->>'display_order')::INTEGER,
      updated_at = NOW()
    WHERE id = (order_item->>'announcement_id')::UUID;
  END LOOP;
END;
$$;

-- 4. Add custom_fields examples for categories
UPDATE benefit_categories
SET custom_fields = '[
  {"key": "unit_count", "label": "조합수", "type": "number"},
  {"key": "location", "label": "위치", "type": "text"},
  {"key": "supply_type", "label": "공급 유형", "type": "select", "options": ["임대", "분양"]}
]'::jsonb
WHERE slug = 'housing';

UPDATE benefit_categories
SET custom_fields = '[
  {"key": "funding_amount", "label": "지원금액", "type": "text"},
  {"key": "support_period", "label": "지원기간", "type": "text"}
]'::jsonb
WHERE slug = 'employment';

UPDATE benefit_categories
SET custom_fields = '[
  {"key": "scholarship_amount", "label": "장학금액", "type": "text"},
  {"key": "eligibility", "label": "자격요건", "type": "text"}
]'::jsonb
WHERE slug = 'education';

-- 5. Grant execute permission on RPC function
GRANT EXECUTE ON FUNCTION update_display_orders(JSONB) TO authenticated, anon;

-- Completion log
DO $$
BEGIN
    RAISE NOTICE 'Migration 20251024000001_add_display_order_and_banner.sql completed successfully';
    RAISE NOTICE 'Added display_order to benefit_announcements';
    RAISE NOTICE 'Added banner fields to benefit_categories';
    RAISE NOTICE 'Created update_display_orders RPC function';
END $$;
