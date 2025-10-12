// Age Category Screen Tests
//
// Comprehensive test suite for the age category selection screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_mobile/features/onboarding/screens/age_category_screen.dart';
import 'package:pickly_mobile/features/onboarding/providers/age_category_provider.dart';
import 'package:pickly_mobile/features/onboarding/widgets/selection_list_item.dart';

void main() {
  group('AgeCategoryScreen', () {
    late List<AgeCategory> mockCategories;

    setUp(() {
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
      ];
    });

    Widget createTestWidget({
      required AsyncValue<List<AgeCategory>> providerValue,
    }) {
      return ProviderScope(
        overrides: [
          ageCategoryProvider.overrideWith(() => TestAgeCategoryNotifier(providerValue)),
        ],
        child: const MaterialApp(
          home: AgeCategoryScreen(),
        ),
      );
    }

    group('Loading State', () {
      testWidgets('shows loading indicator when data is loading', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            providerValue: const AsyncValue.loading(),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(SelectionListItem), findsNothing);
      });
    });

    group('Data State', () {
      testWidgets('displays list of categories when data is loaded', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            providerValue: AsyncValue.data(mockCategories),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SelectionListItem), findsNWidgets(mockCategories.length));
        expect(find.text('청년'), findsOneWidget);
        expect(find.text('신혼부부·예비부부'), findsOneWidget);
        expect(find.text('어르신'), findsOneWidget);
      });

      testWidgets('displays empty state when category list is empty', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            providerValue: const AsyncValue.data([]),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('표시할 카테고리가 없습니다'), findsOneWidget);
        expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
        expect(find.byType(SelectionListItem), findsNothing);
      });
    });

    group('Selection Logic', () {
      testWidgets('selects category when tapped', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            providerValue: AsyncValue.data(mockCategories),
          ),
        );
        await tester.pumpAndSettle();

        final firstItem = find.byType(SelectionListItem).first;
        await tester.tap(firstItem);
        await tester.pumpAndSettle();

        final nextButton = find.widgetWithText(ElevatedButton, '다음');
        expect(nextButton, findsOneWidget);

        final button = tester.widget<ElevatedButton>(nextButton);
        expect(button.onPressed, isNotNull);
      });

      testWidgets('allows multiple category selection', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            providerValue: AsyncValue.data(mockCategories),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(SelectionListItem).at(0));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(SelectionListItem).at(1));
        await tester.pumpAndSettle();

        final nextButton = find.widgetWithText(ElevatedButton, '다음');
        final button = tester.widget<ElevatedButton>(nextButton);
        expect(button.onPressed, isNotNull);
      });
    });

    group('Button State', () {
      testWidgets('next button is disabled when no categories selected', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            providerValue: AsyncValue.data(mockCategories),
          ),
        );
        await tester.pumpAndSettle();

        final nextButton = find.widgetWithText(ElevatedButton, '다음');
        expect(nextButton, findsOneWidget);

        final button = tester.widget<ElevatedButton>(nextButton);
        expect(button.onPressed, isNull);
      });

      testWidgets('next button is enabled when category is selected', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            providerValue: AsyncValue.data(mockCategories),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(SelectionListItem).first);
        await tester.pumpAndSettle();

        final nextButton = find.widgetWithText(ElevatedButton, '다음');
        final button = tester.widget<ElevatedButton>(nextButton);
        expect(button.onPressed, isNotNull);
      });
    });

    group('Error State', () {
      testWidgets('displays error message when data fetch fails', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            providerValue: AsyncValue.error(
              Exception('Network error'),
              StackTrace.current,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('데이터를 불러오는 데 실패했습니다'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('다시 시도'), findsOneWidget);
      });
    });

    group('UI Elements', () {
      testWidgets('displays correct title and guidance text', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            providerValue: AsyncValue.data(mockCategories),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('맞춤 혜택을 위해 내 상황을 알려주세요.'), findsOneWidget);
        expect(find.text('나에게 맞는 정책과 혜택에 대해 안내해드려요'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.text('다음'), findsOneWidget);
      });
    });
  });
}

/// Test notifier for mocking AgeCategoryNotifier
class TestAgeCategoryNotifier extends AgeCategoryNotifier {
  final AsyncValue<List<AgeCategory>> _testValue;

  TestAgeCategoryNotifier(this._testValue);

  @override
  Future<List<AgeCategory>> build() async {
    return _testValue.when(
      data: (data) => data,
      loading: () => throw StateError('Loading'),
      error: (error, stack) => throw error,
    );
  }

  @override
  Future<void> refresh() async {
    // Mock implementation for testing
  }
}
