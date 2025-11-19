# Phase 6.3 Task — Fix Realtime Sync & Regions Dependency (PRD v9.8.2)

**Date:** 2025-11-07
**Version:** PRD v9.8.2 (Phase 6.3)
**Priority:** 🔴 **CRITICAL**
**Status:** 📋 **READY TO START**

---

## 🎯 Objective

Fix critical issues preventing benefit categories (써클탭) from displaying in the Flutter app:

1. **Missing `regions` table** - App crashes on onboarding region selection screen
2. **Multiple Realtime subscriptions** - benefit_categories stream creating duplicate subscriptions
3. **Missing SVG assets** - fire.svg asset not found in design system

---

## 🚨 Current Issues Detected

### Issue #1: Missing `public.regions` Table ❌

**Error in Simulator:**
```
RegionException: Database error: Could not find the table 'public.regions' in the schema cache
Stack trace: #0 RegionRepository.fetchActiveRegions (region_repository.dart:37:7)
```

**Impact:**
- Onboarding flow falls back to mock data
- User cannot select actual regions
- Region-based filtering unavailable

**Root Cause:**
- `regions` table was never created in migration
- Flutter app expects `regions` table with specific schema
- RegionRepository has proper implementation but no database table

### Issue #2: Multiple Realtime Subscriptions ⚠️

**Error in Simulator:**
```
🌊 [Stream Provider] Starting benefit categories stream
🌊 [BenefitRepository] Creating watchCategories() stream subscription
📡 [Supabase Realtime] Starting stream on benefit_categories table
⚠️ [Categories Stream] No data available (loading or error)
```

**Pattern Detected:**
- Stream subscription created 11+ times in logs
- No data received despite categories existing in database
- Possible memory leak from unclosed subscriptions

**Root Cause Analysis Needed:**
- Provider rebuilding excessively?
- StreamProvider not properly disposing?
- Realtime channel not cleaning up?

### Issue #3: Missing SVG Asset 📦

**Error in Simulator:**
```
[ERROR] Unhandled Exception: Unable to load asset:
"packages/pickly_design_system/assets/icons/fire.svg"
The asset does not exist or has empty data.
```

**Impact:**
- Category icons fail to render
- User experience degraded

**Note:** This is a design system issue, NOT a backend/database issue. Lower priority.

---

## 📘 References

### Documentation:
- `/docs/prd/PRD_CURRENT.md` (v9.8.1)
- `/docs/PHASE6_2_ADMIN_UI_COMPLETE.md`
- `/apps/pickly_admin/src/pages/api-mapping/MappingSimulatorPage.tsx`

### Flutter App Files:
- `/apps/pickly_mobile/lib/contexts/user/repositories/region_repository.dart`
- `/apps/pickly_mobile/lib/contexts/user/models/region.dart`
- `/apps/pickly_mobile/lib/features/onboarding/providers/region_provider.dart`
- `/apps/pickly_mobile/lib/contexts/benefit/repositories/benefit_repository.dart`
- `/apps/pickly_mobile/lib/features/benefits/providers/benefit_categories_provider.dart`

### Database:
- Supabase tables: `benefit_categories`, `regions` (missing), `user_regions` (dependency)
- Current active categories: 10 (verified in previous session)

---

## 🧱 Implementation Plan

### Step 1: Create `regions` Table ✅

**Migration File:** `backend/supabase/migrations/20251107000001_create_regions_table.sql`

**Schema Definition:**
```sql
-- Create regions table for Korean regional data
CREATE TABLE IF NOT EXISTS public.regions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text UNIQUE NOT NULL, -- e.g., 'SEOUL', 'GYEONGGI'
  name text NOT NULL, -- e.g., '서울', '경기'
  sort_order integer NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Create index for common queries
CREATE INDEX IF NOT EXISTS idx_regions_active_sort
ON public.regions (is_active, sort_order)
WHERE is_active = true;

-- Create index for code lookup
CREATE INDEX IF NOT EXISTS idx_regions_code
ON public.regions (code);

-- Enable Row Level Security (disabled per PRD v9.7.0)
ALTER TABLE public.regions ENABLE ROW LEVEL SECURITY;

-- Create policy allowing public read access
CREATE POLICY "Public read access for regions"
ON public.regions
FOR SELECT
TO public
USING (is_active = true);

-- Create policy allowing authenticated insert/update/delete
CREATE POLICY "Authenticated users can manage regions"
ON public.regions
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);
```

**Why These Columns:**
- `id`: UUID primary key (standard)
- `code`: Unique identifier for API/system use (e.g., 'SEOUL')
- `name`: Display name in Korean (e.g., '서울')
- `sort_order`: Display order (0 = first, higher = later)
- `is_active`: Soft delete support
- `created_at`, `updated_at`: Audit trail

**Matching Flutter Model:**
```dart
// lib/contexts/user/models/region.dart
class Region {
  final String id;
  final String code;
  final String name;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Step 2: Seed Regions with Korean Data ✅

**Migration File:** `backend/supabase/migrations/20251107000002_seed_regions_data.sql`

**18 Korean Regions (from RegionRepository.getMockRegions()):**
```sql
INSERT INTO public.regions (code, name, sort_order, is_active) VALUES
  ('NATIONWIDE', '전국', 0, true),
  ('SEOUL', '서울', 1, true),
  ('GYEONGGI', '경기', 2, true),
  ('INCHEON', '인천', 3, true),
  ('GANGWON', '강원', 4, true),
  ('CHUNGNAM', '충남', 5, true),
  ('CHUNGBUK', '충북', 6, true),
  ('DAEJEON', '대전', 7, true),
  ('SEJONG', '세종', 8, true),
  ('GYEONGNAM', '경남', 9, true),
  ('GYEONGBUK', '경북', 10, true),
  ('DAEGU', '대구', 11, true),
  ('JEONNAM', '전남', 12, true),
  ('JEONBUK', '전북', 13, true),
  ('GWANGJU', '광주', 14, true),
  ('ULSAN', '울산', 15, true),
  ('BUSAN', '부산', 16, true),
  ('JEJU', '제주', 17, true)
ON CONFLICT (code) DO NOTHING;
```

**Why This Order:**
- Nationwide first (전국)
- Seoul/Gyeonggi/Incheon (수도권)
- Others by geographic/administrative importance

### Step 3: Create `user_regions` Table ✅

**Migration File:** `backend/supabase/migrations/20251107000003_create_user_regions_table.sql`

**Schema:**
```sql
-- Junction table for user's selected regions
CREATE TABLE IF NOT EXISTS public.user_regions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  region_id uuid NOT NULL REFERENCES public.regions(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, region_id)
);

-- Index for user lookup
CREATE INDEX IF NOT EXISTS idx_user_regions_user_id
ON public.user_regions (user_id);

-- Index for region lookup
CREATE INDEX IF NOT EXISTS idx_user_regions_region_id
ON public.user_regions (region_id);

-- Enable RLS
ALTER TABLE public.user_regions ENABLE ROW LEVEL SECURITY;

-- Users can only manage their own regions
CREATE POLICY "Users can manage their own regions"
ON public.user_regions
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

### Step 4: Enable Realtime Publication ✅

**Migration File:** `backend/supabase/migrations/20251107000004_enable_regions_realtime.sql`

```sql
-- Enable Realtime for regions table
ALTER PUBLICATION supabase_realtime ADD TABLE public.regions;

-- Verify publication
SELECT schemaname, tablename
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'
  AND tablename IN ('regions', 'benefit_categories');
```

**Why Needed:**
- RegionRepository.subscribeToRegions() expects realtime events
- Admin can update regions and Flutter app reflects changes immediately
- Consistent with benefit_categories realtime setup

### Step 5: Investigate & Fix Multiple Subscriptions 🔍

**Investigation Steps:**

1. **Check benefit_repository.dart watchCategories() implementation:**
   - Is the stream properly disposed?
   - Is it using `.stream()` method correctly?
   - Are there duplicate stream providers?

2. **Check benefit_categories_provider.dart:**
   - Is StreamProvider rebuilding unnecessarily?
   - Is autoDispose enabled?
   - Are there multiple instances of the same provider?

3. **Check UI layer benefit screens:**
   - How many times is `ref.watch(benefitCategoriesProvider)` called?
   - Are widgets rebuilding excessively?
   - Is there a circular dependency?

**Potential Fixes:**

**Option A: Add autoDispose to StreamProvider**
```dart
@riverpod
Stream<List<BenefitCategory>> benefitCategories(Ref ref) {
  final repository = ref.watch(benefitRepositoryProvider);
  return repository.watchCategories();
}
// Add .autoDispose if not present
```

**Option B: Debounce Stream Creation**
```dart
Stream<List<BenefitCategory>> watchCategories() {
  // Check if channel already exists
  if (_categoriesChannel != null) {
    return _categoriesStream!;
  }

  // Create new channel only if needed
  _categoriesChannel = _client.channel('benefit_categories_changes');
  // ... setup subscription
  return _categoriesStream!;
}
```

**Option C: Use Single Global Channel**
```dart
// Singleton pattern for realtime channel
class RealtimeChannelManager {
  static RealtimeChannel? _benefitCategoriesChannel;

  static RealtimeChannel getBenefitCategoriesChannel(SupabaseClient client) {
    _benefitCategoriesChannel ??= client.channel('benefit_categories_changes');
    return _benefitCategoriesChannel!;
  }
}
```

### Step 6: Verification & Testing 🧪

**Database Verification:**
```bash
# 1. Verify regions table exists
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
"SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'regions';"

# 2. Check regions data
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
"SELECT code, name, sort_order FROM public.regions ORDER BY sort_order LIMIT 5;"

# 3. Verify realtime publication
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
"SELECT tablename FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename IN ('regions', 'benefit_categories');"

# 4. Check RLS policies
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
"SELECT schemaname, tablename, policyname FROM pg_policies WHERE tablename = 'regions';"
```

**Flutter App Testing:**
```bash
# 1. Hot restart simulator
cd /Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_mobile
flutter run -d E7F1E329-C4FF-4224-94F9-408F08A4C96C

# 2. Watch logs for region loading
# Expected output:
# ✅ Successfully loaded 18 regions from Supabase
# ✅ Realtime subscription established for regions

# 3. Check benefit categories stream
# Expected output:
# 🌊 [Stream Provider] Starting benefit categories stream
# ✅ Received 10 categories from Supabase
# (Should only appear ONCE, not 11 times)
```

**Manual Testing Checklist:**
- [ ] Navigate to onboarding region selection screen
- [ ] Verify 18 Korean regions display correctly
- [ ] Select regions and proceed
- [ ] Go to 혜택 (Benefits) tab
- [ ] Verify 써클탭 (category circles) appear at top
- [ ] Tap each category circle, verify navigation works
- [ ] Check console logs - no excessive subscription messages
- [ ] Check console logs - no RegionException errors

---

## 📊 Expected Outcomes

### Success Criteria:

1. ✅ **Regions Table Created**
   - Table `public.regions` exists with 18 Korean regions
   - RLS policies configured correctly
   - Realtime publication enabled

2. ✅ **Flutter App Regions Working**
   - Onboarding region selection screen loads real data (not mock)
   - User can select regions and proceed
   - No RegionException errors in logs

3. ✅ **Benefit Categories Display Fixed**
   - 써클탭 (category circles) visible in Benefits tab
   - Only ONE realtime subscription per provider instance
   - Categories load on app start
   - Tapping categories navigates correctly

4. ✅ **Performance Improvement**
   - Reduced memory usage (fewer duplicate subscriptions)
   - Faster app startup (proper stream management)
   - No duplicate Realtime channels

### Performance Metrics:

**Before Fix:**
- Realtime subscriptions: 11+ duplicate streams
- Region data: Mock fallback only
- Benefit categories: Not displaying

**After Fix:**
- Realtime subscriptions: 1 stream per provider instance
- Region data: Live from Supabase (18 regions)
- Benefit categories: Displaying correctly with 10 active categories

---

## 🔧 Migration Execution Order

Run migrations in this exact order:

```bash
# Navigate to backend directory
cd /Users/kwonhyunjun/Desktop/pickly_service/backend

# 1. Create regions table
supabase migration new create_regions_table
# Copy schema from Step 1

# 2. Seed regions data
supabase migration new seed_regions_data
# Copy INSERT statements from Step 2

# 3. Create user_regions junction table
supabase migration new create_user_regions_table
# Copy schema from Step 3

# 4. Enable realtime publication
supabase migration new enable_regions_realtime
# Copy ALTER PUBLICATION from Step 4

# Apply all migrations
supabase db reset

# Verify
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
"SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename LIKE '%region%';"
```

---

## 🐛 Known Issues to Address

### Issue #1: Missing fire.svg Asset (Lower Priority)

**Error:**
```
Unable to load asset: "packages/pickly_design_system/assets/icons/fire.svg"
```

**Scope:**
- This is a **design system package issue**, NOT a backend/realtime issue
- Should be addressed separately in Phase 6.4

**Quick Fix Options:**
1. Add fire.svg to `packages/pickly_design_system/assets/icons/`
2. Update pubspec.yaml in design system to include assets
3. Run `flutter pub get` and rebuild

### Issue #2: Benefit Categories Stream Multiple Subscriptions (Addressed in Step 5)

**Root Cause TBD** - needs investigation of:
- Provider lifecycle
- Widget rebuild frequency
- StreamProvider.autoDispose usage

---

## 📋 Post-Implementation Checklist

After completing all steps:

- [ ] All 4 migrations executed successfully
- [ ] Database verification queries pass
- [ ] Flutter hot restart successful
- [ ] Regions load from database (not mock)
- [ ] Benefit categories display in app
- [ ] Only 1 realtime subscription per provider
- [ ] No console errors or exceptions
- [ ] Manual testing checklist completed
- [ ] Create Phase 6.3 completion report
- [ ] Update PRD_CURRENT.md to v9.8.2
- [ ] Commit changes with message: `feat: Phase 6.3 - Fix Realtime Sync & Regions Table (PRD v9.8.2)`

---

## 🚀 Next Phase: Phase 6.4

**Focus:** Enhanced Admin UI for API Mapping

1. Add CRUD modals for API sources
2. Implement status toggle with confirmation
3. Replace simulator placeholder with real transformation engine
4. Add form validation
5. Implement loading states and error boundaries
6. Integrate toast notifications

---

**Document Version:** 1.0
**Last Updated:** 2025-11-07
**Author:** Claude Code
**Status:** 📋 **READY TO START**
**Estimated Time:** 2-3 hours

---

## 🎯 Critical Success Factors

1. **Database First** - Create tables before Flutter testing
2. **Realtime Verification** - Confirm publication enabled before app test
3. **Stream Investigation** - Must identify root cause of multiple subscriptions
4. **No Flutter Code Changes** - Keep app code as-is, fix data layer only
5. **Proper Testing** - Verify both database and app before marking complete

**Remember:** "앱 잘 되어있는데 바꾸지 마" - Don't break what's working!
