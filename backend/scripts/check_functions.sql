-- Check v9.12.0 functions
SELECT
  proname AS function_name,
  pg_get_function_identity_arguments(oid) AS arguments
FROM pg_proc
WHERE pronamespace = 'public'::regnamespace
  AND proname IN (
    'sync_search_index_for_announcement',
    'bump_announcements_by_category',
    'bump_announcements_by_subcategory',
    'reindex_announcements',
    'search_announcements',
    'get_featured_announcements',
    'generate_thumbnail_path'
  )
ORDER BY proname;
