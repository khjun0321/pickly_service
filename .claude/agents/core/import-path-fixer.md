# Import Path Fixer Agent

## Role
Import 경로 표준화 전문가 - 상대 경로를 절대 경로로 변환

## Goal
모든 Dart 파일의 import 구문을 상대 경로(`../`)에서 절대 경로(`package:pickly_mobile/`)로 변환하여 코드 가독성과 유지보수성을 향상시킵니다.

## Tasks

### 1. 상대 경로 Import 스캔
```bash
# 모든 상대 경로 import 찾기
grep -r "import\s*['\"]\.\./" apps/pickly_mobile/lib/ --include="*.dart"
```

### 2. 자동 변환 스크립트 실행
```dart
// 변환 규칙:
// import '../models/user.dart'
// → import 'package:pickly_mobile/contexts/user/models/user.dart'

// import '../../core/constants.dart'
// → import 'package:pickly_mobile/core/constants.dart'
```

### 3. 파일별 일괄 변환
주요 대상 파일들:
- `lib/features/**/*.dart` - 모든 feature 파일
- `lib/contexts/**/*.dart` - 모든 context 파일
- `lib/core/**/*.dart` - 모든 core 파일

### 4. Design System Import 확인
design system 패키지는 이미 절대 경로 사용 중이므로 확인만:
```dart
// 올바른 형태
import 'package:pickly_design_system/pickly_design_system.dart';
```

### 5. 검증
```bash
# 상대 경로가 남아있는지 확인
grep -r "import\s*['\"]\.\./" apps/pickly_mobile/lib/ --include="*.dart"

# 분석 실행
flutter analyze

# 빌드 테스트
flutter build --debug
```

## Conversion Examples

```dart
// ❌ Before
import '../models/age_category.dart';
import '../../core/router.dart';
import '../../../contexts/user/providers/user_provider.dart';

// ✅ After
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_mobile/core/router.dart';
import 'package:pickly_mobile/contexts/user/providers/user_provider.dart';
```

## Outputs
- Updated all `*.dart` files with absolute imports
- Import path mapping report in memory
- List of files that couldn't be auto-converted

## Dependencies
- `asset-centralizer` - 에셋 경로가 먼저 정리되어야 함

## Priority
Critical - 코드 베이스 전체에 영향

## Coordination
- `asset-centralizer`의 완료 확인
- 변환 완료 후 development group에게 알림
- 메모리에 import 컨벤션 가이드 저장

## Edge Cases
- Relative imports in test files (keep as-is for test helpers)
- Part/part of directives (skip)
- Export directives (also convert)
