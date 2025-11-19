/**
 * Benefit Management Types
 * PRD v9.6 Section 4.2 - Benefits Management
 */

// =====================================================
// Benefit Category Types
// =====================================================
export interface BenefitCategory {
  id: string
  title: string
  slug: string
  description: string | null
  icon_url: string | null
  icon_name: string | null
  sort_order: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface BenefitCategoryFormData {
  title: string
  slug: string
  description: string | null
  icon_url: string | null
  icon_name: string | null
  sort_order: number
  is_active: boolean
}

// =====================================================
// Benefit Subcategory Types
// =====================================================
export interface BenefitSubcategory {
  id: string
  category_id: string | null
  name: string
  slug: string
  sort_order: number
  is_active: boolean
  icon_url: string | null
  icon_name: string | null
  created_at: string
}

export interface BenefitSubcategoryFormData {
  category_id: string | null
  name: string
  slug: string
  sort_order: number
  is_active: boolean
  icon_url: string | null
  icon_name: string | null
}

// View model with category info
export interface BenefitSubcategoryWithCategory extends BenefitSubcategory {
  category?: BenefitCategory
}

// =====================================================
// Category Banner Types
// =====================================================
export type LinkType = 'internal' | 'external' | 'none'

export interface CategoryBanner {
  id: string
  category_id: string | null
  category_slug: string
  title: string
  subtitle: string | null
  image_url: string
  link_url: string | null
  link_type: LinkType
  background_color: string
  sort_order: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface CategoryBannerFormData {
  category_id: string | null
  category_slug: string
  title: string
  subtitle: string | null
  image_url: string | null
  link_url: string | null
  link_type: LinkType
  background_color: string
  sort_order: number
  is_active: boolean
}

// View model with category info
export interface CategoryBannerWithCategory extends CategoryBanner {
  category?: BenefitCategory
}

// =====================================================
// Announcement Types
// =====================================================
export type AnnouncementStatus = 'recruiting' | 'closed' | 'upcoming' | 'draft'

export interface Announcement {
  id: string
  title: string
  subtitle: string | null
  organization: string
  category_id: string | null
  subcategory_id: string | null
  thumbnail_url: string | null
  external_url: string | null
  detail_url: string | null
  status: AnnouncementStatus
  is_featured: boolean
  is_home_visible: boolean
  is_priority: boolean
  display_priority: number
  tags: string[] | null
  content: string | null
  region: string | null
  application_start_date: string | null
  application_end_date: string | null
  deadline_date: string | null
  views_count: number
  link_type: LinkType
  search_vector: string | null
  created_at: string
  updated_at: string
}

export interface AnnouncementFormData {
  title: string
  subtitle: string | null
  organization: string
  category_id: string | null
  subcategory_id: string | null
  thumbnail_url: string | null
  external_url: string | null
  detail_url: string | null
  status: AnnouncementStatus
  is_featured: boolean
  is_home_visible: boolean
  is_priority: boolean
  display_priority: number
  tags: string[] | null
  content: string | null
  region: string | null
  application_start_date: string | null
  application_end_date: string | null
  deadline_date: string | null
  link_type: LinkType
}

// View model with relations
export interface AnnouncementWithRelations extends Announcement {
  category?: BenefitCategory
  subcategory?: BenefitSubcategory
  tabs?: AnnouncementTab[]
}

// =====================================================
// Announcement Tab Types
// =====================================================
export interface AnnouncementTab {
  id: string
  announcement_id: string | null
  tab_name: string
  age_category_id: string | null
  unit_type: string | null
  floor_plan_image_url: string | null
  supply_count: number | null
  income_conditions: Record<string, any> | null
  additional_info: Record<string, any> | null
  display_order: number
  created_at: string
}

export interface AnnouncementTabFormData {
  announcement_id: string | null
  tab_name: string
  age_category_id: string | null
  unit_type: string | null
  floor_plan_image_url: string | null
  supply_count: number | null
  income_conditions: Record<string, any> | null
  additional_info: Record<string, any> | null
  display_order: number
}

// View model with age category info
export interface AnnouncementTabWithCategory extends AnnouncementTab {
  age_category?: {
    id: string
    name: string
    slug: string
  }
}

// =====================================================
// Age Category Types (Reference)
// =====================================================
export interface AgeCategory {
  id: string
  name: string
  slug: string
  description: string | null
  min_age: number | null
  max_age: number | null
  created_at: string
  updated_at: string
}

// =====================================================
// Statistics & Analytics
// =====================================================
export interface BenefitCategoryStats {
  category_id: string
  category_name: string
  subcategory_count: number
  banner_count: number
  announcement_count: number
  active_announcement_count: number
}

export interface AnnouncementStats {
  total_count: number
  recruiting_count: number
  closed_count: number
  upcoming_count: number
  draft_count: number
  featured_count: number
  home_visible_count: number
}

// =====================================================
// Upload Types
// =====================================================
export interface UploadResult {
  url: string
  path: string
  bucket: string
}

export interface ImageUploadOptions {
  bucket: 'benefit-icons' | 'benefit-thumbnails' | 'benefit-banners'
  maxSizeMB: number
  acceptedFormats: string[]
}

// =====================================================
// Filter & Search Types
// =====================================================
export interface BenefitFilters {
  category_id?: string
  subcategory_id?: string
  status?: AnnouncementStatus
  is_featured?: boolean
  is_active?: boolean
  search?: string
}

export interface PaginationParams {
  page: number
  limit: number
  sort_by?: string
  sort_order?: 'asc' | 'desc'
}

export interface PaginatedResponse<T> {
  data: T[]
  total: number
  page: number
  limit: number
  total_pages: number
}

// =====================================================
// Drag & Drop (reusable from home.ts pattern)
// =====================================================
export interface DragDropItem {
  id: string
  sort_order: number
}

export interface DragDropResult {
  source: {
    index: number
    droppableId: string
  }
  destination: {
    index: number
    droppableId: string
  } | null
}
