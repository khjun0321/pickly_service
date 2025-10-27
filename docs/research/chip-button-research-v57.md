# Chip Button Pattern Research Report - v5.7

**Research Task**: Chip button patterns for SelectionChip component
**Date**: 2025-10-13
**Working Directory**: `/Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_mobile`

---

## Executive Summary

Based on comprehensive codebase analysis, chip-style buttons are **currently not implemented** in Pickly but represent a **strategic opportunity** for enhancing filter and selection UI patterns throughout the application.

**Key Findings**:
- ✅ **Existing Patterns**: Large card-based selection (SelectionListItem, SelectionCard)
- ❌ **Missing Pattern**: Chip/tag-style compact selections
- 🎯 **Opportunity**: Multiple use cases identified for chip buttons
- 📐 **Design System**: Ready for chip component integration

---

## 1. Current Selection Patterns

### 1.1 SelectionListItem (Primary Pattern)

**Location**: `lib/features/onboarding/widgets/selection_list_item.dart` (also in Design System at `packages/pickly_design_system/lib/src/components/selection/selection_list_item.dart`)

**Current Usage**:
- Age category selection screen (003)
- Single/multi-selection lists with icons
- Large format: 48px icon + title + description + checkmark

**Visual Structure**:
```
┌─────────────────────────────────────────┐
│ [Icon] Title                    [✓]     │
│        Description text                 │
└─────────────────────────────────────────┘
```

**Properties**:
- Height: ~80px per item
- Padding: 16px horizontal, 16px vertical
- Border radius: 12px
- Icon size: 48x48px container with 32x32px icon
- Spacing: 8px between items (Figma spec)

**Strengths**:
- ✅ Clear visual hierarchy
- ✅ Accessibility-friendly (large touch targets)
- ✅ Supports rich content (icon + description)

**Limitations**:
- ❌ Takes up significant vertical space
- ❌ Not suitable for many options
- ❌ Overkill for simple tags/filters

### 1.2 SelectionCard (Alternative Pattern)

**Location**: `packages/pickly_design_system/lib/src/components/selection/selection_card.dart`

**Current Usage**: Not actively used in onboarding (prepared for future use)

**Visual Structure**:
```
┌──────────┐
│  [Icon]  │
│   Title  │
└──────────┘
```

**Properties**:
- Compact card layout
- Suitable for grid layouts
- Icon-focused design

---

## 2. Identified Use Cases for Chip Buttons

### 2.1 Policy Filters (High Priority)

**Context**: Users need to filter policies by multiple criteria

**Current Problem**: No filter UI implemented yet

**Chip Use Cases**:

1. **Category Filters**:
   ```
   [주거] [복지] [교육] [취업] [육아]
   ```
   - Quick toggle on/off
   - Visual feedback on active filters
   - Space-efficient for 6-12 categories

2. **Region Filters**:
   ```
   [서울] [경기] [부산] [대구] [제주]
   ```
   - Multi-select for location-based filtering
   - Compact display for numerous regions

3. **Age Group Quick Filters**:
   ```
   [청년] [신혼부부] [육아가정] [다자녀] [어르신]
   ```
   - Quick re-filtering without going back to onboarding
   - Toggle active states

4. **Policy Status Tags**:
   ```
   [진행중] [마감임박] [신규] [인기]
   ```
   - Read-only status indicators
   - Color-coded by urgency

### 2.2 Search & Tagging (Medium Priority)

**Use Cases**:

1. **Search Keywords**:
   ```
   최근 검색: [청년정책] [주거지원] [취업혜택] [X]
   ```
   - Deletable chips for recent searches
   - Click to re-search

2. **Interest Tags** (Future Feature):
   ```
   관심 분야: [주거] [교육] [#청년정책] [#취업지원]
   ```
   - User-defined interest tags
   - Hashtag-style visual

3. **Applied Filters Summary**:
   ```
   적용된 필터: [서울] [청년] [주거] [전체 해제]
   ```
   - Show active filters
   - Quick removal

### 2.3 Onboarding Enhancement (Low Priority)

**Potential Improvements**:

1. **Secondary Selections**:
   - Instead of large SelectionListItem, use chips for secondary/optional choices
   - Example: "관심 있는 추가 혜택" with 10+ chip options

2. **Multi-Category Selection**:
   - Compact chip display for selecting multiple categories
   - More options visible at once

---

## 3. Technical Analysis

### 3.1 Design System Integration

**Current Design System Exports** (`pickly_design_system.dart`):
```dart
// Buttons
export 'widgets/buttons/primary_button.dart';
export 'widgets/buttons/next_button.dart';

// Cards
export 'widgets/cards/list_card.dart';

// Selection Components
export 'src/components/selection/selection_list_item.dart';
export 'src/components/selection/selection_card.dart';
```

**Proposed Addition**:
```dart
// Chips (NEW)
export 'src/components/chips/selection_chip.dart';
export 'src/components/chips/filter_chip.dart';
export 'src/components/chips/input_chip.dart';
```

### 3.2 Design Tokens Available

**From Design System**:
```dart
// Colors
BrandColors.primary      // #FF6B9D (pink)
BorderColors.subtle      // #E5E5E5
BackgroundColors.surface // #FFFFFF
TextColors.primary       // #3E3E3E

// Spacing
Spacing.xs  // 4px
Spacing.sm  // 8px
Spacing.md  // 12px
Spacing.lg  // 16px

// Typography
PicklyTypography.bodySmall
PicklyTypography.bodyMedium
PicklyTypography.labelMedium
```

**Recommended Chip Specs**:
```dart
// Size
height: 32px (compact), 40px (default), 48px (comfortable)
padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)
borderRadius: BorderRadius.circular(16) // Fully rounded

// Typography
PicklyTypography.labelMedium (13px, w600)

// Colors
Selected:   BrandColors.primary + white text
Unselected: BackgroundColors.muted + TextColors.primary
Hover:      BorderColors.subtle border
```

### 3.3 Existing Selection Patterns

**Selection State Management** (from `age_category_screen.dart`):
```dart
// Single selection pattern
String? _selectedId;

void _handleSelection(String id) {
  setState(() {
    if (_selectedId == id) {
      _selectedId = null; // Deselect
    } else {
      _selectedId = id; // Select new
    }
  });
}

// Multi selection pattern (for chips)
Set<String> _selectedIds = {};

void _handleMultiSelection(String id) {
  setState(() {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
  });
}
```

---

## 4. Flutter Chip Component Best Practices

### 4.1 Material Design Chips

Flutter provides built-in chip widgets:

**Types**:
1. **ChoiceChip**: Single selection from set (like radio buttons)
2. **FilterChip**: Multi-selection filtering (like checkboxes)
3. **InputChip**: User input with delete action
4. **ActionChip**: Trigger actions

**Example Usage**:
```dart
// Material FilterChip (baseline)
FilterChip(
  label: Text('주거'),
  selected: _selectedFilters.contains('housing'),
  onSelected: (selected) {
    setState(() {
      if (selected) {
        _selectedFilters.add('housing');
      } else {
        _selectedFilters.remove('housing');
      }
    });
  },
  selectedColor: BrandColors.primary,
  checkmarkColor: Colors.white,
  backgroundColor: BackgroundColors.muted,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
)
```

### 4.2 Custom SelectionChip Requirements

**Why Custom Component**:
- ✅ Match Pickly design system (colors, typography, spacing)
- ✅ Consistent with SelectionListItem visual language
- ✅ Add custom animations and interactions
- ✅ Control accessibility and semantics

**Proposed API**:
```dart
SelectionChip(
  label: '주거',
  isSelected: true,
  onTap: () => toggleFilter('housing'),

  // Optional
  icon: Icons.home,           // Leading icon
  onDeleted: () {},           // Delete button (for InputChip variant)
  enabled: true,              // Disabled state
  avatar: CircleAvatar(...),  // Custom avatar

  // Styling (with defaults from design system)
  selectedColor: BrandColors.primary,
  backgroundColor: BackgroundColors.muted,
  textStyle: PicklyTypography.labelMedium,
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
)
```

### 4.3 Accessibility Considerations

**Required Features**:
```dart
Semantics(
  button: true,
  selected: isSelected,
  label: 'Filter: ${label}',
  enabled: enabled,
  child: // chip widget
)
```

**Touch Target**: Minimum 48x48px (Material guidelines)

**Screen Reader**: "주거 필터, 선택됨" or "주거 필터, 선택되지 않음"

---

## 5. Component Flexibility Recommendations

### 5.1 Variants

**1. SelectionChip (Base)**:
- Single/multi selection
- Used for filters, categories, tags
- Toggle on/off behavior

**2. FilterChip (Specialized)**:
- Explicitly for filtering
- Shows count badge (e.g., "주거 (12)")
- Clear all action

**3. InputChip (Advanced)**:
- User-generated tags
- Delete button (X)
- Used for search history, custom tags

**4. ChoiceChip (Alternative)**:
- Single selection only (radio behavior)
- Visual emphasis on selected state

### 5.2 Layout Patterns

**Horizontal Scroll**:
```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: chips.map((chip) =>
      Padding(
        padding: EdgeInsets.only(right: Spacing.sm),
        child: SelectionChip(...),
      )
    ).toList(),
  ),
)
```

**Wrap Layout** (Multi-line):
```dart
Wrap(
  spacing: Spacing.sm,      // Horizontal gap
  runSpacing: Spacing.sm,   // Vertical gap
  children: chips.map((chip) => SelectionChip(...)).toList(),
)
```

**Grid Layout**:
```dart
GridView.count(
  crossAxisCount: 3,
  mainAxisSpacing: Spacing.sm,
  crossAxisSpacing: Spacing.sm,
  childAspectRatio: 2.5, // Wide chips
  children: chips.map((chip) => SelectionChip(...)).toList(),
)
```

### 5.3 State Management Integration

**Riverpod Pattern** (recommended):
```dart
// Provider
final selectedFiltersProvider = StateNotifierProvider<SelectedFiltersNotifier, Set<String>>(
  (ref) => SelectedFiltersNotifier(),
);

class SelectedFiltersNotifier extends StateNotifier<Set<String>> {
  SelectedFiltersNotifier() : super({});

  void toggle(String filter) {
    if (state.contains(filter)) {
      state = {...state}..remove(filter);
    } else {
      state = {...state, filter};
    }
  }

  void clear() => state = {};
}

// Usage in Widget
final selectedFilters = ref.watch(selectedFiltersProvider);

SelectionChip(
  label: '주거',
  isSelected: selectedFilters.contains('housing'),
  onTap: () => ref.read(selectedFiltersProvider.notifier).toggle('housing'),
)
```

---

## 6. Figma Design System Alignment

### 6.1 Figma Reference

**URL**: https://www.figma.com/design/xOpx8v3FiYmCxSLkj9sgcu/pickly?node-id=39-4490&m=dev

**Observations**:
- Current Figma designs use large selection cards (SelectionListItem pattern)
- No explicit chip/tag components visible in node-id=39-4490
- Opportunity to extend Figma design system with chip variants

### 6.2 Recommended Figma Components

**Create in Figma**:
1. `Chip/Selection/Default` - Unselected state
2. `Chip/Selection/Selected` - Selected state with checkmark
3. `Chip/Selection/Disabled` - Disabled state
4. `Chip/Filter/WithCount` - Filter chip with badge
5. `Chip/Input/Deletable` - Chip with X button

**Specs to Document**:
- Height: 32px (compact), 40px (default)
- Border radius: 16px (fully rounded)
- Padding: 12px horizontal, 8px vertical
- Gap between icon and text: 4px
- Colors: Match existing BrandColors

---

## 7. Implementation Priority

### Phase 1: Core SelectionChip (Week 1)
- [x] Research completed (this document)
- [ ] Create `selection_chip.dart` in design system
- [ ] Implement selected/unselected states
- [ ] Add to `pickly_design_system.dart` exports
- [ ] Write widget tests

### Phase 2: Variants (Week 2)
- [ ] FilterChip with count badge
- [ ] InputChip with delete button
- [ ] Disabled state handling
- [ ] Hover/focus states (web support)

### Phase 3: Integration (Week 3)
- [ ] Add to policy filter screen (when implemented)
- [ ] Search keywords UI
- [ ] Onboarding optional selections

### Phase 4: Polish (Week 4)
- [ ] Animations (selection transition)
- [ ] Accessibility testing
- [ ] Performance optimization (100+ chips)
- [ ] Documentation and examples

---

## 8. Code Example: Proposed SelectionChip

```dart
// File: packages/pickly_design_system/lib/src/components/chips/selection_chip.dart

import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// A compact chip button for selection and filtering UI
///
/// SelectionChip is a space-efficient alternative to SelectionListItem,
/// ideal for filters, tags, categories, and multi-option selections.
///
/// Supports:
/// - Single and multi-selection patterns
/// - Optional leading icon
/// - Selected/unselected states
/// - Accessibility semantics
///
/// Example:
/// ```dart
/// SelectionChip(
///   label: '주거',
///   isSelected: true,
///   onTap: () => toggleFilter('housing'),
/// )
/// ```
class SelectionChip extends StatelessWidget {
  const SelectionChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.enabled = true,
    this.size = SelectionChipSize.medium,
  });

  /// Text label displayed on the chip
  final String label;

  /// Whether this chip is currently selected
  final bool isSelected;

  /// Callback when chip is tapped
  final VoidCallback? onTap;

  /// Optional leading icon
  final IconData? icon;

  /// Whether the chip is enabled for interaction
  final bool enabled;

  /// Chip size variant
  final SelectionChipSize size;

  @override
  Widget build(BuildContext context) {
    final chipHeight = _getHeight();
    final chipPadding = _getPadding();
    final textStyle = _getTextStyle();

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: enabled,
      label: '$label ${isSelected ? '선택됨' : ''}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(chipHeight / 2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: chipHeight,
            padding: chipPadding,
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              border: Border.all(
                color: _getBorderColor(),
                width: isSelected ? 2.0 : 1.0,
              ),
              borderRadius: BorderRadius.circular(chipHeight / 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: _getContentColor(),
                  ),
                  const SizedBox(width: Spacing.xs),
                ],
                Text(
                  label,
                  style: textStyle.copyWith(
                    color: _getContentColor(),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: Spacing.xs),
                  Icon(
                    Icons.check,
                    size: 16,
                    color: _getContentColor(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case SelectionChipSize.small:
        return 32;
      case SelectionChipSize.medium:
        return 40;
      case SelectionChipSize.large:
        return 48;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case SelectionChipSize.small:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 6);
      case SelectionChipSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case SelectionChipSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case SelectionChipSize.small:
        return PicklyTypography.labelSmall;
      case SelectionChipSize.medium:
        return PicklyTypography.labelMedium;
      case SelectionChipSize.large:
        return PicklyTypography.bodyMedium;
    }
  }

  Color _getBackgroundColor() {
    if (!enabled) {
      return BackgroundColors.muted.withOpacity(0.5);
    }
    return isSelected ? BrandColors.primary : BackgroundColors.surface;
  }

  Color _getBorderColor() {
    if (!enabled) {
      return BorderColors.subtle.withOpacity(0.5);
    }
    return isSelected ? BrandColors.primary : BorderColors.subtle;
  }

  Color _getContentColor() {
    if (!enabled) {
      return TextColors.tertiary;
    }
    return isSelected ? Colors.white : TextColors.primary;
  }
}

/// Size variants for SelectionChip
enum SelectionChipSize {
  small,   // 32px height - Compact display
  medium,  // 40px height - Default
  large,   // 48px height - Touch-friendly
}
```

---

## 9. Coordination Report

### Hook Execution
```bash
✅ Pre-task: Research chip patterns v5.7 (Task ID: task-1760362926368-7b4aghx66)
📝 Research Status: Stored in .swarm/memory.db
⏭️  Post-task: Pending completion notification
```

### Key Findings Summary

**For Memory Storage**:
```json
{
  "task": "chip-button-research-v57",
  "status": "completed",
  "findings": {
    "current_patterns": ["SelectionListItem", "SelectionCard"],
    "missing_pattern": "chip_buttons",
    "priority_use_cases": [
      "policy_filters",
      "category_tags",
      "search_keywords",
      "applied_filters_summary"
    ],
    "recommended_implementation": {
      "component": "SelectionChip",
      "location": "packages/pickly_design_system/lib/src/components/chips/",
      "variants": ["selection", "filter", "input", "choice"],
      "priority": "high"
    },
    "integration_points": [
      "policy_feed_filters",
      "search_screen",
      "onboarding_secondary_selections"
    ]
  },
  "next_steps": [
    "Create SelectionChip component",
    "Design Figma chip variants",
    "Implement in policy filter screen",
    "Add to design system exports"
  ]
}
```

---

## 10. Recommendations

### Immediate Actions
1. ✅ **Create SelectionChip component** in design system
2. 📐 **Design Figma chip variants** to extend design language
3. 🎯 **Identify first integration point** (likely policy filters)

### Component Flexibility
- Support both single and multi-selection patterns
- Provide size variants (small, medium, large)
- Enable optional icons and badges
- Maintain accessibility standards
- Align with existing design tokens

### Integration Strategy
- Start with policy filter screen (highest priority)
- Add to search keywords UI
- Consider onboarding enhancements (optional selections)
- Document usage patterns in development guide

---

**Report Generated**: 2025-10-13
**Research Agent**: Researcher v5.7
**Status**: ✅ Complete
**Next Agent**: Planner (for SelectionChip implementation roadmap)
