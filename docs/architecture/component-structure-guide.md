# Component Structure Guide - Pickly Project

## 📋 Overview

This guide explains the clear separation between Design System components and Feature-specific widgets in the Pickly project. Following these rules ensures maintainability, reusability, and prevents code duplication.

---

## 🎯 Core Principle: The "3+ Places Rule"

**Simple Rule**: If a component is used in **3 or more places**, it belongs in the **Design System**. Otherwise, it stays in the **Feature widgets**.

### When to Use Design System (`packages/pickly_design_system/`)

✅ **Design System components are:**
- **Reusable**: Used across multiple features (3+ places)
- **Generic**: No business logic, no feature-specific code
- **Pure UI**: Only visual presentation and basic interactions
- **Configurable**: Accept props to customize appearance/behavior

**Examples from our codebase:**
- `SelectionChip` - Used in age_category, region, and future onboarding steps
- `SelectionCheckmark` - Reusable checkmark for any selection UI
- `AppHeader` - Used across all screens with navigation
- `ProgressBar` - Used in all onboarding flows

### When to Use Feature Widgets (`apps/pickly_mobile/lib/features/*/widgets/`)

✅ **Feature widgets are:**
- **Feature-specific**: Used in only 1-2 places within a single feature
- **Business logic**: May contain domain logic or state management
- **Screen-specific**: Tailored for specific screen requirements
- **Temporary**: May be promoted to Design System if usage grows

**Examples:**
- `RegionCard` (if only used in region selection)
- `ProfileAvatar` (if only used in profile feature)
- `CategoryFilter` (if only used in category feature)

---

## 📁 Directory Structure

```
pickly_service/
├── packages/
│   └── pickly_design_system/
│       ├── lib/
│       │   ├── widgets/
│       │   │   ├── selection/              # Selection-related components
│       │   │   │   ├── selection_chip.dart
│       │   │   │   └── selection_checkmark.dart
│       │   │   ├── app_header.dart         # Navigation header
│       │   │   └── indicators/
│       │   │       └── progress_bar.dart
│       │   └── pickly_design_system.dart   # Main export file
│       └── assets/
│           └── icons/
│               ├── ic_back.svg
│               └── ic_hamburger.svg
│
└── apps/
    └── pickly_mobile/
        └── lib/
            └── features/
                ├── onboarding/
                │   ├── screens/
                │   │   ├── age_category_screen.dart
                │   │   └── region_selection_screen.dart
                │   ├── widgets/            # Feature-specific widgets only
                │   │   └── (future components if needed)
                │   └── providers/
                │       └── age_category_provider.dart
                ├── profile/
                │   └── widgets/
                └── category/
                    └── widgets/
```

---

## 🔧 Implementation Rules

### 1. Design System Component Creation

**Location**: `packages/pickly_design_system/lib/widgets/[category]/`

**Template**:
```dart
// packages/pickly_design_system/lib/widgets/selection/selection_chip.dart
import 'package:flutter/material.dart';

/// A reusable selection chip component for single/multi-selection UI
///
/// This component is used across multiple features (3+ places)
/// and contains NO business logic - only pure UI.
class SelectionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double? width;
  final double? height;

  const SelectionChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
```

**Export in main file**:
```dart
// packages/pickly_design_system/lib/pickly_design_system.dart
library pickly_design_system;

// Selection components
export 'widgets/selection/selection_chip.dart';
export 'widgets/selection/selection_checkmark.dart';

// Navigation components
export 'widgets/app_header.dart';

// Indicators
export 'widgets/indicators/progress_bar.dart';
```

### 2. Feature Widget Creation

**Location**: `apps/pickly_mobile/lib/features/[feature_name]/widgets/`

**Template**:
```dart
// apps/pickly_mobile/lib/features/onboarding/widgets/custom_age_display.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/age_category_provider.dart';

/// Feature-specific widget used ONLY in age category screen
///
/// This widget contains business logic and is not intended
/// for reuse across other features.
class CustomAgeDisplay extends ConsumerWidget {
  const CustomAgeDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAge = ref.watch(ageCategoryProvider);

    // Business logic specific to onboarding
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text('Selected: $selectedAge'),
    );
  }
}
```

---

## 📦 Import Rules

### ✅ CORRECT Import Patterns

**From Design System:**
```dart
// In feature screens/widgets
import 'package:pickly_design_system/pickly_design_system.dart';

// Use imported components
SelectionChip(label: 'Option', isSelected: true, onTap: () {});
AppHeader(title: 'Screen Title');
ProgressBar(progress: 0.5);
```

**From Feature Widgets:**
```dart
// Only within the same feature
import '../widgets/custom_age_display.dart';

// Or with relative path
import 'package:pickly_mobile/features/onboarding/widgets/custom_age_display.dart';
```

### ❌ WRONG Import Patterns

```dart
// ❌ NEVER import from Design System using relative paths
import '../../../../../packages/pickly_design_system/lib/widgets/selection/selection_chip.dart';

// ❌ NEVER create duplicate components in features
// If SelectionChip exists in Design System, DON'T create:
// apps/pickly_mobile/lib/features/onboarding/widgets/selection_chip.dart

// ❌ NEVER import feature widgets across features
import 'package:pickly_mobile/features/profile/widgets/profile_avatar.dart';
// in category feature (if needed, promote to Design System)
```

---

## 🎨 Real Examples from Pickly Codebase

### Example 1: SelectionChip Component

**Location**: `packages/pickly_design_system/lib/widgets/selection/selection_chip.dart`

**Usage across features:**
1. `apps/pickly_mobile/lib/features/onboarding/screens/age_category_screen.dart`
2. `apps/pickly_mobile/lib/features/onboarding/screens/region_selection_screen.dart`
3. Future: interest_selection_screen, goal_selection_screen, etc.

**Why in Design System?**
- Used in 3+ places (meets the rule)
- Pure UI with no business logic
- Highly reusable across any selection interface

### Example 2: SelectionCheckmark Component

**Location**: `packages/pickly_design_system/lib/widgets/selection/selection_checkmark.dart`

**Usage:**
- Inside `SelectionChip` for selected state
- Can be used independently in other selection UIs

**Why in Design System?**
- Reusable visual indicator
- No business logic
- Consistent design across app

### Example 3: AppHeader Component

**Location**: `packages/pickly_design_system/lib/widgets/app_header.dart`

**Usage across screens:**
1. Age category screen
2. Region selection screen
3. All future onboarding screens
4. Profile screens
5. Settings screens

**Why in Design System?**
- Used in 5+ places
- Provides consistent navigation experience
- Pure UI component

---

## 🚫 Common Mistakes to Avoid

### Mistake 1: Duplicate Components

**❌ WRONG:**
```
packages/pickly_design_system/lib/widgets/selection/selection_chip.dart
apps/pickly_mobile/lib/features/onboarding/widgets/selection_chip.dart  // DUPLICATE!
```

**✅ CORRECT:**
```
packages/pickly_design_system/lib/widgets/selection/selection_chip.dart  // Single source of truth
```

### Mistake 2: Wrong Import Paths

**❌ WRONG:**
```dart
// In age_category_screen.dart
import '../../../packages/pickly_design_system/lib/widgets/selection/selection_chip.dart';
```

**✅ CORRECT:**
```dart
// In age_category_screen.dart
import 'package:pickly_design_system/pickly_design_system.dart';
```

### Mistake 3: Business Logic in Design System

**❌ WRONG:**
```dart
// In packages/pickly_design_system/lib/widgets/selection/selection_chip.dart
class SelectionChip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(ageCategoryProvider); // ❌ Business logic!
    // ...
  }
}
```

**✅ CORRECT:**
```dart
// In packages/pickly_design_system/lib/widgets/selection/selection_chip.dart
class SelectionChip extends StatelessWidget {
  final bool isSelected; // ✅ Accept state via props
  final VoidCallback onTap;

  // Pure UI - no providers, no business logic
}
```

### Mistake 4: Feature Widgets in Wrong Location

**❌ WRONG:**
```
packages/pickly_design_system/lib/widgets/onboarding_specific_widget.dart  // Feature-specific!
```

**✅ CORRECT:**
```
apps/pickly_mobile/lib/features/onboarding/widgets/onboarding_specific_widget.dart
```

---

## 📊 Decision Flow Chart

```
Is the component used in 3+ places?
│
├─ YES → Design System
│   │
│   ├─ Does it contain business logic?
│   │   ├─ YES → ❌ REFACTOR: Extract logic to providers
│   │   └─ NO → ✅ Good to go!
│   │
│   └─ Location: packages/pickly_design_system/lib/widgets/[category]/
│
└─ NO (1-2 places) → Feature Widget
    │
    ├─ Is it truly feature-specific?
    │   ├─ YES → ✅ Keep in feature/widgets/
    │   └─ NO → Consider Design System for future reuse
    │
    └─ Location: apps/pickly_mobile/lib/features/[feature]/widgets/
```

---

## 🔄 Migration Guide: Feature → Design System

When a component grows from 2 places to 3+ places:

### Step 1: Move the file
```bash
# Move the component
mv apps/pickly_mobile/lib/features/onboarding/widgets/selection_chip.dart \
   packages/pickly_design_system/lib/widgets/selection/selection_chip.dart
```

### Step 2: Remove business logic
```dart
// Before (in feature widget)
class SelectionChip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(someProvider); // Remove this
    // ...
  }
}

// After (in Design System)
class SelectionChip extends StatelessWidget {
  final bool isSelected; // Accept via props

  const SelectionChip({required this.isSelected, ...});

  @override
  Widget build(BuildContext context) {
    // Pure UI only
  }
}
```

### Step 3: Export in main file
```dart
// packages/pickly_design_system/lib/pickly_design_system.dart
export 'widgets/selection/selection_chip.dart';
```

### Step 4: Update imports in all usage locations
```dart
// Before
import '../widgets/selection_chip.dart';

// After
import 'package:pickly_design_system/pickly_design_system.dart';
```

### Step 5: Update usage to pass state via props
```dart
// Before (in feature widget)
SelectionChip() // Got state from provider internally

// After (in feature screen)
final isSelected = ref.watch(provider);
SelectionChip(isSelected: isSelected, ...) // Pass state explicitly
```

---

## ✅ Best Practices Checklist

### When Creating a New Component

- [ ] Determine if it will be used in 3+ places
- [ ] If YES → Design System, if NO → Feature widget
- [ ] Ensure NO business logic in Design System components
- [ ] Use correct import path (`package:pickly_design_system`)
- [ ] Export in `pickly_design_system.dart` if Design System
- [ ] Add clear documentation comments
- [ ] Follow naming conventions (e.g., `SelectionChip`, not `selectionChip`)

### Before Committing

- [ ] No duplicate components exist
- [ ] All imports use package notation
- [ ] Design System components are pure UI
- [ ] Feature widgets are in correct feature directory
- [ ] All exports are registered in main library file
- [ ] Tests are written (if applicable)

---

## 📚 Quick Reference

### Design System Components Checklist
- ✅ Used in 3+ places
- ✅ Pure UI (no business logic)
- ✅ Generic and configurable
- ✅ Exported in `pickly_design_system.dart`
- ✅ Imported via `package:pickly_design_system`

### Feature Widget Checklist
- ✅ Used in 1-2 places (within single feature)
- ✅ May contain business logic
- ✅ Feature-specific requirements
- ✅ Located in `features/[feature]/widgets/`
- ✅ Not exported to other features

---

## 🎓 Examples Summary

### Current Design System Components
```
packages/pickly_design_system/lib/widgets/
├── selection/
│   ├── selection_chip.dart          # ✅ Used in 3+ onboarding screens
│   └── selection_checkmark.dart     # ✅ Reusable indicator
├── app_header.dart                  # ✅ Used across all screens
└── indicators/
    └── progress_bar.dart            # ✅ Used in all onboarding flows
```

### Current Feature Widgets
```
apps/pickly_mobile/lib/features/onboarding/widgets/
└── (currently empty - using Design System components)
    # Future feature-specific widgets go here
```

---

## 🔗 Related Documentation

- [Flutter Widget Best Practices](https://flutter.dev/docs/development/ui/widgets-intro)
- [Package Structure Guide](https://dart.dev/guides/libraries/create-library-packages)
- [Pickly Design System README](../../packages/pickly_design_system/README.md)

---

## 📝 Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-14 | Initial comprehensive guide created |

---

**Questions or improvements?** Contact the architecture team or submit a PR with suggestions.
