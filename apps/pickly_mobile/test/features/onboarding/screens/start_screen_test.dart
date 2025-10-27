import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/features/onboarding/screens/start_screen.dart';
import 'package:pickly_mobile/core/router.dart';

void main() {
  group('StartScreen', () {
    testWidgets('renders all required elements', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: StartScreen(),
        ),
      );

      // Assert - 환영 메시지 텍스트 확인
      expect(find.text('피클리에 오신 것을 환영합니다'), findsOneWidget);

      // Assert - 설명 텍스트 확인
      expect(
        find.text('나에게 딱 맞는 정책과 혜택을\n쉽고 빠르게 찾아보세요'),
        findsOneWidget,
      );

      // Assert - 시작하기 버튼 확인
      expect(find.text('시작하기'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('start button is enabled', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: StartScreen(),
        ),
      );

      // Assert - 버튼이 활성화되어 있는지 확인
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('start button has correct styling', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: StartScreen(),
        ),
      );

      // Assert - 버튼 스타일 확인
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      final buttonStyle = button.style!;

      // 배경색 확인
      expect(
        buttonStyle.backgroundColor?.resolve({}),
        BrandColors.primary,
      );

      // 전경색(텍스트 색상) 확인
      expect(
        buttonStyle.foregroundColor?.resolve({}),
        Colors.white,
      );
    });

    testWidgets('uses correct background color', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: StartScreen(),
        ),
      );

      // Assert - Scaffold 배경색 확인
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, BackgroundColors.app);
    });

    testWidgets('has proper spacing and layout', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: StartScreen(),
        ),
      );

      // Assert - SafeArea 존재 확인
      expect(find.byType(SafeArea), findsOneWidget);

      // Assert - Column with spaceBetween 확인
      final column = tester.widget<Column>(
        find.descendant(
          of: find.byType(SafeArea),
          matching: find.byType(Column),
        ).first,
      );
      expect(column.mainAxisAlignment, MainAxisAlignment.spaceBetween);
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
    });

    testWidgets('button has correct dimensions', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: StartScreen(),
        ),
      );

      // Assert - 버튼 크기 확인
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.width, double.infinity);
      expect(sizedBox.height, 56);
    });

    testWidgets('button navigates to personal info screen when tapped',
        (WidgetTester tester) async {
      // Arrange - Create mock GoRouter
      final mockGoRouter = GoRouter(
        routes: [
          GoRoute(
            path: '/',
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
          routerConfig: mockGoRouter,
        ),
      );

      // Assert - 시작 화면이 렌더링되었는지 확인
      expect(find.text('피클리에 오신 것을 환영합니다'), findsOneWidget);

      // Act - 시작하기 버튼 탭
      await tester.tap(find.text('시작하기'));
      await tester.pumpAndSettle();

      // Assert - Personal Info 화면으로 이동했는지 확인
      expect(find.text('Personal Info Screen'), findsOneWidget);
      expect(find.text('피클리에 오신 것을 환영합니다'), findsNothing);
    });

    testWidgets('uses correct typography styles', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: StartScreen(),
        ),
      );

      // Assert - 환영 메시지 스타일 확인
      final welcomeText =
          tester.widget<Text>(find.text('피클리에 오신 것을 환영합니다'));
      expect(welcomeText.style?.color, BrandColors.primary);

      // Assert - 설명 텍스트 스타일 확인
      final descText =
          tester.widget<Text>(find.text('나에게 딱 맞는 정책과 혜택을\n쉽고 빠르게 찾아보세요'));
      expect(descText.style?.color, TextColors.secondary);
    });

    testWidgets('button text uses correct typography',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: StartScreen(),
        ),
      );

      // Find the button's Text widget
      final buttonTextFinder = find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.text('시작하기'),
      );
      expect(buttonTextFinder, findsOneWidget);

      final buttonText = tester.widget<Text>(buttonTextFinder);
      expect(buttonText.style?.color, Colors.white);
    });

    testWidgets('has proper padding and safe area', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: StartScreen(),
        ),
      );

      // Assert - SafeArea 존재 확인
      expect(find.byType(SafeArea), findsOneWidget);

      // Assert - Padding 존재 확인 (EdgeInsets.all is const EdgeInsets but stored differently)
      final paddingWidgets = find.descendant(
        of: find.byType(SafeArea),
        matching: find.byType(Padding),
      );
      expect(paddingWidgets, findsWidgets);
    });
  });
}
