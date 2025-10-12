# Component Dependency Map - Pickly Mobile Onboarding

**Analysis Date:** 2025-10-12
**Analyzed Components:** SelectionListItem, OnboardingBottomButton, NextButton, OnboardingHeader

---

## Executive Summary

This analysis reveals a clear component structure with **no circular dependencies**. The onboarding widgets are well-organized with a barrel export file (`widgets.dart`) that simplifies imports. However, there are **inconsistent import patterns** across the codebase - some files use relative imports while others use absolute package imports.

### Key Findings

- **4 core onboarding widgets** analyzed
- **1 barrel export file** (`widgets.dart`) for centralized exports
- **2 screens** using these components
- **7+ test files** with comprehensive coverage
- **No circular dependencies detected**
- **Import inconsistencies** require standardization

---

## Component Overview

### 1. SelectionListItem
**Location:** `/lib/features/onboarding/widgets/selection_list_item.dart`

**Description:** Horizontal list item component for vertical list selection with icon, title, description, and checkmark indicator.

**Key Features:**
- Supports SVG and IconData icons
- Multi-selection capable
- Active/inactive states
- Accessibility support
- 64px fixed height (Figma spec)

**Status:** ⚠️ **DEPRECATED** - File marked for migration to design system package

---

### 2. OnboardingBottomButton
**Location:** `/lib/features/onboarding/widgets/onboarding_bottom_button.dart`

**Description:** Bottom fixed CTA button with loading states.

**Key Features:**
- Enabled/disabled states
- Loading indicator support
- Safe area handling
- Design token integration
- Fixed bottom positioning

**Current Usage:** **NONE** - No active imports found

---

### 3. NextButton
**Location:** `/lib/features/onboarding/widgets/next_button.dart`

**Description:** Reusable bottom CTA button for onboarding navigation.

**Key Features:**
- Primary button styling
- Loading state support
- Icon support
- Custom colors (backgroundColor, textColor)
- Companion widget: `CompactNextButton`

**Current Usage:** Test files only

---

### 4. OnboardingHeader
**Location:** `/lib/features/onboarding/widgets/onboarding_header.dart`

**Description:** Header with progress indicator and optional back button.

**Key Features:**
- Linear progress indicator
- Configurable step tracking
- Back button with custom callback
- Safe area support
- Accessibility labels

**Current Usage:** Active in `age_category_screen.dart`

---

## Dependency Graph

```
┌─────────────────────────────────────────────────┐
│  Barrel Export (widgets.dart)                   │
├─────────────────────────────────────────────────┤
│  Exports:                                        │
│  - onboarding_header.dart                       │
│  - selection_card.dart                          │
│  - selection_list_item.dart                     │
│  - next_button.dart                             │
│  (NOT exported: onboarding_bottom_button.dart)  │
└─────────────────────────────────────────────────┘
           │
           ├──────────────────┬──────────────────┐
           ▼                  ▼                  ▼
    ┌────────────┐   ┌──────────────┐   ┌─────────────┐
    │  Screens   │   │    Tests     │   │   Unused    │
    └────────────┘   └──────────────┘   └─────────────┘
```

---

## Component Usage Matrix

| Component | Screen Usage | Test Usage | Import Pattern | Status |
|-----------|-------------|------------|----------------|--------|
| **SelectionListItem** | `age_category_screen.dart` | 3+ test files | Mixed (relative + absolute) | ⚠️ Deprecated, moving to design system |
| **OnboardingBottomButton** | None | None | None | ❌ Unused |
| **NextButton** | None | 2 test files | Absolute package imports | ⚠️ Test-only |
| **OnboardingHeader** | `age_category_screen.dart` | 2+ test files | Mixed (relative + absolute) | ✅ Active |

---

## Detailed Usage Analysis

### SelectionListItem

#### Production Usage
1. **age_category_screen.dart** (Line 186)
   ```dart
   import '../widgets/selection_list_item.dart';  // Relative import

   SelectionListItem(
     iconUrl: category.iconUrl,
     title: category.title,
     description: category.description,
     isSelected: isSelected,
     onTap: () => _handleCategorySelection(category.id),
   )
   ```

#### Test Usage
1. **selection_list_item_test.dart**
   - Unit tests for the widget
   - Import: `package:pickly_mobile/features/onboarding/widgets/selection_list_item.dart`

2. **integration_test.dart** (8+ usages)
   - Integration tests for onboarding flow
   - Import: `package:pickly_mobile/features/onboarding/widgets/selection_list_item.dart`

3. **age_category_screen_comprehensive_test.dart** (15+ usages)
   - Comprehensive screen tests
   - Import: `package:pickly_mobile/features/onboarding/widgets/selection_list_item.dart`

#### Migration Status
⚠️ **File marked as DEPRECATED** - Header comment indicates migration to design system package:
```dart
// DEPRECATED: This file has been moved to the design system package
// Use: import 'package:pickly_design_system/pickly_design_system.dart';
```

---

### OnboardingBottomButton

#### Production Usage
**NONE** - No active imports found in production code

#### Test Usage
**NONE** - No test files reference this component

#### Status
❌ **UNUSED** - Candidate for removal or consolidation with `NextButton`

---

### NextButton

#### Production Usage
**NONE** - No active imports in screens

#### Test Usage
1. **age_category_screen_test.dart** (Lines 100-125)
   - Import: `package:pickly_mobile/features/onboarding/widgets/next_button.dart`
   - Tests for enabled/disabled states
   ```dart
   final nextButton = find.byType(NextButton);
   final nextButtonWidget = tester.widget<NextButton>(nextButton);
   expect(nextButtonWidget.enabled, false);
   ```

2. **age_category_screen_refactored_test.dart** (Line 286)
   - Tests for button text finding
   ```dart
   // Assert - Find the NextButton by looking for the text
   ```

#### Companion Widget
**CompactNextButton** - Compact variant for inline use (Line 197)

---

### OnboardingHeader

#### Production Usage
1. **age_category_screen.dart** (Line 73)
   ```dart
   import '../widgets/onboarding_header.dart';  // Relative import

   OnboardingHeader(
     currentStep: 2,
     totalSteps: 5,
     showBackButton: true,
     onBack: _handleBack,
   )
   ```

#### Test Usage
1. **age_category_screen_test.dart**
   - Import: `package:pickly_mobile/features/onboarding/widgets/onboarding_header.dart`
   ```dart
   expect(find.byType(OnboardingHeader), findsOneWidget);
   ```

2. **age_category_screen_comprehensive_test.dart** (Lines 139-525)
   - Import: `package:pickly_mobile/features/onboarding/widgets/onboarding_header.dart`
   - Tests header display, back button, semantics
   ```dart
   final header = tester.widget<OnboardingHeader>(find.byType(OnboardingHeader));
   expect(header.currentStep, 2);
   expect(header.totalSteps, 5);
   ```

---

## Import Path Analysis

### Current Import Patterns

#### Pattern 1: Relative Imports (Production Code)
```dart
// age_category_screen.dart
import '../widgets/onboarding_header.dart';
import '../widgets/selection_list_item.dart';
```

#### Pattern 2: Absolute Package Imports (Test Code)
```dart
// Tests
import 'package:pickly_mobile/features/onboarding/widgets/selection_list_item.dart';
import 'package:pickly_mobile/features/onboarding/widgets/onboarding_header.dart';
import 'package:pickly_mobile/features/onboarding/widgets/next_button.dart';
```

#### Pattern 3: Barrel Import (Available but Unused)
```dart
// Available via widgets.dart but not currently used
import 'package:pickly_mobile/features/onboarding/widgets/widgets.dart';
```

### Import Inconsistencies

| File Type | Import Style | Files |
|-----------|-------------|-------|
| Production | Relative (`../widgets/`) | `age_category_screen.dart` |
| Tests | Absolute package | All test files |
| Barrel | Not used | None |

---

## Circular Dependency Check

✅ **NO CIRCULAR DEPENDENCIES DETECTED**

### Dependency Tree
```
External Dependencies:
├── flutter/material.dart
├── flutter_svg/flutter_svg.dart
├── pickly_design_system/pickly_design_system.dart
└── flutter_riverpod/flutter_riverpod.dart (screens)

Widget Dependencies:
├── onboarding_header.dart (standalone)
├── selection_list_item.dart (standalone)
├── next_button.dart (standalone, includes CompactNextButton)
├── onboarding_bottom_button.dart (standalone)
├── selection_card.dart (standalone)
└── age_selection_card.dart (standalone)

Screen Dependencies:
└── age_category_screen.dart
    ├── imports: onboarding_header.dart (relative)
    ├── imports: selection_list_item.dart (relative)
    └── imports: age_category_provider.dart
```

All widgets are **standalone** with no inter-widget dependencies.

---

## Related Components (Not Analyzed)

### Additional Widgets Found
1. **selection_card.dart** - Icon-based card selection (grid layout)
2. **age_selection_card.dart** - Specialized card with fixed sizing

### Export Status
```dart
// widgets.dart exports:
export 'onboarding_header.dart';        ✅ Exported
export 'selection_card.dart';           ✅ Exported
export 'selection_list_item.dart';      ✅ Exported
export 'next_button.dart';              ✅ Exported

// NOT exported:
// onboarding_bottom_button.dart        ❌ Not in barrel
// age_selection_card.dart              ❌ Not in barrel
```

---

## Migration Impact Analysis

### SelectionListItem Migration to Design System

**Impact:**
- **1 production file** needs import update: `age_category_screen.dart`
- **3+ test files** need import updates
- **1 barrel export** needs removal/deprecation notice

**Required Changes:**
```diff
# age_category_screen.dart
- import '../widgets/selection_list_item.dart';
+ import 'package:pickly_design_system/pickly_design_system.dart';

# Test files
- import 'package:pickly_mobile/features/onboarding/widgets/selection_list_item.dart';
+ import 'package:pickly_design_system/pickly_design_system.dart';

# widgets.dart
- export 'selection_list_item.dart';
+ // export 'selection_list_item.dart';  // DEPRECATED: Moved to design system
```

---

## Recommendations

### 1. Import Standardization
**Priority:** High

Standardize all imports to use the barrel export pattern:
```dart
// Recommended pattern
import 'package:pickly_mobile/features/onboarding/widgets/widgets.dart';
```

**Benefits:**
- Single import statement
- Easier refactoring
- Clearer dependency tracking
- Future-proof for component reorganization

### 2. Component Consolidation
**Priority:** Medium

**OnboardingBottomButton vs NextButton:**
- Both serve similar purposes (bottom CTA buttons)
- `OnboardingBottomButton` is unused
- Consider removing `OnboardingBottomButton` or merging functionality

**Action:**
```dart
// Remove unused component
- lib/features/onboarding/widgets/onboarding_bottom_button.dart
```

### 3. Complete Design System Migration
**Priority:** High

Finish migrating `SelectionListItem` to design system:

**Steps:**
1. Update all imports in production code
2. Update all imports in test files
3. Add deprecation warning period (1-2 releases)
4. Remove deprecated file
5. Update barrel export

### 4. Barrel Export Enhancement
**Priority:** Low

Add explicit deprecation exports:
```dart
// widgets.dart
export 'onboarding_header.dart';
export 'selection_card.dart';
export 'next_button.dart';

// Deprecated exports with warnings
@Deprecated('Use SelectionListItem from pickly_design_system package instead')
export 'selection_list_item.dart';
```

### 5. Test Coverage for NextButton
**Priority:** Medium

`NextButton` is only used in tests but not in production. Either:
- **Option A:** Replace inline button with `NextButton` in `age_category_screen.dart`
- **Option B:** Remove component if not needed

**Current Implementation (age_category_screen.dart L139-165):**
```dart
// Inline button implementation
ElevatedButton(
  onPressed: _selectedCategoryIds.isNotEmpty ? _handleNext : null,
  // ... button configuration
)
```

**Suggested Replacement:**
```dart
NextButton(
  label: '다음',
  enabled: _selectedCategoryIds.isNotEmpty,
  onPressed: _handleNext,
)
```

---

## Summary Statistics

| Metric | Count |
|--------|-------|
| Components Analyzed | 4 |
| Production Screens | 1 |
| Test Files | 7+ |
| Circular Dependencies | 0 |
| Unused Components | 1 (`OnboardingBottomButton`) |
| Components in Migration | 1 (`SelectionListItem`) |
| Import Patterns | 3 (relative, absolute, barrel) |
| Total Import Statements | 15+ |

---

## Files Requiring Import Updates

### High Priority (Production Code)
1. `/lib/features/onboarding/screens/age_category_screen.dart`
   - Update: `SelectionListItem` import to design system
   - Consider: Replace inline button with `NextButton`

### Medium Priority (Test Files)
1. `/test/features/onboarding/widgets/selection_list_item_test.dart`
2. `/test/features/onboarding/integration_test.dart`
3. `/test/features/onboarding/screens/age_category_screen_comprehensive_test.dart`
4. `/test/features/onboarding/screens/age_category_screen_test.dart`
5. `/test/features/onboarding/screens/age_category_screen_refactored_test.dart`

### Low Priority (Barrel Export)
1. `/lib/features/onboarding/widgets/widgets.dart`
   - Add deprecation notices
   - Update exports after migration complete

---

## Conclusion

The onboarding component architecture is **well-structured with no circular dependencies**. The main issues are:

1. **Import inconsistencies** - Mix of relative and absolute imports
2. **Unused component** - `OnboardingBottomButton` has zero usage
3. **Incomplete migration** - `SelectionListItem` marked deprecated but still imported
4. **Underutilized components** - `NextButton` exists but not used in production

**Next Steps:**
1. Complete `SelectionListItem` migration to design system
2. Standardize imports to use barrel pattern
3. Remove or repurpose `OnboardingBottomButton`
4. Consider using `NextButton` in `age_category_screen.dart`

---

**Analysis completed using Claude Code Quality Analyzer**
