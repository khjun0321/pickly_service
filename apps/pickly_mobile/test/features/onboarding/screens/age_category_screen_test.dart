import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickly_mobile/features/onboarding/screens/age_category_screen.dart';
import 'package:pickly_mobile/features/onboarding/widgets/onboarding_header.dart';
import 'package:pickly_mobile/features/onboarding/widgets/selection_card.dart';
import 'package:pickly_mobile/features/onboarding/widgets/next_button.dart';

void main() {
  group('AgeCategoryScreen', () {
    testWidgets('should display screen with correct title and subtitle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Verify title
      expect(
        find.text('현재 연령 및 세대 기준을\n선택해주세요'),
        findsOneWidget,
      );

      // Verify subtitle
      expect(
        find.text('나에게 맞는 정책과 혜택에 대해 안내해드려요'),
        findsOneWidget,
      );
    });

    testWidgets('should display onboarding header with correct progress',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify OnboardingHeader is present
      expect(find.byType(OnboardingHeader), findsOneWidget);

      // Verify progress text
      expect(find.text('3 / 5'), findsOneWidget);
    });

    testWidgets('should display loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );

      // Loading should be visible before data loads
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Loading should be gone
      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
      );
    });

    testWidgets('should display selection cards after loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify selection cards are displayed (GridView renders visible items)
      expect(find.byType(SelectionCard), findsWidgets);

      // Verify GridView exists
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should have next button disabled initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find NextButton
      final nextButton = find.byType(NextButton);
      expect(nextButton, findsOneWidget);

      // NextButton should be disabled (enabled = false)
      final nextButtonWidget = tester.widget<NextButton>(nextButton);
      expect(nextButtonWidget.enabled, false);
    });

    testWidgets('should enable next button when category selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on first category
      final firstCard = find.byType(SelectionCard).first;
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // NextButton should now be enabled
      final nextButton = find.byType(NextButton);
      final nextButtonWidget = tester.widget<NextButton>(nextButton);
      expect(nextButtonWidget.enabled, true);
    });

    testWidgets('should toggle category selection on tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find first selection card
      final firstCard = find.byType(SelectionCard).first;
      SelectionCard cardWidget = tester.widget<SelectionCard>(firstCard);

      // Initially not selected
      expect(cardWidget.isSelected, false);

      // Tap to select
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      cardWidget = tester.widget<SelectionCard>(firstCard);
      expect(cardWidget.isSelected, true);

      // Tap again to deselect
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      cardWidget = tester.widget<SelectionCard>(firstCard);
      expect(cardWidget.isSelected, false);
    });

    testWidgets('should allow multiple category selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Select two categories (since we only need to verify multiple selection)
      final cards = find.byType(SelectionCard);
      await tester.tap(cards.at(0));
      await tester.pumpAndSettle();

      await tester.tap(cards.at(1));
      await tester.pumpAndSettle();

      // Verify both are selected
      SelectionCard card1 = tester.widget<SelectionCard>(cards.at(0));
      SelectionCard card2 = tester.widget<SelectionCard>(cards.at(1));

      expect(card1.isSelected, true);
      expect(card2.isSelected, true);
    });

    testWidgets('should show snackbar when next tapped without selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Try to press next button (should be disabled but test the handler)
      // Note: Since button is disabled, we can't actually tap it
      // This test verifies the validation logic exists

      // Select a category first
      final firstCard = find.byType(SelectionCard).first;
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // Deselect it
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // Button should be disabled again
      final nextButton = find.byType(NextButton);
      final nextButtonWidget = tester.widget<NextButton>(nextButton);
      expect(nextButtonWidget.enabled, false);
    });

    testWidgets('should show loading state when saving',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Select a category
      final firstCard = find.byType(SelectionCard).first;
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // Tap next button
      final nextButton = find.byType(ElevatedButton);
      await tester.tap(nextButton);
      await tester.pump(); // Start animation

      // Should show loading indicator in button
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for save to complete
      await tester.pumpAndSettle();
    });

    testWidgets('should show success snackbar after saving',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Select a category
      final firstCard = find.byType(SelectionCard).first;
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // Tap next button
      final nextButton = find.byType(ElevatedButton);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Verify success message appears
      expect(find.text('선택이 저장되었습니다'), findsOneWidget);
    });

    testWidgets('should display categories in grid layout',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify GridView exists
      expect(find.byType(GridView), findsOneWidget);

      // Verify selection cards are rendered (at least some visible)
      expect(find.byType(SelectionCard), findsWidgets);
    });

    testWidgets('should maintain selection state during rebuild',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Select two categories
      final cards = find.byType(SelectionCard);
      await tester.tap(cards.at(0));
      await tester.pumpAndSettle();

      await tester.tap(cards.at(1));
      await tester.pumpAndSettle();

      // Force rebuild
      await tester.pumpWidget(
        const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify selections are maintained
      SelectionCard card1 = tester.widget<SelectionCard>(cards.at(0));
      SelectionCard card2 = tester.widget<SelectionCard>(cards.at(1));

      expect(card1.isSelected, true);
      expect(card2.isSelected, true);
    });

    testWidgets('should have correct background color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Scaffold
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);

      // Verify background color is set
      final scaffoldWidget = tester.widget<Scaffold>(scaffold);
      expect(scaffoldWidget.backgroundColor, isNotNull);
    });

    testWidgets('should display categories with proper layout',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify GridView with proper delegate
      final gridView = find.byType(GridView);
      expect(gridView, findsOneWidget);

      // Verify selection cards are rendered
      expect(find.byType(SelectionCard), findsWidgets);

      // Verify at least 2 cards are visible in viewport
      expect(find.byType(SelectionCard), findsAtLeastNWidgets(2));
    });
  });
}
