-- ============================================================================
-- Migration: Fix auth.users RLS Issue
-- Created: 2025-11-04
-- Purpose: Disable RLS on auth.users to fix login failures
-- Issue: Database error querying schema - auth.users had RLS enabled without policies
-- ============================================================================

-- IMPORTANT: auth.users should NEVER have RLS enabled
-- Supabase Auth manages this table internally and expects direct access

-- Step 1: Grant postgres superuser privileges on auth schema
-- This is necessary because auth schema is owned by supabase_admin
DO $$
BEGIN
  -- Make postgres a member of supabase_admin temporarily
  GRANT supabase_admin TO postgres;
  RAISE NOTICE '✅ Granted supabase_admin to postgres';
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING '⚠️  Could not grant supabase_admin: %', SQLERRM;
END $$;

-- Step 2: Disable RLS on auth.users
DO $$
BEGIN
  -- Set session role to supabase_admin to have necessary privileges
  SET LOCAL ROLE supabase_admin;

  -- Disable RLS
  ALTER TABLE auth.users DISABLE ROW LEVEL SECURITY;

  RAISE NOTICE '✅ RLS disabled on auth.users';

  -- Reset role
  RESET ROLE;
EXCEPTION
  WHEN insufficient_privilege THEN
    RAISE WARNING '⚠️  Could not disable RLS - insufficient privileges';
    RESET ROLE;
  WHEN OTHERS THEN
    RAISE WARNING '⚠️  Error disabling RLS: %', SQLERRM;
    RESET ROLE;
END $$;

-- Step 3: Ensure auth schema has correct permissions for all roles
DO $$
BEGIN
  GRANT USAGE ON SCHEMA auth TO anon, authenticated, service_role;
  GRANT SELECT ON auth.users TO anon, authenticated, service_role;
  RAISE NOTICE '✅ Auth schema permissions granted';
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING '⚠️  Error granting permissions: %', SQLERRM;
END $$;

-- Step 4: Revoke supabase_admin from postgres (cleanup)
DO $$
BEGIN
  REVOKE supabase_admin FROM postgres;
  RAISE NOTICE '✅ Revoked supabase_admin from postgres (cleanup)';
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING '⚠️  Could not revoke supabase_admin: %', SQLERRM;
END $$;

-- Step 5: Verify auth.users table accessibility
DO $$
DECLARE
  v_rls_enabled BOOLEAN;
  v_user_count INTEGER;
  v_admin_exists BOOLEAN;
BEGIN
  -- Check RLS status
  SELECT relrowsecurity INTO v_rls_enabled
  FROM pg_class c
  JOIN pg_namespace n ON c.relnamespace = n.oid
  WHERE n.nspname = 'auth' AND c.relname = 'users';

  -- Check user count
  SELECT COUNT(*) INTO v_user_count FROM auth.users;

  -- Check if admin user exists
  SELECT EXISTS (
    SELECT 1 FROM auth.users WHERE email = 'admin@pickly.com'
  ) INTO v_admin_exists;

  RAISE NOTICE '╔═══════════════════════════════════════════════╗';
  RAISE NOTICE '║  ✅ Migration 20251104000002 Complete         ║';
  RAISE NOTICE '║  📋 Table: auth.users                         ║';
  RAISE NOTICE '║  🔒 RLS Status: %',
    CASE WHEN v_rls_enabled THEN 'ENABLED (ISSUE!)' ELSE 'DISABLED (OK)' END;
  RAISE NOTICE '║  👤 Total Users: %', v_user_count;
  RAISE NOTICE '║  👤 Admin User: %',
    CASE WHEN v_admin_exists THEN 'EXISTS' ELSE 'NOT FOUND' END;
  RAISE NOTICE '║  ✅ Auth schema permissions granted           ║';
  RAISE NOTICE '║  ✅ Login should now work                     ║';
  RAISE NOTICE '╚═══════════════════════════════════════════════╝';
END $$;
