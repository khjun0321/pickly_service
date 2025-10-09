# Age Category Screen - Layer Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                               USER INTERFACE LAYER                              │
│                          (features/onboarding/screens/)                         │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐ │
│  │                        AgeCategoryScreen                                  │ │
│  │                                                                           │ │
│  │  ┌──────────────────────┐  ┌──────────────────────┐                     │ │
│  │  │  OnboardingHeader    │  │  Progress: 3/5       │                     │ │
│  │  │  Title + Subtitle    │  │  ████████░░          │                     │ │
│  │  └──────────────────────┘  └──────────────────────┘                     │ │
│  │                                                                           │ │
│  │  ┌───────────────────────────────────────────────────────────────────┐  │ │
│  │  │                    ListView.separated                             │  │ │
│  │  │                                                                   │  │ │
│  │  │  ┌──────────────────────────────────────────────────────────┐   │  │ │
│  │  │  │ SelectionCard: 청년 (만 19-39세)                         │   │  │ │
│  │  │  │ [Icon] 대학생, 취업준비생, 직장인               [✓]      │   │  │ │
│  │  │  └──────────────────────────────────────────────────────────┘   │  │ │
│  │  │  ┌──────────────────────────────────────────────────────────┐   │  │ │
│  │  │  │ SelectionCard: 신혼부부·예비부부                         │   │  │ │
│  │  │  │ [Icon] 결혼 예정 또는 결혼 7년이내              [ ]      │   │  │ │
│  │  │  └──────────────────────────────────────────────────────────┘   │  │ │
│  │  │  ┌──────────────────────────────────────────────────────────┐   │  │ │
│  │  │  │ SelectionCard: 육아중인 부모                             │   │  │ │
│  │  │  │ [Icon] 영유아~초등 자녀 양육 중                 [✓]      │   │  │ │
│  │  │  └──────────────────────────────────────────────────────────┘   │  │ │
│  │  │  ...                                                             │  │ │
│  │  └───────────────────────────────────────────────────────────────────┘  │ │
│  │                                                                           │ │
│  │  ┌───────────────────────────────────────────────────────────────────┐  │ │
│  │  │                       NextButton                                  │  │ │
│  │  │                         [다음]                                    │  │ │
│  │  └───────────────────────────────────────────────────────────────────┘  │ │
│  └───────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        ↕ consumes
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            STATE MANAGEMENT LAYER                               │
│                        (features/onboarding/providers/)                         │
│                                                                                 │
│  ┌────────────────────────────────────┐  ┌──────────────────────────────────┐ │
│  │  ageCategoriesStreamProvider       │  │  onboardingStateNotifierProvider │ │
│  │  (Riverpod Stream)                 │  │  (Riverpod StateNotifier)        │ │
│  │                                    │  │                                  │ │
│  │  Stream<List<AgeCategory>>         │  │  OnboardingState {               │ │
│  │    - Realtime updates              │  │    currentStep: 3                │ │
│  │    - Auto-reconnect                │  │    totalSteps: 5                 │ │
│  │    - Filter: is_active=true        │  │    selectedCategories: [         │ │
│  │    - Order: sort_order             │  │      "uuid-1", "uuid-3"          │ │
│  │                                    │  │    ]                             │ │
│  │  Methods:                          │  │    isLoading: false              │ │
│  │    - watchActiveCategories()       │  │    isSaving: false               │ │
│  │    - getActiveCategories()         │  │    error: null                   │ │
│  └────────────────────────────────────┘  │  }                               │ │
│                  ↕                        │                                  │ │
│  ┌────────────────────────────────────┐  │  Methods:                        │ │
│  │  ageCategoryRepositoryProvider     │  │    - toggleCategory(id)          │ │
│  │  (Riverpod Provider)               │  │    - isCategorySelected(id)      │ │
│  │                                    │  │    - saveAndProceed()            │ │
│  │  AgeCategoryRepository             │  │    - clearError()                │ │
│  │    (Repository instance)           │  │                                  │ │
│  └────────────────────────────────────┘  └──────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        ↕ uses
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              DOMAIN/BUSINESS LAYER                              │
│                         (contexts/benefits/repositories/)                       │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐ │
│  │                  AgeCategoryRepository (Interface)                        │ │
│  │                                                                           │ │
│  │  abstract class AgeCategoryRepository {                                  │ │
│  │    Stream<List<AgeCategory>> watchActiveCategories();                    │ │
│  │    Future<List<AgeCategory>> getActiveCategories();                      │ │
│  │    Future<AgeCategory?> getCategoryById(String id);                      │ │
│  │  }                                                                        │ │
│  └───────────────────────────────────────────────────────────────────────────┘ │
│                                        ↕ implements                             │
│  ┌───────────────────────────────────────────────────────────────────────────┐ │
│  │              AgeCategoryRepositoryImpl (Supabase Implementation)          │ │
│  │                                                                           │ │
│  │  class AgeCategoryRepositoryImpl implements AgeCategoryRepository {      │ │
│  │    final SupabaseClient _supabase;                                       │ │
│  │                                                                           │ │
│  │    @override                                                              │ │
│  │    Stream<List<AgeCategory>> watchActiveCategories() {                   │ │
│  │      return _supabase                                                    │ │
│  │        .from('age_categories')                                           │ │
│  │        .stream(primaryKey: ['id'])      // Realtime enabled              │ │
│  │        .eq('is_active', true)                                            │ │
│  │        .order('sort_order')                                              │ │
│  │        .map((data) => data.map(AgeCategory.fromJson).toList());          │ │
│  │    }                                                                      │ │
│  │                                                                           │ │
│  │    @override                                                              │ │
│  │    Future<List<AgeCategory>> getActiveCategories() async { ... }         │ │
│  │  }                                                                        │ │
│  └───────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐ │
│  │                    AgeCategory (Domain Model - Freezed)                   │ │
│  │                                                                           │ │
│  │  @freezed                                                                 │ │
│  │  class AgeCategory with _$AgeCategory {                                  │ │
│  │    const factory AgeCategory({                                           │ │
│  │      required String id,                // UUID                          │ │
│  │      required String title,             // "청년"                        │ │
│  │      required String description,       // "(만 19세-39세) ..."          │ │
│  │      required String iconComponent,     // "young_man"                   │ │
│  │      String? iconUrl,                                                    │ │
│  │      int? minAge,                       // 19                            │ │
│  │      int? maxAge,                       // 39                            │ │
│  │      @Default(0) int sortOrder,         // 1                             │ │
│  │      @Default(true) bool isActive,                                       │ │
│  │      DateTime? createdAt,                                                │ │
│  │      DateTime? updatedAt,                                                │ │
│  │    }) = _AgeCategory;                                                    │ │
│  │                                                                           │ │
│  │    factory AgeCategory.fromJson(Map<String, dynamic> json);              │ │
│  │  }                                                                        │ │
│  └───────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        ↕ queries
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                 DATA LAYER                                      │
│                            (Supabase PostgreSQL)                                │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐ │
│  │  Table: age_categories                                                    │ │
│  │  ─────────────────────────────────────────────────────────────────────   │ │
│  │  id               | UUID     | PRIMARY KEY                                │ │
│  │  title            | TEXT     | "청년"                                     │ │
│  │  description      | TEXT     | "(만 19세-39세) 대학생, 취업준비생..."     │ │
│  │  icon_component   | TEXT     | "young_man"                                │ │
│  │  icon_url         | TEXT     | NULL                                       │ │
│  │  min_age          | INTEGER  | 19                                         │ │
│  │  max_age          | INTEGER  | 39                                         │ │
│  │  sort_order       | INTEGER  | 1                                          │ │
│  │  is_active        | BOOLEAN  | true                                       │ │
│  │  created_at       | TIMESTAMPTZ | 2025-10-07 00:00:00                     │ │
│  │  updated_at       | TIMESTAMPTZ | 2025-10-07 00:00:00                     │ │
│  │                                                                           │ │
│  │  Features:                                                                │ │
│  │    - Realtime enabled (pub/sub)                                          │ │
│  │    - RLS: Public read for is_active=true                                 │ │
│  │    - Auto-update trigger on updated_at                                   │ │
│  │                                                                           │ │
│  │  Initial Data (6 categories):                                            │ │
│  │    1. 청년 (19-39세)                                                      │ │
│  │    2. 신혼부부·예비부부                                                   │ │
│  │    3. 육아중인 부모                                                       │ │
│  │    4. 다자녀 가구                                                         │ │
│  │    5. 어르신 (65세+)                                                      │ │
│  │    6. 장애인                                                              │ │
│  └───────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐ │
│  │  Table: user_profiles                                                     │ │
│  │  ─────────────────────────────────────────────────────────────────────   │ │
│  │  id                    | UUID     | PRIMARY KEY                           │ │
│  │  user_id               | UUID     | REFERENCES auth.users(id)             │ │
│  │  ...                                                                      │ │
│  │  selected_categories   | UUID[]   | ["uuid-1", "uuid-3"]  ← SAVE TARGET  │ │
│  │  ...                                                                      │ │
│  │  onboarding_step       | INTEGER  | 4 (after save)                        │ │
│  │  updated_at            | TIMESTAMPTZ                                      │ │
│  │                                                                           │ │
│  │  Features:                                                                │ │
│  │    - RLS: Users manage own profile (auth.uid() = user_id)                │ │
│  │    - Upsert support for incremental onboarding                           │ │
│  └───────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘

───────────────────────────────────────────────────────────────────────────────────

DATA FLOW SEQUENCE:

1. SCREEN LOAD:
   AgeCategoryScreen
     → ref.watch(ageCategoriesStreamProvider)
       → ageCategoryRepository.watchActiveCategories()
         → Supabase: SELECT * FROM age_categories WHERE is_active=true
           → Stream emits List<AgeCategory>
             → UI rebuilds with category cards

2. USER SELECTION:
   SelectionCard.onTap()
     → onboardingStateNotifier.toggleCategory(categoryId)
       → state = state.copyWith(selectedCategories: [...])
         → UI rebuilds (card shows checkmark)

3. SAVE & NAVIGATE:
   NextButton.onPressed()
     → onboardingStateNotifier.saveAndProceed()
       → Validate: selectedCategories.isNotEmpty
         → Supabase: upsert user_profiles {
             user_id: auth.uid(),
             selected_categories: ["uuid-1", "uuid-3"],
             onboarding_step: 4
           }
           → Navigator.pushNamed('/onboarding/004-income')

4. REALTIME UPDATES:
   Admin updates age_categories in backoffice
     → PostgreSQL trigger fires
       → Supabase Realtime broadcasts change
         → Repository stream emits new data
           → UI automatically rebuilds

───────────────────────────────────────────────────────────────────────────────────

KEY ARCHITECTURAL PATTERNS:

✓ Clean Architecture      - Clear separation of concerns
✓ Repository Pattern      - Abstract data access
✓ Provider Pattern        - Dependency injection (Riverpod)
✓ State Management        - Immutable state with Freezed
✓ Reactive Programming    - Streams for realtime updates
✓ SOLID Principles        - Single responsibility, Open/closed
✓ DRY                     - Reusable widgets (Header, Button, Card)
✓ Testability             - All layers mockable/testable

───────────────────────────────────────────────────────────────────────────────────
```
