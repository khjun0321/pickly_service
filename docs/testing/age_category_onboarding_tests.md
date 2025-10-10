# Age Category Onboarding Tests - Quick Reference

## 📋 Test Files Created

### Widget Tests
1. **`test/features/onboarding/screens/age_category_screen_comprehensive_test.dart`**
   - 25+ comprehensive widget tests
   - Tests rendering, interaction, state, navigation, UI/UX, edge cases, accessibility

2. **`test/features/onboarding/widgets/selection_list_item_test.dart`**
   - 34+ component tests
   - Tests rendering, styling, interaction, icons, layout, accessibility, edge cases

### Integration Tests
3. **`test/features/onboarding/integration_test.dart`**
   - 18+ end-to-end flow tests
   - Tests complete user journeys, provider integration, state management

**Total: 77+ tests across 3 files**

## 🚀 Quick Start

### Run All Tests
```bash
cd apps/pickly_mobile
flutter test test/features/onboarding/
```

### Run Specific Test File
```bash
# Screen tests
flutter test test/features/onboarding/screens/age_category_screen_comprehensive_test.dart

# Widget tests
flutter test test/features/onboarding/widgets/selection_list_item_test.dart

# Integration tests
flutter test test/features/onboarding/integration_test.dart
```

### Run with Coverage
```bash
flutter test --coverage test/features/onboarding/
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## ✅ Test Coverage

| Component | Tests | Coverage Target |
|-----------|-------|-----------------|
| AgeCategoryScreen | 25+ | 85%+ |
| SelectionListItem | 34+ | 90%+ |
| Integration Flow | 18+ | 80%+ |
| **Total** | **77+** | **80%+** |

## 📊 What's Tested

### Happy Paths ✅
- Loading categories from provider/mock data
- Selecting single/multiple categories
- Toggling selections
- Enabling/disabling next button based on selection
- Navigating with back button
- Submitting selection

### Edge Cases ✅
- Empty categories list (empty state)
- Rapid taps and state changes
- Selecting all 6 categories
- Deselecting all after selections
- Long text handling
- Scrolling while maintaining state

### Error Handling ✅
- Provider loading state (CircularProgressIndicator)
- Provider error state (retry button)
- Network failures (graceful fallback to mock data)
- Null/empty data handling

### UI/UX ✅
- Visual feedback for selections
- Progress indicator (50% at step 3/5)
- Border styling (1px, colors per Figma)
- Font weights (w700 for title, w600 for description)
- Button styling (56px height, 16px border radius)
- Checkmark animations

### Accessibility ✅
- Semantics labels for screen readers
- Selected state indication
- Button traits
- Proper ARIA attributes

## 🎯 Test Patterns

### 1. Mock Data Setup
```dart
setUp(() {
  final now = DateTime.now();
  mockCategories = [
    AgeCategory(
      id: 'test-1',
      title: '청년',
      description: '만 19세-39세 대학생, 취업준비생, 직장인',
      // ... other fields
    ),
    // ... more categories
  ];
});
```

### 2. Provider Override
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

### 3. Test Structure (AAA Pattern)
```dart
testWidgets('Should select item on tap', (WidgetTester tester) async {
  // Arrange - Set up test environment
  await tester.pumpWidget(createTestWidget());
  await tester.pumpAndSettle();

  // Act - Perform the action
  await tester.tap(find.byType(SelectionListItem).first);
  await tester.pumpAndSettle();

  // Assert - Verify the outcome
  final item = tester.widget<SelectionListItem>(
    find.byType(SelectionListItem).first
  );
  expect(item.isSelected, true);
});
```

## 🛠 Mock Notifiers

### FakeAgeCategoryNotifier
Returns mock data for testing happy path scenarios.

```dart
class FakeAgeCategoryNotifier extends AgeCategoryNotifier {
  final List<AgeCategory> _categories;

  @override
  Future<List<AgeCategory>> build() async => _categories;
}
```

### LoadingAgeCategoryNotifier
Keeps loading state indefinitely for testing loading UI.

```dart
class LoadingAgeCategoryNotifier extends AgeCategoryNotifier {
  @override
  Future<List<AgeCategory>> build() async {
    await Future.delayed(const Duration(hours: 1));
    return [];
  }
}
```

### ErrorAgeCategoryNotifier
Throws errors for testing error handling.

```dart
class ErrorAgeCategoryNotifier extends AgeCategoryNotifier {
  @override
  Future<List<AgeCategory>> build() async {
    throw Exception('Test error');
  }
}
```

## 📝 Implementation Details (Per Figma)

### AgeCategoryScreen
- Title: "맞춤 혜택을 위해 내 상황을 알려주세요." (18px, w700)
- Guidance: "나에게 맞는 정책과 혜택에 대해 안내해드려요" (15px, w600)
- Progress: 50% (step 3/5)
- Progress Bar: 4px height, #DDDDDD bg, #27B473 value
- Button: 56px height, 16px radius, #27B473 bg

### SelectionListItem
- Height: 64px
- Padding: 16px
- Border Radius: 16px
- Border: 1px (all states)
  - Selected: #27B473
  - Unselected: #EBEBEB
- Title: 14px, w700 (always bold)
- Description: 12px, w600, #828282
- Icon: 32x32px
- Checkmark: 24x24px circle

## ⚠️ Known Issues

### Test Execution Issues
1. **Text Mismatch**: Some tests expect old text ("현재 연령 및 세대..."), but implementation has new text ("맞춤 혜택을...")
   - **Solution**: Update test expectations to match current implementation

2. **Border Width**: Tests expect 2.0px for selected, but Figma spec is 1.0px
   - **Solution**: Update border width expectations to 1.0px

3. **Font Weight**: Tests expect w600 for unselected, but Figma spec is w700 (always)
   - **Solution**: Update font weight expectations to w700

4. **Viewport Limitation**: ListView shows 4 items initially (not all 6)
   - **Solution**: Tests should account for scrolling to see all items

5. **Dual Progress Indicators**: Two LinearProgressIndicators (header + bottom)
   - **Solution**: Tests should specify which indicator to verify

### Recommendations
- Run tests individually to identify specific failures
- Update expectations to match current Figma implementation
- Add scroll actions where needed to verify all 6 items
- Use `.first` or `.last` when multiple widgets match

## 🔧 Troubleshooting

### "Expected 6 widgets, found 4"
**Cause**: ListView only renders visible items in viewport.
**Fix**: Scroll to make items visible or update expectation to `findsAtLeastNWidgets(4)`.

### "Text not found" errors
**Cause**: Text in implementation changed to match Figma.
**Fix**: Update test string expectations to match current text.

### "Border width expected 2.0, actual 1.0"
**Cause**: Figma spec is 1.0px for all states.
**Fix**: Update border width expectation to `1.0`.

### "Font weight expected w600, actual w700"
**Cause**: Figma spec is w700 for title (always bold).
**Fix**: Update font weight expectation to `FontWeight.w700`.

## 📚 Resources

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Riverpod Testing](https://riverpod.dev/docs/essentials/testing)
- [Test Summary](../../../apps/pickly_mobile/test/features/onboarding/TEST_SUMMARY.md)

## 🎉 Success Criteria

- [x] 77+ tests created
- [x] All test files compile without errors
- [ ] All tests pass (requires fixing expectations)
- [ ] 80%+ code coverage achieved
- [x] Documentation complete

---

**Created**: 2025-10-11
**Status**: Tests created, expectations need adjustment for passing
**Next Steps**: Update test expectations to match current Figma implementation
