import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pickly_mobile/repositories/age_category_repository.dart';
import 'package:pickly_mobile/models/age_category.dart';

// Generate mocks for Supabase classes
@GenerateNiceMocks([
  MockSpec<SupabaseClient>(),
  MockSpec<PostgrestQueryBuilder>(),
  MockSpec<PostgrestFilterBuilder>(),
  MockSpec<PostgrestTransformBuilder>(),
])
import 'age_category_repository_test.mocks.dart';

void main() {
  late AgeCategoryRepository repository;
  late MockSupabaseClient mockSupabaseClient;
  late MockPostgrestQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockPostgrestTransformBuilder mockTransformBuilder;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockPostgrestQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockTransformBuilder = MockPostgrestTransformBuilder();
    repository = AgeCategoryRepository(client: mockSupabaseClient);
  });

  group('AgeCategoryRepository Tests', () {
    group('fetchActiveCategories', () {
      test('should fetch and parse age categories successfully', () async {
        // Arrange
        final mockResponse = [
          {
            'id': 'cat-1',
            'category_name': '10대',
            'min_age': 10,
            'max_age': 19,
            'description': '10대 청소년',
            'icon': 'teen',
            'sort_order': 1,
            'is_active': true,
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
          {
            'id': 'cat-2',
            'category_name': '20대',
            'min_age': 20,
            'max_age': 29,
            'description': '20대 청년',
            'icon': 'young_adult',
            'sort_order': 2,
            'is_active': true,
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.fetchActiveCategories();

        // Assert
        expect(result, isA<List<AgeCategory>>());
        expect(result.length, 2);
        expect(result[0].categoryName, '10대');
        expect(result[1].categoryName, '20대');

        verify(mockSupabaseClient.from('age_categories')).called(1);
        verify(mockQueryBuilder.select()).called(1);
        verify(mockFilterBuilder.eq('is_active', true)).called(1);
        verify(mockTransformBuilder.order('sort_order', ascending: true)).called(1);
      });

      test('should return empty list when no categories exist', () async {
        // Arrange
        final mockResponse = <Map<String, dynamic>>[];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.fetchActiveCategories();

        // Assert
        expect(result, isEmpty);
        expect(result, isA<List<AgeCategory>>());
      });

      test('should throw AgeCategoryException when query returns null', () async {
        // Arrange
        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => repository.fetchActiveCategories(),
          throwsA(isA<AgeCategoryException>()),
        );
      });

      test('should throw AgeCategoryException on database error', () async {
        // Arrange
        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenThrow(PostgrestException(message: 'Database error'));

        // Act & Assert
        expect(
          () => repository.fetchActiveCategories(),
          throwsA(isA<AgeCategoryException>()),
        );
      });

      test('should filter only active categories', () async {
        // Arrange
        final mockResponse = [
          {
            'id': 'cat-active',
            'category_name': '30대',
            'min_age': 30,
            'max_age': 39,
            'description': '30대',
            'icon': 'adult',
            'sort_order': 1,
            'is_active': true,
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => mockResponse);

        // Act
        await repository.fetchActiveCategories();

        // Assert
        verify(mockFilterBuilder.eq('is_active', true)).called(1);
      });

      test('should sort categories by sort_order', () async {
        // Arrange
        final mockResponse = [
          {
            'id': 'cat-1',
            'category_name': '10대',
            'min_age': 10,
            'max_age': 19,
            'description': '10대',
            'icon': 'teen',
            'sort_order': 1,
            'is_active': true,
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => mockResponse);

        // Act
        await repository.fetchActiveCategories();

        // Assert
        verify(mockTransformBuilder.order('sort_order', ascending: true)).called(1);
      });

      test('should handle malformed data gracefully', () async {
        // Arrange - Missing required field 'category_name'
        final mockResponse = [
          {
            'id': 'cat-malformed',
            'min_age': 10,
            'max_age': 19,
          },
        ];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => repository.fetchActiveCategories(),
          throwsA(isA<AgeCategoryException>()),
        );
      });

      test('should handle network timeout exception', () async {
        // Arrange
        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenThrow(Exception('Network timeout'));

        // Act & Assert
        expect(
          () => repository.fetchActiveCategories(),
          throwsA(isA<AgeCategoryException>()),
        );
      });
    });

    group('Edge Cases', () {
      test('should handle very large number of categories', () async {
        // Arrange
        final mockResponse = List.generate(
          1000,
          (index) => {
            'id': 'cat-$index',
            'category_name': 'Category $index',
            'min_age': index * 10,
            'max_age': (index * 10) + 9,
            'description': 'Description $index',
            'icon': 'icon_$index',
            'sort_order': index,
            'is_active': true,
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        );

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.fetchActiveCategories();

        // Assert
        expect(result.length, 1000);
        expect(result.first.categoryName, 'Category 0');
        expect(result.last.categoryName, 'Category 999');
      });

      test('should handle categories with null max_age', () async {
        // Arrange
        final mockResponse = [
          {
            'id': 'cat-senior',
            'category_name': '60대 이상',
            'min_age': 60,
            'max_age': null,
            'description': '60대 이상 시니어',
            'icon': 'senior',
            'sort_order': 6,
            'is_active': true,
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await repository.fetchActiveCategories();

        // Assert
        expect(result.length, 1);
        expect(result.first.maxAge, isNull);
        expect(result.first.categoryName, '60대 이상');
      });
    });
  });
}
