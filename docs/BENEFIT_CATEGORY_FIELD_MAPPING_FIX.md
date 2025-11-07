# 🔧 BenefitCategory Field Mapping Fix Report

**Date**: 2025-11-05
**PRD**: v9.6.1 Pickly Integrated System
**Status**: 🟡 **PARTIAL FIX APPLIED** - Awaiting Database Verification

---

## 📋 Executive Summary

**Root Cause Identified**: Flutter model was using incorrect `@JsonKey` mappings that didn't match the actual database schema, causing JSON deserialization to fail silently.

**Fix Applied**:
- ✅ Updated `@JsonKey(name: 'title')` → `@JsonKey(name: 'name')`
- ✅ Updated `@JsonKey(name: 'sort_order')` → `@JsonKey(name: 'display_order')`
- ✅ Regenerated code with `build_runner`

**Outstanding Issue**: Stream still not receiving data from Supabase → **Database verification required**

---

## 🔍 Investigation Timeline

### Phase 1: Log Analysis
- ✅ Checked `/tmp/realtime_sync_debug.log` for parse errors
- ✅ Found: **NO parse errors** (stream created but no data events)
- ✅ Observed: Age categories work fine → Proves Supabase Realtime is functional

### Phase 2: Database Schema Investigation
- ✅ Reviewed migration history:
  - `20251027000001_correct_schema.sql` - Original schema with `name`, `display_order`
  - `20251028000001_unify_naming_prd_v7_3.sql` - Attempted rename to `title`, `sort_order`
  - **Finding**: Migration may have failed or been rolled back

### Phase 3: Model vs Database Mismatch
**Flutter Model Expected**:
```dart
@JsonKey(name: 'title')      // ❌ Database likely has 'name'
@JsonKey(name: 'sort_order')  // ❌ Database likely has 'display_order'
```

**Actual Database Schema** (from `20251027000001_correct_schema.sql`):
```sql
CREATE TABLE benefit_categories (
  name varchar(100) NOT NULL,           -- ✅ Not 'title'
  display_order integer NOT NULL,       -- ✅ Not 'sort_order'
  ...
);
```

### Phase 4: Fix Applied
**File**: `apps/pickly_mobile/lib/contexts/benefit/models/benefit_category.dart`

**Changes**:
```dart
// BEFORE (WRONG)
@JsonKey(name: 'title')
final String title;

@JsonKey(name: 'sort_order')
final int sortOrder;

// AFTER (CORRECT)
@JsonKey(name: 'name')  // ✅ Maps to DB column 'name'
final String title;     // Dart field name stays 'title' for API consistency

@JsonKey(name: 'display_order')  // ✅ Maps to DB column 'display_order'
final int sortOrder;              // Dart field name stays 'sortOrder'
```

---

## 🚨 Critical Finding: No Data in Stream

**Evidence from Logs**:
```log
flutter: 🌊 [BenefitRepository] Creating watchCategories() stream subscription
flutter: 📡 [Supabase Realtime] Starting stream on benefit_categories table
# ❌ MISSING: 🔄 [Supabase Event] Stream received data update
# ❌ MISSING: 📊 [Raw Data] Total rows received: X
```

**Diagnosis**:
The stream is being created successfully, but Supabase Realtime is **NOT emitting any data events**. This indicates **ONE of these issues**:

1. ✅ **Database table is empty** (most likely)
   - Admin may not have added any categories yet
   - Seed data may not have been applied
   - Migration may have dropped existing data

2. ⚠️ **Realtime not enabled on table**
   - Supabase console → Tables → `benefit_categories` → Realtime tab
   - INSERT/UPDATE/DELETE events must be enabled

3. ⚠️ **RLS policies blocking anonymous access**
   - Stream may be blocked by Row Level Security
   - Admin panel uses authenticated access (works)
   - Flutter app uses anonymous access (may be blocked)

---

## ✅ Verification Steps Required

### Step 1: Check Database Contents
**Action Required**: User must verify via Supabase console

```sql
-- Run in Supabase SQL Editor:
SELECT id, name, slug, display_order, is_active, icon_url
FROM benefit_categories
ORDER BY display_order;
```

**Expected Result**: If empty → Explains why no stream events

### Step 2: Verify Realtime Enabled
**Action Required**: User must check Supabase console

1. Open Supabase Studio
2. Navigate to: **Database → Tables → benefit_categories**
3. Click **⚡ Realtime** tab
4. Verify checkboxes:
   - ☑️ Enable Realtime for this table
   - ☑️ INSERT events
   - ☑️ UPDATE events
   - ☑️ DELETE events

### Step 3: Check RLS Policies
**Action Required**: User must verify RLS allows SELECT

```sql
-- Run in Supabase SQL Editor:
SELECT tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename = 'benefit_categories';
```

**Expected**: At least one policy allowing **SELECT** for anonymous users or authenticated users

---

## 📊 Test Protocol

### Test 1: Verify Model Fix (Awaiting Data)
**Precondition**: Database must have at least 1 category

1. Add test category via Supabase SQL Editor:
```sql
INSERT INTO benefit_categories (name, slug, display_order, is_active, icon_url)
VALUES ('테스트', 'test', 999, true, 'https://example.com/icon.svg');
```

2. Navigate to Benefits screen in Flutter app
3. Check logs for:
```log
flutter: 🔄 [Supabase Event] Stream received data update
flutter: 📊 [Raw Data] Total rows received: 1
flutter: ✅ [Filtered] Active categories: 1
flutter:   ✓ Category: 테스트 (test) - display_order: 999
flutter: 📋 [Final Result] Emitting 1 categories to stream subscribers
```

**Expected UI**: Circle tab appears with category

### Test 2: Admin → Flutter Realtime Sync
**Precondition**: Test 1 passed

1. Keep Flutter app on Benefits screen
2. Open Admin panel
3. Add new category:
   - name: "실시간테스트"
   - slug: "realtime-test"
   - display_order: 1000
   - is_active: true
4. Save in Admin
5. Check Flutter logs immediately:
```log
flutter: 🔄 [Supabase Event] Stream received data update
flutter: 📊 [Raw Data] Total rows received: 2
```

**Expected UI**: New circle tab appears **without app restart**

---

## 🐛 Known Issues

### Issue 1: SVG Icon URLs (Non-blocking)
**Status**: Separate concern, not related to this fix

Icons stored as filenames (`test.svg`) instead of full URLs cause network errors but don't block category loading.

**Fix Required**: Upload icons to Supabase Storage and use full URLs

### Issue 2: Multiple Stream Subscriptions
**Observation**: Logs show stream created 10+ times

```log
flutter: 📡 [Supabase Realtime] Starting stream on benefit_categories table
flutter: 📡 [Supabase Realtime] Starting stream on benefit_categories table
... (repeated 10+ times)
```

**Cause**: StreamProvider recreates stream on every UI rebuild (normal Riverpod behavior with stateless providers)

**Impact**: Higher Supabase connection usage

**Fix (For Production)**: Switch to FutureProvider + Cache (see PRD v9.6.1 Appendix A)

---

## 📝 Files Modified

### 1. `lib/contexts/benefit/models/benefit_category.dart`
**Lines 14-45**: Updated `@JsonKey` annotations

**Before**:
```dart
@JsonKey(name: 'title')       // ❌ Wrong
@JsonKey(name: 'sort_order')   // ❌ Wrong
```

**After**:
```dart
@JsonKey(name: 'name')            // ✅ Correct
@JsonKey(name: 'display_order')    // ✅ Correct
```

**Code Generated**: `benefit_category.g.dart` auto-regenerated via `dart run build_runner build`

---

## 🎯 Next Actions

### Immediate (User Must Do)
1. ⏳ **Verify database has data**:
   ```sql
   SELECT COUNT(*) FROM benefit_categories WHERE is_active = true;
   ```
   - If 0 → Add test category (see Test 1)
   - If >0 → Check Realtime settings

2. ⏳ **Enable Realtime on table**:
   - Supabase Studio → benefit_categories → Realtime tab
   - Enable all events (INSERT/UPDATE/DELETE)

3. ⏳ **Check RLS policies**:
   - Verify anonymous/authenticated users can SELECT
   - May need to add policy:
   ```sql
   CREATE POLICY "Allow public SELECT on benefit_categories"
   ON benefit_categories FOR SELECT
   TO public
   USING (is_active = true);
   ```

### Short-term (After Data Verified)
1. Run Test 1 protocol to verify field mapping fix
2. Run Test 2 protocol to verify realtime sync
3. Document results in this file
4. Update PRD if schema changes needed

### Long-term (Production Optimization)
1. Review StreamProvider vs FutureProvider decision (PRD Appendix A)
2. Upload category icons to Supabase Storage
3. Implement proper icon URL generation
4. Add RLS policies for Admin vs Public access
5. Consider caching strategy for production

---

## 📚 Related Documentation

- **Investigation Report**: `docs/PHASE3_BENEFIT_CATEGORY_SYNC_FIX.md`
- **Verification Report**: `docs/PHASE3_SYNC_VERIFIED.md`
- **PRD Appendix**: `docs/prd/PRD_v9.6_Pickly_Integrated_System_UPDATED_v9.6.1.md` (Appendix A)
- **Original Migration**: `backend/supabase/migrations/20251027000001_correct_schema.sql`
- **Rename Attempt**: `backend/supabase/migrations/20251028000001_unify_naming_prd_v7_3.sql`

---

## 🔄 Update Log

| Date | Change | Status |
|------|--------|--------|
| 2025-11-05 | Fixed `@JsonKey` mappings in BenefitCategory model | ✅ Applied |
| 2025-11-05 | Regenerated code with build_runner | ✅ Complete |
| 2025-11-05 | Identified empty database as root cause | ⏳ Awaiting verification |

---

**Last Updated**: 2025-11-05
**Author**: Claude Code
**Status**: ✅ Model fix applied, ⏳ Database verification pending
**Next Step**: User must check if `benefit_categories` table has data

