# Phase 6.3 Validation Final Task

**Task ID:** Phase 6.3 Validation Final
**Title:** ✅ Fix SVG Path, Stream Caching, and Admin Auth (PRD v9.8.3)
**Date:** 2025-11-05
**Status:** 🟡 **IN PROGRESS**

---

## 🎯 Objective

Complete Phase 6.3 by fixing three critical issues:

1. **fire.svg Asset Display** - Fix local asset path recognition
2. **Benefit Categories 써클탭** - Fix stream duplication and enable display
3. **Admin Login Error** - Fix authentication policy and session renewal

---

## 📘 References

### Documentation
- `/docs/PHASE6_3_VALIDATION_TASK.md` - Original validation task
- `/docs/PHASE6_3_REBUILD_VERIFICATION_REPORT.md` - Rebuild results
- `/docs/PHASE6_3_REGIONS_AND_REALTIME_STATUS.md` - Status analysis

### Code Files
- `/packages/pickly_design_system/assets/icons/fire.svg` - Asset file
- `/apps/pickly_mobile/lib/contexts/benefit/repositories/benefit_repository.dart` - Stream fix
- `/backend/supabase/migrations/20251107_disable_all_rls.sql` - RLS policies

### Database
- `public.benefit_categories` - 10 active categories
- `public.regions` - 18 Korean regions
- `auth.users` - Admin users

---

## 🧱 Implementation Steps

### 1️⃣ Fix fire.svg Asset Display

**Problem:**
```
[ERROR] Unable to load asset: "packages/pickly_design_system/assets/icons/fire.svg"
```

**Root Cause:**
Code is trying to load via `SvgPicture.network('fire.svg')` instead of local asset path.

**Solution:**

**Step 1: Verify Asset Exists**
```bash
ls -la /Users/kwonhyunjun/Desktop/pickly_service/packages/pickly_design_system/assets/icons/fire.svg
```

**Step 2: Verify pubspec.yaml**
```yaml
# File: /packages/pickly_design_system/pubspec.yaml
flutter:
  uses-material-design: true
  assets:
    - assets/icons/  # ✅ Already includes fire.svg
```

**Step 3: Find Usage in Code**
```bash
# Search for fire.svg usage
cd /Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_mobile
grep -r "fire\.svg" lib/
```

**Step 4: Fix Code to Use Local Asset**
```dart
// ❌ WRONG (network loader)
SvgPicture.network('fire.svg')

// ✅ CORRECT (local asset)
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  'packages/pickly_design_system/assets/icons/fire.svg',
  width: 24,
  height: 24,
  colorFilter: ColorFilter.mode(
    Theme.of(context).colorScheme.primary,
    BlendMode.srcIn,
  ),
)
```

**Step 5: Hot Reload to Test**
```bash
# In running Flutter app
printf "r" | nc localhost 58200
```

---

### 2️⃣ Fix Benefit Categories Stream (써클탭 표시)

**Problem:**
```
flutter: 📡 [Supabase Realtime] Starting stream on benefit_categories table
flutter: 📡 [Supabase Realtime] Starting stream on benefit_categories table
flutter: 📡 [Supabase Realtime] Starting stream on benefit_categories table
... (11 times total)
```

**Impact:**
- Multiple duplicate subscriptions
- Memory leak
- 써클탭 (category circles) not displaying

**Root Cause:**
`watchCategories()` creates new stream on every call, no caching.

**Solution:**

**File:** `/apps/pickly_mobile/lib/contexts/benefit/repositories/benefit_repository.dart`

**Current Code:**
```dart
class BenefitRepository {
  final SupabaseClient _client;
  const BenefitRepository(this._client);

  // ❌ Creates new stream every time
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
}
```

**Fixed Code:**
```dart
class BenefitRepository {
  final SupabaseClient _client;

  // ✅ Add stream cache
  Stream<List<BenefitCategory>>? _cachedStream;

  const BenefitRepository(this._client);

  Stream<List<BenefitCategory>> watchCategories() {
    // Return cached stream if exists
    if (_cachedStream != null) {
      print('🔄 [Stream Cache] Returning existing categories stream');
      return _cachedStream!;
    }

    print('📡 [Supabase Realtime] Starting NEW stream on benefit_categories table');

    // Create and cache stream
    _cachedStream = _client
        .from('benefit_categories')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('display_order', ascending: true)
        .map((data) => data.map((json) =>
            BenefitCategory.fromJson(json as Map<String, dynamic>)).toList())
        .asBroadcastStream(); // ✅ Make it shareable!

    return _cachedStream!;
  }

  // ✅ Add dispose method
  void dispose() {
    _cachedStream = null;
  }
}
```

**Alternative (Simpler) Implementation:**
```dart
class BenefitRepository {
  final SupabaseClient _client;
  Stream<List<BenefitCategory>>? _cachedStream;

  const BenefitRepository(this._client);

  // ✅ Use null-coalescing operator for automatic caching
  Stream<List<BenefitCategory>> watchCategories() {
    _cachedStream ??= _client
        .from('benefit_categories')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .map((rows) => rows
            .map((json) => BenefitCategory.fromJson(json as Map<String, dynamic>))
            .toList())
        .asBroadcastStream();

    return _cachedStream!;
  }
}
```

**Verification Steps:**

1. Apply the fix to benefit_repository.dart
2. Hot restart app: `printf "R" | nc localhost 58200`
3. Navigate to 혜택 (Benefits) tab
4. Check logs - should see stream message ONLY ONCE
5. Verify 써클탭 (category circles) display at top
6. Tap a category - verify navigation works

**Expected Logs After Fix:**
```
flutter: 📡 [Supabase Realtime] Starting NEW stream on benefit_categories table
(Should appear ONLY ONCE)
```

---

### 3️⃣ Fix Admin Authentication

**Problem:**
Admin login fails or session expires quickly.

**Potential Issues:**

1. **RLS Policies Too Restrictive**
2. **Session Not Persisting**
3. **Auth Tokens Expiring**

**Diagnosis Steps:**

**Step 1: Check Admin User Exists**
```bash
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
"SELECT id, email, created_at FROM auth.users WHERE email LIKE '%admin%';"
```

**Step 2: Check RLS Policies**
```bash
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
"SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;"
```

**Step 3: Verify Auth Configuration**
```bash
# Check Supabase config
cat /Users/kwonhyunjun/Desktop/pickly_service/backend/supabase/config.toml | grep -A 10 "\[auth\]"
```

**Potential Fixes:**

**Option A: Temporary - Disable RLS for Testing**
```sql
-- File: /backend/supabase/migrations/20251107_disable_all_rls.sql
-- ⚠️ ONLY FOR DEVELOPMENT TESTING

ALTER TABLE public.benefit_categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.benefit_subcategories DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.regions DISABLE ROW LEVEL SECURITY;
```

**Option B: Fix Admin Role Check**
```sql
-- Add proper admin role check function
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM auth.users
    WHERE id = auth.uid()
    AND email LIKE '%admin%'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update policies to use admin check
DROP POLICY IF EXISTS "Admins full access" ON public.benefit_categories;
CREATE POLICY "Admins full access"
ON public.benefit_categories
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());
```

**Option C: Fix Session Persistence (React Admin)**
```typescript
// File: /apps/pickly_admin/src/hooks/useAuth.ts

export const useAuth = () => {
  const { data: session, error } = useSession();

  useEffect(() => {
    // Listen for auth state changes
    const { data: authListener } = supabase.auth.onAuthStateChange(
      (event, session) => {
        if (event === 'SIGNED_IN') {
          console.log('✅ Admin signed in:', session?.user?.email);
        }
        if (event === 'TOKEN_REFRESHED') {
          console.log('🔄 Token refreshed');
        }
        if (event === 'SIGNED_OUT') {
          console.log('⚠️ Admin signed out');
          window.location.href = '/login';
        }
      }
    );

    return () => {
      authListener?.subscription.unsubscribe();
    };
  }, []);

  return { session, error };
};
```

---

## ✅ Success Criteria

### 1. fire.svg Asset
- [ ] Asset loads without errors
- [ ] Icon displays correctly in UI
- [ ] Hot reload works without rebuild

### 2. Benefit Categories Stream
- [ ] Stream subscription message appears ONLY ONCE
- [ ] 써클탭 (category circles) display at top of Benefits tab
- [ ] All 10 active categories visible
- [ ] Category tap navigation works
- [ ] No memory leaks or duplicate subscriptions

### 3. Admin Authentication
- [ ] Admin can login successfully
- [ ] Session persists across page reloads
- [ ] RLS policies allow admin operations
- [ ] No unauthorized access errors

---

## 🧪 Testing Procedures

### Test 1: Fire.svg Asset

```bash
# 1. Search for fire.svg usage
cd /Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_mobile
grep -r "fire\.svg" lib/

# 2. If found, update code to use local asset
# (See Step 4 in Implementation above)

# 3. Hot reload
printf "r" | nc localhost 58200

# 4. Verify no errors in logs
tail -f /tmp/phase6_3_rebuild_verification.log | grep -i "fire"
```

**Expected Result:**
No errors, icon displays correctly.

---

### Test 2: Benefit Categories Stream

```bash
# 1. Apply stream caching fix to benefit_repository.dart

# 2. Hot restart app
printf "R" | nc localhost 58200

# 3. Navigate to Benefits tab in simulator
# (User must manually tap on 혜택 tab)

# 4. Watch logs for stream subscription
tail -f /tmp/phase6_3_rebuild_verification.log | grep -E "(stream|benefit_categories)"
```

**Expected Logs:**
```
flutter: 📡 [Supabase Realtime] Starting NEW stream on benefit_categories table
(ONLY ONCE)
```

**Visual Verification:**
- 써클탭 (category circles) appear at top
- All categories clickable
- Category detail page loads

---

### Test 3: Admin Authentication

```bash
# 1. Start admin app
cd /Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_admin
npm run dev

# 2. Open browser: http://localhost:5173

# 3. Login with admin credentials
# Email: admin@pickly.io
# Password: [admin password]

# 4. Check browser console for auth messages

# 5. Try to create/update a benefit category
```

**Expected Result:**
- Login successful
- Session persists
- CRUD operations work
- No RLS errors

---

## 🐛 Troubleshooting

### Issue: Stream Still Duplicating

**Symptom:**
Still seeing 11 stream subscription messages.

**Solutions:**

1. **Check Provider Usage:**
```bash
grep -r "benefitCategoriesProvider" lib/
```

2. **Add autoDispose:**
```dart
@riverpod
Stream<List<BenefitCategory>> benefitCategories(Ref ref) {
  final repository = ref.watch(benefitRepositoryProvider);

  ref.onDispose(() {
    repository.dispose();
  });

  return repository.watchCategories();
}
```

3. **Use keepAlive:**
```dart
@Riverpod(keepAlive: true)
Stream<List<BenefitCategory>> benefitCategories(Ref ref) {
  final repository = ref.watch(benefitRepositoryProvider);
  return repository.watchCategories();
}
```

---

### Issue: fire.svg Still Not Loading

**Symptom:**
```
[ERROR] Unable to load asset: "packages/pickly_design_system/assets/icons/fire.svg"
```

**Solutions:**

1. **Full rebuild required for new assets:**
```bash
cd /Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_mobile
flutter clean
flutter pub get
flutter run -d E7F1E329-C4FF-4224-94F9-408F08A4C96C
```

2. **Check if fire.svg is actually used:**
```bash
grep -r "fire" lib/ | grep -v ".g.dart"
```

3. **If not used, this is not a blocker for Phase 6.3**

---

### Issue: Admin Login Still Failing

**Symptom:**
Unauthorized errors or session expires immediately.

**Solutions:**

1. **Check JWT secret:**
```bash
cat backend/supabase/.env | grep JWT_SECRET
```

2. **Verify admin user:**
```sql
SELECT id, email, encrypted_password, created_at
FROM auth.users
WHERE email = 'admin@pickly.io';
```

3. **Reset admin password:**
```sql
-- In Supabase dashboard or psql
UPDATE auth.users
SET encrypted_password = crypt('newpassword', gen_salt('bf'))
WHERE email = 'admin@pickly.io';
```

4. **Disable RLS temporarily:**
```sql
ALTER TABLE public.benefit_categories DISABLE ROW LEVEL SECURITY;
```

---

## 📊 Progress Tracking

### Implementation Checklist

- [ ] **1.1** Search for fire.svg usage in codebase
- [ ] **1.2** Update code to use local asset path
- [ ] **1.3** Hot reload and verify
- [ ] **2.1** Apply stream caching to benefit_repository.dart
- [ ] **2.2** Hot restart app
- [ ] **2.3** Navigate to Benefits tab
- [ ] **2.4** Verify single stream subscription
- [ ] **2.5** Verify 써클탭 displays
- [ ] **3.1** Diagnose admin auth issue
- [ ] **3.2** Apply appropriate fix (RLS/session/token)
- [ ] **3.3** Test admin login
- [ ] **3.4** Verify CRUD operations

### Testing Checklist

- [ ] fire.svg displays without errors
- [ ] Benefit categories stream initializes once
- [ ] 써클탭 appears and is functional
- [ ] Admin can login successfully
- [ ] Admin session persists
- [ ] All CRUD operations work

---

## 🔗 Related Documents

- `/docs/PHASE6_2_ADMIN_UI_COMPLETE.md` - Admin UI completion
- `/docs/PHASE6_3_TASK_REALTIME_REGIONS_FIX.md` - Original Phase 6.3 task
- `/docs/PHASE6_3_REGIONS_AND_REALTIME_STATUS.md` - Status analysis
- `/docs/PHASE6_3_VALIDATION_TASK.md` - Validation procedures
- `/docs/PHASE6_3_REBUILD_VERIFICATION_REPORT.md` - Rebuild results

---

## 📝 Notes

### Out of Scope for Phase 6.3

The following issues were discovered but are NOT part of Phase 6.3:

1. **Age Category Icon URLs**
   - Database contains filenames instead of full URLs
   - Needs separate data migration task
   - Recommend Phase 6.4

2. **Regions Display**
   - Awaiting manual testing
   - Will verify in Phase 6.3 completion report

---

**Document Version:** 1.0
**Last Updated:** 2025-11-05 20:00 KST
**Author:** Claude Code
**Status:** 🟡 **TASK CREATED** - Ready for implementation
