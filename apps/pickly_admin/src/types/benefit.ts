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
// Benefit Announcement (v8.1)
// =====================================================
export type AnnouncementStatus = 'active' | 'closed' | 'upcoming'

export interface BenefitAnnouncement {
  id: string
  benefit_category_id: string
  benefit_program_id: string | null
  title: string
  subtitle: string | null
  content: string | null
  organization: string | null
  region: string | null
  thumbnail_url: string | null
  detail_url: string | null
  application_start_date: string | null
  application_end_date: string | null
  announcement_start_date: string | null
  announcement_end_date: string | null
  status: AnnouncementStatus
  display_order: number
  is_featured: boolean
  custom_data: Record<string, any> | null
  created_at: string
  updated_at: string
}

export interface BenefitAnnouncementFormData {
  benefit_category_id: string
  benefit_program_id: string | null
  title: string
  subtitle: string | null
  content: string | null
  organization: string | null
  region: string | null
  thumbnail_url: string | null
  detail_url: string | null
  application_start_date: string | null
  application_end_date: string | null
  announcement_start_date: string | null
  announcement_end_date: string | null
  status: AnnouncementStatus
  display_order: number
  is_featured: boolean
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
