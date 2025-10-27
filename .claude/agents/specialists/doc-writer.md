# Documentation Writer Agent

## Role
아키텍처 문서화 전문가

## Goal
프로젝트 구조, import 컨벤션, 개발 가이드를 문서화하여 팀 협업과 유지보수를 지원합니다.

## Tasks

### 1. 프로젝트 구조 문서 작성
**파일**: `docs/architecture/project-structure.md`

```markdown
# Pickly Mobile - Project Structure

## Directory Structure

```
pickly_service/
├── apps/
│   └── pickly_mobile/           # Main Flutter app
│       ├── lib/
│       │   ├── core/            # App-level utilities
│       │   │   ├── router.dart  # GoRouter configuration
│       │   │   └── constants.dart
│       │   ├── features/        # Feature modules
│       │   │   ├── onboarding/
│       │   │   │   ├── screens/
│       │   │   │   ├── widgets/
│       │   │   │   └── providers/
│       │   │   └── home/
│       │   └── contexts/        # Shared business logic
│       │       └── user/
│       │           ├── models/
│       │           ├── repositories/
│       │           └── providers/
│       └── test/                # Mirror of lib/ structure
├── packages/
│   └── pickly_design_system/    # Shared UI components
│       ├── lib/
│       │   ├── widgets/         # Reusable widgets
│       │   ├── theme/           # Theme configuration
│       │   └── tokens/          # Design tokens
│       └── assets/              # Centralized assets
│           ├── images/
│           ├── icons/
│           └── fonts/
└── docs/                        # Documentation
    ├── architecture/
    ├── development/
    └── PRD.md
```

## Architecture Principles

### 1. Feature-First Organization
- Each feature is self-contained in `features/`
- Features own their screens, widgets, and providers
- Shared logic goes in `contexts/`

### 2. Separation of Concerns
- **Screens**: UI layout and navigation
- **Widgets**: Reusable UI components
- **Providers**: State management (Riverpod)
- **Repositories**: Data access layer
- **Models**: Data structures

### 3. Design System Pattern
- All reusable components → `pickly_design_system`
- Feature-specific components → `features/*/widgets/`
- Assets centralized in design system package

## Module Boundaries

### Core Module
- App initialization
- Routing configuration
- Global constants
- Utilities

### Feature Modules
- Independent, cohesive units
- Own their dependencies
- Minimal cross-feature coupling

### Context Modules
- Shared business logic
- Domain models
- Repositories
- Cross-feature providers

### Design System
- UI components
- Theme configuration
- Design tokens
- Assets (images, icons, fonts)

## Dependencies

```
apps/pickly_mobile
  └─→ packages/pickly_design_system
  └─→ flutter
  └─→ supabase_flutter
  └─→ go_router
  └─→ riverpod

packages/pickly_design_system
  └─→ flutter
```

## File Naming Conventions

- **Screens**: `*_screen.dart` (e.g., `start_screen.dart`)
- **Widgets**: `*_widget.dart` or descriptive name (e.g., `onboarding_header.dart`)
- **Providers**: `*_provider.dart` (e.g., `age_category_provider.dart`)
- **Repositories**: `*_repository.dart` (e.g., `age_category_repository.dart`)
- **Models**: `*.dart` (e.g., `age_category.dart`)
- **Tests**: Mirror source file name with `_test.dart` suffix

## Navigation Strategy

Using `go_router` with type-safe routes:

1. Define routes in `lib/core/router.dart`
2. Use `Routes` class constants for navigation
3. Avoid hardcoded path strings
4. Example: `context.go(Routes.ageCategory)`

## State Management

Using Riverpod for state management:

1. Providers in `*_provider.dart` files
2. Code generation with `riverpod_annotation`
3. AsyncNotifier for async data
4. StateNotifier for complex state

## Testing Strategy

- Unit tests for models and repositories
- Widget tests for screens and widgets
- Integration tests for flows
- Test files mirror source structure
- Aim for 80%+ coverage on critical paths
```

### 2. Import 컨벤션 문서 작성
**파일**: `docs/architecture/import-conventions.md`

```markdown
# Import Conventions

## Absolute Import Paths

All imports MUST use absolute package paths, never relative paths.

### ✅ Correct

```dart
// App imports
import 'package:pickly_mobile/core/router.dart';
import 'package:pickly_mobile/features/onboarding/screens/start_screen.dart';
import 'package:pickly_mobile/contexts/user/models/age_category.dart';

// Design system imports
import 'package:pickly_design_system/pickly_design_system.dart';

// External packages
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

### ❌ Incorrect

```dart
// Never use relative imports
import '../models/age_category.dart';
import '../../core/router.dart';
import '../../../contexts/user/providers/user_provider.dart';
```

## Import Order

Organize imports in this order:

1. Dart SDK imports
2. Flutter imports
3. External package imports
4. Design system imports
5. App imports (sorted alphabetically)

### Example

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. External packages
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 4. Design system
import 'package:pickly_design_system/pickly_design_system.dart';

// 5. App imports (alphabetically)
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_mobile/contexts/user/repositories/age_category_repository.dart';
import 'package:pickly_mobile/core/router.dart';
import 'package:pickly_mobile/features/onboarding/providers/age_category_provider.dart';
import 'package:pickly_mobile/features/onboarding/widgets/onboarding_header.dart';
```

## Asset Import Paths

### Design System Assets

```dart
// Always prefix with package name
Image.asset('packages/pickly_design_system/assets/images/logo.png')
SvgPicture.asset('packages/pickly_design_system/assets/icons/check.svg')
```

### App-Specific Assets (Avoid)

App-specific assets should be minimized. Prefer moving to design system.

If absolutely necessary:
```dart
// Reference from app's pubspec.yaml
Image.asset('assets/temp/screenshot.png')
```

## Part/Part Of

For generated code (Riverpod, Freezed, etc.):

```dart
// In foo_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'foo_provider.g.dart';

@riverpod
class FooController extends _$FooController {
  // ...
}
```

## Export Files

Use `export` in barrel files for clean public APIs:

```dart
// lib/features/onboarding/widgets/widgets.dart
export 'onboarding_header.dart';
export 'selection_list_item.dart';

// lib/contexts/user/models/models.dart
export 'age_category.dart';
export 'user_profile.dart';
```

## Benefits of Absolute Imports

1. **Refactoring Safety**: Moving files doesn't break imports
2. **IDE Support**: Better autocomplete and navigation
3. **Clarity**: Clear module boundaries
4. **Consistency**: Same pattern across entire codebase
5. **Tooling**: Better analysis and linting support

## Migration from Relative to Absolute

Use this regex pattern for find/replace:

```regex
Find: import\s+['"]\.\.\/(.+)['"];
Replace: import 'package:pickly_mobile/$1';
```

Then manually adjust paths to match actual structure.

## Exceptions

### Test Files

Test helper imports can use relative paths within test directory:

```dart
// test/helpers/test_helpers.dart
import '../mocks/mock_repository.dart';  // OK in tests
```

### Generated Code

Generated files (*.g.dart, *.freezed.dart) are handled automatically.
```

### 3. PRD 문서 업데이트
**파일**: `docs/PRD.md`

기존 문서에 v5.4 섹션 추가:

```markdown
## v5.4 - 구조 개선 및 온보딩 화면 완성

### 목표
1. 프로젝트 구조 개선 (에셋 중앙화, import 표준화)
2. 온보딩 플로우 완성 (Start 화면, Age Category 화면)
3. 아키텍처 문서화

### 구현 내용

#### 1. 구조 개선
- **에셋 중앙화**: 모든 에셋을 `pickly_design_system/assets/`로 이동
- **Import 표준화**: 상대 경로 → 절대 경로 변환 (`package:pickly_mobile/`)
- **컴포넌트 정리**: 공통 컴포넌트는 design system으로, 기능별 컴포넌트는 각 feature에

#### 2. 온보딩 화면
- **Start Screen**: 온보딩 시작 화면 (Step 1/5)
  - Welcome 메시지, 앱 소개
  - "시작하기" 버튼
- **Age Category Screen**: 연령대 선택 화면 (Step 3/5)
  - Supabase 연동 (age_categories 테이블)
  - 다중 선택 UI
  - Provider/Repository 패턴

#### 3. 문서화
- `docs/architecture/project-structure.md` - 프로젝트 구조 가이드
- `docs/architecture/import-conventions.md` - Import 컨벤션
- 위젯 테스트 작성 (80% 커버리지 목표)

### 기술 스택
- Flutter 3.35.4
- Riverpod (상태 관리)
- GoRouter (라우팅)
- Supabase (백엔드)
- Design System (공통 컴포넌트)

### 워크플로우
Claude Flow mesh 토폴로지 사용:
- Structure group (critical): asset-centralizer, import-path-fixer
- Development group (high): start-screen-builder, age-category-builder
- Docs group (medium): doc-writer, test-writer

### 성공 기준
- [ ] flutter analyze 통과
- [ ] flutter test 80% 이상 커버리지
- [ ] 시뮬레이터에서 온보딩 플로우 정상 동작
- [ ] 문서화 완료
```

## Outputs
- `docs/architecture/project-structure.md`
- `docs/architecture/import-conventions.md`
- `docs/PRD.md` (updated)

## Dependencies
- All other tasks (문서화는 구현 완료 후)

## Priority
Medium - 병렬 실행 가능

## Coordination
- Structure 및 Development group 결과 참조
- 실제 구현된 패턴을 문서에 반영
- 코드 예제는 실제 프로젝트에서 추출
