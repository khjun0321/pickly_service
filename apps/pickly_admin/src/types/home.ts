/**
 * Home Management Types
 * PRD v9.6 Section 4.1 - Home Management
 */

// =====================================================
// Home Section Types
// =====================================================
export type SectionType = 'community' | 'featured' | 'announcements'

export interface HomeSection {
  id: string
  title: string
  section_type: SectionType
  description: string | null
  sort_order: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface HomeSectionFormData {
  title: string
  section_type: SectionType
  description: string | null
  sort_order: number
  is_active: boolean
}

// =====================================================
// Featured Content Types
// =====================================================
export type LinkType = 'internal' | 'external' | 'none'

export interface FeaturedContent {
  id: string
  section_id: string
  title: string
  subtitle: string | null
  image_url: string
  link_url: string | null
  link_type: LinkType
  sort_order: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface FeaturedContentFormData {
  section_id: string
  title: string
  subtitle: string | null
  image_url: string | null
  link_url: string | null
  link_type: LinkType
  sort_order: number
  is_active: boolean
}

// =====================================================
// View Models (with joined data)
// =====================================================
export interface HomeSectionWithContents extends HomeSection {
  contents: FeaturedContent[]
  content_count: number
}

// =====================================================
// Statistics
// =====================================================
export interface HomeSectionStats {
  section_id: string
  section_title: string
  content_count: number
  active_content_count: number
  views_count: number
}

// =====================================================
// Drag & Drop
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
