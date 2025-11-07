-- ================================================================
-- Migration: Disable RLS for Development Environment
-- Version: PRD v9.6.2
-- Date: 2025-11-06
-- ================================================================
--
-- PURPOSE: Disable Row Level Security (RLS) on main tables
-- for easier development and testing in local environment.
--
-- WARNING: DO NOT apply this migration to production!
-- Production should use proper RLS policies with admin roles.
-- ================================================================

-- Disable RLS on age_categories
ALTER TABLE public.age_categories DISABLE ROW LEVEL SECURITY;

-- Disable RLS on benefit_categories
ALTER TABLE public.benefit_categories DISABLE ROW LEVEL SECURITY;

-- Disable RLS on benefit_subcategories
ALTER TABLE public.benefit_subcategories DISABLE ROW LEVEL SECURITY;

-- Disable RLS on category_banners
ALTER TABLE public.category_banners DISABLE ROW LEVEL SECURITY;

-- Disable RLS on announcements
ALTER TABLE public.announcements DISABLE ROW LEVEL SECURITY;

-- Verify RLS is disabled
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT tablename, rowsecurity
    FROM pg_tables
    WHERE schemaname = 'public'
    AND tablename IN ('age_categories', 'benefit_categories', 'benefit_subcategories', 'category_banners', 'announcements')
  LOOP
    RAISE NOTICE 'Table: %, RLS Enabled: %', r.tablename, r.rowsecurity;
  END LOOP;
END $$;
