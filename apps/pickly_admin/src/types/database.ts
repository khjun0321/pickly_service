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
      announcement_types: {
        Row: {
          benefit_category_id: string
          created_at: string | null
          description: string | null
          id: string
          is_active: boolean | null
          sort_order: number | null
          title: string
          updated_at: string | null
        }
        Insert: {
          benefit_category_id: string
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          sort_order?: number | null
          title: string
          updated_at?: string | null
        }
        Update: {
          benefit_category_id?: string
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          sort_order?: number | null
          title?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "announcement_types_benefit_category_id_fkey"
            columns: ["benefit_category_id"]
            isOneToOne: false
            referencedRelation: "benefit_categories"
            referencedColumns: ["id"]
          },
        ]
      }
      announcement_unit_types: {
        Row: {
          additional_info: Json | null
          announcement_id: string
          created_at: string | null
          deposit: number | null
          direction: string | null
          exclusive_area: number | null
          floor_info: string | null
          id: string
          maintenance_fee: number | null
          monthly_rent: number | null
          room_structure: string | null
          sort_order: number | null
          supply_area: number | null
          supply_count: number | null
          unit_type: string
          updated_at: string | null
        }
        Insert: {
          additional_info?: Json | null
          announcement_id: string
          created_at?: string | null
          deposit?: number | null
          direction?: string | null
          exclusive_area?: number | null
          floor_info?: string | null
          id?: string
          maintenance_fee?: number | null
          monthly_rent?: number | null
          room_structure?: string | null
          sort_order?: number | null
          supply_area?: number | null
          supply_count?: number | null
          unit_type: string
          updated_at?: string | null
        }
        Update: {
          additional_info?: Json | null
          announcement_id?: string
          created_at?: string | null
          deposit?: number | null
          direction?: string | null
          exclusive_area?: number | null
          floor_info?: string | null
          id?: string
          maintenance_fee?: number | null
          monthly_rent?: number | null
          room_structure?: string | null
          sort_order?: number | null
          supply_area?: number | null
          supply_count?: number | null
          unit_type?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "announcement_unit_types_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "announcements"
            referencedColumns: ["id"]
          },
        ]
      }
      announcements: {
        Row: {
          application_end_date: string | null
          application_start_date: string | null
          category_id: string | null
          content: string | null
          created_at: string | null
          deadline_date: string | null
          detail_url: string | null
          display_priority: number | null
          external_url: string | null
          id: string
          is_featured: boolean | null
          is_home_visible: boolean | null
          is_priority: boolean
          link_type: string | null
          organization: string
          region: string | null
          search_vector: unknown
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
          application_end_date?: string | null
          application_start_date?: string | null
          category_id?: string | null
          content?: string | null
          created_at?: string | null
          deadline_date?: string | null
          detail_url?: string | null
          display_priority?: number | null
          external_url?: string | null
          id?: string
          is_featured?: boolean | null
          is_home_visible?: boolean | null
          is_priority?: boolean
          link_type?: string | null
          organization: string
          region?: string | null
          search_vector?: unknown
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
          application_end_date?: string | null
          application_start_date?: string | null
          category_id?: string | null
          content?: string | null
          created_at?: string | null
          deadline_date?: string | null
          detail_url?: string | null
          display_priority?: number | null
          external_url?: string | null
          id?: string
          is_featured?: boolean | null
          is_home_visible?: boolean | null
          is_priority?: boolean
          link_type?: string | null
          organization?: string
          region?: string | null
          search_vector?: unknown
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
      api_collection_logs: {
        Row: {
          api_source_id: string
          completed_at: string | null
          created_at: string | null
          error_message: string | null
          error_summary: Json | null
          id: string
          records_failed: number | null
          records_fetched: number | null
          records_processed: number | null
          started_at: string
          status: string
        }
        Insert: {
          api_source_id: string
          completed_at?: string | null
          created_at?: string | null
          error_message?: string | null
          error_summary?: Json | null
          id?: string
          records_failed?: number | null
          records_fetched?: number | null
          records_processed?: number | null
          started_at?: string
          status: string
        }
        Update: {
          api_source_id?: string
          completed_at?: string | null
          created_at?: string | null
          error_message?: string | null
          error_summary?: Json | null
          id?: string
          records_failed?: number | null
          records_fetched?: number | null
          records_processed?: number | null
          started_at?: string
          status?: string
        }
        Relationships: [
          {
            foreignKeyName: "api_collection_logs_api_source_id_fkey"
            columns: ["api_source_id"]
            isOneToOne: false
            referencedRelation: "api_sources"
            referencedColumns: ["id"]
          },
        ]
      }
      api_sources: {
        Row: {
          auth_key: string | null
          auth_type: string | null
          collection_schedule: string | null
          created_at: string | null
          description: string | null
          endpoint_url: string
          id: string
          is_active: boolean | null
          last_collected_at: string | null
          mapping_config: Json | null
          name: string
          updated_at: string | null
        }
        Insert: {
          auth_key?: string | null
          auth_type?: string | null
          collection_schedule?: string | null
          created_at?: string | null
          description?: string | null
          endpoint_url: string
          id?: string
          is_active?: boolean | null
          last_collected_at?: string | null
          mapping_config?: Json | null
          name: string
          updated_at?: string | null
        }
        Update: {
          auth_key?: string | null
          auth_type?: string | null
          collection_schedule?: string | null
          created_at?: string | null
          description?: string | null
          endpoint_url?: string
          id?: string
          is_active?: boolean | null
          last_collected_at?: string | null
          mapping_config?: Json | null
          name?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      benefit_categories: {
        Row: {
          created_at: string | null
          description: string | null
          icon_name: string | null
          icon_url: string | null
          id: string
          is_active: boolean | null
          slug: string
          sort_order: number
          title: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          description?: string | null
          icon_name?: string | null
          icon_url?: string | null
          id?: string
          is_active?: boolean | null
          slug: string
          sort_order?: number
          title: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          description?: string | null
          icon_name?: string | null
          icon_url?: string | null
          id?: string
          is_active?: boolean | null
          slug?: string
          sort_order?: number
          title?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      benefit_subcategories: {
        Row: {
          category_id: string | null
          created_at: string | null
          icon_name: string | null
          icon_url: string | null
          id: string
          is_active: boolean | null
          name: string
          slug: string
          sort_order: number
        }
        Insert: {
          category_id?: string | null
          created_at?: string | null
          icon_name?: string | null
          icon_url?: string | null
          id?: string
          is_active?: boolean | null
          name: string
          slug: string
          sort_order?: number
        }
        Update: {
          category_id?: string | null
          created_at?: string | null
          icon_name?: string | null
          icon_url?: string | null
          id?: string
          is_active?: boolean | null
          name?: string
          slug?: string
          sort_order?: number
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
          background_color: string | null
          category_id: string | null
          category_slug: string
          created_at: string | null
          id: string
          image_url: string
          is_active: boolean | null
          link_type: string | null
          link_url: string | null
          sort_order: number
          subtitle: string | null
          title: string
          updated_at: string | null
        }
        Insert: {
          background_color?: string | null
          category_id?: string | null
          category_slug: string
          created_at?: string | null
          id?: string
          image_url: string
          is_active?: boolean | null
          link_type?: string | null
          link_url?: string | null
          sort_order?: number
          subtitle?: string | null
          title: string
          updated_at?: string | null
        }
        Update: {
          background_color?: string | null
          category_id?: string | null
          category_slug?: string
          created_at?: string | null
          id?: string
          image_url?: string
          is_active?: boolean | null
          link_type?: string | null
          link_url?: string | null
          sort_order?: number
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
      featured_contents: {
        Row: {
          created_at: string | null
          id: string
          image_url: string
          is_active: boolean | null
          link_type: string | null
          link_url: string | null
          section_id: string
          sort_order: number
          subtitle: string | null
          title: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          id?: string
          image_url: string
          is_active?: boolean | null
          link_type?: string | null
          link_url?: string | null
          section_id: string
          sort_order?: number
          subtitle?: string | null
          title: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          id?: string
          image_url?: string
          is_active?: boolean | null
          link_type?: string | null
          link_url?: string | null
          section_id?: string
          sort_order?: number
          subtitle?: string | null
          title?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "featured_contents_section_id_fkey"
            columns: ["section_id"]
            isOneToOne: false
            referencedRelation: "home_sections"
            referencedColumns: ["id"]
          },
        ]
      }
      home_sections: {
        Row: {
          created_at: string | null
          description: string | null
          id: string
          is_active: boolean | null
          section_type: string
          sort_order: number
          title: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          section_type: string
          sort_order?: number
          title: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          section_type?: string
          sort_order?: number
          title?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      raw_announcements: {
        Row: {
          api_source_id: string
          collected_at: string
          collection_log_id: string | null
          created_at: string
          error_log: string | null
          id: string
          is_active: boolean
          processed_at: string | null
          raw_payload: Json
          status: string
          updated_at: string
        }
        Insert: {
          api_source_id: string
          collected_at?: string
          collection_log_id?: string | null
          created_at?: string
          error_log?: string | null
          id?: string
          is_active?: boolean
          processed_at?: string | null
          raw_payload: Json
          status?: string
          updated_at?: string
        }
        Update: {
          api_source_id?: string
          collected_at?: string
          collection_log_id?: string | null
          created_at?: string
          error_log?: string | null
          id?: string
          is_active?: boolean
          processed_at?: string | null
          raw_payload?: Json
          status?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "raw_announcements_api_source_id_fkey"
            columns: ["api_source_id"]
            isOneToOne: false
            referencedRelation: "api_sources"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "raw_announcements_collection_log_id_fkey"
            columns: ["collection_log_id"]
            isOneToOne: false
            referencedRelation: "api_collection_logs"
            referencedColumns: ["id"]
          },
        ]
      }
      regions: {
        Row: {
          code: string
          created_at: string
          id: string
          is_active: boolean
          name: string
          sort_order: number
          updated_at: string
        }
        Insert: {
          code: string
          created_at?: string
          id?: string
          is_active?: boolean
          name: string
          sort_order?: number
          updated_at?: string
        }
        Update: {
          code?: string
          created_at?: string
          id?: string
          is_active?: boolean
          name?: string
          sort_order?: number
          updated_at?: string
        }
        Relationships: []
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
      user_regions: {
        Row: {
          created_at: string
          id: string
          region_id: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          region_id: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          region_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_regions_region_id_fkey"
            columns: ["region_id"]
            isOneToOne: false
            referencedRelation: "regions"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      custom_access: { Args: { email: string }; Returns: boolean }
      is_admin: { Args: never; Returns: boolean }
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

// =============================
// ✅ 타입 export 보강
// =============================
export type BenefitCategory = Database['public']['Tables']['benefit_categories']['Row'];
export type Announcement = Database['public']['Tables']['announcements']['Row'];
export type CategoryBannerDB = Database['public']['Tables']['category_banners']['Row'];

