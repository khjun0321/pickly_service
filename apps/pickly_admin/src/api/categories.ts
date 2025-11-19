import { supabase } from '@/lib/supabase'
import type { AgeCategory } from '@/types/database'

// ✅ v9.15.0: Fetch benefit_categories (대분류) for announcement form
export async function fetchCategories() {
  const { data, error } = await supabase
    .from('benefit_categories')
    .select('id, title, slug, icon_url, sort_order')
    .eq('is_active', true)
    .order('sort_order', { ascending: true })

  if (error) {
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }
  return data
}

// ✅ v9.15.0: Fetch benefit_subcategories (하위분류) by category_id
export async function fetchSubcategories(categoryId: string) {
  const { data, error } = await supabase
    .from('benefit_subcategories')
    .select('id, name, slug, icon_url, sort_order')
    .eq('category_id', categoryId)
    .eq('is_active', true)
    .order('sort_order', { ascending: true })

  if (error) {
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }
  return data
}

export async function fetchCategoryById(id: string) {
  const { data, error } = await supabase
    .from('age_categories')
    .select('*')
    .eq('id', id)
    .single()

  if (error) throw error
  return data as AgeCategory
}

export async function createCategory(category: Omit<AgeCategory, 'id' | 'created_at' | 'updated_at'>) {
  const { data, error } = await supabase
    .from('age_categories')
    .insert(category)
    .select()
    .single()

  if (error) {
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }
  return data as AgeCategory
}

export async function updateCategory(id: string, category: Partial<AgeCategory>) {
  console.log('🔄 Updating category:', id, category)

  const { data, error } = await supabase
    .from('age_categories')
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
  return data as AgeCategory
}

export async function deleteCategory(id: string) {
  console.log('🗑️ Deleting category:', id)

  const { error } = await supabase
    .from('age_categories')
    .delete()
    .eq('id', id)

  if (error) {
    console.error('❌ Delete error:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  console.log('✅ Deleted category:', id)
}

/**
 * Fetch benefit categories for banner management
 */
export async function fetchBenefitCategories() {
  const { data, error } = await supabase
    .from('benefit_categories')
    .select('id, name, slug, description, icon_url') // ✅ FIXED: Removed 'as title' alias syntax
    .eq('is_active', true)
    .order('display_order', { ascending: true })

  if (error) {
    console.error('❌ Error fetching benefit categories:', error)
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }

  return data
}
