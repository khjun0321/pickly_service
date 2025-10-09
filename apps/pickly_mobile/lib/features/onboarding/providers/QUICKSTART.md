# Quick Start Guide - Age Category Providers

## 🚀 5-Minute Setup

### Step 1: Initialize Supabase in main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(
    const ProviderScope(  // IMPORTANT: Wrap with ProviderScope
      child: PicklyApp(),
    ),
  );
}
```

### Step 2: Use in Your Screen

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/onboarding/providers/age_category_provider.dart';
import 'features/onboarding/providers/age_category_controller.dart';

class AgeCategoryScreen extends ConsumerWidget {
  const AgeCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(ageCategoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('연령/세대 선택')),
      body: categoriesAsync.when(
        data: (categories) => ListView(
          children: categories.map((cat) =>
            CategoryTile(category: cat)
          ).toList(),
        ),
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
      ),
    );
  }
}
```

### Step 3: Handle Selection

```dart
class CategoryTile extends ConsumerWidget {
  final AgeCategory category;
  const CategoryTile({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(
      isAgeCategorySelectedProvider(category.id),
    );

    return ListTile(
      title: Text(category.title),
      subtitle: Text(category.description),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () {
        ref.read(ageCategoryControllerProvider.notifier)
            .toggleSelection(category.id);
      },
    );
  }
}
```

### Step 4: Save Selections

```dart
ElevatedButton(
  onPressed: () async {
    final success = await ref
        .read(ageCategoryControllerProvider.notifier)
        .saveToSupabase();

    if (success && context.mounted) {
      Navigator.push(context, /* next screen */);
    }
  },
  child: const Text('다음'),
)
```

## 📋 Common Patterns

### Get Selection Count
```dart
final count = ref.watch(selectedAgeCategoryCountProvider);
Text('$count개 선택됨');
```

### Check if Valid (Min 1 Selection)
```dart
final isValid = ref.watch(isAgeCategorySelectionValidProvider);
ElevatedButton(
  onPressed: isValid ? _handleNext : null,
  child: const Text('다음'),
)
```

### Show Error Message
```dart
final state = ref.watch(ageCategoryControllerProvider);
if (state.errorMessage != null) {
  return Text(state.errorMessage!, style: TextStyle(color: Colors.red));
}
```

### Check Loading State
```dart
final state = ref.watch(ageCategoryControllerProvider);
if (state.isLoading) {
  return const CircularProgressIndicator();
}
```

### Clear Selections
```dart
TextButton(
  onPressed: () {
    ref.read(ageCategoryControllerProvider.notifier).clearSelections();
  },
  child: const Text('초기화'),
)
```

### Refresh Categories
```dart
IconButton(
  icon: const Icon(Icons.refresh),
  onPressed: () {
    ref.read(ageCategoryProvider.notifier).refresh();
  },
)
```

## 🔧 Environment Setup

### Create .env file (optional)
```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### Load environment variables
```dart
// Using flutter_dotenv
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();

await SupabaseService.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

### Or use compile-time constants
```bash
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

## 🎨 UI States Reference

### Loading State
```dart
categoriesAsync.when(
  loading: () => const Center(
    child: CircularProgressIndicator(),
  ),
  ...
)
```

### Error State
```dart
categoriesAsync.when(
  error: (error, stack) => Column(
    children: [
      Text('Error: $error'),
      ElevatedButton(
        onPressed: () => ref.read(ageCategoryProvider.notifier).retry(),
        child: const Text('다시 시도'),
      ),
    ],
  ),
  ...
)
```

### Empty State
```dart
categoriesAsync.when(
  data: (categories) {
    if (categories.isEmpty) {
      return const Text('카테고리가 없습니다');
    }
    return CategoryList(categories);
  },
  ...
)
```

### Saving State
```dart
final state = ref.watch(ageCategoryControllerProvider);

ElevatedButton(
  onPressed: state.isSaving ? null : _handleSave,
  child: state.isSaving
      ? const CircularProgressIndicator()
      : const Text('저장'),
)
```

## 🐛 Troubleshooting

### Issue: "ProviderScope not found"
**Solution**: Wrap your app with ProviderScope in main.dart
```dart
runApp(const ProviderScope(child: MyApp()));
```

### Issue: Categories not loading
**Solution**: Check Supabase initialization and RLS policies
```dart
// Verify initialization
print(SupabaseService.instance.isAuthenticated);

// Check categories table RLS
// SQL: CREATE POLICY "Anyone views active categories"
//      ON age_categories FOR SELECT
//      USING (is_active = true);
```

### Issue: Save failing with auth error
**Solution**: User must be authenticated
```dart
final userId = SupabaseService.instance.currentUserId;
if (userId == null) {
  // Show login screen
}
```

### Issue: Realtime updates not working
**Solution**: Enable realtime in Supabase dashboard
1. Go to Database > Replication
2. Enable replication for `age_categories` table

## 📱 Complete Example App

See `/lib/features/onboarding/screens/age_category_screen_example.dart` for a complete working example with:
- Loading states
- Error handling
- Selection management
- Validation
- Save functionality
- Navigation flow

## 🔗 Related Files

- **Provider**: `age_category_provider.dart` - Data fetching
- **Controller**: `age_category_controller.dart` - Selection logic
- **Model**: `../../core/models/age_category.dart` - Data model
- **Service**: `../../core/services/supabase_service.dart` - Backend
- **Example**: `../screens/age_category_screen_example.dart` - Full screen

## 📚 Full Documentation

See `README.md` in this directory for comprehensive documentation including:
- Architecture details
- Advanced patterns
- Testing strategies
- Performance optimization
- Security considerations

## 🚦 Testing

### Quick Test
```bash
cd apps/pickly_mobile
flutter test
```

### Run Example
```bash
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

## 💡 Tips

1. Always wrap app with `ProviderScope`
2. Use `ref.watch()` for reactive UI updates
3. Use `ref.read()` for one-time actions
4. Handle all three states: loading, data, error
5. Clear error messages after user action
6. Validate before saving
7. Show user-friendly error messages in Korean

## 🎯 Next Steps

1. ✅ Created providers and controller
2. ⏭️ Test with real Supabase instance
3. ⏭️ Integrate with onboarding flow
4. ⏭️ Add analytics tracking
5. ⏭️ Implement offline support
6. ⏭️ Create tests

---

**Happy Coding! 🚀**
