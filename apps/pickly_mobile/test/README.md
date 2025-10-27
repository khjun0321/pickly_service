# Age Category Onboarding Tests

## Quick Start

### 1. Install Dependencies
```bash
cd apps/pickly_mobile
flutter pub get
```

### 2. Generate Mock Files
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/models/age_category_test.dart
```

## Test Structure

```
test/
├── models/
│   └── age_category_test.dart              # Model serialization tests (15+ tests)
├── repositories/
│   └── age_category_repository_test.dart   # Repository logic tests (12+ tests)
├── features/
│   └── onboarding/
│       ├── age_category_controller_test.dart    # State management tests (20+ tests)
│       ├── age_category_screen_test.dart        # Widget/UI tests (15+ tests)
│       └── age_category_integration_test.dart   # E2E tests (10+ integration tests)
├── TEST_SUMMARY.md                         # Detailed test documentation
└── README.md                               # This file
```

## Test Coverage

| Component | File | Tests | Coverage Target |
|-----------|------|-------|-----------------|
| Model | `age_category_test.dart` | 15+ | 95%+ |
| Repository | `age_category_repository_test.dart` | 12+ | 90%+ |
| Controller | `age_category_controller_test.dart` | 20+ | 90%+ |
| Widgets | `age_category_screen_test.dart` | 15+ | 85%+ |
| Integration | `age_category_integration_test.dart` | 10+ | 80%+ |
| **Total** | **5 files** | **72+** | **90%+** |

## What's Tested

### ✅ Happy Path Scenarios
- Loading age categories from Supabase
- Selecting single/multiple categories
- Submitting selection to database
- Navigation to next onboarding step

### ✅ Edge Cases
- Empty categories list
- Null `max_age` values (e.g., "60대 이상")
- Network timeouts and failures
- Database errors
- Invalid/malformed data
- Large datasets (1000+ items)
- Special characters in IDs (한글, emojis)
- Rapid user interactions

### ✅ Error Handling
- Network failures with retry logic
- Database constraint violations
- Validation errors (no selection)
- Save failures with user feedback
- Loading state management

### ✅ UI/UX
- Loading indicators
- Selection highlighting
- Checkmarks for selected items
- Error SnackBars
- Button enabled/disabled states
- Accessibility (semantic labels)
- Smooth scrolling

## Running Tests

### All Tests
```bash
flutter test
```

Expected output:
```
00:05 +72: All tests passed!
```

### With Coverage Report
```bash
# Generate coverage
flutter test --coverage

# View coverage (macOS/Linux)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# View coverage (Windows)
genhtml coverage/lcov.info -o coverage/html
start coverage/html/index.html
```

### Individual Test Files
```bash
# Model tests only
flutter test test/models/age_category_test.dart

# Repository tests only
flutter test test/repositories/age_category_repository_test.dart

# Controller tests only
flutter test test/features/onboarding/age_category_controller_test.dart

# Widget tests only
flutter test test/features/onboarding/age_category_screen_test.dart

# Integration tests only
flutter test test/features/onboarding/age_category_integration_test.dart
```

### Watch Mode (Re-run on Changes)
```bash
flutter test --watch
```

### Specific Test
```bash
flutter test --name "should fetch and parse age categories successfully"
```

## Mock Generation

Tests use Mockito for mocking dependencies. Mocks are auto-generated from annotations.

### Regenerate Mocks
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Generated Mock Files
- `test/repositories/age_category_repository_test.mocks.dart`
- `test/features/onboarding/age_category_controller_test.mocks.dart`
- `test/features/onboarding/age_category_screen_test.mocks.dart`
- `test/features/onboarding/age_category_integration_test.mocks.dart`

## Test Patterns

### Arrange-Act-Assert (AAA)
```dart
test('should select category successfully', () {
  // Arrange - Set up test data and mocks
  final category = AgeCategory(id: '1', categoryName: '20대');

  // Act - Execute the function being tested
  controller.selectCategory(category);

  // Assert - Verify the expected outcome
  expect(controller.selectedCategory, category);
});
```

### Given-When-Then (BDD Style)
```dart
test('should display error when no categories are loaded', () {
  // Given an empty category list
  when(mockRepository.fetchActiveCategories())
      .thenAnswer((_) async => []);

  // When loading categories
  await controller.loadCategories();

  // Then an error should be displayed
  expect(controller.errorMessage, isNotNull);
});
```

## Troubleshooting

### Mock Generation Fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Tests Fail Due to Missing Dependencies
```bash
# Ensure all dependencies are installed
flutter pub get
flutter pub upgrade
```

### Coverage Not Generated
```bash
# Ensure lcov is installed (macOS)
brew install lcov

# Or use Flutter's built-in coverage viewer
flutter test --coverage
# View coverage/lcov.info in your IDE
```

### Integration Tests Won't Run
```bash
# Ensure integration_test is in pubspec.yaml
flutter test integration_test/
```

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Generate mocks
        run: flutter pub run build_runner build --delete-conflicting-outputs

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

## Best Practices

### ✅ DO
- Write descriptive test names
- Test one behavior per test
- Use mocks for external dependencies
- Cover edge cases and error scenarios
- Keep tests fast and independent
- Follow AAA pattern
- Update tests when code changes

### ❌ DON'T
- Test implementation details
- Create interdependent tests
- Skip error scenarios
- Ignore flaky tests
- Mock everything unnecessarily
- Write tests without assertions

## Coverage Goals

Maintain these coverage thresholds:

- **Statements**: >80%
- **Branches**: >75%
- **Functions**: >80%
- **Lines**: >80%
- **Overall**: >90%

## Resources

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Test Summary](./TEST_SUMMARY.md)

## Support

For issues or questions:
1. Check [TEST_SUMMARY.md](./TEST_SUMMARY.md) for detailed documentation
2. Review test patterns in existing test files
3. Consult Flutter testing documentation

---

**Last Updated**: 2025-10-07
**Total Tests**: 72+
**Coverage**: 90%+ target
