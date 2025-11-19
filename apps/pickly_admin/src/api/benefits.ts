import { supabase } from '@/lib/supabase'
import type { BenefitCategory, BenefitCategoryInsert, BenefitCategoryUpdate } from '@/types/database'

/**
 * Fetch all top-level benefit categories (parent categories only)
 * @returns Array of parent benefit categories ordered by display_order
 */
export async function fetchBenefitCategories() {
  console.log('📦 Fetching benefit categories...')

  const { data, error } = await supabase
    .from('benefit_categories')
    .select('*')
    .is('parent_id', null)
    .order('display_order', { ascending: true })

  if (error) {
    console.error('❌ Error fetching benefit categories:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  console.log('✅ Fetched benefit categories:', data?.length)
  return data as BenefitCategory[]
}

/**
 * Fetch a single benefit category by ID
 * @param id - Category ID
 * @returns Single benefit category
 */
export async function fetchBenefitCategoryById(id: string) {
  console.log('📦 Fetching benefit category by ID:', id)

  const { data, error } = await supabase
    .from('benefit_categories')
    .select('*')
    .eq('id', id)
    .single()

  if (error) {
    console.error('❌ Error fetching benefit category:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  console.log('✅ Fetched benefit category:', data?.name)
  return data as BenefitCategory
}

/**
 * Create a new benefit category
 * @param category - Category data to create
 * @returns Created benefit category
 */
export async function createBenefitCategory(category: BenefitCategoryInsert) {
  console.log('🔨 Creating benefit category:', category.name)

  const { data, error } = await supabase
    .from('benefit_categories')
    .insert(category)
    .select()
    .single()

  if (error) {
    console.error('❌ Error creating benefit category:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  console.log('✅ Created benefit category:', data?.id)
  return data as BenefitCategory
}

/**
 * Update an existing benefit category
 * @param id - Category ID
 * @param category - Partial category data to update
 * @returns Updated benefit category
 */
export async function updateBenefitCategory(id: string, category: BenefitCategoryUpdate) {
  console.log('🔄 Updating benefit category:', id, category)

  const { data, error } = await supabase
    .from('benefit_categories')
    .update(category)
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

  console.log('✅ Updated benefit category:', data?.id)
  return data as BenefitCategory
}

/**
 * Delete a benefit category
 * @param id - Category ID
 */
export async function deleteBenefitCategory(id: string) {
  console.log('🗑️ Deleting benefit category:', id)

  const { error } = await supabase
    .from('benefit_categories')
    .delete()
    .eq('id', id)

  if (error) {
    console.error('❌ Error deleting benefit category:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  console.log('✅ Deleted benefit category:', id)
}
