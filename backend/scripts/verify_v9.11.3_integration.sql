-- ============================================
-- Pickly v9.11.3 Integration Verification Script
-- Purpose: Verify announcement_details, announcement_complex_info tables and Storage buckets
-- Date: 2025-11-11
-- ============================================

-- 1️⃣ Check announcement_details table
SELECT
  'announcement_details' AS table_name,
  COUNT(*) AS total_count
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'announcement_details';

-- Check columns
SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'announcement_details'
ORDER BY ordinal_position;

-- 2️⃣ Check announcement_complex_info table
SELECT
  'announcement_complex_info' AS table_name,
  COUNT(*) AS total_count
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'announcement_complex_info';

-- Check columns
SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'announcement_complex_info'
ORDER BY ordinal_position;

-- 3️⃣ Check announcements table new fields
SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'announcements'
  AND column_name IN ('pdf_url', 'source_type', 'external_id')
ORDER BY ordinal_position;

-- 4️⃣ Check Storage buckets
SELECT
  id AS bucket_id,
  name,
  public,
  file_size_limit,
  allowed_mime_types,
  created_at
FROM storage.buckets
WHERE id IN ('announcement-pdfs', 'announcement-images', 'pickly-storage', 'icons', 'age-icons')
ORDER BY created_at;

-- 5️⃣ Check RLS policies for announcement_details
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'announcement_details'
ORDER BY policyname;

-- 6️⃣ Check RLS policies for announcement_complex_info
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'announcement_complex_info'
ORDER BY policyname;

-- 7️⃣ Check Storage RLS policies
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  substring(qual::text, 1, 100) AS qual_preview
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND policyname LIKE '%announcement%'
ORDER BY policyname;

-- 8️⃣ Check indexes
SELECT
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND (
    tablename = 'announcement_details' OR
    tablename = 'announcement_complex_info' OR
    (tablename = 'announcements' AND indexname LIKE '%source%') OR
    (tablename = 'announcements' AND indexname LIKE '%external%')
  )
ORDER BY tablename, indexname;

-- 9️⃣ Check triggers
SELECT
  trigger_schema,
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE event_object_schema = 'public'
  AND event_object_table IN ('announcement_details', 'announcement_complex_info')
ORDER BY event_object_table, trigger_name;

-- 🔟 Summary Report
SELECT
  '=== V9.11.3 INTEGRATION VERIFICATION SUMMARY ===' AS report_title;

SELECT
  'announcements table' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'announcements' AND column_name = 'pdf_url'
  ) THEN '✅ READY' ELSE '❌ MISSING' END AS status;

SELECT
  'announcement_details table' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'announcement_details'
  ) THEN '✅ READY' ELSE '❌ MISSING' END AS status;

SELECT
  'announcement_complex_info table' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'announcement_complex_info'
  ) THEN '✅ READY' ELSE '❌ MISSING' END AS status;

SELECT
  'announcement-pdfs bucket' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM storage.buckets WHERE id = 'announcement-pdfs'
  ) THEN '✅ READY' ELSE '❌ MISSING' END AS status;

SELECT
  'announcement-images bucket' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM storage.buckets WHERE id = 'announcement-images'
  ) THEN '✅ READY' ELSE '❌ MISSING' END AS status;

SELECT
  'RLS policies count' AS component,
  CONCAT(COUNT(*), ' policies') AS status
FROM pg_policies
WHERE tablename IN ('announcement_details', 'announcement_complex_info')
  AND schemaname = 'public';
