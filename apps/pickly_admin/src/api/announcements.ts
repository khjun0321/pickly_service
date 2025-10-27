import { supabase } from '@/lib/supabase'
import type {
  Announcement,
  AnnouncementInsert,
  AnnouncementUpdate
} from '@/types/database'

export interface AnnouncementFilters {
  category_id?: string
  status?: string
  is_active?: boolean
  is_featured?: boolean
  search?: string
}

/**
 * Fetch all announcements with optional filters
 * @param filters - Optional filters for announcements
 * @returns Array of announcements ordered by created_at (newest first)
 */
export async function fetchAnnouncements(filters?: AnnouncementFilters) {
  console.log('📦 Fetching announcements with filters:', filters)

  let query = supabase
    .from('announcements')
    .select('*')

  // Apply filters
  if (filters) {
    if (filters.category_id) {
      query = query.eq('category_id', filters.category_id)
    }
    if (filters.status) {
      query = query.eq('status', filters.status)
    }
    if (filters.is_active !== undefined) {
      query = query.eq('is_active', filters.is_active)
    }
    if (filters.is_featured !== undefined) {
      query = query.eq('is_featured', filters.is_featured)
    }
    if (filters.search) {
      query = query.or(`title.ilike.%${filters.search}%,description.ilike.%${filters.search}%`)
    }
  }

  const { data, error } = await query.order('created_at', { ascending: false })

  if (error) {
    console.error('❌ Error fetching announcements:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  console.log('✅ Fetched announcements:', data?.length)
  return data as Announcement[]
}

/**
 * Fetch a single announcement by ID with all related data
 * @param id - Announcement ID
 * @returns Single announcement with related unit types, sections, and category
 */
export async function fetchAnnouncementById(id: string) {
  console.log('📦 Fetching announcement by ID:', id)

  const { data, error } = await supabase
    .from('announcements')
    .select(`
      *,
      benefit_categories (
        id,
        name,
        description,
        icon,
        color
      ),
      announcement_unit_types (
        id,
        unit_type,
        supply_area,
        exclusive_area,
        supply_count,
        monthly_rent,
        deposit,
        maintenance_fee,
        floor_info,
        direction,
        room_structure,
        additional_info,
        sort_order
      ),
      announcement_sections (
        id,
        section_type,
        title,
        content,
        sort_order,
        metadata
      )
    `)
    .eq('id', id)
    .single()

  if (error) {
    console.error('❌ Error fetching announcement:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  console.log('✅ Fetched announcement:', data?.title)
  return data
}

/**
 * Create a new announcement
 * @param announcement - Announcement data to create
 * @returns Created announcement
 */
export async function createAnnouncement(announcement: AnnouncementInsert) {
  console.log('🔨 Creating announcement:', announcement.title)

  const { data, error } = await supabase
    .from('announcements')
    // @ts-expect-error - Supabase type inference issue
    .insert(announcement)
    .select()
    .single()

  if (error) {
    console.error('❌ Error creating announcement:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  console.log('✅ Created announcement:', data?.id)
  return data as Announcement
}

/**
 * Update an existing announcement
 * @param id - Announcement ID
 * @param announcement - Partial announcement data to update
 * @returns Updated announcement
 */
export async function updateAnnouncement(id: string, announcement: AnnouncementUpdate) {
  console.log('🔄 Updating announcement:', id, announcement)

  const { data, error } = await supabase
    .from('announcements')
    // @ts-expect-error - Supabase type inference issue
    .update(announcement)
    .eq('id', id)
    .select()
    .single()

  console.log('📊 Update result:', { data, error })

  if (error) {
    console.error('❌ Update error:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  console.log('✅ Updated announcement:', data?.id)
  return data as Announcement
}

/**
 * Delete an announcement
 * @param id - Announcement ID
 */
export async function deleteAnnouncement(id: string) {
  console.log('🗑️ Deleting announcement:', id)

  const { error } = await supabase
    .from('announcements')
    .delete()
    .eq('id', id)

  if (error) {
    console.error('❌ Error deleting announcement:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  console.log('✅ Deleted announcement:', id)
}

/**
 * Fetch announcements by category ID
 * @param categoryId - Benefit category ID
 * @returns Array of announcements for the specified category
 */
export async function fetchAnnouncementsByCategory(categoryId: string) {
  console.log('📦 Fetching announcements for category:', categoryId)

  const { data, error } = await supabase
    .from('announcements')
    .select('*')
    .eq('category_id', categoryId)
    .eq('is_active', true)
    .order('created_at', { ascending: false })

  if (error) {
    console.error('❌ Error fetching announcements by category:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  console.log('✅ Fetched announcements for category:', data?.length)
  return data as Announcement[]
}

/**
 * Increment view count for an announcement
 * @param id - Announcement ID
 */
export async function incrementAnnouncementViewCount(id: string) {
  console.log('👁️ Incrementing view count for announcement:', id)

  const { error } = await supabase.rpc('increment_announcement_view_count', {
    announcement_id: id
  })

  if (error) {
    console.error('❌ Error incrementing view count:', error)
    // Don't throw error for analytics - just log it
  } else {
    console.log('✅ Incremented view count for announcement:', id)
  }
}

/**
 * Fetch LH announcements from external API and save to database
 * @returns Result of the fetch operation
 */
export async function fetchLHAnnouncements() {
  console.log('🏠 Fetching LH announcements from Edge Function...')

  try {
    const { data, error } = await supabase.functions.invoke('fetch-lh-announcements', {
      method: 'POST',
    })

    if (error) {
      console.error('❌ Error calling Edge Function:', error)
      throw new Error(error.message || 'Edge Function 호출에 실패했습니다.')
    }

    console.log('✅ LH announcements fetched successfully:', data)
    return data
  } catch (error) {
    console.error('❌ Error in fetchLHAnnouncements:', error)
    throw error
  }
}

/**
 * Fetch LH-style announcements from the new announcements table
 * @returns Array of LH announcements
 */
export async function fetchLHStyleAnnouncements() {
  console.log('📦 Fetching LH-style announcements from announcements table')

  const { data, error } = await supabase
    .from('announcements')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    console.error('❌ Error fetching LH announcements:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  console.log('✅ Fetched LH announcements:', data?.length)
  return data
}

/**
 * Fetch combined announcements from both tables
 * @returns Array of all announcements
 */
export async function fetchAllAnnouncements() {
  console.log('📦 Fetching all announcements from both tables')

  try {
    // Fetch from both tables in parallel
    const [benefitData, lhData] = await Promise.all([
      supabase.from('announcements').select('*').order('created_at', { ascending: false }),
      supabase.from('announcements').select('*').order('created_at', { ascending: false })
    ])

    const announcements: any[] = []

    // Add benefit announcements
    if (benefitData.data) {
      announcements.push(...benefitData.data.map((a: any) => ({ ...a, source: 'benefit' })))
    }

    // Add LH announcements
    if (lhData.data) {
      announcements.push(...lhData.data.map((a: any) => ({
        id: a.id,
        title: a.title,
        subtitle: a.subtitle,
        category_id: null,
        organization: a.source,
        status: a.status === 'active' ? 'recruiting' : 'draft',
        application_start_date: null,
        application_end_date: null,
        view_count: 0,
        created_at: a.created_at,
        source: 'lh'
      })))
    }

    // Sort by created_at
    announcements.sort((a, b) =>
      new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
    )

    console.log('✅ Fetched combined announcements:', announcements.length)
    return announcements
  } catch (error) {
    console.error('❌ Error fetching combined announcements:', error)
    throw error
  }
}
