# Phase 6.3 Status Report — Regions Table & Realtime Issues

**Date:** 2025-11-07
**Version:** PRD v9.8.2 (Phase 6.3 In Progress)
**Status:** 🟡 **PARTIAL COMPLETE** - Database ready, app integration pending

---

## ✅ Completed Tasks

### 1. Database Schema — COMPLETE ✅

**Tables Created:**
- `public.regions` - Main regions table with 18 Korean regions
- `public.user_regions` - Junction table for user's selected regions

**Verification:**
```sql
-- All 18 regions confirmed
SELECT code, name, sort_order FROM public.regions ORDER BY sort_order;

CODE       | NAME | SORT_ORDER
-----------|------|------------
NATIONWIDE | 전국 | 0
SEOUL      | 서울 | 1
GYEONGGI   | 경기 | 2
... (18 total rows)
```

**Realtime Publication:**
```
✅ ALTER PUBLICATION supabase_realtime ADD TABLE public.regions;
✅ ALTER PUBLICATION supabase_realtime ADD TABLE public.user_regions;
```

**RLS Policies:**
- ✅ Public read access for active regions
- ✅ Authenticated users can manage regions
- ✅ Users can only manage their own region selections

### 2. Migration Files Created — COMPLETE ✅

**Files:**
1. `20251107000001_create_regions_table.sql` - Table schema
2. `20251107000002_seed_regions_data.sql` - 18 Korean regions
3. `20251107000003_create_user_regions_table.sql` - Junction table
4. `20251107000004_enable_regions_realtime.sql` - Realtime pub

**Applied:** ✅ All migrations applied successfully via direct psql execution

---

## 🟡 Partial Complete / In Progress

### 3. Flutter App Integration — PARTIAL ⚠️

**Status in Simulator:**
```
✅ Realtime subscription established for regions
❌ RegionException: Database error: Could not find the table 'public.regions' in the schema cache
→ Using mock data as fallback
```

**Analysis:**
The Supabase Flutter client appears to be caching an old schema that doesn't include the `regions` table. This is likely because:

1. **Schema Cache Not Refreshed**: Supabase client caches table schemas on initialization
2. **Hot Restart Insufficient**: Need full app rebuild or Supabase reconnection
3. **Timing Issue**: Realtime subscription establishes before schema fetch completes

**Potential Solutions:**

**Solution A: Full App Rebuild** (Recommended)
```bash
cd /Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_mobile
flutter clean && flutter pub get && flutter run -d E7F1E329-C4FF-4224-94F9-408F08A4C96C
```

**Solution B: Supabase Client Reinitialization**
```dart
// Add to main.dart or relevant provider
await Supabase.instance.client.removeAllChannels();
await Supabase.instance.dispose();
await Supabase.initialize(...); // Re-init with fresh schema
```

**Solution C: Force Schema Refresh**
```dart
// In RegionRepository
Future<List<Region>> fetchActiveRegions() async {
  try {
    // Force a fresh connection by using .from() directly
    final response = await _client
        .schema('public') // Explicitly specify schema
        .from('regions')
        .select()
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return (response as List)
        .map((json) => Region.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    // ...
  }
}
```

---

## 🔴 Critical Issue: Multiple Realtime Subscriptions

### Problem Description:

**Observed in Logs:**
```
flutter: 📡 [Supabase Realtime] Starting stream on benefit_categories table
flutter: 📡 [Supabase Realtime] Starting stream on benefit_categories table
flutter: 📡 [Supabase Realtime] Starting stream on benefit_categories table
... (11 times total)
```

**Impact:**
- Memory leak from unclosed subscriptions
- Duplicate event handlers
- Poor performance
- Benefit categories (써클탭) not displaying despite data existing

**Root Cause Analysis:**

1. **Provider Rebuilding Excessively**
   - `benefitCategoriesProvider` likely rebuilding on every widget rebuild
   - No `.autoDispose` modifier on StreamProvider

2. **Stream Not Properly Managed**
   - `watchCategories()` creating new subscription on each call
   - Old subscriptions not disposed before creating new ones

3. **Widget Tree Rebuilding**
   - Multiple widgets watching the same provider
   - Each rebuild triggers new stream subscription

**Evidence from Code:**
```dart
// lib/contexts/benefit/repositories/benefit_repository.dart:100
Stream<List<BenefitCategory>> watchCategories() {
  print('📡 [Supabase Realtime] Starting stream on benefit_categories table');
  return _client
      .from('benefit_categories')
      .stream(primaryKey: ['id'])
      .eq('is_active', true)
      .order('display_order', ascending: true)
      .map((data) => data.map((json) =>
          BenefitCategory.fromJson(json as Map<String, dynamic>)).toList());
}
```

**This creates a new stream every time it's called!**

---

## 🔧 Recommended Fixes

### Fix #1: Add Stream Caching to BenefitRepository

**File:** `/apps/pickly_mobile/lib/contexts/benefit/repositories/benefit_repository.dart`

**Add:**
```dart
class BenefitRepository {
  final SupabaseClient _client;

  // Add stream cache
  Stream<List<BenefitCategory>>? _categoriesStream;
  RealtimeChannel? _categoriesChannel;

  const BenefitRepository(this._client);

  Stream<List<BenefitCategory>> watchCategories() {
    // Return cached stream if already exists
    if (_categoriesStream != null) {
      print('🔄 [Stream Cache] Returning existing categories stream');
      return _categoriesStream!;
    }

    print('📡 [Supabase Realtime] Starting NEW stream on benefit_categories table');

    _categoriesStream = _client
        .from('benefit_categories')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('display_order', ascending: true)
        .map((data) => data.map((json) =>
            BenefitCategory.fromJson(json as Map<String, dynamic>)).toList())
        .asBroadcastStream(); // Make it shareable!

    return _categoriesStream!;
  }

  // Add dispose method
  void dispose() {
    _categoriesChannel?.unsubscribe();
    _categoriesChannel = null;
    _categoriesStream = null;
  }
}
```

### Fix #2: Add autoDispose to Provider

**File:** `/apps/pickly_mobile/lib/features/benefits/providers/benefit_categories_provider.dart`

**Change from:**
```dart
@riverpod
Stream<List<BenefitCategory>> benefitCategories(Ref ref) {
  final repository = ref.watch(benefitRepositoryProvider);
  return repository.watchCategories();
}
```

**To:**
```dart
@riverpod
Stream<List<BenefitCategory>> benefitCategories(Ref ref) {
  final repository = ref.watch(benefitRepositoryProvider);

  // Dispose repository when provider is disposed
  ref.onDispose(() {
    repository.dispose();
  });

  return repository.watchCategories();
}
```

### Fix #3: Use keepAlive for Long-Lived Streams

**Alternative approach:**
```dart
@Riverpod(keepAlive: true) // Prevent disposal
Stream<List<BenefitCategory>> benefitCategories(Ref ref) {
  final repository = ref.watch(benefitRepositoryProvider);
  return repository.watchCategories();
}
```

---

## 📊 Current Status Summary

| Component | Status | Notes |
|-----------|--------|-------|
| Database - regions table | ✅ COMPLETE | 18 regions inserted |
| Database - user_regions table | ✅ COMPLETE | Junction table ready |
| Database - Realtime pub | ✅ COMPLETE | Both tables published |
| Flutter - Regions loading | ❌ BLOCKED | Schema cache issue |
| Flutter - Benefit categories stream | 🔴 CRITICAL BUG | 11 duplicate subscriptions |
| Flutter - Benefit categories display | ❌ NOT WORKING | Likely due to stream issue |
| Storage RLS | ✅ COMPLETE | benefit-icons bucket ready |

---

## 🎯 Next Steps (Priority Order)

### Priority 1: Fix Benefit Categories Stream (CRITICAL)
**Why:** Currently app is unusable - 써클탭 (category circles) not displaying
**Action:** Implement Fix #1 above (stream caching in repository)
**Time Estimate:** 30 minutes

### Priority 2: Fix Regions Schema Cache (HIGH)
**Why:** Regions feature not working, using fallback mock data
**Action:** Full Flutter clean and rebuild OR implement Solution C (force schema)
**Time Estimate:** 15 minutes

### Priority 3: Verification Testing (MEDIUM)
**Actions:**
1. Navigate to onboarding region selection - verify 18 real regions load
2. Navigate to 혜택 (Benefits) tab - verify 써클탭 appears
3. Check console logs - verify only 1 stream subscription message
4. Test category tap - verify navigation works

**Time Estimate:** 20 minutes

### Priority 4: Documentation & PRD Update (LOW)
**Actions:**
1. Update PRD_CURRENT.md to v9.8.2
2. Create Phase 6.3 completion report
3. Commit changes with proper message

**Time Estimate:** 30 minutes

---

## 🐛 Known Issues

### Issue #1: Schema Cache Stale Data
**Symptom:** "Could not find the table 'public.regions' in the schema cache"
**Workaround:** Using mock data fallback
**Fix Required:** Full app rebuild or schema refresh

### Issue #2: Multiple Stream Subscriptions
**Symptom:** 11 duplicate "Starting stream on benefit_categories table" messages
**Impact:** Memory leak, poor performance, categories not displaying
**Fix Required:** Stream caching in repository (Priority 1)

### Issue #3: Missing SVG Asset (Lower Priority)
**Symptom:** Unable to load asset: "fire.svg"
**Impact:** Icon display degraded
**Scope:** Design system issue, not backend
**Fix:** Add asset to pickly_design_system package

---

## 🔬 Verification Commands

### Database Verification:
```bash
# Check regions table
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
"SELECT COUNT(*) FROM public.regions WHERE is_active = true;"

# Check realtime publication
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
"SELECT tablename FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename LIKE '%region%';"

# Check benefit categories
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
"SELECT id, title, is_active FROM public.benefit_categories WHERE is_active = true;"
```

### Flutter Verification:
```bash
# Hot restart (insufficient for schema cache)
printf "R" | nc localhost 51626

# Full rebuild (recommended)
cd /Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_mobile
flutter clean && flutter pub get && flutter run -d E7F1E329-C4FF-4224-94F9-408F08A4C96C
```

---

## 📝 Migration Files Location

All migration files saved in:
```
/Users/kwonhyunjun/Desktop/pickly_service/backend/supabase/migrations/
├── 20251107000001_create_regions_table.sql
├── 20251107000002_seed_regions_data.sql
├── 20251107000003_create_user_regions_table.sql
└── 20251107000004_enable_regions_realtime.sql
```

**Note:** Migrations applied manually via psql due to conflicts in `supabase db reset`. This is acceptable for Phase 6.3.

---

## 🎓 Lessons Learned

1. **Supabase Schema Caching**: Client caches table schemas on init - requires full reconnection or rebuild after new tables
2. **Stream Management**: StreamProviders need careful lifecycle management to avoid duplicate subscriptions
3. **Migration Conflicts**: Manual psql execution sometimes necessary when `db reset` encounters conflicts
4. **Realtime != Schema Refresh**: Realtime subscriptions establish independently of schema cache updates

---

## 🔗 Related Documents

- `/docs/PHASE6_2_ADMIN_UI_COMPLETE.md` - Previous phase completion
- `/docs/PHASE6_3_TASK_REALTIME_REGIONS_FIX.md` - Original task specification
- `/apps/pickly_mobile/lib/contexts/user/repositories/region_repository.dart` - Regions implementation
- `/apps/pickly_mobile/lib/contexts/benefit/repositories/benefit_repository.dart` - Categories stream (needs fix)

---

**Document Version:** 1.0
**Last Updated:** 2025-11-07 19:30 KST
**Author:** Claude Code
**Status:** 🟡 **IN PROGRESS** - Awaiting stream fixes and verification
