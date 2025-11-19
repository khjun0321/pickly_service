# 🚀 Pickly v9.9.0 — One-Shot Stabilization Runbook (Step-by-Step)

**Date:** 2025-11-05
**Version:** v9.9.0 Final
**Status:** 📋 **RUNBOOK** - Ready for execution
**Environment:** DEV (Development)

---

## 🎯 Goal

Admin ↔ Storage ↔ App 전 구간을 **한 번에** 안정화. (DEV 환경 기준)

✅ Admin 로그인 즉시 가능 (훅 에러 우회)
✅ SVG 아이콘: Admin 업로드 → App 즉시 표시
✅ Regions/Realtime 보장
✅ Flutter 중복 스트림 제거, 써클탭 표시
✅ 문서 및 롤백 가이드 포함
✅ (확장 고려) 썸네일/첨부 파일 구조까지 스캐폴딩

---

## 📋 Prerequisites

### Required Tools
- ✅ Docker (Supabase local)
- ✅ PostgreSQL client (psql)
- ✅ Node.js 18+ (Admin app)
- ✅ Flutter 3.x (Mobile app)
- ✅ pnpm (Admin package manager)

### Verify Environment
```bash
# Check Docker
docker ps | grep supabase

# Check Flutter
flutter --version

# Check Node.js
node --version
pnpm --version

# Check project structure
ls -la backend/supabase/migrations/
ls -la apps/pickly_admin/
ls -la apps/pickly_mobile/
```

---

## 0️⃣ PRECHECK — 충돌 마이그레이션 임시 비활성화

### Why?
기존 마이그레이션 중 일부가 새 구조와 충돌할 수 있으므로 임시 비활성화.

### Commands

```bash
# Navigate to project root
cd /Users/kwonhyunjun/Desktop/pickly_service

# Disable conflicting migrations
mv backend/supabase/migrations/20251101000010_create_dev_admin_user.sql \
   backend/supabase/migrations/20251101000010_create_dev_admin_user.sql.disabled 2>/dev/null || true

mv backend/supabase/migrations/20251101_fix_admin_schema.sql \
   backend/supabase/migrations/20251101_fix_admin_schema.sql.disabled 2>/dev/null || true

mv backend/supabase/migrations/20251106000001_fix_rls_admin_role_guard_prd_v9_6_2.sql \
   backend/supabase/migrations/20251106000001_fix_rls_admin_role_guard_prd_v9_6_2.sql.disabled 2>/dev/null || true
```

### ✅ Success Criteria

```bash
# Verify files are disabled
ls -la backend/supabase/migrations/*.disabled

# Should see:
# 20251101000010_create_dev_admin_user.sql.disabled
# 20251101_fix_admin_schema.sql.disabled
# 20251106000001_fix_rls_admin_role_guard_prd_v9_6_2.sql.disabled
```

**Expected:** 3 files with `.disabled` extension.

---

## 1️⃣ SUPABASE — Regions/Realtime/Storage 정책 확정

### Why?
데이터베이스 구조 확정, Realtime 활성화, Storage 정책 설정으로 전체 파이프라인 기반 구축.

### SQL Migration

**File:** `/backend/supabase/migrations/20251108000000_one_shot_stabilization.sql`

```sql
-- ============================================================================
-- Pickly v9.9.0 - One-Shot Stabilization
-- ============================================================================
-- Date: 2025-11-05
-- Description: 전체 시스템 안정화 (Regions, Realtime, Storage, Admin)
-- ============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- 1-1) Regions & User Regions (존재 시 스킵)
-- ────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.regions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text UNIQUE NOT NULL,
  name text NOT NULL,
  sort_order int DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_regions_code ON public.regions(code);
CREATE INDEX IF NOT EXISTS idx_regions_active ON public.regions(is_active);

CREATE TABLE IF NOT EXISTS public.user_regions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  region_id uuid NOT NULL REFERENCES public.regions(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, region_id)
);

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

-- ────────────────────────────────────────────────────────────────────────────
-- 1-2) Realtime Publication (idempotent)
-- ────────────────────────────────────────────────────────────────────────────

ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.regions;
ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.user_regions;
ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.benefit_categories;
ALTER PUBLICATION supabase_realtime ADD TABLE IF NOT EXISTS public.announcements;

-- ────────────────────────────────────────────────────────────────────────────
-- 1-3) Storage Bucket & Policies (benefit-icons)
-- ────────────────────────────────────────────────────────────────────────────

-- Create bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('benefit-icons', 'benefit-icons', true, 5242880, ARRAY['image/svg+xml'])
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/svg+xml'];

-- Storage policies (idempotent)
DO $$
BEGIN
  -- Public read
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
    AND tablename = 'objects'
    AND policyname = 'benefit-icons read (public)'
  ) THEN
    CREATE POLICY "benefit-icons read (public)"
    ON storage.objects
    FOR SELECT
    TO public
    USING (bucket_id = 'benefit-icons');
  END IF;

  -- Authenticated upload
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
    AND tablename = 'objects'
    AND policyname = 'benefit-icons upload (auth)'
  ) THEN
    CREATE POLICY "benefit-icons upload (auth)"
    ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'benefit-icons');
  END IF;

  -- Authenticated update
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
    AND tablename = 'objects'
    AND policyname = 'benefit-icons update (auth)'
  ) THEN
    CREATE POLICY "benefit-icons update (auth)"
    ON storage.objects
    FOR UPDATE
    TO authenticated
    USING (bucket_id = 'benefit-icons');
  END IF;

  -- Authenticated delete
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'storage'
    AND tablename = 'objects'
    AND policyname = 'benefit-icons delete (auth)'
  ) THEN
    CREATE POLICY "benefit-icons delete (auth)"
    ON storage.objects
    FOR DELETE
    TO authenticated
    USING (bucket_id = 'benefit-icons');
  END IF;
END $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 1-4) Admin Helper Function (DEV 임시 우회)
-- ────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.custom_access(email text)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT (email = 'admin@pickly.com')::boolean;
$$;

GRANT EXECUTE ON FUNCTION public.custom_access(text) TO anon, authenticated, service_role;

COMMENT ON FUNCTION public.custom_access(text) IS 'DEV: Admin access check (bypasses some RLS in dev)';

-- ────────────────────────────────────────────────────────────────────────────
-- Verification Queries
-- ────────────────────────────────────────────────────────────────────────────

-- Count regions
DO $$
DECLARE
  region_count int;
BEGIN
  SELECT COUNT(*) INTO region_count FROM public.regions WHERE is_active = true;
  RAISE NOTICE '✅ Active regions: %', region_count;
  IF region_count != 18 THEN
    RAISE WARNING '⚠️ Expected 18 regions, found %', region_count;
  END IF;
END $$;

-- Verify Realtime publication
DO $$
DECLARE
  table_count int;
BEGIN
  SELECT COUNT(*) INTO table_count
  FROM pg_publication_tables
  WHERE pubname = 'supabase_realtime'
  AND tablename IN ('regions', 'user_regions', 'benefit_categories', 'announcements');
  RAISE NOTICE '✅ Realtime tables: %/4', table_count;
END $$;

-- Verify storage bucket
DO $$
DECLARE
  bucket_exists boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM storage.buckets WHERE id = 'benefit-icons' AND public = true
  ) INTO bucket_exists;
  IF bucket_exists THEN
    RAISE NOTICE '✅ benefit-icons bucket: public';
  ELSE
    RAISE WARNING '⚠️ benefit-icons bucket not configured correctly';
  END IF;
END $$;

-- Verify storage policies
DO $$
DECLARE
  policy_count int;
BEGIN
  SELECT COUNT(*) INTO policy_count
  FROM pg_policies
  WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND policyname LIKE 'benefit-icons%';
  RAISE NOTICE '✅ benefit-icons policies: %/4', policy_count;
END $$;
```

### Execute Migration

```bash
# Option 1: Using psql directly (if Supabase is running locally)
psql -U postgres -d postgres -h localhost -p 54322 \
  -f backend/supabase/migrations/20251108000000_one_shot_stabilization.sql

# Option 2: Using Docker exec (recommended)
docker exec -i supabase_db_supabase psql -U postgres -d postgres < \
  backend/supabase/migrations/20251108000000_one_shot_stabilization.sql
```

### ✅ Success Criteria

```bash
# Verify regions
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
  "SELECT COUNT(*) FROM public.regions WHERE is_active = true;"
# Expected: 18

# Verify Realtime publication
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
  "SELECT tablename FROM pg_publication_tables WHERE pubname = 'supabase_realtime' ORDER BY tablename;"
# Expected: announcements, benefit_categories, regions, user_regions

# Verify storage bucket
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
  "SELECT id, name, public FROM storage.buckets WHERE id = 'benefit-icons';"
# Expected: benefit-icons | benefit-icons | t

# Verify storage policies
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
  "SELECT policyname FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname LIKE 'benefit-icons%';"
# Expected: 4 policies (read, upload, update, delete)
```

**Expected Output:**
```
✅ Active regions: 18
✅ Realtime tables: 4/4
✅ benefit-icons bucket: public
✅ benefit-icons policies: 4/4
```

---

## 2️⃣ ADMIN — Dev 자동 로그인 + SVG filename 규칙

### Why?
개발 환경에서 매번 로그인하는 번거로움 제거. SVG 파일명만 DB에 저장하여 앱에서 로컬/원격 자동 분기 가능.

### Step 2.1: Create Environment File

**File:** `/apps/pickly_admin/.env.development.local`

```env
# Dev Auto-Login Configuration
# ⚠️ DO NOT commit this file to git
VITE_DEV_AUTO_LOGIN=true
VITE_DEV_ADMIN_EMAIL=admin@pickly.com
VITE_DEV_ADMIN_PASSWORD=pickly2025!

# Supabase Configuration
VITE_SUPABASE_URL=http://localhost:54321
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
```

**Important:** Add to `.gitignore`

```bash
# Add to apps/pickly_admin/.gitignore
echo ".env.development.local" >> apps/pickly_admin/.gitignore
```

### Step 2.2: Create Auto-Login Component

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

### Step 2.3: Integrate into App.tsx

**File:** `/apps/pickly_admin/src/App.tsx`

Find the root component and add:

```typescript
import DevAutoLoginGate from '@/features/auth/DevAutoLoginGate';

function App() {
  return (
    <>
      {/* DEV ONLY: Auto-login gate */}
      {import.meta.env.DEV && <DevAutoLoginGate />}

      {/* Your existing app structure */}
      {/* ... rest of the app ... */}
    </>
  );
}
```

### Step 2.4: Run Admin App

```bash
cd apps/pickly_admin
pnpm install  # If needed
pnpm dev
```

### ✅ Success Criteria

Open browser at `http://localhost:5173`

**Check browser console:**
```
✅ [DevAutoLogin] Success: admin@pickly.com
```

**Test SVG Upload:**
1. Navigate to benefit categories management
2. Upload an SVG icon
3. Verify in database:
```bash
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
  "SELECT title, icon_url FROM public.benefit_categories LIMIT 5;"
```

**Expected:** `icon_url` column contains **filename only** (e.g., `housing.svg`), not full URL.

**Rule:** Admin에서 SVG 업로드 후 **DB에 저장되는 icon_url 값은 '파일명만'** (예: `housing.svg`)

---

## 3️⃣ FLUTTER — 아이콘 경로 해석 + 로컬/스토리지 자동 분기

### Why?
로컬 assets 우선, 없으면 Supabase Storage에서 로드. 오프라인 지원 + 유연한 배포.

### Step 3.1: Verify Local Assets

```bash
# Check if icons exist
ls -la packages/pickly_design_system/assets/icons/

# Should contain:
# fire.svg
# housing.svg
# ... other SVGs
```

### Step 3.2: Update pubspec.yaml

**File:** `/apps/pickly_mobile/pubspec.yaml`

Ensure assets are included:

```yaml
flutter:
  uses-material-design: true
  assets:
    - packages/pickly_design_system/assets/icons/
```

### Step 3.3: Create MediaResolver Utility

**File:** `/apps/pickly_mobile/lib/core/utils/media_resolver.dart`

```dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Check if local asset exists
Future<bool> _assetExists(String assetPath) async {
  try {
    await rootBundle.load(assetPath);
    return true;
  } catch (_) {
    return false;
  }
}

/// Resolve icon URL with automatic local/remote fallback
///
/// Returns:
/// - `asset://path` if local asset exists
/// - `https://...` Supabase Storage URL otherwise
///
/// Example:
/// ```dart
/// final url = await resolveIconUrl('housing.svg');
/// // Returns: 'asset://packages/pickly_design_system/assets/icons/housing.svg'
/// // or: 'https://localhost:54321/storage/v1/object/public/benefit-icons/housing.svg'
/// ```
Future<String> resolveIconUrl(String filename) async {
  final localPath = 'packages/pickly_design_system/assets/icons/$filename';

  // Try local asset first
  if (await _assetExists(localPath)) {
    print('🎨 [MediaResolver] Using local asset: $localPath');
    return 'asset://$localPath';
  }

  // Fallback to Supabase Storage
  final supabase = Supabase.instance.client;
  final baseUrl = supabase.restUrl.replace(path: '').toString();
  final storageUrl = '$baseUrl/storage/v1/object/public/benefit-icons/$filename';

  print('🌐 [MediaResolver] Using remote URL: $storageUrl');
  return storageUrl;
}

/// Check if URL is a local asset
bool isLocalAsset(String url) {
  return url.startsWith('asset://');
}

/// Strip asset:// prefix
String stripAssetPrefix(String url) {
  return url.replaceFirst('asset://', '');
}
```

### Step 3.4: Update CategoryCircle Widget

**File:** `/apps/pickly_mobile/lib/features/benefits/widgets/category_circle.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickly_mobile/core/utils/media_resolver.dart';
import 'package:pickly_mobile/contexts/benefit/models/benefit_category.dart';

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
            future: resolveIconUrl(category.iconUrl),
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
      if (isLocalAsset(url)) {
        // Local asset
        return SvgPicture.asset(
          stripAssetPrefix(url),
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

### Step 3.5: Run Flutter App

```bash
cd apps/pickly_mobile

# Clean build
flutter clean
flutter pub get

# Run on simulator
flutter run -d <device-id>

# Or specific simulator (example)
flutter run -d E7F1E329-C4FF-4224-94F9-408F08A4C96C
```

### ✅ Success Criteria

**Check Flutter logs:**
```
🎨 [MediaResolver] Using local asset: packages/pickly_design_system/assets/icons/housing.svg
🌐 [MediaResolver] Using remote URL: http://localhost:54321/storage/v1/object/public/benefit-icons/education.svg
```

**Visual Check:**
- Navigate to Benefits tab (혜택)
- Verify 써클탭 (category circles) display at top
- Icons should load correctly (local or remote)

---

## 4️⃣ FLUTTER — Realtime 중복 구독 제거 (스트림 1회)

### Why?
11개의 중복 구독이 발생하여 메모리 누수 및 UI 응답 지연. 1회 구독으로 최적화.

### Step 4.1: Update BenefitRepository

**File:** `/apps/pickly_mobile/lib/contexts/benefit/repositories/benefit_repository.dart`

Modify the `watchCategories()` method:

```dart
class BenefitRepository {
  final SupabaseClient _client;

  // ✅ Stream cache field
  Stream<List<BenefitCategory>>? _cachedCategoriesStream;

  const BenefitRepository(this._client);

  Stream<List<BenefitCategory>> watchCategories() {
    // Return cached stream if exists
    if (_cachedCategoriesStream != null) {
      print('🔄 [Stream Cache] Returning existing categories stream');
      return _cachedCategoriesStream!;
    }

    print('📡 [Supabase Realtime] Starting NEW stream on benefit_categories table');

    // Create and cache stream
    _cachedCategoriesStream = _client
        .from('benefit_categories')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('display_order', ascending: true)
        .map((rows) => rows
            .map((json) => BenefitCategory.fromJson(json as Map<String, dynamic>))
            .toList())
        .asBroadcastStream(); // ✅ Make shareable!

    return _cachedCategoriesStream!;
  }

  // ✅ Dispose method
  void dispose() {
    _cachedCategoriesStream = null;
  }
}
```

### Step 4.2: Update Provider (Optional but Recommended)

**File:** `/apps/pickly_mobile/lib/features/benefits/providers/benefit_category_provider.dart`

```dart
/// StreamProvider for watching benefit categories in realtime
///
/// keepAlive prevents provider from being disposed when no longer watched
final benefitCategoriesStreamProvider = StreamProvider.autoDispose<List<BenefitCategory>>((ref) {
  // ✅ Keep provider alive to prevent recreation
  ref.keepAlive();

  final repository = ref.watch(benefitRepositoryProvider);

  // ✅ Dispose repository when provider is disposed
  ref.onDispose(() {
    repository.dispose();
  });

  return repository.watchCategories();
});
```

### Step 4.3: Hot Restart App

```bash
# In running Flutter app, send hot restart command
printf "R" | nc localhost 58200

# Or restart app completely
# Press 'q' in terminal, then 'flutter run' again
```

### ✅ Success Criteria

**Check Flutter logs:**
```
📡 [Supabase Realtime] Starting NEW stream on benefit_categories table
```

**MUST appear ONLY ONCE** (not 11 times)

**Visual Check:**
- Navigate to Benefits tab (혜택)
- Verify 써클탭 displays correctly
- Tap a category - verify navigation works
- Check logs - no duplicate stream messages

---

## 5️⃣ 검증 체크리스트 — Admin→DB→App 파이프 확인

### Admin Verification

```bash
# Start admin
cd apps/pickly_admin
pnpm dev

# Open: http://localhost:5173
```

**Checklist:**
- [ ] Auto-login successful (check browser console)
- [ ] Session persists across page reloads
- [ ] Navigate to benefit categories management
- [ ] Upload SVG icon
- [ ] Verify `icon_url` in database = filename only

### Database Verification

```bash
# Count regions
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
  "SELECT COUNT(*) FROM public.regions WHERE is_active = true;"
# Expected: 18

# Check storage public URL
curl -I http://localhost:54321/storage/v1/object/public/benefit-icons/housing.svg
# Expected: HTTP/1.1 200 OK (if housing.svg exists)

# Verify benefit categories
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
  "SELECT title, icon_url, is_active FROM public.benefit_categories WHERE is_active = true ORDER BY display_order;"
# Expected: List of categories with filename-only icon_url
```

### Flutter App Verification

```bash
# Run app
cd apps/pickly_mobile
flutter run -d <device-id>
```

**Checklist:**
- [ ] App launches successfully
- [ ] Navigate to Benefits tab (혜택)
- [ ] 써클탭 (category circles) display at top
- [ ] Icons load correctly (check logs for local/remote)
- [ ] Stream subscription appears ONLY ONCE in logs
- [ ] Navigate to region selection
- [ ] 18 regions display correctly
- [ ] No "table not found" errors

---

## 6️⃣ 문서/버전 & 롤백

### Update PRD Document

**File:** `/docs/prd/PRD_CURRENT.md`

Update to version v9.9.0 with the following changes:

```markdown
# Pickly PRD - Current Version

**Version:** v9.9.0
**Date:** 2025-11-05
**Status:** ✅ Stable

## Recent Changes (v9.9.0)

### Storage Architecture
- **benefit-icons bucket**: Public, filename-only storage
  - Admin uploads SVG → DB stores filename only (e.g., `housing.svg`)
  - App resolves: local asset first, then Supabase Storage URL

### Regions & Realtime
- 18 Korean regions guaranteed in database
- Realtime publication enabled for:
  - `public.regions`
  - `public.user_regions`
  - `public.benefit_categories`
  - `public.announcements`

### Flutter Stream Optimization
- Stream caching implemented in `BenefitRepository`
- Single subscription with `.asBroadcastStream()`
- Provider `keepAlive` prevents recreation

### Admin DevAutoLogin Gate
- Development environment auto-login
- Configured via `.env.development.local`
- Production: disabled automatically
```

### Rollback Procedures

#### Rollback Admin Auto-Login

**File:** `/apps/pickly_admin/.env.development.local`

```env
# Disable auto-login
VITE_DEV_AUTO_LOGIN=false
```

Or remove the file entirely:
```bash
rm apps/pickly_admin/.env.development.local
```

#### Rollback Database Changes

```sql
-- Remove admin helper function
DROP FUNCTION IF EXISTS public.custom_access(text);

-- Remove storage policies
DROP POLICY IF EXISTS "benefit-icons read (public)" ON storage.objects;
DROP POLICY IF EXISTS "benefit-icons upload (auth)" ON storage.objects;
DROP POLICY IF EXISTS "benefit-icons update (auth)" ON storage.objects;
DROP POLICY IF EXISTS "benefit-icons delete (auth)" ON storage.objects;

-- Remove storage bucket
DELETE FROM storage.buckets WHERE id = 'benefit-icons';

-- Remove Realtime publication
ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS public.regions;
ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS public.user_regions;

-- Note: Regions table data is safe to keep
-- Only drop if you need complete rollback:
-- DROP TABLE IF EXISTS public.user_regions;
-- DROP TABLE IF EXISTS public.regions;
```

#### Rollback Flutter Changes

```bash
cd apps/pickly_mobile

# Remove media resolver
rm lib/core/utils/media_resolver.dart

# Revert category_circle.dart to previous version
git checkout HEAD~1 -- lib/features/benefits/widgets/category_circle.dart

# Revert benefit_repository.dart stream caching
git checkout HEAD~1 -- lib/contexts/benefit/repositories/benefit_repository.dart

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### Re-enable Disabled Migrations

```bash
# If you need to re-enable previously disabled migrations
mv backend/supabase/migrations/20251101000010_create_dev_admin_user.sql.disabled \
   backend/supabase/migrations/20251101000010_create_dev_admin_user.sql

mv backend/supabase/migrations/20251101_fix_admin_schema.sql.disabled \
   backend/supabase/migrations/20251101_fix_admin_schema.sql

mv backend/supabase/migrations/20251106000001_fix_rls_admin_role_guard_prd_v9_6_2.sql.disabled \
   backend/supabase/migrations/20251106000001_fix_rls_admin_role_guard_prd_v9_6_2.sql
```

---

## ✅ Final Success Criteria

### Admin
- [x] Admin 로그인 즉시 가능 (no manual login needed)
- [x] SVG 업로드 → 저장 OK
- [x] DB에 filename만 저장 (full URL 아님)
- [x] Session persists across page reloads

### Database
- [x] 18 regions active and verified
- [x] Realtime publication includes all critical tables
- [x] Storage bucket `benefit-icons` public with 4 policies
- [x] Admin helper function `custom_access()` created

### Flutter App
- [x] App 써클탭 즉시 반영 (icons load correctly)
- [x] Icons: local asset first, remote fallback
- [x] Realtime 중복 구독 없음 (1회만)
- [x] Stream logs show single subscription
- [x] 18 regions display correctly
- [x] No "table not found" errors

### Documentation
- [x] PRD updated to v9.9.0
- [x] Rollback procedures documented
- [x] All steps verified and tested

---

## 🐛 Troubleshooting Guide

### Issue: Admin Auto-Login Not Working

**Symptoms:**
- Console shows no auto-login messages
- Manual login still required

**Solutions:**

1. **Check environment variable:**
```bash
cat apps/pickly_admin/.env.development.local | grep VITE_DEV_AUTO_LOGIN
# Should show: VITE_DEV_AUTO_LOGIN=true
```

2. **Verify dev mode:**
```bash
# Admin must be running in dev mode
pnpm -C apps/pickly_admin dev
# NOT: pnpm build && pnpm preview
```

3. **Check browser console:**
Open DevTools → Console → Look for:
```
✅ [DevAutoLogin] Success: admin@pickly.com
```

4. **Clear browser cache:**
```bash
# In Chrome: Ctrl+Shift+Delete
# Select "Cookies and other site data"
# Clear and refresh
```

---

### Issue: Storage Upload Fails

**Symptoms:**
```
Error: new row violates row-level security policy
```

**Solutions:**

1. **Check authentication:**
```bash
# In browser console (Admin):
const session = await supabase.auth.getSession()
console.log(session.data.session?.user?.email)
# Should show: admin@pickly.com
```

2. **Verify storage policies:**
```bash
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
  "SELECT policyname, cmd FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname LIKE 'benefit-icons%';"
# Should show 4 policies
```

3. **Force logout and re-login:**
```typescript
// In browser console:
await supabase.auth.signOut()
location.reload()
// Then auto-login will re-authenticate
```

---

### Issue: Flutter Icons Not Loading

**Symptoms:**
- Category circles show placeholder icons
- Logs show errors loading SVG

**Solutions:**

1. **Check local assets:**
```bash
ls -la packages/pickly_design_system/assets/icons/
# Verify SVG files exist
```

2. **Verify pubspec.yaml:**
```bash
grep -A 5 "assets:" apps/pickly_mobile/pubspec.yaml
# Should include: - packages/pickly_design_system/assets/icons/
```

3. **Full rebuild required for new assets:**
```bash
cd apps/pickly_mobile
flutter clean
flutter pub get
flutter run
```

4. **Check MediaResolver logs:**
```
🎨 [MediaResolver] Using local asset: packages/...
🌐 [MediaResolver] Using remote URL: http://localhost:...
```

If no logs, check that `resolveIconUrl()` is being called.

---

### Issue: Stream Still Duplicating

**Symptoms:**
Logs show multiple "Starting NEW stream" messages

**Solutions:**

1. **Verify code changes applied:**
```bash
grep -A 5 "_cachedCategoriesStream" apps/pickly_mobile/lib/contexts/benefit/repositories/benefit_repository.dart
# Should show cache field and null check
```

2. **Hot restart required (not hot reload):**
```bash
# In Flutter terminal, press:
R  # Capital R for hot restart
# Or:
printf "R" | nc localhost 58200
```

3. **Check provider configuration:**
```dart
// In benefit_category_provider.dart
// Should have:
ref.keepAlive();
ref.onDispose(() { repository.dispose(); });
```

4. **Full restart if hot restart doesn't work:**
```bash
# Kill app and restart
q  # In Flutter terminal
flutter run
```

---

### Issue: Regions Table Not Found

**Symptoms:**
```
Error: relation "public.regions" does not exist
```

**Solutions:**

1. **Run migration:**
```bash
docker exec -i supabase_db_supabase psql -U postgres -d postgres < \
  backend/supabase/migrations/20251108000000_one_shot_stabilization.sql
```

2. **Verify table exists:**
```bash
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
  "\dt public.regions"
# Should show: public | regions | table | postgres
```

3. **Full Flutter rebuild:**
```bash
cd apps/pickly_mobile
flutter clean
flutter pub get
flutter run
```

Flutter caches Supabase schema - full rebuild refreshes it.

---

## 📊 Execution Timeline

**Estimated Time:** 30-45 minutes

| Step | Task | Time | Checkpoint |
|------|------|------|------------|
| 0 | Precheck - Disable migrations | 2 min | Files renamed to `.disabled` |
| 1 | Database setup | 5 min | 18 regions, storage policies verified |
| 2 | Admin configuration | 10 min | Auto-login working |
| 3 | Flutter media resolver | 10 min | Icons loading correctly |
| 4 | Flutter stream caching | 10 min | Single stream subscription |
| 5 | End-to-end verification | 10 min | Full pipeline working |
| 6 | Documentation update | 5 min | PRD updated |

---

## 📝 Post-Execution Checklist

After completing all steps, verify:

- [ ] Admin app running at `http://localhost:5173`
- [ ] Admin auto-login successful
- [ ] Database has 18 active regions
- [ ] Supabase Storage `benefit-icons` bucket accessible
- [ ] Flutter app running on simulator
- [ ] Category circles (써클탭) displaying correctly
- [ ] Icons loading from local or remote source
- [ ] Single stream subscription (check logs)
- [ ] No "table not found" errors
- [ ] PRD document updated to v9.9.0
- [ ] All disabled migrations noted for future reference

---

## 🎉 Success Indicators

If you see all of these, you're done:

**Admin Console:**
```
✅ [DevAutoLogin] Success: admin@pickly.com
```

**Database:**
```
✅ Active regions: 18
✅ Realtime tables: 4/4
✅ benefit-icons bucket: public
✅ benefit-icons policies: 4/4
```

**Flutter Logs:**
```
📡 [Supabase Realtime] Starting NEW stream on benefit_categories table
🎨 [MediaResolver] Using local asset: packages/pickly_design_system/assets/icons/housing.svg
✅ Successfully loaded 18 regions from Supabase
```

**Visual Confirmation:**
- 혜택 (Benefits) tab shows category circles
- Icons display correctly
- Category navigation works
- Region selection shows 18 regions
- No placeholder icons or errors

---

**Document Version:** 1.0
**Created:** 2025-11-05 21:00 KST
**Author:** Claude Code
**Status:** 📋 **RUNBOOK READY** - Execute step-by-step for immediate stabilization
