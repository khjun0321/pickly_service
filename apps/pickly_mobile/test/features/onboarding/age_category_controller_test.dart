import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pickly_mobile/features/onboarding/providers/age_category_controller.dart';
import 'package:pickly_mobile/repositories/age_category_repository.dart';
import 'package:pickly_mobile/models/age_category.dart';

// Generate mocks for repository
@GenerateNiceMocks([MockSpec<AgeCategoryRepository>()])
import 'age_category_controller_test.mocks.dart';

void main() {
  late MockAgeCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockAgeCategoryRepository();
  });

  group('AgeCategorySelectionState Tests', () {
    group('Initialization', () {
      test('should initialize with default empty state', () {
        // Arrange & Act
        const state = AgeCategorySelectionState();

        // Assert
        expect(state.selectedIds, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.errorMessage, isNull);
        expect(state.isSaving, isFalse);
        expect(state.isSaved, isFalse);
        expect(state.isValid, isFalse);
        expect(state.selectedCount, 0);
      });
    });

    group('Selection State', () {
      test('should track selected category IDs', () {
        // Arrange & Act
        const state = AgeCategorySelectionState(
          selectedIds: {'cat-1', 'cat-2'},
        );

        // Assert
        expect(state.selectedIds, {'cat-1', 'cat-2'});
        expect(state.selectedCount, 2);
        expect(state.isValid, isTrue);
      });

      test('should check if specific ID is selected', () {
        // Arrange
        const state = AgeCategorySelectionState(
          selectedIds: {'cat-1', 'cat-2'},
        );

        // Act & Assert
        expect(state.isSelected('cat-1'), isTrue);
        expect(state.isSelected('cat-2'), isTrue);
        expect(state.isSelected('cat-3'), isFalse);
      });

      test('should toggle selection correctly', () {
        // Arrange
        const initialState = AgeCategorySelectionState(
          selectedIds: {'cat-1'},
        );

        // Act - Toggle cat-2 (add)
        final stateWithCat2 = initialState.toggleSelection('cat-2');

        // Assert
        expect(stateWithCat2.selectedIds, {'cat-1', 'cat-2'});
        expect(stateWithCat2.selectedCount, 2);

        // Act - Toggle cat-1 (remove)
        final stateWithoutCat1 = stateWithCat2.toggleSelection('cat-1');

        // Assert
        expect(stateWithoutCat1.selectedIds, {'cat-2'});
        expect(stateWithoutCat1.selectedCount, 1);
      });

      test('should clear all selections', () {
        // Arrange
        const state = AgeCategorySelectionState(
          selectedIds: {'cat-1', 'cat-2', 'cat-3'},
        );

        // Act
        final clearedState = state.clearSelection();

        // Assert
        expect(clearedState.selectedIds, isEmpty);
        expect(clearedState.selectedCount, 0);
        expect(clearedState.isValid, isFalse);
      });
    });

    group('Validation', () {
      test('should be invalid when no categories selected', () {
        // Arrange & Act
        const state = AgeCategorySelectionState();

        // Assert
        expect(state.isValid, isFalse);
      });

      test('should be valid when at least one category selected', () {
        // Arrange & Act
        const state = AgeCategorySelectionState(
          selectedIds: {'cat-1'},
        );

        // Assert
        expect(state.isValid, isTrue);
      });

      test('should count selected categories correctly', () {
        // Arrange & Act
        const state = AgeCategorySelectionState(
          selectedIds: {'cat-1', 'cat-2', 'cat-3'},
        );

        // Assert
        expect(state.selectedCount, 3);
      });
    });

    group('Loading State', () {
      test('should track loading state', () {
        // Arrange & Act
        const state = AgeCategorySelectionState(isLoading: true);

        // Assert
        expect(state.isLoading, isTrue);
      });

      test('should set loading state with copyWith', () {
        // Arrange
        const initialState = AgeCategorySelectionState();

        // Act
        final loadingState = initialState.copyWith(isLoading: true);

        // Assert
        expect(loadingState.isLoading, isTrue);
        expect(initialState.isLoading, isFalse);
      });
    });

    group('Saving State', () {
      test('should track saving state', () {
        // Arrange & Act
        const state = AgeCategorySelectionState(isSaving: true);

        // Assert
        expect(state.isSaving, isTrue);
      });

      test('should track saved state', () {
        // Arrange & Act
        const state = AgeCategorySelectionState(isSaved: true);

        // Assert
        expect(state.isSaved, isTrue);
      });

      test('should transition through saving states', () {
        // Arrange
        const initialState = AgeCategorySelectionState(
          selectedIds: {'cat-1'},
        );

        // Act - Start saving
        final savingState = initialState.copyWith(isSaving: true);

        // Assert
        expect(savingState.isSaving, isTrue);
        expect(savingState.isSaved, isFalse);

        // Act - Finish saving
        final savedState = savingState.copyWith(
          isSaving: false,
          isSaved: true,
        );

        // Assert
        expect(savedState.isSaving, isFalse);
        expect(savedState.isSaved, isTrue);
      });
    });

    group('Error State', () {
      test('should track error messages', () {
        // Arrange & Act
        const state = AgeCategorySelectionState(
          errorMessage: 'Failed to load categories',
        );

        // Assert
        expect(state.errorMessage, 'Failed to load categories');
      });

      test('should clear error messages', () {
        // Arrange
        const stateWithError = AgeCategorySelectionState(
          errorMessage: 'Some error',
        );

        // Act
        final clearedState = stateWithError.copyWith(
          errorMessage: () => null,
        );

        // Assert
        expect(clearedState.errorMessage, isNull);
      });
    });

    group('State Immutability', () {
      test('should return new instance on copyWith', () {
        // Arrange
        const initialState = AgeCategorySelectionState();

        // Act
        final newState = initialState.copyWith(isLoading: true);

        // Assert
        expect(newState, isNot(same(initialState)));
        expect(initialState.isLoading, isFalse);
        expect(newState.isLoading, isTrue);
      });

      test('should preserve unmodified fields on copyWith', () {
        // Arrange
        const initialState = AgeCategorySelectionState(
          selectedIds: {'cat-1'},
          isLoading: false,
          errorMessage: 'Error',
        );

        // Act
        final newState = initialState.copyWith(isLoading: true);

        // Assert
        expect(newState.selectedIds, initialState.selectedIds);
        expect(newState.errorMessage, initialState.errorMessage);
        expect(newState.isLoading, isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle empty string ID selection', () {
        // Arrange
        const state = AgeCategorySelectionState();

        // Act
        final newState = state.toggleSelection('');

        // Assert
        expect(newState.selectedIds, {''}); // Empty string is a valid ID
        expect(newState.isValid, isTrue);
      });

      test('should handle very long selection sets', () {
        // Arrange
        final largeSet = Set<String>.from(
          List.generate(1000, (index) => 'cat-$index'),
        );

        // Act
        final state = AgeCategorySelectionState(selectedIds: largeSet);

        // Assert
        expect(state.selectedCount, 1000);
        expect(state.isValid, isTrue);
      });

      test('should handle rapid toggles on same ID', () {
        // Arrange
        const initialState = AgeCategorySelectionState();

        // Act
        final state1 = initialState.toggleSelection('cat-1');
        final state2 = state1.toggleSelection('cat-1');
        final state3 = state2.toggleSelection('cat-1');

        // Assert
        expect(state1.isSelected('cat-1'), isTrue);
        expect(state2.isSelected('cat-1'), isFalse);
        expect(state3.isSelected('cat-1'), isTrue);
      });

      test('should handle special characters in IDs', () {
        // Arrange
        const specialIds = {'cat-!@#', 'cat-한글', 'cat-🎉'};
        const state = AgeCategorySelectionState(selectedIds: specialIds);

        // Act & Assert
        expect(state.selectedCount, 3);
        expect(state.isSelected('cat-!@#'), isTrue);
        expect(state.isSelected('cat-한글'), isTrue);
        expect(state.isSelected('cat-🎉'), isTrue);
      });
    });

    group('Equality', () {
      test('should be equal when all fields match', () {
        // Arrange
        const state1 = AgeCategorySelectionState(
          selectedIds: {'cat-1'},
          isLoading: false,
        );
        const state2 = AgeCategorySelectionState(
          selectedIds: {'cat-1'},
          isLoading: false,
        );

        // Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal when fields differ', () {
        // Arrange
        const state1 = AgeCategorySelectionState(
          selectedIds: {'cat-1'},
        );
        const state2 = AgeCategorySelectionState(
          selectedIds: {'cat-2'},
        );

        // Assert
        expect(state1, isNot(equals(state2)));
      });
    });
  });
}
