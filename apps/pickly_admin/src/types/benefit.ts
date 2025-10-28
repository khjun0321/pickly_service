/**
 * Benefit Management System Types
 * v7.3 - Category, Banner, Announcement Type, Announcement
 */

// =====================================================
// Benefit Category
// =====================================================
export interface BenefitCategory {
  id: string
  title: string
  icon_url: string | null
  sort_order: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface BenefitCategoryFormData {
  title: string
  icon_url: string | null
  sort_order: number
  is_active: boolean
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
// Announcement Type
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
// Announcement
// =====================================================
export type AnnouncementStatus = 'active' | 'closed' | 'upcoming'

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
