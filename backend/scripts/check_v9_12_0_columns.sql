-- Check v9.12.0 columns in announcements table
SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'announcements'
  AND column_name IN (
    'thumbnail_url',
    'is_featured',
    'featured_section',
    'featured_order',
    'tags',
    'searchable_text'
  )
ORDER BY ordinal_position;
