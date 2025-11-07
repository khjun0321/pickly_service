/**
 * Fetch API Source - Single Source Collection
 * PRD v9.6.1 - Phase 4C Step 2
 *
 * Purpose: Fetch data from a single API source and store in raw_announcements
 */

import supabase, { ApiSource, ApiCollectionLog, RawAnnouncement } from './supabaseClient'

export interface CollectionResult {
  success: boolean
  logId: string | null
  recordsFetched: number
  recordsProcessed: number
  recordsFailed: number
  error: string | null
  errorSummary: Record<string, any> | null
}

/**
 * Fetch data from a single API source
 *
 * Flow:
 * 1. Create collection log (status: running)
 * 2. Fetch data from API endpoint
 * 3. Store raw responses in raw_announcements
 * 4. Update collection log (status: success/failed)
 * 5. Update api_sources.last_collected_at
 */
export async function fetchApiSource(
  source: ApiSource,
  options: { dryRun?: boolean } = {}
): Promise<CollectionResult> {
  const { dryRun = false } = options

  console.log(`\n${'='.repeat(60)}`)
  console.log(`📡 Collecting from: ${source.name}`)
  console.log(`🔗 Endpoint: ${source.endpoint_url}`)
  console.log(`🔐 Auth Type: ${source.auth_type}`)
  console.log(`🧪 Dry Run: ${dryRun ? 'YES' : 'NO'}`)
  console.log(`${'='.repeat(60)}\n`)

  let logId: string | null = null
  const startTime = new Date()

  try {
    // Step 1: Create collection log (status: running)
    if (!dryRun) {
      const { data: log, error: logError } = await supabase
        .from('api_collection_logs')
        .insert({
          api_source_id: source.id,
          status: 'running',
          started_at: startTime.toISOString(),
          records_fetched: 0,
          records_processed: 0,
          records_failed: 0,
        })
        .select()
        .single()

      if (logError) {
        throw new Error(`Failed to create collection log: ${logError.message}`)
      }

      logId = log.id
      console.log(`✅ Created collection log: ${logId}`)
    } else {
      console.log(`🧪 [DRY RUN] Would create collection log`)
    }

    // Step 2: Prepare HTTP request headers
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'User-Agent': 'Pickly-API-Collector/1.0',
    }

    // Add authentication headers
    if (source.auth_type === 'api_key' && source.auth_key) {
      headers['X-API-Key'] = source.auth_key
    } else if (source.auth_type === 'bearer' && source.auth_key) {
      headers['Authorization'] = `Bearer ${source.auth_key}`
    }

    // Step 3: Fetch data from API endpoint
    console.log(`📥 Fetching data from API...`)

    if (dryRun) {
      console.log(`🧪 [DRY RUN] Would fetch from: ${source.endpoint_url}`)
      console.log(`🧪 [DRY RUN] Headers:`, JSON.stringify(headers, null, 2))

      return {
        success: true,
        logId: null,
        recordsFetched: 0,
        recordsProcessed: 0,
        recordsFailed: 0,
        error: null,
        errorSummary: null,
      }
    }

    const response = await fetch(source.endpoint_url, {
      method: 'GET',
      headers,
      signal: AbortSignal.timeout(30000), // 30 second timeout
    })

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }

    const contentType = response.headers.get('content-type')
    if (!contentType?.includes('application/json')) {
      throw new Error(`Invalid content type: ${contentType}. Expected application/json`)
    }

    const rawData: any = await response.json()
    console.log(`✅ Received API response (${response.status})`)

    // Step 4: Normalize response to array
    let records: any[] = []

    if (Array.isArray(rawData)) {
      records = rawData
    } else if (rawData?.data && Array.isArray(rawData.data)) {
      records = rawData.data
    } else if (rawData?.items && Array.isArray(rawData.items)) {
      records = rawData.items
    } else if (rawData?.results && Array.isArray(rawData.results)) {
      records = rawData.results
    } else {
      // Single record response
      records = [rawData]
    }

    console.log(`📊 Found ${records.length} records`)

    // Step 5: Store each record in raw_announcements
    const insertResults = await Promise.allSettled(
      records.map(async (record) => {
        const { data, error } = await supabase
          .from('raw_announcements')
          .insert({
            api_source_id: source.id,
            collection_log_id: logId,
            raw_payload: record,
            status: 'fetched',
            collected_at: new Date().toISOString(),
            is_active: true,
          })
          .select()
          .single()

        if (error) {
          throw error
        }

        return data
      })
    )

    const successful = insertResults.filter((r) => r.status === 'fulfilled').length
    const failed = insertResults.filter((r) => r.status === 'rejected').length

    console.log(`✅ Inserted ${successful} records into raw_announcements`)
    if (failed > 0) {
      console.log(`⚠️  Failed to insert ${failed} records`)
    }

    // Step 6: Update collection log (success/partial)
    const endTime = new Date()
    const status = failed === 0 ? 'success' : 'partial'

    const failedReasons = insertResults
      .filter((r) => r.status === 'rejected')
      .map((r) => (r as PromiseRejectedResult).reason?.message || 'Unknown error')

    const { error: updateError } = await supabase
      .from('api_collection_logs')
      .update({
        status,
        records_fetched: records.length,
        records_processed: successful,
        records_failed: failed,
        completed_at: endTime.toISOString(),
        error_summary: failed > 0 ? { failed_records: failed, errors: failedReasons } : null,
      })
      .eq('id', logId!)

    if (updateError) {
      console.error(`❌ Failed to update collection log:`, updateError)
    }

    // Step 7: Update api_sources.last_collected_at
    const { error: sourceUpdateError } = await supabase
      .from('api_sources')
      .update({ last_collected_at: endTime.toISOString() })
      .eq('id', source.id)

    if (sourceUpdateError) {
      console.error(`❌ Failed to update last_collected_at:`, sourceUpdateError)
    }

    console.log(`\n✅ Collection completed successfully`)
    console.log(`   Status: ${status}`)
    console.log(`   Fetched: ${records.length}`)
    console.log(`   Processed: ${successful}`)
    console.log(`   Failed: ${failed}`)
    console.log(`   Duration: ${endTime.getTime() - startTime.getTime()}ms\n`)

    return {
      success: status === 'success',
      logId,
      recordsFetched: records.length,
      recordsProcessed: successful,
      recordsFailed: failed,
      error: null,
      errorSummary: failed > 0 ? { failed_records: failed, errors: failedReasons } : null,
    }

  } catch (error: any) {
    const endTime = new Date()
    const errorMessage = error.message || 'Unknown error'

    console.error(`\n❌ Collection failed: ${errorMessage}\n`)

    // Update collection log with failure
    if (logId) {
      await supabase
        .from('api_collection_logs')
        .update({
          status: 'failed',
          error_message: errorMessage,
          error_summary: {
            error_type: error.name || 'Error',
            error_code: error.code,
            stack: error.stack?.split('\n').slice(0, 3),
          },
          completed_at: endTime.toISOString(),
        })
        .eq('id', logId)
    }

    return {
      success: false,
      logId,
      recordsFetched: 0,
      recordsProcessed: 0,
      recordsFailed: 0,
      error: errorMessage,
      errorSummary: {
        error_type: error.name || 'Error',
        error_code: error.code,
        message: errorMessage,
      },
    }
  }
}

export default fetchApiSource
