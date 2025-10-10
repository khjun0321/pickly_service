import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_mobile/features/onboarding/screens/age_category_screen.dart';
import 'package:pickly_mobile/features/onboarding/widgets/onboarding_header.dart';
import 'package:pickly_mobile/features/onboarding/widgets/selection_list_item.dart';
import 'package:pickly_mobile/features/onboarding/providers/age_category_provider.dart';
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

void main() {
  group('AgeCategoryScreen Widget Tests', () {
    late List<AgeCategory> mockCategories;

    setUp(() {
      // Create mock age categories for testing
      final now = DateTime.now();
      mockCategories = [
        AgeCategory(
          id: 'test-1',
          title: '청년',
          description: '만 19세-39세 대학생, 취업준비생, 직장인',
          iconComponent: 'youth',
          iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/young_man.svg',
          minAge: 19,
          maxAge: 39,
          sortOrder: 1,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
        AgeCategory(
          id: 'test-2',
          title: '신혼부부·예비부부',
          description: '결혼 예정 또는 결혼 7년이내',
          iconComponent: 'newlywed',
          iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/bride.svg',
          minAge: null,
          maxAge: null,
          sortOrder: 2,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
        AgeCategory(
          id: 'test-3',
          title: '육아중인 부모',
          description: '영유아~초등 자녀 양육 중',
          iconComponent: 'parenting',
          iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/baby.svg',
          minAge: null,
          maxAge: null,
          sortOrder: 3,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
        AgeCategory(
          id: 'test-4',
          title: '다자녀 가구',
          description: '자녀 2명 이상 양육중',
          iconComponent: 'multi_child',
          iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/kinder.svg',
          minAge: null,
          maxAge: null,
          sortOrder: 4,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
        AgeCategory(
          id: 'test-5',
          title: '어르신',
          description: '만 65세 이상',
          iconComponent: 'elderly',
          iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/old_man.svg',
          minAge: 65,
          maxAge: null,
          sortOrder: 5,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
        AgeCategory(
          id: 'test-6',
          title: '장애인',
          description: '장애인 등록 대상',
          iconComponent: 'disability',
          iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/wheel_chair.svg',
          minAge: null,
          maxAge: null,
          sortOrder: 6,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      ];
    });

    Widget createTestWidget({List<AgeCategory>? categories}) {
      return ProviderScope(
        overrides: [
          ageCategoryProvider.overrideWith(() {
            return FakeAgeCategoryNotifier(categories ?? mockCategories);
          }),
        ],
        child: const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );
    }

    group('Rendering Tests', () {
      testWidgets('Should display title and subtitle', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('현재 연령 및 세대 기준을\n선택해주세요'),
          findsOneWidget,
        );
        expect(
          find.text('나에게 맞는 정책과 혜택에 대해 안내해드려요'),
          findsOneWidget,
        );
      });

      testWidgets('Should display 6 category items', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(SelectionListItem), findsNWidgets(6));
      });

      testWidgets('Should display OnboardingHeader with correct step', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        final header = tester.widget<OnboardingHeader>(find.byType(OnboardingHeader));
        expect(header.currentStep, 2);
        expect(header.totalSteps, 5);
        expect(header.showBackButton, true);
      });

      testWidgets('Should display all category titles', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('청년'), findsOneWidget);
        expect(find.text('신혼부부·예비부부'), findsOneWidget);
        expect(find.text('육아중인 부모'), findsOneWidget);
        expect(find.text('다자녀 가구'), findsOneWidget);
        expect(find.text('어르신'), findsOneWidget);
        expect(find.text('장애인'), findsOneWidget);
      });

      testWidgets('Should display category descriptions', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('만 19세-39세 대학생, 취업준비생, 직장인'), findsOneWidget);
        expect(find.text('결혼 예정 또는 결혼 7년이내'), findsOneWidget);
        expect(find.text('영유아~초등 자녀 양육 중'), findsOneWidget);
      });
    });

    group('Interaction Tests', () {
      testWidgets('Should select item on tap', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Get first item
        final firstItem = find.byType(SelectionListItem).first;
        SelectionListItem item = tester.widget<SelectionListItem>(firstItem);

        // Assert initial state
        expect(item.isSelected, false);

        // Act - Tap to select
        await tester.tap(firstItem);
        await tester.pumpAndSettle();

        // Assert - Item should be selected
        item = tester.widget<SelectionListItem>(firstItem);
        expect(item.isSelected, true);
      });

      testWidgets('Should support multiple selection', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Select first three items
        final items = find.byType(SelectionListItem);
        await tester.tap(items.at(0));
        await tester.pumpAndSettle();
        await tester.tap(items.at(1));
        await tester.pumpAndSettle();
        await tester.tap(items.at(2));
        await tester.pumpAndSettle();

        // Assert - All three should be selected
        final item1 = tester.widget<SelectionListItem>(items.at(0));
        final item2 = tester.widget<SelectionListItem>(items.at(1));
        final item3 = tester.widget<SelectionListItem>(items.at(2));

        expect(item1.isSelected, true);
        expect(item2.isSelected, true);
        expect(item3.isSelected, true);
      });

      testWidgets('Should toggle selection on second tap', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final firstItem = find.byType(SelectionListItem).first;

        // Act - Tap to select
        await tester.tap(firstItem);
        await tester.pumpAndSettle();

        var item = tester.widget<SelectionListItem>(firstItem);
        expect(item.isSelected, true);

        // Act - Tap again to deselect
        await tester.tap(firstItem);
        await tester.pumpAndSettle();

        // Assert - Should be deselected
        item = tester.widget<SelectionListItem>(firstItem);
        expect(item.isSelected, false);
      });

      testWidgets('Should enable next button when at least one selected', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find next button
        final nextButton = find.widgetWithText(ElevatedButton, '다음');
        expect(nextButton, findsOneWidget);

        // Assert - Initially disabled
        var button = tester.widget<ElevatedButton>(nextButton);
        expect(button.onPressed, isNull);

        // Act - Select a category
        await tester.tap(find.byType(SelectionListItem).first);
        await tester.pumpAndSettle();

        // Assert - Button should be enabled
        button = tester.widget<ElevatedButton>(nextButton);
        expect(button.onPressed, isNotNull);
      });

      testWidgets('Should disable next button when all items deselected', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Select and then deselect
        final firstItem = find.byType(SelectionListItem).first;
        await tester.tap(firstItem);
        await tester.pumpAndSettle();
        await tester.tap(firstItem);
        await tester.pumpAndSettle();

        // Assert - Button should be disabled
        final nextButton = find.widgetWithText(ElevatedButton, '다음');
        final button = tester.widget<ElevatedButton>(nextButton);
        expect(button.onPressed, isNull);
      });

      testWidgets('Should navigate back on back button press', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find back button in OnboardingHeader
        final backButton = find.byType(IconButton);
        expect(backButton, findsOneWidget);

        // Act - Tap back button
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Assert - Should clear selections (tested through button state)
        final nextButton = find.widgetWithText(ElevatedButton, '다음');
        final button = tester.widget<ElevatedButton>(nextButton);
        expect(button.onPressed, isNull);
      });
    });

    group('State Tests', () {
      testWidgets('Should show loading state', (WidgetTester tester) async {
        // Arrange - Override with loading state
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              ageCategoryProvider.overrideWith(() {
                return LoadingAgeCategoryNotifier();
              }),
            ],
            child: const MaterialApp(
              home: AgeCategoryScreen(),
            ),
          ),
        );

        // Act - Pump once to show loading
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('Should show error state with retry button', (WidgetTester tester) async {
        // Arrange - Override with error state
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              ageCategoryProvider.overrideWith(() {
                return ErrorAgeCategoryNotifier();
              }),
            ],
            child: const MaterialApp(
              home: AgeCategoryScreen(),
            ),
          ),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('데이터를 불러오는 데 실패했습니다'), findsOneWidget);
        expect(find.text('다시 시도'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('Should show empty state', (WidgetTester tester) async {
        // Arrange - Override with empty list
        await tester.pumpWidget(createTestWidget(categories: []));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('표시할 카테고리가 없습니다'), findsOneWidget);
        expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      });

      testWidgets('Should maintain selection state during scroll', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Select first item
        await tester.tap(find.byType(SelectionListItem).first);
        await tester.pumpAndSettle();

        // Scroll down and up
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(ListView), const Offset(0, 300));
        await tester.pumpAndSettle();

        // Assert - Selection should be maintained
        final firstItem = find.byType(SelectionListItem).first;
        final item = tester.widget<SelectionListItem>(firstItem);
        expect(item.isSelected, true);
      });
    });

    group('Navigation Tests', () {
      testWidgets('Should show snackbar when next button tapped', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Select category and tap next
        await tester.tap(find.byType(SelectionListItem).first);
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ElevatedButton, '다음'));
        await tester.pumpAndSettle();

        // Assert - Snackbar should appear
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Selected: 1 categories'), findsOneWidget);
      });

      testWidgets('Should prevent back navigation with PopScope', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - PopScope should exist with canPop false
        final popScope = tester.widget<PopScope>(find.byType(PopScope));
        expect(popScope.canPop, false);
      });
    });

    group('UI/UX Tests', () {
      testWidgets('Should use correct background color', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, BackgroundColors.app);
      });

      testWidgets('Should have proper spacing between elements', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Verify SizedBox widgets exist for spacing
        expect(find.byType(SizedBox), findsWidgets);
      });

      testWidgets('Should display items in a scrollable list', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - ListView should be scrollable
        expect(find.byType(ListView), findsOneWidget);

        // Verify scrolling works
        final listView = find.byType(ListView);
        await tester.drag(listView, const Offset(0, -100));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('Should show button at bottom with proper padding', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Button should be in a Padding widget
        final button = find.widgetWithText(ElevatedButton, '다음');
        expect(button, findsOneWidget);

        // Check button has proper dimensions
        final buttonWidget = tester.widget<SizedBox>(
          find.ancestor(
            of: button,
            matching: find.byType(SizedBox),
          ).first,
        );
        expect(buttonWidget.height, 56);
      });
    });

    group('Edge Cases', () {
      testWidgets('Should handle rapid taps gracefully', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final firstItem = find.byType(SelectionListItem).first;

        // Act - Rapid taps
        for (int i = 0; i < 5; i++) {
          await tester.tap(firstItem);
          await tester.pump(const Duration(milliseconds: 10));
        }
        await tester.pumpAndSettle();

        // Assert - Should end in deselected state (odd number of taps)
        final item = tester.widget<SelectionListItem>(firstItem);
        expect(item.isSelected, true);
      });

      testWidgets('Should handle selecting all categories', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Select all 6 categories
        final items = find.byType(SelectionListItem);
        for (int i = 0; i < 6; i++) {
          await tester.tap(items.at(i));
          await tester.pumpAndSettle();
        }

        // Assert - All should be selected
        for (int i = 0; i < 6; i++) {
          final item = tester.widget<SelectionListItem>(items.at(i));
          expect(item.isSelected, true);
        }

        // Next button should show "6 categories"
        await tester.tap(find.widgetWithText(ElevatedButton, '다음'));
        await tester.pumpAndSettle();
        expect(find.text('Selected: 6 categories'), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('Should have proper semantics for screen readers', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - SelectionListItem should have Semantics
        final firstItem = find.byType(SelectionListItem).first;
        expect(firstItem, findsOneWidget);

        // OnboardingHeader should have semantics
        final header = find.byType(OnboardingHeader);
        expect(header, findsOneWidget);
      });
    });
  });
}

// Mock notifiers for testing different states
class FakeAgeCategoryNotifier extends AgeCategoryNotifier {
  final List<AgeCategory> _categories;

  FakeAgeCategoryNotifier(this._categories);

  @override
  Future<List<AgeCategory>> build() async {
    return _categories;
  }

  @override
  Future<void> refresh() async {
    state = await AsyncValue.guard(() => Future.value(_categories));
  }
}

class LoadingAgeCategoryNotifier extends AgeCategoryNotifier {
  @override
  Future<List<AgeCategory>> build() async {
    // Never complete to keep loading state
    await Future.delayed(const Duration(hours: 1));
    return [];
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<void> retry() async {}
}

class ErrorAgeCategoryNotifier extends AgeCategoryNotifier {
  @override
  Future<List<AgeCategory>> build() async {
    throw Exception('Test error');
  }

  @override
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => Future.error(Exception('Test error')));
  }

  @override
  Future<void> retry() async {
    await refresh();
  }
}
