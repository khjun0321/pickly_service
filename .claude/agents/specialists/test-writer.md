# Test Writer Agent

## Role
위젯 테스트 작성 전문가

## Goal
새로 구현된 온보딩 화면들의 위젯 테스트를 작성하여 80% 이상의 코드 커버리지를 달성합니다.

## Tasks

### 1. Start Screen 테스트
**파일**: `apps/pickly_mobile/test/features/onboarding/screens/start_screen_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_mobile/features/onboarding/screens/start_screen.dart';
import 'package:pickly_mobile/core/router.dart';

void main() {
  group('StartScreen', () {
    testWidgets('renders all required elements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StartScreen(),
        ),
      );

      // Check for welcome text
      expect(find.text('피클리에 오신 것을 환영합니다'), findsOneWidget);

      // Check for description
      expect(find.textContaining('나에게 딱 맞는 정책과 혜택'), findsOneWidget);

      // Check for start button
      expect(find.text('시작하기'), findsOneWidget);
    });

    testWidgets('start button is always enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StartScreen(),
        ),
      );

      final button = find.widgetWithText(ElevatedButton, '시작하기');
      expect(button, findsOneWidget);

      final elevatedButton = tester.widget<ElevatedButton>(button);
      expect(elevatedButton.onPressed, isNotNull);
    });

    testWidgets('navigates to next screen on button tap', (tester) async {
      final router = GoRouter(
        initialLocation: Routes.onboardingStart,
        routes: [
          GoRoute(
            path: Routes.onboardingStart,
            builder: (context, state) => const StartScreen(),
          ),
          GoRoute(
            path: Routes.personalInfo,
            builder: (context, state) => const Scaffold(
              body: Text('Personal Info Screen'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Tap start button
      await tester.tap(find.text('시작하기'));
      await tester.pumpAndSettle();

      // Verify navigation
      expect(find.text('Personal Info Screen'), findsOneWidget);
    });

    testWidgets('has correct background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StartScreen(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNotNull);
    });

    testWidgets('button has correct styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StartScreen(),
        ),
      );

      final button = find.widgetWithText(ElevatedButton, '시작하기');
      final elevatedButton = tester.widget<ElevatedButton>(button);

      expect(elevatedButton.style, isNotNull);
    });
  });
}
```

### 2. Age Category Screen 테스트
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
      AgeCategory(
        id: '3',
        title: '청년',
        description: '19-34세',
        iconUrl: 'icon3.svg',
        sortOrder: 3,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    testWidgets('displays loading indicator initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ageCategoryProvider.overrideWith(
              (ref) => Future.delayed(
                const Duration(milliseconds: 100),
                () => mockCategories,
              ),
            ),
          ],
          child: const MaterialApp(
            home: AgeCategoryScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays categories after loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ageCategoryProvider.overrideWith(
              (ref) => Future.value(mockCategories),
            ),
          ],
          child: const MaterialApp(
            home: AgeCategoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('영유아'), findsOneWidget);
      expect(find.text('청소년'), findsOneWidget);
      expect(find.text('청년'), findsOneWidget);
    });

    testWidgets('next button is disabled when no selection', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ageCategoryProvider.overrideWith(
              (ref) => Future.value(mockCategories),
            ),
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

    testWidgets('can select category', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ageCategoryProvider.overrideWith(
              (ref) => Future.value(mockCategories),
            ),
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

      // Button should now be enabled
      final button = find.widgetWithText(ElevatedButton, '다음');
      final elevatedButton = tester.widget<ElevatedButton>(button);
      expect(elevatedButton.onPressed, isNotNull);
    });

    testWidgets('can select multiple categories', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ageCategoryProvider.overrideWith(
              (ref) => Future.value(mockCategories),
            ),
          ],
          child: const MaterialApp(
            home: AgeCategoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Select multiple categories
      await tester.tap(find.text('영유아'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('청소년'));
      await tester.pumpAndSettle();

      // Both should be selected (verify via button still enabled)
      final button = find.widgetWithText(ElevatedButton, '다음');
      final elevatedButton = tester.widget<ElevatedButton>(button);
      expect(elevatedButton.onPressed, isNotNull);
    });

    testWidgets('can deselect category', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ageCategoryProvider.overrideWith(
              (ref) => Future.value(mockCategories),
            ),
          ],
          child: const MaterialApp(
            home: AgeCategoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Select then deselect
      await tester.tap(find.text('영유아'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('영유아'));
      await tester.pumpAndSettle();

      // Button should be disabled again
      final button = find.widgetWithText(ElevatedButton, '다음');
      final elevatedButton = tester.widget<ElevatedButton>(button);
      expect(elevatedButton.onPressed, isNull);
    });

    testWidgets('displays error state on failure', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ageCategoryProvider.overrideWith(
              (ref) => Future.error('Network error'),
            ),
          ],
          child: const MaterialApp(
            home: AgeCategoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('데이터를 불러오는 데 실패했습니다'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
    });

    testWidgets('displays progress bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ageCategoryProvider.overrideWith(
              (ref) => Future.value(mockCategories),
            ),
          ],
          child: const MaterialApp(
            home: AgeCategoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays onboarding header', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ageCategoryProvider.overrideWith(
              (ref) => Future.value(mockCategories),
            ),
          ],
          child: const MaterialApp(
            home: AgeCategoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Header should be present (contains back button and step indicator)
      expect(find.byType(IconButton), findsWidgets);
    });
  });
}
```

### 3. 테스트 실행 및 커버리지 확인
```bash
# 개별 테스트 실행
flutter test test/features/onboarding/screens/start_screen_test.dart
flutter test test/features/onboarding/screens/age_category_screen_test.dart

# 전체 테스트 실행
flutter test

# 커버리지 확인
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 4. Golden 테스트 (Optional)
```dart
// Golden tests for visual regression
testWidgets('start screen golden test', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: StartScreen(),
    ),
  );

  await expectLater(
    find.byType(StartScreen),
    matchesGoldenFile('goldens/start_screen.png'),
  );
});
```

## Outputs
- `apps/pickly_mobile/test/features/onboarding/screens/start_screen_test.dart`
- `apps/pickly_mobile/test/features/onboarding/screens/age_category_screen_test.dart`
- Test coverage report

## Dependencies
- `start-screen-builder` - StartScreen 구현 완료 필요
- `age-category-builder` - AgeCategoryScreen 구현 완료 필요

## Priority
Medium - Development group과 병렬 실행 가능 (완료 후 실행)

## Coordination
- Development group 완료 대기
- 실제 구현된 화면 기반으로 테스트 작성
- 80% 커버리지 목표 달성
- Test 패턴을 memory에 저장 (다른 화면 테스트 참고용)

## Test Coverage Goals
- **Start Screen**: 90%+ (simple screen)
- **Age Category Screen**: 85%+ (more complex with state)
- **Overall onboarding**: 80%+

## Test Types
1. **Widget tests**: UI rendering and interaction
2. **Provider tests**: State management logic
3. **Integration tests**: Full flow navigation (optional)
4. **Golden tests**: Visual regression (optional)
