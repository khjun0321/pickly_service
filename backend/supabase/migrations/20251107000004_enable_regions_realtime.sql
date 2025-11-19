-- Migration: Enable Realtime publication for regions table
-- Version: PRD v9.8.2 (Phase 6.3)
-- Date: 2025-11-07
-- Purpose: Enable Flutter app to receive real-time updates when regions change

-- Enable Realtime for regions table
ALTER PUBLICATION supabase_realtime ADD TABLE public.regions;

-- Enable Realtime for user_regions table (for user's own selections)
ALTER PUBLICATION supabase_realtime ADD TABLE public.user_regions;

-- Verify publication (output will show in migration logs)
DO $$
DECLARE
  regions_published boolean;
  user_regions_published boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'regions'
  ) INTO regions_published;

  SELECT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'user_regions'
  ) INTO user_regions_published;

  IF regions_published AND user_regions_published THEN
    RAISE NOTICE '✅ Realtime enabled for regions and user_regions tables';
  ELSE
    RAISE WARNING '⚠️ Realtime publication verification failed';
    RAISE NOTICE 'regions published: %', regions_published;
    RAISE NOTICE 'user_regions published: %', user_regions_published;
  END IF;
END $$;
