import { supabase } from '@/lib/supabase'
import type { UserProfile } from '@/types/database'

export async function fetchUsers() {
  const { data, error } = await supabase
    .from('user_profiles')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) throw error
  return data as UserProfile[]
}

export async function fetchUserById(id: string) {
  const { data, error } = await supabase
    .from('user_profiles')
    .select('*')
    .eq('id', id)
    .single()

  if (error) throw error
  return data as UserProfile
}
