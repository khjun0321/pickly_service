-- ============================================
-- Pickly v9.12.0 Implementation Verification Script
-- Purpose: Verify announcement search extension, thumbnails, and featured sections
-- Date: 2025-11-12
-- ============================================

-- ============================================
-- 1️⃣ Verify announcements table new columns
-- ============================================

SELECT
  '=== announcements 테이블 확장 검증 ===' AS verification_section;

SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'announcements'
  AND column_name IN ('thumbnail_url', 'is_featured', 'featured_section', 'featured_order', 'tags', 'searchable_text')
ORDER BY ordinal_position;

-- ============================================
-- 2️⃣ Verify search_index table
-- ============================================

SELECT
  '=== search_index 테이블 검증 ===' AS verification_section;

SELECT
  COUNT(*) AS table_exists
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'search_index';

SELECT
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'search_index'
ORDER BY ordinal_position;

-- ============================================
-- 3️⃣ Verify indexes
-- ============================================

SELECT
  '=== 인덱스 검증 ===' AS verification_section;

SELECT
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND (
    indexname LIKE '%featured%' OR
    indexname LIKE '%search%' OR
    indexname LIKE '%tags%'
  )
ORDER BY indexname;

-- ============================================
-- 4️⃣ Verify functions
-- ============================================

SELECT
  '=== 함수 검증 ===' AS verification_section;

SELECT
  proname AS function_name,
  pg_get_function_identity_arguments(oid) AS arguments,
  prokind AS kind
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

-- ============================================
-- 5️⃣ Verify triggers
-- ============================================

SELECT
  '=== 트리거 검증 ===' AS verification_section;

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

-- ============================================
-- 6️⃣ Verify Storage buckets
-- ============================================

SELECT
  '=== Storage 버킷 검증 ===' AS verification_section;

SELECT
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types,
  created_at
FROM storage.buckets
WHERE id = 'announcement-thumbnails';

-- ============================================
-- 7️⃣ Verify Storage RLS policies
-- ============================================

SELECT
  '=== Storage RLS 정책 검증 ===' AS verification_section;

SELECT
  policyname,
  cmd,
  roles
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND policyname LIKE '%thumb%'
ORDER BY policyname;

-- ============================================
-- 8️⃣ Test search functionality
-- ============================================

SELECT
  '=== 검색 기능 테스트 ===' AS verification_section;

-- Test 1: Check if searchable_text is generated
SELECT
  id,
  title,
  tags,
  searchable_text IS NOT NULL AS has_search_vector
FROM public.announcements
LIMIT 3;

-- Test 2: Test full-text search (example)
-- Note: This will only work if there's data
SELECT
  id,
  title,
  organization,
  tags
FROM public.announcements
WHERE searchable_text @@ plainto_tsquery('simple', '청년')
LIMIT 5;

-- ============================================
-- 9️⃣ Test featured functionality
-- ============================================

SELECT
  '=== 홈 노출 기능 테스트 ===' AS verification_section;

-- Count featured announcements by section
SELECT
  COALESCE(featured_section, 'null') AS section,
  COUNT(*) AS announcement_count
FROM public.announcements
WHERE is_featured = true
GROUP BY featured_section
ORDER BY featured_section;

-- ============================================
-- 🔟 RLS Policies verification
-- ============================================

SELECT
  '=== RLS 정책 검증 ===' AS verification_section;

SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'search_index'
ORDER BY policyname;

-- ============================================
-- 1️⃣1️⃣ Test helper functions
-- ============================================

SELECT
  '=== Helper 함수 테스트 ===' AS verification_section;

-- Test generate_thumbnail_path function
SELECT public.generate_thumbnail_path(
  'e5c5e5e5-1234-5678-90ab-cdef12345678'::UUID,
  'jpg'
) AS sample_thumbnail_path;

-- Test get_featured_announcements function
SELECT * FROM public.get_featured_announcements(NULL, 5);

-- ============================================
-- ✅ Summary Report
-- ============================================

SELECT
  '=== V9.12.0 구현 검증 요약 ===' AS report_title;

SELECT
  'announcements 확장 컬럼' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'announcements' AND column_name = 'searchable_text'
  ) THEN '✅ OK' ELSE '❌ MISSING' END AS status;

SELECT
  'search_index 테이블' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'search_index'
  ) THEN '✅ OK' ELSE '❌ MISSING' END AS status;

SELECT
  'announcement-thumbnails 버킷' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM storage.buckets WHERE id = 'announcement-thumbnails'
  ) THEN '✅ OK' ELSE '❌ MISSING' END AS status;

SELECT
  '검색 함수' AS component,
  COUNT(*)::TEXT || ' 개 함수' AS status
FROM pg_proc
WHERE pronamespace = 'public'::regnamespace
  AND proname IN (
    'sync_search_index_for_announcement',
    'reindex_announcements',
    'search_announcements',
    'get_featured_announcements'
  );

SELECT
  '파이프 트리거' AS component,
  COUNT(*)::TEXT || ' 개 트리거' AS status
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND trigger_name IN (
    'trg_announcements_search_sync',
    'trg_benefit_categories_bump',
    'trg_benefit_subcategories_bump'
  );

SELECT
  'GIN 검색 인덱스' AS component,
  COUNT(*)::TEXT || ' 개 인덱스' AS status
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexdef LIKE '%USING gin%'
  AND (indexname LIKE '%search%' OR indexname LIKE '%tags%');

-- ============================================
-- 📊 Performance Statistics
-- ============================================

SELECT
  '=== 성능 통계 ===' AS stats_section;

SELECT
  COUNT(*) AS total_announcements,
  COUNT(*) FILTER (WHERE is_featured = true) AS featured_count,
  COUNT(*) FILTER (WHERE thumbnail_url IS NOT NULL) AS with_thumbnail_count,
  COUNT(*) FILTER (WHERE tags IS NOT NULL AND array_length(tags, 1) > 0) AS with_tags_count
FROM public.announcements;

SELECT
  COUNT(*) AS search_index_entries,
  COUNT(DISTINCT target_type) AS target_types
FROM public.search_index;
