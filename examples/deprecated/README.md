# Deprecated Files

This directory contains code that has been deprecated and removed from the active codebase.

## age_category_controller.dart

**Deprecated:** October 12, 2025

### Why it was deprecated

The `age_category_controller.dart` file used the older **StateNotifier** pattern from Riverpod, which has been superseded by the newer and more recommended **AsyncNotifier** pattern.

### What replaced it

- **New file:** `apps/pickly_mobile/lib/features/onboarding/providers/age_category_provider.dart`
- **Pattern:** AsyncNotifier instead of StateNotifier
- **Benefits:**
  - Better async state management
  - More idiomatic Riverpod 2.0+ pattern
  - Cleaner error handling
  - Improved code generation support
  - Better integration with async operations

### Migration guide

If you were using the old controller:

```dart
// OLD (Deprecated)
final controller = ref.read(ageCategoryControllerProvider.notifier);
controller.toggleSelection(categoryId);
await controller.saveToSupabase();
```

Replace with the new provider:

```dart
// NEW (Current)
final controller = ref.read(ageCategorySelectionProvider.notifier);
controller.toggleSelection(categoryId);
await controller.saveSelection();
```

### Key differences

| Old (StateNotifier) | New (AsyncNotifier) |
|---------------------|---------------------|
| `AgeCategoryController extends StateNotifier` | `AgeCategorySelectionNotifier extends AsyncNotifier` |
| `ageCategoryControllerProvider` | `ageCategorySelectionProvider` |
| `saveToSupabase()` | `saveSelection()` |
| Manual state management | Built-in async state handling |
| Separate loading/error states | Unified AsyncValue state |

### References

- **Riverpod Documentation:** https://riverpod.dev/docs/concepts/why_immutability
- **Migration Guide:** https://riverpod.dev/docs/migration/from_state_notifier
- **AsyncNotifier Guide:** https://riverpod.dev/docs/providers/notifier_provider

### File location (deprecated)

Original location: `apps/pickly_mobile/lib/features/onboarding/providers/age_category_controller.dart`

### Related test files (also deprecated)

- `apps/pickly_mobile/test/features/onboarding/age_category_controller_test.dart`
- `apps/pickly_mobile/test/features/onboarding/age_category_controller_test.mocks.dart`

These test files should also be migrated to test the new `age_category_provider.dart` implementation.
