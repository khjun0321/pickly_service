import 'package:flutter_test/flutter_test.dart';
import 'package:pickly_mobile/models/age_category.dart';

void main() {
  group('AgeCategory Model Tests', () {
    group('fromJson', () {
      test('should correctly deserialize valid JSON with all fields', () {
        // Arrange
        final json = {
          'id': 'test-uuid-123',
          'category_name': '10대',
          'min_age': 10,
          'max_age': 19,
          'created_at': '2024-01-01T00:00:00Z',
        };

        // Act
        final category = AgeCategory.fromJson(json);

        // Assert
        expect(category.id, 'test-uuid-123');
        expect(category.categoryName, '10대');
        expect(category.minAge, 10);
        expect(category.maxAge, 19);
        expect(category.createdAt, DateTime.parse('2024-01-01T00:00:00Z'));
      });

      test('should handle nullable max_age field', () {
        // Arrange
        final json = {
          'id': 'test-uuid-456',
          'category_name': '60대 이상',
          'min_age': 60,
          'max_age': null,
          'created_at': '2024-01-01T00:00:00Z',
        };

        // Act
        final category = AgeCategory.fromJson(json);

        // Assert
        expect(category.id, 'test-uuid-456');
        expect(category.categoryName, '60대 이상');
        expect(category.minAge, 60);
        expect(category.maxAge, isNull);
      });

      test('should handle nullable created_at field', () {
        // Arrange
        final json = {
          'id': 'test-uuid-789',
          'category_name': '20대',
          'min_age': 20,
          'max_age': 29,
          'created_at': null,
        };

        // Act
        final category = AgeCategory.fromJson(json);

        // Assert
        expect(category.id, 'test-uuid-789');
        expect(category.categoryName, '20대');
        expect(category.createdAt, isNull);
      });

      test('should throw FormatException on invalid date format', () {
        // Arrange
        final json = {
          'id': 'test-uuid-999',
          'category_name': '30대',
          'min_age': 30,
          'max_age': 39,
          'created_at': 'invalid-date',
        };

        // Act & Assert
        expect(() => AgeCategory.fromJson(json), throwsFormatException);
      });

      test('should handle edge case min_age of 0', () {
        // Arrange
        final json = {
          'id': 'test-uuid-000',
          'category_name': '유아',
          'min_age': 0,
          'max_age': 9,
          'created_at': '2024-01-01T00:00:00Z',
        };

        // Act
        final category = AgeCategory.fromJson(json);

        // Assert
        expect(category.minAge, 0);
        expect(category.maxAge, 9);
      });

      test('should handle very large age values', () {
        // Arrange
        final json = {
          'id': 'test-uuid-max',
          'category_name': '고령',
          'min_age': 100,
          'max_age': 150,
          'created_at': '2024-01-01T00:00:00Z',
        };

        // Act
        final category = AgeCategory.fromJson(json);

        // Assert
        expect(category.minAge, 100);
        expect(category.maxAge, 150);
      });
    });

    group('toJson', () {
      test('should correctly serialize to JSON with all fields', () {
        // Arrange
        final category = AgeCategory(
          id: 'test-uuid-serialize',
          categoryName: '40대',
          minAge: 40,
          maxAge: 49,
          createdAt: DateTime.parse('2024-06-15T10:30:00Z'),
        );

        // Act
        final json = category.toJson();

        // Assert
        expect(json['id'], 'test-uuid-serialize');
        expect(json['category_name'], '40대');
        expect(json['min_age'], 40);
        expect(json['max_age'], 49);
        expect(json['created_at'], '2024-06-15T10:30:00.000Z');
      });

      test('should serialize null max_age correctly', () {
        // Arrange
        final category = AgeCategory(
          id: 'test-uuid-null-max',
          categoryName: '60대 이상',
          minAge: 60,
          maxAge: null,
          createdAt: DateTime.parse('2024-06-15T10:30:00Z'),
        );

        // Act
        final json = category.toJson();

        // Assert
        expect(json['max_age'], isNull);
        expect(json.containsKey('max_age'), isTrue);
      });

      test('should serialize null created_at correctly', () {
        // Arrange
        final category = AgeCategory(
          id: 'test-uuid-null-created',
          categoryName: '50대',
          minAge: 50,
          maxAge: 59,
          createdAt: null,
        );

        // Act
        final json = category.toJson();

        // Assert
        expect(json['created_at'], isNull);
        expect(json.containsKey('created_at'), isTrue);
      });
    });

    group('Equality and HashCode', () {
      test('should be equal when all fields match', () {
        // Arrange
        final createdAt = DateTime.parse('2024-01-01T00:00:00Z');
        final category1 = AgeCategory(
          id: 'same-id',
          categoryName: '20대',
          minAge: 20,
          maxAge: 29,
          createdAt: createdAt,
        );
        final category2 = AgeCategory(
          id: 'same-id',
          categoryName: '20대',
          minAge: 20,
          maxAge: 29,
          createdAt: createdAt,
        );

        // Act & Assert
        expect(category1, equals(category2));
        expect(category1.hashCode, equals(category2.hashCode));
      });

      test('should not be equal when id differs', () {
        // Arrange
        final category1 = AgeCategory(
          id: 'id-1',
          categoryName: '20대',
          minAge: 20,
          maxAge: 29,
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        );
        final category2 = AgeCategory(
          id: 'id-2',
          categoryName: '20대',
          minAge: 20,
          maxAge: 29,
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        );

        // Act & Assert
        expect(category1, isNot(equals(category2)));
      });

      test('should not be equal when categoryName differs', () {
        // Arrange
        final category1 = AgeCategory(
          id: 'same-id',
          categoryName: '20대',
          minAge: 20,
          maxAge: 29,
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        );
        final category2 = AgeCategory(
          id: 'same-id',
          categoryName: '30대',
          minAge: 20,
          maxAge: 29,
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        );

        // Act & Assert
        expect(category1, isNot(equals(category2)));
      });
    });

    group('JSON Round-trip Serialization', () {
      test('should maintain data integrity through serialize-deserialize cycle', () {
        // Arrange
        final original = AgeCategory(
          id: 'round-trip-id',
          categoryName: '30대',
          minAge: 30,
          maxAge: 39,
          createdAt: DateTime.parse('2024-03-15T14:25:00Z'),
        );

        // Act
        final json = original.toJson();
        final deserialized = AgeCategory.fromJson(json);

        // Assert
        expect(deserialized.id, original.id);
        expect(deserialized.categoryName, original.categoryName);
        expect(deserialized.minAge, original.minAge);
        expect(deserialized.maxAge, original.maxAge);
        expect(deserialized.createdAt, original.createdAt);
      });

      test('should handle round-trip with null values', () {
        // Arrange
        final original = AgeCategory(
          id: 'round-trip-null',
          categoryName: '60대 이상',
          minAge: 60,
          maxAge: null,
          createdAt: null,
        );

        // Act
        final json = original.toJson();
        final deserialized = AgeCategory.fromJson(json);

        // Assert
        expect(deserialized.id, original.id);
        expect(deserialized.categoryName, original.categoryName);
        expect(deserialized.minAge, original.minAge);
        expect(deserialized.maxAge, isNull);
        expect(deserialized.createdAt, isNull);
      });
    });

    group('Edge Cases', () {
      test('should handle empty string category_name', () {
        // Arrange
        final json = {
          'id': 'empty-name',
          'category_name': '',
          'min_age': 10,
          'max_age': 19,
        };

        // Act
        final category = AgeCategory.fromJson(json);

        // Assert
        expect(category.categoryName, '');
      });

      test('should handle very long category_name', () {
        // Arrange
        final longName = 'A' * 1000;
        final json = {
          'id': 'long-name',
          'category_name': longName,
          'min_age': 10,
          'max_age': 19,
        };

        // Act
        final category = AgeCategory.fromJson(json);

        // Assert
        expect(category.categoryName, longName);
        expect(category.categoryName.length, 1000);
      });

      test('should handle min_age equal to max_age', () {
        // Arrange
        final json = {
          'id': 'equal-ages',
          'category_name': 'Same Age',
          'min_age': 25,
          'max_age': 25,
        };

        // Act
        final category = AgeCategory.fromJson(json);

        // Assert
        expect(category.minAge, 25);
        expect(category.maxAge, 25);
      });
    });
  });
}
