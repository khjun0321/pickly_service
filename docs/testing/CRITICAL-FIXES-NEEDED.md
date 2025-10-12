# CRITICAL FIXES NEEDED - Component Cleanup

**Status:** ❌ BUILD BROKEN - 888 issues found
**Date:** 2025-10-12
**Priority:** URGENT

---

## 🔥 TOP 5 CRITICAL ISSUES (Must Fix Immediately)

### 1. StateNotifier Extension Error ⚠️ HIGHEST PRIORITY

**File:** `/lib/features/onboarding/providers/age_category_controller.dart:80`

**Error:**
```
error • Classes can only extend other classes
```

**Issue:** StateNotifier not recognized, causing 100+ cascading "undefined state" errors

**Fix:**
```bash
cd /Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_mobile
flutter pub get
```

**Verify pubspec.yaml contains:**
```yaml
dependencies:
  flutter_riverpod: ^2.4.0  # or latest
```

---

### 2. Example File Import Paths

**File:** `/examples/onboarding/age_category_screen_example.dart:4-5`

**Errors:**
```
error • Target of URI doesn't exist: '../providers/age_category_provider.dart'
error • Target of URI doesn't exist: '../providers/age_category_controller.dart'
```

**Fix:**
```dart
// REPLACE lines 4-5 with:
import 'package:pickly_mobile/features/onboarding/providers/age_category_provider.dart';
import 'package:pickly_mobile/features/onboarding/providers/age_category_controller.dart';
```

---

### 3. Test File Import Path

**File:** `/test/screens/onboarding/splah_screen_test.dart:3`

**Error:**
```
error • Target of URI doesn't exist: 'package:pickly_mobile/screens/onboarding/splash_screen.dart'
```

**Fix:**
```dart
// REPLACE line 3 with:
import 'package:pickly_mobile/features/onboarding/screens/splash_screen.dart';
```

**Bonus:** Rename file from `splah_screen_test.dart` to `splash_screen_test.dart` (fix typo)

---

### 4. Regenerate All Mock Files

**Files:** All `*.mocks.dart` files

**Error Pattern:**
```
error • The named parameter 'returnValue' isn't defined
```

**Fix:**
```bash
cd /Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_mobile
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### 5. Remove Undefined Property Usage

**File:** `/examples/onboarding/age_category_screen_example.dart:319,322`

**Error:**
```
error • The getter 'ageRangeText' isn't defined for the type 'AgeCategory'
```

**Fix:**
```dart
// REPLACE lines 319 and 322:
// OLD:
category.ageRangeText

// NEW (check AgeCategory model for correct property):
// Option 1: Remove the age range display
// Option 2: Build it from existing properties
(category.minAge != null && category.maxAge != null)
  ? '(${category.minAge}-${category.maxAge}세)'
  : ''
```

---

## Quick Fix Script

```bash
#!/bin/bash
# Run this to fix most issues automatically

cd /Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_mobile

# 1. Update dependencies
echo "Installing dependencies..."
flutter pub get

# 2. Regenerate mocks
echo "Regenerating mock files..."
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run analyze again
echo "Running flutter analyze..."
flutter analyze

echo "Done! Check output for remaining issues."
```

---

## Validation After Fixes

Run these commands to verify:

```bash
# Should show significantly fewer errors (target: <50)
flutter analyze

# Should compile successfully
flutter build apk --debug

# Should run tests
flutter test
```

---

## Impact Summary

- **Total Issues:** 888
- **Build Breaking:** 200+ critical errors
- **Caused By:** 5 root issues (listed above)
- **Expected After Fix:** <50 issues (mostly warnings/info)

---

## Files Requiring Manual Edits

1. `/examples/onboarding/age_category_screen_example.dart` - Fix imports (lines 4-5) and property usage (lines 319, 322)
2. `/test/screens/onboarding/splah_screen_test.dart` - Fix import (line 3)

All other issues should resolve automatically after running `flutter pub get` and regenerating mocks.

---

**Next Agent:** Please fix these 5 critical issues in order, then re-run `flutter analyze`
