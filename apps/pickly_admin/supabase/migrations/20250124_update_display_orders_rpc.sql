-- Migration: Add update_display_orders RPC function
-- Purpose: Enable drag-and-drop reordering of benefit announcements
-- Created: 2025-01-24

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS update_display_orders(jsonb);

-- Create function to update display orders in batch
CREATE OR REPLACE FUNCTION update_display_orders(orders jsonb)
RETURNS void AS $$
DECLARE
  item jsonb;
BEGIN
  -- Iterate through each order update
  FOR item IN SELECT * FROM jsonb_array_elements(orders)
  LOOP
    -- Update the announcement's display order
    UPDATE benefit_announcements
    SET
      display_order = (item->>'display_order')::integer,
      updated_at = now()
    WHERE id = (item->>'announcement_id')::uuid;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add comment for documentation
COMMENT ON FUNCTION update_display_orders(jsonb) IS
'Updates display_order for multiple benefit announcements in a single transaction.
Used for drag-and-drop reordering in the admin panel.
Input format: [{"announcement_id": "uuid", "display_order": 0}, ...]';

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION update_display_orders(jsonb) TO authenticated;

-- Optional: Add display_order column if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'benefit_announcements'
    AND column_name = 'display_order'
  ) THEN
    ALTER TABLE benefit_announcements
    ADD COLUMN display_order INTEGER DEFAULT 0;

    -- Initialize display_order based on created_at
    UPDATE benefit_announcements
    SET display_order = sub.row_num - 1
    FROM (
      SELECT id, ROW_NUMBER() OVER (ORDER BY created_at ASC) as row_num
      FROM benefit_announcements
    ) sub
    WHERE benefit_announcements.id = sub.id;
  END IF;
END $$;

-- Add index for performance
CREATE INDEX IF NOT EXISTS idx_benefit_announcements_display_order
ON benefit_announcements(display_order);

-- Add index for category + display order queries
CREATE INDEX IF NOT EXISTS idx_benefit_announcements_category_display
ON benefit_announcements(category_id, display_order);
