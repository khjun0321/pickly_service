-- =====================================================
-- Legacy Tables Verification Script
-- =====================================================
-- Purpose: Check which legacy tables actually exist
-- Date: 2025-11-03
-- Usage: psql -U postgres -d postgres -f verify_legacy_tables.sql
-- =====================================================

\echo '╔════════════════════════════════════════════════════╗'
\echo '║  Legacy Tables Verification Report                 ║'
\echo '╚════════════════════════════════════════════════════╝'
\echo ''

-- =====================================================
-- 1. Check which tables exist
-- =====================================================
\echo '📋 STEP 1: Table Existence Check'
\echo '─────────────────────────────────────────────────────'

SELECT
  tablename AS "Table Name",
  CASE
    WHEN tablename IN ('announcements', 'announcement_tabs', 'announcement_types',
                       'announcement_sections', 'announcement_unit_types') THEN '✅ Active (PRD v9.6.1)'
    WHEN tablename IN ('benefit_announcements', 'housing_announcements', 'display_order_history') THEN '⚠️  Legacy'
    ELSE '🔍 Other'
  END AS "Status"
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename LIKE '%announcement%'
ORDER BY tablename;

\echo ''

-- =====================================================
-- 2. Row count for all announcement tables
-- =====================================================
\echo '📊 STEP 2: Row Count Analysis'
\echo '─────────────────────────────────────────────────────'

DO $$
DECLARE
  tbl RECORD;
  row_count INTEGER;
BEGIN
  FOR tbl IN
    SELECT tablename
    FROM pg_tables
    WHERE schemaname = 'public'
      AND tablename LIKE '%announcement%'
    ORDER BY tablename
  LOOP
    EXECUTE format('SELECT COUNT(*) FROM %I', tbl.tablename) INTO row_count;
    RAISE NOTICE '% rows: %', RPAD(tbl.tablename, 35), row_count;
  END LOOP;
END $$;

\echo ''

-- =====================================================
-- 3. Foreign key dependencies check
-- =====================================================
\echo '🔗 STEP 3: Foreign Key Dependencies'
\echo '─────────────────────────────────────────────────────'

SELECT
  tc.table_name AS "From Table",
  kcu.column_name AS "Column",
  ccu.table_name AS "References Table",
  ccu.column_name AS "References Column"
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND (ccu.table_name IN ('benefit_announcements', 'housing_announcements', 'display_order_history')
    OR tc.table_name IN ('benefit_announcements', 'housing_announcements', 'display_order_history'))
ORDER BY tc.table_name, kcu.column_name;

\echo ''

-- =====================================================
-- 4. Views check
-- =====================================================
\echo '🔍 STEP 4: Views Analysis'
\echo '─────────────────────────────────────────────────────'

SELECT
  viewname AS "View Name",
  CASE
    WHEN viewname LIKE 'v_announcement%' THEN 'Announcement-related view'
    WHEN viewname LIKE 'v_benefit%' THEN 'Benefit-related view'
    WHEN viewname LIKE 'v_featured%' THEN 'Featured content view'
    ELSE 'Other view'
  END AS "Purpose"
FROM pg_views
WHERE schemaname = 'public'
  AND viewname LIKE 'v_%'
ORDER BY viewname;

\echo ''

-- =====================================================
-- 5. Schema comparison: announcements vs benefit_announcements
-- =====================================================
\echo '🔬 STEP 5: Schema Comparison'
\echo '─────────────────────────────────────────────────────'

-- Only run if both tables exist
DO $$
DECLARE
  announcements_exists BOOLEAN;
  benefit_announcements_exists BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT FROM pg_tables
    WHERE schemaname = 'public' AND tablename = 'announcements'
  ) INTO announcements_exists;

  SELECT EXISTS (
    SELECT FROM pg_tables
    WHERE schemaname = 'public' AND tablename = 'benefit_announcements'
  ) INTO benefit_announcements_exists;

  IF announcements_exists AND benefit_announcements_exists THEN
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  WARNING: Both announcements and benefit_announcements exist!';
    RAISE NOTICE '';

    -- Compare column counts
    RAISE NOTICE 'Column count comparison:';
    RAISE NOTICE '  announcements: % columns',
      (SELECT COUNT(*) FROM information_schema.columns
       WHERE table_name = 'announcements' AND table_schema = 'public');
    RAISE NOTICE '  benefit_announcements: % columns',
      (SELECT COUNT(*) FROM information_schema.columns
       WHERE table_name = 'benefit_announcements' AND table_schema = 'public');
    RAISE NOTICE '';

    -- Compare row counts
    RAISE NOTICE 'Row count comparison:';
    RAISE NOTICE '  announcements: % rows',
      (SELECT COUNT(*) FROM announcements);
    RAISE NOTICE '  benefit_announcements: % rows',
      (SELECT COUNT(*) FROM benefit_announcements);
    RAISE NOTICE '';

  ELSIF NOT announcements_exists THEN
    RAISE NOTICE '❌ ERROR: announcements table does not exist! This is a CRITICAL issue.';
  ELSIF NOT benefit_announcements_exists THEN
    RAISE NOTICE '✅ OK: benefit_announcements does not exist (expected for PRD v9.6.1)';
  END IF;
END $$;

\echo ''

-- =====================================================
-- 6. Column comparison (if both tables exist)
-- =====================================================
\echo '📝 STEP 6: Column Comparison (if both tables exist)'
\echo '─────────────────────────────────────────────────────'

-- Compare columns between announcements and benefit_announcements
SELECT
  COALESCE(a.column_name, b.column_name) AS "Column Name",
  CASE
    WHEN a.column_name IS NULL THEN '⚠️  Only in benefit_announcements'
    WHEN b.column_name IS NULL THEN '✅ Only in announcements (PRD v9.6.1)'
    ELSE '🔄 In both tables'
  END AS "Status",
  COALESCE(a.data_type, b.data_type) AS "Data Type"
FROM
  (SELECT column_name, data_type
   FROM information_schema.columns
   WHERE table_schema = 'public' AND table_name = 'announcements') a
FULL OUTER JOIN
  (SELECT column_name, data_type
   FROM information_schema.columns
   WHERE table_schema = 'public' AND table_name = 'benefit_announcements') b
ON a.column_name = b.column_name
ORDER BY COALESCE(a.column_name, b.column_name);

\echo ''

-- =====================================================
-- 7. Sample data check (if legacy tables exist)
-- =====================================================
\echo '📄 STEP 7: Sample Data Preview'
\echo '─────────────────────────────────────────────────────'

DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE tablename = 'benefit_announcements') THEN
    RAISE NOTICE 'First 3 rows from benefit_announcements:';
    FOR rec IN (SELECT id, title, created_at FROM benefit_announcements ORDER BY created_at DESC LIMIT 3) LOOP
      RAISE NOTICE '  ID: % | Title: % | Created: %', rec.id, rec.title, rec.created_at;
    END LOOP;
    RAISE NOTICE '';
  END IF;

  IF EXISTS (SELECT FROM pg_tables WHERE tablename = 'housing_announcements') THEN
    RAISE NOTICE 'First 3 rows from housing_announcements:';
    FOR rec IN (SELECT id, title, created_at FROM housing_announcements ORDER BY created_at DESC LIMIT 3) LOOP
      RAISE NOTICE '  ID: % | Title: % | Created: %', rec.id, rec.title, rec.created_at;
    END LOOP;
    RAISE NOTICE '';
  END IF;

  IF EXISTS (SELECT FROM pg_tables WHERE tablename = 'display_order_history') THEN
    RAISE NOTICE 'Row count in display_order_history: %',
      (SELECT COUNT(*) FROM display_order_history);
    RAISE NOTICE '';
  END IF;
END $$;

\echo ''

-- =====================================================
-- 8. Final recommendations
-- =====================================================
\echo '💡 STEP 8: Recommendations'
\echo '─────────────────────────────────────────────────────'

DO $$
DECLARE
  announcements_exists BOOLEAN;
  benefit_announcements_exists BOOLEAN;
  housing_announcements_exists BOOLEAN;
  display_order_history_exists BOOLEAN;
BEGIN
  SELECT EXISTS (SELECT FROM pg_tables WHERE tablename = 'announcements') INTO announcements_exists;
  SELECT EXISTS (SELECT FROM pg_tables WHERE tablename = 'benefit_announcements') INTO benefit_announcements_exists;
  SELECT EXISTS (SELECT FROM pg_tables WHERE tablename = 'housing_announcements') INTO housing_announcements_exists;
  SELECT EXISTS (SELECT FROM pg_tables WHERE tablename = 'display_order_history') INTO display_order_history_exists;

  RAISE NOTICE '╔════════════════════════════════════════════════════╗';
  RAISE NOTICE '║  Recommendations:                                  ║';
  RAISE NOTICE '╚════════════════════════════════════════════════════╝';
  RAISE NOTICE '';

  IF NOT announcements_exists THEN
    RAISE NOTICE '🔴 CRITICAL: announcements table MISSING! Run migrations immediately.';
  ELSE
    RAISE NOTICE '✅ announcements table exists (PRD v9.6.1 core table)';
  END IF;

  IF benefit_announcements_exists THEN
    RAISE NOTICE '⚠️  benefit_announcements exists (legacy):';
    RAISE NOTICE '   1. Update Flutter code to use announcements table';
    RAISE NOTICE '   2. Backup data to CSV';
    RAISE NOTICE '   3. Migrate data if needed';
    RAISE NOTICE '   4. Drop table after verification';
  ELSE
    RAISE NOTICE '✅ benefit_announcements does not exist (expected)';
    RAISE NOTICE '   Action: Regenerate TypeScript types to remove reference';
  END IF;

  IF housing_announcements_exists THEN
    RAISE NOTICE '⚠️  housing_announcements exists (legacy):';
    RAISE NOTICE '   1. Backup data to CSV';
    RAISE NOTICE '   2. Drop table (no code references found)';
  ELSE
    RAISE NOTICE '✅ housing_announcements does not exist (expected)';
  END IF;

  IF display_order_history_exists THEN
    RAISE NOTICE '⚠️  display_order_history exists (audit trail):';
    RAISE NOTICE '   1. Decide if audit trail is needed';
    RAISE NOTICE '   2. Archive to CSV if not needed';
    RAISE NOTICE '   3. Drop table or keep for compliance';
  ELSE
    RAISE NOTICE '✅ display_order_history does not exist (expected)';
  END IF;

  RAISE NOTICE '';
  RAISE NOTICE 'Next steps:';
  RAISE NOTICE '  1. Review this report';
  RAISE NOTICE '  2. Create backups (see DB_LEGACY_CLEANUP_REPORT.md)';
  RAISE NOTICE '  3. Update Flutter code if benefit_announcements exists';
  RAISE NOTICE '  4. Regenerate TypeScript types';
  RAISE NOTICE '  5. Execute cleanup migration';
  RAISE NOTICE '';
END $$;

\echo '╔════════════════════════════════════════════════════╗'
\echo '║  Verification Complete!                            ║'
\echo '║  Report saved at:                                  ║'
\echo '║  docs/DB_LEGACY_CLEANUP_REPORT.md                  ║'
\echo '╚════════════════════════════════════════════════════╝'
