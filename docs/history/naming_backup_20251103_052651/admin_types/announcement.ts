/**
 * Announcement and Type Management
 *
 * Type definitions for the announcement system including:
 * - Age categories
 * - Announcement tabs (formerly types)
 * - Custom content structures
 */

import type { Database } from './database'

// Re-export database types
export type AgeCategory = Database['public']['Tables']['age_categories']['Row']
export type AgeCategoryInsert = Database['public']['Tables']['age_categories']['Insert']
export type AgeCategoryUpdate = Database['public']['Tables']['age_categories']['Update']

export type Announcement = Database['public']['Tables']['announcements']['Row']
export type AnnouncementInsert = Database['public']['Tables']['announcements']['Insert']
export type AnnouncementUpdate = Database['public']['Tables']['announcements']['Update']

export type AnnouncementTab = Database['public']['Tables']['announcement_tabs']['Row']
export type AnnouncementTabInsert = Database['public']['Tables']['announcement_tabs']['Insert']
export type AnnouncementTabUpdate = Database['public']['Tables']['announcement_tabs']['Update']

/**
 * Custom content structure for announcement tabs
 * Stores flexible JSON data including images, PDFs, and notes
 */
export interface CustomContent {
  images?: {
    url: string
    caption?: string
    order: number
  }[]
  pdfs?: {
    url: string
    title: string
    order: number
  }[]
  extra_notes?: string
}

/**
 * Income conditions structure
 */
export interface IncomeCondition {
  min_income?: number
  max_income?: number
  description: string
}

/**
 * Form data for creating/editing age categories
 */
export interface AgeCategoryFormData {
  title: string
  description: string
  icon_component?: string
  icon_url: string | null
  min_age: number | null
  max_age: number | null
  sort_order: number
  is_active: boolean
}

/**
 * Form data for creating/editing announcement tabs
 */
export interface AnnouncementTabFormData {
  announcement_id: string
  age_category_id: string | null
  tab_name: string
  unit_type: string | null
  supply_count: number | null
  floor_plan_image_url: string | null
  income_conditions: IncomeCondition[] | null
  additional_info: CustomContent | null
  display_order: number
}

/**
 * File upload metadata
 */
export interface UploadedFile {
  url: string
  path: string
  name: string
  size: number
  type: string
}

/**
 * Announcement with populated relationships
 */
export interface AnnouncementWithTabs extends Announcement {
  tabs?: AnnouncementTab[]
  category?: {
    id: string
    name: string
  }
}
