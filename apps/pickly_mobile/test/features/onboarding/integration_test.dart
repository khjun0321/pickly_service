import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_mobile/features/onboarding/screens/age_category_screen.dart';
import 'package:pickly_mobile/features/onboarding/widgets/selection_list_item.dart';
import 'package:pickly_mobile/features/onboarding/providers/age_category_provider.dart';
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Integration tests for Age Category Onboarding Flow
///
/// Tests the complete user journey through the age category selection screen:
/// 1. 전체 플로우: 001→002→003→004→005
/// 2. 화면별 검증 로직
/// 3. Realtime 동기화 (003, 005)
/// 4. 뒤로가기 복원
void main() {
  group('Age Category Onboarding Integration Tests', () {
    late List<AgeCategory> mockCategories;

    setUp(() {
      // Create realistic mock age categories
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

    Widget createTestApp({List<AgeCategory>? categories}) {
      return ProviderScope(
        overrides: [
          ageCategoryProvider.overrideWith(() {
            return TestAgeCategoryNotifier(categories ?? mockCategories);
          }),
        ],
        child: const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );
    }

    group('Complete User Flow Tests', () {
      testWidgets('Should complete full selection flow from start to finish', (WidgetTester tester) async {
        // Arrange - Start with clean screen
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Step 1: Verify initial screen state
        expect(find.text('맞춤 혜택을 위해 내 상황을 알려주세요.'), findsOneWidget);
        expect(find.text('나에게 맞는 정책과 혜택에 대해 안내해드려요'), findsOneWidget);
        expect(find.byType(SelectionListItem), findsNWidgets(6));

        // Step 2: Verify next button is initially disabled
        final nextButton = find.widgetWithText(ElevatedButton, '다음');
        var button = tester.widget<ElevatedButton>(nextButton);
        expect(button.onPressed, isNull, reason: 'Next button should be disabled initially');

        // Step 3: Select first category (청년)
        await tester.tap(find.text('청년'));
        await tester.pumpAndSettle();

        // Verify selection state changed
        var firstItem = tester.widget<SelectionListItem>(find.byType(SelectionListItem).first);
        expect(firstItem.isSelected, true);

        // Verify next button is now enabled
        button = tester.widget<ElevatedButton>(nextButton);
        expect(button.onPressed, isNotNull, reason: 'Next button should be enabled after selection');

        // Step 4: Select second category (육아중인 부모)
        await tester.tap(find.text('육아중인 부모'));
        await tester.pumpAndSettle();

        // Verify both selections
        final items = find.byType(SelectionListItem);
        final item1 = tester.widget<SelectionListItem>(items.at(0));
        final item3 = tester.widget<SelectionListItem>(items.at(2));
        expect(item1.isSelected, true);
        expect(item3.isSelected, true);

        // Step 5: Deselect first category
        await tester.tap(find.text('청년'));
        await tester.pumpAndSettle();

        // Verify only second remains selected
        firstItem = tester.widget<SelectionListItem>(items.at(0));
        final thirdItem = tester.widget<SelectionListItem>(items.at(2));
        expect(firstItem.isSelected, false);
        expect(thirdItem.isSelected, true);

        // Step 6: Tap next button
        await tester.tap(nextButton);
        await tester.pumpAndSettle();

        // Verify snackbar appears with correct message
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Selected: 1 categories'), findsOneWidget);
      });

      testWidgets('Should handle multiple selections and navigate', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Act - Select 3 categories
        await tester.tap(find.text('청년'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('신혼부부·예비부부'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('어르신'));
        await tester.pumpAndSettle();

        // Verify all selected
        final items = find.byType(SelectionListItem);
        expect(tester.widget<SelectionListItem>(items.at(0)).isSelected, true);
        expect(tester.widget<SelectionListItem>(items.at(1)).isSelected, true);
        expect(tester.widget<SelectionListItem>(items.at(4)).isSelected, true);

        // Submit selection
        await tester.tap(find.widgetWithText(ElevatedButton, '다음'));
        await tester.pumpAndSettle();

        // Verify correct count in snackbar
        expect(find.text('Selected: 3 categories'), findsOneWidget);
      });
    });

    group('Screen Validation Logic Tests', () {
      testWidgets('Should display correct screen structure and layout', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Verify screen structure
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(SafeArea), findsOneWidget);

        // Verify header with progress
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(progressIndicator.value, 0.5, reason: 'Progress should be 50% (step 3/5)');

        // Verify title and subtitle
        expect(find.text('맞춤 혜택을 위해 내 상황을 알려주세요.'), findsOneWidget);
        expect(find.text('나에게 맞는 정책과 혜택에 대해 안내해드려요'), findsOneWidget);

        // Verify list view with all categories
        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(SelectionListItem), findsNWidgets(6));

        // Verify next button at bottom
        expect(find.widgetWithText(ElevatedButton, '다음'), findsOneWidget);
      });

      testWidgets('Should validate all category data is displayed correctly', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Verify all titles
        expect(find.text('청년'), findsOneWidget);
        expect(find.text('신혼부부·예비부부'), findsOneWidget);
        expect(find.text('육아중인 부모'), findsOneWidget);
        expect(find.text('다자녀 가구'), findsOneWidget);
        expect(find.text('어르신'), findsOneWidget);
        expect(find.text('장애인'), findsOneWidget);

        // Verify descriptions are shown
        expect(find.text('만 19세-39세 대학생, 취업준비생, 직장인'), findsOneWidget);
        expect(find.text('결혼 예정 또는 결혼 7년이내'), findsOneWidget);
        expect(find.text('영유아~초등 자녀 양육 중'), findsOneWidget);
        expect(find.text('자녀 2명 이상 양육중'), findsOneWidget);
        expect(find.text('만 65세 이상'), findsOneWidget);
        expect(find.text('장애인 등록 대상'), findsOneWidget);
      });
    });

    group('Provider Integration Tests', () {
      testWidgets('Should load categories from provider', (WidgetTester tester) async {
        // Arrange - Custom categories
        final customCategories = [
          AgeCategory(
            id: 'custom-1',
            title: 'Custom Category',
            description: 'Custom Description',
            iconComponent: 'custom',
            iconUrl: null,
            minAge: null,
            maxAge: null,
            sortOrder: 1,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        await tester.pumpWidget(createTestApp(categories: customCategories));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Custom Category'), findsOneWidget);
        expect(find.text('Custom Description'), findsOneWidget);
      });

      testWidgets('Should handle empty categories list', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestApp(categories: []));
        await tester.pumpAndSettle();

        // Assert - Empty state
        expect(find.text('표시할 카테고리가 없습니다'), findsOneWidget);
        expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      });

      testWidgets('Should handle provider loading state', (WidgetTester tester) async {
        // Arrange - Loading provider
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

        // Act - Pump to show loading
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('Should handle provider error state', (WidgetTester tester) async {
        // Arrange - Error provider
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

        // Assert - Error state
        expect(find.text('데이터를 불러오는 데 실패했습니다'), findsOneWidget);
        expect(find.text('다시 시도'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });
    });

    group('Navigation and State Restoration Tests', () {
      testWidgets('Should clear selection on back button press', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Select a category
        await tester.tap(find.text('청년'));
        await tester.pumpAndSettle();

        // Verify selection
        var firstItem = tester.widget<SelectionListItem>(find.byType(SelectionListItem).first);
        expect(firstItem.isSelected, true);

        // Act - Press back button
        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        // Assert - Selection should be cleared
        final nextButton = find.widgetWithText(ElevatedButton, '다음');
        final button = tester.widget<ElevatedButton>(nextButton);
        expect(button.onPressed, isNull, reason: 'Next button should be disabled after back');
      });

      testWidgets('Should maintain selection state during scroll', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Select items
        await tester.tap(find.text('청년'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('장애인'));
        await tester.pumpAndSettle();

        // Act - Scroll
        await tester.drag(find.byType(ListView), const Offset(0, -200));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(ListView), const Offset(0, 200));
        await tester.pumpAndSettle();

        // Assert - Selections maintained
        final items = find.byType(SelectionListItem);
        expect(tester.widget<SelectionListItem>(items.at(0)).isSelected, true);
        expect(tester.widget<SelectionListItem>(items.at(5)).isSelected, true);
      });

      testWidgets('Should prevent system back button with PopScope', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Assert - PopScope exists and prevents back
        final popScope = tester.widget<PopScope>(find.byType(PopScope));
        expect(popScope.canPop, false);
      });
    });

    group('UI/UX Validation Tests', () {
      testWidgets('Should show visual feedback for selections', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        final firstItem = find.byType(SelectionListItem).first;

        // Get initial state
        var item = tester.widget<SelectionListItem>(firstItem);
        expect(item.isSelected, false);

        // Act - Select
        await tester.tap(firstItem);
        await tester.pumpAndSettle();

        // Assert - Visual state changed
        item = tester.widget<SelectionListItem>(firstItem);
        expect(item.isSelected, true);
      });

      testWidgets('Should show progress indicator correctly', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Assert - Progress bar
        final progressIndicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(progressIndicator.value, 0.5); // Step 3/5 shown as 50%
        expect(progressIndicator.minHeight, 4);
        expect(progressIndicator.backgroundColor, const Color(0xFFDDDDDD));
      });

      testWidgets('Should have proper button styling', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Find button container
        final buttonContainer = tester.widget<SizedBox>(
          find.ancestor(
            of: find.widgetWithText(ElevatedButton, '다음'),
            matching: find.byType(SizedBox),
          ).first,
        );

        // Assert - Button dimensions
        expect(buttonContainer.height, 56);
        expect(buttonContainer.width, double.infinity);
      });
    });

    group('Edge Cases and Error Handling', () {
      testWidgets('Should handle rapid selection toggles', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        final firstItem = find.byType(SelectionListItem).first;

        // Act - Rapid toggles
        for (int i = 0; i < 10; i++) {
          await tester.tap(firstItem);
          await tester.pump(const Duration(milliseconds: 10));
        }
        await tester.pumpAndSettle();

        // Assert - Should end in deselected state (even number)
        final item = tester.widget<SelectionListItem>(firstItem);
        expect(item.isSelected, false);
      });

      testWidgets('Should handle selecting all categories', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Act - Select all 6
        for (final title in ['청년', '신혼부부·예비부부', '육아중인 부모', '다자녀 가구', '어르신', '장애인']) {
          await tester.tap(find.text(title));
          await tester.pumpAndSettle();
        }

        // Assert - All selected
        final items = find.byType(SelectionListItem);
        for (int i = 0; i < 6; i++) {
          expect(tester.widget<SelectionListItem>(items.at(i)).isSelected, true);
        }

        // Submit and verify
        await tester.tap(find.widgetWithText(ElevatedButton, '다음'));
        await tester.pumpAndSettle();
        expect(find.text('Selected: 6 categories'), findsOneWidget);
      });

      testWidgets('Should handle deselecting all after selections', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Select two
        await tester.tap(find.text('청년'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('어르신'));
        await tester.pumpAndSettle();

        // Verify button enabled
        var button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, '다음'));
        expect(button.onPressed, isNotNull);

        // Act - Deselect both
        await tester.tap(find.text('청년'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('어르신'));
        await tester.pumpAndSettle();

        // Assert - Button disabled again
        button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, '다음'));
        expect(button.onPressed, isNull);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('Should have proper semantic structure', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Assert - All SelectionListItems have semantics
        final items = find.byType(SelectionListItem);
        expect(items, findsNWidgets(6));

        // Each item should be accessible
        for (int i = 0; i < 6; i++) {
          final itemWidget = tester.widget<SelectionListItem>(items.at(i));
          expect(itemWidget.title, isNotEmpty);
        }
      });
    });
  });
}

// Test notifier implementations
class TestAgeCategoryNotifier extends AgeCategoryNotifier {
  final List<AgeCategory> _categories;

  TestAgeCategoryNotifier(this._categories);

  @override
  Future<List<AgeCategory>> build() async {
    return _categories;
  }

  @override
  Future<void> refresh() async {
    state = await AsyncValue.guard(() => Future.value(_categories));
  }

  @override
  Future<void> retry() async {
    await refresh();
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
    throw Exception('Test error: Failed to load categories');
  }

  @override
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => Future.error(Exception('Test error: Failed to load categories')),
    );
  }

  @override
  Future<void> retry() async {
    await refresh();
  }
}
