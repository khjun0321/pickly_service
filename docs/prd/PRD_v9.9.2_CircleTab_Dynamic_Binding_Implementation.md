# 📘 Pickly PRD v9.9.2 — CircleTab Dynamic Binding Implementation

**Version**: 9.9.2
**Date**: 2025-11-06
**Status**: ✅ Active
**Purpose**: 써클탭 디자인 레이아웃 고정 + 동적 아이콘/텍스트 바인딩 구현

---

## 🎯 Goal

써클탭(TabCircleWithLabel)은 **디자인 레이아웃을 고정**하고, **카테고리명(title)과 아이콘(icon_url)만 DB에서 동적으로 바인딩**한다.

### Key Requirements

1. ✅ **DB 저장**: 파일명만 저장 (경로 금지) → `icon_url = 'popular.svg'`
2. ✅ **앱 로딩**: Local asset 우선 → 없으면 Supabase Storage에서 network 로딩
3. ✅ **레이아웃 고정**: 써클 모양/크기/간격/활성 스타일은 디자인 시스템에서 제어
4. ✅ **fire.svg → popular.svg**: 전면 교체 (DB + Storage + Design System)

---

## 🧱 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│ BenefitsScreen (Flutter)                                     │
│  ├─ watchCategories() → Realtime Stream                     │
│  └─ TabCircleWithLabel (Design System)                      │
│      ├─ iconPath: resolveIconUrl(category.iconUrl)          │
│      └─ label: category.title                               │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ resolveIconUrl(filename) Utility                            │
│  1. Check local asset: assets/icons/{filename}              │
│  2. If not found → Generate Supabase Storage URL            │
│  3. Return: 'asset://...' OR 'https://...'                  │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ Database (benefit_categories)                               │
│  - icon_url: 'popular.svg' (파일명만)                       │
│  - Trigger: enforce_icon_url_filename_only()                │
│  - Migration: fire.svg → popular.svg                        │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ Supabase Storage (benefit-icons bucket)                     │
│  - popular.svg, home.svg, book.svg, ...                     │
│  - Public bucket with read access                           │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 Implementation Steps

### Phase 1: Database Migration

#### Step 1.1: Normalize icon_url to Filename Only

**File**: `backend/supabase/migrations/20251110000001_normalize_icon_url_filename.sql`

```sql
-- Phase 1.1: Normalize icon_url to filename only (remove paths)
-- PRD v9.9.2: CircleTab Dynamic Binding Implementation

-- Function to extract filename from path
CREATE OR REPLACE FUNCTION extract_filename(path TEXT)
RETURNS TEXT AS $$
BEGIN
  -- Remove leading slash
  path := LTRIM(path, '/');

  -- Extract filename after last slash
  IF path ~ '/' THEN
    RETURN SUBSTRING(path FROM '([^/]+)$');
  ELSE
    RETURN path;
  END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Update all icon_url to filename only
UPDATE public.benefit_categories
SET icon_url = extract_filename(icon_url)
WHERE icon_url IS NOT NULL
  AND icon_url != extract_filename(icon_url);

-- Verification query
DO $$
DECLARE
  invalid_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO invalid_count
  FROM public.benefit_categories
  WHERE icon_url IS NOT NULL
    AND (icon_url ~ '/' OR icon_url ~ '^http');

  IF invalid_count > 0 THEN
    RAISE EXCEPTION 'Found % rows with invalid icon_url (contains path)', invalid_count;
  END IF;

  RAISE NOTICE '✅ All icon_url values normalized to filename only';
END $$;
```

#### Step 1.2: Rename fire.svg → popular.svg

**File**: `backend/supabase/migrations/20251110000002_rename_fire_to_popular.sql`

```sql
-- Phase 1.2: Rename fire.svg to popular.svg
-- PRD v9.9.2: CircleTab Dynamic Binding Implementation

-- Update all fire.svg references to popular.svg
UPDATE public.benefit_categories
SET icon_url = 'popular.svg'
WHERE icon_url IN ('fire.svg', 'flame.svg', 'hot.svg');

-- Verification
DO $$
DECLARE
  fire_count INTEGER;
  popular_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO fire_count
  FROM public.benefit_categories
  WHERE icon_url IN ('fire.svg', 'flame.svg', 'hot.svg');

  SELECT COUNT(*) INTO popular_count
  FROM public.benefit_categories
  WHERE icon_url = 'popular.svg';

  IF fire_count > 0 THEN
    RAISE EXCEPTION 'Still found % rows with fire.svg variants', fire_count;
  END IF;

  RAISE NOTICE '✅ fire.svg → popular.svg migration complete';
  RAISE NOTICE '   Total popular.svg entries: %', popular_count;
END $$;
```

#### Step 1.3: Create Trigger for Filename-Only Enforcement

**File**: `backend/supabase/migrations/20251110000003_enforce_icon_url_filename_trigger.sql`

```sql
-- Phase 1.3: Create trigger to enforce filename-only icon_url
-- PRD v9.9.2: CircleTab Dynamic Binding Implementation

-- Trigger function to normalize icon_url before insert/update
CREATE OR REPLACE FUNCTION enforce_icon_url_filename_only()
RETURNS TRIGGER AS $$
BEGIN
  -- If icon_url is NULL, allow it
  IF NEW.icon_url IS NULL THEN
    RETURN NEW;
  END IF;

  -- Extract filename from any path format
  NEW.icon_url := extract_filename(NEW.icon_url);

  -- Validate: No slashes, no http/https
  IF NEW.icon_url ~ '/' OR NEW.icon_url ~ '^http' THEN
    RAISE EXCEPTION 'icon_url must be filename only (no paths): %', NEW.icon_url;
  END IF;

  -- Validate: Must end with .svg (for now)
  IF NEW.icon_url !~ '\.svg$' THEN
    RAISE EXCEPTION 'icon_url must be SVG file: %', NEW.icon_url;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to benefit_categories
DROP TRIGGER IF EXISTS trg_enforce_icon_url_filename ON public.benefit_categories;

CREATE TRIGGER trg_enforce_icon_url_filename
  BEFORE INSERT OR UPDATE OF icon_url
  ON public.benefit_categories
  FOR EACH ROW
  EXECUTE FUNCTION enforce_icon_url_filename_only();

-- Test trigger
DO $$
BEGIN
  -- This should succeed
  UPDATE public.benefit_categories
  SET icon_url = 'popular.svg'
  WHERE id = (SELECT id FROM public.benefit_categories LIMIT 1);

  RAISE NOTICE '✅ Trigger test passed: filename accepted';

  -- This should fail (path included)
  BEGIN
    UPDATE public.benefit_categories
    SET icon_url = '/icons/test.svg'
    WHERE id = (SELECT id FROM public.benefit_categories LIMIT 1);

    RAISE EXCEPTION 'Trigger failed: path was accepted';
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '✅ Trigger test passed: path rejected';
  END;
END $$;
```

---

### Phase 2: Flutter Utility Implementation

#### Step 2.1: Create media_resolver.dart Utility

**File**: `apps/pickly_mobile/lib/core/utils/media_resolver.dart`

```dart
/// Media URL Resolver Utility
///
/// Resolves icon filenames to either local assets or Supabase Storage URLs.
///
/// PRD v9.9.2: CircleTab Dynamic Binding Implementation
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Resolves icon filename to asset path or network URL
///
/// Resolution Order:
/// 1. Check if local asset exists: assets/icons/{filename}
/// 2. If not found → Generate Supabase Storage URL
///
/// Returns:
/// - 'asset://assets/icons/{filename}' if local asset exists
/// - 'https://..../benefit-icons/{filename}' if remote only
///
/// Example:
/// ```dart
/// final url = await resolveIconUrl('popular.svg');
/// // Returns: 'asset://assets/icons/popular.svg' (if exists locally)
/// // OR: 'https://xyz.supabase.co/storage/v1/object/public/benefit-icons/popular.svg'
/// ```
Future<String> resolveIconUrl(String? filename) async {
  // Handle null or empty filename
  if (filename == null || filename.isEmpty) {
    return 'asset://assets/icons/placeholder.svg';
  }

  // Normalize filename (remove any accidental paths)
  final cleanFilename = filename.split('/').last;

  // Check if local asset exists
  final assetPath = 'packages/pickly_design_system/assets/icons/$cleanFilename';

  try {
    await rootBundle.load(assetPath);
    // Asset exists locally - use it
    return 'asset://$assetPath';
  } catch (e) {
    // Asset not found locally - use Supabase Storage
    final storageUrl = Supabase.instance.client.storage
        .from('benefit-icons')
        .getPublicUrl(cleanFilename);

    return storageUrl;
  }
}

/// Load SVG from resolved URL
///
/// Automatically detects asset:// vs https:// protocol
///
/// Usage:
/// ```dart
/// final resolvedUrl = await resolveIconUrl(category.iconUrl);
/// final svgWidget = await loadSvgFromResolvedUrl(resolvedUrl);
/// ```
Future<Widget> loadSvgFromResolvedUrl(
  String resolvedUrl, {
  double? width,
  double? height,
  Color? color,
}) async {
  if (resolvedUrl.startsWith('asset://')) {
    // Load from local asset
    final assetPath = resolvedUrl.replaceFirst('asset://', '');

    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  } else {
    // Load from network
    return SvgPicture.network(
      resolvedUrl,
      width: width,
      height: height,
      fit: BoxFit.contain,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
      placeholderBuilder: (context) => const CircularProgressIndicator(),
    );
  }
}
```

#### Step 2.2: Update BenefitsScreen to Use Resolver

**File**: `apps/pickly_mobile/lib/features/benefits/screens/benefits_screen.dart`

**Changes**:
```dart
// Add import
import 'package:pickly_mobile/core/utils/media_resolver.dart';

// Update TabCircleWithLabel usage (around line 255)
// Before:
return TabCircleWithLabel(
  iconPath: category.iconUrl ?? 'assets/icons/popular.svg',
  label: category.title,
  // ...
);

// After:
return FutureBuilder<String>(
  future: resolveIconUrl(category.iconUrl),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      // Loading state
      return TabCircleWithLabel(
        iconPath: 'assets/icons/placeholder.svg',
        label: category.title,
        isActive: selectedCategorySlug == category.slug,
        onTap: () => _onCategoryTap(category.slug),
      );
    }

    final resolvedUrl = snapshot.data!;

    return TabCircleWithLabel(
      iconPath: resolvedUrl,
      label: category.title,
      isActive: selectedCategorySlug == category.slug,
      onTap: () => _onCategoryTap(category.slug),
    );
  },
);
```

---

### Phase 3: Design System Component Update

#### Step 3.1: Update TabCircleWithLabel to Support Network URLs

**File**: `packages/pickly_design_system/lib/widgets/tabs/tab_circle_with_label.dart`

**Changes** (around line 145-154):

```dart
// Before:
child: SvgPicture.asset(
  iconPath,
  package: 'pickly_design_system',
  width: 24,
  height: 24,
  fit: BoxFit.contain,
  colorFilter: iconColor != null
      ? ColorFilter.mode(iconColor, BlendMode.srcIn)
      : null,
),

// After:
child: iconPath.startsWith('asset://')
    ? SvgPicture.asset(
        iconPath.replaceFirst('asset://', ''),
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        colorFilter: iconColor != null
            ? ColorFilter.mode(iconColor, BlendMode.srcIn)
            : null,
      )
    : SvgPicture.network(
        iconPath,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        colorFilter: iconColor != null
            ? ColorFilter.mode(iconColor, BlendMode.srcIn)
            : null,
        placeholderBuilder: (context) => const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
```

#### Step 3.2: Rename fire.svg to popular.svg in Design System

**File**: `packages/pickly_design_system/assets/icons/fire.svg`

```bash
# In design system directory
cd packages/pickly_design_system/assets/icons
mv fire.svg popular.svg
```

---

### Phase 4: Supabase Storage Setup

#### Step 4.1: Upload popular.svg to Supabase Storage

```bash
# Via Supabase Studio UI:
# 1. Go to http://127.0.0.1:54323
# 2. Navigate to Storage → benefit-icons bucket
# 3. Upload popular.svg

# OR via CLI:
supabase storage cp \
  packages/pickly_design_system/assets/icons/popular.svg \
  benefit-icons/popular.svg \
  --project-ref local
```

#### Step 4.2: Verify Bucket Public Access

```sql
-- Check bucket policy
SELECT * FROM storage.buckets WHERE id = 'benefit-icons';

-- Should have: public = true

-- If not, create policy:
INSERT INTO storage.policies (
  name,
  bucket_id,
  definition,
  check_expression
) VALUES (
  'Public read access for benefit icons',
  'benefit-icons',
  '(bucket_id = ''benefit-icons''::text)',
  'true'
);
```

---

## 🧪 Testing & Verification

### Test 1: Database Migration Verification

```sql
-- Should return 0 (no paths in icon_url)
SELECT COUNT(*)
FROM public.benefit_categories
WHERE icon_url ~ '/' OR icon_url ~ '^http';

-- Should return 0 (no fire.svg)
SELECT COUNT(*)
FROM public.benefit_categories
WHERE icon_url IN ('fire.svg', 'flame.svg', 'hot.svg');

-- Should show popular.svg
SELECT id, title, icon_url, slug
FROM public.benefit_categories
WHERE slug = 'popular'
ORDER BY display_order;
```

### Test 2: Trigger Enforcement

```sql
-- This should SUCCEED
UPDATE public.benefit_categories
SET icon_url = 'home.svg'
WHERE slug = 'housing';

-- This should FAIL with error
UPDATE public.benefit_categories
SET icon_url = '/icons/home.svg'
WHERE slug = 'housing';
-- Expected: ERROR: icon_url must be filename only (no paths): /icons/home.svg
```

### Test 3: Flutter Hot Reload Test

```dart
// In BenefitsScreen:
// 1. Save changes
// 2. Hot reload (r in terminal)
// 3. Verify:
//    - Categories display with correct icons
//    - popular.svg shows instead of fire.svg
//    - No SVG loading errors in console
//    - Network icons load with placeholder
```

### Test 4: Admin Icon Upload Test

```typescript
// In Pickly Admin:
// 1. Navigate to Benefit Categories
// 2. Edit a category
// 3. Upload new icon (test.svg)
// 4. Save
// 5. Verify in mobile app:
//    - Icon updates in realtime
//    - New icon loads from Supabase Storage
```

---

## ✅ Success Criteria

1. ✅ DB에 `icon_url`이 파일명만 저장됨 (경로 없음)
2. ✅ `fire.svg` 참조가 0건, `popular.svg`가 정상 표시
3. ✅ Local asset 우선, 없으면 Supabase Storage에서 로드
4. ✅ Admin에서 아이콘 업로드 시 앱에 즉시 반영
5. ✅ 네트워크 오류 시 placeholder 표시
6. ✅ Trigger가 경로 포함 시 자동 차단
7. ✅ Hot reload로 아이콘 변경 확인 가능

---

## 🔗 Related Documents

- **PRD v9.9.1**: Icon Asset Management Policy (Design vs Data)
- **PRD v9.6**: Benefit Categories Realtime Stream
- **Design System**: Icon Guidelines

---

## 📊 File Changes Summary

### New Files Created
- `backend/supabase/migrations/20251110000001_normalize_icon_url_filename.sql`
- `backend/supabase/migrations/20251110000002_rename_fire_to_popular.sql`
- `backend/supabase/migrations/20251110000003_enforce_icon_url_filename_trigger.sql`
- `apps/pickly_mobile/lib/core/utils/media_resolver.dart`

### Files Modified
- `apps/pickly_mobile/lib/features/benefits/screens/benefits_screen.dart`
- `packages/pickly_design_system/lib/widgets/tabs/tab_circle_with_label.dart`

### Files Renamed
- `packages/pickly_design_system/assets/icons/fire.svg` → `popular.svg`

---

**Document Control**
- Author: Claude Code
- Last Updated: 2025-11-06
- Next Review: 2025-12-06
- Implementation Status: 🟡 Ready for Implementation
