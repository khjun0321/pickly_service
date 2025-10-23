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
    }
  }
}

export type UserProfile = Database['public']['Tables']['user_profiles']['Row']
export type AgeCategory = Database['public']['Tables']['age_categories']['Row']
