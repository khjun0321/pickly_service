import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_mobile/features/onboarding/providers/age_category_selection_provider.dart';

void main() {
  group('AgeCategorySelectionNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('should start with no selection', () {
        // Act
        final state = container.read(ageCategorySelectionProvider);

        // Assert
        expect(state.selectedCategory, isNull);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });
    });

    group('selectCategory()', () {
      test('should select a category', () {
        // Arrange
        final notifier = container.read(ageCategorySelectionProvider.notifier);

        // Act
        notifier.selectCategory('cat-1');

        // Assert
        final state = container.read(ageCategorySelectionProvider);
        expect(state.selectedCategory, 'cat-1');
        expect(state.error, isNull);
      });

      test('should replace previous selection (single selection)', () {
        // Arrange
        final notifier = container.read(ageCategorySelectionProvider.notifier);

        // Act - Select first category
        notifier.selectCategory('cat-1');
        var state = container.read(ageCategorySelectionProvider);
        expect(state.selectedCategory, 'cat-1');

        // Act - Select second category (should replace)
        notifier.selectCategory('cat-2');
        state = container.read(ageCategorySelectionProvider);

        // Assert
        expect(state.selectedCategory, 'cat-2');
      });

      test('should clear error when selecting', () {
        // Arrange
        final notifier = container.read(ageCategorySelectionProvider.notifier);

        // Set an error first
        notifier.state = notifier.state.copyWith(error: 'Test error');

        // Act
        notifier.selectCategory('cat-1');

        // Assert
        final state = container.read(ageCategorySelectionProvider);
        expect(state.error, isNull);
      });

      test('should handle selecting same category twice', () {
        // Arrange
        final notifier = container.read(ageCategorySelectionProvider.notifier);

        // Act
        notifier.selectCategory('cat-1');
        notifier.selectCategory('cat-1');

        // Assert
        final state = container.read(ageCategorySelectionProvider);
        expect(state.selectedCategory, 'cat-1');
      });
    });

    group('clearSelection()', () {
      test('should clear selected category', () {
        // Arrange
        final notifier = container.read(ageCategorySelectionProvider.notifier);
        notifier.selectCategory('cat-1');

        // Act
        notifier.clearSelection();

        // Assert
        final state = container.read(ageCategorySelectionProvider);
        expect(state.selectedCategory, isNull);
      });

      test('should handle clearing when nothing selected', () {
        // Arrange
        final notifier = container.read(ageCategorySelectionProvider.notifier);

        // Act
        notifier.clearSelection();

        // Assert
        final state = container.read(ageCategorySelectionProvider);
        expect(state.selectedCategory, isNull);
      });
    });

    group('saveAndContinue()', () {
      test('should save selected category successfully', () async {
        // Arrange
        final notifier = container.read(ageCategorySelectionProvider.notifier);
        notifier.selectCategory('cat-1');

        // Act
        await notifier.saveAndContinue();

        // Assert
        final state = container.read(ageCategorySelectionProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.selectedCategory, 'cat-1');
      });

      test('should set loading state during save', () async {
        // Arrange
        final notifier = container.read(ageCategorySelectionProvider.notifier);
        notifier.selectCategory('cat-1');

        // Act - Start save but don't await
        final saveFuture = notifier.saveAndContinue();

        // Check loading state immediately
        await Future.delayed(Duration.zero);
        var state = container.read(ageCategorySelectionProvider);
        expect(state.isLoading, isTrue);

        // Complete save
        await saveFuture;

        // Assert final state
        state = container.read(ageCategorySelectionProvider);
        expect(state.isLoading, isFalse);
      });

      test('should do nothing when no category selected', () async {
        // Arrange
        final notifier = container.read(ageCategorySelectionProvider.notifier);

        // Act
        await notifier.saveAndContinue();

        // Assert
        final state = container.read(ageCategorySelectionProvider);
        expect(state.isLoading, isFalse);
        expect(state.selectedCategory, isNull);
      });

      test('should preserve selection on successful save', () async {
        // Arrange
        final notifier = container.read(ageCategorySelectionProvider.notifier);
        notifier.selectCategory('cat-preserve');

        // Act
        await notifier.saveAndContinue();

        // Assert
        final state = container.read(ageCategorySelectionProvider);
        expect(state.selectedCategory, 'cat-preserve');
      });
    });

    group('reset()', () {
      test('should reset to initial state', () {
        // Arrange
        final notifier = container.read(ageCategorySelectionProvider.notifier);
        notifier.selectCategory('cat-1');
        notifier.state = notifier.state.copyWith(error: 'Test error');

        // Act
        notifier.reset();

        // Assert
        final state = container.read(ageCategorySelectionProvider);
        expect(state.selectedCategory, isNull);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });
    });

    group('copyWith()', () {
      test('should copy state with updated fields', () {
        // Arrange
        const originalState = AgeCategorySelectionState(
          selectedCategory: 'cat-1',
          isLoading: false,
          error: null,
        );

        // Act
        final newState = originalState.copyWith(
          selectedCategory: 'cat-2',
          isLoading: true,
        );

        // Assert
        expect(newState.selectedCategory, 'cat-2');
        expect(newState.isLoading, isTrue);
        expect(newState.error, isNull);
      });

      test('should preserve original values when not overridden', () {
        // Arrange
        const originalState = AgeCategorySelectionState(
          selectedCategory: 'cat-1',
          isLoading: true,
          error: 'Some error',
        );

        // Act
        final newState = originalState.copyWith(isLoading: false);

        // Assert
        expect(newState.selectedCategory, 'cat-1');
        expect(newState.isLoading, isFalse);
        expect(newState.error, 'Some error');
      });
    });
  });

  group('Computed Providers Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('hasSelectionProvider', () {
      test('should return true when category is selected', () {
        // Arrange
        final notifier = container.read(ageCategorySelectionProvider.notifier);
        notifier.selectCategory('cat-1');

        // Act
        final hasSelection = container.read(hasSelectionProvider);

        // Assert
        expect(hasSelection, isTrue);
      });

      test('should return false when no category selected', () {
        // Act
        final hasSelection = container.read(hasSelectionProvider);

        // Assert
        expect(hasSelection, isFalse);
      });

      test('should update when selection changes', () {
        // Arrange
        final notifier = container.read(ageCategorySelectionProvider.notifier);

        // Initial state
        var hasSelection = container.read(hasSelectionProvider);
        expect(hasSelection, isFalse);

        // Select category
        notifier.selectCategory('cat-1');
        hasSelection = container.read(hasSelectionProvider);
        expect(hasSelection, isTrue);

        // Clear selection
        notifier.clearSelection();
        hasSelection = container.read(hasSelectionProvider);
        expect(hasSelection, isFalse);
      });
    });

    group('selectedCategoryIdProvider', () {
      test('should return selected category ID', () {
        // Arrange
        final notifier = container.read(ageCategorySelectionProvider.notifier);
        notifier.selectCategory('cat-123');

        // Act
        final selectedId = container.read(selectedCategoryIdProvider);

        // Assert
        expect(selectedId, 'cat-123');
      });

      test('should return null when nothing selected', () {
        // Act
        final selectedId = container.read(selectedCategoryIdProvider);

        // Assert
        expect(selectedId, isNull);
      });

      test('should update when selection changes', () {
        // Arrange
        final notifier = container.read(ageCategorySelectionProvider.notifier);

        // Initial state
        var selectedId = container.read(selectedCategoryIdProvider);
        expect(selectedId, isNull);

        // Select first category
        notifier.selectCategory('cat-1');
        selectedId = container.read(selectedCategoryIdProvider);
        expect(selectedId, 'cat-1');

        // Select different category
        notifier.selectCategory('cat-2');
        selectedId = container.read(selectedCategoryIdProvider);
        expect(selectedId, 'cat-2');
      });
    });
  });

  group('Integration Tests', () {
    test('should handle complete user flow', () async {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(ageCategorySelectionProvider.notifier);

      // Act & Assert - Initial state
      var state = container.read(ageCategorySelectionProvider);
      expect(state.selectedCategory, isNull);
      expect(container.read(hasSelectionProvider), isFalse);

      // Act & Assert - Select category
      notifier.selectCategory('youth');
      state = container.read(ageCategorySelectionProvider);
      expect(state.selectedCategory, 'youth');
      expect(container.read(hasSelectionProvider), isTrue);
      expect(container.read(selectedCategoryIdProvider), 'youth');

      // Act & Assert - Change selection
      notifier.selectCategory('senior');
      state = container.read(ageCategorySelectionProvider);
      expect(state.selectedCategory, 'senior');
      expect(container.read(selectedCategoryIdProvider), 'senior');

      // Act & Assert - Save
      await notifier.saveAndContinue();
      state = container.read(ageCategorySelectionProvider);
      expect(state.selectedCategory, 'senior');
      expect(state.error, isNull);

      // Act & Assert - Reset
      notifier.reset();
      state = container.read(ageCategorySelectionProvider);
      expect(state.selectedCategory, isNull);
      expect(container.read(hasSelectionProvider), isFalse);

      container.dispose();
    });

    test('should handle rapid selection changes', () {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(ageCategorySelectionProvider.notifier);

      // Act - Rapid selections
      for (var i = 0; i < 10; i++) {
        notifier.selectCategory('cat-$i');
      }

      // Assert - Should have last selection
      final state = container.read(ageCategorySelectionProvider);
      expect(state.selectedCategory, 'cat-9');

      container.dispose();
    });

    test('should maintain state consistency during concurrent operations',
        () async {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(ageCategorySelectionProvider.notifier);
      notifier.selectCategory('cat-1');

      // Act - Start multiple save operations
      final futures = [
        notifier.saveAndContinue(),
        notifier.saveAndContinue(),
        notifier.saveAndContinue(),
      ];

      await Future.wait(futures);

      // Assert - State should be consistent
      final state = container.read(ageCategorySelectionProvider);
      expect(state.selectedCategory, 'cat-1');
      expect(state.isLoading, isFalse);

      container.dispose();
    });
  });

  group('Edge Cases', () {
    test('should handle empty string category ID', () {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(ageCategorySelectionProvider.notifier);

      // Act
      notifier.selectCategory('');

      // Assert
      final state = container.read(ageCategorySelectionProvider);
      expect(state.selectedCategory, '');
      expect(container.read(hasSelectionProvider), isTrue);

      container.dispose();
    });

    test('should handle very long category ID', () {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(ageCategorySelectionProvider.notifier);
      final longId = 'category-' * 1000;

      // Act
      notifier.selectCategory(longId);

      // Assert
      final state = container.read(ageCategorySelectionProvider);
      expect(state.selectedCategory, longId);

      container.dispose();
    });

    test('should handle special characters in category ID', () {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(ageCategorySelectionProvider.notifier);
      final specialId = 'cat-😀-한글-@#\$%';

      // Act
      notifier.selectCategory(specialId);

      // Assert
      final state = container.read(ageCategorySelectionProvider);
      expect(state.selectedCategory, specialId);

      container.dispose();
    });

    test('should handle save when container is disposed', () async {
      // Arrange
      final container = ProviderContainer();
      final notifier = container.read(ageCategorySelectionProvider.notifier);
      notifier.selectCategory('cat-1');

      // Dispose container before save completes
      container.dispose();

      // Act & Assert - Should not throw
      expect(() async => await notifier.saveAndContinue(), returnsNormally);
    });
  });
}
