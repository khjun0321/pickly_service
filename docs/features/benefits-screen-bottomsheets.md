# Benefits Screen Bottom Sheets - Technical Documentation

## Overview

This document details the three bottom sheet implementations added to the benefits screen (`benefits_screen.dart`). These bottom sheets provide users with interactive filter options for personalized benefit discovery, maintaining consistent UI/UX patterns with the onboarding flow.

**Last Updated:** 2025-10-20
**File:** `/apps/pickly_mobile/lib/features/benefits/screens/benefits_screen.dart`
**Lines:** 677-943 (Bottom sheet implementations)

---

## Summary of Changes

### 1. Region Selector Bottom Sheet (`_showRegionSelector`)
**Lines:** 677-802
**Purpose:** Allows users to change their selected region for localized benefit filtering

### 2. Age Category Selector Bottom Sheet (`_showAgeCategorySelector`)
**Lines:** 804-943
**Purpose:** Enables users to update their age category for personalized benefit recommendations

### 3. Program Type Selector Improvements (`_showProgramTypeSelector`)
**Lines:** 519-675
**Purpose:** Multi-selection interface for filtering specific program types (e.g., housing types, education support)

---

## Common Design Patterns

All three bottom sheets follow a standardized architecture aligned with the onboarding screens:

### Layout Structure
```
SafeArea
└── Container (height: 540px or 600px)
    └── Column
        ├── Header (Title + Subtitle)
        ├── Expanded (Scrollable Content)
        └── Save Button (height: 48px)
```

### Key Specifications
- **Container Height:** 540px (region/age category), 600px (program type)
- **Border Radius:** 24px (top corners)
- **Background Color:** White
- **Padding:** `Spacing.lg` (16px) horizontal, `Spacing.xxl` (32px) top
- **Button Height:** 48px
- **Button Radius:** 16px
- **Modal Property:** `isScrollControlled: true`

### Typography
- **Title:** `PicklyTypography.titleMedium` - 18px, FontWeight.w700, Color: TextColors.primary
- **Subtitle:** `PicklyTypography.bodyMedium` - 15px, FontWeight.w600, Color: TextColors.secondary
- **Button Text:** `PicklyTypography.bodyLarge` - 16px, FontWeight.w700, Color: White

---

## 1. Region Selector Bottom Sheet

### Implementation Details

**Method:** `_showRegionSelector(BuildContext context)`
**Trigger:** User taps on region filter pill (location icon)
**Lines:** 677-802

#### UI Components
- **Layout:** GridView with 3 columns
- **Component:** `SelectionChip` from design system
- **Selection Mode:** Single selection
- **Data Source:** `regionsListProvider` (Riverpod)

#### Layout Specifications
```dart
Container(
  height: 540,
  padding: EdgeInsets.fromLTRB(Spacing.lg, Spacing.xxl, Spacing.lg, Spacing.lg),
)

GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    childAspectRatio: 2.0,
  ),
)
```

#### State Management
```dart
// Local state within StatefulBuilder
String? selectedRegionId = selectedRegionIds.isNotEmpty
    ? selectedRegionIds.first
    : null;

// Update on tap
setBottomSheetState(() {
  selectedRegionId = region.id;
});
```

#### Storage Integration
```dart
final storage = ref.read(onboardingStorageServiceProvider);

// Save to storage with age category validation
if (ageCategoryId != null) {
  await storage.saveOnboardingData(
    ageCategoryId: ageCategoryId,
    regionIds: [selectedRegionId!],
  );
}

// Refresh parent UI
setState(() {});
```

#### Code Example
```dart
void _showRegionSelector(BuildContext context) {
  final regions = ref.read(regionsListProvider);
  final storage = ref.read(onboardingStorageServiceProvider);
  final selectedRegionIds = storage.getSelectedRegionIds();
  String? selectedRegionId = selectedRegionIds.isNotEmpty ? selectedRegionIds.first : null;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomSheetContext) {
      return StatefulBuilder(
        builder: (stateContext, setBottomSheetState) {
          return SafeArea(
            child: Container(
              height: 540,
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.xxl,
                Spacing.lg,
                Spacing.lg
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    '관심 지역을 선택해주세요.',
                    style: PicklyTypography.titleMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TextColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '해당 지역의 공고를 안내해드립니다.',
                    style: PicklyTypography.bodyMedium.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: TextColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Region grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.0,
                      ),
                      itemCount: regions.length,
                      itemBuilder: (context, index) {
                        final region = regions[index];
                        final isSelected = selectedRegionId == region.id;
                        return SelectionChip(
                          label: region.name,
                          isSelected: isSelected,
                          size: ChipSize.small,
                          onTap: () {
                            setBottomSheetState(() {
                              selectedRegionId = region.id;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: selectedRegionId != null ? () async {
                        final storage = ref.read(onboardingStorageServiceProvider);
                        final ageCategoryId = storage.getSelectedAgeCategoryId();

                        if (ageCategoryId != null) {
                          await storage.saveOnboardingData(
                            ageCategoryId: ageCategoryId,
                            regionIds: [selectedRegionId!],
                          );
                        }

                        if (mounted) {
                          Navigator.pop(bottomSheetContext);
                          setState(() {});
                        }
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BrandColors.primary,
                        disabledBackgroundColor: BrandColors.primary.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        '저장',
                        style: PicklyTypography.bodyLarge.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
```

---

## 2. Age Category Selector Bottom Sheet

### Implementation Details

**Method:** `_showAgeCategorySelector(BuildContext context)`
**Trigger:** User taps on age category filter pill (condition icon)
**Lines:** 804-943

#### UI Components
- **Layout:** Vertical ListView
- **Component:** `SelectionListItem` from design system
- **Selection Mode:** Single selection
- **Data Source:** `ageCategoryProvider` (Riverpod AsyncValue)

#### Layout Specifications
```dart
Container(
  height: 540,
  padding: EdgeInsets.fromLTRB(Spacing.lg, Spacing.xxl, Spacing.lg, Spacing.lg),
)

ListView.separated(
  itemCount: categories.length,
  separatorBuilder: (context, index) => SizedBox(height: 8),
  itemBuilder: (context, index) => SelectionListItem(...),
)
```

#### State Management
```dart
// Local state within StatefulBuilder
String? selectedCategoryId = ageCategoryId;

// Update on tap
setBottomSheetState(() {
  selectedCategoryId = category.id;
});
```

#### Async Data Handling
```dart
final categoriesAsync = ref.read(ageCategoryProvider);

categoriesAsync.when(
  data: (categories) {
    // Show bottom sheet
  },
  loading: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('데이터를 불러오는 중...')),
    );
  },
  error: (error, stack) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('데이터를 불러오는 데 실패했습니다: $error')),
    );
  },
);
```

#### Storage Integration
```dart
// Save to storage with region validation
if (regionIds.isNotEmpty) {
  await storage.saveOnboardingData(
    ageCategoryId: selectedCategoryId!,
    regionIds: regionIds,
  );
}
```

#### Code Example
```dart
void _showAgeCategorySelector(BuildContext context) {
  final categoriesAsync = ref.read(ageCategoryProvider);

  categoriesAsync.when(
    data: (categories) {
      final storage = ref.read(onboardingStorageServiceProvider);
      final ageCategoryId = storage.getSelectedAgeCategoryId();
      String? selectedCategoryId = ageCategoryId;

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (bottomSheetContext) {
          return StatefulBuilder(
            builder: (stateContext, setBottomSheetState) {
              return SafeArea(
                child: Container(
                  height: 540,
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.lg,
                    Spacing.xxl,
                    Spacing.lg,
                    Spacing.lg
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        '맞춤 혜택을 위해 내 상황을 알려주세요.',
                        style: PicklyTypography.titleMedium.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: TextColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '나에게 맞는 정책과 혜택에 대해 안내해드립니다.',
                        style: PicklyTypography.bodyMedium.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: TextColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Category list
                      Expanded(
                        child: ListView.separated(
                          itemCount: categories.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = selectedCategoryId == category.id;

                            return SelectionListItem(
                              iconUrl: category.iconUrl,
                              title: category.title,
                              description: category.description,
                              isSelected: isSelected,
                              onTap: () {
                                setBottomSheetState(() {
                                  selectedCategoryId = category.id;
                                });
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: selectedCategoryId != null ? () async {
                            final storage = ref.read(onboardingStorageServiceProvider);
                            final regionIds = storage.getSelectedRegionIds();

                            if (regionIds.isNotEmpty) {
                              await storage.saveOnboardingData(
                                ageCategoryId: selectedCategoryId!,
                                regionIds: regionIds,
                              );
                            }

                            if (mounted) {
                              Navigator.pop(bottomSheetContext);
                              setState(() {});
                            }
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BrandColors.primary,
                            disabledBackgroundColor: BrandColors.primary.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            '저장',
                            style: PicklyTypography.bodyLarge.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
    loading: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('데이터를 불러오는 중...')),
      );
    },
    error: (error, stack) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터를 불러오는 데 실패했습니다: $error')),
      );
    },
  );
}
```

---

## 3. Program Type Selector (Enhanced)

### Implementation Details

**Method:** `_showProgramTypeSelector(BuildContext context)`
**Trigger:** User taps on program type filter pill
**Lines:** 519-675

#### UI Components
- **Layout:** Vertical ScrollView with custom list items
- **Component:** Custom `_buildProgramTypeItem` widget
- **Selection Mode:** Multiple selection
- **Data Source:** `_programTypesByCategory` map (category-specific)

#### Layout Specifications
```dart
SafeArea(
  child: Container(
    height: 600,  // Taller for more content
    child: Column(
      children: [
        // Header
        Padding(...),

        // Scrollable content (Expanded)
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Column(...),
          ),
        ),

        // Save button
        Padding(...),
      ],
    ),
  ),
)
```

#### Key Improvements
1. **SafeArea wrapper** - Prevents overlap with system UI
2. **Expanded layout** - Content scrolls to fill available space
3. **Multiple selection** - Users can select multiple program types
4. **"전체 선택" option** - Clear all selections to show all programs

#### State Management
```dart
// Temporary state copy for selection changes
final currentSelections = List<String>.from(
  _selectedProgramTypes[_selectedCategoryIndex] ?? []
);

// Toggle selection
setBottomSheetState(() {
  if (isSelected) {
    currentSelections.remove(type['title']);
  } else {
    currentSelections.add(type['title']!);
  }
});

// "전체 선택" - Clear all selections
setBottomSheetState(() {
  currentSelections.clear(); // Empty list = show all
});
```

#### Storage Integration
```dart
// Update main state
setState(() {
  _selectedProgramTypes[_selectedCategoryIndex] = currentSelections;
});

// Save to storage with category ID
await storage.setSelectedProgramTypes(categoryId, currentSelections);
```

#### Custom Item Widget
```dart
Widget _buildProgramTypeItem({
  required String icon,
  required String title,
  required String subtitle,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isSelected ? BrandColors.primary : const Color(0xFFEBEBEB),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon (32x32)
          SvgPicture.asset(
            icon,
            width: 32,
            height: 32,
            package: 'pickly_design_system',
          ),
          const SizedBox(width: 12),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF3E3E3E),
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF828282),
                    fontSize: 12,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),

          // Checkbox (24x24 circle)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isSelected ? BrandColors.primary : const Color(0xFFDDDDDD),
              shape: BoxShape.circle,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        ],
      ),
    ),
  );
}
```

---

## UI/UX Alignment with Onboarding

### Consistent Patterns

| Feature | Onboarding | Benefits Bottom Sheet |
|---------|------------|----------------------|
| Container Height | 540px (fixed) | 540px (region/age), 600px (program) |
| Border Radius | 24px (top) | 24px (top) |
| Background | BackgroundColors.app | Colors.white |
| Padding | Spacing.lg (16px) | Spacing.lg (16px) |
| Title Font | 18px, w700 | 18px, w700 |
| Subtitle Font | 15px, w600 | 15px, w600 |
| Button Height | 48px | 48px |
| Button Radius | 16px | 16px |
| Selection Component | SelectionChip/ListItem | SelectionChip/ListItem |
| State Management | StatefulWidget | StatefulBuilder |
| Storage Service | OnboardingStorageService | OnboardingStorageService |

### Design System Components

Both implementations use the same Pickly Design System components:

1. **SelectionChip** - Region selection (3-column grid)
2. **SelectionListItem** - Age category selection (vertical list)
3. **Typography** - PicklyTypography styles throughout
4. **Colors** - BrandColors.primary, TextColors.primary/secondary
5. **Spacing** - Spacing.lg, Spacing.xxl constants

---

## Storage Service Integration

### OnboardingStorageService Methods Used

```dart
// Get current selections
String? getSelectedAgeCategoryId()
List<String> getSelectedRegionIds()
List<String> getSelectedProgramTypes(String categoryId)

// Save selections
Future<void> saveOnboardingData({
  required String ageCategoryId,
  required List<String> regionIds,
})

Future<void> setSelectedProgramTypes(
  String categoryId,
  List<String> programTypes,
)

// Get all program type selections across categories
Map<String, List<String>> getAllSelectedProgramTypes()
```

### Storage Keys
```dart
static const String _keySelectedAgeCategoryId = 'selected_age_category_id';
static const String _keySelectedRegionIds = 'selected_region_ids';
static const String _keyProgramTypePrefix = 'selected_program_type_';
```

### Data Persistence Flow
1. User selects option in bottom sheet
2. Local state updated via `StatefulBuilder`
3. On save button press:
   - Main screen state updated via `setState()`
   - Data persisted via `OnboardingStorageService`
   - Bottom sheet dismissed
   - Parent UI refreshed to show new selection

---

## Testing Instructions

### Manual Testing

#### Region Selector
1. Navigate to Benefits screen
2. Tap on region filter pill (location icon)
3. Verify bottom sheet opens at 540px height
4. Verify 3-column grid displays all regions
5. Select a different region
6. Verify SelectionChip visual feedback (primary color border)
7. Tap "저장" button
8. Verify bottom sheet closes
9. Verify filter pill updates to show new region
10. Restart app and verify selection persists

#### Age Category Selector
1. Navigate to Benefits screen
2. Tap on age category filter pill (condition icon)
3. Verify bottom sheet opens at 540px height
4. Verify vertical list displays all age categories with icons
5. Select a different category
6. Verify SelectionListItem visual feedback
7. Tap "저장" button
8. Verify bottom sheet closes
9. Verify filter pill updates to show new category
10. Restart app and verify selection persists

#### Program Type Selector
1. Navigate to Benefits screen
2. Switch to "주거" category tab
3. Tap on "전체" program type filter pill
4. Verify bottom sheet opens at 600px height
5. Verify "전체 선택" option at top
6. Select multiple program types (e.g., "행복주택", "국민임대주택")
7. Verify multiple checkboxes are checked
8. Tap "저장" button
9. Verify bottom sheet closes
10. Verify filter pills show all selected program types
11. Restart app and verify selections persist
12. Tap filter pill again and select "전체 선택"
13. Verify all checkboxes clear
14. Save and verify single "전체" pill displays

### Edge Cases

- **No Selection**: Save button should be disabled
- **Single Selection (Region/Age)**: Previous selection should be replaced
- **Multiple Selection (Program Types)**: All selections should be preserved
- **Empty State**: "전체 선택" should display when no program types selected
- **AsyncValue Error**: Age category selector should show error message
- **AsyncValue Loading**: Age category selector should show loading message
- **Storage Validation**: Region selector requires age category ID; age selector requires region IDs

### Automated Test Cases

```dart
// Example test structure
testWidgets('Region selector shows and saves selection', (tester) async {
  // Arrange
  await tester.pumpWidget(TestApp());

  // Act
  await tester.tap(find.byIcon(Icons.location_on));
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('관심 지역을 선택해주세요.'), findsOneWidget);
  expect(find.byType(SelectionChip), findsWidgets);

  // Act - Select region
  await tester.tap(find.text('서울특별시'));
  await tester.tap(find.text('저장'));
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('서울특별시'), findsOneWidget); // In filter pill
});
```

---

## Architecture Insights

### State Management Strategy

**Local State (StatefulBuilder)**
- User's temporary selection within bottom sheet
- Updates immediately for visual feedback
- Discarded if user dismisses without saving

**Parent State (ConsumerStatefulWidget)**
- Persistent selection shown in filter pills
- Updated only after save button pressed
- Triggers UI rebuild to show new selection

**Global State (OnboardingStorageService)**
- Long-term persistence across app sessions
- Uses SharedPreferences for local storage
- Single source of truth for user preferences

### Riverpod Provider Integration

```dart
// Current selections
final storage = ref.watch(onboardingStorageServiceProvider);
final ageCategoryId = storage.getSelectedAgeCategoryId();
final regionIds = storage.getSelectedRegionIds();

// Data providers
final selectedRegion = ref.watch(regionByIdProvider(regionIds.first));
final selectedAgeCategory = ref.watch(ageCategoryByIdProvider(ageCategoryId));
final regions = ref.read(regionsListProvider);
final categoriesAsync = ref.read(ageCategoryProvider);
```

### Navigation Context Handling

```dart
// Use bottomSheetContext for navigation
Navigator.pop(bottomSheetContext);

// Use mounted check before navigation
if (mounted) {
  Navigator.pop(bottomSheetContext);
  setState(() {}); // Refresh parent UI
}
```

---

## Future Enhancements

### Potential Improvements

1. **Animations**
   - Add slide-in animation for bottom sheets
   - Smooth transitions for selection changes
   - Loading skeleton for async data

2. **Accessibility**
   - Add semantic labels for screen readers
   - Keyboard navigation support
   - High contrast mode support

3. **Validation**
   - Show error messages inline
   - Add success confirmation feedback
   - Prevent invalid state combinations

4. **Performance**
   - Cache region/category data locally
   - Lazy load program type icons
   - Optimize rebuild scope

5. **Analytics**
   - Track filter usage patterns
   - Monitor selection change frequency
   - A/B test different layouts

### Code Optimization Opportunities

```dart
// Extract common bottom sheet wrapper
Widget _buildBottomSheetWrapper({
  required double height,
  required Widget child,
}) {
  return SafeArea(
    child: Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.xxl,
        Spacing.lg,
        Spacing.lg
      ),
      child: child,
    ),
  );
}

// Extract common save button
Widget _buildSaveButton({
  required bool enabled,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: BrandColors.primary,
        disabledBackgroundColor: BrandColors.primary.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        '저장',
        style: PicklyTypography.bodyLarge.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ),
  );
}
```

---

## Related Files

### Implementation Files
- `/apps/pickly_mobile/lib/features/benefits/screens/benefits_screen.dart` - Main screen with bottom sheets
- `/apps/pickly_mobile/lib/features/onboarding/screens/region_selection_screen.dart` - Reference implementation
- `/apps/pickly_mobile/lib/features/onboarding/services/onboarding_storage_service.dart` - Storage service

### Design System Components
- `/packages/pickly_design_system/lib/widgets/inputs/selection_chip.dart` - Region selection
- `/packages/pickly_design_system/lib/widgets/inputs/selection_list_item.dart` - Age category selection
- `/packages/pickly_design_system/lib/widgets/tabs/tab_pill.dart` - Filter pills

### Providers
- `/apps/pickly_mobile/lib/features/onboarding/providers/region_provider.dart` - Region data
- `/apps/pickly_mobile/lib/features/onboarding/providers/age_category_provider.dart` - Age category data
- `/apps/pickly_mobile/lib/features/onboarding/providers/onboarding_storage_provider.dart` - Storage provider

---

## Conclusion

The three bottom sheet implementations successfully maintain UI/UX consistency with the onboarding flow while providing flexible filtering options in the benefits screen. Key achievements:

1. **Consistent Layout** - 540px/600px containers with standardized padding and spacing
2. **Reusable Components** - Leverages SelectionChip and SelectionListItem from design system
3. **Robust State Management** - StatefulBuilder for local state, Riverpod for global state
4. **Persistent Storage** - OnboardingStorageService ensures selections survive app restarts
5. **Clean Architecture** - Separation of concerns between UI, state, and storage layers

The implementation serves as a strong foundation for future filter enhancements and demonstrates proper Flutter/Riverpod patterns for modal interactions and data persistence.
