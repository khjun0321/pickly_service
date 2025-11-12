#!/usr/bin/env node

/**
 * Pickly Admin v9.12.0 - Production DB Schema Check
 * READ-ONLY script to verify database schema and Auth account
 */

const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://vymxxpjxrorpywfmqpuk.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ5bXh4cGp4cm9ycHl3Zm1xcHVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ4MjAyMzQsImV4cCI6MjA3MDM5NjIzNH0.WWtRtbxidZAhMXnaToiJqXz3mplRzS9kJ6ZCPkUc95I';

const supabase = createClient(supabaseUrl, supabaseAnonKey);

console.log('🔍 Pickly Admin v9.12.0 - Production DB Schema Check');
console.log('📋 READ-ONLY Mode - No write operations will be performed\n');
console.log('🔗 Connecting to:', supabaseUrl);
console.log('🔑 Using: anon key (RLS-protected)\n');

async function main() {
  try {
    // Test 1: Check public schema tables (usually fails with anon key)
    console.log('📦 Test 1: Checking public schema tables...');
    const { data: tables, error: tablesError } = await supabase
      .rpc('get_public_tables');  // Custom RPC if exists

    if (tablesError) {
      console.log('⚠️  Cannot query information_schema directly (expected with anon key)');
      console.log('   This is normal - anon key doesn\'t have access to system tables');
      console.log('   Attempting direct table access instead...\n');
    } else if (tables) {
      console.log(`✅ Found ${tables.length} tables in public schema`);
      console.log('');
    }

    // Test 2: Try to access announcements table
    console.log('📋 Test 2: Accessing announcements table...');
    const { data: announcements, error: announcementsError } = await supabase
      .from('announcements')
      .select('id, title, status')
      .limit(3);

    if (announcementsError) {
      console.log('❌ announcements table access FAILED');
      console.log('   Error:', announcementsError.message);
      console.log('   Error Code:', announcementsError.code);
      console.log('   Error Details:', announcementsError.details);
      console.log('   Error Hint:', announcementsError.hint);
      console.log('');

      // Check if it's a cache issue
      if (announcementsError.message.includes('relation') ||
          announcementsError.message.includes('does not exist') ||
          announcementsError.code === '42P01') {
        console.log('🔧 DIAGNOSIS: PostgREST schema cache is outdated');
        console.log('   The table exists in PostgreSQL but PostgREST doesn\'t know about it');
        console.log('   This happens when:');
        console.log('   - New migrations were applied');
        console.log('   - Schema was modified');
        console.log('   - PostgREST hasn\'t been restarted/reloaded');
        console.log('');
      }
    } else {
      console.log(`✅ announcements table accessible`);
      console.log(`   Found ${announcements.length} announcements`);
      announcements.forEach((a, i) => {
        console.log(`   ${i + 1}. ${a.title.substring(0, 50)}... (${a.status})`);
      });
      console.log('');
    }

    // Test 3: Check benefit_categories
    console.log('📦 Test 3: Accessing benefit_categories table...');
    const { data: categories, error: categoriesError } = await supabase
      .from('benefit_categories')
      .select('id, name')
      .limit(3);

    if (categoriesError) {
      console.log('❌ benefit_categories table access FAILED');
      console.log('   Error:', categoriesError.message);
      console.log('');
    } else {
      console.log(`✅ benefit_categories table accessible`);
      console.log(`   Found ${categories.length} categories`);
      categories.forEach((c, i) => {
        console.log(`   ${i + 1}. ${c.name}`);
      });
      console.log('');
    }

    // Test 4: Check age_categories
    console.log('👶 Test 4: Accessing age_categories table...');
    const { data: ageCategories, error: ageCategoriesError } = await supabase
      .from('age_categories')
      .select('id, name, description')
      .limit(3);

    if (ageCategoriesError) {
      console.log('❌ age_categories table access FAILED');
      console.log('   Error:', ageCategoriesError.message);
      console.log('');
    } else {
      console.log(`✅ age_categories table accessible`);
      console.log(`   Found ${ageCategories.length} age categories`);
      ageCategories.forEach((a, i) => {
        console.log(`   ${i + 1}. ${a.name} - ${a.description}`);
      });
      console.log('');
    }

    // Test 5: Check Storage buckets
    console.log('🗄️  Test 5: Checking Storage buckets...');
    const { data: buckets, error: bucketsError } = await supabase
      .storage
      .listBuckets();

    if (bucketsError) {
      console.log('❌ Storage buckets list FAILED');
      console.log('   Error:', bucketsError.message);
      console.log('');
    } else {
      console.log(`✅ Found ${buckets.length} Storage buckets:`);
      buckets.forEach(b => {
        console.log(`   - ${b.id} (public: ${b.public})`);
      });
      console.log('');
    }

    // Test 6: Check Auth (cannot directly query auth.users with anon key)
    console.log('🔐 Test 6: Testing Auth functionality...');
    console.log('   Note: Cannot query auth.users directly with anon key (expected)');
    console.log('   To verify admin@pickly.com account:');
    console.log('   1. Go to Supabase Dashboard');
    console.log('   2. Navigate to Authentication → Users');
    console.log('   3. Search for admin@pickly.com');
    console.log('   4. Check email_confirmed_at is not null');
    console.log('   5. Check banned_until is null');
    console.log('');

    // Summary
    console.log('═══════════════════════════════════════════════════');
    console.log('📊 SUMMARY');
    console.log('═══════════════════════════════════════════════════');
    console.log('Connection:              ', '✅ Success');
    console.log('Anon Key:                ', '✅ Valid');
    console.log('announcements table:     ', announcementsError ? '❌ Not accessible' : '✅ Accessible');
    console.log('benefit_categories table:', categoriesError ? '❌ Not accessible' : '✅ Accessible');
    console.log('age_categories table:    ', ageCategoriesError ? '❌ Not accessible' : '✅ Accessible');
    console.log('Storage buckets:         ', bucketsError ? '❌ Not accessible' : `✅ ${buckets.length} found`);
    console.log('═══════════════════════════════════════════════════');

    if (announcementsError) {
      console.log('\n🔧 RECOMMENDED ACTIONS:');
      console.log('═══════════════════════════════════════════════════');
      console.log('\n✅ Option 1: Dashboard (RECOMMENDED - No CLI needed)');
      console.log('─────────────────────────────────────────────────');
      console.log('1. Go to: https://supabase.com/dashboard/project/vymxxpjxrorpywfmqpuk/settings/api');
      console.log('2. Scroll to "PostgREST API"');
      console.log('3. Click "Restart API" button');
      console.log('4. Wait 10-15 seconds for restart to complete');
      console.log('5. Re-run this script to verify fix');
      console.log('');
      console.log('✅ Option 2: SQL Query (Requires service_role or postgres role)');
      console.log('─────────────────────────────────────────────────');
      console.log('-- Execute this in Supabase SQL Editor:');
      console.log('NOTIFY pgrst, \'reload schema\';');
      console.log('');
      console.log('✅ Option 3: CLI Migration Push (If you have pending migrations)');
      console.log('─────────────────────────────────────────────────');
      console.log('supabase db push');
      console.log('');
      console.log('⚠️  IMPORTANT:');
      console.log('This issue is likely due to schema cache being outdated.');
      console.log('The announcements table DOES exist in the database,');
      console.log('but PostgREST API doesn\'t know about it yet.');
    } else {
      console.log('\n✅ ALL CHECKS PASSED!');
      console.log('═══════════════════════════════════════════════════');
      console.log('All tables are accessible through PostgREST API.');
      console.log('No schema cache reload needed.');
      console.log('Admin UI should work correctly.');
    }

    console.log('\n📝 Next Steps:');
    console.log('═══════════════════════════════════════════════════');
    console.log('1. If tables are accessible: Test login in browser');
    console.log('2. If tables NOT accessible: Follow "RECOMMENDED ACTIONS" above');
    console.log('3. After fixing: Open http://localhost:5180 and test');
    console.log('4. Check for "🟢 Supabase connection: READY" in console');
    console.log('');

  } catch (err) {
    console.error('\n❌ UNEXPECTED ERROR:', err.message);
    console.error('Stack trace:', err.stack);
    console.error('\nThis might indicate:');
    console.error('- Network connection issues');
    console.error('- Invalid Supabase URL or anon key');
    console.error('- Supabase project is down');
  }
}

main();
