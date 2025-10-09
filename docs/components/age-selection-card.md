# Age Selection Card Component

## Overview

The `CategoryCard` is a reusable Flutter widget that displays an individual age category option with interactive selection state. Used in the age category selection screen (Screen 003) of the onboarding flow.

**Location:** `apps/pickly_mobile/lib/features/onboarding/screens/age_category_screen_example.dart` (lines 250-375)

---

## Visual Design

### States

#### Unselected State
```
┌─────────────────────────────────────────┐
│  [Icon]   청년                          │
│           (만 19-39세)                  │
│           대학생, 취업준비생, 직장인     │  ○
└─────────────────────────────────────────┘
```

#### Selected State
```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  [Icon]   청년                          ┃
┃           (만 19-39세)                  ┃
┃           대학생, 취업준비생, 직장인     ┃  ●
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

### Visual Specifications

| Element | Property | Unselected | Selected |
|---------|----------|------------|----------|
| Card | Border Width | 1px | 2px |
| Card | Border Color | `Colors.grey[300]` | `#27B473` (Primary Green) |
| Card | Elevation | 1 | 4 |
| Card | Border Radius | 12px | 12px |
| Card | Padding | 16px | 16px |
| Icon Container | Size | 56x56 | 56x56 |
| Icon Container | Background | `Colors.grey[100]` | `#27B473` (10% opacity) |
| Icon Container | Border Radius | 12px | 12px |
| Icon | Size | 32px | 32px |
| Icon | Color | `Colors.grey[600]` | `#27B473` |
| Title | Font Size | 16px | 16px |
| Title | Font Weight | Bold | Bold |
| Title | Color | `Colors.black87` | `#27B473` |
| Age Range | Font Size | 12px | 12px |
| Age Range | Color | `Colors.grey[600]` | `Colors.grey[600]` |
| Description | Font Size | 14px | 14px |
| Description | Color | `Colors.grey[700]` | `Colors.grey[700]` |
| Check Icon | Size | 28px | 28px |
| Check Icon | Color | `Colors.grey[400]` | `#27B473` |
| Check Icon | Icon | `circle_outlined` | `check_circle` |

---

## Usage

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// In your screen widget
final categoriesAsync = ref.watch(ageCategoryProvider);

categoriesAsync.when(
  data: (categories) => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: categories.length,
    itemBuilder: (context, index) {
      final category = categories[index];
      return CategoryCard(
        category: category,
        key: ValueKey(category.id),
      );
    },
  ),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

### With Custom Spacing

```dart
ListView.separated(
  padding: const EdgeInsets.all(16),
  itemCount: categories.length,
  separatorBuilder: (context, index) => SizedBox(height: 12),
  itemBuilder: (context, index) {
    return CategoryCard(
      category: categories[index],
      key: ValueKey(categories[index].id),
    );
  },
)
```

---

## Props

### Required Props

| Prop | Type | Description |
|------|------|-------------|
| `category` | `AgeCategory` | The age category data to display |

### Optional Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `key` | `Key?` | null | Widget key (recommended: `ValueKey(category.id)`) |

---

## Component Structure

```dart
class CategoryCard extends ConsumerWidget {
  final AgeCategory category;

  const CategoryCard({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches selection state from provider
    final isSelected = ref.watch(
      isAgeCategorySelectedProvider(category.id),
    );

    return Card(
      // Card styling...
      child: InkWell(
        onTap: () {
          // Toggle selection via controller
          ref.read(ageCategoryControllerProvider.notifier)
              .toggleSelection(category.id);
        },
        child: Padding(
          child: Row(
            children: [
              // Icon container
              // Title, age range, description
              // Check icon
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Layout Breakdown

```
┌─────────────────────────────────────────────────────────┐
│  Padding: 16px                                          │
│  ┌─────────┐  ┌──────────────────────────┐  ┌────────┐ │
│  │         │  │  Title + Age Range      │  │        │ │
│  │  Icon   │  │  (Row)                  │  │ Check  │ │
│  │  56x56  │  │                          │  │ Icon   │ │
│  │         │  │  Description             │  │ 28x28  │ │
│  └─────────┘  └──────────────────────────┘  └────────┘ │
│  16px gap            Expanded                           │
└─────────────────────────────────────────────────────────┘
```

### Hierarchy

```
Card
└─ InkWell (tap handler)
   └─ Padding (16px all)
      └─ Row
         ├─ Container (Icon)
         │  └─ Icon (32px)
         ├─ SizedBox (16px width)
         ├─ Expanded
         │  └─ Column (crossAxisAlignment: start)
         │     ├─ Row
         │     │  ├─ Text (title)
         │     │  ├─ SizedBox (4px)
         │     │  └─ Text (age range)
         │     ├─ SizedBox (4px height)
         │     └─ Text (description)
         └─ Icon (check circle)
```

---

## State Management

### Provider Integration

The component uses Riverpod providers for reactive state:

```dart
// Check if category is selected
final isSelected = ref.watch(
  isAgeCategorySelectedProvider(category.id),
);

// Toggle selection on tap
ref.read(ageCategoryControllerProvider.notifier)
   .toggleSelection(category.id);
```

### Selection Flow

1. **User taps card** → `onTap()` called
2. **Controller notified** → `toggleSelection(category.id)`
3. **State updates** → `AgeCategorySelectionState` modified
4. **UI rebuilds** → Card reflects new selection state

---

## Styling Details

### Card Styling

```dart
Card(
  margin: const EdgeInsets.only(bottom: 12),
  elevation: isSelected ? 4 : 1,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(
      color: isSelected ? const Color(0xFF27B473) : Colors.grey[300]!,
      width: isSelected ? 2 : 1,
    ),
  ),
  // ...
)
```

### Icon Container Styling

```dart
Container(
  width: 56,
  height: 56,
  decoration: BoxDecoration(
    color: isSelected
        ? const Color(0xFF27B473).withOpacity(0.1)
        : Colors.grey[100],
    borderRadius: BorderRadius.circular(12),
  ),
  child: Icon(
    _getIconData(category.iconComponent),
    size: 32,
    color: isSelected ? const Color(0xFF27B473) : Colors.grey[600],
  ),
)
```

### Title Row Styling

```dart
Row(
  children: [
    Text(
      category.title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isSelected ? const Color(0xFF27B473) : Colors.black87,
      ),
    ),
    if (category.ageRangeText.isNotEmpty) ...[
      const SizedBox(width: 4),
      Text(
        category.ageRangeText,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    ],
  ],
)
```

---

## Icon Mapping

The component maps icon component names to Material Icons:

```dart
IconData _getIconData(String iconComponent) {
  switch (iconComponent) {
    case 'young_man':
      return Icons.person;
    case 'bride':
      return Icons.favorite;
    case 'baby':
      return Icons.child_care;
    case 'kinder':
      return Icons.family_restroom;
    case 'old_man':
      return Icons.elderly;
    case 'wheel_chair':
      return Icons.accessible;
    default:
      return Icons.category;
  }
}
```

**Note:** In production, this should use SVG assets from the design system:

```dart
// Future implementation
SvgPicture.asset(
  category.iconUrl ?? 'packages/pickly_design_system/assets/icons/default.svg',
  width: 32,
  height: 32,
  colorFilter: ColorFilter.mode(
    isSelected ? BrandColors.primary : Colors.grey[600]!,
    BlendMode.srcIn,
  ),
)
```

---

## Accessibility

### Semantic Labels

Currently, the component relies on Material's default semantics. For enhanced accessibility:

```dart
Semantics(
  label: '${category.title}, ${category.description}',
  hint: isSelected ? '선택됨' : '선택하려면 탭하세요',
  selected: isSelected,
  button: true,
  onTap: () {
    ref.read(ageCategoryControllerProvider.notifier)
       .toggleSelection(category.id);
  },
  child: Card(
    // ...
  ),
)
```

### Focus Management

```dart
InkWell(
  focusColor: const Color(0xFF27B473).withOpacity(0.1),
  hoverColor: const Color(0xFF27B473).withOpacity(0.05),
  splashColor: const Color(0xFF27B473).withOpacity(0.2),
  borderRadius: BorderRadius.circular(12),
  onTap: () { /* ... */ },
  // ...
)
```

---

## Responsive Design

### Breakpoints

The component is responsive by default due to `Expanded` widget:

```dart
Row(
  children: [
    Container(width: 56, height: 56), // Fixed size icon
    SizedBox(width: 16),              // Fixed gap
    Expanded(                          // Flexible text area
      child: Column(/* ... */),
    ),
    Icon(size: 28),                   // Fixed size check
  ],
)
```

### Text Overflow

```dart
Text(
  category.description,
  style: TextStyle(fontSize: 14),
  overflow: TextOverflow.ellipsis,  // Add if needed
  maxLines: 2,                       // Add if needed
)
```

---

## Animation

### Add Selection Animation

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  curve: Curves.easeInOut,
  decoration: BoxDecoration(
    color: isSelected
        ? const Color(0xFF27B473).withOpacity(0.1)
        : Colors.grey[100],
    borderRadius: BorderRadius.circular(12),
  ),
  // ...
)
```

### Add Ripple Effect

The `InkWell` already provides Material ripple effect:

```dart
InkWell(
  splashColor: const Color(0xFF27B473).withOpacity(0.2),
  highlightColor: const Color(0xFF27B473).withOpacity(0.1),
  borderRadius: BorderRadius.circular(12),
  onTap: () { /* ... */ },
  // ...
)
```

---

## Testing

### Widget Test Example

```dart
testWidgets('CategoryCard displays category information', (tester) async {
  final category = AgeCategory(
    id: 'test-id',
    title: '청년',
    description: '대학생, 취업준비생',
    iconComponent: 'young_man',
    sortOrder: 1,
    isActive: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: CategoryCard(category: category),
        ),
      ),
    ),
  );

  expect(find.text('청년'), findsOneWidget);
  expect(find.text('대학생, 취업준비생'), findsOneWidget);
});

testWidgets('CategoryCard toggles selection on tap', (tester) async {
  // Test implementation...
});
```

---

## Common Issues & Solutions

### Issue: Age Range Not Displaying

**Problem:** `category.ageRangeText` is empty

**Solution:** Add getter to `AgeCategory` model:

```dart
// In age_category.dart
String get ageRangeText {
  if (minAge == null && maxAge == null) return '';
  if (minAge != null && maxAge != null) {
    return '(만 $minAge-$maxAge세)';
  }
  if (minAge != null) return '(만 $minAge세 이상)';
  if (maxAge != null) return '(만 $maxAge세 이하)';
  return '';
}
```

### Issue: Icon Not Showing

**Problem:** Icon component name not mapped

**Solution:** Add to `_getIconData()` switch case or use SVG fallback

---

## Future Enhancements

1. **SVG Icon Support**
   - Replace Material Icons with SVG assets
   - Support custom icon colors and gradients

2. **Badge Support**
   - Add "인기" (popular) badge
   - Add "신규" (new) badge

3. **Transition Animations**
   - Smooth card expansion
   - Icon rotation/scale effects

4. **Haptic Feedback**
   - Vibration on selection toggle

5. **Dark Mode Support**
   - Theme-aware colors
   - Adjust opacity and contrast

---

## Related Documentation

- [Age Category API](../api/age-category-api.md)
- [Onboarding Header Component](./onboarding-header.md)
- [Onboarding Flow](../flows/onboarding-flow.md)
