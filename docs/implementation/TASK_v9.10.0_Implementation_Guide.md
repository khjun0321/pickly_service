# 🚀 PRD v9.10.0 — Flutter Subcategory Filter Implementation Guide

**Status:** 📋 Ready for Implementation
**Branch:** `feat/v9.10.0-subcategory-filter`
**Target:** Dynamic database-driven subcategory filtering
**Timeline:** 1 week (~30 hours)

---

## 🔒 Non-Negotiable Guardrails

### ❌ ABSOLUTELY FORBIDDEN

1. **NO UI/Design Changes**
   - ❌ Do NOT modify colors, spacing, typography
   - ❌ Do NOT change existing widget layouts
   - ❌ Do NOT create new design system components
   - ✅ ONLY use existing `pickly_design_system` components

2. **NO Schema Changes**
   - ❌ Do NOT modify migrations (except new ones if absolutely needed)
   - ❌ Do NOT alter existing seed data structure
   - ✅ ONLY read from `benefit_subcategories` table

3. **NO Scope Creep**
   - ❌ Do NOT refactor unrelated code
   - ❌ Do NOT "improve" existing features
   - ✅ ONLY implement subcategory filter functionality

### ✅ REQUIRED PATTERNS

1. **B-Lite Pattern** (NOT Freezed)
   - Use `Equatable` + `json_serializable`
   - Follow existing `BenefitCategory` model structure
   - Reason: Freezed 3.2.3 mixin generation bug

2. **Existing Design Components**
   - Use `BottomSheet` from Material
   - Use `FilterChip` or `ChoiceChip` for selections
   - Use `Card` for subcategory items
   - Follow spacing: `EdgeInsets` values from existing code

3. **Icon Resolution Priority**
   - 1st: `iconUrl` (from Supabase Storage)
   - 2nd: `iconName` → `MediaResolver` → local SVG
   - 3rd: Default fallback icon

---

## 🌿 Branch Strategy

### Create Feature Branch

```bash
cd /Users/kwonhyunjun/Desktop/pickly_service
git checkout fix/v8.0-rebuild
git pull origin fix/v8.0-rebuild
git checkout -b feat/v9.10.0-subcategory-filter
```

### Commit Convention

```
feat(v9.10.0): <specific change>

Examples:
- feat(v9.10.0): add BenefitSubcategory model with B-Lite pattern
- feat(v9.10.0): extend repository with subcategory fetch methods
- feat(v9.10.0): implement FilterBottomSheet UI component
- feat(v9.10.0): integrate dynamic filters into BenefitsScreen
```

---

## 🧱 Implementation Tasks (7 Components)

### Task 1: Create BenefitSubcategory Model

**File:** `apps/pickly_mobile/lib/contexts/benefit/models/benefit_subcategory.dart`

**Implementation:**

```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'benefit_subcategory.g.dart';

/// BenefitSubcategory - Database-driven filter model
///
/// Maps to: benefit_subcategories table
/// PRD: v9.10.0 - Dynamic subcategory filtering
/// Pattern: B-Lite (Equatable + json_serializable)
@JsonSerializable()
class BenefitSubcategory extends Equatable {
  final String id;

  @JsonKey(name: 'category_id')
  final String? categoryId;

  final String name;
  final String slug;

  @JsonKey(name: 'sort_order')
  final int sortOrder;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'icon_url')
  final String? iconUrl;

  @JsonKey(name: 'icon_name')
  final String? iconName;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const BenefitSubcategory({
    required this.id,
    this.categoryId,
    required this.name,
    required this.slug,
    this.sortOrder = 0,
    this.isActive = true,
    this.iconUrl,
    this.iconName,
    required this.createdAt,
    this.updatedAt,
  });

  factory BenefitSubcategory.fromJson(Map<String, dynamic> json) =>
      _$BenefitSubcategoryFromJson(json);

  Map<String, dynamic> toJson() => _$BenefitSubcategoryToJson(this);

  BenefitSubcategory copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? slug,
    int? sortOrder,
    bool? isActive,
    String? iconUrl,
    String? iconName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BenefitSubcategory(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      iconUrl: iconUrl ?? this.iconUrl,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        name,
        slug,
        sortOrder,
        isActive,
        iconUrl,
        iconName,
        createdAt,
        updatedAt,
      ];

  @override
  bool get stringify => true;
}
```

**Run Code Generation:**

```bash
cd apps/pickly_mobile
dart run build_runner build --delete-conflicting-outputs
```

**Verify Generated File:**
- Check `benefit_subcategory.g.dart` created
- Verify no compilation errors

---

### Task 2: Extend BenefitRepository

**File:** `apps/pickly_mobile/lib/contexts/benefit/repositories/benefit_repository.dart`

**Add Import (after line 6):**

```dart
import '../models/benefit_subcategory.dart';
```

**Add Methods (after line 162, after `dispose()` method):**

```dart
// ============================================================================
// SUBCATEGORIES (PRD v9.10.0)
// ============================================================================

/// Fetch subcategories for a specific category
///
/// Returns active subcategories sorted by sort_order.
/// Used for filter bottom sheet population.
Future<List<BenefitSubcategory>> fetchSubcategoriesByCategory(
  String categoryId, {
  bool onlyActive = true,
}) async {
  try {
    var query = _client
        .from('benefit_subcategories')
        .select()
        .eq('category_id', categoryId)
        .order('sort_order', ascending: true);

    if (onlyActive) {
      query = query.eq('is_active', true);
    }

    final response = await query;

    return (response as List)
        .map((json) => BenefitSubcategory.fromJson(json as Map<String, dynamic>))
        .toList();
  } on PostgrestException catch (e) {
    throw AnnouncementNetworkException(e.message);
  } catch (e, stackTrace) {
    throw AnnouncementException(e.toString(), stackTrace);
  }
}

/// Watch subcategories with Realtime updates
///
/// Automatically syncs when Admin modifies subcategories.
/// Used for filter UI that needs live updates.
Stream<List<BenefitSubcategory>> streamSubcategoriesByCategory(
  String categoryId, {
  bool onlyActive = true,
}) {
  print('🌊 [BenefitRepository] streamSubcategoriesByCategory($categoryId)');

  return _client
      .from('benefit_subcategories')
      .stream(primaryKey: ['id'])
      .order('sort_order', ascending: true)
      .handleError((error, stackTrace) {
        print('❌ [Stream Error] Subcategories: $error');
      })
      .map((data) {
        var filtered = data.where((json) =>
            json['category_id'] == categoryId &&
            (!onlyActive || json['is_active'] == true));

        final subcategories = filtered
            .map((json) => BenefitSubcategory.fromJson(json as Map<String, dynamic>))
            .toList();

        print('✅ [Subcategories] Loaded ${subcategories.length} for category $categoryId');

        return subcategories;
      })
      .asBroadcastStream();
}

/// Fetch all subcategories grouped by category
///
/// Useful for bulk loading or search functionality.
Future<Map<String, List<BenefitSubcategory>>> fetchAllSubcategoriesGrouped({
  bool onlyActive = true,
}) async {
  try {
    var query = _client
        .from('benefit_subcategories')
        .select()
        .order('sort_order', ascending: true);

    if (onlyActive) {
      query = query.eq('is_active', true);
    }

    final response = await query;

    final subcategories = (response as List)
        .map((json) => BenefitSubcategory.fromJson(json as Map<String, dynamic>))
        .toList();

    // Group by categoryId
    final Map<String, List<BenefitSubcategory>> grouped = {};
    for (final subcategory in subcategories) {
      final categoryId = subcategory.categoryId;
      if (categoryId != null) {
        grouped.putIfAbsent(categoryId, () => []).add(subcategory);
      }
    }

    return grouped;
  } on PostgrestException catch (e) {
    throw AnnouncementNetworkException(e.message);
  } catch (e, stackTrace) {
    throw AnnouncementException(e.toString(), stackTrace);
  }
}
```

---

### Task 3: Update Announcement Fetching with Subcategory Filter

**File:** `apps/pickly_mobile/lib/contexts/benefit/repositories/benefit_repository.dart`

**Modify `getAnnouncementsByCategory` method (line 266-290):**

```dart
/// Get announcements by category with optional subcategory filtering
///
/// PRD v9.10.0: Added subcategoryIds parameter for hierarchical filtering
Future<List<Announcement>> getAnnouncementsByCategory(
  String categoryId, {
  List<String>? subcategoryIds, // ← NEW PARAMETER
  int limit = 50,
  int offset = 0,
}) async {
  try {
    var queryBuilder = _client
        .from('benefit_announcements')
        .select()
        .eq('category_id', categoryId)
        .eq('status', 'published');

    // ← NEW: Filter by subcategory IDs if provided
    if (subcategoryIds != null && subcategoryIds.isNotEmpty) {
      queryBuilder = queryBuilder.in_('subcategory_id', subcategoryIds);
    }

    final response = await queryBuilder
        .order('sort_order', ascending: true)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
        .toList();
  } on PostgrestException catch (e) {
    throw AnnouncementNetworkException(e.message);
  } catch (e, stackTrace) {
    throw AnnouncementException(e.toString(), stackTrace);
  }
}
```

**Also update stream method `watchAnnouncementsByCategory` (line 176-188):**

```dart
/// Watch announcements by category with optional subcategory filter
///
/// PRD v9.10.0: Added subcategoryIds parameter
Stream<List<Announcement>> watchAnnouncementsByCategory(
  String categoryId, {
  List<String>? subcategoryIds, // ← NEW PARAMETER
}) {
  return _client
      .from('benefit_announcements')
      .stream(primaryKey: ['id'])
      .order('sort_order', ascending: true)
      .order('created_at', ascending: false)
      .map((data) {
        var filtered = data.where((json) =>
            json['category_id'] == categoryId &&
            json['status'] == 'published');

        // ← NEW: Apply subcategory filter
        if (subcategoryIds != null && subcategoryIds.isNotEmpty) {
          filtered = filtered.where((json) =>
              subcategoryIds.contains(json['subcategory_id']));
        }

        return filtered
            .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
            .toList();
      });
}
```

---

### Task 4: Create Subcategory Providers

**File:** `apps/pickly_mobile/lib/contexts/benefit/providers/subcategory_providers.dart` (NEW)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pickly_mobile/contexts/benefit/models/benefit_subcategory.dart';
import 'package:pickly_mobile/contexts/benefit/repositories/benefit_repository.dart';

part 'subcategory_providers.g.dart';

/// Stream provider for subcategories of a specific category
///
/// Provides realtime updates when Admin modifies subcategories.
/// Auto-refreshes when parent category changes.
///
/// Usage:
/// ```dart
/// final subcategoriesAsync = ref.watch(subcategoriesStreamProvider(categoryId));
/// ```
@riverpod
Stream<List<BenefitSubcategory>> subcategoriesStream(
  Ref ref,
  String categoryId,
) {
  final repository = ref.watch(benefitRepositoryProvider);
  return repository.streamSubcategoriesByCategory(categoryId);
}

/// Future provider for one-time fetch of subcategories
///
/// Use when you don't need realtime updates.
@riverpod
Future<List<BenefitSubcategory>> subcategoriesFuture(
  Ref ref,
  String categoryId,
) async {
  final repository = ref.watch(benefitRepositoryProvider);
  return repository.fetchSubcategoriesByCategory(categoryId);
}

/// Provider for all subcategories grouped by category
///
/// Useful for search/filter pre-loading.
@riverpod
Future<Map<String, List<BenefitSubcategory>>> allSubcategoriesGrouped(
  Ref ref,
) async {
  final repository = ref.watch(benefitRepositoryProvider);
  return repository.fetchAllSubcategoriesGrouped();
}

/// State provider for selected subcategory IDs (multi-select filter)
///
/// Stores user's filter selections as Set<String> of subcategory IDs.
///
/// Usage:
/// ```dart
/// // Read selected IDs
/// final selectedIds = ref.watch(selectedSubcategoryIdsProvider);
///
/// // Toggle selection
/// ref.read(selectedSubcategoryIdsProvider.notifier).state = {...selectedIds, newId};
///
/// // Clear all
/// ref.read(selectedSubcategoryIdsProvider.notifier).state = {};
/// ```
final selectedSubcategoryIdsProvider = StateProvider<Set<String>>((ref) => {});
```

**Run Code Generation:**

```bash
cd apps/pickly_mobile
dart run build_runner build --delete-conflicting-outputs
```

---

### Task 5: Create FilterBottomSheet UI Component

**File:** `apps/pickly_mobile/lib/features/benefits/widgets/filter_bottom_sheet.dart` (NEW)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_mobile/core/utils/media_resolver.dart';
import 'package:pickly_mobile/contexts/benefit/models/benefit_category.dart';
import 'package:pickly_mobile/contexts/benefit/models/benefit_subcategory.dart';
import 'package:pickly_mobile/contexts/benefit/providers/subcategory_providers.dart';

/// FilterBottomSheet - Hierarchical subcategory filter UI
///
/// PRD v9.10.0: Dynamic database-driven filter selection
///
/// User Flow:
/// 1. User taps filter button
/// 2. Bottom sheet opens
/// 3. Shows subcategories for current category
/// 4. User multi-selects subcategories
/// 5. Taps "적용" to apply filters
/// 6. Bottom sheet closes and returns selected IDs
class FilterBottomSheet extends ConsumerStatefulWidget {
  final BenefitCategory category;
  final Set<String> initialSelectedIds;

  const FilterBottomSheet({
    super.key,
    required this.category,
    this.initialSelectedIds = const {},
  });

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.initialSelectedIds);
  }

  void _toggleSelection(String subcategoryId) {
    setState(() {
      if (_selectedIds.contains(subcategoryId)) {
        _selectedIds.remove(subcategoryId);
      } else {
        _selectedIds.add(subcategoryId);
      }
    });
  }

  void _clearAll() {
    setState(() {
      _selectedIds.clear();
    });
  }

  void _applyFilters() {
    // Update global state provider
    ref.read(selectedSubcategoryIdsProvider.notifier).state = _selectedIds;
    Navigator.pop(context, _selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final subcategoriesAsync = ref.watch(
      subcategoriesStreamProvider(widget.category.id),
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${widget.category.title} 세부 필터',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Subcategory list
          Expanded(
            child: subcategoriesAsync.when(
              data: (subcategories) {
                if (subcategories.isEmpty) {
                  return const Center(
                    child: Text(
                      '사용 가능한 세부 필터가 없습니다',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: subcategories.length,
                  itemBuilder: (context, index) {
                    final subcategory = subcategories[index];
                    final isSelected = _selectedIds.contains(subcategory.id);

                    return _SubcategoryFilterCard(
                      subcategory: subcategory,
                      isSelected: isSelected,
                      onTap: () => _toggleSelection(subcategory.id),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('오류: $error'),
                  ],
                ),
              ),
            ),
          ),

          // Footer actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearAll,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('초기화'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      '적용${_selectedIds.isEmpty ? '' : ' (${_selectedIds.length})'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Subcategory filter card widget
class _SubcategoryFilterCard extends StatelessWidget {
  final BenefitSubcategory subcategory;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubcategoryFilterCard({
    required this.subcategory,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? theme.primaryColor.withOpacity(0.05)
              : Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            if (subcategory.iconUrl != null)
              MediaResolver.buildSvgIcon(
                subcategory.iconUrl!,
                size: 32,
              )
            else if (subcategory.iconName != null)
              MediaResolver.buildLocalIcon(
                subcategory.iconName!,
                size: 32,
              )
            else
              const Icon(Icons.category_outlined, size: 32),

            const SizedBox(height: 8),

            // Name
            Text(
              subcategory.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),

            // Checkmark
            if (isSelected) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.check_circle,
                color: theme.primaryColor,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

### Task 6: Integrate Filter into BenefitsScreen

**File:** `apps/pickly_mobile/lib/features/benefits/screens/benefits_screen.dart`

**Step 1: Add Import (after line 18):**

```dart
import 'package:pickly_mobile/features/benefits/widgets/filter_bottom_sheet.dart';
import 'package:pickly_mobile/contexts/benefit/providers/subcategory_providers.dart';
```

**Step 2: REMOVE Hardcoded Data (DELETE lines 88-121):**

```dart
// DELETE THIS ENTIRE BLOCK:
final Map<int, List<Map<String, String>>> _programTypesByCategory = {
  0: [], // 인기
  1: [ // 주거
    {'icon': 'assets/icons/happy_apt.svg', 'title': '행복주택'},
    // ... all hardcoded entries
  ],
  // ... rest of hardcoded data
};
```

**Step 3: Add Filter Button Handler (add new method):**

```dart
/// Show filter bottom sheet for subcategory selection
void _showFilterBottomSheet(BenefitCategory category) {
  final currentlySelected = ref.read(selectedSubcategoryIdsProvider);

  showModalBottomSheet<Set<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FilterBottomSheet(
      category: category,
      initialSelectedIds: currentlySelected,
    ),
  ).then((selectedIds) {
    if (selectedIds != null) {
      setState(() {
        // Trigger UI refresh with new filter
      });

      // Save to storage for persistence
      final storage = ref.read(onboardingStorageServiceProvider);
      storage.saveSelectedProgramTypes(
        category.slug,
        selectedIds.toList(),
      );
    }
  });
}
```

**Step 4: Update UI to Show Filter Button**

Replace filter chip rendering logic (around line 300-400) with dynamic subcategory loading.

**Before:**
```dart
final programTypes = _programTypesByCategory[_selectedCategoryIndex] ?? [];
```

**After:**
```dart
// Get selected subcategory IDs
final selectedIds = ref.watch(selectedSubcategoryIdsProvider);

// Show filter button instead of chips
ElevatedButton.icon(
  onPressed: () {
    final categories = ref.read(categoriesStreamListProvider);
    if (_selectedCategoryIndex < categories.length) {
      _showFilterBottomSheet(categories[_selectedCategoryIndex]);
    }
  },
  icon: const Icon(Icons.filter_list),
  label: Text(
    selectedIds.isEmpty
        ? '필터'
        : '필터 (${selectedIds.length})',
  ),
),
```

**Step 5: Update Announcement Fetching to Use Selected Filters**

Find where announcements are fetched and add `subcategoryIds` parameter:

```dart
// In the widget that fetches announcements
final selectedIds = ref.watch(selectedSubcategoryIdsProvider);

// Pass to repository
final announcements = await benefitRepository.getAnnouncementsByCategory(
  categoryId,
  subcategoryIds: selectedIds.isEmpty ? null : selectedIds.toList(),
);
```

---

### Task 7: Code Generation & Wiring

**Step 1: Run Build Runner**

```bash
cd apps/pickly_mobile
dart run build_runner build --delete-conflicting-outputs
```

**Expected Generated Files:**
- `benefit_subcategory.g.dart`
- `subcategory_providers.g.dart`

**Step 2: Verify Imports**

Check all files import correctly:
- Models exported from barrel file
- Providers accessible
- No unused imports

**Step 3: Fix Any Compilation Errors**

```bash
cd apps/pickly_mobile
flutter analyze
```

---

## 🧪 Testing & Verification

### Manual Testing Checklist

**Pre-Test Setup:**
1. ✅ Verify seed data loaded: `benefit_subcategories` has 30 records
2. ✅ Verify Admin UI working: Can add/edit subcategories
3. ✅ Fresh app restart

**Test Scenarios:**

**Scenario 1: Basic Filter Flow**
- [ ] Open BenefitsScreen
- [ ] Tap filter button
- [ ] Bottom sheet opens with subcategories
- [ ] Select 2-3 subcategories
- [ ] Tap "적용"
- [ ] Announcement list updates to show only selected types
- [ ] Filter button shows count: "필터 (3)"

**Scenario 2: Multi-Select Toggle**
- [ ] Open filter bottom sheet
- [ ] Select subcategory → checkmark appears
- [ ] Tap same subcategory → checkmark disappears
- [ ] Visual feedback (border color, background) correct

**Scenario 3: Clear Filters**
- [ ] Select multiple filters
- [ ] Tap "초기화" button
- [ ] All selections cleared
- [ ] Visual state resets

**Scenario 4: Persistence**
- [ ] Select filters and apply
- [ ] Navigate away from BenefitsScreen
- [ ] Return to BenefitsScreen
- [ ] Filters still applied (from SharedPreferences)

**Scenario 5: Realtime Sync**
- [ ] Open filter bottom sheet
- [ ] Go to Admin UI (on desktop)
- [ ] Add new subcategory
- [ ] Return to mobile app
- [ ] Close and reopen bottom sheet
- [ ] New subcategory appears in list

**Scenario 6: Icon Display**
- [ ] Subcategories with `iconUrl` show network icon
- [ ] Subcategories with only `iconName` show local icon
- [ ] Subcategories with neither show fallback icon
- [ ] No broken image placeholders

**Scenario 7: Empty State**
- [ ] Select category with no subcategories (e.g., "인기")
- [ ] Open filter bottom sheet
- [ ] Shows "사용 가능한 세부 필터가 없습니다" message

**Scenario 8: Error State**
- [ ] Disconnect network
- [ ] Open filter bottom sheet
- [ ] Shows error icon and message
- [ ] Reconnect network
- [ ] Bottom sheet recovers

### Programmatic Testing

**Unit Tests (optional but recommended):**

```dart
// test/models/benefit_subcategory_test.dart
test('BenefitSubcategory fromJson', () {
  final json = {
    'id': '123',
    'category_id': '456',
    'name': '행복주택',
    'slug': 'happy-housing',
    'sort_order': 1,
    'is_active': true,
    'icon_url': 'https://example.com/icon.svg',
    'icon_name': 'happy_apt',
    'created_at': '2025-01-01T00:00:00Z',
    'updated_at': '2025-01-01T00:00:00Z',
  };

  final subcategory = BenefitSubcategory.fromJson(json);

  expect(subcategory.id, '123');
  expect(subcategory.name, '행복주택');
  expect(subcategory.slug, 'happy-housing');
});
```

---

## 📸 Documentation & Screenshots

### Required Screenshots

1. **Before State** (Hardcoded Filters)
   - Screenshot of filter chips with hardcoded data
   - Label: "Before: Hardcoded filter chips"

2. **After State - Bottom Sheet Closed**
   - Screenshot of filter button
   - Label: "After: Filter button (dynamic)"

3. **After State - Bottom Sheet Open**
   - Screenshot of opened bottom sheet
   - Show subcategories grid
   - Label: "After: Dynamic subcategory selection"

4. **After State - Selected Filters**
   - Screenshot with 2-3 filters selected
   - Show checkmarks and blue borders
   - Label: "After: Multi-select with visual feedback"

5. **After State - Filtered List**
   - Screenshot of announcement list after applying filters
   - Show reduced count
   - Label: "After: Filtered announcement list"

### GIF/Video (Optional but Recommended)

**10-20 second screen recording:**
1. Tap filter button
2. Bottom sheet slides up
3. Select 2-3 subcategories (show toggle)
4. Tap "적용"
5. Bottom sheet closes
6. List refreshes with filtered results

---

## 📦 Pull Request Template

**Title:** `feat(v9.10.0): Implement dynamic subcategory filter with bottom sheet UI`

**Description:**

```markdown
## 🎯 Summary

Implements PRD v9.10.0 - Dynamic database-driven subcategory filtering, replacing hardcoded filter data with realtime Admin-managed subcategories.

## ✅ Implementation Checklist

### Models & Data Layer
- [x] Created `BenefitSubcategory` model with B-Lite pattern
- [x] Extended `BenefitRepository` with 3 subcategory methods
- [x] Updated announcement API with `subcategoryIds` parameter

### Providers & State
- [x] Created `subcategory_providers.dart` with Stream/Future providers
- [x] Added `selectedSubcategoryIdsProvider` for multi-select state
- [x] Integrated with existing storage for persistence

### UI Components
- [x] Built `FilterBottomSheet` widget with grid layout
- [x] Implemented multi-select toggle with visual feedback
- [x] Added Apply/Clear actions

### Screen Integration
- [x] **REMOVED** hardcoded `_programTypesByCategory` map (lines 88-121)
- [x] Integrated filter button into `BenefitsScreen`
- [x] Connected announcement list to selected filters

### Testing & Polish
- [x] Manual testing all scenarios (8/8 passed)
- [x] Code generation completed without errors
- [x] No design/spacing changes
- [x] Screenshots captured

## 📊 Changed Files

- `apps/pickly_mobile/lib/contexts/benefit/models/benefit_subcategory.dart` (new)
- `apps/pickly_mobile/lib/contexts/benefit/repositories/benefit_repository.dart` (extended)
- `apps/pickly_mobile/lib/contexts/benefit/providers/subcategory_providers.dart` (new)
- `apps/pickly_mobile/lib/features/benefits/widgets/filter_bottom_sheet.dart` (new)
- `apps/pickly_mobile/lib/features/benefits/screens/benefits_screen.dart` (modified)
- `docs/prd/PRD_v9.10.0_Flutter_Subcategory_Filter_Integration.md` (updated)

## 🔍 Key Changes

### Before (Hardcoded)
```dart
final Map<int, List<Map<String, String>>> _programTypesByCategory = {
  1: [
    {'icon': 'assets/icons/happy_apt.svg', 'title': '행복주택'},
    // ... 30+ hardcoded entries
  ],
};
```

### After (Dynamic)
```dart
final subcategoriesAsync = ref.watch(subcategoriesStreamProvider(categoryId));
// Auto-syncs when Admin modifies data
```

## 📸 Screenshots

[Attach 5 screenshots as described above]

## 🧪 Testing

Manual testing completed:
- ✅ Filter bottom sheet opens and displays subcategories
- ✅ Multi-select toggle works with visual feedback
- ✅ Apply button filters announcement list correctly
- ✅ Clear button resets selections
- ✅ Filter state persists across sessions
- ✅ Realtime sync works when Admin modifies data
- ✅ Icon resolution (iconUrl → iconName → fallback) working
- ✅ Empty state and error state display correctly

## 🎯 Impact

**Benefits:**
- ✅ Admin can manage filters without app update
- ✅ Automatic sync across all app instances
- ✅ Better user filtering precision
- ✅ Consistent with v9.9.8 seed data & v9.9.9 Admin UI

**Removed:**
- ❌ 33 lines of hardcoded filter data

**Added:**
- ✅ Dynamic database-driven filtering
- ✅ Realtime updates from Admin
- ✅ Multi-select filter UI

## Related PRDs

- PRD v9.9.7: Seed Automation
- PRD v9.9.8: Benefit Subcategories Seed Data (Phase 1)
- PRD v9.9.9: Admin Subcategory CRUD Interface (Phase 2)
- PRD v9.10.0: Flutter Subcategory Filter Integration (Phase 3) ← This PR

## 📅 Next Steps

- Phase 4 (v9.10.1): End-to-end testing & validation
```

---

## ⚠️ Common Pitfalls to Avoid

### ❌ DON'T

1. **Don't Modify Design:**
   ```dart
   // ❌ WRONG
   Container(
     color: Color(0xFF123456), // Custom color
     padding: EdgeInsets.all(24), // Custom spacing
   )

   // ✅ CORRECT
   Container(
     color: theme.primaryColor, // Theme color
     padding: const EdgeInsets.all(16), // Existing spacing
   )
   ```

2. **Don't Change Existing Layouts:**
   ```dart
   // ❌ WRONG - Reorganizing existing UI
   Column(
     children: [
       Header(), // Moved
       Content(), // Reordered
       Footer(), // Different structure
     ],
   )

   // ✅ CORRECT - Only add new filter button
   Existing layout...
   FilterButton(), // Added
   ```

3. **Don't Over-Engineer:**
   ```dart
   // ❌ WRONG - Complex state management
   class FilterNotifier extends StateNotifier<FilterState> {
     // 200 lines of custom logic
   }

   // ✅ CORRECT - Simple StateProvider
   final selectedSubcategoryIdsProvider = StateProvider<Set<String>>((ref) => {});
   ```

4. **Don't Ignore B-Lite Pattern:**
   ```dart
   // ❌ WRONG - Using Freezed
   @freezed
   class BenefitSubcategory with _$BenefitSubcategory { ... }

   // ✅ CORRECT - Using B-Lite
   @JsonSerializable()
   class BenefitSubcategory extends Equatable { ... }
   ```

### ✅ DO

1. **Follow Existing Patterns:**
   - Check how `BenefitCategory` is structured → copy that pattern
   - Check how existing bottom sheets work → follow same style
   - Check how providers are organized → maintain structure

2. **Test Incrementally:**
   - After each task, verify it compiles
   - Test each component in isolation
   - Don't wait until the end to test

3. **Keep Commits Atomic:**
   - One commit per task
   - Clear commit messages
   - Easy to review and rollback

---

## 📅 Timeline & Milestones

| Day | Tasks | Deliverable |
|-----|-------|-------------|
| 1 | Tasks 1-3 (Model, Repository, Providers) | Infrastructure complete, tests passing |
| 2 | Task 4 (FilterBottomSheet UI) | Bottom sheet component working in isolation |
| 3 | Task 5 (BenefitsScreen integration) | Filter integrated, hardcoded data removed |
| 4 | Tasks 6-7 (API update, codegen) | Full flow working end-to-end |
| 5 | Task 8-10 (Testing, screenshots, PR) | PR submitted, documentation updated |

**Total:** 5 days (~30 hours full-time)

---

## 🎯 Definition of Done

**Code:**
- [x] All 7 tasks completed
- [x] Code generation successful
- [x] No compilation errors
- [x] No analyzer warnings
- [x] Hardcoded data fully removed

**Testing:**
- [x] All 8 manual test scenarios passed
- [x] At least 1 unit test for model serialization
- [x] No visual regressions

**Documentation:**
- [x] 5 screenshots captured
- [x] PRD v9.10.0 updated to "Complete" status
- [x] Implementation guide followed
- [x] PR description comprehensive

**Review:**
- [x] Self-review completed
- [x] No design changes introduced
- [x] No scope creep

---

**Document Created:** 2025-11-08
**Last Updated:** 2025-11-08
**Author:** Claude Code
**Status:** 📋 Ready for Implementation
**Estimated Completion:** 5 days

