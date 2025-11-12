-- ============================================
-- Schema v2.0 Validation Script
-- 실행: psql -f validate_schema_v2.sql
-- ============================================

-- ============================================
-- 1. 테이블 존재 확인
-- ============================================

\echo '=== Validating Tables ==='

SELECT
  CASE
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'announcement_types')
    THEN '✅ announcement_types exists'
    ELSE '❌ announcement_types NOT FOUND'
  END as table_check;

-- ============================================
-- 2. 컬럼 존재 확인
-- ============================================

\echo '=== Validating Columns ==='

SELECT
  CASE
    WHEN EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'announcement_sections'
        AND column_name = 'is_custom'
    )
    THEN '✅ announcement_sections.is_custom exists'
    ELSE '❌ announcement_sections.is_custom NOT FOUND'
  END as is_custom_check;

SELECT
  CASE
    WHEN EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'announcement_sections'
        AND column_name = 'custom_content'
    )
    THEN '✅ announcement_sections.custom_content exists'
    ELSE '❌ announcement_sections.custom_content NOT FOUND'
  END as custom_content_check;

-- ============================================
-- 3. 인덱스 존재 확인
-- ============================================

\echo '=== Validating Indexes ==='

SELECT
  CASE
    WHEN EXISTS (
      SELECT 1 FROM pg_indexes
      WHERE indexname = 'idx_announcement_types_announcement'
    )
    THEN '✅ idx_announcement_types_announcement exists'
    ELSE '❌ idx_announcement_types_announcement NOT FOUND'
  END as index_check_1;

SELECT
  CASE
    WHEN EXISTS (
      SELECT 1 FROM pg_indexes
      WHERE indexname = 'idx_announcement_sections_custom'
    )
    THEN '✅ idx_announcement_sections_custom exists'
    ELSE '❌ idx_announcement_sections_custom NOT FOUND'
  END as index_check_2;

-- ============================================
-- 4. 뷰 존재 확인
-- ============================================

\echo '=== Validating Views ==='

SELECT
  CASE
    WHEN EXISTS (
      SELECT 1 FROM pg_views
      WHERE schemaname = 'public'
        AND viewname = 'v_announcements_with_types'
    )
    THEN '✅ v_announcements_with_types exists'
    ELSE '❌ v_announcements_with_types NOT FOUND'
  END as view_check;

-- ============================================
-- 5. RLS 정책 확인
-- ============================================

\echo '=== Validating RLS Policies ==='

SELECT
  CASE
    WHEN EXISTS (
      SELECT 1 FROM pg_policies
      WHERE tablename = 'announcement_types'
        AND policyname = 'Public read access'
    )
    THEN '✅ RLS policy on announcement_types exists'
    ELSE '❌ RLS policy on announcement_types NOT FOUND'
  END as rls_check;

-- ============================================
-- 6. 트리거 확인
-- ============================================

\echo '=== Validating Triggers ==='

SELECT
  CASE
    WHEN EXISTS (
      SELECT 1 FROM pg_trigger
      WHERE tgname = 'update_announcement_types_updated_at'
    )
    THEN '✅ Trigger update_announcement_types_updated_at exists'
    ELSE '❌ Trigger update_announcement_types_updated_at NOT FOUND'
  END as trigger_check;

-- ============================================
-- 7. 제약 조건 확인
-- ============================================

\echo '=== Validating Constraints ==='

SELECT
  constraint_name,
  constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'announcement_types'
ORDER BY constraint_type, constraint_name;

SELECT
  constraint_name
FROM information_schema.table_constraints
WHERE table_name = 'announcement_sections'
  AND constraint_name LIKE '%section_type%'
ORDER BY constraint_name;

-- ============================================
-- 8. 샘플 데이터 확인
-- ============================================

\echo '=== Sample Data Count ==='

SELECT
  'announcement_types' as table_name,
  COUNT(*) as row_count
FROM announcement_types

UNION ALL

SELECT
  'announcement_sections (custom)',
  COUNT(*)
FROM announcement_sections
WHERE is_custom = true;

-- ============================================
-- 9. 뷰 테스트
-- ============================================

\echo '=== Testing View ==='

SELECT
  COUNT(*) as announcements_with_types_count
FROM v_announcements_with_types;

-- ============================================
-- 10. 성능 통계
-- ============================================

\echo '=== Performance Statistics ==='

SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('announcements', 'announcement_types', 'announcement_sections', 'announcement_tabs')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- ============================================
-- 완료
-- ============================================

\echo '=== Validation Complete ==='
