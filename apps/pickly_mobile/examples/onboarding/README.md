# Onboarding Examples

## ⚠️ DEPRECATION NOTICE

The files in this directory are **DEPRECATED** and contain broken imports.

### Issues:
- `age_category_screen_example.dart` uses `age_category_controller.dart` which has StateNotifier errors
- Import paths are broken after the project restructuring
- The controller is NOT used in production code (see `lib/features/onboarding/screens/age_category_screen.dart`)

### Current Production Implementation:
The actual onboarding screens use:
- **Local state management** (StatefulWidget with setState)
- **Design System components** from `pickly_design_system` package
- **Clean architecture** with contexts/user/models

### Files:
1. **age_category_screen_example.dart** - ⚠️ BROKEN - Uses deprecated controller

### For Reference:
See the actual production implementation in:
- `/lib/features/onboarding/screens/age_category_screen.dart` - Working example
- `/lib/features/onboarding/widgets/` - Reusable onboarding widgets
- `/lib/contexts/user/models/age_category.dart` - Current model

## TODO:
- [ ] Update example to use current architecture
- [ ] Remove dependency on broken controller
- [ ] Add working examples for all onboarding screens
