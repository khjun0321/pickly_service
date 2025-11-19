/**
 * Transform Raw Announcement - Single Record Transformation
 * PRD v9.6.1 - Phase 4C Step 3
 *
 * Purpose: Transform a single raw_announcement using mapping_config
 */

import supabase, { ApiSource, RawAnnouncement, Announcement, TransformationResult } from './supabaseClient'

/**
 * Get nested value from object using dot notation path
 * Example: getNestedValue({a: {b: {c: 1}}}, 'a.b.c') => 1
 */
function getNestedValue(obj: any, path: string): any {
  if (!path || !obj) return undefined

  const keys = path.split('.')
  let current = obj

  for (const key of keys) {
    if (current === null || current === undefined) return undefined
    current = current[key]
  }

  return current
}

/**
 * Apply field mapping from mapping_config
 *
 * mapping_config.fields format:
 * {
 *   "title": "response.title",           // Direct mapping
 *   "organization": "response.org_name", // Nested path
 *   "content": "response.description"
 * }
 */
function applyFieldMapping(
  rawPayload: Record<string, any>,
  mappingConfig: ApiSource['mapping_config']
): Partial<Announcement> {
  const mapped: any = {}

  if (!mappingConfig.fields) {
    return mapped
  }

  // Apply each field mapping
  for (const [targetField, sourcePath] of Object.entries(mappingConfig.fields)) {
    const value = getNestedValue(rawPayload, sourcePath)

    if (value !== undefined && value !== null) {
      // Type conversion for specific fields
      if (targetField === 'tags' && typeof value === 'string') {
        // Convert comma-separated string to array
        mapped[targetField] = value.split(',').map((t: string) => t.trim())
      } else if (targetField === 'is_featured' || targetField === 'is_home_visible' || targetField === 'is_priority') {
        // Convert to boolean
        mapped[targetField] = Boolean(value)
      } else if (targetField === 'display_priority' || targetField === 'views_count') {
        // Convert to number
        mapped[targetField] = Number(value) || 0
      } else if (targetField.includes('_date')) {
        // Convert to ISO string for date fields
        mapped[targetField] = new Date(value).toISOString()
      } else {
        mapped[targetField] = value
      }
    }
  }

  // Apply defaults from mapping_config
  if (mappingConfig.defaults) {
    for (const [field, value] of Object.entries(mappingConfig.defaults)) {
      if (mapped[field] === undefined) {
        mapped[field] = value
      }
    }
  }

  // Apply target category/subcategory if specified
  if (mappingConfig.target_category && !mapped.category_id) {
    mapped.category_id = mappingConfig.target_category
  }

  if (mappingConfig.target_subcategory && !mapped.subcategory_id) {
    mapped.subcategory_id = mappingConfig.target_subcategory
  }

  return mapped
}

/**
 * Validate required fields for announcement
 */
function validateAnnouncement(announcement: Partial<Announcement>): { valid: boolean; errors: string[] } {
  const errors: string[] = []

  // Required fields based on announcements table schema
  if (!announcement.title || announcement.title.trim() === '') {
    errors.push('title is required')
  }

  if (!announcement.organization || announcement.organization.trim() === '') {
    errors.push('organization is required')
  }

  // Validate enum values
  if (announcement.status && !['recruiting', 'closed', 'upcoming', 'draft'].includes(announcement.status)) {
    errors.push(`Invalid status: ${announcement.status}`)
  }

  if (announcement.link_type && !['internal', 'external', 'none'].includes(announcement.link_type)) {
    errors.push(`Invalid link_type: ${announcement.link_type}`)
  }

  return {
    valid: errors.length === 0,
    errors,
  }
}

/**
 * Transform a single raw announcement to announcement
 *
 * Flow:
 * 1. Fetch api_source for mapping_config
 * 2. Apply field mapping
 * 3. Validate result
 * 4. Insert/Update announcement
 * 5. Update raw_announcement status
 */
export async function transformRawAnnouncement(
  raw: RawAnnouncement,
  options: { dryRun?: boolean } = {}
): Promise<TransformationResult> {
  const { dryRun = false } = options

  try {
    // Step 1: Fetch API source for mapping config
    const { data: apiSource, error: sourceError } = await supabase
      .from('api_sources')
      .select('*')
      .eq('id', raw.api_source_id)
      .single()

    if (sourceError || !apiSource) {
      throw new Error(`Failed to fetch api_source: ${sourceError?.message || 'not found'}`)
    }

    // Check if mapping_config exists
    if (!apiSource.mapping_config || !apiSource.mapping_config.fields) {
      console.log(`⚠️  No mapping_config found for source: ${apiSource.name}`)

      if (!dryRun) {
        // Mark as skipped (keep status as 'fetched')
        await supabase
          .from('raw_announcements')
          .update({
            error_log: 'No mapping_config available - skipped transformation',
          })
          .eq('id', raw.id)
      }

      return {
        success: false,
        rawId: raw.id,
        announcementId: null,
        error: 'No mapping_config available',
        action: 'skipped',
      }
    }

    console.log(`\n🔄 Transforming raw announcement: ${raw.id}`)
    console.log(`   Source: ${apiSource.name}`)
    console.log(`   Mapping fields: ${Object.keys(apiSource.mapping_config.fields || {}).length}`)

    // Step 2: Apply field mapping
    const mappedAnnouncement = applyFieldMapping(raw.raw_payload, apiSource.mapping_config)

    // Add default values
    if (!mappedAnnouncement.status) {
      mappedAnnouncement.status = 'recruiting'
    }
    if (!mappedAnnouncement.link_type) {
      mappedAnnouncement.link_type = 'external'
    }

    console.log(`   Mapped fields: ${Object.keys(mappedAnnouncement).length}`)

    // Step 3: Validate
    const validation = validateAnnouncement(mappedAnnouncement)

    if (!validation.valid) {
      const errorMsg = `Validation failed: ${validation.errors.join(', ')}`
      console.error(`❌ ${errorMsg}`)

      if (!dryRun) {
        // Mark as error
        await supabase
          .from('raw_announcements')
          .update({
            status: 'error',
            error_log: errorMsg,
          })
          .eq('id', raw.id)
      }

      return {
        success: false,
        rawId: raw.id,
        announcementId: null,
        error: errorMsg,
        action: 'failed',
      }
    }

    if (dryRun) {
      console.log(`🧪 [DRY RUN] Would insert/update announcement:`)
      console.log(JSON.stringify(mappedAnnouncement, null, 2))

      return {
        success: true,
        rawId: raw.id,
        announcementId: null,
        error: null,
        action: 'created',
      }
    }

    // Step 4: Insert or Update announcement
    // Check if announcement with same title + organization exists (deduplication)
    const { data: existing } = await supabase
      .from('announcements')
      .select('id')
      .eq('title', mappedAnnouncement.title)
      .eq('organization', mappedAnnouncement.organization)
      .single()

    let announcementId: string
    let action: 'created' | 'updated'

    if (existing) {
      // Update existing
      const { data: updated, error: updateError } = await supabase
        .from('announcements')
        .update({
          ...mappedAnnouncement,
          updated_at: new Date().toISOString(),
        })
        .eq('id', existing.id)
        .select('id')
        .single()

      if (updateError) {
        throw new Error(`Failed to update announcement: ${updateError.message}`)
      }

      announcementId = updated.id
      action = 'updated'
      console.log(`✅ Updated announcement: ${announcementId}`)
    } else {
      // Insert new
      const { data: inserted, error: insertError } = await supabase
        .from('announcements')
        .insert(mappedAnnouncement)
        .select('id')
        .single()

      if (insertError) {
        throw new Error(`Failed to insert announcement: ${insertError.message}`)
      }

      announcementId = inserted.id
      action = 'created'
      console.log(`✅ Created announcement: ${announcementId}`)
    }

    // Step 5: Update raw_announcement status
    const { error: updateRawError } = await supabase
      .from('raw_announcements')
      .update({
        status: 'processed',
        processed_at: new Date().toISOString(),
        error_log: null, // Clear any previous errors
      })
      .eq('id', raw.id)

    if (updateRawError) {
      console.error(`⚠️  Failed to update raw_announcement status: ${updateRawError.message}`)
    }

    return {
      success: true,
      rawId: raw.id,
      announcementId,
      error: null,
      action,
    }

  } catch (error: any) {
    const errorMessage = error.message || 'Unknown error'
    console.error(`\n❌ Transformation failed: ${errorMessage}\n`)

    if (!dryRun) {
      // Mark as error
      await supabase
        .from('raw_announcements')
        .update({
          status: 'error',
          error_log: errorMessage,
        })
        .eq('id', raw.id)
    }

    return {
      success: false,
      rawId: raw.id,
      announcementId: null,
      error: errorMessage,
      action: 'failed',
    }
  }
}

export default transformRawAnnouncement
