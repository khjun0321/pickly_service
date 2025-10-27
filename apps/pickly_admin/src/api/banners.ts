import { supabase } from '@/lib/supabase'

export interface BenefitBanner {
  id: string
  category_id: string
  title: string
  subtitle: string | null
  image_url: string
  link_url: string | null
  // background_color: string | null // ❌ REMOVED: Not in DB schema (category_banners table)
  display_order: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface BenefitBannerInsert {
  category_id: string
  title: string
  subtitle?: string | null
  image_url: string
  link_url?: string | null
  // background_color?: string | null // ❌ REMOVED: Not in DB schema
  display_order?: number
  is_active?: boolean
}

export interface BenefitBannerUpdate {
  title?: string
  subtitle?: string | null
  image_url?: string
  link_url?: string | null
  // background_color?: string | null // ❌ REMOVED: Not in DB schema
  display_order?: number
  is_active?: boolean
}

/**
 * Fetch all banners for a specific category
 */
export async function fetchBannersByCategory(categoryId: string): Promise<BenefitBanner[]> {
  console.log('📦 Fetching banners for category:', categoryId)

  const { data, error } = await supabase
    .from('category_banners')
    .select('*')
    .eq('category_id', categoryId)
    .order('display_order', { ascending: true })

  if (error) {
    console.error('❌ Error fetching banners:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  console.log('✅ Fetched banners:', data?.length)
  return data as BenefitBanner[]
}

/**
 * Fetch all banners (all categories)
 */
export async function fetchAllBanners(): Promise<BenefitBanner[]> {
  console.log('📦 Fetching all banners')

  const { data, error } = await supabase
    .from('category_banners')
    .select(`
      *,
      benefit_categories (
        id,
        name,
        slug
      )
    `)
    .order('display_order', { ascending: true })

  if (error) {
    console.error('❌ Error fetching all banners:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  console.log('✅ Fetched all banners:', data?.length)
  return data as BenefitBanner[]
}

/**
 * Fetch a single banner by ID
 */
export async function fetchBannerById(id: string): Promise<BenefitBanner> {
  console.log('📦 Fetching banner by ID:', id)

  const { data, error } = await supabase
    .from('category_banners')
    .select('*')
    .eq('id', id)
    .single()

  if (error) {
    console.error('❌ Error fetching banner:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  console.log('✅ Fetched banner:', data?.title)
  return data as BenefitBanner
}

/**
 * Create a new banner
 */
export async function createBanner(banner: BenefitBannerInsert): Promise<BenefitBanner> {
  console.log('🔨 Creating banner:', banner.title)

  const { data, error } = await supabase
    .from('category_banners')
    .insert(banner)
    .select()
    .single()

  if (error) {
    console.error('❌ Error creating banner:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  console.log('✅ Created banner:', data?.id)
  return data as BenefitBanner
}

/**
 * Update an existing banner
 */
export async function updateBanner(id: string, banner: BenefitBannerUpdate): Promise<BenefitBanner> {
  console.log('🔄 Updating banner:', id, banner)

  const { data, error} = await supabase
    .from('category_banners')
    .update(banner)
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

  console.log('✅ Updated banner:', data?.id)
  return data as BenefitBanner
}

/**
 * Delete a banner
 */
export async function deleteBanner(id: string): Promise<void> {
  console.log('🗑️ Deleting banner:', id)

  const { error } = await supabase
    .from('category_banners')
    .delete()
    .eq('id', id)

  if (error) {
    console.error('❌ Error deleting banner:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  console.log('✅ Deleted banner:', id)
}

/**
 * Reorder banners by updating display_order
 */
export async function reorderBanners(
  banners: { id: string; display_order: number }[]
): Promise<void> {
  console.log('🔄 Reordering banners:', banners)

  const updates = banners.map(({ id, display_order }) =>
    supabase
      .from('category_banners')
      .update({ display_order })
      .eq('id', id)
  )

  const results = await Promise.all(updates)
  const errors = results.filter((r) => r.error)

  if (errors.length > 0) {
    console.error('❌ Error reordering banners:', errors)
    throw new Error('배너 순서 변경에 실패했습니다.')
  }

  console.log('✅ Reordered banners successfully')
}

/**
 * Toggle banner active status
 */
export async function toggleBannerStatus(id: string, isActive: boolean): Promise<void> {
  console.log('🔄 Toggling banner status:', id, isActive)

  const { error } = await supabase
    .from('category_banners')
    .update({ is_active: isActive })
    .eq('id', id)

  if (error) {
    console.error('❌ Error toggling banner status:', error)
    throw error
  }

  console.log('✅ Toggled banner status:', id)
}
