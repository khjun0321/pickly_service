-- Check if search_index table exists
SELECT
  EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'search_index'
  ) AS search_index_exists;
