-- Check v9.12.0 triggers
SELECT
  trigger_name,
  event_object_table,
  action_timing,
  event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND trigger_name IN (
    'trg_announcements_search_sync',
    'trg_benefit_categories_bump',
    'trg_benefit_subcategories_bump'
  )
ORDER BY trigger_name;
