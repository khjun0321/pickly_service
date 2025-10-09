/// Generic Onboarding State Model
///
/// Provides a reusable state management structure for onboarding screens
/// with selection tracking, validation, and loading states.
///
/// Designed to work with Riverpod state management for type-safe,
/// immutable state handling across all onboarding steps.
library;

import 'package:flutter/foundation.dart';

/// Generic state model for onboarding screens with item selection.
///
/// Type parameter [T] represents the type of items being displayed
/// and selected (e.g., [AgeCategory], Region, Policy, etc.).
///
/// This model supports:
/// - Single or multiple selection modes
/// - Loading and error states
/// - Validation tracking
/// - Type-safe item management
@immutable
class OnboardingState<T> {
  /// List of available items to select from
  final List<T> items;

  /// Set of currently selected item IDs (UUIDs)
  final Set<String> selectedIds;

  /// Whether data is currently being loaded
  final bool isLoading;

  /// Error message if an error occurred (null if no error)
  final String? errorMessage;

  /// Whether the current selection is valid per validation rules
  final bool isValid;

  /// Minimum number of required selections (from screen config)
  final int minSelection;

  /// Maximum number of allowed selections (null for unlimited)
  final int? maxSelection;

  /// Creates an immutable [OnboardingState] instance.
  const OnboardingState({
    required this.items,
    required this.selectedIds,
    this.isLoading = false,
    this.errorMessage,
    this.isValid = false,
    this.minSelection = 1,
    this.maxSelection,
  });

  /// Creates an initial empty state.
  factory OnboardingState.initial({
    int minSelection = 1,
    int? maxSelection,
  }) {
    return OnboardingState<T>(
      items: const [],
      selectedIds: const {},
      isLoading: true,
      isValid: false,
      minSelection: minSelection,
      maxSelection: maxSelection,
    );
  }

  /// Creates a loading state.
  OnboardingState<T> setLoading(bool loading) {
    return copyWith(isLoading: loading);
  }

  /// Creates a state with loaded items.
  OnboardingState<T> setItems(List<T> items) {
    return copyWith(
      items: items,
      isLoading: false,
      errorMessage: null,
    );
  }

  /// Creates a state with an error.
  OnboardingState<T> setError(String error) {
    return copyWith(
      isLoading: false,
      errorMessage: error,
    );
  }

  /// Toggles selection of an item by ID.
  ///
  /// For single selection mode (maxSelection = 1), replaces current selection.
  /// For multiple selection mode, adds/removes from the set.
  OnboardingState<T> toggleSelection(String id) {
    final newSelectedIds = Set<String>.from(selectedIds);

    if (maxSelection == 1) {
      // Single selection mode: replace selection
      newSelectedIds.clear();
      newSelectedIds.add(id);
    } else {
      // Multiple selection mode: toggle
      if (newSelectedIds.contains(id)) {
        newSelectedIds.remove(id);
      } else {
        // Check max selection limit
        if (maxSelection != null && newSelectedIds.length >= maxSelection!) {
          return this; // Cannot add more selections
        }
        newSelectedIds.add(id);
      }
    }

    return copyWith(
      selectedIds: newSelectedIds,
      isValid: _validateSelection(newSelectedIds),
    );
  }

  /// Clears all selections.
  OnboardingState<T> clearSelections() {
    return copyWith(
      selectedIds: const {},
      isValid: false,
    );
  }

  /// Sets multiple selections at once.
  OnboardingState<T> setSelections(Set<String> ids) {
    return copyWith(
      selectedIds: ids,
      isValid: _validateSelection(ids),
    );
  }

  /// Validates the current selection against min/max rules.
  bool _validateSelection(Set<String> ids) {
    if (ids.length < minSelection) return false;
    if (maxSelection != null && ids.length > maxSelection!) return false;
    return true;
  }

  /// Checks if a specific item is selected.
  bool isSelected(String id) => selectedIds.contains(id);

  /// Gets the count of selected items.
  int get selectedCount => selectedIds.length;

  /// Checks if selection is at maximum capacity.
  bool get isAtMaxSelection =>
      maxSelection != null && selectedIds.length >= maxSelection!;

  /// Creates a copy with optional field overrides.
  OnboardingState<T> copyWith({
    List<T>? items,
    Set<String>? selectedIds,
    bool? isLoading,
    String? errorMessage,
    bool? isValid,
    int? minSelection,
    int? maxSelection,
  }) {
    return OnboardingState<T>(
      items: items ?? this.items,
      selectedIds: selectedIds ?? this.selectedIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isValid: isValid ?? this.isValid,
      minSelection: minSelection ?? this.minSelection,
      maxSelection: maxSelection ?? this.maxSelection,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingState<T> &&
        listEquals(other.items, items) &&
        setEquals(other.selectedIds, selectedIds) &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.isValid == isValid &&
        other.minSelection == minSelection &&
        other.maxSelection == maxSelection;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(items),
      Object.hashAll(selectedIds),
      isLoading,
      errorMessage,
      isValid,
      minSelection,
      maxSelection,
    );
  }

  @override
  String toString() {
    return 'OnboardingState<$T>('
        'items: ${items.length}, '
        'selectedIds: $selectedIds, '
        'isLoading: $isLoading, '
        'errorMessage: $errorMessage, '
        'isValid: $isValid, '
        'minSelection: $minSelection, '
        'maxSelection: $maxSelection)';
  }
}
