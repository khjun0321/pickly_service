import { useEffect, useState } from 'react'
import type { User } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'

// 🚨 DEVELOPMENT MODE: Bypass authentication for local development
const IS_DEV_MODE = import.meta.env.DEV && import.meta.env.VITE_BYPASS_AUTH === 'true'

// Mock user for development
const DEV_USER: User = {
  id: 'dev-user-00000000-0000-0000-0000-000000000000',
  email: 'dev@pickly.com',
  created_at: new Date().toISOString(),
  app_metadata: {},
  user_metadata: {},
  aud: 'authenticated',
  role: 'authenticated',
} as User

export function useAuth() {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // 🚨 DEV MODE: Skip authentication entirely
    if (IS_DEV_MODE) {
      console.warn('🚨 DEV MODE: Authentication bypassed - dev@pickly.com')
      setUser(DEV_USER)
      setLoading(false)
      return
    }

    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user ?? null)
      setLoading(false)
    })

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null)
    })

    return () => subscription.unsubscribe()
  }, [])

  const signIn = async (email: string, password: string) => {
    // 🚨 DEV MODE: Auto-login
    if (IS_DEV_MODE) {
      console.warn('🚨 DEV MODE: Auto-login as dev@pickly.com')
      setUser(DEV_USER)
      return
    }

    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })
    if (error) throw error
  }

  const signOut = async () => {
    // 🚨 DEV MODE: Mock signout
    if (IS_DEV_MODE) {
      console.warn('🚨 DEV MODE: Mock signout')
      return
    }

    const { error } = await supabase.auth.signOut()
    if (error) throw error
  }

  return { user, loading, signIn, signOut, isDevMode: IS_DEV_MODE }
}
