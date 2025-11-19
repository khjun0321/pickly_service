-- ============================================
-- Production Status Check - v9.12.0 Pre-Deployment
-- Purpose: Verify current Production state before applying v9.12.0
-- Date: 2025-11-12
-- Project: vymxxpjxrorpywfmqpuk (READ-ONLY)
-- ============================================

\echo '============================================'
\echo '📊 Pickly Production Status Check v9.12.0'
\echo '============================================'
\echo ''

-- ============================================
-- 1️⃣ Check v9.12.0 announcements columns
-- ============================================

\echo '1️⃣ Announcements Table - v9.12.0 Columns Check:'
\echo '------------------------------------------------'

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

\echo ''
\echo '✅ Expected: 6 columns if v9.12.0 applied, 0 if not yet applied'
\echo ''

-- ============================================
-- 2️⃣ Check search_index table
-- ============================================

\echo '2️⃣ Search Index Table Check:'
\echo '----------------------------'

SELECT
  EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'search_index'
  ) AS search_index_exists;

\echo ''
\echo '✅ Expected: true if v9.12.0 applied, false if not'
\echo ''

-- ============================================
-- 3️⃣ Check Storage buckets
-- ============================================

\echo '3️⃣ Storage Buckets Check:'
\echo '-------------------------'

SELECT
  id,
  name,
  public,
  file_size_limit,
  array_length(allowed_mime_types, 1) AS mime_type_count
FROM storage.buckets
WHERE id IN (
  'announcement-thumbnails',
  'announcement-pdfs',
  'announcement-images'
)
ORDER BY id;

\echo ''
\echo '✅ Expected: 3 buckets (pdfs, images from v9.11.3; thumbnails from v9.12.0)'
\echo ''

-- ============================================
-- 4️⃣ Check v9.12.0 functions
-- ============================================

\echo '4️⃣ v9.12.0 Functions Check:'
\echo '---------------------------'

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

\echo ''
\echo '✅ Expected: 7 functions if v9.12.0 applied, 0-1 if not'
\echo ''

-- ============================================
-- 5️⃣ Check v9.12.0 triggers
-- ============================================

\echo '5️⃣ v9.12.0 Triggers Check:'
\echo '-------------------------'

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

\echo ''
\echo '✅ Expected: 3 triggers if v9.12.0 applied, 0 if not'
\echo ''

-- ============================================
-- 6️⃣ Check v9.12.0 indexes
-- ============================================

\echo '6️⃣ v9.12.0 Indexes Check:'
\echo '------------------------'

SELECT
  indexname,
  tablename,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND (
    indexname LIKE '%searchable%' OR
    indexname LIKE '%tags%' OR
    indexname LIKE '%featured%'
  )
ORDER BY indexname;

\echo ''
\echo '✅ Expected: 4 indexes if v9.12.0 applied, 0 if not'
\echo ''

-- ============================================
-- 7️⃣ Check Storage RLS policies
-- ============================================

\echo '7️⃣ Storage RLS Policies Check:'
\echo '------------------------------'

SELECT
  policyname,
  cmd,
  roles
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND (
    policyname LIKE '%thumb%' OR
    policyname LIKE '%pdf%' OR
    policyname LIKE '%image%'
  )
ORDER BY policyname;

\echo ''
\echo '✅ Expected: 12 policies (4 per bucket) if all migrations applied'
\echo ''

-- ============================================
-- 8️⃣ Current announcements data sample
-- ============================================

\echo '8️⃣ Current Announcements Sample:'
\echo '--------------------------------'

SELECT
  id,
  title,
  organization,
  status,
  created_at
FROM public.announcements
ORDER BY created_at DESC
LIMIT 5;

\echo ''
\echo '✅ Shows latest 5 announcements in Production'
\echo ''

-- ============================================
-- 9️⃣ Migration history check
-- ============================================

\echo '9️⃣ Applied Migrations Check:'
\echo '----------------------------'

SELECT
  version,
  name,
  inserted_at
FROM supabase_migrations.schema_migrations
WHERE version >= '20251112000000'
ORDER BY version DESC;

\echo ''
\echo '✅ Shows migrations applied since 2025-11-12'
\echo ''

-- ============================================
-- 🔟 Summary Report
-- ============================================

\echo '🔟 Summary Report:'
\echo '-----------------'

SELECT
  'announcements.thumbnail_url' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'announcements' AND column_name = 'thumbnail_url'
  ) THEN '✅ EXISTS' ELSE '❌ NOT FOUND' END AS status
UNION ALL
SELECT
  'announcements.is_featured' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'announcements' AND column_name = 'is_featured'
  ) THEN '✅ EXISTS' ELSE '❌ NOT FOUND' END AS status
UNION ALL
SELECT
  'announcements.searchable_text' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'announcements' AND column_name = 'searchable_text'
  ) THEN '✅ EXISTS' ELSE '❌ NOT FOUND' END AS status
UNION ALL
SELECT
  'search_index table' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'search_index'
  ) THEN '✅ EXISTS' ELSE '❌ NOT FOUND' END AS status
UNION ALL
SELECT
  'announcement-thumbnails bucket' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM storage.buckets WHERE id = 'announcement-thumbnails'
  ) THEN '✅ EXISTS' ELSE '❌ NOT FOUND' END AS status
UNION ALL
SELECT
  'v9.12.0 functions' AS component,
  (SELECT COUNT(*)::TEXT || ' found' FROM pg_proc
   WHERE pronamespace = 'public'::regnamespace
   AND proname IN (
     'sync_search_index_for_announcement',
     'reindex_announcements',
     'search_announcements'
   )) AS status
UNION ALL
SELECT
  'v9.12.0 triggers' AS component,
  (SELECT COUNT(*)::TEXT || ' found' FROM information_schema.triggers
   WHERE trigger_schema = 'public'
   AND trigger_name IN (
     'trg_announcements_search_sync',
     'trg_benefit_categories_bump'
   )) AS status;

\echo ''
\echo '============================================'
\echo '✅ Production Status Check Complete'
\echo '============================================'
