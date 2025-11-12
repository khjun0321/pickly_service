#!/usr/bin/env node
/**
 * Production Verification Script for v9.12.0
 * Executes read-only queries against Production database
 * Project: vymxxpjxrorpywfmqpuk
 */

import { createClient } from '@supabase/supabase-js';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Read Supabase config from .env or config
const getSupabaseConfig = () => {
  try {
    const envPath = join(__dirname, '../../.env.production');
    const envContent = readFileSync(envPath, 'utf-8');
    const lines = envContent.split('\n');

    const config = {};
    lines.forEach(line => {
      const [key, value] = line.split('=');
      if (key && value) {
        config[key.trim()] = value.trim();
      }
    });

    return {
      url: config.VITE_SUPABASE_URL || config.SUPABASE_URL,
      anonKey: config.VITE_SUPABASE_ANON_KEY || config.SUPABASE_ANON_KEY
    };
  } catch (error) {
    console.error('❌ Could not read .env.production file');
    console.error('Please create .env.production with:');
    console.error('  VITE_SUPABASE_URL=https://vymxxpjxrorpywfmqpuk.supabase.co');
    console.error('  VITE_SUPABASE_ANON_KEY=<your-anon-key>');
    process.exit(1);
  }
};

const config = getSupabaseConfig();

if (!config.url || !config.anonKey) {
  console.error('❌ Missing Supabase credentials in .env.production');
  process.exit(1);
}

const supabase = createClient(config.url, config.anonKey);

console.log('============================================');
console.log('📊 Pickly Production v9.12.0 Verification');
console.log('============================================');
console.log(`Environment: ${config.url}`);
console.log(`Mode: READ-ONLY`);
console.log('');

const results = {
  columns: null,
  searchIndex: null,
  buckets: null,
  functions: null,
  triggers: null,
  announcements: null
};

// 1️⃣ Check v9.12.0 columns in announcements table
console.log('1️⃣ Checking v9.12.0 columns in announcements table...');
try {
  const { data, error } = await supabase.rpc('exec_sql', {
    query: `
      SELECT
        column_name,
        data_type,
        is_nullable,
        column_default
      FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = 'announcements'
        AND column_name IN (
          'thumbnail_url',
          'is_featured',
          'featured_section',
          'featured_order',
          'tags',
          'searchable_text'
        )
      ORDER BY ordinal_position;
    `
  });

  if (error) {
    console.log('   ℹ️  RPC exec_sql not available, trying direct query...');
    // Alternative: check via announcements table structure
    const { data: announcements, error: annError } = await supabase
      .from('announcements')
      .select('*')
      .limit(1);

    if (!annError && announcements) {
      const firstRow = announcements[0] || {};
      const v9_12_columns = [
        'thumbnail_url',
        'is_featured',
        'featured_section',
        'featured_order',
        'tags',
        'searchable_text'
      ];

      const found = v9_12_columns.filter(col => col in firstRow);
      results.columns = {
        found: found.length,
        expected: 6,
        columns: found
      };

      console.log(`   ✅ Found ${found.length}/6 v9.12.0 columns`);
      if (found.length > 0) {
        console.log(`   Columns: ${found.join(', ')}`);
      } else {
        console.log(`   ⚠️  v9.12.0 columns not yet applied`);
      }
    }
  } else {
    results.columns = data;
    console.log(`   ✅ Query executed: ${data?.length || 0} columns found`);
  }
} catch (err) {
  console.log(`   ❌ Error: ${err.message}`);
}

console.log('');

// 2️⃣ Check search_index table
console.log('2️⃣ Checking search_index table...');
try {
  const { data, error } = await supabase
    .from('search_index')
    .select('count', { count: 'exact', head: true });

  if (error) {
    if (error.message.includes('does not exist') || error.code === '42P01') {
      results.searchIndex = { exists: false };
      console.log('   ⚠️  search_index table does not exist (v9.12.0 not applied)');
    } else {
      console.log(`   ❌ Error: ${error.message}`);
    }
  } else {
    results.searchIndex = { exists: true, count: data };
    console.log(`   ✅ search_index table exists`);
  }
} catch (err) {
  console.log(`   ⚠️  search_index table not accessible: ${err.message}`);
  results.searchIndex = { exists: false };
}

console.log('');

// 3️⃣ Check Storage buckets
console.log('3️⃣ Checking Storage buckets...');
try {
  const { data: buckets, error } = await supabase.storage.listBuckets();

  if (error) {
    console.log(`   ❌ Error: ${error.message}`);
  } else {
    const targetBuckets = ['announcement-thumbnails', 'announcement-pdfs', 'announcement-images'];
    const found = buckets.filter(b => targetBuckets.includes(b.id));

    results.buckets = {
      found: found.length,
      expected: 3,
      buckets: found.map(b => ({
        id: b.id,
        public: b.public,
        file_size_limit: b.file_size_limit
      }))
    };

    console.log(`   ✅ Found ${found.length}/3 buckets`);
    found.forEach(bucket => {
      console.log(`      - ${bucket.id}: public=${bucket.public}, limit=${bucket.file_size_limit || 'N/A'}`);
    });

    const missing = targetBuckets.filter(id => !found.some(b => b.id === id));
    if (missing.length > 0) {
      console.log(`   ⚠️  Missing buckets: ${missing.join(', ')}`);
    }
  }
} catch (err) {
  console.log(`   ❌ Error: ${err.message}`);
}

console.log('');

// 4️⃣ Check sample announcements
console.log('4️⃣ Checking sample announcements...');
try {
  const { data, error } = await supabase
    .from('announcements')
    .select('id, title, organization, status, created_at')
    .order('created_at', { ascending: false })
    .limit(3);

  if (error) {
    console.log(`   ❌ Error: ${error.message}`);
  } else {
    results.announcements = {
      count: data.length,
      sample: data
    };
    console.log(`   ✅ Found ${data.length} announcements (showing latest 3)`);
    data.forEach((ann, i) => {
      console.log(`      ${i + 1}. ${ann.title.substring(0, 40)}... (${ann.status})`);
    });
  }
} catch (err) {
  console.log(`   ❌ Error: ${err.message}`);
}

console.log('');

// Summary
console.log('============================================');
console.log('📊 Verification Summary');
console.log('============================================');

const summary = {
  'v9.12.0 Columns': results.columns?.found === 6 ? '✅ APPLIED' : '⚠️  NOT APPLIED',
  'search_index Table': results.searchIndex?.exists ? '✅ EXISTS' : '⚠️  NOT EXISTS',
  'Storage Buckets': results.buckets?.found === 3 ? '✅ ALL FOUND' : `⚠️  ${results.buckets?.found || 0}/3 FOUND`,
  'Announcements Data': results.announcements?.count > 0 ? '✅ ACCESSIBLE' : '❌ NO DATA'
};

Object.entries(summary).forEach(([key, value]) => {
  console.log(`${key}: ${value}`);
});

console.log('');
console.log('============================================');

if (results.columns?.found === 6 && results.searchIndex?.exists) {
  console.log('✅ v9.12.0 IS FULLY DEPLOYED TO PRODUCTION');
} else if (results.columns?.found === 0 && !results.searchIndex?.exists) {
  console.log('⚠️  v9.12.0 NOT YET DEPLOYED (Expected - ready for deployment)');
} else {
  console.log('⚠️  PARTIAL DEPLOYMENT DETECTED - INVESTIGATION NEEDED');
}

console.log('============================================');
console.log('');

// Save results to JSON
const outputPath = join(__dirname, '../../docs/prd/v9.12.0_verification_results.json');
try {
  const fs = await import('fs/promises');
  await fs.writeFile(outputPath, JSON.stringify({
    timestamp: new Date().toISOString(),
    environment: config.url,
    results,
    summary
  }, null, 2));
  console.log(`📄 Results saved to: ${outputPath}`);
} catch (err) {
  console.error(`❌ Could not save results: ${err.message}`);
}

process.exit(results.columns?.found === 6 && results.searchIndex?.exists ? 0 : 1);
