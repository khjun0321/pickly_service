/**
 * API Management Types
 * PRD v9.6 Section 4.3 & 5.5 - API Source Management
 */

export type AuthType = 'none' | 'api_key' | 'bearer' | 'oauth'

export interface MappingConfig {
  fields: {
    [sourceField: string]: string // API field name → DB field name mapping
  }
  target_category?: string // Which benefit category this API targets
  filters?: {
    [key: string]: any // Optional API request filters
  }
  [key: string]: any // Allow additional configuration
}

export interface ApiSource {
  id: string
  name: string
  description: string | null
  endpoint_url: string
  auth_type: AuthType
  auth_key: string | null
  mapping_config: MappingConfig
  collection_schedule: string | null // Cron expression
  is_active: boolean
  last_collected_at: string | null
  created_at: string
  updated_at: string
}

export interface ApiSourceFormData {
  name: string
  description: string | null
  endpoint_url: string
  auth_type: AuthType
  auth_key: string | null
  mapping_config: MappingConfig
  collection_schedule: string | null
  is_active: boolean
}

// Collection Log Types (for future Phase 4B)
export interface CollectionLog {
  id: string
  api_source_id: string
  started_at: string
  completed_at: string | null
  status: 'running' | 'success' | 'partial' | 'failed'
  records_fetched: number
  records_processed: number
  records_failed: number
  error_summary: Record<string, any> | null
}

// Raw Announcement Types (for future Phase 4B)
export interface RawAnnouncement {
  id: string
  api_source_id: string
  raw_payload: Record<string, any>
  collection_timestamp: string
  status: 'pending' | 'processed' | 'error'
  processed_at: string | null
  created_announcement_id: string | null
  error_message: string | null
}
