# Age Category API Documentation

## Overview

The Age Category API provides data access layer for managing age/generation categories in the Pickly onboarding flow. It includes the data model, repository pattern for Supabase integration, and state management providers.

---

## Database Schema

### Table: `age_categories`

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| `id` | UUID | NO | Primary key |
| `title` | TEXT | NO | Display title (e.g., "청년") |
| `description` | TEXT | NO | Detailed description |
| `icon_component` | TEXT | NO | Icon identifier |
| `icon_url` | TEXT | YES | SVG icon path |
| `min_age` | INTEGER | YES | Minimum age for eligibility |
| `max_age` | INTEGER | YES | Maximum age for eligibility |
| `sort_order` | INTEGER | NO | Display order (default: 0) |
| `is_active` | BOOLEAN | NO | Active status (default: true) |
| `created_at` | TIMESTAMP | NO | Creation timestamp |
| `updated_at` | TIMESTAMP | NO | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Index on `is_active` for filtering
- Index on `sort_order` for ordering

**Sample Data:**

```sql
INSERT INTO age_categories (id, title, description, icon_component, sort_order) VALUES
('uuid-1', '청년', '(만 19세-39세) 대학생, 취업준비생, 직장인', 'young_man', 1),
('uuid-2', '신혼부부·예비부부', '결혼 준비 중이거나 신혼 가정', 'bride', 2),
('uuid-3', '영유아 부모', '영유아(0-7세) 자녀를 둔 부모', 'baby', 3),
('uuid-4', '학부모', '초중고 자녀를 둔 부모', 'kinder', 4),
('uuid-5', '중장년', '(만 40세-64세) 경력자, 은퇴 준비', 'old_man', 5),
('uuid-6', '노년·장애인', '(만 65세 이상) 노후 생활, 장애인 지원', 'wheel_chair', 6);
```

---

## Data Model

### Class: `AgeCategory`

**Location:** `apps/pickly_mobile/lib/models/age_category.dart`

#### Properties

```dart
class AgeCategory {
  final String id;              // Unique identifier (UUID)
  final String title;           // Display title
  final String description;     // Detailed description
  final String iconComponent;   // Icon component identifier
  final String? iconUrl;        // Optional icon URL
  final int? minAge;           // Minimum age (nullable)
  final int? maxAge;           // Maximum age (nullable)
  final int sortOrder;         // Display order
  final bool isActive;         // Active status
  final DateTime createdAt;    // Creation timestamp
  final DateTime updatedAt;    // Update timestamp
}
```

#### Methods

##### Constructor

```dart
const AgeCategory({
  required this.id,
  required this.title,
  required this.description,
  required this.iconComponent,
  this.iconUrl,
  this.minAge,
  this.maxAge,
  required this.sortOrder,
  required this.isActive,
  required this.createdAt,
  required this.updatedAt,
});
```

##### Factory Methods

**`fromJson(Map<String, dynamic> json)`**

Creates an `AgeCategory` from Supabase JSON response.

```dart
final category = AgeCategory.fromJson({
  'id': 'uuid-1',
  'title': '청년',
  'description': '(만 19세-39세) 대학생, 취업준비생, 직장인',
  'icon_component': 'young_man',
  'icon_url': 'packages/pickly_design_system/assets/icons/age_categories/young_man.svg',
  'min_age': 19,
  'max_age': 39,
  'sort_order': 1,
  'is_active': true,
  'created_at': '2025-01-01T00:00:00Z',
  'updated_at': '2025-01-01T00:00:00Z',
});
```

**`toJson()`**

Converts the model to JSON for Supabase operations.

```dart
final json = category.toJson();
// Returns: Map<String, dynamic>
```

##### Instance Methods

**`copyWith({...})`**

Creates a copy with optional field overrides.

```dart
final updated = category.copyWith(
  title: '청년층',
  sortOrder: 2,
);
```

**`isAgeInRange(int age)`**

Checks if a given age falls within this category's age range.

```dart
bool isEligible = category.isAgeInRange(25); // true for 청년 (19-39)
bool isNotEligible = category.isAgeInRange(15); // false
```

**Logic:**
- Returns `true` if no age constraints are defined (`minAge` and `maxAge` are both null)
- Returns `false` if age is below `minAge` or above `maxAge`
- Range is inclusive

---

## Repository Layer

### Class: `AgeCategoryRepository`

**Location:** `apps/pickly_mobile/lib/repositories/age_category_repository.dart`

#### Constructor

```dart
AgeCategoryRepository({SupabaseClient? client})
```

If no client is provided, uses `Supabase.instance.client`.

#### Methods

##### `fetchActiveCategories()`

Fetches all active age categories ordered by `sort_order`.

**Signature:**
```dart
Future<List<AgeCategory>> fetchActiveCategories()
```

**Returns:** List of `AgeCategory` objects

**Throws:** `AgeCategoryException` on error

**Example:**
```dart
final repository = AgeCategoryRepository();
try {
  final categories = await repository.fetchActiveCategories();
  print('Loaded ${categories.length} categories');
} on AgeCategoryException catch (e) {
  print('Error: ${e.message}');
}
```

**SQL Query:**
```sql
SELECT * FROM age_categories
WHERE is_active = true
ORDER BY sort_order ASC
```

---

##### `fetchCategoryById(String id)`

Fetches a single age category by ID.

**Signature:**
```dart
Future<AgeCategory?> fetchCategoryById(String id)
```

**Returns:** `AgeCategory` if found, `null` otherwise

**Throws:** `AgeCategoryException` on error

**Example:**
```dart
final category = await repository.fetchCategoryById('uuid-1');
if (category != null) {
  print('Found: ${category.title}');
} else {
  print('Category not found');
}
```

---

##### `subscribeToCategories({...})`

Subscribes to realtime changes in age categories.

**Signature:**
```dart
RealtimeChannel subscribeToCategories({
  void Function(AgeCategory category)? onInsert,
  void Function(AgeCategory category)? onUpdate,
  void Function(String id)? onDelete,
})
```

**Returns:** `RealtimeChannel` for managing the subscription

**Example:**
```dart
final channel = repository.subscribeToCategories(
  onInsert: (category) => print('New: ${category.title}'),
  onUpdate: (category) => print('Updated: ${category.title}'),
  onDelete: (id) => print('Deleted: $id'),
);

// Later, unsubscribe
await channel.unsubscribe();
```

**Events:**
- `INSERT`: New category added to database
- `UPDATE`: Existing category modified
- `DELETE`: Category removed

---

##### `validateCategoryIds(List<String> categoryIds)`

Validates that a list of category IDs exist in the database.

**Signature:**
```dart
Future<bool> validateCategoryIds(List<String> categoryIds)
```

**Returns:** `true` if all IDs are valid and active

**Throws:** `AgeCategoryException` on error

**Example:**
```dart
final isValid = await repository.validateCategoryIds([
  'uuid-1',
  'uuid-2',
  'uuid-3',
]);

if (isValid) {
  print('All categories are valid');
} else {
  print('Some categories are invalid or inactive');
}
```

---

## State Management (Riverpod Providers)

### Provider: `ageCategoryProvider`

**Location:** `apps/pickly_mobile/lib/features/onboarding/providers/age_category_provider.dart`

**Type:** `AsyncNotifierProvider<AgeCategoryNotifier, List<AgeCategory>>`

**Description:** Main provider for fetching and managing age categories with realtime updates.

**Usage:**
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(ageCategoryProvider);

    return categoriesAsync.when(
      data: (categories) => ListView(
        children: categories.map((cat) => Text(cat.title)).toList(),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

**Methods:**
- `refresh()` - Manually refresh categories
- `retry()` - Retry after error

---

### Provider: `ageCategoriesListProvider`

**Type:** `Provider<List<AgeCategory>>`

**Description:** Convenience provider that returns an empty list during loading states.

**Usage:**
```dart
final categories = ref.watch(ageCategoriesListProvider);
// Always returns List<AgeCategory>, never null
```

---

### Provider: `ageCategoriesLoadingProvider`

**Type:** `Provider<bool>`

**Description:** Returns `true` when categories are loading.

**Usage:**
```dart
final isLoading = ref.watch(ageCategoriesLoadingProvider);
if (isLoading) {
  return CircularProgressIndicator();
}
```

---

### Provider: `ageCategoriesErrorProvider`

**Type:** `Provider<Object?>`

**Description:** Returns the error object if loading failed, `null` otherwise.

**Usage:**
```dart
final error = ref.watch(ageCategoriesErrorProvider);
if (error != null) {
  return Text('Error: $error');
}
```

---

### Provider: `ageCategoryByIdProvider`

**Type:** `Provider.family<AgeCategory?, String>`

**Description:** Get a specific category by ID.

**Usage:**
```dart
final category = ref.watch(ageCategoryByIdProvider('uuid-1'));
if (category != null) {
  return Text(category.title);
}
```

---

## Selection Controller

### Class: `AgeCategoryController`

**Location:** `apps/pickly_mobile/lib/features/onboarding/providers/age_category_controller.dart`

Manages user selection of age categories during onboarding.

#### State: `AgeCategorySelectionState`

```dart
class AgeCategorySelectionState {
  final Set<String> selectedIds;      // Selected category IDs
  final bool isLoading;                // Loading saved selections
  final String? errorMessage;          // Error message
  final bool isSaving;                 // Saving to Supabase
  final bool isSaved;                  // Successfully saved

  bool get isValid;                    // At least 1 selection
  int get selectedCount;               // Number of selections
  bool isSelected(String id);          // Check if ID is selected
}
```

#### Methods

##### `toggleSelection(String categoryId)`

Toggle selection of a category.

```dart
ref.read(ageCategoryControllerProvider.notifier)
   .toggleSelection('uuid-1');
```

---

##### `selectMultiple(List<String> categoryIds)`

Select multiple categories at once.

```dart
ref.read(ageCategoryControllerProvider.notifier)
   .selectMultiple(['uuid-1', 'uuid-2', 'uuid-3']);
```

---

##### `clearSelections()`

Clear all selections.

```dart
ref.read(ageCategoryControllerProvider.notifier)
   .clearSelections();
```

---

##### `validate()`

Validate selection (minimum 1 required).

```dart
final isValid = ref.read(ageCategoryControllerProvider.notifier)
                   .validate();
if (!isValid) {
  // Show error: "최소 1개 이상의 연령/세대를 선택해주세요"
}
```

---

##### `saveToSupabase()`

Save selections to Supabase user profile.

**Signature:**
```dart
Future<bool> saveToSupabase()
```

**Returns:** `true` if successful, `false` otherwise

**Example:**
```dart
final success = await ref.read(ageCategoryControllerProvider.notifier)
                         .saveToSupabase();

if (success) {
  // Navigate to next screen
  Navigator.push(context, MaterialPageRoute(builder: (_) => NextScreen()));
} else {
  // Error message is already in state.errorMessage
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('저장에 실패했습니다')),
  );
}
```

**Database Operation:**
```sql
INSERT INTO user_profiles (user_id, selected_categories, updated_at)
VALUES ($1, $2, $3)
ON CONFLICT (user_id) DO UPDATE
SET selected_categories = $2, updated_at = $3
```

---

### Helper Providers

#### `isAgeCategorySelectionValidProvider`

```dart
final isValid = ref.watch(isAgeCategorySelectionValidProvider);
// Returns: bool
```

#### `selectedAgeCategoryIdsProvider`

```dart
final selectedIds = ref.watch(selectedAgeCategoryIdsProvider);
// Returns: List<String>
```

#### `selectedAgeCategoryCountProvider`

```dart
final count = ref.watch(selectedAgeCategoryCountProvider);
// Returns: int
```

#### `isAgeCategorySelectedProvider`

```dart
final isSelected = ref.watch(isAgeCategorySelectedProvider('uuid-1'));
// Returns: bool
```

---

## Error Handling

### Exception: `AgeCategoryException`

Custom exception for age category operations.

```dart
class AgeCategoryException implements Exception {
  final String message;
  final String? code;          // PostgreSQL error code
  final dynamic details;       // Additional error details
}
```

**Example:**
```dart
try {
  final categories = await repository.fetchActiveCategories();
} on AgeCategoryException catch (e) {
  print('Error: ${e.message}');
  if (e.code != null) {
    print('Error code: ${e.code}');
  }
  if (e.details != null) {
    print('Details: ${e.details}');
  }
}
```

---

## Realtime Updates

The age category provider automatically subscribes to Supabase realtime changes:

```dart
// Automatic subscription in AgeCategoryNotifier
void _setupRealtimeSubscription() {
  _channel = supabase.client
      .channel('age_categories_changes')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'age_categories',
        callback: (payload) => refresh(),
      )
      .subscribe();
}
```

**Events Handled:**
- `INSERT`: New category added → Refresh list
- `UPDATE`: Category modified → Refresh list
- `DELETE`: Category removed → Refresh list

**Cleanup:**
```dart
// Automatic cleanup when provider is disposed
ref.onDispose(() {
  _channel?.unsubscribe();
});
```

---

## Performance Considerations

### Caching
- Data is cached in Riverpod provider state
- No need to refetch on widget rebuilds

### Optimizations
- Single query for all categories
- Ordered by `sort_order` in database (no client-side sorting)
- Realtime updates prevent stale data

### Best Practices
1. Use `ageCategoriesListProvider` for simple lists (handles loading state)
2. Use `ageCategoryProvider` for full AsyncValue control
3. Subscribe to realtime updates for admin interfaces
4. Validate selections before saving
5. Handle errors gracefully with user-friendly messages

---

## Testing

See: `apps/pickly_mobile/test/models/age_category_test.dart`

**Coverage:**
- Model serialization/deserialization
- Repository error handling
- Provider state management
- Selection controller logic

---

## Related Documentation

- [Age Selection Card Component](../components/age-selection-card.md)
- [Onboarding Header Component](../components/onboarding-header.md)
- [Onboarding Flow](../flows/onboarding-flow.md)
