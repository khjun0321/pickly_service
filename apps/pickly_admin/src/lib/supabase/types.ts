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
      announcement_ai_chats: {
        Row: {
          announcement_id: string | null
          content: string
          context_data: Json | null
          created_at: string
          id: string
          model_name: string | null
          response_time_ms: number | null
          role: string
          session_id: string
          tokens_used: number | null
          user_id: string
        }
        Insert: {
          announcement_id?: string | null
          content: string
          context_data?: Json | null
          created_at?: string
          id?: string
          model_name?: string | null
          response_time_ms?: number | null
          role: string
          session_id?: string
          tokens_used?: number | null
          user_id: string
        }
        Update: {
          announcement_id?: string | null
          content?: string
          context_data?: Json | null
          created_at?: string
          id?: string
          model_name?: string | null
          response_time_ms?: number | null
          role?: string
          session_id?: string
          tokens_used?: number | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "announcement_ai_chats_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "benefit_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "announcement_ai_chats_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "v_featured_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "announcement_ai_chats_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "v_published_announcements"
            referencedColumns: ["id"]
          },
        ]
      }
      announcement_comments: {
        Row: {
          announcement_id: string
          content: string
          created_at: string
          deleted_at: string | null
          id: string
          is_deleted: boolean
          is_edited: boolean
          is_reported: boolean
          likes_count: number
          moderation_status: string | null
          parent_comment_id: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          announcement_id: string
          content: string
          created_at?: string
          deleted_at?: string | null
          id?: string
          is_deleted?: boolean
          is_edited?: boolean
          is_reported?: boolean
          likes_count?: number
          moderation_status?: string | null
          parent_comment_id?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          announcement_id?: string
          content?: string
          created_at?: string
          deleted_at?: string | null
          id?: string
          is_deleted?: boolean
          is_edited?: boolean
          is_reported?: boolean
          likes_count?: number
          moderation_status?: string | null
          parent_comment_id?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "announcement_comments_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "benefit_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "announcement_comments_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "v_featured_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "announcement_comments_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "v_published_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "announcement_comments_parent_comment_id_fkey"
            columns: ["parent_comment_id"]
            isOneToOne: false
            referencedRelation: "announcement_comments"
            referencedColumns: ["id"]
          },
        ]
      }
      announcement_files: {
        Row: {
          announcement_id: string
          created_at: string
          display_order: number
          file_name: string
          file_size: number | null
          file_type: string | null
          file_url: string
          id: string
        }
        Insert: {
          announcement_id: string
          created_at?: string
          display_order?: number
          file_name: string
          file_size?: number | null
          file_type?: string | null
          file_url: string
          id?: string
        }
        Update: {
          announcement_id?: string
          created_at?: string
          display_order?: number
          file_name?: string
          file_size?: number | null
          file_type?: string | null
          file_url?: string
          id?: string
        }
        Relationships: [
          {
            foreignKeyName: "announcement_files_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "benefit_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "announcement_files_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "v_featured_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "announcement_files_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "v_published_announcements"
            referencedColumns: ["id"]
          },
        ]
      }
      announcement_sections: {
        Row: {
          announcement_id: string
          content: string
          created_at: string
          display_order: number
          id: string
          is_visible: boolean
          section_type: string
          structured_data: Json | null
          title: string
          updated_at: string
        }
        Insert: {
          announcement_id: string
          content: string
          created_at?: string
          display_order?: number
          id?: string
          is_visible?: boolean
          section_type: string
          structured_data?: Json | null
          title: string
          updated_at?: string
        }
        Update: {
          announcement_id?: string
          content?: string
          created_at?: string
          display_order?: number
          id?: string
          is_visible?: boolean
          section_type?: string
          structured_data?: Json | null
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "announcement_sections_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "benefit_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "announcement_sections_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "v_featured_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "announcement_sections_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "v_published_announcements"
            referencedColumns: ["id"]
          },
        ]
      }
      announcement_types: {
        Row: {
          benefit_category_id: string
          created_at: string
          description: string | null
          id: string
          is_active: boolean
          sort_order: number
          title: string
          updated_at: string
        }
        Insert: {
          benefit_category_id: string
          created_at?: string
          description?: string | null
          id?: string
          is_active?: boolean
          sort_order?: number
          title: string
          updated_at?: string
        }
        Update: {
          benefit_category_id?: string
          created_at?: string
          description?: string | null
          id?: string
          is_active?: boolean
          sort_order?: number
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "announcement_types_benefit_category_id_fkey"
            columns: ["benefit_category_id"]
            isOneToOne: false
            referencedRelation: "benefit_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "announcement_types_benefit_category_id_fkey"
            columns: ["benefit_category_id"]
            isOneToOne: false
            referencedRelation: "v_announcements_full"
            referencedColumns: ["category_id"]
          },
        ]
      }
      announcement_unit_types: {
        Row: {
          announcement_id: string
          created_at: string
          deposit_amount: number | null
          display_order: number
          exclusive_area: number | null
          id: string
          monthly_rent: number | null
          room_layout: string | null
          sale_price: number | null
          special_conditions: string | null
          supply_area: number | null
          unit_count: number | null
          unit_type: string
          updated_at: string
        }
        Insert: {
          announcement_id: string
          created_at?: string
          deposit_amount?: number | null
          display_order?: number
          exclusive_area?: number | null
          id?: string
          monthly_rent?: number | null
          room_layout?: string | null
          sale_price?: number | null
          special_conditions?: string | null
          supply_area?: number | null
          unit_count?: number | null
          unit_type: string
          updated_at?: string
        }
        Update: {
          announcement_id?: string
          created_at?: string
          deposit_amount?: number | null
          display_order?: number
          exclusive_area?: number | null
          id?: string
          monthly_rent?: number | null
          room_layout?: string | null
          sale_price?: number | null
          special_conditions?: string | null
          supply_area?: number | null
          unit_count?: number | null
          unit_type?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "announcement_unit_types_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "benefit_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "announcement_unit_types_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "v_featured_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "announcement_unit_types_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "v_published_announcements"
            referencedColumns: ["id"]
          },
        ]
      }
      announcements: {
        Row: {
          created_at: string
          detail_url: string | null
          id: string
          is_priority: boolean
          organization: string
          posted_date: string | null
          region: string | null
          status: string
          thumbnail_url: string | null
          title: string
          type_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          detail_url?: string | null
          id?: string
          is_priority?: boolean
          organization: string
          posted_date?: string | null
          region?: string | null
          status?: string
          thumbnail_url?: string | null
          title: string
          type_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          detail_url?: string | null
          id?: string
          is_priority?: boolean
          organization?: string
          posted_date?: string | null
          region?: string | null
          status?: string
          thumbnail_url?: string | null
          title?: string
          type_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "announcements_type_id_fkey"
            columns: ["type_id"]
            isOneToOne: false
            referencedRelation: "announcement_types"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "announcements_type_id_fkey"
            columns: ["type_id"]
            isOneToOne: false
            referencedRelation: "v_announcements_full"
            referencedColumns: ["type_id"]
          },
        ]
      }
      benefit_announcements: {
        Row: {
          announcement_date: string | null
          application_period_end: string | null
          application_period_start: string | null
          category_id: string
          content: string | null
          created_at: string
          custom_data: Json | null
          display_order: number
          external_url: string | null
          id: string
          is_featured: boolean
          organization: string
          published_at: string | null
          search_vector: unknown | null
          status: string
          subtitle: string | null
          summary: string | null
          tags: string[] | null
          thumbnail_url: string | null
          title: string
          updated_at: string
          views_count: number
        }
        Insert: {
          announcement_date?: string | null
          application_period_end?: string | null
          application_period_start?: string | null
          category_id: string
          content?: string | null
          created_at?: string
          custom_data?: Json | null
          display_order?: number
          external_url?: string | null
          id?: string
          is_featured?: boolean
          organization: string
          published_at?: string | null
          search_vector?: unknown | null
          status?: string
          subtitle?: string | null
          summary?: string | null
          tags?: string[] | null
          thumbnail_url?: string | null
          title: string
          updated_at?: string
          views_count?: number
        }
        Update: {
          announcement_date?: string | null
          application_period_end?: string | null
          application_period_start?: string | null
          category_id?: string
          content?: string | null
          created_at?: string
          custom_data?: Json | null
          display_order?: number
          external_url?: string | null
          id?: string
          is_featured?: boolean
          organization?: string
          published_at?: string | null
          search_vector?: unknown | null
          status?: string
          subtitle?: string | null
          summary?: string | null
          tags?: string[] | null
          thumbnail_url?: string | null
          title?: string
          updated_at?: string
          views_count?: number
        }
        Relationships: [
          {
            foreignKeyName: "benefit_announcements_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "benefit_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "benefit_announcements_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "v_announcements_full"
            referencedColumns: ["category_id"]
          },
        ]
      }
      benefit_categories: {
        Row: {
          created_at: string
          custom_fields: Json | null
          description: string | null
          icon_url: string | null
          id: string
          is_active: boolean
          parent_id: string | null
          slug: string
          sort_order: number
          title: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          custom_fields?: Json | null
          description?: string | null
          icon_url?: string | null
          id?: string
          is_active?: boolean
          parent_id?: string | null
          slug: string
          sort_order?: number
          title: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          custom_fields?: Json | null
          description?: string | null
          icon_url?: string | null
          id?: string
          is_active?: boolean
          parent_id?: string | null
          slug?: string
          sort_order?: number
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "benefit_categories_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "benefit_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "benefit_categories_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "v_announcements_full"
            referencedColumns: ["category_id"]
          },
        ]
      }
      benefit_files: {
        Row: {
          announcement_id: string | null
          file_name: string
          file_size: number | null
          file_type: string
          id: string
          metadata: Json | null
          mime_type: string | null
          public_url: string | null
          storage_path: string
          uploaded_at: string | null
          uploaded_by: string | null
        }
        Insert: {
          announcement_id?: string | null
          file_name: string
          file_size?: number | null
          file_type: string
          id?: string
          metadata?: Json | null
          mime_type?: string | null
          public_url?: string | null
          storage_path: string
          uploaded_at?: string | null
          uploaded_by?: string | null
        }
        Update: {
          announcement_id?: string | null
          file_name?: string
          file_size?: number | null
          file_type?: string
          id?: string
          metadata?: Json | null
          mime_type?: string | null
          public_url?: string | null
          storage_path?: string
          uploaded_at?: string | null
          uploaded_by?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "benefit_files_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "benefit_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "benefit_files_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "v_featured_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "benefit_files_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "v_published_announcements"
            referencedColumns: ["id"]
          },
        ]
      }
      category_banners: {
        Row: {
          background_color: string | null
          benefit_category_id: string
          created_at: string
          id: string
          image_url: string
          is_active: boolean
          link_target: string | null
          link_type: string | null
          sort_order: number
          subtitle: string | null
          title: string
          updated_at: string
        }
        Insert: {
          background_color?: string | null
          benefit_category_id: string
          created_at?: string
          id?: string
          image_url: string
          is_active?: boolean
          link_target?: string | null
          link_type?: string | null
          sort_order?: number
          subtitle?: string | null
          title: string
          updated_at?: string
        }
        Update: {
          background_color?: string | null
          benefit_category_id?: string
          created_at?: string
          id?: string
          image_url?: string
          is_active?: boolean
          link_target?: string | null
          link_type?: string | null
          sort_order?: number
          subtitle?: string | null
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "category_banners_category_id_fkey"
            columns: ["benefit_category_id"]
            isOneToOne: false
            referencedRelation: "benefit_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "category_banners_category_id_fkey"
            columns: ["benefit_category_id"]
            isOneToOne: false
            referencedRelation: "v_announcements_full"
            referencedColumns: ["category_id"]
          },
        ]
      }
      display_order_history: {
        Row: {
          announcement_id: string
          category_id: string
          changed_at: string
          changed_by: string | null
          id: string
          new_order: number
          old_order: number
        }
        Insert: {
          announcement_id: string
          category_id: string
          changed_at?: string
          changed_by?: string | null
          id?: string
          new_order: number
          old_order: number
        }
        Update: {
          announcement_id?: string
          category_id?: string
          changed_at?: string
          changed_by?: string | null
          id?: string
          new_order?: number
          old_order?: number
        }
        Relationships: [
          {
            foreignKeyName: "display_order_history_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "benefit_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "display_order_history_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "v_featured_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "display_order_history_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "v_published_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "display_order_history_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "benefit_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "display_order_history_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "v_announcements_full"
            referencedColumns: ["category_id"]
          },
        ]
      }
      housing_announcements: {
        Row: {
          category: string
          created_at: string | null
          display_config: Json
          housing_types: Json
          id: string
          raw_data: Json
          source: string
          source_id: string
          status: string | null
          subtitle: string | null
          title: string
          updated_at: string | null
        }
        Insert: {
          category: string
          created_at?: string | null
          display_config?: Json
          housing_types?: Json
          id?: string
          raw_data?: Json
          source: string
          source_id: string
          status?: string | null
          subtitle?: string | null
          title: string
          updated_at?: string | null
        }
        Update: {
          category?: string
          created_at?: string | null
          display_config?: Json
          housing_types?: Json
          id?: string
          raw_data?: Json
          source?: string
          source_id?: string
          status?: string | null
          subtitle?: string | null
          title?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      storage_folders: {
        Row: {
          bucket_id: string
          created_at: string | null
          description: string | null
          id: string
          path: string
        }
        Insert: {
          bucket_id?: string
          created_at?: string | null
          description?: string | null
          id?: string
          path: string
        }
        Update: {
          bucket_id?: string
          created_at?: string | null
          description?: string | null
          id?: string
          path?: string
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
    }
    Views: {
      v_announcement_files: {
        Row: {
          announcement_id: string | null
          announcement_title: string | null
          file_name: string | null
          file_size: number | null
          file_type: string | null
          id: string | null
          metadata: Json | null
          mime_type: string | null
          organization: string | null
          public_url: string | null
          storage_path: string | null
          uploaded_at: string | null
        }
        Relationships: [
          {
            foreignKeyName: "benefit_files_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "benefit_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "benefit_files_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "v_featured_announcements"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "benefit_files_announcement_id_fkey"
            columns: ["announcement_id"]
            isOneToOne: false
            referencedRelation: "v_published_announcements"
            referencedColumns: ["id"]
          },
        ]
      }
      v_announcement_stats: {
        Row: {
          category_name: string | null
          category_slug: string | null
          featured_count: number | null
          published_count: number | null
          total_announcements: number | null
          total_views: number | null
        }
        Relationships: []
      }
      v_announcements_full: {
        Row: {
          category_id: string | null
          category_title: string | null
          created_at: string | null
          detail_url: string | null
          id: string | null
          is_priority: boolean | null
          organization: string | null
          posted_date: string | null
          region: string | null
          status: string | null
          thumbnail_url: string | null
          title: string | null
          type_id: string | null
          type_title: string | null
          updated_at: string | null
        }
        Relationships: []
      }
      v_featured_announcements: {
        Row: {
          announcement_date: string | null
          application_period_end: string | null
          application_period_start: string | null
          application_status: string | null
          category_id: string | null
          category_name: string | null
          category_slug: string | null
          created_at: string | null
          external_url: string | null
          id: string | null
          is_featured: boolean | null
          organization: string | null
          published_at: string | null
          search_vector: unknown | null
          status: string | null
          subtitle: string | null
          summary: string | null
          tags: string[] | null
          thumbnail_url: string | null
          title: string | null
          updated_at: string | null
          views_count: number | null
        }
        Relationships: [
          {
            foreignKeyName: "benefit_announcements_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "benefit_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "benefit_announcements_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "v_announcements_full"
            referencedColumns: ["category_id"]
          },
        ]
      }
      v_published_announcements: {
        Row: {
          announcement_date: string | null
          application_period_end: string | null
          application_period_start: string | null
          application_status: string | null
          category_id: string | null
          category_name: string | null
          category_slug: string | null
          created_at: string | null
          external_url: string | null
          id: string | null
          is_featured: boolean | null
          organization: string | null
          published_at: string | null
          search_vector: unknown | null
          status: string | null
          subtitle: string | null
          summary: string | null
          tags: string[] | null
          thumbnail_url: string | null
          title: string | null
          updated_at: string | null
          views_count: number | null
        }
        Relationships: [
          {
            foreignKeyName: "benefit_announcements_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "benefit_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "benefit_announcements_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "v_announcements_full"
            referencedColumns: ["category_id"]
          },
        ]
      }
      v_storage_stats: {
        Row: {
          avg_file_size_bytes: number | null
          file_count: number | null
          file_type: string | null
          total_size_bytes: number | null
          total_size_mb: number | null
        }
        Relationships: []
      }
    }
    Functions: {
      generate_announcement_file_path: {
        Args: {
          p_announcement_id: string
          p_file_name: string
          p_file_type: string
        }
        Returns: string
      }
      generate_banner_path: {
        Args: { p_category: string; p_file_name: string }
        Returns: string
      }
      get_storage_public_url: {
        Args: { p_bucket_id: string; p_path: string }
        Returns: string
      }
      gtrgm_compress: {
        Args: { "": unknown }
        Returns: unknown
      }
      gtrgm_decompress: {
        Args: { "": unknown }
        Returns: unknown
      }
      gtrgm_in: {
        Args: { "": unknown }
        Returns: unknown
      }
      gtrgm_options: {
        Args: { "": unknown }
        Returns: undefined
      }
      gtrgm_out: {
        Args: { "": unknown }
        Returns: unknown
      }
      set_limit: {
        Args: { "": number }
        Returns: number
      }
      show_limit: {
        Args: Record<PropertyKey, never>
        Returns: number
      }
      show_trgm: {
        Args: { "": string }
        Returns: string[]
      }
      update_display_orders: {
        Args: { p_announcement_ids: string[]; p_category_id: string }
        Returns: undefined
      }
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

