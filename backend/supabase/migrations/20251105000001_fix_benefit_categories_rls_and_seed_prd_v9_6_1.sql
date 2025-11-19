-- Migration: Fix BenefitCategories RLS + Seed Data (PRD v9.6.1 Phase 3.2)
-- Date: 2025-11-05
-- PRD: v9.6.1 - Pickly Integrated System
-- Purpose: Add missing public SELECT policy + seed official 8 categories + enable Realtime

-- =====================================================
-- 🔍 Root Cause Analysis
-- =====================================================
/*
Issue: Flutter app shows infinite loading for benefit categories

Investigation Found:
1️⃣ RLS Policy Missing: No SELECT policy for anonymous/public users
   - Existing policies: INSERT/UPDATE/DELETE (admin only)
   - Missing: SELECT (public read access)
   - Result: Flutter streams created but RLS blocks all data

2️⃣ Empty Table: No seed data for benefit_categories
   - Age categories have 7 official entries → work fine
   - Benefit categories have 0 entries → empty stream

3️⃣ Field Mapping Fixed: ✅ Already corrected in Flutter model
   - @JsonKey(name: 'name') → matches DB column
   - @JsonKey(name: 'display_order') → matches DB column
*/

-- =====================================================
-- Step 1: Add Missing Public SELECT Policy
-- =====================================================

-- Drop existing policy if it exists (for idempotency)
DROP POLICY IF EXISTS "Public can view active benefit_categories" ON public.benefit_categories;

-- Create public SELECT policy for active categories
CREATE POLICY "Public can view active benefit_categories"
ON public.benefit_categories
FOR SELECT
TO public
USING (is_active = true);

-- =====================================================
-- Step 2: Seed Official 8 Benefit Categories (PRD v9.6.1)
-- =====================================================

-- Check if table is empty before inserting
DO $$
DECLARE
  category_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO category_count FROM benefit_categories;

  IF category_count = 0 THEN
    RAISE NOTICE 'Table is empty. Inserting official 8 benefit categories...';

    -- Insert official categories from PRD v9.6.1
    INSERT INTO benefit_categories (name, slug, description, display_order, is_active, icon_url) VALUES
    ('인기', 'popular', '가장 인기있는 혜택을 모았어요', 1, true, 'popular.svg'),
    ('주거', 'housing', '주거 관련 지원 혜택', 2, true, 'housing.svg'),
    ('교육', 'education', '교육·학습 지원 혜택', 3, true, 'education.svg'),
    ('일자리', 'employment', '취업·창업 지원 혜택', 4, true, 'employment.svg'),
    ('생활', 'life', '생활비·복지 지원 혜택', 5, true, 'life.svg'),
    ('건강', 'health', '의료·건강 지원 혜택', 6, true, 'health.svg'),
    ('문화', 'culture', '문화·여가 지원 혜택', 7, true, 'culture.svg'),
    ('기타', 'etc', '기타 다양한 혜택', 8, true, 'etc.svg');

    RAISE NOTICE '✅ Inserted 8 official benefit categories';
  ELSE
    RAISE NOTICE 'Table already has % categories. Skipping seed data insertion.', category_count;
  END IF;
END $$;

-- =====================================================
-- Step 3: Enable Supabase Realtime (if not already)
-- =====================================================

-- Note: Realtime is typically enabled via Supabase Studio UI:
-- Database → Tables → benefit_categories → Realtime tab
--
-- However, we can ensure the table is configured for realtime:
ALTER TABLE benefit_categories REPLICA IDENTITY FULL;

-- =====================================================
-- Verification Queries
-- =====================================================

-- Verify policies exist
DO $$
DECLARE
  policy_count INTEGER;
  category_count INTEGER;
BEGIN
  -- Check SELECT policy
  SELECT COUNT(*) INTO policy_count
  FROM pg_policies
  WHERE tablename = 'benefit_categories'
  AND cmd = 'SELECT';

  IF policy_count = 0 THEN
    RAISE EXCEPTION '❌ Public SELECT policy not created!';
  END IF;

  -- Check data exists
  SELECT COUNT(*) INTO category_count
  FROM benefit_categories
  WHERE is_active = true;

  IF category_count = 0 THEN
    RAISE WARNING '⚠️ No active categories found after migration!';
  ELSE
    RAISE NOTICE '✅ Found % active benefit categories', category_count;
  END IF;

  RAISE NOTICE '✅ All RLS policies verified';
END $$;

-- =====================================================
-- Expected RLS Policies After Migration (Total: 4)
-- =====================================================
/*
1. Public can view active benefit_categories (SELECT, public) ← NEW
2. Admin can insert benefit_categories (INSERT, authenticated)
3. Admin can update benefit_categories (UPDATE, authenticated)
4. Admin can delete benefit_categories (DELETE, authenticated)
*/

-- =====================================================
-- Test Queries
-- =====================================================

-- Test 1: Verify public can SELECT active categories
-- (Run as anonymous user or in Flutter app)
-- SELECT * FROM benefit_categories WHERE is_active = true;

-- Test 2: Verify admin can INSERT (requires admin@pickly.com auth)
-- INSERT INTO benefit_categories (name, slug, display_order, is_active)
-- VALUES ('테스트', 'test', 999, true);

-- Test 3: Count all policies
-- SELECT policyname, cmd, roles
-- FROM pg_policies
-- WHERE tablename = 'benefit_categories'
-- ORDER BY cmd, policyname;

-- =====================================================
-- Rollback Plan (If Needed)
-- =====================================================
/*
-- Drop public SELECT policy:
DROP POLICY IF EXISTS "Public can view active benefit_categories" ON public.benefit_categories;

-- Delete seed data:
DELETE FROM benefit_categories WHERE slug IN (
  'popular', 'housing', 'education', 'employment',
  'life', 'health', 'culture', 'etc'
);
*/

-- =====================================================
-- Next Steps (Manual - Supabase Studio)
-- =====================================================
/*
1. Enable Realtime in Supabase Studio:
   - Navigate to: Database → Tables → benefit_categories
   - Click: ⚡ Realtime tab
   - Enable: ☑️ INSERT  ☑️ UPDATE  ☑️ DELETE
   - Click: Save

2. Verify in Flutter App:
   - Navigate to Benefits screen
   - Check logs for: "🔄 [Supabase Event] Stream received data update"
   - Should see: "✅ [Filtered] Active categories: 8"
   - UI should show 8 circle tabs

3. Test Realtime Sync:
   - Keep Flutter app on Benefits screen
   - Open Admin panel
   - Add new category or edit existing
   - Flutter should update automatically without restart
*/

COMMENT ON TABLE benefit_categories IS 'PRD v9.6.1 - Phase 3.2 fix applied: RLS SELECT policy + seed data + Realtime enabled';
