# Start Screen Builder Agent

## Role
온보딩 시작 화면 개발 전문가

## Goal
Figma 디자인을 기반으로 온보딩 시작 화면(`StartScreen`)을 구현합니다.

## Tasks

### 1. 디자인 스펙 분석
Figma에서 확인할 사항:
- 화면 레이아웃 (SafeArea, padding, spacing)
- 텍스트 스타일 (폰트, 크기, 색상, 정렬)
- 버튼 스타일 (크기, 색상, border radius)
- 이미지/아이콘 위치 및 크기
- 애니메이션 요구사항

### 2. 파일 생성
**파일**: `apps/pickly_mobile/lib/features/onboarding/screens/start_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/core/router.dart';

/// Onboarding start screen (Step 1/5)
///
/// Welcome screen with app introduction and "시작하기" button
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void _handleStart(BuildContext context) {
    // Navigate to next screen (PersonalInfoScreen)
    context.go(Routes.personalInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColors.app,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top content (logo, title, description)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TODO: Add logo/illustration from design system
                    // Image.asset('packages/pickly_design_system/assets/images/onboarding_start.png')

                    const SizedBox(height: Spacing.xxl),

                    Text(
                      '피클리에 오신 것을 환영합니다',
                      style: PicklyTypography.titleLarge.copyWith(
                        color: TextColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: Spacing.md),

                    Text(
                      '나에게 딱 맞는 정책과 혜택을\n쉽고 빠르게 찾아보세요',
                      style: PicklyTypography.bodyLarge.copyWith(
                        color: TextColors.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Bottom button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _handleStart(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    '시작하기',
                    style: PicklyTypography.buttonLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 3. 라우터 등록
`apps/pickly_mobile/lib/core/router.dart`에 라우트 추가 (manual step에서 처리됨)

### 4. 위젯 테스트 작성
**파일**: `apps/pickly_mobile/test/features/onboarding/screens/start_screen_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickly_mobile/features/onboarding/screens/start_screen.dart';

void main() {
  group('StartScreen', () {
    testWidgets('renders welcome text and start button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StartScreen(),
        ),
      );

      expect(find.text('피클리에 오신 것을 환영합니다'), findsOneWidget);
      expect(find.text('시작하기'), findsOneWidget);
    });

    testWidgets('start button is enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StartScreen(),
        ),
      );

      final button = find.widgetWithText(ElevatedButton, '시작하기');
      expect(button, findsOneWidget);

      final elevatedButton = tester.widget<ElevatedButton>(button);
      expect(elevatedButton.onPressed, isNotNull);
    });
  });
}
```

### 5. 검증
```bash
flutter analyze
flutter test test/features/onboarding/screens/start_screen_test.dart
flutter run # Visual check
```

## Outputs
- `apps/pickly_mobile/lib/features/onboarding/screens/start_screen.dart`
- `apps/pickly_mobile/test/features/onboarding/screens/start_screen_test.dart`

## Dependencies
- `import-path-fixer` - import 경로가 표준화되어야 함
- `asset-centralizer` - 에셋 경로가 정리되어야 함

## Priority
High - 온보딩 플로우의 첫 화면

## Coordination
- Structure group 완료 후 시작
- Design system 컴포넌트 사용
- Router 정보를 memory에 저장 (manual step 참고용)

## Design System Components to Use
- `BackgroundColors.app`
- `TextColors.primary`, `TextColors.secondary`
- `PicklyTypography.titleLarge`, `PicklyTypography.bodyLarge`
- `BrandColors.primary`
- `Spacing.xl`, `Spacing.xxl`, `Spacing.md`
