# Benefits Screen Component Structure

## Overview

The Benefits Screen is the main hub for displaying government benefits and policies. It features a sophisticated filtering system with bottom sheets, category-based navigation, and persistent storage for user preferences.

## File Location

```
/apps/pickly_mobile/lib/features/benefits/screens/benefits_screen.dart
```

## Architecture

### Screen Hierarchy

```
BenefitsScreen (ConsumerStatefulWidget)
├── Scaffold
│   ├── SafeArea
│   │   ├── Header (AppHeader.home)
│   │   ├── Category Tabs (Horizontal Scroll)
│   │   └── Content Area (SingleChildScrollView)
│   │       ├── Banner (Category-specific PageView)
│   │       ├── Filter Pills (Horizontal Scroll)
│   │       │   ├── Location Filter → Region Selector
│   │       │   ├── Condition Filter → Age Category Selector
│   │       │   ├── Divider (conditional)
│   │       │   └── Program Type Filters → Program Type Selector
│   │       └── Category Content
│   │           ├── PopularCategoryContent (인기)
│   │           ├── HousingCategoryContent (주거)
│   │           └── Other Categories (준비중)
│   └── PicklyBottomNavigationBar
```

## Filter Pill Integration

### 1. Location Filter Pill

**Purpose**: Allow users to change their region preference
**Trigger**: Tap on location pill (e.g., "서울")
**Connected To**: Region Selector Bottom Sheet

```dart
// Location filter pill
TabPill.default_(
  iconPath: 'assets/icons/location.svg',
  text: selectedRegion.name,
  onTap: () {
    _showRegionSelector(context);
  },
)
```

**Bottom Sheet**: `_showRegionSelector`
- Height: 540px
- Contains: GridView with 3 columns
- Selection: Single selection
- Storage: `OnboardingStorageService.saveOnboardingData`

### 2. Condition Filter Pill

**Purpose**: Allow users to change their age category
**Trigger**: Tap on condition pill (e.g., "청년")
**Connected To**: Age Category Selector Bottom Sheet

```dart
// Age category filter pill
TabPill.default_(
  iconPath: 'assets/icons/condition.svg',
  text: selectedAgeCategory.title,
  onTap: () {
    _showAgeCategorySelector(context);
  },
)
```

**Bottom Sheet**: `_showAgeCategorySelector`
- Height: 540px
- Contains: ListView with SelectionListItem components
- Selection: Single selection
- Storage: `OnboardingStorageService.saveOnboardingData`

### 3. Program Type Filter Pills

**Purpose**: Filter benefits by specific program types (e.g., housing types)
**Trigger**: Tap on program type pill (e.g., "행복주택", "전체")
**Connected To**: Program Type Selector Bottom Sheet

```dart
// Program type filter pills (multiple selections)
TabPill.default_(
  iconPath: _getIconForProgramType(type),
  text: type,
  onTap: () {
    _showProgramTypeSelector(context);
  },
)
```

**Bottom Sheet**: `_showProgramTypeSelector`
- Height: 600px
- Contains: Scrollable list with custom selection items
- Selection: Multiple selection (checkbox-based)
- Storage: `OnboardingStorageService.setSelectedProgramTypes`
- Special: "전체 선택" option clears all selections

## Bottom Sheet Patterns

### Common Structure

All bottom sheets in the benefits screen follow a consistent pattern:

```dart
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
            height: [540px or 600px],
            padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              children: [
                // Header section
                // Content section (Expanded)
                // Button section (Fixed at bottom)
              ],
            ),
          ),
        );
      },
    );
  },
);
```

### Height Guidelines

- **Standard Bottom Sheet**: 540px (Region, Age Category)
- **Extended Bottom Sheet**: 600px (Program Type with multiple options)
- **SafeArea Wrapper**: Always used for proper device edge handling

### Button Positioning

```dart
// Fixed at bottom with consistent spacing
const SizedBox(height: 20),
Padding(
  padding: const EdgeInsets.all(16),
  child: SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      // Button content
    ),
  ),
),
```

**Key Measurements**:
- Button height: 48px
- Button to bottom SafeArea: 16px padding
- Content to button spacing: 20px

### State Management Approach

#### 1. StatefulBuilder Pattern

Bottom sheets use `StatefulBuilder` to maintain local state:

```dart
StatefulBuilder(
  builder: (stateContext, setBottomSheetState) {
    return SafeArea(
      child: Container(
        // Local state can be updated via setBottomSheetState
      ),
    );
  },
)
```

**Why StatefulBuilder?**
- Isolates bottom sheet state from parent widget
- Enables immediate UI updates within the sheet
- Prevents unnecessary rebuilds of parent screen

#### 2. Riverpod Integration

```dart
// Read storage service
final storage = ref.read(onboardingStorageServiceProvider);

// Watch provider data
final selectedRegion = ref.watch(regionByIdProvider(regionIds.first));
```

**Provider Usage**:
- `onboardingStorageServiceProvider`: Access to storage service
- `regionByIdProvider`: Fetch region data by ID
- `ageCategoryByIdProvider`: Fetch age category data by ID
- `regionsListProvider`: Get all available regions
- `ageCategoryProvider`: Get all age categories

#### 3. Storage Persistence

```dart
// Save to storage
await storage.saveOnboardingData(
  ageCategoryId: ageCategoryId,
  regionIds: [selectedRegionId],
);

// Refresh parent UI after closing sheet
if (mounted) {
  Navigator.pop(bottomSheetContext);
  setState(() {}); // Trigger rebuild
}
```

**Storage Methods**:
- `saveOnboardingData()`: Save region + age category
- `setSelectedProgramTypes()`: Save program type selections
- `getSelectedRegionIds()`: Retrieve saved regions
- `getSelectedAgeCategoryId()`: Retrieve saved age category
- `getAllSelectedProgramTypes()`: Retrieve all program type selections

### Data Flow

```
┌─────────────────┐
│   Filter Pill   │
│   (Tap Event)   │
└────────┬────────┘
         │
         v
┌─────────────────────────┐
│  Bottom Sheet Opens     │
│  (StatefulBuilder)      │
│  - Load current state   │
│  - from storage via     │
│    Riverpod provider    │
└────────┬────────────────┘
         │
         v
┌─────────────────────────┐
│  User Makes Selection   │
│  - Update local state   │
│    via setBottomSheetState
└────────┬────────────────┘
         │
         v
┌─────────────────────────┐
│  Save Button Pressed    │
│  - Write to storage     │
│  - Close bottom sheet   │
│  - Trigger parent       │
│    setState()           │
└────────┬────────────────┘
         │
         v
┌─────────────────────────┐
│  UI Refreshes           │
│  - Filter pills update  │
│  - Content re-renders   │
└─────────────────────────┘
```

## Visual Diagrams

### Benefits Screen Layout

```
┌────────────────────────────────────┐
│ SafeArea Top (~44px)               │
├────────────────────────────────────┤
│ Header (60px)                      │
│  Logo + Menu Button                │
├────────────────────────────────────┤
│ SizedBox (12px)                    │
├────────────────────────────────────┤
│ Category Tabs (72px)               │
│  [인기] [주거] [교육] [지원] ...    │
├────────────────────────────────────┤
│ Content (Scrollable)               │
│ ┌────────────────────────────────┐ │
│ │ SizedBox (16px)                │ │
│ ├────────────────────────────────┤ │
│ │ Banner (80px)                  │ │
│ │  Category-specific PageView    │ │
│ ├────────────────────────────────┤ │
│ │ SizedBox (16px)                │ │
│ ├────────────────────────────────┤ │
│ │ Filter Pills (40px)            │ │
│ │  [Location] [Condition] [Type] │ │
│ ├────────────────────────────────┤ │
│ │ SizedBox (16px)                │ │
│ ├────────────────────────────────┤ │
│ │ Category Content               │ │
│ │  (Dynamic based on category)   │ │
│ └────────────────────────────────┘ │
├────────────────────────────────────┤
│ Bottom Navigation (80px)           │
└────────────────────────────────────┘
```

### Filter Pill to Bottom Sheet Flow

```
┌─────────────────────┐
│   Location Pill     │
│   [📍 서울]         │
└──────────┬──────────┘
           │ Tap
           v
┌─────────────────────────────────┐
│  Region Selector Bottom Sheet   │
│  ┌───────────────────────────┐  │
│  │ Header (Title + Subtitle) │  │
│  ├───────────────────────────┤  │
│  │ Region Grid (Expanded)    │  │
│  │  [서울] [부산] [대구]      │  │
│  │  [인천] [광주] ...        │  │
│  ├───────────────────────────┤  │
│  │ SizedBox (20px)           │  │
│  ├───────────────────────────┤  │
│  │ Save Button (48px)        │  │
│  └───────────────────────────┘  │
│  SafeArea Bottom               │
└─────────────────────────────────┘
           │ Save
           v
┌─────────────────────┐
│ Storage Updated     │
│ UI Refreshes        │
└─────────────────────┘
```

### State Management Flow

```
                    ┌──────────────────┐
                    │ BenefitsScreen   │
                    │ (Parent State)   │
                    └────────┬─────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              v              v              v
    ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
    │   Region    │  │ Age Category│  │ Program Type│
    │  Bottom     │  │  Bottom     │  │   Bottom    │
    │  Sheet      │  │  Sheet      │  │   Sheet     │
    └──────┬──────┘  └──────┬──────┘  └──────┬──────┘
           │                │                │
           │    ┌───────────┴────────┐      │
           │    │                    │      │
           v    v                    v      v
    ┌──────────────────────────────────────────┐
    │   OnboardingStorageService               │
    │   (SharedPreferences)                    │
    │                                          │
    │   - saveOnboardingData()                 │
    │   - setSelectedProgramTypes()            │
    │   - getSelectedRegionIds()               │
    │   - getSelectedAgeCategoryId()           │
    │   - getAllSelectedProgramTypes()         │
    └──────────────────────────────────────────┘
           │                    │
           v                    v
    ┌─────────────┐      ┌─────────────┐
    │  Riverpod   │      │ Parent UI   │
    │  Providers  │      │  Refresh    │
    │             │      │ setState()  │
    └─────────────┘      └─────────────┘
```

## Storage Service Integration

### OnboardingStorageService

Located at: `/apps/pickly_mobile/lib/features/onboarding/services/onboarding_storage_service.dart`

#### Key Methods

```dart
// Region and age category
Future<void> saveOnboardingData({
  required String ageCategoryId,
  required List<String> regionIds,
})

List<String> getSelectedRegionIds()
String? getSelectedAgeCategoryId()

// Program types (multiple selection support)
Future<void> setSelectedProgramTypes(
  String categoryId,
  List<String> programTypes,
)

List<String> getSelectedProgramTypes(String categoryId)

Map<String, List<String>> getAllSelectedProgramTypes()
```

#### Storage Keys

```dart
// Core onboarding
'has_completed_onboarding'
'selected_age_category_id'
'selected_region_ids'

// Program types by category
'selected_program_type_popular'
'selected_program_type_housing'
'selected_program_type_education'
// ... etc
```

#### Data Format

```dart
// Region storage
SharedPreferences.setStringList('selected_region_ids', ['seoul'])

// Age category storage
SharedPreferences.setString('selected_age_category_id', 'youth')

// Program types storage (multiple selection)
SharedPreferences.setStringList('selected_program_type_housing',
  ['행복주택', '국민임대주택']
)

// Empty list = "전체 선택"
SharedPreferences.setStringList('selected_program_type_housing', [])
```

## Category System

### Category Tab Configuration

```dart
final List<Map<String, String>> _categories = [
  {'label': '인기', 'icon': 'assets/icons/fire.svg'},      // index 0
  {'label': '주거', 'icon': 'assets/icons/home.svg'},      // index 1
  {'label': '교육', 'icon': 'assets/icons/school.svg'},    // index 2
  {'label': '지원', 'icon': 'assets/icons/dollar.svg'},    // index 3
  {'label': '교통', 'icon': 'assets/icons/bus.svg'},       // index 4
  {'label': '복지', 'icon': 'assets/icons/happy_apt.svg'}, // index 5
  {'label': '의류', 'icon': 'assets/icons/shirts.svg'},    // index 6
  {'label': '식품', 'icon': 'assets/icons/rice.svg'},      // index 7
  {'label': '문화', 'icon': 'assets/icons/speaker.svg'},   // index 8
];
```

### Category ID Mapping

```dart
String _getCategoryId(int index) {
  switch (index) {
    case 0: return 'popular';
    case 1: return 'housing';
    case 2: return 'education';
    case 3: return 'support';
    case 4: return 'transportation';
    case 5: return 'welfare';
    case 6: return 'clothing';
    case 7: return 'food';
    case 8: return 'culture';
    default: return 'popular';
  }
}
```

### Program Types by Category

Only certain categories have program type filters:

```dart
final Map<int, List<Map<String, String>>> _programTypesByCategory = {
  0: [], // 인기: No program types (전체만)
  1: [ // 주거: 6 housing types
    {'icon': 'assets/icons/happy_apt.svg', 'title': '행복주택'},
    {'icon': 'assets/icons/apt.svg', 'title': '국민임대주택'},
    {'icon': 'assets/icons/home2.svg', 'title': '영구임대주택'},
    {'icon': 'assets/icons/building.svg', 'title': '공공임대주택'},
    {'icon': 'assets/icons/buy.svg', 'title': '매입임대주택'},
    {'icon': 'assets/icons/ring.svg', 'title': '신혼희망타운'},
  ],
  2: [ // 교육: 2 education types
    {'icon': 'assets/icons/school.svg', 'title': '학자금 지원'},
    {'icon': 'assets/icons/book.svg', 'title': '교육비 지원'},
  ],
  // ... more categories
};
```

## Component Specifications

### Filter Pill Specifications

**Component**: `TabPill.default_` from `pickly_design_system`

**Properties**:
- Height: 40px
- Border radius: 20px (pill shape)
- Padding: 8px horizontal, 10px vertical
- Icon size: 16x16px
- Text style: Pretendard, 14px, weight 600

**Spacing**:
- Between pills: 8px
- Horizontal padding: 16px
- Divider: 1px width, 20px height, color #EBEBEB

### Bottom Sheet Specifications

**Common Properties**:
- Background color: White
- Top border radius: 24px
- isScrollControlled: true (for custom height)

**Region Selector**:
- Height: 540px
- Grid: 3 columns, 8px spacing
- Chip aspect ratio: 2.0
- Chip component: `SelectionChip` (size: small)

**Age Category Selector**:
- Height: 540px
- List item: `SelectionListItem`
- Separator: 8px
- Icon size: 48x48px

**Program Type Selector**:
- Height: 600px (larger for multiple items)
- Item padding: 16px all sides
- Icon size: 32x32px
- Checkbox size: 24x24px
- Border: 1px, color varies (selected/unselected)

### Button Specifications

**Save Button** (All bottom sheets):
- Width: Full width (double.infinity)
- Height: 48px
- Border radius: 16px
- Background: BrandColors.primary
- Text: 16px, weight 700, white color
- Padding: Vertical 12px, Horizontal 80px

## Best Practices

### 1. State Management

- Use `StatefulBuilder` for bottom sheet local state
- Use `setState()` in parent to refresh after bottom sheet closes
- Access storage via Riverpod providers
- Check `mounted` before calling `Navigator.pop()`

### 2. Data Persistence

- Always save to `OnboardingStorageService` when user confirms selection
- Load saved values in `initState()` using `addPostFrameCallback`
- Use empty list `[]` to represent "전체 선택" for program types

### 3. UI Consistency

- Maintain 540px or 600px bottom sheet heights
- Keep 16px padding from SafeArea bottom
- Use 20px spacing before button
- Always wrap in SafeArea for device edge handling

### 4. Navigation Safety

```dart
if (mounted) {
  Navigator.pop(bottomSheetContext);
  setState(() {}); // Refresh parent UI
}
```

### 5. Multiple Selection Handling

```dart
// Toggle selection
if (isSelected) {
  currentSelections.remove(item);
} else {
  currentSelections.add(item);
}

// Clear all for "전체 선택"
currentSelections.clear();
```

## Future Enhancements

### Planned Features

1. Search functionality in bottom sheets
2. Recent selections history
3. Smart defaults based on user behavior
4. Animation transitions between states
5. Accessibility improvements (VoiceOver, TalkBack)

### Technical Debt

1. Extract bottom sheet builders into separate widgets
2. Create reusable bottom sheet scaffold
3. Add unit tests for filter state management
4. Implement analytics tracking for filter usage
5. Add error handling for storage failures

## Related Documentation

- [Component Structure Guide](/docs/architecture/component-structure-guide.md)
- [Category Banner Architecture](/docs/architecture/category-banner-architecture.md)
- [Onboarding Flow Documentation](/docs/architecture/onboarding-flow.md)

## Code Examples

### Complete Bottom Sheet Example

```dart
void _showRegionSelector(BuildContext context) {
  final regions = ref.read(regionsListProvider);
  final storage = ref.read(onboardingStorageServiceProvider);
  final selectedRegionIds = storage.getSelectedRegionIds();
  String? selectedRegionId = selectedRegionIds.isNotEmpty
    ? selectedRegionIds.first
    : null;

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
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
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

                  // Content (Expanded)
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
                      onPressed: selectedRegionId != null
                        ? () async {
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
                              setState(() {}); // Refresh parent UI
                            }
                          }
                        : null,
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

## Troubleshooting

### Common Issues

1. **Bottom sheet doesn't show selected state**
   - Ensure you're using `StatefulBuilder` and `setBottomSheetState`
   - Check that initial state is loaded from storage correctly

2. **Filter pills don't update after closing bottom sheet**
   - Call `setState(() {})` in parent after `Navigator.pop()`
   - Verify storage is being updated correctly

3. **Multiple selection not persisting**
   - Use `List<String>` not `String?` for program types
   - Check `setSelectedProgramTypes` is called with correct category ID

4. **Bottom sheet height issues on different devices**
   - Always wrap in `SafeArea`
   - Use fixed heights (540px or 600px) with `isScrollControlled: true`

## Testing Checklist

- [ ] Filter pills display correct initial values from storage
- [ ] Tapping filter pill opens corresponding bottom sheet
- [ ] Bottom sheet shows correct selected state
- [ ] Save button enables/disables based on selection
- [ ] Selections persist after app restart
- [ ] Parent UI updates after bottom sheet closes
- [ ] Multiple program types can be selected and saved
- [ ] "전체 선택" clears other selections
- [ ] Different categories show correct program types
- [ ] Navigation safety (mounted check) prevents errors

---

**Last Updated**: 2025-10-20
**Version**: 1.0.0
**Maintained By**: Pickly Mobile Team
