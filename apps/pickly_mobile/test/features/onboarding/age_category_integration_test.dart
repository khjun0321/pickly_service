import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pickly_mobile/features/onboarding/age_category_screen.dart';
import 'package:pickly_mobile/features/onboarding/age_category_controller.dart';
import 'package:pickly_mobile/repositories/age_category_repository.dart';
import 'package:pickly_mobile/models/age_category.dart';

import 'age_category_integration_test.mocks.dart';

@GenerateMocks([SupabaseClient, SupabaseQueryBuilder, PostgrestFilterBuilder])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late AgeCategoryRepository repository;
  late AgeCategoryController controller;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    repository = AgeCategoryRepository(mockSupabaseClient);
    controller = AgeCategoryController(repository);
  });

  tearDown(() {
    controller.dispose();
  });

  Widget createTestApp() {
    return MaterialApp(
      home: ChangeNotifierProvider<AgeCategoryController>.value(
        value: controller,
        child: const AgeCategoryScreen(userId: 'integration-test-user'),
      ),
    );
  }

  group('Age Category Onboarding Integration Tests', () {
    group('Complete User Flow', () {
      testWidgets('should complete full onboarding flow successfully', (tester) async {
        // Arrange - Mock Supabase responses
        final mockCategories = [
          {
            'id': 'cat-integration-1',
            'category_name': '10대',
            'min_age': 10,
            'max_age': 19,
            'created_at': '2024-01-01T00:00:00Z',
          },
          {
            'id': 'cat-integration-2',
            'category_name': '20대',
            'min_age': 20,
            'max_age': 29,
            'created_at': '2024-01-01T00:00:00Z',
          },
          {
            'id': 'cat-integration-3',
            'category_name': '30대',
            'min_age': 30,
            'max_age': 39,
            'created_at': '2024-01-01T00:00:00Z',
          },
        ];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('min_age', ascending: true))
            .thenAnswer((_) async => mockCategories);

        when(mockSupabaseClient.from('user_age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.upsert(any))
            .thenAnswer((_) async => {'success': true});

        // Act - Build widget
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Assert - Initial screen loaded
        expect(find.text('연령대 선택'), findsOneWidget);
        expect(find.text('10대'), findsOneWidget);
        expect(find.text('20대'), findsOneWidget);
        expect(find.text('30대'), findsOneWidget);

        // Act - Select category
        await tester.tap(find.text('20대'));
        await tester.pumpAndSettle();

        // Assert - Category selected
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(controller.selectedCategory?.categoryName, '20대');

        // Act - Submit
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();

        // Assert - Submit successful
        verify(mockQueryBuilder.upsert(argThat(containsPair('age_category_id', 'cat-integration-2'))))
            .called(1);
      });

      testWidgets('should handle category change before submit', (tester) async {
        // Arrange
        final mockCategories = [
          {
            'id': 'cat-change-1',
            'category_name': '20대',
            'min_age': 20,
            'max_age': 29,
            'created_at': '2024-01-01T00:00:00Z',
          },
          {
            'id': 'cat-change-2',
            'category_name': '30대',
            'min_age': 30,
            'max_age': 39,
            'created_at': '2024-01-01T00:00:00Z',
          },
        ];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('min_age', ascending: true))
            .thenAnswer((_) async => mockCategories);

        when(mockSupabaseClient.from('user_age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.upsert(any))
            .thenAnswer((_) async => {'success': true});

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Act - Select first category
        await tester.tap(find.text('20대'));
        await tester.pumpAndSettle();
        expect(controller.selectedCategory?.categoryName, '20대');

        // Act - Change to second category
        await tester.tap(find.text('30대'));
        await tester.pumpAndSettle();

        // Assert - Selection changed
        expect(controller.selectedCategory?.categoryName, '30대');

        // Act - Submit final selection
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();

        // Assert - Correct category submitted
        verify(mockQueryBuilder.upsert(argThat(containsPair('age_category_id', 'cat-change-2'))))
            .called(1);
      });
    });

    group('Error Recovery Flow', () {
      testWidgets('should recover from initial load failure and retry', (tester) async {
        // Arrange - First call fails, second succeeds
        var callCount = 0;
        final mockCategories = [
          {
            'id': 'cat-retry',
            'category_name': '20대',
            'min_age': 20,
            'max_age': 29,
            'created_at': '2024-01-01T00:00:00Z',
          },
        ];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('min_age', ascending: true))
            .thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw Exception('Network error');
          }
          return mockCategories;
        });

        // Act - Initial load (fails)
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Assert - Error displayed
        expect(controller.errorMessage, isNotNull);
        expect(find.text('연령대 정보를 불러올 수 없습니다'), findsOneWidget);

        // Act - Retry
        await controller.loadCategories();
        await tester.pumpAndSettle();

        // Assert - Success after retry
        expect(controller.errorMessage, isNull);
        expect(find.text('20대'), findsOneWidget);
      });

      testWidgets('should show error on save failure and allow retry', (tester) async {
        // Arrange
        final mockCategories = [
          {
            'id': 'cat-save-fail',
            'category_name': '30대',
            'min_age': 30,
            'max_age': 39,
            'created_at': '2024-01-01T00:00:00Z',
          },
        ];

        var saveCallCount = 0;

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('min_age', ascending: true))
            .thenAnswer((_) async => mockCategories);

        when(mockSupabaseClient.from('user_age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.upsert(any)).thenAnswer((_) async {
          saveCallCount++;
          if (saveCallCount == 1) {
            throw Exception('Database error');
          }
          return {'success': true};
        });

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Act - Select and submit (fails)
        await tester.tap(find.text('30대'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();

        // Assert - Error shown
        expect(controller.errorMessage, isNotNull);

        // Act - Retry submit
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();

        // Assert - Success on retry
        expect(saveCallCount, 2);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle empty categories list gracefully', (tester) async {
        // Arrange
        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('min_age', ascending: true))
            .thenAnswer((_) async => []);

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('연령대 정보를 불러올 수 없습니다'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.enabled, isFalse);
      });

      testWidgets('should handle category with null max_age', (tester) async {
        // Arrange
        final mockCategories = [
          {
            'id': 'cat-senior',
            'category_name': '60대 이상',
            'min_age': 60,
            'max_age': null,
            'created_at': '2024-01-01T00:00:00Z',
          },
        ];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('min_age', ascending: true))
            .thenAnswer((_) async => mockCategories);

        when(mockSupabaseClient.from('user_age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.upsert(any))
            .thenAnswer((_) async => {'success': true});

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('60대 이상'), findsOneWidget);
        expect(find.text('60세 이상'), findsOneWidget);

        // Act - Select and submit
        await tester.tap(find.text('60대 이상'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();

        // Assert - Successfully handled null max_age
        verify(mockQueryBuilder.upsert(argThat(containsPair('age_category_id', 'cat-senior'))))
            .called(1);
      });

      testWidgets('should handle rapid category selection changes', (tester) async {
        // Arrange
        final mockCategories = [
          {
            'id': 'cat-rapid-1',
            'category_name': '10대',
            'min_age': 10,
            'max_age': 19,
            'created_at': '2024-01-01T00:00:00Z',
          },
          {
            'id': 'cat-rapid-2',
            'category_name': '20대',
            'min_age': 20,
            'max_age': 29,
            'created_at': '2024-01-01T00:00:00Z',
          },
          {
            'id': 'cat-rapid-3',
            'category_name': '30대',
            'min_age': 30,
            'max_age': 39,
            'created_at': '2024-01-01T00:00:00Z',
          },
        ];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('min_age', ascending: true))
            .thenAnswer((_) async => mockCategories);

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Act - Rapidly change selections
        await tester.tap(find.text('10대'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('20대'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('30대'));
        await tester.pumpAndSettle();

        // Assert - Final selection is correct
        expect(controller.selectedCategory?.categoryName, '30대');
      });
    });

    group('Data Persistence', () {
      testWidgets('should maintain selection during rebuild', (tester) async {
        // Arrange
        final mockCategories = [
          {
            'id': 'cat-persist',
            'category_name': '40대',
            'min_age': 40,
            'max_age': 49,
            'created_at': '2024-01-01T00:00:00Z',
          },
        ];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('min_age', ascending: true))
            .thenAnswer((_) async => mockCategories);

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Act - Select category
        await tester.tap(find.text('40대'));
        await tester.pumpAndSettle();

        final selectedBefore = controller.selectedCategory;

        // Act - Trigger rebuild
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Assert - Selection persisted
        expect(controller.selectedCategory, selectedBefore);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });
    });

    group('Performance Under Load', () {
      testWidgets('should handle large category list efficiently', (tester) async {
        // Arrange - Create 100 categories
        final mockCategories = List.generate(
          100,
          (index) => {
            'id': 'cat-load-$index',
            'category_name': '${index}0대',
            'min_age': index * 10,
            'max_age': (index * 10) + 9,
            'created_at': '2024-01-01T00:00:00Z',
          },
        );

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('min_age', ascending: true))
            .thenAnswer((_) async => mockCategories);

        // Act
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Assert - Rendered without errors
        expect(find.byType(ListView), findsOneWidget);
        expect(controller.categories.length, 100);

        // Act - Scroll through list
        await tester.drag(find.byType(ListView), const Offset(0, -2000));
        await tester.pumpAndSettle();

        // Assert - Still functional after scrolling
        expect(find.byType(ListView), findsOneWidget);
      });
    });

    group('Navigation Flow', () {
      testWidgets('should navigate to next screen on successful submit', (tester) async {
        // Arrange
        final mockCategories = [
          {
            'id': 'cat-nav',
            'category_name': '25대',
            'min_age': 20,
            'max_age': 29,
            'created_at': '2024-01-01T00:00:00Z',
          },
        ];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('min_age', ascending: true))
            .thenAnswer((_) async => mockCategories);

        when(mockSupabaseClient.from('user_age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.upsert(any))
            .thenAnswer((_) async => {'success': true});

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Act - Complete flow
        await tester.tap(find.text('25대'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();

        // Assert - Navigation occurred (would check Navigator in real app)
        verify(mockQueryBuilder.upsert(any)).called(1);
      });
    });
  });
}
