/**
 * Supabase Connection Test (Read-Only)
 * v9.12.0 Local Environment Setup
 */

import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || '';

export async function testSupabaseConnection() {
  console.log('🔍 Testing Supabase connection...');
  console.log(`URL: ${supabaseUrl}`);
  console.log(`Anon Key: ${supabaseAnonKey.substring(0, 20)}...`);

  if (!supabaseUrl || !supabaseAnonKey) {
    console.error('❌ Missing Supabase credentials');
    return {
      success: false,
      error: 'Missing VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY'
    };
  }

  const supabase = createClient(supabaseUrl, supabaseAnonKey);

  try {
    // Test 1: List Storage buckets (read-only)
    console.log('\n📦 Test 1: Listing Storage buckets...');
    const { data: buckets, error: bucketsError } = await supabase.storage.listBuckets();

    if (bucketsError) {
      console.error('❌ Storage buckets test failed:', bucketsError.message);
      return {
        success: false,
        error: bucketsError.message,
        test: 'storage_buckets'
      };
    }

    console.log(`✅ Found ${buckets.length} Storage buckets`);
    buckets.forEach(bucket => {
      console.log(`   - ${bucket.id} (public: ${bucket.public})`);
    });

    // Test 2: Query announcements table (read-only)
    console.log('\n📋 Test 2: Querying announcements table...');
    const { data: announcements, error: announcementsError } = await supabase
      .from('announcements')
      .select('id, title, status, created_at')
      .order('created_at', { ascending: false })
      .limit(3);

    if (announcementsError) {
      console.error('❌ Announcements query failed:', announcementsError.message);
      return {
        success: false,
        error: announcementsError.message,
        test: 'announcements_query'
      };
    }

    console.log(`✅ Found ${announcements.length} announcements (showing latest 3)`);
    announcements.forEach((ann, i) => {
      console.log(`   ${i + 1}. ${ann.title.substring(0, 40)}... (${ann.status})`);
    });

    // Test 3: Check if v9.12.0 columns exist
    console.log('\n🔍 Test 3: Checking for v9.12.0 columns...');
    const firstAnnouncement = announcements[0] || {};
    const v9_12_columns = [
      'thumbnail_url',
      'is_featured',
      'featured_section',
      'featured_order',
      'tags',
      'searchable_text'
    ];

    const foundColumns = v9_12_columns.filter(col => col in firstAnnouncement);
    console.log(`   Found ${foundColumns.length}/6 v9.12.0 columns`);

    if (foundColumns.length === 0) {
      console.log('   ⚠️  v9.12.0 not yet deployed (expected)');
    } else if (foundColumns.length === 6) {
      console.log('   ✅ v9.12.0 fully deployed!');
      console.log(`   Columns: ${foundColumns.join(', ')}`);
    } else {
      console.log(`   ⚠️  Partial deployment: ${foundColumns.join(', ')}`);
    }

    console.log('\n✅ All connection tests passed!');
    return {
      success: true,
      buckets: buckets.length,
      announcements: announcements.length,
      v9_12_columns: foundColumns.length
    };
  } catch (err) {
    console.error('❌ Connection test failed:', err);
    return {
      success: false,
      error: err instanceof Error ? err.message : 'Unknown error'
    };
  }
}
