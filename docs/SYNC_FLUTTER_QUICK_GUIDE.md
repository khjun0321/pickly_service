# Flutter Realtime Sync - Quick Guide

**PRD v9.6.1 Phase 3**
**Date**: 2025-11-04
**Status**: ✅ Ready for Testing

---

## 🎯 What Changed

Flutter 앱이 이제 Admin 패널의 카테고리 변경사항을 **실시간으로** 받아옵니다.
앱 재시작 없이 즉시 반영됩니다!

---

## 📝 Files Updated

### 1. Repository (Stream Method Added)
**File**: `lib/contexts/benefit/repositories/benefit_repository.dart`

```dart
Stream<List<BenefitCategory>> watchCategories() {
  return _client
      .from('benefit_categories')
      .stream(primaryKey: ['id'])
      .eq('is_active', true)
      .order('display_order', ascending: true)
      .map((data) => data
          .map((json) => BenefitCategory.fromJson(json))
          .toList());
}
```

### 2. Provider (NEW)
**File**: `lib/features/benefits/providers/benefit_category_provider.dart`

```dart
final benefitCategoriesStreamProvider = StreamProvider<List<BenefitCategory>>((ref) {
  final repository = ref.watch(benefitRepositoryProvider);
  return repository.watchCategories();
});
```

---

## 🔧 How to Use

### In Your Widget

**Old Way** (one-time fetch):
```dart
// DON'T USE THIS ANYMORE
final repository = ref.watch(benefitRepositoryProvider);
final categories = await repository.getCategories();
```

**New Way** (realtime stream):
```dart
import 'package:pickly_mobile/features/benefits/providers/benefit_category_provider.dart';

class CategoryTabs extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(benefitCategoriesStreamProvider);

    return categoriesAsync.when(
      data: (categories) => ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, i) => CategoryTab(categories[i]),
      ),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

### Quick Access (No Loading/Error Handling)

```dart
// Just give me the list (empty if loading/error)
final categories = ref.watch(categoriesStreamListProvider);

// Get single category
final category = ref.watch(categoryStreamByIdProvider('id'));

// Check if categories exist
final hasCategories = ref.watch(hasCategoriesStreamProvider);
```

---

## 🧪 Testing Steps

1. **Run Flutter app**
   ```bash
   cd apps/pickly_mobile
   flutter run
   ```

2. **Open Admin panel**
   - URL: http://localhost:5174/
   - Login: admin@pickly.com / admin1234
   - Go to: Benefit Categories

3. **Create new category**
   - Click "Add New Category"
   - Fill form and save

4. **Check Flutter app** (DON'T RESTART)
   - ✅ Expected: New category appears in circle tabs within 1-2 seconds

5. **Edit category**
   - Change name/icon in Admin
   - Save

6. **Check Flutter app** (DON'T RESTART)
   - ✅ Expected: Category updates instantly

7. **Delete category**
   - Delete in Admin

8. **Check Flutter app** (DON'T RESTART)
   - ✅ Expected: Category disappears instantly

---

## 📊 What to Watch For

### ✅ Expected Behavior
- New categories appear **within 1-2 seconds**
- Updates reflect **immediately**
- Deletes remove category **instantly**
- No app restart needed
- Smooth animations when list changes

### ❌ If Not Working
1. Check Supabase is running
2. Check migration applied:
   ```sql
   SELECT tablename FROM pg_publication_tables WHERE pubname = 'supabase_realtime';
   -- Should show: benefit_categories
   ```
3. Check Flutter console for errors
4. Restart Flutter app to clear cache

---

## 🔗 Full Documentation

- **Technical Details**: `docs/SYNC_FLUTTER_UPDATE_REPORT.md`
- **Backend Fix**: `docs/SYNC_FIX_REPORT.md`
- **Quick Summary**: `docs/SYNC_FIX_SUMMARY.md`

---

## 💡 Provider Cheat Sheet

```dart
// Main stream (with loading/error states)
benefitCategoriesStreamProvider

// Simple list (no loading/error)
categoriesStreamListProvider

// Single category by ID
categoryStreamByIdProvider('uuid')

// Single category by slug
categoryStreamBySlugProvider('housing')

// Loading state
categoriesStreamLoadingProvider

// Error state
categoriesStreamErrorProvider

// Count
categoriesStreamCountProvider

// Check if exists
hasCategoriesStreamProvider

// All slugs
categoryStreamSlugsProvider

// All IDs
categoryStreamIdsProvider
```

---

**Quick Start**: Import `benefit_category_provider.dart` and use `benefitCategoriesStreamProvider` in your widgets!

🎉 **Realtime sync is ready to test!**
