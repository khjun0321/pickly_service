-- Migration: Enable Realtime for benefit_categories
-- PRD: v9.6.1 Phase 3 - Realtime Sync
-- Date: 2025-11-04
-- Issue: benefit_categories INSERT events not propagating to Flutter app
--
-- Problem:
-- 1. supabase_realtime publication exists but has no tables
-- 2. benefit_categories not included in realtime publication
-- 3. Flutter app uses one-time fetch, not stream subscription
--
-- Solution:
-- Add benefit_categories to supabase_realtime publication
-- This enables INSERT/UPDATE/DELETE events to propagate to subscribed clients

-- Add benefit_categories to Realtime publication
ALTER PUBLICATION supabase_realtime ADD TABLE benefit_categories;

-- Verify the table was added
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
    AND tablename = 'benefit_categories'
  ) THEN
    RAISE EXCEPTION 'Failed to add benefit_categories to supabase_realtime publication';
  END IF;

  RAISE NOTICE '✅ benefit_categories added to Realtime publication';
  RAISE NOTICE '📡 INSERT/UPDATE/DELETE events will now propagate to Flutter app';
END $$;

-- Add age_categories as well (for consistency)
ALTER PUBLICATION supabase_realtime ADD TABLE age_categories;

-- Add announcements (already uses streams but ensure publication)
ALTER PUBLICATION supabase_realtime ADD TABLE announcements;

-- Verify all tables
DO $$
DECLARE
  table_count INTEGER;
  tbl_name TEXT;
BEGIN
  SELECT COUNT(*)
  INTO table_count
  FROM pg_publication_tables
  WHERE pubname = 'supabase_realtime';

  RAISE NOTICE '📊 Total tables in Realtime publication: %', table_count;

  -- List all tables in publication
  RAISE NOTICE '📋 Tables in supabase_realtime:';
  FOR tbl_name IN
    SELECT tablename
    FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
    ORDER BY tablename
  LOOP
    RAISE NOTICE '   - %', tbl_name;
  END LOOP;
END $$;

-- IMPORTANT: Flutter Code Update Required
-- This migration enables the backend to send events.
-- To receive events, update Flutter code:
--
-- File: lib/contexts/benefit/repositories/benefit_repository.dart
--
-- Add this method:
-- /// Watch benefit categories with Realtime updates
-- Stream<List<BenefitCategory>> watchCategories() {
--   return _client
--       .from('benefit_categories')
--       .stream(primaryKey: ['id'])
--       .eq('is_active', true)
--       .order('display_order', ascending: true)
--       .map((data) => data
--           .map((json) => BenefitCategory.fromJson(json as Map<String, dynamic>))
--           .toList());
-- }
--
-- Then update UI to use StreamProvider instead of FutureProvider
