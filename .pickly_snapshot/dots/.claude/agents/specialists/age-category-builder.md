# Age Category Builder Agent

## Role
연령대 선택 화면 개선 전문가

## Goal
기존 `AgeCategoryScreen`을 완성하고 Supabase 연동, 상태 관리, 테스트를 구현합니다.

## Tasks

### 1. 현재 파일 분석
**파일**: `apps/pickly_mobile/lib/features/onboarding/screens/age_category_screen.dart`

현재 상태:
- ✅ UI 구조 완성 (header, list, progress bar, button)
- ✅ Provider 연동 (`ageCategoryProvider`)
- ⚠️ TODO: Save selection and navigate (line 35)
- ✅ Design system 컴포넌트 사용

### 2. Navigation 로직 완성
`_handleNext()` 메서드 구현:

```dart
Future<void> _handleNext() async {
  if (_selectedCategoryIds.isEmpty) return;

  try {
    // Save selection to user profile
    // TODO: Implement user profile update via repository
    // await ref.read(userProfileProvider.notifier)
    //   .updateAgeCategories(_selectedCategoryIds.toList());

    // For now, just navigate to next screen
    if (mounted) {
      context.go(Routes.income); // or next onboarding screen
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 중 오류가 발생했습니다: $e'),
          backgroundColor: StateColors.error,
        ),
      );
    }
  }
}
```

### 3. Provider 확인 및 개선
**파일**: `apps/pickly_mobile/lib/features/onboarding/providers/age_category_provider.dart`

Provider가 없으면 생성:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_mobile/contexts/user/repositories/age_category_repository.dart';

part 'age_category_provider.g.dart';

@riverpod
class AgeCategoryController extends _$AgeCategoryController {
  @override
  Future<List<AgeCategory>> build() async {
    final repository = ref.watch(ageCategoryRepositoryProvider);
    return repository.fetchActiveCategories();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(ageCategoryRepositoryProvider);
      return repository.fetchActiveCategories();
    });
  }
}

@riverpod
AgeCategoryRepository ageCategoryRepository(AgeCategoryRepositoryRef ref) {
  return AgeCategoryRepository();
}
```

### 4. Repository 확인
**파일**: `apps/pickly_mobile/lib/contexts/user/repositories/age_category_repository.dart`

이미 구현되어 있음:
- ✅ `fetchActiveCategories()`
- ✅ `fetchCategoryById()`
- ✅ `validateCategoryIds()`
- ✅ Realtime subscriptions

### 5. 위젯 테스트 작성
**파일**: `apps/pickly_mobile/test/features/onboarding/screens/age_category_screen_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_mobile/features/onboarding/screens/age_category_screen.dart';
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_mobile/features/onboarding/providers/age_category_provider.dart';

void main() {
  group('AgeCategoryScreen', () {
    final mockCategories = [
      AgeCategory(
        id: '1',
        title: '영유아',
        description: '0-7세',
        iconUrl: 'icon1.svg',
        sortOrder: 1,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      AgeCategory(
        id: '2',
        title: '청소년',
        description: '8-18세',
        iconUrl: 'icon2.svg',
        sortOrder: 2,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    testWidgets('displays loading indicator initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ageCategoryProvider.overrideWith(
              (ref) => Future.delayed(const Duration(seconds: 1), () => mockCategories),
            ),
          ],
          child: const MaterialApp(
            home: AgeCategoryScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays categories when loaded', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ageCategoryProvider.overrideWith((ref) => Future.value(mockCategories)),
          ],
          child: const MaterialApp(
            home: AgeCategoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('영유아'), findsOneWidget);
      expect(find.text('청소년'), findsOneWidget);
    });

    testWidgets('next button is disabled when no selection', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ageCategoryProvider.overrideWith((ref) => Future.value(mockCategories)),
          ],
          child: const MaterialApp(
            home: AgeCategoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final button = find.widgetWithText(ElevatedButton, '다음');
      final elevatedButton = tester.widget<ElevatedButton>(button);
      expect(elevatedButton.onPressed, isNull);
    });

    testWidgets('next button is enabled after selection', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ageCategoryProvider.overrideWith((ref) => Future.value(mockCategories)),
          ],
          child: const MaterialApp(
            home: AgeCategoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap first category
      await tester.tap(find.text('영유아'));
      await tester.pumpAndSettle();

      // Button should be enabled
      final button = find.widgetWithText(ElevatedButton, '다음');
      final elevatedButton = tester.widget<ElevatedButton>(button);
      expect(elevatedButton.onPressed, isNotNull);
    });
  });
}
```

### 6. 검증
```bash
flutter pub get
flutter pub run build_runner build # Generate provider code
flutter analyze
flutter test test/features/onboarding/screens/age_category_screen_test.dart
```

## Outputs
- `apps/pickly_mobile/lib/features/onboarding/screens/age_category_screen.dart` (updated)
- `apps/pickly_mobile/lib/features/onboarding/providers/age_category_provider.dart` (created if missing)
- `apps/pickly_mobile/test/features/onboarding/screens/age_category_screen_test.dart`

## Dependencies
- `import-path-fixer` - import 경로가 표준화되어야 함
- Supabase setup in `main.dart`
- Repository already exists

## Priority
High - 온보딩 플로우의 핵심 화면

## Coordination
- Structure group 완료 후 시작
- Repository layer 사용
- 상태 관리 패턴을 memory에 저장 (다른 화면 참고용)

## Key Improvements
1. ✅ Complete navigation logic
2. ✅ Provider implementation with Riverpod
3. ✅ Error handling and loading states
4. ✅ Widget tests with mocked data
5. ✅ Accessibility (semantic labels)
6. ✅ Design system consistency
