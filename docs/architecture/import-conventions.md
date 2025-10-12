# Import 규칙 및 Best Practices

> **마지막 업데이트**: 2025.10.12 (v5.4)
> **대상 독자**: 모든 개발자

---

## 📌 목차

1. [개요](#개요)
2. [절대 경로 vs 상대 경로](#절대-경로-vs-상대-경로)
3. [Import 순서](#import-순서)
4. [올바른 Import 예시](#올바른-import-예시)
5. [Asset Import 패턴](#asset-import-패턴)
6. [절대 경로의 이점](#절대-경로의-이점)
7. [예외 사항](#예외-사항)
8. [자동화 도구](#자동화-도구)

---

## 개요

Pickly 프로젝트는 **절대 경로 Import**를 필수로 사용합니다. 이는 코드의 가독성, 유지보수성, 리팩토링 용이성을 높이기 위한 중요한 규칙입니다.

### 핵심 규칙

1. ✅ **절대 경로 사용 필수**: `package:pickly_mobile/...` 형식만 허용
2. ❌ **상대 경로 사용 금지**: `../`, `../../` 등 사용 불가
3. 📋 **표준 Import 순서 준수**: Dart SDK → Flutter → 외부 패키지 → 내부 패키지 순서
4. 🎯 **명확한 경로**: 파일 위치가 명확하게 드러나야 함

---

## 절대 경로 vs 상대 경로

### ✅ 절대 경로 (Absolute Import) - 필수

절대 경로는 `package:` 접두사를 사용하여 프로젝트 루트부터 전체 경로를 명시합니다.

```dart
// ✅ 올바른 예시: 절대 경로
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_mobile/features/onboarding/screens/age_category_screen.dart';
import 'package:pickly_design_system/widgets/buttons/pickly_button.dart';
```

**장점**:
- 파일 위치를 명확하게 파악 가능
- IDE 자동 완성 및 리팩토링 도구와 호환
- 파일 이동 시 경로 변경 최소화
- 의존성 관계를 명확하게 표현

### ❌ 상대 경로 (Relative Import) - 금지

상대 경로는 `../`, `./` 등을 사용하여 현재 파일 기준으로 경로를 지정합니다.

```dart
// ❌ 잘못된 예시: 상대 경로 (사용 금지!)
import '../models/age_category.dart';
import '../../contexts/user/models/user_profile.dart';
import './widgets/onboarding_header.dart';
```

**단점**:
- 파일 이동 시 모든 import 경로 수정 필요
- 파일 실제 위치 파악 어려움
- IDE 리팩토링 도구가 제대로 작동하지 않을 수 있음
- 코드 리뷰 시 의존성 파악 어려움

---

## Import 순서

### 표준 Import 순서 (6단계)

Dart 공식 스타일 가이드를 따라 다음 순서로 import를 작성합니다:

```dart
// 1. Dart SDK (dart:로 시작)
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// 2. Flutter SDK (package:flutter/로 시작)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. 외부 패키지 (pub.dev 패키지)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 4. Design System (공유 패키지)
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_design_system/widgets/buttons/pickly_button.dart';
import 'package:pickly_design_system/widgets/cards/selection_list_item.dart';

// 5. Contexts (도메인 모델 및 Repository)
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_mobile/contexts/user/models/user_profile.dart';
import 'package:pickly_mobile/contexts/user/repositories/age_category_repository.dart';

// 6. Features 및 Core (앱 내부 코드)
import 'package:pickly_mobile/core/router.dart';
import 'package:pickly_mobile/core/theme/theme.dart';
import 'package:pickly_mobile/features/onboarding/providers/age_category_provider.dart';
import 'package:pickly_mobile/features/onboarding/widgets/onboarding_header.dart';
```

### Import 그룹 간 공백

각 그룹 사이에는 **빈 줄 하나**를 추가하여 가독성을 높입니다.

```dart
import 'dart:async';        // Dart SDK

import 'package:flutter/material.dart';  // Flutter SDK

import 'package:riverpod/riverpod.dart'; // 외부 패키지

import 'package:pickly_design_system/pickly_design_system.dart'; // Design System

import 'package:pickly_mobile/contexts/user/models/age_category.dart'; // Contexts

import 'package:pickly_mobile/features/onboarding/screens/splash_screen.dart'; // Features
```

### 그룹 내 알파벳 순서

같은 그룹 내에서는 **알파벳 순서**로 정렬합니다.

```dart
// ✅ 올바른 예시: 알파벳 순서
import 'package:pickly_mobile/contexts/policy/models/policy.dart';
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_mobile/contexts/user/models/user_profile.dart';

// ❌ 잘못된 예시: 순서 없음
import 'package:pickly_mobile/contexts/user/models/user_profile.dart';
import 'package:pickly_mobile/contexts/policy/models/policy.dart';
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
```

---

## 올바른 Import 예시

### 예시 1: Screen 파일

```dart
// lib/features/onboarding/screens/age_category_screen.dart

// 1. Dart SDK
import 'dart:async';

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 3. 외부 패키지
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 4. Design System
import 'package:pickly_design_system/pickly_design_system.dart';

// 5. Contexts
import 'package:pickly_mobile/contexts/user/models/age_category.dart';

// 6. Features/Core
import 'package:pickly_mobile/features/onboarding/providers/age_category_provider.dart';
import 'package:pickly_mobile/features/onboarding/widgets/onboarding_header.dart';

class AgeCategoryScreen extends ConsumerWidget {
  const AgeCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ...
  }
}
```

### 예시 2: Provider 파일

```dart
// lib/features/onboarding/providers/age_category_provider.dart

// 2. Flutter SDK
import 'package:flutter/foundation.dart';

// 3. 외부 패키지
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 5. Contexts
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_mobile/contexts/user/repositories/age_category_repository.dart';

// 6. Core
import 'package:pickly_mobile/core/services/supabase_service.dart';

part 'age_category_provider.g.dart';

@riverpod
class AgeCategory extends _$AgeCategory {
  // ...
}
```

### 예시 3: Repository 파일

```dart
// lib/contexts/user/repositories/age_category_repository.dart

// 1. Dart SDK
import 'dart:async';

// 3. 외부 패키지
import 'package:supabase_flutter/supabase_flutter.dart';

// 5. Contexts (같은 Context 내 모델)
import 'package:pickly_mobile/contexts/user/models/age_category.dart';

class AgeCategoryRepository {
  final SupabaseClient _supabase;

  AgeCategoryRepository(this._supabase);

  Future<List<AgeCategory>> fetchCategories() async {
    // ...
  }
}
```

### 예시 4: Widget 파일

```dart
// lib/features/onboarding/widgets/onboarding_header.dart

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 4. Design System
import 'package:pickly_design_system/pickly_design_system.dart';

class OnboardingHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool showBackButton;
  final VoidCallback? onBack;

  const OnboardingHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

---

## Asset Import 패턴

### 1. Design System Assets

Design System의 에셋은 패키지 경로를 사용합니다.

```dart
// ✅ 올바른 예시: Design System 아이콘
Image.asset(
  'packages/pickly_design_system/assets/icons/age_categories/teen.svg',
  package: 'pickly_design_system',
)

// ✅ 올바른 예시: Design System 이미지
Image.asset(
  'assets/images/logo.png',
  package: 'pickly_design_system',
)
```

### 2. 앱 전용 Assets

앱 내부 에셋은 상대 경로를 사용합니다.

```dart
// ✅ 올바른 예시: 앱 전용 이미지
Image.asset('assets/images/onboarding_bg.png')

// ✅ 올바른 예시: 환경 변수 파일
await dotenv.load(fileName: '.env');
```

### 3. SVG 파일

SVG 파일은 `flutter_svg` 패키지를 사용합니다.

```dart
import 'package:flutter_svg/flutter_svg.dart';

// ✅ Design System SVG
SvgPicture.asset(
  'assets/icons/age_categories/teen.svg',
  package: 'pickly_design_system',
  width: 24,
  height: 24,
)

// ✅ 앱 전용 SVG
SvgPicture.asset(
  'assets/icons/custom_icon.svg',
  width: 24,
  height: 24,
)
```

### 4. 네트워크 이미지

Supabase Storage 등 외부 URL의 이미지는 `Image.network` 사용:

```dart
// ✅ 올바른 예시: 네트워크 이미지
Image.network(
  'https://your-supabase-url.supabase.co/storage/v1/object/public/icons/teen.png',
  width: 24,
  height: 24,
)

// ✅ 캐싱 포함
CachedNetworkImage(
  imageUrl: category.iconUrl,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

---

## 절대 경로의 이점

### 1. 명확한 의존성 파악

```dart
// ✅ 절대 경로: 파일 위치 명확
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
// → "contexts/user/models 폴더의 age_category.dart" 명확

// ❌ 상대 경로: 파일 위치 불명확
import '../../contexts/user/models/age_category.dart';
// → 현재 파일이 어디에 있는지 알아야 경로 파악 가능
```

### 2. 리팩토링 용이성

**시나리오**: `age_category_screen.dart`를 `features/onboarding/screens/`에서 `features/onboarding/pages/`로 이동

```dart
// ✅ 절대 경로: import 경로 변경 불필요
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
// → 파일 이동해도 import 경로는 그대로

// ❌ 상대 경로: 모든 import 수정 필요
import '../../../contexts/user/models/age_category.dart';
// → 파일 이동 시 모든 상대 경로 재계산 필요
```

### 3. IDE 지원

대부분의 IDE(VS Code, Android Studio, IntelliJ)는 절대 경로에 대해 더 나은 지원을 제공합니다:

- **자동 완성**: `package:`를 입력하면 전체 프로젝트 구조 표시
- **정의로 이동** (Go to Definition): Cmd+Click으로 파일 즉시 이동
- **사용처 찾기** (Find Usages): 모든 사용처 정확히 검색
- **자동 리팩토링**: 파일 이름 변경 시 모든 import 자동 업데이트

### 4. 코드 리뷰 효율성

```dart
// ✅ 절대 경로: 리뷰어가 즉시 의존성 파악 가능
import 'package:pickly_mobile/contexts/user/repositories/user_repository.dart';
// → "User Context의 Repository를 사용하는구나"

// ❌ 상대 경로: 리뷰어가 파일 위치 추적 필요
import '../../../contexts/user/repositories/user_repository.dart';
// → "현재 파일이 어디인지 먼저 파악해야 함"
```

### 5. 린트 및 정적 분석

Dart 린터는 절대 경로를 선호하며, 많은 정적 분석 도구가 절대 경로를 기반으로 작동합니다.

```yaml
# analysis_options.yaml
linter:
  rules:
    - prefer_relative_imports: false  # 상대 경로 사용 금지
    - always_use_package_imports: true # 절대 경로 강제
```

---

## 예외 사항

### 1. Generated 파일 (`.g.dart`, `.freezed.dart`)

Code Generation으로 생성된 파일은 `part` 지시자를 사용합니다.

```dart
// lib/features/onboarding/providers/age_category_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pickly_mobile/contexts/user/models/age_category.dart';

// ✅ 예외: Generated 파일은 part 사용
part 'age_category_provider.g.dart';

@riverpod
class AgeCategory extends _$AgeCategory {
  // ...
}
```

### 2. 테스트 파일의 Helper 모듈

테스트 파일 간 Helper 모듈은 상대 경로 허용 (선택적):

```dart
// test/helpers/mock_data.dart
const mockCategories = [...];

// test/features/onboarding/screens/age_category_screen_test.dart

// ✅ 허용: 테스트 헬퍼는 상대 경로 가능 (선택적)
import '../../../helpers/mock_data.dart';

// ✅ 권장: 테스트 헬퍼도 절대 경로 권장
import 'package:pickly_mobile/test/helpers/mock_data.dart';
```

### 3. 배럴 파일 (Barrel File)

같은 폴더 내 여러 위젯을 export하는 배럴 파일:

```dart
// lib/features/onboarding/widgets/widgets.dart

// ✅ 허용: 배럴 파일 내부는 상대 경로 가능
export 'onboarding_header.dart';
export 'selection_list_item.dart';

// 사용처에서는 배럴 파일 import
import 'package:pickly_mobile/features/onboarding/widgets/widgets.dart';
```

---

## 자동화 도구

### 1. VS Code 설정

`.vscode/settings.json`에 다음 설정 추가:

```json
{
  "dart.autoImportCompletions": true,
  "dart.autoUpdateImports": true,
  "editor.codeActionsOnSave": {
    "source.organizeImports": true
  },
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.rulers": [80]
  }
}
```

### 2. Import 자동 정렬

파일 저장 시 자동으로 import를 정렬하도록 설정:

```bash
# 수동으로 import 정렬
flutter format lib/

# 특정 파일만 정렬
flutter format lib/features/onboarding/screens/age_category_screen.dart
```

### 3. 린트 규칙

`analysis_options.yaml`에 import 규칙 추가:

```yaml
analyzer:
  errors:
    always_use_package_imports: error
    avoid_relative_lib_imports: error

linter:
  rules:
    # Import 관련
    - always_use_package_imports      # 절대 경로 강제
    - avoid_relative_lib_imports      # 상대 경로 금지
    - directives_ordering             # Import 순서 강제

    # 일반 규칙
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
```

### 4. Pre-commit Hook

Git commit 전에 자동으로 import 체크:

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Import 규칙 검사
flutter analyze --no-pub

if [ $? -ne 0 ]; then
  echo "❌ Import 규칙 위반이 발견되었습니다. 수정 후 다시 커밋하세요."
  exit 1
fi

echo "✅ Import 규칙 검사 통과"
```

### 5. IDE 확장 프로그램

**VS Code**:
- **Dart**: 공식 Dart 확장
- **Flutter**: 공식 Flutter 확장
- **Dart Import Sorter**: Import 자동 정렬

**Android Studio / IntelliJ**:
- **Flutter Plugin**: 공식 플러그인
- **Save Actions**: 저장 시 자동 포맷

---

## 실전 팁

### 1. 새 파일 생성 시

새 파일을 생성할 때 IDE의 자동 완성을 활용하세요:

```dart
// 1. "import" 입력
// 2. "package:" 입력
// 3. IDE 자동 완성으로 경로 선택
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
```

### 2. 기존 상대 경로를 절대 경로로 변환

**수동 변환**:
```dart
// Before
import '../models/age_category.dart';

// After
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
```

**자동 변환** (VS Code):
1. 상대 경로에 커서 위치
2. `Cmd+.` (Quick Fix)
3. "Convert to absolute import" 선택

### 3. 순환 참조 방지

절대 경로를 사용하면 순환 참조를 쉽게 발견할 수 있습니다:

```dart
// lib/contexts/user/models/user.dart
import 'package:pickly_mobile/contexts/policy/models/policy.dart'; // User → Policy

// lib/contexts/policy/models/policy.dart
import 'package:pickly_mobile/contexts/user/models/user.dart'; // Policy → User

// ⚠️ 순환 참조 발견! 설계 수정 필요
```

---

## 체크리스트

코드 작성 시 다음 사항을 확인하세요:

- [ ] 모든 import가 `package:` 형식의 절대 경로인가?
- [ ] Import 순서가 표준을 따르는가? (Dart SDK → Flutter → 외부 → Design System → Contexts → Features)
- [ ] 그룹 간 빈 줄이 추가되었는가?
- [ ] 같은 그룹 내에서 알파벳 순서로 정렬되었는가?
- [ ] 사용하지 않는 import는 제거되었는가?
- [ ] Asset 경로가 올바른가? (Design System은 `package:`, 앱 전용은 상대 경로)

---

## 참고 자료

- [Effective Dart: Style](https://dart.dev/guides/language/effective-dart/style#ordering)
- [Flutter Style Guide](https://flutter.dev/docs/development/tools/formatting)
- [Dart Linter Rules](https://dart.dev/tools/linter-rules)

---

## 변경 이력

### v5.4 (2025.10.12)
- Import 규칙 상세 문서 신규 작성
- 절대 경로 vs 상대 경로 비교 추가
- Asset import 패턴 추가
- 자동화 도구 가이드 추가
- 실전 팁 및 체크리스트 포함

---

✍️ 이 문서는 Pickly Mobile 프로젝트의 Import 규칙을 설명합니다.
모든 개발자는 본 문서의 규칙을 준수해야 합니다.
