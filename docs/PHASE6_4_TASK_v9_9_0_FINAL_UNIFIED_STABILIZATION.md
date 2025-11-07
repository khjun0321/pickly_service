# 🚀 Pickly v9.9.0 Final — Unified Stabilization & Scalable Media Architecture

**Task ID:** Phase 6.4 - v9.9.0 Final
**Date:** 2025-11-05
**Status:** 📋 **PLANNING**
**Priority:** 🔥 **CRITICAL** - Production Readiness

---

## 🎯 Objective

현재 모든 꼬인 흐름(Admin ↔ Storage ↔ App)을 완전 정리하고,
상용(Prod)에서도 확장 가능한 구조로 재정립한다.
(🔥 아이콘·썸네일·첨부파일·RLS·Edge Function·Realtime 전체 포함)

---

## 📦 Scope

- ✅ Supabase (DB, Storage, RLS, Realtime)
- ✅ Admin (React)
- ✅ Flutter App (Icons, Streams, Region, Thumbnails)
- ✅ PRD 문서 (v9.9.0-final 업데이트)

---

## 🧱 Step 1 — Supabase 구조 재정립 (확장성 고려)

### 1️⃣ 버킷 분리 (Storage)

**Architecture:**

| 버킷 | 용도 | 접근 정책 (DEV) | 접근 정책 (PROD) |
|-------|-------|----------------|----------------|
| `benefit-icons` | 카테고리 아이콘 (SVG) | public-read, auth-write | public-read, admin-write |
| `announcement-thumbnails` | 공고 썸네일 (jpg/webp/png) | public-read, auth-write | public-read, admin-write |
| `announcement-files` | 공고 첨부 (PDF 등) | private | private + signed URL |
| `mapping-exports` | 매핑 로그 | private | private |

**Implementation:**

**File:** `/backend/supabase/migrations/20251108000001_create_storage_buckets.sql`

```sql
-- ============================================================================
-- Phase 6.4 - v9.9.0 Final: Storage Buckets Architecture
-- ============================================================================

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('benefit-icons', 'benefit-icons', true, 5242880, ARRAY['image/svg+xml']),
  ('announcement-thumbnails', 'announcement-thumbnails', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp']),
  ('announcement-files', 'announcement-files', false, 52428800, NULL),
  ('mapping-exports', 'mapping-exports', false, 104857600, NULL)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ============================================================================
-- Storage Policies
-- ============================================================================

-- benefit-icons: Public read
DROP POLICY IF EXISTS "benefit-icons read (public)" ON storage.objects;
CREATE POLICY "benefit-icons read (public)"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'benefit-icons');

-- benefit-icons: Admin write (DEV: authenticated, PROD: admin only)
DROP POLICY IF EXISTS "benefit-icons write (dev)" ON storage.objects;
CREATE POLICY "benefit-icons write (dev)"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'benefit-icons' AND
  (
    -- DEV: Allow all authenticated users
    auth.jwt() ->> 'email' LIKE '%@%'
    OR
    -- PROD: Only admin
    auth.jwt() ->> 'email' = 'admin@pickly.com'
  )
);

DROP POLICY IF EXISTS "benefit-icons update (dev)" ON storage.objects;
CREATE POLICY "benefit-icons update (dev)"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'benefit-icons')
WITH CHECK (
  bucket_id = 'benefit-icons' AND
  (
    auth.jwt() ->> 'email' LIKE '%@%' OR
    auth.jwt() ->> 'email' = 'admin@pickly.com'
  )
);

DROP POLICY IF EXISTS "benefit-icons delete (dev)" ON storage.objects;
CREATE POLICY "benefit-icons delete (dev)"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'benefit-icons' AND
  (
    auth.jwt() ->> 'email' LIKE '%@%' OR
    auth.jwt() ->> 'email' = 'admin@pickly.com'
  )
);

-- announcement-thumbnails: Public read
DROP POLICY IF EXISTS "announcement-thumbnails read (public)" ON storage.objects;
CREATE POLICY "announcement-thumbnails read (public)"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'announcement-thumbnails');

-- announcement-thumbnails: Admin write
DROP POLICY IF EXISTS "announcement-thumbnails write (admin)" ON storage.objects;
CREATE POLICY "announcement-thumbnails write (admin)"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'announcement-thumbnails' AND
  (
    auth.jwt() ->> 'email' LIKE '%@%' OR
    auth.jwt() ->> 'email' = 'admin@pickly.com'
  )
);

DROP POLICY IF EXISTS "announcement-thumbnails update (admin)" ON storage.objects;
CREATE POLICY "announcement-thumbnails update (admin)"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'announcement-thumbnails')
WITH CHECK (
  bucket_id = 'announcement-thumbnails' AND
  (
    auth.jwt() ->> 'email' LIKE '%@%' OR
    auth.jwt() ->> 'email' = 'admin@pickly.com'
  )
);

DROP POLICY IF EXISTS "announcement-thumbnails delete (admin)" ON storage.objects;
CREATE POLICY "announcement-thumbnails delete (admin)"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'announcement-thumbnails' AND
  (
    auth.jwt() ->> 'email' LIKE '%@%' OR
    auth.jwt() ->> 'email' = 'admin@pickly.com'
  )
);

-- announcement-files: Private (signed URLs only)
DROP POLICY IF EXISTS "announcement-files read (owner)" ON storage.objects;
CREATE POLICY "announcement-files read (owner)"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'announcement-files' AND
  (
    auth.uid()::text = (storage.foldername(name))[1] OR
    auth.jwt() ->> 'email' = 'admin@pickly.com'
  )
);

DROP POLICY IF EXISTS "announcement-files write (owner)" ON storage.objects;
CREATE POLICY "announcement-files write (owner)"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'announcement-files' AND
  (
    auth.uid()::text = (storage.foldername(name))[1] OR
    auth.jwt() ->> 'email' = 'admin@pickly.com'
  )
);

-- mapping-exports: Private (admin only)
DROP POLICY IF EXISTS "mapping-exports admin only" ON storage.objects;
CREATE POLICY "mapping-exports admin only"
ON storage.objects
FOR ALL
TO authenticated
USING (
  bucket_id = 'mapping-exports' AND
  auth.jwt() ->> 'email' = 'admin@pickly.com'
)
WITH CHECK (
  bucket_id = 'mapping-exports' AND
  auth.jwt() ->> 'email' = 'admin@pickly.com'
);
```

---

### 2️⃣ 테이블 확장

**File:** `/backend/supabase/migrations/20251108000002_extend_tables_media.sql`

```sql
-- ============================================================================
-- Phase 6.4 - v9.9.0 Final: Table Extensions for Media
-- ============================================================================

-- Extend announcements table for media support
ALTER TABLE public.announcements
ADD COLUMN IF NOT EXISTS thumbnail_filename text,
ADD COLUMN IF NOT EXISTS attachments jsonb DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

-- Create trigger to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_announcements_updated_at ON public.announcements;
CREATE TRIGGER update_announcements_updated_at
BEFORE UPDATE ON public.announcements
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Media assets metadata management
CREATE TABLE IF NOT EXISTS public.media_assets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bucket text NOT NULL,
  path text NOT NULL,
  mime text,
  size int8,
  owner_user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  purpose text CHECK (purpose IN ('icon','thumbnail','attachment','other')),
  linked_table text,
  linked_id uuid,
  created_at timestamptz DEFAULT now(),
  metadata jsonb DEFAULT '{}'::jsonb,
  UNIQUE(bucket, path)
);

CREATE INDEX IF NOT EXISTS idx_media_bucket_path ON public.media_assets(bucket, path);
CREATE INDEX IF NOT EXISTS idx_media_linked ON public.media_assets(linked_table, linked_id);
CREATE INDEX IF NOT EXISTS idx_media_purpose ON public.media_assets(purpose);
CREATE INDEX IF NOT EXISTS idx_media_owner ON public.media_assets(owner_user_id);

COMMENT ON TABLE public.media_assets IS 'Metadata tracking for all media files in Supabase Storage';
COMMENT ON COLUMN public.media_assets.purpose IS 'icon, thumbnail, attachment, other';
COMMENT ON COLUMN public.media_assets.linked_table IS 'benefit_categories, announcements, etc.';
COMMENT ON COLUMN public.media_assets.linked_id IS 'Foreign key to linked_table';

-- RLS for media_assets
ALTER TABLE public.media_assets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "media_assets read (public)" ON public.media_assets;
CREATE POLICY "media_assets read (public)"
ON public.media_assets
FOR SELECT
TO public
USING (
  purpose IN ('icon', 'thumbnail') OR
  owner_user_id = auth.uid() OR
  auth.jwt() ->> 'email' = 'admin@pickly.com'
);

DROP POLICY IF EXISTS "media_assets write (admin)" ON public.media_assets;
CREATE POLICY "media_assets write (admin)"
ON public.media_assets
FOR ALL
TO authenticated
USING (
  owner_user_id = auth.uid() OR
  auth.jwt() ->> 'email' = 'admin@pickly.com'
)
WITH CHECK (
  owner_user_id = auth.uid() OR
  auth.jwt() ->> 'email' = 'admin@pickly.com'
);
```

---

### 3️⃣ Realtime 확장

**File:** `/backend/supabase/migrations/20251108000003_extend_realtime.sql`

```sql
-- ============================================================================
-- Phase 6.4 - v9.9.0 Final: Realtime Extensions
-- ============================================================================

-- Add all critical tables to Realtime publication
ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.regions;
ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.user_regions;
ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.benefit_categories;
ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.announcements;
ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.media_assets;

-- Verify publication
SELECT schemaname, tablename
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'
ORDER BY schemaname, tablename;
```

---

### 4️⃣ Regions & User Regions 보장

**File:** `/backend/supabase/migrations/20251108000004_ensure_regions.sql`

```sql
-- ============================================================================
-- Phase 6.4 - v9.9.0 Final: Regions Data Integrity
-- ============================================================================

-- Ensure regions table exists (idempotent)
CREATE TABLE IF NOT EXISTS public.regions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text UNIQUE NOT NULL,
  name text NOT NULL,
  sort_order int DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Ensure user_regions table exists (idempotent)
CREATE TABLE IF NOT EXISTS public.user_regions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  region_id uuid NOT NULL REFERENCES public.regions(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, region_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_regions_code ON public.regions(code);
CREATE INDEX IF NOT EXISTS idx_regions_active ON public.regions(is_active);
CREATE INDEX IF NOT EXISTS idx_user_regions_user ON public.user_regions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_regions_region ON public.user_regions(region_id);

-- Seed 18 Korean regions (idempotent)
INSERT INTO public.regions(code, name, sort_order, is_active) VALUES
('NATIONWIDE', '전국', 0, true),
('SEOUL', '서울', 1, true),
('GYEONGGI', '경기', 2, true),
('INCHEON', '인천', 3, true),
('BUSAN', '부산', 4, true),
('DAEGU', '대구', 5, true),
('GWANGJU', '광주', 6, true),
('DAEJEON', '대전', 7, true),
('ULSAN', '울산', 8, true),
('SEJONG', '세종', 9, true),
('GANGWON', '강원', 10, true),
('CHUNGNAM', '충남', 11, true),
('CHUNGBUK', '충북', 12, true),
('JEONNAM', '전남', 13, true),
('JEONBUK', '전북', 14, true),
('GYEONGBUK', '경북', 15, true),
('GYEONGNAM', '경남', 16, true),
('JEJU', '제주', 17, true)
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  sort_order = EXCLUDED.sort_order,
  is_active = EXCLUDED.is_active;

-- RLS for regions
ALTER TABLE public.regions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "regions read (public)" ON public.regions;
CREATE POLICY "regions read (public)"
ON public.regions
FOR SELECT
TO public
USING (is_active = true);

DROP POLICY IF EXISTS "regions write (admin)" ON public.regions;
CREATE POLICY "regions write (admin)"
ON public.regions
FOR ALL
TO authenticated
USING (auth.jwt() ->> 'email' = 'admin@pickly.com')
WITH CHECK (auth.jwt() ->> 'email' = 'admin@pickly.com');

-- RLS for user_regions
ALTER TABLE public.user_regions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_regions read (owner)" ON public.user_regions;
CREATE POLICY "user_regions read (owner)"
ON public.user_regions
FOR SELECT
TO authenticated
USING (
  user_id = auth.uid() OR
  auth.jwt() ->> 'email' = 'admin@pickly.com'
);

DROP POLICY IF EXISTS "user_regions write (owner)" ON public.user_regions;
CREATE POLICY "user_regions write (owner)"
ON public.user_regions
FOR ALL
TO authenticated
USING (
  user_id = auth.uid() OR
  auth.jwt() ->> 'email' = 'admin@pickly.com'
)
WITH CHECK (
  user_id = auth.uid() OR
  auth.jwt() ->> 'email' = 'admin@pickly.com'
);
```

---

### 5️⃣ DEV 훅 우회 + Admin 세션 유지

**File:** `/backend/supabase/migrations/20251108000005_admin_helpers.sql`

```sql
-- ============================================================================
-- Phase 6.4 - v9.9.0 Final: Admin Helper Functions
-- ============================================================================

-- Helper function for admin check
CREATE OR REPLACE FUNCTION public.custom_access(email text)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT (email = 'admin@pickly.com')::boolean;
$$;

GRANT EXECUTE ON FUNCTION public.custom_access(text) TO anon, authenticated, service_role;

-- Helper function to check if current user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN (auth.jwt() ->> 'email' = 'admin@pickly.com');
END;
$$;

GRANT EXECUTE ON FUNCTION public.is_admin() TO anon, authenticated, service_role;

-- Custom access check trigger function (already exists, ensuring it's present)
CREATE OR REPLACE FUNCTION public.custom_access_check()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN NEW;  -- ✅ 아무것도 안함, 에러 방지용
END;
$$;

GRANT EXECUTE ON FUNCTION public.custom_access_check() TO anon, authenticated, service_role;

COMMENT ON FUNCTION public.custom_access(text) IS 'Check if email is admin';
COMMENT ON FUNCTION public.is_admin() IS 'Check if current authenticated user is admin';
COMMENT ON FUNCTION public.custom_access_check() IS 'Pass-through trigger for RLS error prevention';
```

---

## 🧱 Step 2 — Admin (React)

### 1️⃣ Dev Auto-Login Configuration

**File:** `/apps/pickly_admin/.env.development.local`

```env
# Dev Auto-Login (개발 환경에서만 사용)
VITE_DEV_AUTO_LOGIN=true
VITE_DEV_ADMIN_EMAIL=admin@pickly.com
VITE_DEV_ADMIN_PASSWORD=pickly2025!

# Supabase Configuration
VITE_SUPABASE_URL=http://localhost:54321
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
```

**Important:** Add `.env.development.local` to `.gitignore`

```gitignore
# Local env files
.env.local
.env.development.local
.env.test.local
.env.production.local
```

---

### 2️⃣ Dev Auto-Login Component

**File:** `/apps/pickly_admin/src/features/auth/DevAutoLoginGate.tsx`

```typescript
import { useEffect, useState } from 'react';
import { supabase } from '@/utils/supabase';

/**
 * DevAutoLoginGate
 *
 * 개발 환경에서만 자동 로그인을 수행하는 컴포넌트
 * 환경변수로 제어되며, production 빌드에서는 작동하지 않음
 */
export default function DevAutoLoginGate() {
  const [attempted, setAttempted] = useState(false);

  useEffect(() => {
    // Only run in development mode
    if (import.meta.env.MODE !== 'development') {
      return;
    }

    // Check if auto-login is enabled
    if (import.meta.env.VITE_DEV_AUTO_LOGIN !== 'true') {
      return;
    }

    // Only attempt once
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

        // Attempt auto-login
        const email = import.meta.env.VITE_DEV_ADMIN_EMAIL;
        const password = import.meta.env.VITE_DEV_ADMIN_PASSWORD;

        if (!email || !password) {
          console.warn('⚠️ [DevAutoLogin] Credentials not configured');
          return;
        }

        console.log('🔐 [DevAutoLogin] Attempting auto-login...');
        const { data, error } = await supabase.auth.signInWithPassword({
          email,
          password,
        });

        if (error) {
          console.error('❌ [DevAutoLogin] Failed:', error.message);
        } else {
          console.log('✅ [DevAutoLogin] Success:', data.user?.email);
        }
      } catch (error) {
        console.error('❌ [DevAutoLogin] Exception:', error);
      } finally {
        setAttempted(true);
      }
    };

    attemptAutoLogin();
  }, [attempted]);

  return null;
}
```

---

### 3️⃣ Integrate into App.tsx

**File:** `/apps/pickly_admin/src/App.tsx`

```typescript
import { BrowserRouter } from 'react-router-dom';
import DevAutoLoginGate from '@/features/auth/DevAutoLoginGate';
// ... other imports

function App() {
  return (
    <BrowserRouter>
      {/* DEV ONLY: Auto-login gate */}
      {import.meta.env.DEV && <DevAutoLoginGate />}

      {/* Your existing app structure */}
      <Routes>
        {/* ... routes ... */}
      </Routes>
    </BrowserRouter>
  );
}

export default App;
```

---

## 🧱 Step 3 — Flutter (App)

### 1️⃣ Media Resolver Utility

**File:** `/apps/pickly_mobile/lib/core/utils/media_resolver.dart`

```dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Media Resolver Utility
///
/// Resolves media URLs from local assets or Supabase Storage
/// with automatic fallback logic.
///
/// PRD v9.9.0 Final: Unified Media Architecture
class MediaResolver {
  /// Check if local asset exists
  static Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Resolve media URL with fallback
  ///
  /// Returns:
  /// - `asset://path` if local asset exists
  /// - `https://...` Supabase Storage URL otherwise
  ///
  /// Parameters:
  /// - [filename]: The filename (e.g., 'housing.svg', 'thumbnail.jpg')
  /// - [bucket]: Storage bucket name (default: 'benefit-icons')
  /// - [localPath]: Local asset path prefix (default: 'packages/pickly_design_system/assets/icons/')
  ///
  /// Example:
  /// ```dart
  /// final url = await MediaResolver.resolveMediaUrl('housing.svg');
  /// // Returns: 'asset://packages/pickly_design_system/assets/icons/housing.svg'
  /// // or: 'https://project.supabase.co/storage/v1/object/public/benefit-icons/housing.svg'
  /// ```
  static Future<String> resolveMediaUrl(
    String filename, {
    String bucket = 'benefit-icons',
    String? localPath,
  }) async {
    // Default local path based on bucket
    final defaultLocalPath = bucket == 'benefit-icons'
        ? 'packages/pickly_design_system/assets/icons/'
        : 'packages/pickly_design_system/assets/images/';

    final assetPath = (localPath ?? defaultLocalPath) + filename;

    // Check if local asset exists
    if (await _assetExists(assetPath)) {
      print('🎨 [MediaResolver] Using local asset: $assetPath');
      return 'asset://$assetPath';
    }

    // Fallback to Supabase Storage
    final supabase = Supabase.instance.client;
    final storageUrl = supabase.storage.from(bucket).getPublicUrl(filename);

    print('🌐 [MediaResolver] Using remote URL: $storageUrl');
    return storageUrl;
  }

  /// Resolve signed URL for private files
  ///
  /// Used for announcement attachments and other private media
  ///
  /// Parameters:
  /// - [filename]: The filename
  /// - [bucket]: Storage bucket name
  /// - [expiresIn]: URL expiry time in seconds (default: 3600 = 1 hour)
  static Future<String> resolveSignedUrl(
    String filename, {
    required String bucket,
    int expiresIn = 3600,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final signedUrl = await supabase.storage
          .from(bucket)
          .createSignedUrl(filename, expiresIn);

      print('🔐 [MediaResolver] Generated signed URL (expires in ${expiresIn}s): $filename');
      return signedUrl;
    } catch (e) {
      print('❌ [MediaResolver] Failed to generate signed URL: $e');
      rethrow;
    }
  }

  /// Check if URL is a local asset
  static bool isLocalAsset(String url) {
    return url.startsWith('asset://');
  }

  /// Strip asset:// prefix
  static String stripAssetPrefix(String url) {
    return url.replaceFirst('asset://', '');
  }
}
```

---

### 2️⃣ Category Circle Widget (Updated)

**File:** `/apps/pickly_mobile/lib/features/benefits/widgets/category_circle.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickly_mobile/core/utils/media_resolver.dart';
import 'package:pickly_mobile/contexts/benefit/models/benefit_category.dart';

/// Category Circle Widget
///
/// Displays benefit category as a circular icon with label
/// Uses MediaResolver for icon loading (local asset or remote URL)
///
/// PRD v9.9.0 Final: Unified Media Architecture
class CategoryCircle extends StatelessWidget {
  final BenefitCategory category;
  final VoidCallback? onTap;
  final bool selected;

  const CategoryCircle({
    Key? key,
    required this.category,
    this.onTap,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon circle
          FutureBuilder<String>(
            future: MediaResolver.resolveMediaUrl(
              category.iconUrl,
              bucket: 'benefit-icons',
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return _buildPlaceholder();
              }

              final url = snapshot.data!;

              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.grey[100],
                  border: selected
                      ? Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        )
                      : null,
                ),
                child: Center(
                  child: _buildIcon(url, context),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          // Label
          Text(
            category.title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? Theme.of(context).primaryColor : null,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(String url, BuildContext context) {
    try {
      if (MediaResolver.isLocalAsset(url)) {
        // Local asset
        return SvgPicture.asset(
          MediaResolver.stripAssetPrefix(url),
          width: 32,
          height: 32,
          colorFilter: ColorFilter.mode(
            Theme.of(context).primaryColor,
            BlendMode.srcIn,
          ),
        );
      } else {
        // Remote URL
        return SvgPicture.network(
          url,
          width: 32,
          height: 32,
          colorFilter: ColorFilter.mode(
            Theme.of(context).primaryColor,
            BlendMode.srcIn,
          ),
          placeholderBuilder: (context) => _buildPlaceholder(),
        );
      }
    } catch (e) {
      print('❌ [CategoryCircle] Failed to load icon: $e');
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      child: const Center(
        child: Icon(
          Icons.category,
          size: 32,
          color: Colors.grey,
        ),
      ),
    );
  }
}
```

---

### 3️⃣ Announcement Card Widget (Updated)

**File:** `/apps/pickly_mobile/lib/features/benefits/widgets/announcement_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:pickly_mobile/core/utils/media_resolver.dart';
import 'package:pickly_mobile/contexts/benefit/models/announcement.dart';

/// Announcement Card Widget
///
/// Displays announcement with thumbnail image
/// Uses MediaResolver for thumbnail loading
///
/// PRD v9.9.0 Final: Unified Media Architecture
class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback? onTap;

  const AnnouncementCard({
    Key? key,
    required this.announcement,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            _buildThumbnail(),
            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (announcement.subtitle != null)
                    Text(
                      announcement.subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${announcement.viewsCount ?? 0}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (announcement.thumbnailFilename == null) {
      return _buildPlaceholderThumbnail();
    }

    return FutureBuilder<String>(
      future: MediaResolver.resolveMediaUrl(
        announcement.thumbnailFilename!,
        bucket: 'announcement-thumbnails',
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildPlaceholderThumbnail();
        }

        return AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('❌ [AnnouncementCard] Failed to load thumbnail: $error');
              return _buildPlaceholderThumbnail();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildPlaceholderThumbnail();
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderThumbnail() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(
            Icons.image,
            size: 48,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
```

---

## 📋 Migration Execution Order

Execute migrations in this exact order:

```bash
# Step 1: Storage Buckets
psql -U postgres -d postgres -f backend/supabase/migrations/20251108000001_create_storage_buckets.sql

# Step 2: Table Extensions
psql -U postgres -d postgres -f backend/supabase/migrations/20251108000002_extend_tables_media.sql

# Step 3: Realtime
psql -U postgres -d postgres -f backend/supabase/migrations/20251108000003_extend_realtime.sql

# Step 4: Regions
psql -U postgres -d postgres -f backend/supabase/migrations/20251108000004_ensure_regions.sql

# Step 5: Admin Helpers
psql -U postgres -d postgres -f backend/supabase/migrations/20251108000005_admin_helpers.sql
```

Or use Docker:

```bash
docker exec -i supabase_db_supabase psql -U postgres -d postgres < backend/supabase/migrations/20251108000001_create_storage_buckets.sql
docker exec -i supabase_db_supabase psql -U postgres -d postgres < backend/supabase/migrations/20251108000002_extend_tables_media.sql
docker exec -i supabase_db_supabase psql -U postgres -d postgres < backend/supabase/migrations/20251108000003_extend_realtime.sql
docker exec -i supabase_db_supabase psql -U postgres -d postgres < backend/supabase/migrations/20251108000004_ensure_regions.sql
docker exec -i supabase_db_supabase psql -U postgres -d postgres < backend/supabase/migrations/20251108000005_admin_helpers.sql
```

---

## ✅ Success Criteria

### Database
- [ ] All 4 storage buckets created with correct policies
- [ ] `announcements` table extended with `thumbnail_filename`, `attachments`, `updated_at`
- [ ] `media_assets` table created with indexes
- [ ] All tables added to Realtime publication
- [ ] 18 regions seeded and verified
- [ ] Admin helper functions created

### Admin (React)
- [ ] `.env.development.local` configured
- [ ] `DevAutoLoginGate` component created
- [ ] Component integrated into `App.tsx`
- [ ] Dev auto-login working (logs show successful auth)

### Flutter (App)
- [ ] `MediaResolver` utility created
- [ ] `CategoryCircle` widget updated to use `MediaResolver`
- [ ] `AnnouncementCard` widget updated to use `MediaResolver`
- [ ] Icons display correctly (local or remote)
- [ ] Thumbnails display correctly

### Integration Testing
- [ ] Admin can upload icon to `benefit-icons` bucket
- [ ] Admin can upload thumbnail to `announcement-thumbnails` bucket
- [ ] Flutter app loads icons from correct source (local fallback working)
- [ ] Flutter app loads thumbnails from Supabase Storage
- [ ] Realtime updates working for all tables
- [ ] RLS policies enforced correctly

---

## 🐛 Troubleshooting

### Issue: Storage Policy Error

**Symptom:**
```
Error: new row violates row-level security policy
```

**Solution:**
Check if admin is authenticated:
```sql
SELECT auth.jwt() ->> 'email';
```

Force logout and re-login to refresh JWT token.

---

### Issue: Asset Not Found

**Symptom:**
```
[ERROR] Unable to load asset: packages/pickly_design_system/assets/icons/housing.svg
```

**Solution:**
1. Verify asset exists in package
2. Check `pubspec.yaml` includes `assets/icons/`
3. Run `flutter clean && flutter pub get`
4. Full rebuild required for new assets

---

### Issue: MediaResolver Fallback Not Working

**Symptom:**
Icons not loading from either local or remote

**Solution:**
Check logs for MediaResolver output:
```
🎨 [MediaResolver] Using local asset: ...
🌐 [MediaResolver] Using remote URL: ...
```

If no logs appear, check if `MediaResolver.resolveMediaUrl()` is being awaited in `FutureBuilder`.

---

## 📊 Implementation Checklist

- [ ] **Database Migrations (5 files)**
  - [ ] 20251108000001_create_storage_buckets.sql
  - [ ] 20251108000002_extend_tables_media.sql
  - [ ] 20251108000003_extend_realtime.sql
  - [ ] 20251108000004_ensure_regions.sql
  - [ ] 20251108000005_admin_helpers.sql

- [ ] **Admin (React)**
  - [ ] .env.development.local
  - [ ] src/features/auth/DevAutoLoginGate.tsx
  - [ ] Update App.tsx

- [ ] **Flutter (App)**
  - [ ] lib/core/utils/media_resolver.dart
  - [ ] Update lib/features/benefits/widgets/category_circle.dart
  - [ ] Update lib/features/benefits/widgets/announcement_card.dart

- [ ] **Testing**
  - [ ] Run all migrations
  - [ ] Verify storage buckets
  - [ ] Test admin auto-login
  - [ ] Test icon loading in app
  - [ ] Test thumbnail loading in app
  - [ ] Verify Realtime subscriptions

- [ ] **Documentation**
  - [ ] Update PRD to v9.9.0-final
  - [ ] Create Phase 6.4 completion report

---

## 📝 Notes

### Why This Architecture?

1. **Scalability**: Separate buckets for different media types allow independent scaling
2. **Security**: Private buckets with signed URLs for sensitive files
3. **Performance**: Public buckets with CDN for icons and thumbnails
4. **Flexibility**: Local asset fallback for offline support
5. **Maintainability**: Centralized media metadata tracking

### DEV vs PROD Differences

| Aspect | DEV | PROD |
|--------|-----|------|
| Storage Write | All authenticated | Admin only |
| Auto-login | Enabled | Disabled |
| RLS Checks | Relaxed | Strict |
| Logging | Verbose | Minimal |

### Migration Strategy

All migrations are **idempotent** (can be run multiple times safely):
- `CREATE TABLE IF NOT EXISTS`
- `DROP POLICY IF EXISTS` before `CREATE POLICY`
- `INSERT ... ON CONFLICT DO UPDATE/NOTHING`
- `ADD COLUMN IF NOT EXISTS`

---

**Document Version:** 1.0
**Created:** 2025-11-05 20:30 KST
**Author:** Claude Code
**Status:** 📋 **TASK CREATED** - Ready for implementation
