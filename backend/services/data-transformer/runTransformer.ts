#!/usr/bin/env ts-node
/**
 * Run Transformer - Data Transformation Orchestrator
 * PRD v9.6.1 - Phase 4C Step 3
 *
 * Purpose: Transform raw_announcements to announcements using mapping_config
 *
 * Usage:
 *   npm run transform:api                    - Transform all fetched records
 *   npm run transform:api -- --dry-run       - Dry run (no DB writes)
 *   npm run transform:api -- --raw-id=<uuid> - Transform specific record
 *   npm run transform:api -- --help          - Show help
 */

import supabase, { RawAnnouncement, TransformationResult } from './supabaseClient'
import { transformRawAnnouncement } from './transformRaw'

interface CliOptions {
  dryRun: boolean
  rawId: string | null
  help: boolean
}

/**
 * Parse CLI arguments
 */
function parseArgs(): CliOptions {
  const args = process.argv.slice(2)

  return {
    dryRun: args.includes('--dry-run'),
    rawId: args.find(arg => arg.startsWith('--raw-id='))?.split('=')[1] || null,
    help: args.includes('--help') || args.includes('-h'),
  }
}

/**
 * Show CLI help
 */
function showHelp(): void {
  console.log(`
╔════════════════════════════════════════════════════════════════╗
║        🔄 Pickly Data Transformation Service - Help           ║
╚════════════════════════════════════════════════════════════════╝

Transform raw_announcements to announcements using mapping_config.

USAGE:
  npm run transform:api [options]

OPTIONS:
  --dry-run              Test mode - no database writes
  --raw-id=<uuid>        Transform specific raw announcement
  --help, -h             Show this help message

EXAMPLES:
  # Transform all fetched records
  npm run transform:api

  # Dry run (test without saving)
  npm run transform:api -- --dry-run

  # Transform specific record
  npm run transform:api -- --raw-id=550e8400-e29b-41d4-a716-446655440000

TRANSFORMATION FLOW:
  1. Fetch raw_announcements WHERE status = 'fetched'
  2. For each record:
     a. Load api_source.mapping_config
     b. Apply field mapping (title, organization, etc.)
     c. Validate required fields
     d. Insert/Update announcements table
     e. Update raw_announcements.status = 'processed'

MAPPING CONFIG EXAMPLE:
  {
    "fields": {
      "title": "response.title",
      "organization": "response.org_name",
      "content": "response.description"
    },
    "defaults": {
      "status": "recruiting",
      "link_type": "external"
    },
    "target_category": "uuid-here"
  }

DATABASE VERIFICATION:
  # Check transformed announcements
  docker exec -i supabase_db_supabase psql -U postgres -d postgres -c \\
    "SELECT id, title, organization, status FROM announcements ORDER BY created_at DESC LIMIT 5;"

  # Check processing status
  docker exec -i supabase_db_supabase psql -U postgres -d postgres -c \\
    "SELECT status, COUNT(*) FROM raw_announcements GROUP BY status;"

For more info: backend/services/data-transformer/README.md
`)
}

/**
 * Fetch raw announcements to transform
 */
async function getRawAnnouncements(rawId: string | null): Promise<RawAnnouncement[]> {
  if (rawId) {
    // Fetch specific record
    const { data, error } = await supabase
      .from('raw_announcements')
      .select('*')
      .eq('id', rawId)
      .single()

    if (error) {
      throw new Error(`Failed to fetch raw announcement: ${error.message}`)
    }

    if (!data) {
      throw new Error(`Raw announcement not found: ${rawId}`)
    }

    return [data]
  } else {
    // Fetch all records with status = 'fetched'
    const { data, error } = await supabase
      .from('raw_announcements')
      .select('*')
      .eq('status', 'fetched')
      .eq('is_active', true)
      .order('collected_at', { ascending: true })

    if (error) {
      throw new Error(`Failed to fetch raw announcements: ${error.message}`)
    }

    return data || []
  }
}

/**
 * Print summary statistics
 */
function printSummary(results: TransformationResult[], duration: number): void {
  const successful = results.filter(r => r.success).length
  const failed = results.filter(r => !r.success).length
  const created = results.filter(r => r.action === 'created').length
  const updated = results.filter(r => r.action === 'updated').length
  const skipped = results.filter(r => r.action === 'skipped').length

  console.log(`\n╔════════════════════════════════════════════════════════════════╗`)
  console.log(`║              📊 Transformation Summary                        ║`)
  console.log(`╚════════════════════════════════════════════════════════════════╝\n`)

  console.log(`⏱️  Duration: ${(duration / 1000).toFixed(2)}s`)
  console.log(`\n📈 Results:`)
  console.log(`   Total Records: ${results.length}`)
  console.log(`   ✅ Successful: ${successful}`)
  console.log(`   ❌ Failed: ${failed}`)
  console.log(`\n📝 Actions:`)
  console.log(`   🆕 Created: ${created}`)
  console.log(`   🔄 Updated: ${updated}`)
  console.log(`   ⏭️  Skipped: ${skipped}`)

  // Show errors if any
  const errors = results.filter(r => r.error)
  if (errors.length > 0) {
    console.log(`\n❌ Errors:`)
    errors.forEach((result, idx) => {
      console.log(`   ${idx + 1}. ${result.error}`)
      console.log(`      Raw ID: ${result.rawId}`)
    })
  }

  console.log(`\n${successful === results.length ? '✅ All transformations completed successfully!' : '⚠️  Some transformations failed. Check errors above.'}`)
}

/**
 * Main transformation function
 */
async function runTransformation(): Promise<void> {
  const options = parseArgs()

  // Show help if requested
  if (options.help) {
    showHelp()
    process.exit(0)
  }

  console.log(`╔════════════════════════════════════════════════════════════════╗`)
  console.log(`║        🔄 Pickly Data Transformation Service                  ║`)
  console.log(`║              PRD v9.6.1 - Phase 4C Step 3                     ║`)
  console.log(`╚════════════════════════════════════════════════════════════════╝\n`)

  const startTime = Date.now()

  console.log(`⏰ Started at: ${new Date().toLocaleString()}`)
  console.log(`🧪 Dry Run: ${options.dryRun ? 'YES' : 'NO'}`)
  console.log(`🎯 Target: ${options.rawId ? `Specific record (${options.rawId})` : 'All fetched records'}\n`)

  try {
    // Step 1: Fetch raw announcements
    console.log(`📋 Fetching raw announcements...`)
    const rawRecords = await getRawAnnouncements(options.rawId)

    if (rawRecords.length === 0) {
      console.log(`\n⚠️  No raw announcements found with status='fetched'`)
      console.log(`\nTip: Run 'npm run collect:api' to fetch data from API sources first.\n`)
      process.exit(0)
    }

    console.log(`✅ Found ${rawRecords.length} record(s) to transform\n`)

    // Step 2: Transform each record
    const results: TransformationResult[] = []

    for (let i = 0; i < rawRecords.length; i++) {
      const raw = rawRecords[i]

      console.log(`${'='.repeat(60)}`)
      console.log(`📝 Processing ${i + 1}/${rawRecords.length}`)
      console.log(`   Raw ID: ${raw.id}`)
      console.log(`   Collected: ${new Date(raw.collected_at).toLocaleString()}`)
      console.log(`${'='.repeat(60)}`)

      const result = await transformRawAnnouncement(raw, { dryRun: options.dryRun })
      results.push(result)

      // Add small delay to avoid overwhelming the database
      if (i < rawRecords.length - 1) {
        await new Promise(resolve => setTimeout(resolve, 100))
      }
    }

    // Step 3: Print summary
    const duration = Date.now() - startTime
    printSummary(results, duration)

    // Exit with error code if any transformations failed
    const hasFailures = results.some(r => !r.success)
    process.exit(hasFailures ? 1 : 0)

  } catch (error: any) {
    console.error(`\n❌ Fatal error: ${error.message}\n`)
    console.error(error.stack)
    process.exit(1)
  }
}

// Run if executed directly
if (require.main === module) {
  runTransformation().catch(error => {
    console.error(`Fatal error:`, error)
    process.exit(1)
  })
}

export default runTransformation
