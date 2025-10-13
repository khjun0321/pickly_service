# Database Quickstart - Region Selection Feature

## 🚀 Quick Setup (5 minutes)

### 1. Run Migration

```bash
# Option A: Via Supabase CLI
supabase db reset
supabase db push

# Option B: Via psql
psql -h db.PROJECT_ID.supabase.co -U postgres -d postgres \
  -f docs/database/migrations/002_regions.sql \
  -f docs/database/seeds/regions.sql
```

### 2. Verify Installation

```sql
-- Should return 18 regions
SELECT COUNT(*) FROM public.regions WHERE is_active = true;

-- Check RLS is enabled
SELECT tablename, rowsecurity FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('regions', 'user_regions', 'user_profiles');
```

---

## 📱 Flutter/Dart Integration

### Setup Supabase Client

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
```

### Common Operations

#### 1. Fetch All Regions

```dart
Future<List<Region>> fetchRegions() async {
  final response = await supabase
      .from('regions')
      .select()
      .eq('is_active', true)
      .order('sort_order');

  return (response as List)
      .map((json) => Region.fromJson(json))
      .toList();
}
```

#### 2. Get User's Selected Regions

```dart
Future<List<Region>> getUserRegions(String userId) async {
  final response = await supabase
      .rpc('get_user_regions', params: {'p_user_id': userId});

  return (response as List)
      .map((json) => Region.fromJson(json))
      .toList();
}
```

#### 3. Update User Regions

```dart
Future<void> updateUserRegions(String userId, List<String> regionIds) async {
  await supabase.rpc('set_user_regions', params: {
    'p_user_id': userId,
    'p_region_ids': regionIds
  });
}
```

#### 4. Complete Onboarding

```dart
Future<void> completeOnboarding(String userId, String? ageCategoryId) async {
  await supabase.rpc('complete_onboarding', params: {
    'p_user_id': userId,
    'p_age_category_id': ageCategoryId
  });
}
```

---

## 🏗️ Data Models

### Region Model

```dart
class Region {
  final String id;
  final String code;
  final String name;
  final int sortOrder;
  final bool isActive;

  Region({
    required this.id,
    required this.code,
    required this.name,
    required this.sortOrder,
    required this.isActive,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      sortOrder: json['sort_order'] as int,
      isActive: json['is_active'] as bool,
    );
  }
}
```

### User Profile Model

```dart
class UserProfile {
  final String id;
  final String? selectedAgeCategoryId;
  final bool onboardingCompleted;
  final DateTime? onboardingCompletedAt;

  UserProfile({
    required this.id,
    this.selectedAgeCategoryId,
    required this.onboardingCompleted,
    this.onboardingCompletedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      selectedAgeCategoryId: json['selected_age_category_id'] as String?,
      onboardingCompleted: json['onboarding_completed'] as bool,
      onboardingCompletedAt: json['onboarding_completed_at'] != null
          ? DateTime.parse(json['onboarding_completed_at'] as String)
          : null,
    );
  }
}
```

---

## 🔒 Security (RLS Policies)

### What Users CAN Do:
- ✅ View all active regions
- ✅ View their own region selections
- ✅ Add/remove their own region selections
- ✅ View/update their own profile

### What Users CANNOT Do:
- ❌ View other users' region selections
- ❌ Modify region master data
- ❌ View/modify other users' profiles

---

## 🧪 Testing

### Test Data Setup

```sql
-- Create test user profile (replace with real user ID)
INSERT INTO public.user_profiles (id, onboarding_completed)
VALUES ('your-test-user-uuid', false)
ON CONFLICT (id) DO NOTHING;

-- Add test region selections
INSERT INTO public.user_regions (user_id, region_id)
SELECT 'your-test-user-uuid', id
FROM public.regions
WHERE code IN ('seoul', 'gyeonggi', 'incheon');
```

### Test Queries

```sql
-- Verify user regions
SELECT * FROM get_user_regions('your-test-user-uuid');

-- Test set regions
SELECT set_user_regions(
  'your-test-user-uuid',
  ARRAY(SELECT id FROM regions WHERE code IN ('seoul', 'busan'))::UUID[]
);

-- Test complete onboarding
SELECT complete_onboarding('your-test-user-uuid', 'age-category-uuid');
```

---

## 🐛 Troubleshooting

### Problem: "permission denied for table regions"
**Solution:** Check RLS policies are enabled and user is authenticated.

```sql
-- Verify RLS is enabled
SELECT tablename, rowsecurity FROM pg_tables WHERE tablename = 'regions';

-- Check user authentication
SELECT auth.uid(); -- Should return user UUID
```

### Problem: "duplicate key value violates unique constraint"
**Solution:** User already selected that region.

```dart
// Use set_user_regions to replace all selections
await supabase.rpc('set_user_regions', params: {
  'p_user_id': userId,
  'p_region_ids': regionIds
});
```

### Problem: "null value in column 'onboarding_completed_at'"
**Solution:** Don't set completed_at manually, use complete_onboarding function.

```dart
// ✅ Correct
await supabase.rpc('complete_onboarding', params: {'p_user_id': userId});

// ❌ Wrong
await supabase.from('user_profiles').update({
  'onboarding_completed': true,
  'onboarding_completed_at': DateTime.now().toIso8601String()
});
```

---

## 📊 Performance Tips

1. **Use RPC functions** for complex operations (atomic + faster)
2. **Batch region fetches** - Don't fetch one at a time
3. **Cache regions** - They rarely change, cache client-side
4. **Use select()** with specific columns to reduce payload

```dart
// ✅ Good: Select only needed columns
final regions = await supabase
    .from('regions')
    .select('id, code, name, sort_order')
    .eq('is_active', true);

// ❌ Bad: Fetching all columns
final regions = await supabase
    .from('regions')
    .select();
```

---

## 📚 Additional Resources

- **Full Schema Documentation:** [schema-diagram.md](./schema-diagram.md)
- **Migration SQL:** [002_regions.sql](./migrations/002_regions.sql)
- **Seed Data:** [regions.sql](./seeds/regions.sql)
- **Supabase RLS Guide:** https://supabase.com/docs/guides/auth/row-level-security

---

## ✅ Checklist

- [ ] Migration executed successfully
- [ ] 18 regions seeded
- [ ] RLS policies enabled on all tables
- [ ] Helper functions tested
- [ ] Flutter models created
- [ ] Supabase client configured
- [ ] Test user profile created
- [ ] Region selection UI integrated
- [ ] Onboarding completion tested

---

**Need Help?** Check the full documentation in `schema-diagram.md` or contact the System Architect team.
