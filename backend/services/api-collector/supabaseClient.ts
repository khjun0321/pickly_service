/**
 * Supabase Client for API Collector Service
 * PRD v9.6.1 - Phase 4C Step 2
 *
 * Purpose: Shared Supabase client configuration for API collection service
 */

import { createClient, SupabaseClient } from '@supabase/supabase-js'
import * as dotenv from 'dotenv'
import * as path from 'path'

// Load environment variables from .env file
dotenv.config({ path: path.join(__dirname, '../../.env') })

// Load environment variables
const SUPABASE_URL = process.env.SUPABASE_URL || 'http://127.0.0.1:54321'
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY

if (!SUPABASE_SERVICE_ROLE_KEY) {
  throw new Error('SUPABASE_SERVICE_ROLE_KEY or SUPABASE_ANON_KEY must be set')
}

/**
 * Create Supabase client with service role key
 * Bypasses RLS policies for background jobs
 */
export const supabase: SupabaseClient = createClient(
  SUPABASE_URL,
  SUPABASE_SERVICE_ROLE_KEY,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  }
)

/**
 * Database type definitions for API collector
 */
export interface ApiSource {
  id: string
  name: string
  description: string | null
  endpoint_url: string
  auth_type: 'none' | 'api_key' | 'bearer' | 'oauth'
  auth_key: string | null
  mapping_config: {
    fields?: Record<string, string>
    target_category?: string
    filters?: Record<string, any>
    [key: string]: any
  }
  collection_schedule: string | null
  is_active: boolean
  last_collected_at: string | null
  created_at: string
  updated_at: string
}

export interface ApiCollectionLog {
  id: string
  api_source_id: string
  status: 'running' | 'success' | 'partial' | 'failed'
  records_fetched: number
  records_processed: number
  records_failed: number
  error_message: string | null
  error_summary: Record<string, any> | null
  started_at: string
  completed_at: string | null
  created_at: string
}

export interface RawAnnouncement {
  id: string
  api_source_id: string
  collection_log_id: string | null
  raw_payload: Record<string, any>
  status: 'fetched' | 'processed' | 'error'
  error_log: string | null
  collected_at: string
  processed_at: string | null
  is_active: boolean
  created_at: string
  updated_at: string
}

export default supabase
