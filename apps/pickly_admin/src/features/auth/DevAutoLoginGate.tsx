/**
 * DevAutoLoginGate Component
 *
 * PRD v9.9.0 - Phase 6.5 Step 2
 *
 * Purpose: Automatically log in admin user in development environment
 * to bypass manual login during development workflow.
 *
 * Security:
 * - Only active when import.meta.env.MODE === 'development'
 * - Only when VITE_DEV_AUTO_LOGIN === 'true'
 * - Disabled in production builds automatically
 *
 * Usage:
 * Import and render at the root of App.tsx:
 *
 * ```tsx
 * import DevAutoLoginGate from '@/features/auth/DevAutoLoginGate';
 *
 * function App() {
 *   return (
 *     <>
 *       <DevAutoLoginGate />
 *       {/ * rest of app * /}
 *     </>
 *   );
 * }
 * ```
 */

import { useEffect, useState } from 'react';
import { supabase } from '@/utils/supabase';

export default function DevAutoLoginGate() {
  const [attempted, setAttempted] = useState(false);

  useEffect(() => {
    // Only run in development mode
    if (import.meta.env.MODE !== 'development') {
      return;
    }

    // Only run if explicitly enabled
    if (import.meta.env.VITE_DEV_AUTO_LOGIN !== 'true') {
      return;
    }

    // Only attempt once per session
    if (attempted) {
      return;
    }

    const attemptAutoLogin = async () => {
      try {
        // Check if already logged in
        const { data: { session } } = await supabase.auth.getSession();

        if (session) {
          console.log('✅ [DevAutoLogin] Already logged in:', session.user.email);
          return;
        }

        // Get credentials from environment
        const email = import.meta.env.VITE_DEV_ADMIN_EMAIL;
        const password = import.meta.env.VITE_DEV_ADMIN_PASSWORD;

        if (!email || !password) {
          console.warn('⚠️  [DevAutoLogin] Missing credentials in .env.development.local');
          return;
        }

        console.log('🔐 [DevAutoLogin] Attempting auto-login for:', email);

        // Attempt login
        const { data, error } = await supabase.auth.signInWithPassword({
          email,
          password,
        });

        if (error) {
          console.error('❌ [DevAutoLogin] Failed:', error.message);
        } else {
          console.log('✅ [DevAutoLogin] Success:', data.user?.email);
          console.log('🔑 [DevAutoLogin] Session established');
        }
      } catch (error) {
        console.error('❌ [DevAutoLogin] Exception:', error);
      } finally {
        setAttempted(true);
      }
    };

    // Run after a small delay to ensure Supabase client is ready
    const timeoutId = setTimeout(attemptAutoLogin, 500);

    return () => clearTimeout(timeoutId);
  }, [attempted]);

  // This component renders nothing - it's just a side-effect hook
  return null;
}
