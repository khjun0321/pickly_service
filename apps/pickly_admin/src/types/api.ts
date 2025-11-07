/**
 * API Mapping Types
 * PRD v9.8.1 Section - API Mapping Management
 * Phase 6.2 - Admin UI Implementation
 */

// =====================================================
// API Source Types
// =====================================================
export interface ApiSource {
  id: string
  name: string
  api_url: string
  api_key: string | null
  status: 'active' | 'inactive'
  last_collected_at: string | null
  created_at: string
  updated_at: string
}

export interface ApiSourceFormData {
  name: string
  api_url: string
  api_key: string | null
  status: 'active' | 'inactive'
}

// =====================================================
// Mapping Config Types
// =====================================================
export interface MappingConfig {
  id: string
  source_id: string
  mapping_rules: Record<string, any>
  created_at: string
  updated_at: string
}

export interface MappingConfigFormData {
  source_id: string
  mapping_rules: Record<string, any>
}

// =====================================================
// Mapping Rules Structure (JSON Schema)
// =====================================================
export interface MappingRules {
  field_mappings?: Record<string, string>
  category_mapping?: Record<string, string>
  transformations?: {
    date_format?: string
    remove_html_tags?: boolean
    [key: string]: any
  }
  [key: string]: any
}

// =====================================================
// Simulator Types
// =====================================================
export interface SimulatorTestInput {
  raw_data: Record<string, any>
  mapping_rules: MappingRules
}

export interface SimulatorTestOutput {
  transformed_data: Record<string, any>
  errors: string[]
  warnings: string[]
}
