import { useEffect, useState } from 'react'
import type { User } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'

// 🚨 DEVELOPMENT MODE: Bypass authentication for local development
// ONLY bypass if explicitly set to 'true' in .env
const IS_DEV_MODE = import.meta.env.VITE_BYPASS_AUTH === 'true'

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
    // Always use real authentication - no bypass
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
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })
    if (error) throw error
  }

  const signOut = async () => {
    try {
      // 1. Sign out from Supabase (even in dev mode)
      await supabase.auth.signOut()
    } catch (error) {
      console.error('Supabase signOut error:', error)
    }

    // 2. Clear all local state
    setUser(null)
    localStorage.clear()
    sessionStorage.clear()

    // 3. Clear cookies
    document.cookie.split(";").forEach((c) => {
      document.cookie = c
        .replace(/^ +/, "")
        .replace(/=.*/, "=;expires=" + new Date().toUTCString() + ";path=/")
    })

    // 4. Force redirect to login page
    window.location.href = '/login'
  }

  return { user, loading, signIn, signOut, isDevMode: IS_DEV_MODE }
}
