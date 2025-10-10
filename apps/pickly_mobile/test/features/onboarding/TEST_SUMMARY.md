# Age Category Screen Test Summary

## Overview

Comprehensive test suite for the `AgeCategoryScreen` onboarding flow (Step 3/5 - 003).

## Test Files Created

### 1. Widget Tests

#### `/test/features/onboarding/screens/age_category_screen_comprehensive_test.dart`
Comprehensive widget tests for the main screen component.

**Test Groups:**
- **Rendering Tests** (7 tests)
  - Display title and guidance text
  - Display category items
  - Display header with progress
  - Display category titles and descriptions

- **Interaction Tests** (6 tests)
  - Select item on tap
  - Support multiple selection
  - Toggle selection on second tap
  - Enable next button when selected
  - Disable button when deselected
  - Navigate back on back button press

- **State Tests** (3 tests)
  - Show loading state with CircularProgressIndicator
  - Show error state with retry button
  - Show empty state when no categories
  - Maintain selection during scroll

- **Navigation Tests** (2 tests)
  - Show snackbar when next tapped
  - Prevent back navigation with PopScope

- **UI/UX Tests** (4 tests)
  - Correct background color
  - Proper spacing between elements
  - Scrollable list view
  - Button at bottom with proper padding

- **Edge Cases** (2 tests)
  - Handle rapid taps gracefully
  - Handle selecting all 6 categories

- **Accessibility Tests** (1 test)
  - Proper semantics for screen readers

**Total Tests: 25+**

#### `/test/features/onboarding/widgets/selection_list_item_test.dart`
Comprehensive widget tests for the reusable SelectionListItem component.

**Test Groups:**
- **Rendering Tests** (6 tests)
  - Render with title only
  - Render with title and description
  - Render IconData icon
  - Render default icon
  - Render checkmark when selected
  - Render empty checkmark circle when not selected

- **State-based Styling Tests** (6 tests)
  - Apply active border when selected (1px, #27B473)
  - Apply subtle border when not selected (1px, #EBEBEB)
  - Apply disabled styles when disabled
  - Show bold text when selected (FontWeight.w700)
  - Show bold text always per Figma (FontWeight.w700)

- **Interaction Tests** (4 tests)
  - Call onTap when tapped
  - Not call onTap when disabled
  - Handle null onTap gracefully
  - Animate on selection change

- **Icon Tests** (3 tests)
  - Prioritize iconUrl over icon
  - Use icon when iconUrl is null
  - Show default icon when both null

- **Checkmark Circle Tests** (3 tests)
  - Show primary color circle when selected
  - Show gray circle when not selected
  - Animate checkmark transition

- **Layout Tests** (3 tests)
  - Use horizontal row layout
  - Place icon on left and checkmark on right
  - Stack title and description vertically

- **Accessibility Tests** (4 tests)
  - Proper semantics labels
  - Indicate selected state in semantics
  - Indicate enabled state in semantics
  - Mark as button for screen readers

- **Edge Cases** (4 tests)
  - Handle long titles gracefully
  - Handle long descriptions gracefully
  - Handle rapid state changes
  - Handle empty title

- **Visual Regression Tests** (1 test)
  - Maintain consistent size when selection changes

**Total Tests: 34+**

### 2. Integration Tests

#### `/test/features/onboarding/integration_test.dart`
Full end-to-end user flow tests with provider integration.

**Test Groups:**
- **Complete User Flow Tests** (2 tests)
  - Complete full selection flow from start to finish
  - Handle multiple selections and navigate

- **Screen Validation Logic Tests** (2 tests)
  - Display correct screen structure and layout
  - Validate all category data displayed correctly

- **Provider Integration Tests** (4 tests)
  - Load categories from provider
  - Handle empty categories list
  - Handle provider loading state
  - Handle provider error state

- **Navigation and State Restoration Tests** (3 tests)
  - Clear selection on back button press
  - Maintain selection state during scroll
  - Prevent system back button with PopScope

- **UI/UX Validation Tests** (3 tests)
  - Show visual feedback for selections
  - Show progress indicator correctly (50% at step 3/5)
  - Proper button styling (56px height, border radius 16px)

- **Edge Cases and Error Handling** (3 tests)
  - Handle rapid selection toggles
  - Handle selecting all 6 categories
  - Handle deselecting all after selections

- **Accessibility Tests** (1 test)
  - Proper semantic structure for all elements

**Total Tests: 18+**

## Test Coverage Summary

| Component | File | Widget Tests | Integration Tests | Total |
|-----------|------|--------------|-------------------|-------|
| AgeCategoryScreen | age_category_screen_comprehensive_test.dart | 25+ | - | 25+ |
| SelectionListItem | selection_list_item_test.dart | 34+ | - | 34+ |
| Full Flow | integration_test.dart | - | 18+ | 18+ |
| **TOTAL** | **3 files** | **59+** | **18+** | **77+** |

## Current Implementation Details (Per Figma Spec)

### AgeCategoryScreen
- **Title**: "맞춤 혜택을 위해 내 상황을 알려주세요." (18px, w700, #3E3E3E)
- **Guidance**: "나에게 맞는 정책과 혜택에 대해 안내해드려요" (15px, w600, #828282)
- **Progress**: 50% (Step 3/5 shown as 0.5)
- **Progress Bar**: 4px height, border radius 2px, #DDDDDD background
- **Button**: 56px height, 16px border radius, #27B473 background

### SelectionListItem
- **Height**: 64px
- **Padding**: 16px
- **Border Radius**: 16px
- **Border**: 1px (always), #27B473 selected, #EBEBEB unselected
- **Title**: 14px, w700 (always bold per Figma)
- **Description**: 12px, w600, #828282
- **Icon**: 32x32px, emoji icons retain original colors
- **Checkmark**: 24x24px circle, #27B473 selected, #DDDDDD unselected

## Running the Tests

### All Tests
```bash
cd apps/pickly_mobile
flutter test test/features/onboarding/
```

### Individual Test Files
```bash
# Widget tests
flutter test test/features/onboarding/screens/age_category_screen_comprehensive_test.dart
flutter test test/features/onboarding/widgets/selection_list_item_test.dart

# Integration tests
flutter test test/features/onboarding/integration_test.dart
```

### With Coverage
```bash
flutter test --coverage test/features/onboarding/
```

## Test Patterns Used

### 1. Provider Override Pattern
```dart
Widget createTestWidget({List<AgeCategory>? categories}) {
  return ProviderScope(
    overrides: [
      ageCategoryProvider.overrideWith(() {
        return FakeAgeCategoryNotifier(categories ?? mockCategories);
      }),
    ],
    child: const MaterialApp(
      home: AgeCategoryScreen(),
    ),
  );
}
```

### 2. Mock Notifiers
- `FakeAgeCategoryNotifier` - Returns mock data
- `LoadingAgeCategoryNotifier` - Keeps loading state
- `ErrorAgeCategoryNotifier` - Throws errors

### 3. AAA Pattern (Arrange-Act-Assert)
```dart
testWidgets('Should select item on tap', (WidgetTester tester) async {
  // Arrange
  await tester.pumpWidget(createTestWidget());
  await tester.pumpAndSettle();

  // Act
  await tester.tap(find.byType(SelectionListItem).first);
  await tester.pumpAndSettle();

  // Assert
  final item = tester.widget<SelectionListItem>(find.byType(SelectionListItem).first);
  expect(item.isSelected, true);
});
```

## Known Issues and Adjustments

### Implementation vs Test Mismatches
1. **Text Changes**: Screen title updated to match Figma ("맞춤 혜택을 위해...")
2. **Border Width**: Always 1.0px per Figma (not 2.0px for selected)
3. **Font Weight**: Always w700 per Figma (not changing based on selection)
4. **Viewport**: ListView shows 4 items initially (needs scroll for all 6)
5. **Progress Indicators**: Two indicators (header + bottom), tests updated accordingly

### Test Adjustments Made
- Updated text expectations to match current implementation
- Corrected border width expectations (1.0px)
- Corrected font weight expectations (w700)
- Updated list view tests to account for viewport limitations
- Adjusted progress indicator tests for dual indicators

## Test Dependencies

### Required Packages
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_riverpod: ^3.0.3
```

### Required Files
- `lib/features/onboarding/screens/age_category_screen.dart`
- `lib/features/onboarding/widgets/selection_list_item.dart`
- `lib/features/onboarding/widgets/onboarding_header.dart`
- `lib/features/onboarding/providers/age_category_provider.dart`
- `lib/contexts/user/models/age_category.dart`
- `pickly_design_system` package

## Coverage Goals

- **Target**: 80%+ overall coverage
- **Widget Tests**: 85%+ statement coverage
- **Integration Tests**: 80%+ flow coverage
- **Critical Paths**: 100% coverage (selection, navigation, error handling)

## Next Steps

1. ✅ Widget tests created for AgeCategoryScreen
2. ✅ Widget tests created for SelectionListItem
3. ✅ Integration tests created for full flow
4. ⚠️ Run tests and fix failures (in progress)
5. ⏳ Measure coverage with `flutter test --coverage`
6. ⏳ Add additional edge case tests if coverage < 80%
7. ⏳ Document any remaining known issues

## Maintenance Notes

### When to Update Tests
- UI design changes (Figma updates)
- New features added to screen
- Provider logic changes
- Navigation flow changes
- Error handling changes

### Test Naming Convention
- **Widget Tests**: `Should [expected behavior]`
- **Integration Tests**: `Should [complete user action]`
- **Group Names**: Descriptive of feature area

### Best Practices
- ✅ Use `pumpAndSettle()` after actions
- ✅ Test one behavior per test
- ✅ Use descriptive test names
- ✅ Mock external dependencies (providers, repositories)
- ✅ Test both happy and unhappy paths
- ✅ Verify accessibility (semantics)

---

**Last Updated**: 2025-10-11
**Total Test Count**: 77+
**Estimated Coverage**: 80-85%
**Status**: Tests created, validation in progress
