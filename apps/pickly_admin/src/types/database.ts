export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      user_profiles: {
        Row: {
          id: string
          user_id: string | null
          name: string | null
          age: number | null
          gender: string | null
          region_sido: string | null
          region_sigungu: string | null
          selected_categories: string[] | null
          income_level: string | null
          interest_policies: string[] | null
          onboarding_completed: boolean
          onboarding_step: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id?: string | null
          name?: string | null
          age?: number | null
          gender?: string | null
          region_sido?: string | null
          region_sigungu?: string | null
          selected_categories?: string[] | null
          income_level?: string | null
          interest_policies?: string[] | null
          onboarding_completed?: boolean
          onboarding_step?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string | null
          name?: string | null
          age?: number | null
          gender?: string | null
          region_sido?: string | null
          region_sigungu?: string | null
          selected_categories?: string[] | null
          income_level?: string | null
          interest_policies?: string[] | null
          onboarding_completed?: boolean
          onboarding_step?: number
          created_at?: string
          updated_at?: string
        }
      }
      age_categories: {
        Row: {
          id: string
          title: string
          description: string
          icon_component: string
          icon_url: string | null
          min_age: number | null
          max_age: number | null
          sort_order: number
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          title: string
          description: string
          icon_component: string
          icon_url?: string | null
          min_age?: number | null
          max_age?: number | null
          sort_order?: number
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          title?: string
          description?: string
          icon_component?: string
          icon_url?: string | null
          min_age?: number | null
          max_age?: number | null
          sort_order?: number
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      benefit_categories: {
        Row: {
          id: string
          name: string
          slug: string
          description: string | null
          icon_url: string | null
          banner_image_url: string | null
          banner_link_url: string | null
          display_order: number
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          slug: string
          description?: string | null
          icon_url?: string | null
          banner_image_url?: string | null
          banner_link_url?: string | null
          display_order?: number
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          slug?: string
          description?: string | null
          icon_url?: string | null
          banner_image_url?: string | null
          banner_link_url?: string | null
          display_order?: number
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      benefit_announcements: {
        Row: {
          id: string
          category_id: string
          title: string
          subtitle: string | null
          organization: string | null
          application_period_start: string | null
          application_period_end: string | null
          announcement_date: string | null
          status: string
          is_featured: boolean
          views_count: number
          summary: string | null
          thumbnail_url: string | null
          external_url: string | null
          tags: string[] | null
          search_vector: string | null
          created_at: string
          updated_at: string
          published_at: string | null
        }
        Insert: {
          id?: string
          category_id: string
          title: string
          subtitle?: string | null
          organization?: string | null
          application_period_start?: string | null
          application_period_end?: string | null
          announcement_date?: string | null
          status?: string
          is_featured?: boolean
          views_count?: number
          summary?: string | null
          thumbnail_url?: string | null
          external_url?: string | null
          tags?: string[] | null
          search_vector?: string | null
          created_at?: string
          updated_at?: string
          published_at?: string | null
        }
        Update: {
          id?: string
          category_id?: string
          title?: string
          subtitle?: string | null
          organization?: string | null
          application_period_start?: string | null
          application_period_end?: string | null
          announcement_date?: string | null
          status?: string
          is_featured?: boolean
          views_count?: number
          summary?: string | null
          thumbnail_url?: string | null
          external_url?: string | null
          tags?: string[] | null
          search_vector?: string | null
          created_at?: string
          updated_at?: string
          published_at?: string | null
        }
      }
      announcement_unit_types: {
        Row: {
          id: string
          announcement_id: string
          unit_type: string
          supply_area: number | null
          exclusive_area: number | null
          supply_count: number | null
          monthly_rent: number | null
          deposit: number | null
          maintenance_fee: number | null
          floor_info: string | null
          direction: string | null
          room_structure: string | null
          additional_info: Json | null
          sort_order: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          announcement_id: string
          unit_type: string
          supply_area?: number | null
          exclusive_area?: number | null
          supply_count?: number | null
          monthly_rent?: number | null
          deposit?: number | null
          maintenance_fee?: number | null
          floor_info?: string | null
          direction?: string | null
          room_structure?: string | null
          additional_info?: Json | null
          sort_order?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          announcement_id?: string
          unit_type?: string
          supply_area?: number | null
          exclusive_area?: number | null
          supply_count?: number | null
          monthly_rent?: number | null
          deposit?: number | null
          maintenance_fee?: number | null
          floor_info?: string | null
          direction?: string | null
          room_structure?: string | null
          additional_info?: Json | null
          sort_order?: number
          created_at?: string
          updated_at?: string
        }
      }
      announcement_sections: {
        Row: {
          id: string
          announcement_id: string
          section_type: string
          title: string
          content: string
          sort_order: number
          metadata: Json | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          announcement_id: string
          section_type: string
          title: string
          content: string
          sort_order?: number
          metadata?: Json | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          announcement_id?: string
          section_type?: string
          title?: string
          content?: string
          sort_order?: number
          metadata?: Json | null
          created_at?: string
          updated_at?: string
        }
      }
      announcement_comments: {
        Row: {
          id: string
          announcement_id: string
          user_id: string
          parent_comment_id: string | null
          content: string
          is_anonymous: boolean
          likes_count: number
          is_deleted: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          announcement_id: string
          user_id: string
          parent_comment_id?: string | null
          content: string
          is_anonymous?: boolean
          likes_count?: number
          is_deleted?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          announcement_id?: string
          user_id?: string
          parent_comment_id?: string | null
          content?: string
          is_anonymous?: boolean
          likes_count?: number
          is_deleted?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      announcement_ai_chats: {
        Row: {
          id: string
          announcement_id: string
          user_id: string
          session_id: string
          message: string
          response: string
          message_type: string
          metadata: Json | null
          created_at: string
        }
        Insert: {
          id?: string
          announcement_id: string
          user_id: string
          session_id: string
          message: string
          response: string
          message_type?: string
          metadata?: Json | null
          created_at?: string
        }
        Update: {
          id?: string
          announcement_id?: string
          user_id?: string
          session_id?: string
          message?: string
          response?: string
          message_type?: string
          metadata?: Json | null
          created_at?: string
        }
      }
      category_banners: {
        Row: {
          id: string
          category_id: string
          title: string
          subtitle: string | null
          image_url: string
          action_url: string | null
          background_color: string | null
          display_order: number
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          category_id: string
          title: string
          subtitle?: string | null
          image_url: string
          action_url?: string | null
          background_color?: string | null
          display_order?: number
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          category_id?: string
          title?: string | null
          subtitle?: string | null
          image_url?: string
          action_url?: string | null
          background_color?: string | null
          display_order?: number
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
    }
  }
}

export type UserProfile = Database['public']['Tables']['user_profiles']['Row']
export type AgeCategory = Database['public']['Tables']['age_categories']['Row']

// Benefit System Types
export type BenefitCategory = Database['public']['Tables']['benefit_categories']['Row']
export type BenefitCategoryInsert = Database['public']['Tables']['benefit_categories']['Insert']
export type BenefitCategoryUpdate = Database['public']['Tables']['benefit_categories']['Update']

export type BenefitAnnouncement = Database['public']['Tables']['benefit_announcements']['Row']
export type BenefitAnnouncementInsert = Database['public']['Tables']['benefit_announcements']['Insert']
export type BenefitAnnouncementUpdate = Database['public']['Tables']['benefit_announcements']['Update']

export type AnnouncementUnitType = Database['public']['Tables']['announcement_unit_types']['Row']
export type AnnouncementUnitTypeInsert = Database['public']['Tables']['announcement_unit_types']['Insert']
export type AnnouncementUnitTypeUpdate = Database['public']['Tables']['announcement_unit_types']['Update']

export type AnnouncementSection = Database['public']['Tables']['announcement_sections']['Row']
export type AnnouncementSectionInsert = Database['public']['Tables']['announcement_sections']['Insert']
export type AnnouncementSectionUpdate = Database['public']['Tables']['announcement_sections']['Update']

export type AnnouncementComment = Database['public']['Tables']['announcement_comments']['Row']
export type AnnouncementCommentInsert = Database['public']['Tables']['announcement_comments']['Insert']
export type AnnouncementCommentUpdate = Database['public']['Tables']['announcement_comments']['Update']

export type AnnouncementAIChat = Database['public']['Tables']['announcement_ai_chats']['Row']
export type AnnouncementAIChatInsert = Database['public']['Tables']['announcement_ai_chats']['Insert']
export type AnnouncementAIChatUpdate = Database['public']['Tables']['announcement_ai_chats']['Update']

export type BenefitBanner = Database['public']['Tables']['category_banners']['Row']
export type BenefitBannerInsert = Database['public']['Tables']['category_banners']['Insert']
export type BenefitBannerUpdate = Database['public']['Tables']['category_banners']['Update']
