# Phase 6.3 Validation Task — Flutter Schema & Stream Fix (PRD v9.8.3-pre)

**Date:** 2025-11-07
**Version:** PRD v9.8.3-pre (Validation Phase)
**Priority:** 🔴 **CRITICAL**
**Status:** 📋 **READY TO EXECUTE**
**Prerequisites:** ✅ Database migrations complete, regions table seeded

---

## 🎯 Objective

Validate and fix Flutter app integration issues after regions table creation:

1. **Schema Cache Issue** - Flutter client not recognizing new regions table
2. **Stream Duplication** - 11 duplicate benefit_categories subscriptions
3. **SVG Asset Path** - fire.svg missing from design system
4. **UI Display** - 써클탭 (category circles) not appearing

---

## 📘 Context & References

### Previous Work:
- `/docs/PHASE6_3_REGIONS_AND_REALTIME_STATUS.md` - Current status analysis
- `/docs/PHASE6_3_TASK_REALTIME_REGIONS_FIX.md` - Original task spec
- `/docs/PHASE6_2_ADMIN_UI_COMPLETE.md` - Phase 6.2 completion

### Database Status:
```sql
-- ✅ Verified: 18 regions in database
SELECT COUNT(*) FROM public.regions WHERE is_active = true;
-- Result: 18

-- ✅ Verified: Realtime enabled
SELECT tablename FROM pg_publication_tables
WHERE pubname = 'supabase_realtime' AND tablename IN ('regions', 'user_regions');
-- Result: 2 rows

-- ✅ Verified: 10 active benefit categories
SELECT COUNT(*) FROM public.benefit_categories WHERE is_active = true;
-- Result: 10
```

### Flutter App Issues:
```
❌ RegionException: Database error: Could not find the table 'public.regions' in the schema cache
🔴 CRITICAL: 11 duplicate "Starting stream on benefit_categories table" messages
❌ Unable to load asset: "packages/pickly_design_system/assets/icons/fire.svg"
❌ 써클탭 (category circles) not displaying despite data existing
```

---

## 🧱 Implementation Steps

### Step 1: Flutter Clean & Rebuild (Schema Cache Fix)

**Problem:** Supabase Flutter client caches table schemas on initialization. Hot restart is insufficient.

**Solution:** Full rebuild to force schema cache refresh.

**Commands:**
```bash
# 1. Stop current Flutter process
# (All background Flutter processes will be killed)

# 2. Clean build artifacts
cd /Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_mobile
flutter clean

# 3. Clean iOS build (optional but recommended)
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..

# 4. Get dependencies
flutter pub get

# 5. Rebuild and run
flutter run -d E7F1E329-C4FF-4224-94F9-408F08A4C96C
```

**Expected Result:**
```
✅ Realtime subscription established for regions
✅ Successfully loaded 18 regions from Supabase
❌ [REMOVED] RegionException: Database error: Could not find the table...
```

**Verification:**
```bash
# Check Flutter logs for successful region loading
# Look for these log messages:
# ✅ Successfully loaded 18 regions from Supabase
# ✅ Realtime subscription established for regions
```

**Alternative (if full rebuild fails):**
```dart
// Add to main.dart if schema cache persists
await Supabase.instance.client.removeAllChannels();
await Supabase.instance.dispose();
await Supabase.initialize(
  url: supabaseUrl,
  anonKey: supabaseAnonKey,
  // Force fresh schema fetch
  realtimeClientOptions: const RealtimeClientOptions(
    eventsPerSecond: 10,
  ),
);
```

---

### Step 2: Fix Benefit Categories Stream Duplication

**Problem:** `watchCategories()` creates a new stream subscription on every provider rebuild.

**Root Cause:**
```dart
// Current implementation (creates new stream each time)
Stream<List<BenefitCategory>> watchCategories() {
  print('📡 [Supabase Realtime] Starting stream on benefit_categories table');
  return _client
      .from('benefit_categories')
      .stream(primaryKey: ['id'])
      .eq('is_active', true)
      .order('display_order', ascending: true)
      .map((data) => ...);
}
```

**Solution:** Add stream caching to repository.

**File to Edit:** `/apps/pickly_mobile/lib/contexts/benefit/repositories/benefit_repository.dart`

**Implementation:**

```dart
class BenefitRepository {
  final SupabaseClient _client;

  // Add stream cache fields
  Stream<List<BenefitCategory>>? _categoriesStream;
  bool _isStreamInitialized = false;

  const BenefitRepository(this._client);

  /// Watch all active benefit categories with Realtime updates
  ///
  /// CACHED: Returns existing stream if already created to prevent
  /// multiple subscriptions (PRD v9.8.3 - Phase 6.3 Fix)
  Stream<List<BenefitCategory>> watchCategories() {
    // Return cached stream if already exists
    if (_isStreamInitialized && _categoriesStream != null) {
      print('🔄 [Stream Cache] Returning existing categories stream');
      return _categoriesStream!;
    }

    print('📡 [Supabase Realtime] Starting NEW stream on benefit_categories table');
    print('🌊 [Stream Provider] Starting benefit categories stream');
    print('🌊 [BenefitRepository] Creating watchCategories() stream subscription');

    _categoriesStream = _client
        .from('benefit_categories')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('display_order', ascending: true)
        .map((data) {
          final categories = (data as List)
              .map((json) => BenefitCategory.fromJson(json as Map<String, dynamic>))
              .toList();

          print('✅ [Categories Stream] Received ${categories.length} categories');
          return categories;
        })
        .handleError((error, stackTrace) {
          print('❌ [Categories Stream] Error: $error');
          return <BenefitCategory>[];
        })
        .asBroadcastStream(); // Make it shareable across multiple listeners!

    _isStreamInitialized = true;
    return _categoriesStream!;
  }

  /// Dispose method to clean up streams when repository is disposed
  ///
  /// Should be called from provider's onDispose callback
  void dispose() {
    print('🗑️ [Repository] Disposing benefit categories stream');
    _categoriesStream = null;
    _isStreamInitialized = false;
  }

  // ... rest of the class remains unchanged
}
```

**Provider Update (if needed):**

File: `/apps/pickly_mobile/lib/features/benefits/providers/benefit_categories_provider.dart`

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

**Expected Result:**
```
📡 [Supabase Realtime] Starting NEW stream on benefit_categories table (appears ONCE)
🔄 [Stream Cache] Returning existing categories stream (on subsequent calls)
✅ [Categories Stream] Received 10 categories
```

**Verification:**
```bash
# Check Flutter logs - should see these messages:
# 1. ONE "Starting NEW stream" message
# 2. Multiple "Returning existing categories stream" messages
# 3. "Received 10 categories" message

# Count stream creation messages (should be 1, not 11)
flutter logs | grep "Starting stream on benefit_categories" | wc -l
# Expected: 1 (not 11)
```

---

### Step 3: Fix SVG Asset Path (Optional - Lower Priority)

**Problem:** `fire.svg` not found in pickly_design_system package.

**Impact:** Category icons fail to render, but doesn't block core functionality.

**Quick Check:**
```bash
# Check if fire.svg exists
ls /Users/kwonhyunjun/Desktop/pickly_service/packages/pickly_design_system/assets/icons/fire.svg

# If missing, check what icons ARE available
ls /Users/kwonhyunjun/Desktop/pickly_service/packages/pickly_design_system/assets/icons/
```

**Solution A: If file is missing:**
```bash
# Option 1: Use alternative icon temporarily
# Edit the widget using fire.svg to use a different icon

# Option 2: Add fire.svg to design system
# 1. Add SVG file to assets/icons/
# 2. Update pubspec.yaml in pickly_design_system:
#    assets:
#      - assets/icons/fire.svg
# 3. Run flutter pub get in mobile app
```

**Solution B: If file exists but path is wrong:**
```dart
// Check usage in code - might need to update path
// From: 'packages/pickly_design_system/assets/icons/fire.svg'
// To: 'assets/icons/fire.svg' (if using direct package reference)
```

**Note:** This is a **design system issue**, not a backend/database issue. Can be addressed separately in Phase 6.4.

---

### Step 4: Verify 써클탭 (Category Circles) Display

**Problem:** Benefit categories not displaying in Benefits tab despite data existing.

**Root Cause:** Likely caused by stream duplication issue (Step 2).

**After Fixing Stream:**

**Manual Testing Steps:**

1. **Launch App:**
   ```bash
   flutter run -d E7F1E329-C4FF-4224-94F9-408F08A4C96C
   ```

2. **Navigate to Benefits Tab (혜택):**
   - Tap bottom navigation bar
   - Select "혜택" tab (second from left)

3. **Verify Category Circles:**
   - [ ] Category circles appear at top of screen
   - [ ] 10 categories display (인기, 주거, 교육, 건강, 교통, 복지, 취업, 지원, 문화, test)
   - [ ] Each circle shows icon (if SVG fixed) and Korean text
   - [ ] Circles are horizontally scrollable

4. **Test Category Selection:**
   - [ ] Tap any category circle
   - [ ] App navigates to category detail screen
   - [ ] Announcements for that category load (if any exist)

5. **Verify Realtime Updates:**
   - [ ] Open Admin panel in browser
   - [ ] Update a category (change icon or title)
   - [ ] Flutter app updates automatically without refresh

**Expected Console Logs:**
```
🌊 [Stream Provider] Starting benefit categories stream
📡 [Supabase Realtime] Starting NEW stream on benefit_categories table
✅ [Categories Stream] Received 10 categories
[UI Layer] Rendering 10 category circles
```

**Not Expected (these should be GONE):**
```
❌ [REMOVED] Starting stream on benefit_categories table (11 times)
❌ [REMOVED] ⚠️ [Categories Stream] No data available (loading or error)
```

---

### Step 5: Verify Regions Integration

**Problem:** Regions table not found in schema cache (should be fixed by Step 1).

**Manual Testing Steps:**

1. **Clear App Data (Simulate Fresh Install):**
   ```bash
   # iOS Simulator
   xcrun simctl uninstall E7F1E329-C4FF-4224-94F9-408F08A4C96C com.pickly.mobile
   ```

2. **Launch App Fresh:**
   ```bash
   flutter run -d E7F1E329-C4FF-4224-94F9-408F08A4C96C
   ```

3. **Navigate Through Onboarding:**
   - [ ] Age category selection screen appears
   - [ ] Select age category (e.g., "20대")
   - [ ] **Region selection screen appears**
   - [ ] **18 Korean regions display** (전국, 서울, 경기, ...)
   - [ ] NOT "Using mock data as fallback"
   - [ ] Regions are selectable (multi-select)
   - [ ] "다음" (Next) button works

4. **Verify Region Data:**
   - [ ] Regions loaded from Supabase (not mock)
   - [ ] All 18 regions present
   - [ ] Correct Korean names
   - [ ] Proper sort order (전국 first)

**Expected Console Logs:**
```
✅ Realtime subscription established for regions
✅ Successfully loaded 18 regions from Supabase
✅ [Regions] Loaded 18 regions: [전국, 서울, 경기, ...]
```

**Not Expected:**
```
❌ [REMOVED] RegionException: Database error: Could not find the table 'public.regions' in the schema cache
❌ [REMOVED] → Using mock data as fallback
```

---

## ✅ Success Criteria

### Primary Criteria (Must Pass):

1. **Schema Cache Fixed** ✅
   - [ ] Flutter recognizes `public.regions` table
   - [ ] No "table not found in schema cache" errors
   - [ ] RegionRepository loads 18 real regions (not mock data)

2. **Stream Duplication Fixed** ✅
   - [ ] Only 1 "Starting stream on benefit_categories" message in logs
   - [ ] Multiple "Returning existing categories stream" messages OK
   - [ ] Categories successfully received (10 items)

3. **써클탭 Display Working** ✅
   - [ ] Category circles visible in Benefits tab
   - [ ] 10 categories render with icons and text
   - [ ] Tapping circles navigates to category detail
   - [ ] Realtime updates work

4. **Regions Display Working** ✅
   - [ ] Onboarding region screen shows 18 real regions
   - [ ] Region selection saves to database
   - [ ] Realtime subscription established

### Secondary Criteria (Nice to Have):

5. **SVG Assets Fixed** (Optional)
   - [ ] No "Unable to load asset: fire.svg" errors
   - [ ] Category icons render correctly

6. **Performance Improved**
   - [ ] Reduced memory usage (fewer duplicate subscriptions)
   - [ ] Faster app startup
   - [ ] No memory leaks

---

## 📊 Verification Commands

### Database Verification:
```bash
# 1. Check regions data
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
"SELECT code, name, sort_order FROM public.regions ORDER BY sort_order LIMIT 5;"

# Expected output:
#  code       | name | sort_order
# ------------|------|------------
#  NATIONWIDE | 전국 | 0
#  SEOUL      | 서울 | 1
#  GYEONGGI   | 경기 | 2
#  INCHEON    | 인천 | 3
#  GANGWON    | 강원 | 4

# 2. Check benefit categories
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
"SELECT id, title, display_order FROM public.benefit_categories WHERE is_active = true ORDER BY display_order;"

# Expected: 10 rows (인기, 주거, 교육, etc.)

# 3. Verify Realtime publication
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
"SELECT tablename FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename IN ('regions', 'benefit_categories');"

# Expected: 2 rows (regions, benefit_categories)
```

### Flutter Log Analysis:
```bash
# After running the app, check for these patterns:

# SUCCESS INDICATORS:
grep "Successfully loaded.*regions" flutter_logs.txt
grep "Received.*categories" flutter_logs.txt
grep "Returning existing categories stream" flutter_logs.txt

# FAILURE INDICATORS (should NOT appear):
grep "table not found in schema cache" flutter_logs.txt
grep "Using mock data" flutter_logs.txt

# Count stream creations (should be 1, not 11):
grep -c "Starting NEW stream on benefit_categories" flutter_logs.txt
```

---

## 🐛 Troubleshooting

### Issue #1: Schema Cache Still Stale After Rebuild

**Symptom:** Still getting "table not found in schema cache" after `flutter clean`

**Solutions:**

**Solution A: Nuclear Clean**
```bash
cd /Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_mobile
flutter clean
rm -rf build/
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -rf .dart_tool/
flutter pub get
flutter run -d E7F1E329-C4FF-4224-94F9-408F08A4C96C
```

**Solution B: Force Supabase Reconnection**
```dart
// Add to main.dart initialization
try {
  await Supabase.instance.dispose();
} catch (e) {
  print('Dispose error (OK): $e');
}

await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

**Solution C: Verify Database Connection**
```dart
// Add debug query in RegionRepository
Future<void> debugSchemaCheck() async {
  try {
    final result = await _client.rpc('version');
    print('✅ Supabase connected: $result');

    final tables = await _client.rpc('get_tables'); // if function exists
    print('📊 Available tables: $tables');
  } catch (e) {
    print('❌ Connection issue: $e');
  }
}
```

### Issue #2: Stream Still Duplicating After Fix

**Symptom:** Still seeing multiple "Starting stream" messages

**Check:**
```dart
// Verify asBroadcastStream() is called
_categoriesStream = _client
    .from('benefit_categories')
    .stream(primaryKey: ['id'])
    // ...
    .asBroadcastStream(); // ← This line is critical!
```

**Verify Provider Not Rebuilding:**
```dart
// Add debug logging to provider
@riverpod
Stream<List<BenefitCategory>> benefitCategories(Ref ref) {
  print('🔍 [Provider] benefitCategories provider called');
  // ...
}

// If this prints more than once, investigate why provider is rebuilding
```

### Issue #3: Categories Still Not Displaying

**Symptom:** Stream working but UI not showing categories

**Check:**
```dart
// In benefit screen widget
ref.watch(benefitCategoriesProvider).when(
  data: (categories) {
    print('✅ [UI] Rendering ${categories.length} categories');
    // Check if categories.isEmpty
    if (categories.isEmpty) {
      print('⚠️ [UI] Categories list is empty!');
    }
    return CategoryCircles(categories: categories);
  },
  loading: () {
    print('🔄 [UI] Loading categories...');
    return CircularProgressIndicator();
  },
  error: (error, stack) {
    print('❌ [UI] Error loading categories: $error');
    return ErrorWidget(error);
  },
);
```

---

## 📝 Post-Validation Checklist

After completing all steps and verifying success:

- [ ] All primary success criteria passed
- [ ] Flutter logs clean (no errors)
- [ ] Manual testing completed
- [ ] Database verification queries passed
- [ ] Create Phase 6.3 completion report
- [ ] Update PRD_CURRENT.md to v9.8.3
- [ ] Commit changes:
  ```bash
  git add .
  git commit -m "feat: Phase 6.3 Complete - Regions Table & Stream Fixes (PRD v9.8.3)

  ✅ Created regions table with 18 Korean regions
  ✅ Fixed benefit_categories stream duplication (11 → 1)
  ✅ Fixed schema cache issue with full Flutter rebuild
  ✅ Verified 써클탭 (category circles) displaying correctly
  ✅ Verified regions integration with onboarding flow

  Database Changes:
  - Added public.regions table with RLS policies
  - Added public.user_regions junction table
  - Enabled Realtime publication for both tables
  - Seeded 18 Korean regions (전국, 서울, 경기, etc.)

  Flutter Changes:
  - Added stream caching to BenefitRepository.watchCategories()
  - Fixed schema cache with flutter clean + rebuild
  - Improved logging for debugging

  Related Issues:
  - Fixes #RegionException (table not found in schema cache)
  - Fixes #StreamDuplication (11 duplicate subscriptions)
  - Fixes #CategoryDisplay (써클탭 not showing)

  Phase: 6.3 Complete
  PRD: v9.8.3"
  ```

---

## 🚀 Next Phase: Phase 6.4

After Phase 6.3 validation is complete:

**Focus:** Enhanced Admin UI for API Mapping

1. Add CRUD modals for API sources
2. Implement status toggle with confirmation
3. Replace simulator placeholder with real transformation engine
4. Add form validation
5. Implement loading states
6. Add toast notifications
7. Integrate Monaco Editor for advanced JSON editing

**Prerequisites from Phase 6.3:**
- ✅ Regions table working
- ✅ Benefit categories stream optimized
- ✅ No schema cache issues
- ✅ App UI displaying correctly

---

## 📄 Related Documents

- `/docs/PHASE6_3_REGIONS_AND_REALTIME_STATUS.md` - Current status before validation
- `/docs/PHASE6_3_TASK_REALTIME_REGIONS_FIX.md` - Original task specification
- `/docs/PHASE6_2_ADMIN_UI_COMPLETE.md` - Previous phase completion
- `/backend/supabase/migrations/202511070000*.sql` - Regions migrations
- `/apps/pickly_mobile/lib/contexts/benefit/repositories/benefit_repository.dart` - Repository to fix
- `/apps/pickly_mobile/lib/contexts/user/repositories/region_repository.dart` - Regions implementation

---

**Document Version:** 1.0
**Last Updated:** 2025-11-07 19:35 KST
**Author:** Claude Code
**Status:** 📋 **READY TO EXECUTE**
**Estimated Time:** 1-2 hours
**Priority:** 🔴 **CRITICAL** - Blocks app usability

---

## 🎯 Critical Success Factor

**"앱 잘 되어있는데 바꾸지 마"** - Don't break what's working!

- ✅ Database changes are COMPLETE and TESTED
- ✅ Only touching Flutter app for bug fixes (not feature changes)
- ✅ All fixes are targeted at specific issues
- ✅ Full testing before considering complete

**Remember:** The goal is to make the existing app work correctly with the new database schema, NOT to change the app's functionality.
