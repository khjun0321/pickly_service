-- =============================================================
-- Migration: 20251107_disable_all_rls.sql
-- Description: Disable all RLS policies and make buckets public
-- PRD Version: v9.7.0 — Admin API Role Guard Architecture
-- =============================================================

ALTER TABLE age_categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE benefit_categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE benefit_subcategories DISABLE ROW LEVEL SECURITY;
ALTER TABLE category_banners DISABLE ROW LEVEL SECURITY;
ALTER TABLE announcements DISABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_tabs DISABLE ROW LEVEL SECURITY;
ALTER TABLE api_sources DISABLE ROW LEVEL SECURITY;
ALTER TABLE raw_announcements DISABLE ROW LEVEL SECURITY;

UPDATE storage.buckets SET public = true WHERE name IN ('benefit-icons', 'home-banners');
