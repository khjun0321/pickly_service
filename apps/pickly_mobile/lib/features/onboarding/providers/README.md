# Age Category Providers

This directory contains Riverpod providers and controllers for managing age category selection in the onboarding flow (Screen 003).

## Files

### 1. `age_category_provider.dart`
Provider for fetching and managing age categories from Supabase with realtime updates.

**Key Features:**
- AsyncNotifier pattern for async data management
- Realtime subscription to `age_categories` table
- Automatic refresh on database changes
- Error handling with custom exceptions
- Loading and error state management

**Providers:**
- `ageCategoryProvider` - Main AsyncNotifier provider
- `ageCategoriesListProvider` - Convenience provider for list access
- `ageCategoriesLoadingProvider` - Loading state check
- `ageCategoriesErrorProvider` - Error state access
- `ageCategoryByIdProvider` - Get category by ID

### 2. `age_category_controller.dart`
StateNotifier for managing age category selection state and persistence.

**Key Features:**
- Selection state management with Set<String>
- Validation (minimum 1 selection required)
- Save/load from Supabase user_profiles
- Toggle, select multiple, clear operations
- Loading, saving, and error states

**Providers:**
- `ageCategoryControllerProvider` - Main StateNotifier provider
- `isAgeCategorySelectionValidProvider` - Validation check
- `selectedAgeCategoryIdsProvider` - Get selected IDs as list
- `selectedAgeCategoryCountProvider` - Count of selections
- `isAgeCategorySelectedProvider` - Check if specific ID is selected

## Usage Examples

### Initialize Supabase (in main.dart)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(
    const ProviderScope(
      child: PicklyApp(),
    ),
  );
}
```

### Display Age Categories
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/age_category_provider.dart';

class AgeCategoryScreen extends ConsumerWidget {
  const AgeCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(ageCategoryProvider);

    return categoriesAsync.when(
      data: (categories) {
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryCard(category: category);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            ElevatedButton(
              onPressed: () => ref.read(ageCategoryProvider.notifier).retry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Handle Category Selection
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/age_category_controller.dart';

class CategoryCard extends ConsumerWidget {
  final AgeCategory category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(
      isAgeCategorySelectedProvider(category.id),
    );

    return GestureDetector(
      onTap: () {
        ref.read(ageCategoryControllerProvider.notifier)
            .toggleSelection(category.id);
      },
      child: Card(
        color: isSelected ? Colors.green : Colors.white,
        child: ListTile(
          title: Text(category.title),
          subtitle: Text(category.description),
        ),
      ),
    );
  }
}
```

### Save Selections
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/age_category_controller.dart';

class SaveButton extends ConsumerWidget {
  const SaveButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(ageCategoryControllerProvider);
    final controller = ref.read(ageCategoryControllerProvider.notifier);

    return Column(
      children: [
        // Display validation error
        if (selectionState.errorMessage != null)
          Text(
            selectionState.errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),

        // Save button
        ElevatedButton(
          onPressed: selectionState.isSaving
              ? null
              : () async {
                  final success = await controller.saveToSupabase();

                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('저장되었습니다')),
                    );
                    // Navigate to next screen
                    // Navigator.push(...);
                  }
                },
          child: selectionState.isSaving
              ? const CircularProgressIndicator()
              : Text('저장 (${selectionState.selectedCount}개 선택)'),
        ),
      ],
    );
  }
}
```

### Check Validation
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/age_category_controller.dart';

class NextButton extends ConsumerWidget {
  const NextButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isValid = ref.watch(isAgeCategorySelectionValidProvider);

    return ElevatedButton(
      onPressed: isValid ? () => _navigateToNext(context) : null,
      child: const Text('다음'),
    );
  }

  void _navigateToNext(BuildContext context) {
    // Navigate to next onboarding screen
  }
}
```

### Load Saved Selections
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/age_category_controller.dart';

class AgeCategoryScreen extends ConsumerStatefulWidget {
  const AgeCategoryScreen({super.key});

  @override
  ConsumerState<AgeCategoryScreen> createState() => _AgeCategoryScreenState();
}

class _AgeCategoryScreenState extends ConsumerState<AgeCategoryScreen> {
  @override
  void initState() {
    super.initState();
    // Selections are automatically loaded in controller constructor
    // But you can manually refresh if needed
    Future.microtask(() {
      ref.read(ageCategoryControllerProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectionState = ref.watch(ageCategoryControllerProvider);

    if (selectionState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return YourScreenContent();
  }
}
```

### Select Multiple Categories
```dart
final controller = ref.read(ageCategoryControllerProvider.notifier);

// Select multiple at once
controller.selectMultiple(['id1', 'id2', 'id3']);

// Clear all selections
controller.clearSelections();

// Manual validation
if (controller.validate()) {
  // Proceed
}
```

## State Management Architecture

### Provider Hierarchy
```
ProviderScope
├── supabaseServiceProvider (Provider)
├── ageCategoryProvider (AsyncNotifierProvider)
│   ├── ageCategoriesListProvider (Provider)
│   ├── ageCategoriesLoadingProvider (Provider)
│   ├── ageCategoriesErrorProvider (Provider)
│   └── ageCategoryByIdProvider (Provider.family)
└── ageCategoryControllerProvider (StateNotifierProvider)
    ├── isAgeCategorySelectionValidProvider (Provider)
    ├── selectedAgeCategoryIdsProvider (Provider)
    ├── selectedAgeCategoryCountProvider (Provider)
    └── isAgeCategorySelectedProvider (Provider.family)
```

## Best Practices

1. **Always wrap app with ProviderScope**
   ```dart
   runApp(const ProviderScope(child: MyApp()));
   ```

2. **Use ref.watch() for reactive UI**
   ```dart
   final data = ref.watch(ageCategoryProvider);
   ```

3. **Use ref.read() for one-time actions**
   ```dart
   ref.read(ageCategoryControllerProvider.notifier).save();
   ```

4. **Handle loading and error states**
   ```dart
   asyncValue.when(
     data: (data) => YourWidget(data),
     loading: () => LoadingWidget(),
     error: (error, stack) => ErrorWidget(error),
   );
   ```

5. **Clean up subscriptions automatically**
   - Realtime subscriptions are automatically cleaned up when provider is disposed

## Testing

### Mock Providers
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Category selection works', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ageCategoryProvider.overrideWith((ref) {
            return AgeCategoryNotifier()..state = AsyncValue.data(mockCategories);
          }),
        ],
        child: const MyApp(),
      ),
    );

    // Test your widget
  });
}
```

## Database Schema Reference

### age_categories table
```sql
CREATE TABLE age_categories (
  id UUID PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  icon_component TEXT NOT NULL,
  icon_url TEXT,
  min_age INTEGER,
  max_age INTEGER,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### user_profiles table (relevant fields)
```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  selected_categories UUID[],  -- Array of age_category IDs
  -- ... other fields
);
```

## Error Handling

### Custom Exceptions
- `AgeCategoryException` - Wraps errors with context and cause

### Error Types
1. **Network errors** - Supabase connection issues
2. **Authentication errors** - User not logged in
3. **Validation errors** - Minimum selection not met
4. **Database errors** - Query failures

### Error Display
```dart
if (selectionState.errorMessage != null) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: Text(selectionState.errorMessage!),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            ref.read(ageCategoryControllerProvider.notifier).clearError();
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
```

## Performance Considerations

1. **Realtime subscriptions** - Automatically cleaned up on dispose
2. **Efficient re-renders** - Only affected widgets rebuild
3. **Immutable state** - State objects use copyWith for updates
4. **Lazy loading** - Providers only build when needed

## Future Enhancements

- [ ] Offline caching with Hive/SharedPreferences
- [ ] Optimistic updates for better UX
- [ ] Pagination for large category lists
- [ ] Search and filter capabilities
- [ ] Analytics tracking for selections
