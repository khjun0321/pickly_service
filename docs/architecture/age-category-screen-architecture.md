# Age Category Onboarding Screen Architecture

> **Clean Architecture Design for Screen 003: Age-Category Selection**
> Generated: 2025-10-07
> Based on: `.claude/screens/003-age-category.json`

---

## 1. Executive Summary

### Screen Requirements
- **ID**: 003
- **Name**: age-category
- **Type**: selection-list with multiple selection
- **Data Source**: `age_categories` table (Supabase Realtime)
- **UI Component**: SelectionCard with icon-card layout
- **Validation**: Minimum 1 selection required
- **Save Target**: `user_profiles.selected_categories` field (UUID array)

### Architecture Pattern
**Clean Architecture with Feature-First Organization**
- **Contexts**: Domain logic (auth, user, benefits)
- **Features**: UI + State + Routing (onboarding, profile, filter, settings)
- **Separation**: Business logic (contexts) vs Presentation logic (features)

---

## 2. Folder Structure

### 2.1 Recommended Directory Layout

```
apps/pickly_mobile/lib/
├── contexts/                           # Domain/Business Logic Layer
│   ├── auth/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── services/
│   ├── user/
│   │   ├── models/
│   │   │   ├── user_profile.dart       # User profile model
│   │   │   └── user_profile.freezed.dart
│   │   ├── repositories/
│   │   │   ├── user_repository.dart    # Abstract repository
│   │   │   └── user_repository_impl.dart
│   │   └── services/
│   └── benefits/
│       ├── models/
│       │   ├── age_category.dart       # AgeCategory model ✅
│       │   └── age_category.freezed.dart
│       ├── repositories/
│       │   ├── age_category_repository.dart  # Abstract ✅
│       │   └── age_category_repository_impl.dart  # Supabase impl ✅
│       └── services/
│
├── features/                           # Presentation/UI Layer
│   ├── onboarding/
│   │   ├── models/
│   │   │   ├── onboarding_state.dart   # Onboarding state model ✅
│   │   │   └── onboarding_state.freezed.dart
│   │   ├── providers/
│   │   │   ├── age_category_provider.dart      # Riverpod ✅
│   │   │   ├── onboarding_state_provider.dart  # Riverpod ✅
│   │   │   └── user_profile_provider.dart      # Riverpod
│   │   ├── screens/
│   │   │   ├── splash_screen.dart      # Existing
│   │   │   ├── age_category_screen.dart  # NEW ✅
│   │   │   ├── personal_info_screen.dart # Future
│   │   │   ├── region_screen.dart        # Future
│   │   │   ├── income_screen.dart        # Future
│   │   │   └── interest_screen.dart      # Future
│   │   ├── widgets/
│   │   │   ├── common/
│   │   │   │   ├── onboarding_header.dart      # Shared ✅
│   │   │   │   ├── next_button.dart            # Shared ✅
│   │   │   │   └── progress_indicator.dart     # Shared
│   │   │   └── selection_card.dart             # Reusable ✅
│   │   └── routes/
│   │       └── onboarding_routes.dart          # Route definitions
│   ├── profile/
│   ├── filter/
│   └── settings/
│
├── shared/                             # Shared Infrastructure
│   ├── core/
│   │   ├── config/
│   │   │   └── supabase_config.dart    # Supabase client setup ✅
│   │   ├── errors/
│   │   │   └── app_exceptions.dart     # Error handling
│   │   └── utils/
│   │       ├── logger.dart
│   │       └── validators.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── constants/
│       ├── app_constants.dart
│       └── route_constants.dart
│
└── main.dart                           # App entry point
```

---

## 3. Data Layer Architecture

### 3.1 Domain Model: AgeCategory

**File**: `lib/contexts/benefits/models/age_category.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'age_category.freezed.dart';
part 'age_category.g.dart';

@freezed
class AgeCategory with _$AgeCategory {
  const factory AgeCategory({
    required String id,
    required String title,
    required String description,
    required String iconComponent,
    String? iconUrl,
    int? minAge,
    int? maxAge,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AgeCategory;

  factory AgeCategory.fromJson(Map<String, dynamic> json) =>
      _$AgeCategoryFromJson(json);
}
```

**Schema Mapping**:
```sql
age_categories (
  id UUID,
  title TEXT,
  description TEXT,
  icon_component TEXT,
  icon_url TEXT,
  min_age INTEGER,
  max_age INTEGER,
  sort_order INTEGER,
  is_active BOOLEAN,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
```

### 3.2 Repository Interface

**File**: `lib/contexts/benefits/repositories/age_category_repository.dart`

```dart
import '../models/age_category.dart';

abstract class AgeCategoryRepository {
  /// Stream active age categories with realtime updates
  Stream<List<AgeCategory>> watchActiveCategories();

  /// Fetch active categories once
  Future<List<AgeCategory>> getActiveCategories();

  /// Get category by ID
  Future<AgeCategory?> getCategoryById(String id);
}
```

### 3.3 Repository Implementation

**File**: `lib/contexts/benefits/repositories/age_category_repository_impl.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'age_category_repository.dart';
import '../models/age_category.dart';

class AgeCategoryRepositoryImpl implements AgeCategoryRepository {
  final SupabaseClient _supabase;

  AgeCategoryRepositoryImpl(this._supabase);

  @override
  Stream<List<AgeCategory>> watchActiveCategories() {
    return _supabase
        .from('age_categories')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('sort_order')
        .map((data) => data
            .map((json) => AgeCategory.fromJson(json))
            .toList());
  }

  @override
  Future<List<AgeCategory>> getActiveCategories() async {
    final response = await _supabase
        .from('age_categories')
        .select()
        .eq('is_active', true)
        .order('sort_order');

    return (response as List)
        .map((json) => AgeCategory.fromJson(json))
        .toList();
  }

  @override
  Future<AgeCategory?> getCategoryById(String id) async {
    final response = await _supabase
        .from('age_categories')
        .select()
        .eq('id', id)
        .single();

    return response != null ? AgeCategory.fromJson(response) : null;
  }
}
```

---

## 4. State Management Architecture

### 4.1 Onboarding State Model

**File**: `lib/features/onboarding/models/onboarding_state.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(1) int currentStep,
    @Default(5) int totalSteps,
    @Default([]) List<String> selectedCategories,
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    String? error,
  }) = _OnboardingState;

  const OnboardingState._();

  bool get canProceed => selectedCategories.isNotEmpty;
  double get progress => currentStep / totalSteps;
}
```

### 4.2 Riverpod Providers

**File**: `lib/features/onboarding/providers/age_category_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../contexts/benefits/models/age_category.dart';
import '../../../contexts/benefits/repositories/age_category_repository.dart';
import '../../../contexts/benefits/repositories/age_category_repository_impl.dart';

part 'age_category_provider.g.dart';

// Repository provider
@riverpod
AgeCategoryRepository ageCategoryRepository(AgeCategoryRepositoryRef ref) {
  final supabase = Supabase.instance.client;
  return AgeCategoryRepositoryImpl(supabase);
}

// Stream provider for realtime updates
@riverpod
Stream<List<AgeCategory>> ageCategoriesStream(AgeCategoriesStreamRef ref) {
  final repository = ref.watch(ageCategoryRepositoryProvider);
  return repository.watchActiveCategories();
}

// Future provider for one-time fetch
@riverpod
Future<List<AgeCategory>> ageCategories(AgeCategoriesRef ref) {
  final repository = ref.watch(ageCategoryRepositoryProvider);
  return repository.getActiveCategories();
}
```

**File**: `lib/features/onboarding/providers/onboarding_state_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/onboarding_state.dart';

part 'onboarding_state_provider.g.dart';

@riverpod
class OnboardingStateNotifier extends _$OnboardingStateNotifier {
  @override
  OnboardingState build() {
    return const OnboardingState(currentStep: 3, totalSteps: 5);
  }

  void toggleCategory(String categoryId) {
    final selected = state.selectedCategories;
    if (selected.contains(categoryId)) {
      state = state.copyWith(
        selectedCategories: selected.where((id) => id != categoryId).toList(),
      );
    } else {
      state = state.copyWith(
        selectedCategories: [...selected, categoryId],
      );
    }
  }

  bool isCategorySelected(String categoryId) {
    return state.selectedCategories.contains(categoryId);
  }

  Future<void> saveAndProceed() async {
    if (!state.canProceed) {
      state = state.copyWith(error: '최소 1개 이상 선택해주세요');
      return;
    }

    state = state.copyWith(isSaving: true, error: null);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await supabase.from('user_profiles').upsert({
        'user_id': userId,
        'selected_categories': state.selectedCategories,
        'onboarding_step': 4,
        'updated_at': DateTime.now().toIso8601String(),
      });

      state = state.copyWith(isSaving: false);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: '저장 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
```

---

## 5. Presentation Layer Architecture

### 5.1 Main Screen Widget

**File**: `lib/features/onboarding/screens/age_category_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/age_category_provider.dart';
import '../providers/onboarding_state_provider.dart';
import '../widgets/common/onboarding_header.dart';
import '../widgets/common/next_button.dart';
import '../widgets/selection_card.dart';

class AgeCategoryScreen extends ConsumerWidget {
  const AgeCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(ageCategoriesStreamProvider);
    final onboardingState = ref.watch(onboardingStateNotifierProvider);
    final notifier = ref.read(onboardingStateNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            OnboardingHeader(
              currentStep: onboardingState.currentStep,
              totalSteps: onboardingState.totalSteps,
              title: '현재 연령 및 세대 기준을 선택해주세요',
              subtitle: '나에게 맞는 정책과 혜택에 대해 안내해드려요',
            ),

            Expanded(
              child: categoriesAsync.when(
                data: (categories) => _buildCategoryList(
                  categories,
                  onboardingState,
                  notifier,
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Text('데이터 로드 오류: $error'),
                ),
              ),
            ),

            if (onboardingState.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  onboardingState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: NextButton(
                isEnabled: onboardingState.canProceed && !onboardingState.isSaving,
                isLoading: onboardingState.isSaving,
                onPressed: () async {
                  await notifier.saveAndProceed();
                  if (context.mounted && onboardingState.error == null) {
                    Navigator.pushNamed(context, '/onboarding/004-income');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    List<AgeCategory> categories,
    OnboardingState state,
    OnboardingStateNotifier notifier,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final category = categories[index];
        return SelectionCard(
          title: category.title,
          description: category.description,
          iconComponent: category.iconComponent,
          isSelected: notifier.isCategorySelected(category.id),
          onTap: () => notifier.toggleCategory(category.id),
        );
      },
    );
  }
}
```

### 5.2 Reusable Widgets

**File**: `lib/features/onboarding/widgets/common/onboarding_header.dart`

```dart
import 'package:flutter/material.dart';

class OnboardingHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  final String? subtitle;

  const OnboardingHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Row(
            children: List.generate(
              totalSteps,
              (index) => Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(
                    right: index < totalSteps - 1 ? 4 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: index < currentStep
                        ? const Color(0xFF27B473)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Step indicator
          Text(
            '$currentStep / $totalSteps',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

**File**: `lib/features/onboarding/widgets/common/next_button.dart`

```dart
import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback? onPressed;

  const NextButton({
    super.key,
    required this.isEnabled,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF27B473),
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                '다음',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
```

**File**: `lib/features/onboarding/widgets/selection_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

class SelectionCard extends StatelessWidget {
  final String title;
  final String description;
  final String iconComponent;
  final bool isSelected;
  final VoidCallback? onTap;

  const SelectionCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconComponent,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF27B473) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon
            SvgPicture.asset(
              'assets/icons/$iconComponent.svg',
              package: 'pickly_design_system',
              width: 48,
              height: 48,
            ),

            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF27B473),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## 6. Navigation Integration

### 6.1 Route Configuration

**File**: `lib/features/onboarding/routes/onboarding_routes.dart`

```dart
import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/age_category_screen.dart';
// Import other screens as they are created

class OnboardingRoutes {
  static const String splash = '/';
  static const String personalInfo = '/onboarding/001-personal-info';
  static const String region = '/onboarding/002-region';
  static const String ageCategory = '/onboarding/003-age-category';
  static const String income = '/onboarding/004-income';
  static const String interest = '/onboarding/005-interest';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      ageCategory: (context) => const AgeCategoryScreen(),
      // Add other routes
    };
  }
}
```

### 6.2 Main App Update

**File**: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/onboarding/routes/onboarding_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const ProviderScope(child: PicklyApp()));
}

class PicklyApp extends StatelessWidget {
  const PicklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pickly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF27B473),
        ),
        useMaterial3: true,
      ),
      routes: OnboardingRoutes.getRoutes(),
      initialRoute: OnboardingRoutes.splash,
    );
  }
}
```

---

## 7. Dependencies Required

### 7.1 pubspec.yaml Updates

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Backend
  supabase_flutter: ^2.0.0

  # Immutability & Serialization
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

  # UI
  flutter_svg: ^2.0.0

  # Design System
  pickly_design_system:
    path: ../../packages/pickly_design_system

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.6
  riverpod_generator: ^2.3.0
  freezed: ^2.4.5
  json_serializable: ^6.7.1

  # Testing
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2

  # Linting
  flutter_lints: ^3.0.0
```

---

## 8. Supabase Configuration

### 8.1 Environment Setup

**File**: `lib/shared/core/config/supabase_config.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
```

### 8.2 Realtime Subscription

The repository implementation already handles realtime updates through Supabase's `.stream()` method:

```dart
Stream<List<AgeCategory>> watchActiveCategories() {
  return _supabase
      .from('age_categories')
      .stream(primaryKey: ['id'])  // Enable realtime
      .eq('is_active', true)
      .order('sort_order')
      .map((data) => data
          .map((json) => AgeCategory.fromJson(json))
          .toList());
}
```

---

## 9. Testing Strategy

### 9.1 Unit Tests

**File**: `test/contexts/benefits/repositories/age_category_repository_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pickly_mobile/contexts/benefits/repositories/age_category_repository_impl.dart';

void main() {
  group('AgeCategoryRepository', () {
    test('should fetch active categories from Supabase', () async {
      // Test implementation
    });

    test('should stream realtime updates', () async {
      // Test implementation
    });
  });
}
```

### 9.2 Widget Tests

**File**: `test/features/onboarding/screens/age_category_screen_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_mobile/features/onboarding/screens/age_category_screen.dart';

void main() {
  testWidgets('Should display title and subtitle', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AgeCategoryScreen(),
        ),
      ),
    );

    expect(find.text('현재 연령 및 세대 기준을 선택해주세요'), findsOneWidget);
    expect(find.text('나에게 맞는 정책과 혜택에 대해 안내해드려요'), findsOneWidget);
  });

  testWidgets('Should validate before allowing next', (tester) async {
    // Test validation logic
  });

  testWidgets('Should save data on next button', (tester) async {
    // Test save functionality
  });
}
```

---

## 10. Key Architecture Decisions

### 10.1 Clean Architecture Benefits
- **Testability**: Domain logic independent of UI
- **Maintainability**: Clear separation of concerns
- **Scalability**: Easy to add new features
- **Reusability**: Shared components across screens

### 10.2 Riverpod Advantages
- **Type Safety**: Compile-time safety with code generation
- **Performance**: Automatic dependency tracking
- **Testability**: Easy to mock providers
- **DevTools**: Built-in debugging support

### 10.3 Freezed Benefits
- **Immutability**: Prevents accidental state mutations
- **CopyWith**: Easy state updates
- **Equality**: Automatic equality checks
- **JSON Serialization**: Built-in serialization support

---

## 11. Implementation Checklist

### Phase 1: Data Layer
- [ ] Create `AgeCategory` model with Freezed
- [ ] Implement `AgeCategoryRepository` interface
- [ ] Implement `AgeCategoryRepositoryImpl` with Supabase
- [ ] Create `OnboardingState` model
- [ ] Run code generation: `flutter pub run build_runner build`

### Phase 2: State Management
- [ ] Create Riverpod providers for age categories
- [ ] Create Riverpod provider for onboarding state
- [ ] Implement selection toggle logic
- [ ] Implement save functionality
- [ ] Handle error states

### Phase 3: UI Components
- [ ] Create `OnboardingHeader` widget
- [ ] Create `NextButton` widget
- [ ] Create `SelectionCard` widget
- [ ] Implement `AgeCategoryScreen`
- [ ] Add navigation routing

### Phase 4: Integration
- [ ] Update `main.dart` with Supabase initialization
- [ ] Configure routes
- [ ] Test realtime updates
- [ ] Test navigation flow
- [ ] Validate data persistence

### Phase 5: Testing
- [ ] Write unit tests for repository
- [ ] Write unit tests for providers
- [ ] Write widget tests for components
- [ ] Write integration tests for full flow
- [ ] Achieve 80%+ code coverage

---

## 12. Performance Considerations

### 12.1 Realtime Optimization
- Use Supabase's built-in `.stream()` for automatic reconnection
- Implement debouncing for rapid selection changes
- Cache category data to reduce API calls

### 12.2 State Management
- Use `select` in Riverpod to prevent unnecessary rebuilds
- Implement proper disposal of stream subscriptions
- Use `autoDispose` for providers when appropriate

### 12.3 UI Performance
- Use `const` constructors where possible
- Implement `RepaintBoundary` for complex widgets
- Lazy-load images and icons

---

## 13. Error Handling Strategy

### 13.1 Repository Layer
```dart
try {
  final categories = await repository.getActiveCategories();
  return categories;
} on PostgrestException catch (e) {
  throw RepositoryException('Failed to fetch categories: ${e.message}');
} catch (e) {
  throw RepositoryException('Unexpected error: $e');
}
```

### 13.2 Provider Layer
```dart
@riverpod
Future<List<AgeCategory>> ageCategories(AgeCategoriesRef ref) async {
  try {
    final repository = ref.watch(ageCategoryRepositoryProvider);
    return await repository.getActiveCategories();
  } catch (e) {
    // Log error
    rethrow;
  }
}
```

### 13.3 UI Layer
```dart
categoriesAsync.when(
  data: (categories) => _buildCategoryList(categories),
  loading: () => const LoadingIndicator(),
  error: (error, stack) => ErrorWidget(error: error),
)
```

---

## 14. Next Steps

### Immediate Actions
1. **Coder Agent**: Implement data models and repositories
2. **State Manager Agent**: Create Riverpod providers
3. **UI Builder Agent**: Build screen and widgets
4. **Tester Agent**: Write comprehensive tests

### Future Enhancements
1. Add offline support with local caching
2. Implement analytics tracking
3. Add accessibility features
4. Optimize bundle size
5. Add internationalization (i18n)

---

## 15. References

- **Screen Config**: `.claude/screens/003-age-category.json`
- **Database Schema**: `supabase/migrations/20251007035747_onboarding_schema.sql`
- **Development Guide**: `docs/development/onboarding-development-guide.md`
- **PRD**: `docs/PRD.md`
- **Supabase Docs**: https://supabase.com/docs/guides/realtime
- **Riverpod Docs**: https://riverpod.dev/
- **Freezed Docs**: https://pub.dev/packages/freezed

---

**Document Version**: 1.0
**Last Updated**: 2025-10-07
**Author**: Research Agent (Researcher)
**Status**: Ready for Implementation
