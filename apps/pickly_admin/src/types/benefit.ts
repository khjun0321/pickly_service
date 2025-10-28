/**
 * Benefit Management System Types
 * v8.1 - Category, Banner, Program, Announcement
 */

// =====================================================
// Benefit Category
// =====================================================
export interface BenefitCategory {
  id: string
  title: string
  slug: string
  description: string | null
  icon_url: string | null
  sort_order: number
  is_active: boolean
  parent_id: string | null
  custom_fields: Record<string, any> | null
  created_at: string
  updated_at: string
}

export interface BenefitCategoryFormData {
  title: string
  slug: string
  description: string | null
  icon_url: string | null
  sort_order: number
  is_active: boolean
  parent_id: string | null
}

// =====================================================
// Category Banner
// =====================================================
export type BannerLinkType = 'internal' | 'external' | 'none'

export interface CategoryBanner {
  id: string
  benefit_category_id: string
  title: string
  subtitle: string | null
  image_url: string
  link_type: BannerLinkType
  link_target: string | null
  sort_order: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface CategoryBannerFormData {
  benefit_category_id: string
  title: string
  subtitle: string | null
  image_url: string | null
  link_type: BannerLinkType
  link_target: string | null
  sort_order: number
  is_active: boolean
}

// =====================================================
// Benefit Detail (v9.0 - Policy/Program Layer)
// =====================================================
export interface BenefitDetail {
  id: string
  benefit_category_id: string
  title: string
  description: string | null
  icon_url: string | null
  sort_order: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface BenefitDetailFormData {
  benefit_category_id: string
  title: string
  description: string | null
  icon_url: string | null
  sort_order: number
  is_active: boolean
}

// =====================================================
// Benefit Program (v8.1 - Replaces Announcement Type)
// =====================================================
export interface BenefitProgram {
  id: string
  benefit_category_id: string
  title: string
  description: string | null
  icon_url: string | null
  sort_order: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface BenefitProgramFormData {
  benefit_category_id: string
  title: string
  description: string | null
  icon_url: string | null
  sort_order: number
  is_active: boolean
}

// =====================================================
// Announcement Type (Legacy - Deprecated in v8.1)
// =====================================================
export interface AnnouncementType {
  id: string
  benefit_category_id: string
  title: string
  description: string | null
  sort_order: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface AnnouncementTypeFormData {
  benefit_category_id: string
  title: string
  description: string | null
  sort_order: number
  is_active: boolean
}

// =====================================================
// Benefit Announcement (v9.0 - Tab-based with benefit_detail_id)
// =====================================================
export type AnnouncementStatus = 'draft' | 'published' | 'archived'

export interface BenefitAnnouncement {
  id: string
  category_id: string
  benefit_detail_id: string | null
  title: string
  subtitle: string | null
  organization: string
  application_period_start: string | null
  application_period_end: string | null
  announcement_date: string | null
  status: AnnouncementStatus
  is_featured: boolean
  views_count: number
  summary: string | null
  thumbnail_url: string | null
  external_url: string | null
  tags: string[] | null
  search_vector: any
  created_at: string
  updated_at: string
  published_at: string | null
  display_order: number
  custom_data: Record<string, any> | null
  content: string | null
}

export interface BenefitAnnouncementFormData {
  category_id: string
  benefit_detail_id: string
  title: string
  subtitle: string | null
  organization: string
  summary: string | null
  thumbnail_url: string | null
  external_url: string | null
  application_period_start: string | null
  application_period_end: string | null
  status: AnnouncementStatus
  is_featured: boolean
  display_order: number
}

// =====================================================
// Announcement (Legacy - housing_announcements table)
// =====================================================
export interface Announcement {
  id: string
  type_id: string
  title: string
  organization: string
  region: string | null
  thumbnail_url: string | null
  posted_date: string | null
  status: AnnouncementStatus
  is_priority: boolean
  detail_url: string | null
  created_at: string
  updated_at: string
}

export interface AnnouncementFormData {
  type_id: string
  title: string
  organization: string
  region: string | null
  thumbnail_url: string | null
  posted_date: string | null
  status: AnnouncementStatus
  is_priority: boolean
  detail_url: string | null
}

// =====================================================
// Full View (with joined data)
// =====================================================
export interface AnnouncementFull extends Announcement {
  type_title: string
  category_id: string
  category_title: string
}

// =====================================================
// Statistics
// =====================================================
export interface BenefitCategoryStats {
  category_id: string
  category_title: string
  banner_count: number
  type_count: number
  announcement_count: number
  active_announcement_count: number
}
