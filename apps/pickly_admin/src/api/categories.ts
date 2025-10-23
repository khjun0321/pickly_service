import { supabase } from '@/lib/supabase'
import type { AgeCategory } from '@/types/database'

export async function fetchCategories() {
  const { data, error } = await supabase
    .from('age_categories')
    .select('*')
    .order('sort_order', { ascending: true })

  if (error) {
    if (error.message.includes('JWT') || error.message.includes('expired')) {
      throw new Error('세션이 만료되었습니다. 다시 로그인해주세요.')
    }
    throw error
  }
  return data as AgeCategory[]
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
    // @ts-expect-error - Supabase type inference issue
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
    // @ts-expect-error - Supabase type inference issue
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
  const { error } = await supabase
    .from('age_categories')
    .delete()
    .eq('id', id)

  if (error) throw error
}
