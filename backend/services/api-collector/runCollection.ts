#!/usr/bin/env ts-node
/**
 * Run Collection - Orchestrate All Active API Sources
 * PRD v9.6.1 - Phase 4C Step 2
 *
 * Purpose: Main entry point for API collection service
 * Usage:
 *   - Collect all active sources: npm run collect:api
 *   - Dry run mode: npm run collect:api -- --dry-run
 *   - Single source: npm run collect:api -- --source-id=<uuid>
 */

import supabase, { ApiSource } from './supabaseClient'
import { fetchApiSource, CollectionResult } from './fetchApiSource'

/**
 * Parse command line arguments
 */
interface CliOptions {
  dryRun: boolean
  sourceId: string | null
  help: boolean
}

function parseArgs(): CliOptions {
  const args = process.argv.slice(2)

  return {
    dryRun: args.includes('--dry-run'),
    sourceId: args.find((arg) => arg.startsWith('--source-id='))?.split('=')[1] || null,
    help: args.includes('--help') || args.includes('-h'),
  }
}

/**
 * Display help message
 */
function showHelp() {
  console.log(`
╔════════════════════════════════════════════════════════════════════════╗
║                  Pickly API Collection Service                         ║
║                     PRD v9.6.1 - Phase 4C Step 2                       ║
╚════════════════════════════════════════════════════════════════════════╝

Usage:
  npm run collect:api [options]

Options:
  --dry-run               Run without actually collecting data (test mode)
  --source-id=<uuid>      Collect from a specific API source only
  --help, -h              Show this help message

Examples:
  npm run collect:api                          # Collect from all active sources
  npm run collect:api -- --dry-run             # Test without collecting
  npm run collect:api -- --source-id=<uuid>    # Collect from one source

Environment Variables:
  SUPABASE_URL                    Supabase project URL (default: http://127.0.0.1:54321)
  SUPABASE_SERVICE_ROLE_KEY       Supabase service role key (required)
  SUPABASE_ANON_KEY               Fallback if service role key not set

Database Tables:
  - api_sources               → Source configuration
  - api_collection_logs       → Execution logs
  - raw_announcements         → Raw API responses

For more information, see:
  docs/PHASE4C_STEP2_API_COLLECTOR_COMPLETE.md
`)
}

/**
 * Fetch all active API sources
 */
async function getActiveSources(sourceId: string | null = null): Promise<ApiSource[]> {
  let query = supabase.from('api_sources').select('*')

  if (sourceId) {
    query = query.eq('id', sourceId)
  } else {
    query = query.eq('is_active', true)
  }

  const { data, error } = await query.order('name')

  if (error) {
    throw new Error(`Failed to fetch API sources: ${error.message}`)
  }

  return data || []
}

/**
 * Run collection for all active sources
 */
async function runCollection(options: CliOptions): Promise<void> {
  const startTime = new Date()

  console.log(`\n╔════════════════════════════════════════════════════════════════════════╗`)
  console.log(`║                  🚀 Pickly API Collection Service                      ║`)
  console.log(`║                     PRD v9.6.1 - Phase 4C Step 2                       ║`)
  console.log(`╚════════════════════════════════════════════════════════════════════════╝\n`)

  console.log(`⏰ Started at: ${startTime.toLocaleString()}`)
  console.log(`🧪 Dry Run: ${options.dryRun ? 'YES' : 'NO'}`)
  console.log(`🎯 Source Filter: ${options.sourceId || 'All active sources'}\n`)

  try {
    // Step 1: Fetch active API sources
    console.log(`📋 Fetching active API sources...`)
    const sources = await getActiveSources(options.sourceId)

    if (sources.length === 0) {
      console.log(`\n⚠️  No active API sources found`)
      if (options.sourceId) {
        console.log(`   Source ID: ${options.sourceId} not found or not active`)
      }
      console.log(`\n💡 Tip: Enable API sources in the admin panel or check the database:\n`)
      console.log(`   SELECT id, name, is_active FROM api_sources;\n`)
      return
    }

    console.log(`✅ Found ${sources.length} active source(s):\n`)
    sources.forEach((source, index) => {
      console.log(`   ${index + 1}. ${source.name}`)
      console.log(`      ID: ${source.id}`)
      console.log(`      Endpoint: ${source.endpoint_url}`)
      console.log(`      Auth: ${source.auth_type}`)
      console.log(`      Last Collected: ${source.last_collected_at || 'Never'}\n`)
    })

    // Step 2: Collect from each source sequentially
    const results: Array<{ source: ApiSource; result: CollectionResult }> = []

    for (let i = 0; i < sources.length; i++) {
      const source = sources[i]
      console.log(`\n┌${'─'.repeat(70)}┐`)
      console.log(`│ [${i + 1}/${sources.length}] Processing: ${source.name.padEnd(55)} │`)
      console.log(`└${'─'.repeat(70)}┘`)

      try {
        const result = await fetchApiSource(source, { dryRun: options.dryRun })
        results.push({ source, result })

        if (result.success) {
          console.log(`✅ SUCCESS`)
        } else {
          console.log(`❌ FAILED: ${result.error}`)
        }
      } catch (error: any) {
        console.error(`❌ Unexpected error: ${error.message}`)
        results.push({
          source,
          result: {
            success: false,
            logId: null,
            recordsFetched: 0,
            recordsProcessed: 0,
            recordsFailed: 0,
            error: error.message,
            errorSummary: { type: 'unexpected_error', message: error.message },
          },
        })
      }

      // Add delay between sources to avoid rate limiting
      if (i < sources.length - 1 && !options.dryRun) {
        console.log(`\n⏳ Waiting 2 seconds before next source...`)
        await new Promise((resolve) => setTimeout(resolve, 2000))
      }
    }

    // Step 3: Summary report
    const endTime = new Date()
    const duration = endTime.getTime() - startTime.getTime()

    console.log(`\n\n╔════════════════════════════════════════════════════════════════════════╗`)
    console.log(`║                         📊 Collection Summary                          ║`)
    console.log(`╚════════════════════════════════════════════════════════════════════════╝\n`)

    console.log(`⏰ Completed at: ${endTime.toLocaleString()}`)
    console.log(`⏱️  Duration: ${(duration / 1000).toFixed(2)}s\n`)

    const totalSuccess = results.filter((r) => r.result.success).length
    const totalFailed = results.filter((r) => !r.result.success).length
    const totalFetched = results.reduce((sum, r) => sum + r.result.recordsFetched, 0)
    const totalProcessed = results.reduce((sum, r) => sum + r.result.recordsProcessed, 0)
    const totalRecordsFailed = results.reduce((sum, r) => sum + r.result.recordsFailed, 0)

    console.log(`📈 Results:`)
    console.log(`   Total Sources: ${sources.length}`)
    console.log(`   ✅ Successful: ${totalSuccess}`)
    console.log(`   ❌ Failed: ${totalFailed}`)
    console.log(`   📊 Records Fetched: ${totalFetched}`)
    console.log(`   ✅ Records Processed: ${totalProcessed}`)
    console.log(`   ❌ Records Failed: ${totalRecordsFailed}\n`)

    if (totalFailed > 0) {
      console.log(`❌ Failed Sources:\n`)
      results
        .filter((r) => !r.result.success)
        .forEach((r) => {
          console.log(`   - ${r.source.name}`)
          console.log(`     Error: ${r.result.error}\n`)
        })
    }

    if (!options.dryRun) {
      console.log(`💾 Database Records Created:`)
      const logIds = results.map((r) => r.result.logId).filter(Boolean)
      console.log(`   Collection Logs: ${logIds.length}`)
      console.log(`   Raw Announcements: ${totalProcessed}\n`)

      if (logIds.length > 0) {
        console.log(`📋 Collection Log IDs:`)
        logIds.forEach((id) => console.log(`   - ${id}`))
        console.log()
      }

      console.log(`🔍 Verify records:`)
      console.log(`   docker exec -i supabase_db_supabase psql -U postgres -d postgres -c "SELECT id, api_source_id, status FROM api_collection_logs ORDER BY started_at DESC LIMIT 10;"`)
      console.log(`   docker exec -i supabase_db_supabase psql -U postgres -d postgres -c "SELECT id, status, collected_at FROM raw_announcements ORDER BY collected_at DESC LIMIT 10;"\n`)
    }

    // Exit with error code if any collection failed
    if (totalFailed > 0) {
      console.log(`\n⚠️  ${totalFailed} source(s) failed. Exiting with error code 1\n`)
      process.exit(1)
    }

    console.log(`\n✅ All collections completed successfully!\n`)

  } catch (error: any) {
    console.error(`\n❌ Fatal error: ${error.message}`)
    console.error(error.stack)
    process.exit(1)
  }
}

/**
 * Main entry point
 */
async function main() {
  const options = parseArgs()

  if (options.help) {
    showHelp()
    process.exit(0)
  }

  await runCollection(options)
}

// Run if executed directly
if (require.main === module) {
  main().catch((error) => {
    console.error('Fatal error:', error)
    process.exit(1)
  })
}

export { runCollection, getActiveSources }
export default runCollection
