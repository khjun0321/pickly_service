export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      age_categories: {
        Row: {
          created_at: string | null
          description: string
          icon_component: string
          icon_url: string | null
          id: string
          is_active: boolean | null
          max_age: number | null
          min_age: number | null
          sort_order: number | null
          title: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          description: string
          icon_component: string
          icon_url?: string | null
          id?: string
          is_active?: boolean | null
          max_age?: number | null
          min_age?: number | null
          sort_order?: number | null
          title: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          description?: string
          icon_component?: string
          icon_url?: string | null
          id?: string
          is_active?: boolean | null
          max_age?: number | null
          min_age?: number | null
          sort_order?: number | null
          title?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      announcement_sections: {
        Row: {
          announcement_id: string | null
          content: Json
          created_at: string | null
          display_order: number
          id: string
          is_visible: boolean | null
          section_type: string
          title: string | null
          updated_at: string | null
        }
        Insert: {
          announcement_id?: string | null
          content: Json
          created_at?: string | null
          display_order?: number
          id?: string
          is_visible?: boolean | null
          section_type: string
          title?: string | null
          updated_at?: string | null
        }
        Update: {
          announcement_id?: string | null
          content?: Json
          created_at?: string | null
          display_order?: number
          id?: string
          is_visible?: boolean | null
          section_type?: string
          title?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "announcement_sections_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "announcements"
            referencedColumns: ["id"]
          },
        ]
      }
      announcement_tabs: {
        Row: {
          additional_info: Json | null
          age_category_id: string | null
          announcement_id: string | null
          created_at: string | null
          display_order: number
          floor_plan_image_url: string | null
          id: string
          income_conditions: Json | null
          supply_count: number | null
          tab_name: string
          unit_type: string | null
        }
        Insert: {
          additional_info?: Json | null
          age_category_id?: string | null
          announcement_id?: string | null
          created_at?: string | null
          display_order?: number
          floor_plan_image_url?: string | null
          id?: string
          income_conditions?: Json | null
          supply_count?: number | null
          tab_name: string
          unit_type?: string | null
        }
        Update: {
          additional_info?: Json | null
          age_category_id?: string | null
          announcement_id?: string | null
          created_at?: string | null
          display_order?: number
          floor_plan_image_url?: string | null
          id?: string
          income_conditions?: Json | null
          supply_count?: number | null
          tab_name?: string
          unit_type?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "announcement_tabs_age_category_id_fkey"
            columns: ["age_category_id"]
            isOneToOne: false
            referencedRelation: "age_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "announcement_tabs_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "announcements"
            referencedColumns: ["id"]
          },
        ]
      }
      announcements: {
        Row: {
          application_end_date: string | null // ✅ ADDED: Missing from DB types after refactoring
          application_start_date: string | null // ✅ ADDED: Missing from DB types after refactoring
          category_id: string | null
          created_at: string | null
          display_priority: number | null
          external_url: string | null
          id: string
          is_featured: boolean | null
          is_home_visible: boolean | null
          organization: string
          search_vector: unknown | null
          status: string
          subcategory_id: string | null
          subtitle: string | null
          tags: string[] | null
          thumbnail_url: string | null
          title: string
          updated_at: string | null
          views_count: number | null
        }
        Insert: {
          application_end_date?: string | null // ✅ ADDED: Missing from DB types
          application_start_date?: string | null // ✅ ADDED: Missing from DB types
          category_id?: string | null
          created_at?: string | null
          display_priority?: number | null
          external_url?: string | null
          id?: string
          is_featured?: boolean | null
          is_home_visible?: boolean | null
          organization: string
          search_vector?: unknown | null
          status?: string
          subcategory_id?: string | null
          subtitle?: string | null
          tags?: string[] | null
          thumbnail_url?: string | null
          title: string
          updated_at?: string | null
          views_count?: number | null
        }
        Update: {
          application_end_date?: string | null // ✅ ADDED: Missing from DB types
          application_start_date?: string | null // ✅ ADDED: Missing from DB types
          category_id?: string | null
          created_at?: string | null
          display_priority?: number | null
          external_url?: string | null
          id?: string
          is_featured?: boolean | null
          is_home_visible?: boolean | null
          organization?: string
          search_vector?: unknown | null
          status?: string
          subcategory_id?: string | null
          subtitle?: string | null
          tags?: string[] | null
          thumbnail_url?: string | null
          title?: string
          updated_at?: string | null
          views_count?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "announcements_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "benefit_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "announcements_subcategory_id_fkey"
            columns: ["subcategory_id"]
            isOneToOne: false
            referencedRelation: "benefit_subcategories"
            referencedColumns: ["id"]
          },
        ]
      }
      benefit_categories: {
        Row: {
          created_at: string | null
          description: string | null
          display_order: number
          icon_url: string | null
          id: string
          is_active: boolean | null
          name: string
          slug: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          description?: string | null
          display_order?: number
          icon_url?: string | null
          id?: string
          is_active?: boolean | null
          name: string
          slug: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          description?: string | null
          display_order?: number
          icon_url?: string | null
          id?: string
          is_active?: boolean | null
          name?: string
          slug?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      benefit_subcategories: {
        Row: {
          category_id: string | null
          created_at: string | null
          display_order: number
          id: string
          is_active: boolean | null
          name: string
          slug: string
        }
        Insert: {
          category_id?: string | null
          created_at?: string | null
          display_order?: number
          id?: string
          is_active?: boolean | null
          name: string
          slug: string
        }
        Update: {
          category_id?: string | null
          created_at?: string | null
          display_order?: number
          id?: string
          is_active?: boolean | null
          name?: string
          slug?: string
        }
        Relationships: [
          {
            foreignKeyName: "benefit_subcategories_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "benefit_categories"
            referencedColumns: ["id"]
          },
        ]
      }
      category_banners: {
        Row: {
          category_id: string | null
          created_at: string | null
          display_order: number
          end_date: string | null
          id: string
          image_url: string
          is_active: boolean | null
          link_url: string | null
          start_date: string | null
          subtitle: string | null
          title: string
          updated_at: string | null
        }
        Insert: {
          category_id?: string | null
          created_at?: string | null
          display_order?: number
          end_date?: string | null
          id?: string
          image_url: string
          is_active?: boolean | null
          link_url?: string | null
          start_date?: string | null
          subtitle?: string | null
          title: string
          updated_at?: string | null
        }
        Update: {
          category_id?: string | null
          created_at?: string | null
          display_order?: number
          end_date?: string | null
          id?: string
          image_url?: string
          is_active?: boolean | null
          link_url?: string | null
          start_date?: string | null
          subtitle?: string | null
          title?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "category_banners_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "benefit_categories"
            referencedColumns: ["id"]
          },
        ]
      }
      user_profiles: {
        Row: {
          age: number | null
          created_at: string | null
          gender: string | null
          id: string
          income_level: string | null
          interest_policies: string[] | null
          name: string | null
          onboarding_completed: boolean | null
          onboarding_step: number | null
          region_sido: string | null
          region_sigungu: string | null
          selected_categories: string[] | null
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          age?: number | null
          created_at?: string | null
          gender?: string | null
          id?: string
          income_level?: string | null
          interest_policies?: string[] | null
          name?: string | null
          onboarding_completed?: boolean | null
          onboarding_step?: number | null
          region_sido?: string | null
          region_sigungu?: string | null
          selected_categories?: string[] | null
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          age?: number | null
          created_at?: string | null
          gender?: string | null
          id?: string
          income_level?: string | null
          interest_policies?: string[] | null
          name?: string | null
          onboarding_completed?: boolean | null
          onboarding_step?: number | null
          region_sido?: string | null
          region_sigungu?: string | null
          selected_categories?: string[] | null
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {},
  },
} as const


// Type exports for convenience
export type UserProfile = Database['public']['Tables']['user_profiles']['Row']
export type AgeCategory = Database['public']['Tables']['age_categories']['Row']

// Benefit System Types
export type BenefitCategory = Database['public']['Tables']['benefit_categories']['Row']
export type BenefitCategoryInsert = Database['public']['Tables']['benefit_categories']['Insert']
export type BenefitCategoryUpdate = Database['public']['Tables']['benefit_categories']['Update']

export type Announcement = Database['public']['Tables']['announcements']['Row']
export type AnnouncementInsert = Database['public']['Tables']['announcements']['Insert']
export type AnnouncementUpdate = Database['public']['Tables']['announcements']['Update']

export type AnnouncementSection = Database['public']['Tables']['announcement_sections']['Row']
export type AnnouncementSectionInsert = Database['public']['Tables']['announcement_sections']['Insert']
export type AnnouncementSectionUpdate = Database['public']['Tables']['announcement_sections']['Update']

export type AnnouncementTab = Database['public']['Tables']['announcement_tabs']['Row']
export type AnnouncementTabInsert = Database['public']['Tables']['announcement_tabs']['Insert']
export type AnnouncementTabUpdate = Database['public']['Tables']['announcement_tabs']['Update']

export type BenefitBanner = Database['public']['Tables']['category_banners']['Row']
export type BenefitBannerInsert = Database['public']['Tables']['category_banners']['Insert']
export type BenefitBannerUpdate = Database['public']['Tables']['category_banners']['Update']
