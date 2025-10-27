# Benefit Management System - Complete Guide

**Version**: 7.0
**Last Updated**: 2025-10-23
**Audience**: Developers, Product Managers, System Administrators

---

## Table of Contents

1. [Overview](#1-overview)
2. [Installation & Setup](#2-installation--setup)
3. [Architecture](#3-architecture)
4. [User Guide](#4-user-guide)
5. [Developer Guide](#5-developer-guide)
6. [Database Schema](#6-database-schema)
7. [API Reference](#7-api-reference)
8. [Troubleshooting](#8-troubleshooting)
9. [Performance Optimization](#9-performance-optimization)
10. [Future Enhancements](#10-future-enhancements)

---

## 1. Overview

### 1.1 What is the Benefit Management System?

The Benefit Management System is a comprehensive policy browsing and filtering feature within the Pickly mobile application. It enables users to:

- Browse government benefits and policies across multiple categories
- Filter policies by recruitment status (등록순, 모집중, 마감)
- View detailed policy information
- Navigate between different benefit categories
- Save and persist filter preferences

### 1.2 Key Features

**Category Browsing**:
- 9 benefit categories: 인기, 주거, 교육, 지원, 교통, 복지, 의류, 식품, 문화
- Horizontal scrollable category tabs
- Category-specific banners
- Dynamic content loading

**Filtering System**:
- Three filter options per category:
  - 등록순 (Registration order) - All policies
  - 모집중 (Recruiting) - Active policies only
  - 마감 (Closed) - Closed policies only
- Real-time filter updates
- Visual feedback on selection

**Policy Cards**:
- 72x72px thumbnail image
- Policy title with status chip
- Organization name
- Posted date
- Tap to view details

**Data Management**:
- 40 mock policies (10 per major category)
- Realistic Korean policy examples
- Ready for backend integration

### 1.3 System Requirements

**Development Environment**:
- Flutter SDK: 3.10.0+
- Dart SDK: 3.0.0+
- IDE: VS Code or Android Studio

**Dependencies**:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  go_router: ^12.0.0
  flutter_svg: ^2.0.7

  # Design System (local package)
  pickly_design_system:
    path: ../../packages/pickly_design_system
```

**Device Requirements**:
- iOS 12.0+ / Android API 21+
- Minimum screen size: 320x568 (iPhone SE)
- Recommended: 375x667+ (iPhone 8+)

---

## 2. Installation & Setup

### 2.1 Quick Start

```bash
# 1. Clone repository
git clone https://github.com/kwonhyunjun/pickly-service.git
cd pickly-service

# 2. Install dependencies
cd apps/pickly_mobile
flutter pub get

# 3. Generate code (if using freezed/json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run
```

### 2.2 Design System Setup

The benefit management system relies on the Pickly Design System package:

```bash
# Install design system dependencies
cd packages/pickly_design_system
flutter pub get

# Add assets to pubspec.yaml (if not already present)
flutter:
  assets:
    - assets/images/test/
    - assets/icons/
```

### 2.3 Asset Configuration

**Required Assets**:
```
packages/pickly_design_system/assets/
├── images/
│   └── test/
│       ├── list_sample.png          # Default policy image
│       ├── house_banner_test_01.png # Housing banner 1
│       ├── house_banner_test_02.png # Housing banner 2
│       └── house_banner_test_03.png # Housing banner 3
└── icons/
    ├── home.svg                      # Category icons
    ├── book.svg
    ├── dollar.svg
    ├── bus.svg
    └── ... (other category icons)
```

**Adding New Assets**:
1. Place images in `assets/images/test/`
2. Update `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/images/test/your_image.png
   ```
3. Reference in code:
   ```dart
   imageUrl: 'assets/images/test/your_image.png'
   ```

### 2.4 Verification

**Check Installation**:
```bash
# 1. Verify dependencies
flutter pub get

# 2. Check for errors
flutter analyze

# 3. Run tests
flutter test

# 4. Hot reload during development
# Press 'r' in terminal or use IDE hot reload
```

**Expected Output**:
- Benefits screen displays with 9 category tabs
- Policies load in list format
- Filter tabs respond to taps
- Images load correctly

---

## 3. Architecture

### 3.1 Component Hierarchy

```
BenefitsScreen (apps/pickly_mobile/lib/features/benefits/screens/)
│
├── AppHeader (Design System)
│
├── Category Tabs (Design System - TabCircleWithLabel)
│   ├── 인기 (Popular)
│   ├── 주거 (Housing)
│   ├── 교육 (Education)
│   ├── 지원 (Support)
│   ├── 교통 (Transportation)
│   └── ... (5 more categories)
│
├── Category Banner (Dynamic - Consumer)
│   └── PageView of ImageBanners
│
├── Filter Pills (TabPill - Region & Age)
│   ├── Region Selector Bottom Sheet
│   └── Age Category Selector Bottom Sheet
│
├── Category Content (Dynamic)
│   ├── HousingCategoryContent
│   │   ├── FilterTabBar (등록순, 모집중, 마감)
│   │   └── ListView of PolicyListCard
│   ├── EducationCategoryContent
│   ├── SupportCategoryContent
│   └── TransportationCategoryContent
│
└── BottomNavigationBar (Design System)
```

### 3.2 Data Flow

```
User Action → State Update → UI Re-render
     ↓              ↓              ↓
Tap Category → setState() → Update selectedCategoryIndex
Tap Filter   → setState() → Update filterIndex
Tap Policy   → debugPrint → (TODO: Navigate to detail)
```

**State Management Pattern**:
```dart
// 1. Local UI State (BenefitsScreen)
int _selectedCategoryIndex = 0;
Map<int, List<String>> _selectedProgramTypes = {};

// 2. Provider State (Category Content Widgets)
int _filterIndex = 0;

// 3. Global State (Riverpod Providers)
final storage = ref.watch(onboardingStorageServiceProvider);
final banners = ref.watch(bannersByCategoryProvider(categoryId));
```

### 3.3 File Structure

```
apps/pickly_mobile/lib/features/benefits/
├── models/
│   └── policy.dart                           # Policy data model
│
├── providers/
│   ├── mock_policy_data.dart                 # 40 mock policies
│   ├── category_banner_provider.dart         # Banner data provider
│   └── mock_banner_data.dart                 # Banner mock data
│
├── screens/
│   └── benefits_screen.dart                  # Main benefits screen
│
└── widgets/
    ├── popular_category_content.dart         # Popular policies
    ├── housing_category_content.dart         # Housing policies
    ├── education_category_content.dart       # Education policies
    ├── support_category_content.dart         # Support policies
    └── transportation_category_content.dart  # Transportation policies

packages/pickly_design_system/lib/widgets/
├── cards/
│   └── policy_list_card.dart                 # Reusable policy card
│
├── chips/
│   └── status_chip.dart                      # Status indicator chip
│
└── tabs/
    └── filter_tab.dart                       # Filter tab components
```

### 3.4 Design Patterns

**1. Repository Pattern** (Future Backend Integration):
```dart
// Currently: Mock data
class MockPolicyData {
  static List<Policy> getPoliciesByCategory(String categoryId) { ... }
}

// Future: Backend repository
class PolicyRepository {
  final SupabaseClient _client;

  Future<List<Policy>> getPoliciesByCategory(String categoryId) async {
    final response = await _client
        .from('policies')
        .select()
        .eq('category_id', categoryId);

    return response.map((json) => Policy.fromJson(json)).toList();
  }
}
```

**2. Factory Pattern** (Policy Model):
```dart
class Policy {
  // Factory constructor for JSON deserialization
  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      id: json['id'] as String,
      title: json['title'] as String,
      // ... other fields
    );
  }
}
```

**3. Strategy Pattern** (Filtering):
```dart
List<Policy> _getFilteredPolicies() {
  final allPolicies = MockPolicyData.getPoliciesByCategory('housing');

  switch (_filterIndex) {
    case 0: return allPolicies;  // All strategy
    case 1: return allPolicies.where((p) => p.isRecruiting).toList();  // Recruiting strategy
    case 2: return allPolicies.where((p) => !p.isRecruiting).toList();  // Closed strategy
    default: return allPolicies;
  }
}
```

---

## 4. User Guide

### 4.1 Browsing Benefits

**Step 1: Access Benefits Screen**
1. Open Pickly app
2. Tap "혜택" (Benefits) icon in bottom navigation bar
3. Benefits screen loads with "인기" (Popular) category selected

**Step 2: Browse Categories**
1. Horizontal scroll through category tabs:
   - 인기 (Popular)
   - 주거 (Housing)
   - 교육 (Education)
   - 지원 (Support)
   - 교통 (Transportation)
   - 복지 (Welfare)
   - 의류 (Clothing)
   - 식품 (Food)
   - 문화 (Culture)
2. Tap a category to view its policies
3. Banner updates to show category-specific promotions

**Step 3: Apply Filters**
1. After selecting a category, view filter tabs:
   - 등록순 (Registration Order) - Shows all policies
   - 모집중 (Recruiting) - Shows only active policies
   - 마감 (Closed) - Shows only closed policies
2. Tap a filter to update the list
3. List updates in real-time

**Step 4: View Policy Details**
1. Scroll through policy list
2. Each card shows:
   - Policy title (truncated with "...")
   - Organization name
   - Posted date
   - Status chip (모집중 or 마감)
   - Thumbnail image
3. Tap a policy card to view details (currently shows debug message)

### 4.2 Filter Persistence

**Region Filter**:
1. Tap "지역" (Region) filter pill (if visible)
2. Bottom sheet appears with 17 Korean regions
3. Select a region (single selection)
4. Tap "저장" (Save)
5. Filter persists across app sessions

**Age Category Filter**:
1. Tap "연령" (Age) filter pill (if visible)
2. Bottom sheet appears with age categories
3. Select an age category (single selection)
4. Tap "저장" (Save)
5. Filter persists across app sessions

**Program Type Filter** (Category-specific):
1. Tap "공고 선택" (Program Type) filter pill
2. Bottom sheet appears with program types for current category
3. Select multiple program types (checkbox behavior)
4. Tap "저장" (Save)
5. Selected types appear as filter pills
6. Filter persists for each category separately

### 4.3 Common User Flows

**Flow 1: Finding Housing Policies**
```
1. Open app → 혜택 screen
2. Tap "주거" category
3. View housing banner
4. Tap "모집중" filter
5. Browse active housing policies
6. Tap policy for details
```

**Flow 2: Filtering by Region**
```
1. Open app → 혜택 screen
2. Tap "서울" (region filter pill)
3. Select "경기" (Gyeonggi) from bottom sheet
4. Tap "저장"
5. View policies for Gyeonggi region
```

**Flow 3: Selecting Program Types**
```
1. Open app → 혜택 screen
2. Tap "주거" category
3. Tap "전체" (program type pill)
4. Bottom sheet appears
5. Select "행복주택" and "국민임대주택"
6. Tap "저장"
7. View only selected program types
```

---

## 5. Developer Guide

### 5.1 Adding a New Category

**Step 1: Update Category List**
```dart
// In benefits_screen.dart
final List<Map<String, String>> _categories = [
  {'label': '인기', 'icon': 'assets/icons/fire.svg'},
  {'label': '주거', 'icon': 'assets/icons/home.svg'},
  // ... existing categories
  {'label': 'NEW_CATEGORY', 'icon': 'assets/icons/new_icon.svg'},  // Add here
];
```

**Step 2: Update Category ID Mapping**
```dart
String _getCategoryId(int index) {
  switch (index) {
    case 0: return 'popular';
    case 1: return 'housing';
    // ... existing cases
    case 9: return 'new_category';  // Add here
    default: return 'popular';
  }
}
```

**Step 3: Create Category Content Widget**
```dart
// Create: lib/features/benefits/widgets/new_category_content.dart
import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import '../models/policy.dart';
import '../providers/mock_policy_data.dart';

class NewCategoryContent extends StatefulWidget {
  const NewCategoryContent({super.key});

  @override
  State<NewCategoryContent> createState() => _NewCategoryContentState();
}

class _NewCategoryContentState extends State<NewCategoryContent> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final policies = _getFilteredPolicies();

    return Column(
      children: [
        // Filter tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            children: [
              FilterTabBar(
                tabs: const ['등록순', '모집중', '마감'],
                selectedIndex: _filterIndex,
                onTabSelected: (index) {
                  setState(() {
                    _filterIndex = index;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Policy list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: policies.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final policy = policies[index];
              return PolicyListCard(
                imageUrl: policy.imageUrl,
                title: policy.title,
                organization: policy.organization,
                postedDate: policy.postedDate,
                status: policy.isRecruiting
                    ? RecruitmentStatus.recruiting
                    : RecruitmentStatus.closed,
                onTap: () {
                  debugPrint('Policy tapped: ${policy.id}');
                  // TODO: Navigate to policy detail page
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  List<Policy> _getFilteredPolicies() {
    final allPolicies = MockPolicyData.getPoliciesByCategory('new_category');

    switch (_filterIndex) {
      case 0: return allPolicies;
      case 1: return allPolicies.where((p) => p.isRecruiting).toList();
      case 2: return allPolicies.where((p) => !p.isRecruiting).toList();
      default: return allPolicies;
    }
  }
}
```

**Step 4: Add Mock Data**
```dart
// In mock_policy_data.dart
static final List<Policy> newCategoryPolicies = [
  const Policy(
    id: 'new_001',
    title: 'New Policy Title',
    organization: 'Organization Name',
    imageUrl: 'assets/images/test/list_sample.png',
    postedDate: '2025/04/12',
    isRecruiting: true,
    categoryId: 'new_category',
    description: 'Policy description',
  ),
  // Add 9 more policies for a total of 10
];

static List<Policy> getPoliciesByCategory(String categoryId) {
  switch (categoryId) {
    case 'housing': return housingPolicies;
    // ... existing cases
    case 'new_category': return newCategoryPolicies;  // Add here
    default: return [];
  }
}
```

**Step 5: Update Content Routing**
```dart
// In benefits_screen.dart
Widget _getCategoryContent() {
  switch (_selectedCategoryIndex) {
    case 0: return const PopularCategoryContent();
    // ... existing cases
    case 9: return const NewCategoryContent();  // Add here
    default: return const PopularCategoryContent();
  }
}
```

### 5.2 Creating a New Design System Component

**When to Create a Component**:
- Used in 3+ places across the app
- Has clear, reusable functionality
- No business logic (pure UI)

**Example: Creating a Custom Card Component**
```dart
// File: packages/pickly_design_system/lib/widgets/cards/custom_card.dart

import 'package:flutter/material.dart';
import '../../tokens/design_tokens.dart';

/// Custom card component for displaying information
///
/// Example:
/// ```dart
/// CustomCard(
///   title: 'Card Title',
///   subtitle: 'Card Subtitle',
///   onTap: () {},
/// )
/// ```
class CustomCard extends StatelessWidget {
  /// Card title
  final String title;

  /// Card subtitle (optional)
  final String? subtitle;

  /// Tap callback
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: PicklyTypography.titleMedium.copyWith(
                color: TextColors.primary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: PicklyTypography.bodySmall.copyWith(
                  color: TextColors.secondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

**Export Component**:
```dart
// In packages/pickly_design_system/lib/pickly_design_system.dart
export 'widgets/cards/custom_card.dart';
```

**Use Component**:
```dart
import 'package:pickly_design_system/pickly_design_system.dart';

CustomCard(
  title: 'My Card',
  subtitle: 'Card description',
  onTap: () {
    print('Card tapped');
  },
)
```

### 5.3 Backend Integration Guide

**Step 1: Create Supabase Table**
```sql
-- Create policies table
CREATE TABLE policies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  organization TEXT NOT NULL,
  image_url TEXT NOT NULL,
  posted_date DATE NOT NULL,
  is_recruiting BOOLEAN DEFAULT true,
  category_id TEXT NOT NULL,
  description TEXT,
  deadline DATE,
  target_audience TEXT,
  external_url TEXT,
  required_documents TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for category queries
CREATE INDEX idx_policies_category ON policies(category_id);

-- Create index for recruiting status
CREATE INDEX idx_policies_recruiting ON policies(is_recruiting);

-- Row Level Security (RLS)
ALTER TABLE policies ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Allow public read access"
  ON policies FOR SELECT
  USING (true);

-- Only admins can insert/update/delete
CREATE POLICY "Admin full access"
  ON policies FOR ALL
  USING (auth.jwt() ->> 'role' = 'admin');
```

**Step 2: Create Repository**
```dart
// File: lib/contexts/policy/repositories/policy_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/policy.dart';

class PolicyRepository {
  final SupabaseClient _client;

  PolicyRepository(this._client);

  /// Get all policies for a category
  Future<List<Policy>> getPoliciesByCategory(String categoryId) async {
    try {
      final response = await _client
          .from('policies')
          .select()
          .eq('category_id', categoryId)
          .order('posted_date', ascending: false);

      return (response as List)
          .map((json) => Policy.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch policies: $e');
    }
  }

  /// Get recruiting policies only
  Future<List<Policy>> getRecruitingPolicies(String categoryId) async {
    try {
      final response = await _client
          .from('policies')
          .select()
          .eq('category_id', categoryId)
          .eq('is_recruiting', true)
          .order('posted_date', ascending: false);

      return (response as List)
          .map((json) => Policy.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch recruiting policies: $e');
    }
  }

  /// Get closed policies only
  Future<List<Policy>> getClosedPolicies(String categoryId) async {
    try {
      final response = await _client
          .from('policies')
          .select()
          .eq('category_id', categoryId)
          .eq('is_recruiting', false)
          .order('posted_date', ascending: false);

      return (response as List)
          .map((json) => Policy.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch closed policies: $e');
    }
  }

  /// Get single policy by ID
  Future<Policy> getPolicyById(String id) async {
    try {
      final response = await _client
          .from('policies')
          .select()
          .eq('id', id)
          .single();

      return Policy.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch policy: $e');
    }
  }
}
```

**Step 3: Create Riverpod Provider**
```dart
// File: lib/features/benefits/providers/policy_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../contexts/policy/repositories/policy_repository.dart';
import '../../../contexts/policy/models/policy.dart';

// Repository provider
final policyRepositoryProvider = Provider<PolicyRepository>((ref) {
  final supabase = Supabase.instance.client;
  return PolicyRepository(supabase);
});

// Category policies provider
final policiesByCategoryProvider = FutureProvider.family<List<Policy>, String>(
  (ref, categoryId) async {
    final repository = ref.watch(policyRepositoryProvider);
    return repository.getPoliciesByCategory(categoryId);
  },
);

// Recruiting policies provider
final recruitingPoliciesProvider = FutureProvider.family<List<Policy>, String>(
  (ref, categoryId) async {
    final repository = ref.watch(policyRepositoryProvider);
    return repository.getRecruitingPolicies(categoryId);
  },
);

// Closed policies provider
final closedPoliciesProvider = FutureProvider.family<List<Policy>, String>(
  (ref, categoryId) async {
    final repository = ref.watch(policyRepositoryProvider);
    return repository.getClosedPolicies(categoryId);
  },
);

// Single policy provider
final policyByIdProvider = FutureProvider.family<Policy, String>(
  (ref, policyId) async {
    final repository = ref.watch(policyRepositoryProvider);
    return repository.getPolicyById(policyId);
  },
);
```

**Step 4: Update Category Content Widget**
```dart
// Updated: lib/features/benefits/widgets/housing_category_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import '../models/policy.dart';
import '../providers/policy_provider.dart';

class HousingCategoryContent extends ConsumerStatefulWidget {
  const HousingCategoryContent({super.key});

  @override
  ConsumerState<HousingCategoryContent> createState() => _HousingCategoryContentState();
}

class _HousingCategoryContentState extends ConsumerState<HousingCategoryContent> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Get policies based on filter
    final policiesAsync = _filterIndex == 0
        ? ref.watch(policiesByCategoryProvider('housing'))
        : _filterIndex == 1
            ? ref.watch(recruitingPoliciesProvider('housing'))
            : ref.watch(closedPoliciesProvider('housing'));

    return Column(
      children: [
        // Filter tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            children: [
              FilterTabBar(
                tabs: const ['등록순', '모집중', '마감'],
                selectedIndex: _filterIndex,
                onTabSelected: (index) {
                  setState(() {
                    _filterIndex = index;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Policy list with async handling
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: policiesAsync.when(
            data: (policies) {
              if (policies.isEmpty) {
                return const Center(
                  child: Text('No policies found'),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: policies.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final policy = policies[index];
                  return PolicyListCard(
                    imageUrl: policy.imageUrl,
                    title: policy.title,
                    organization: policy.organization,
                    postedDate: policy.postedDate,
                    status: policy.isRecruiting
                        ? RecruitmentStatus.recruiting
                        : RecruitmentStatus.closed,
                    onTap: () {
                      // Navigate to policy detail
                      Navigator.pushNamed(
                        context,
                        '/policy-detail',
                        arguments: policy.id,
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Text('Error: $error'),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
```

---

## 6. Database Schema

### 6.1 Policy Model Fields

| Field | Type | Required | Description | Example |
|-------|------|----------|-------------|---------|
| `id` | String | Yes | Unique identifier | `"housing_001"` |
| `title` | String | Yes | Policy title | `"화성동탄2 A93 동탄호수공원 행복주택"` |
| `organization` | String | Yes | Organization/agency name | `"장기전세주택(GH)"` |
| `imageUrl` | String | Yes | Image URL (network or asset) | `"assets/images/test/list_sample.png"` |
| `postedDate` | String | Yes | Posted date (YYYY/MM/DD) | `"2025/04/12"` |
| `isRecruiting` | bool | Yes | Recruitment status | `true` |
| `categoryId` | String | Yes | Category identifier | `"housing"` |
| `description` | String? | No | Detailed description | `"동탄호수공원 인근 행복주택 입주자 모집"` |
| `deadline` | String? | No | Application deadline | `"2025/05/15"` |
| `targetAudience` | String? | No | Target audience | `"무주택 청년, 신혼부부"` |
| `externalUrl` | String? | No | External link | `"https://example.com"` |
| `requiredDocuments` | List<String>? | No | Required documents | `["신분증", "소득증명서"]` |

### 6.2 Category IDs

| Category ID | Korean Name | English Name | Icon |
|-------------|-------------|--------------|------|
| `popular` | 인기 | Popular | fire.svg |
| `housing` | 주거 | Housing | home.svg |
| `education` | 교육 | Education | book.svg |
| `support` | 지원 | Support | dollar.svg |
| `transportation` | 교통 | Transportation | bus.svg |
| `welfare` | 복지 | Welfare | heart.svg |
| `clothing` | 의류 | Clothing | shirts.svg |
| `food` | 식품 | Food | rice.svg |
| `culture` | 문화 | Culture | speaker.svg |

### 6.3 Supabase Schema (Future)

```sql
-- Policies table
CREATE TABLE policies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  organization TEXT NOT NULL,
  image_url TEXT NOT NULL,
  posted_date DATE NOT NULL,
  is_recruiting BOOLEAN DEFAULT true,
  category_id TEXT NOT NULL,
  description TEXT,
  deadline DATE,
  target_audience TEXT,
  external_url TEXT,
  required_documents TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Categories table
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name_ko TEXT NOT NULL,
  name_en TEXT NOT NULL,
  icon_url TEXT NOT NULL,
  sort_order INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Policy views tracking
CREATE TABLE policy_views (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  policy_id UUID REFERENCES policies(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id),
  viewed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_policies_category ON policies(category_id);
CREATE INDEX idx_policies_recruiting ON policies(is_recruiting);
CREATE INDEX idx_policies_posted_date ON policies(posted_date DESC);
CREATE INDEX idx_policy_views_policy_id ON policy_views(policy_id);

-- Row Level Security
ALTER TABLE policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE policy_views ENABLE ROW LEVEL SECURITY;

-- Policies: Public read, admin write
CREATE POLICY "Public read policies"
  ON policies FOR SELECT
  USING (true);

CREATE POLICY "Admin manage policies"
  ON policies FOR ALL
  USING (auth.jwt() ->> 'role' = 'admin');

-- Categories: Public read, admin write
CREATE POLICY "Public read categories"
  ON categories FOR SELECT
  USING (true);

CREATE POLICY "Admin manage categories"
  ON categories FOR ALL
  USING (auth.jwt() ->> 'role' = 'admin');

-- Policy views: Users can insert their own views
CREATE POLICY "Users insert own views"
  ON policy_views FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users view own views"
  ON policy_views FOR SELECT
  USING (auth.uid() = user_id);
```

---

## 7. API Reference

### 7.1 Policy Model

**Constructor**:
```dart
const Policy({
  required this.id,
  required this.title,
  required this.organization,
  required this.imageUrl,
  required this.postedDate,
  required this.isRecruiting,
  required this.categoryId,
  this.description,
  this.deadline,
  this.targetAudience,
  this.externalUrl,
  this.requiredDocuments,
})
```

**Methods**:

`fromJson(Map<String, dynamic> json)`:
```dart
factory Policy.fromJson(Map<String, dynamic> json) {
  return Policy(
    id: json['id'] as String,
    title: json['title'] as String,
    organization: json['organization'] as String,
    imageUrl: json['image_url'] as String,
    postedDate: json['posted_date'] as String,
    isRecruiting: json['is_recruiting'] as bool,
    categoryId: json['category_id'] as String,
    description: json['description'] as String?,
    deadline: json['deadline'] as String?,
    targetAudience: json['target_audience'] as String?,
    externalUrl: json['external_url'] as String?,
    requiredDocuments: (json['required_documents'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
  );
}
```

`toJson()`:
```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'title': title,
    'organization': organization,
    'image_url': imageUrl,
    'posted_date': postedDate,
    'is_recruiting': isRecruiting,
    'category_id': categoryId,
    'description': description,
    'deadline': deadline,
    'target_audience': targetAudience,
    'external_url': externalUrl,
    'required_documents': requiredDocuments,
  };
}
```

`copyWith({...})`:
```dart
Policy copyWith({
  String? id,
  String? title,
  String? organization,
  String? imageUrl,
  String? postedDate,
  bool? isRecruiting,
  String? categoryId,
  String? description,
  String? deadline,
  String? targetAudience,
  String? externalUrl,
  List<String>? requiredDocuments,
}) {
  return Policy(
    id: id ?? this.id,
    title: title ?? this.title,
    organization: organization ?? this.organization,
    imageUrl: imageUrl ?? this.imageUrl,
    postedDate: postedDate ?? this.postedDate,
    isRecruiting: isRecruiting ?? this.isRecruiting,
    categoryId: categoryId ?? this.categoryId,
    description: description ?? this.description,
    deadline: deadline ?? this.deadline,
    targetAudience: targetAudience ?? this.targetAudience,
    externalUrl: externalUrl ?? this.externalUrl,
    requiredDocuments: requiredDocuments ?? this.requiredDocuments,
  );
}
```

### 7.2 MockPolicyData

**Static Methods**:

`getPoliciesByCategory(String categoryId)`:
```dart
static List<Policy> getPoliciesByCategory(String categoryId) {
  switch (categoryId) {
    case 'housing': return housingPolicies;
    case 'education': return educationPolicies;
    case 'support': return supportPolicies;
    case 'transportation': return transportationPolicies;
    default: return [];
  }
}
```

`getAllPolicies()`:
```dart
static List<Policy> getAllPolicies() {
  return [
    ...housingPolicies,
    ...educationPolicies,
    ...supportPolicies,
    ...transportationPolicies,
  ];
}
```

### 7.3 PolicyListCard

**Properties**:
```dart
const PolicyListCard({
  super.key,
  required this.imageUrl,      // Image URL (network or asset)
  required this.title,          // Policy title
  required this.organization,   // Organization name
  required this.postedDate,     // Posted date (YYYY/MM/DD)
  required this.status,         // RecruitmentStatus enum
  this.onTap,                   // Optional tap callback
})
```

**Example Usage**:
```dart
PolicyListCard(
  imageUrl: 'assets/images/test/list_sample.png',
  title: '화성동탄2 A93 동탄호수공원 행복주택',
  organization: '장기전세주택(GH)',
  postedDate: '2025/04/12',
  status: RecruitmentStatus.recruiting,
  onTap: () {
    print('Policy tapped');
  },
)
```

### 7.4 StatusChip

**Properties**:
```dart
const StatusChip({
  super.key,
  required this.status,  // RecruitmentStatus.recruiting or .closed
})
```

**Example Usage**:
```dart
StatusChip(status: RecruitmentStatus.recruiting)  // Shows "모집중"
StatusChip(status: RecruitmentStatus.closed)      // Shows "마감"
```

### 7.5 FilterTabBar

**Properties**:
```dart
const FilterTabBar({
  super.key,
  required this.tabs,              // List of tab labels
  required this.selectedIndex,     // Currently selected index
  this.onTabSelected,              // Callback(int index)
})
```

**Example Usage**:
```dart
FilterTabBar(
  tabs: const ['등록순', '모집중', '마감'],
  selectedIndex: 0,
  onTabSelected: (index) {
    setState(() {
      _filterIndex = index;
    });
  },
)
```

---

## 8. Troubleshooting

### 8.1 Common Issues

**Issue: Images not loading**
```
Symptom: PolicyListCard shows placeholder instead of images
Cause: Asset path incorrect or assets not declared in pubspec.yaml
```

**Solution**:
1. Check asset path in policy model
2. Verify `pubspec.yaml` includes asset:
   ```yaml
   flutter:
     assets:
       - assets/images/test/
   ```
3. Run `flutter clean && flutter pub get`
4. Rebuild app

---

**Issue: Filter not updating list**
```
Symptom: Tapping filter tabs doesn't update policy list
Cause: State not updating or filter logic incorrect
```

**Solution**:
1. Check `setState()` is called in filter callback:
   ```dart
   onTabSelected: (index) {
     setState(() {
       _filterIndex = index;  // Must trigger rebuild
     });
   }
   ```
2. Verify `_getFilteredPolicies()` references correct state:
   ```dart
   List<Policy> _getFilteredPolicies() {
     switch (_filterIndex) {  // Uses instance variable
       // ...
     }
   }
   ```
3. Check data exists for filter (e.g., recruiting policies)

---

**Issue: Bottom sheet not appearing**
```
Symptom: Tapping filter pills doesn't show bottom sheet
Cause: Context issue or modal not properly configured
```

**Solution**:
1. Ensure `showModalBottomSheet` is called:
   ```dart
   showModalBottomSheet(
     context: context,
     backgroundColor: Colors.white,
     isScrollControlled: true,
     shape: const RoundedRectangleBorder(
       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
     ),
     builder: (context) => Container(...),
   );
   ```
2. Check context is valid (not disposed widget)
3. Verify no errors in console

---

**Issue: Design system component not found**
```
Symptom: Import error for PolicyListCard or other design system widget
Cause: Component not exported from design system package
```

**Solution**:
1. Check component is exported in `pickly_design_system.dart`:
   ```dart
   export 'widgets/cards/policy_list_card.dart';
   ```
2. Run `flutter clean` in design system package:
   ```bash
   cd packages/pickly_design_system
   flutter clean
   flutter pub get
   ```
3. Rebuild app:
   ```bash
   cd ../../apps/pickly_mobile
   flutter pub get
   flutter run
   ```

---

**Issue: Overflow errors in PolicyListCard**
```
Symptom: RenderFlex overflow errors in console
Cause: Content too large for 72px height constraint
```

**Solution**:
1. Ensure text uses `maxLines` and `overflow`:
   ```dart
   Text(
     title,
     maxLines: 1,
     overflow: TextOverflow.ellipsis,
   )
   ```
2. Check spacing values don't exceed container:
   ```dart
   // Total height = padding + content + spacing
   // Must be ≤ 72px
   ```
3. Use `Expanded` for flexible content:
   ```dart
   Row(
     children: [
       Container(width: 72, height: 72),
       const SizedBox(width: 12),
       Expanded(  // Takes remaining space
         child: Column(...),
       ),
     ],
   )
   ```

---

### 8.2 Debug Mode

**Enable Debug Logging**:
```dart
// In benefits_screen.dart
@override
Widget build(BuildContext context) {
  print('[BenefitsScreen] Building with category: $_selectedCategoryIndex');
  print('[BenefitsScreen] Program types: $_selectedProgramTypes');

  // ... rest of build method
}
```

**Check Riverpod State**:
```dart
final storage = ref.watch(onboardingStorageServiceProvider);
print('[BenefitsScreen] Storage state: ${storage.getAllSelectedProgramTypes()}');
```

**Verify Data Loading**:
```dart
final policies = MockPolicyData.getPoliciesByCategory('housing');
print('[MockData] Loaded ${policies.length} housing policies');
```

---

### 8.3 Performance Issues

**Issue: Slow scrolling or janky animations**
```
Symptom: List stutters when scrolling
Cause: Too many widgets rebuilding or heavy operations in build()
```

**Solution**:
1. Use `const` constructors where possible:
   ```dart
   const SizedBox(height: 16)  // Instead of SizedBox(height: 16)
   ```
2. Extract static widgets to separate methods or widgets
3. Avoid heavy computations in `build()`:
   ```dart
   // Bad
   Widget build(BuildContext context) {
     final filtered = policies.where(...).toList();  // Recomputes every build
     return ListView(...);
   }

   // Good
   List<Policy> _cachedPolicies = [];

   @override
   void didUpdateWidget(OldWidget old) {
     super.didUpdateWidget(old);
     if (_filterIndex != old._filterIndex) {
       _cachedPolicies = _computeFilteredPolicies();
     }
   }
   ```
4. Use `RepaintBoundary` for complex widgets:
   ```dart
   RepaintBoundary(
     child: PolicyListCard(...),
   )
   ```

---

## 9. Performance Optimization

### 9.1 Image Optimization

**Use `cached_network_image`**:
```dart
// Add dependency
dependencies:
  cached_network_image: ^3.3.0

// Update PolicyListCard
import 'package:cached_network_image/cached_network_image.dart';

Widget _buildImage() {
  final isAsset = imageUrl.startsWith('assets/');

  if (isAsset) {
    return Image.asset(
      imageUrl,
      package: 'pickly_design_system',
      fit: BoxFit.cover,
    );
  } else {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      errorWidget: (context, url, error) => _buildPlaceholder(),
    );
  }
}
```

**Benefits**:
- Automatic caching (in-memory + disk)
- Reduced network requests
- Faster load times

---

### 9.2 List Optimization

**Add Pagination**:
```dart
class _HousingCategoryContentState extends State<HousingCategoryContent> {
  int _currentPage = 0;
  final int _pageSize = 10;
  List<Policy> _displayedPolicies = [];

  @override
  void initState() {
    super.initState();
    _loadNextPage();
  }

  void _loadNextPage() {
    final allPolicies = MockPolicyData.getPoliciesByCategory('housing');
    final start = _currentPage * _pageSize;
    final end = min(start + _pageSize, allPolicies.length);

    setState(() {
      _displayedPolicies.addAll(allPolicies.sublist(start, end));
      _currentPage++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _displayedPolicies.length + 1,  // +1 for loader
      itemBuilder: (context, index) {
        if (index == _displayedPolicies.length) {
          // Load more indicator
          _loadNextPage();
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final policy = _displayedPolicies[index];
        return PolicyListCard(...);
      },
    );
  }
}
```

---

### 9.3 State Optimization

**Use `SelectNotifier` for Filters**:
```dart
// Create notifier
class FilterNotifier extends StateNotifier<int> {
  FilterNotifier() : super(0);

  void setFilter(int index) {
    state = index;
  }
}

// Create provider
final filterProvider = StateNotifierProvider.autoDispose<FilterNotifier, int>(
  (ref) => FilterNotifier(),
);

// Use in widget
class _HousingCategoryContentState extends ConsumerState<HousingCategoryContent> {
  @override
  Widget build(BuildContext context) {
    final filterIndex = ref.watch(filterProvider);

    return Column(
      children: [
        FilterTabBar(
          tabs: const ['등록순', '모집중', '마감'],
          selectedIndex: filterIndex,
          onTabSelected: (index) {
            ref.read(filterProvider.notifier).setFilter(index);
          },
        ),
        // ... rest of widget
      ],
    );
  }
}
```

**Benefits**:
- Automatic disposal when widget unmounted
- Better separation of concerns
- Easier testing

---

## 10. Future Enhancements

### 10.1 Planned Features

**Phase 1: Backend Integration (2-3 months)**
- [ ] Connect to Supabase database
- [ ] Implement real-time policy updates
- [ ] Add policy CRUD operations (admin)
- [ ] Enable image uploads

**Phase 2: Enhanced Filtering (3-4 months)**
- [ ] Advanced filter options (income, region, etc.)
- [ ] Save filter presets
- [ ] Multi-category filtering
- [ ] Smart recommendations

**Phase 3: User Engagement (4-6 months)**
- [ ] Policy bookmarking
- [ ] Sharing policies
- [ ] Push notifications for new policies
- [ ] Policy comments and Q&A

**Phase 4: AI Features (6+ months)**
- [ ] AI-powered policy recommendations
- [ ] Natural language search
- [ ] Policy summarization
- [ ] Eligibility checker

---

### 10.2 Technical Roadmap

**Performance**:
- Implement virtual scrolling for lists >100 items
- Add image lazy loading
- Optimize bundle size
- Implement code splitting

**Accessibility**:
- Add full screen reader support
- Implement keyboard navigation
- Add high contrast mode
- Support dynamic text sizing

**Testing**:
- Achieve 80% code coverage
- Add E2E tests for critical flows
- Implement visual regression testing
- Add performance monitoring

**DevOps**:
- Set up CI/CD pipeline
- Implement automatic deployments
- Add error tracking (Sentry)
- Implement analytics (Firebase Analytics)

---

## Appendix A: Mock Data Reference

### Housing Policies (10)
1. 화성동탄2 A93 동탄호수공원 행복주택
2. 서울시 청년 매입임대주택 입주자 모집
3. 경기도 공공임대주택 신청 안내
4. 신혼희망타운 사전예약 접수
5. 행복주택 3차 입주자 모집 공고
6. 인천 청라지구 공공분양 입주자 모집
7. 부산 에코델타시티 스마트시티 분양
8. 전월세 보증금 반환 보증 신청
9. 청년 전세자금 대출 지원
10. 다자녀 가구 특별공급 신청

### Education Policies (10)
1. 국가장학금 2학기 신청 안내
2. 서울시 청년 교육비 지원 사업
3. 취업 연계 직업훈련 과정 모집
4. 경기도 청년 학자금 대출 이자 지원
5. 고등학생 교육비 지원 사업
6. K-디지털 트레이닝 교육 과정
7. 외국어 교육비 지원 프로그램
8. 평생교육 바우처 지원 사업
9. 대학생 해외 연수 지원 프로그램
10. 자격증 취득 비용 지원

### Support Policies (10)
1. 청년 구직활동 지원금 신청
2. 청년 창업 지원 사업
3. 면접 정장 대여 서비스
4. 청년 내일채움공제 가입 안내
5. 일자리 안정 자금 지원
6. 청년 저축계좌 지원 사업
7. 중소기업 청년 취업 지원금
8. 청년 월세 지원 사업
9. 장애인 고용장려금 신청
10. 경력단절여성 재취업 지원

### Transportation Policies (10)
1. 청년 교통비 지원 사업
2. 경기도 K-패스 카드 신청
3. 장애인 콜택시 이용권 지원
4. 저소득층 유류비 지원
5. 전기차 구매 보조금 신청
6. 수도권 통합환승 할인제 확대
7. 자전거 출퇴근 마일리지 제도
8. 수소차 구매 지원금 신청
9. 고령자 교통비 지원 사업
10. 지하철 무료 와이파이 확대

---

## Appendix B: Color Reference

### Status Chip Colors

**Recruiting (모집중)**:
- Background: `#C6ECFF` (Light blue)
- Text: `#5090FF` (Blue)
- Border: None

**Closed (마감)**:
- Background: `#DDDDDD` (Gray)
- Text: `#FFFFFF` (White)
- Border: `#DDDDDD` (Gray, 1px)

### Design Tokens

**Brand Colors**:
- Primary: `BrandColors.primary` (Green)
- Secondary: `BrandColors.secondary`

**Text Colors**:
- Primary: `TextColors.primary` (#3E3E3E)
- Secondary: `TextColors.secondary` (#828282)
- Tertiary: `TextColors.tertiary`

**Background Colors**:
- App: `BackgroundColors.app` (#F5F5F5)
- Card: `Colors.white` (#FFFFFF)

---

## Appendix C: Changelog

### v7.0 (2025-10-20)
- Initial release of benefit management system
- 40 mock policies across 4 categories
- PolicyListCard, StatusChip, FilterTabBar components
- Category browsing and filtering
- Filter persistence

### v7.1 (Planned)
- Backend integration with Supabase
- Real-time policy updates
- Policy detail page
- Navigation implementation

### v7.2 (Planned)
- Advanced filtering
- Policy bookmarking
- Sharing functionality
- Push notifications

---

**End of Benefit Management Guide**

For additional support:
- GitHub Issues: https://github.com/kwonhyunjun/pickly-service/issues
- Developer Documentation: `/docs/README.md`
- Design System Guide: `/packages/pickly_design_system/README.md`
