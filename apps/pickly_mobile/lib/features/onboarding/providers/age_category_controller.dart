import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'age_category_provider.dart';

/// Selection state for age categories
@immutable
class AgeCategorySelectionState {
  final Set<String> selectedIds;
  final bool isLoading;
  final String? errorMessage;
  final bool isSaving;
  final bool isSaved;

  const AgeCategorySelectionState({
    this.selectedIds = const {},
    this.isLoading = false,
    this.errorMessage,
    this.isSaving = false,
    this.isSaved = false,
  });

  /// Check if selection is valid (minimum 1 selection)
  bool get isValid => selectedIds.isNotEmpty;

  /// Get number of selected categories
  int get selectedCount => selectedIds.length;

  /// Check if a specific ID is selected
  bool isSelected(String id) => selectedIds.contains(id);

  /// Copy with modifications
  AgeCategorySelectionState copyWith({
    Set<String>? selectedIds,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isSaving,
    bool? isSaved,
  }) {
    return AgeCategorySelectionState(
      selectedIds: selectedIds ?? this.selectedIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgeCategorySelectionState &&
        setEquals(other.selectedIds, selectedIds) &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.isSaving == isSaving &&
        other.isSaved == isSaved;
  }

  @override
  int get hashCode => Object.hash(
        selectedIds,
        isLoading,
        errorMessage,
        isSaving,
        isSaved,
      );

  @override
  String toString() => 'AgeCategorySelectionState('
      'selectedIds: $selectedIds, '
      'isLoading: $isLoading, '
      'errorMessage: $errorMessage, '
      'isSaving: $isSaving, '
      'isSaved: $isSaved)';
}

/// StateNotifier for managing age category selection
class AgeCategoryController extends StateNotifier<AgeCategorySelectionState> {
  final Ref ref;

  AgeCategoryController(this.ref) : super(const AgeCategorySelectionState()) {
    _loadSavedSelections();
  }

  /// Load saved selections from Supabase user profile
  /// Falls back to local storage if user is not authenticated
  Future<void> _loadSavedSelections() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final supabase = ref.read(supabaseServiceProvider);

      // Check if Supabase is initialized before accessing it
      if (supabase.isInitialized) {
        final userId = supabase.currentUserId;

        // If user is authenticated, load from Supabase
        if (userId != null) {
          await _loadFromSupabase(userId);
        } else {
          // Otherwise, load from local storage (SharedPreferences)
          await _loadFromLocalStorage();
        }
      } else {
        // Supabase not initialized, use local storage only
        debugPrint('Supabase not initialized, using local storage');
        await _loadFromLocalStorage();
      }

      state = state.copyWith(isLoading: false);
    } catch (e, stackTrace) {
      debugPrint('Error loading saved selections: $e');
      debugPrint('Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load saved selections',
      );
    }
  }

  /// Load selections from Supabase
  Future<void> _loadFromSupabase(String userId) async {
    final supabase = ref.read(supabaseServiceProvider);

    // Safety check: ensure client is initialized
    if (supabase.client == null) {
      debugPrint('Supabase client not available');
      return;
    }

    final response = await supabase.client!
        .from('user_profiles')
        .select('selected_categories')
        .eq('user_id', userId)
        .maybeSingle();

    if (response != null) {
      final selectedCategories = response['selected_categories'] as List?;
      if (selectedCategories != null) {
        final selectedIds = selectedCategories.cast<String>().toSet();
        state = state.copyWith(selectedIds: selectedIds);

        // Sync to local storage as backup
        await _saveToLocalStorage(selectedIds);
      }
    }
  }

  /// Load selections from SharedPreferences (local storage)
  /// This is used when user is not authenticated yet
  Future<void> _loadFromLocalStorage() async {
    // TODO: Implement SharedPreferences loading
    // Example implementation:
    // final prefs = await SharedPreferences.getInstance();
    // final savedJson = prefs.getString(_localStorageKey);
    // if (savedJson != null) {
    //   final List<dynamic> decoded = json.decode(savedJson);
    //   final selectedIds = decoded.cast<String>().toSet();
    //   state = state.copyWith(selectedIds: selectedIds);
    // }

    // For now, just start with empty selections
    debugPrint('Local storage loading not implemented yet (requires shared_preferences package)');
  }

  /// Save selections to local storage (SharedPreferences)
  Future<void> _saveToLocalStorage(Set<String> selectedIds) async {
    // TODO: Implement SharedPreferences saving
    // Example implementation:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString(_localStorageKey, json.encode(selectedIds.toList()));

    debugPrint('Local storage saving not implemented yet (requires shared_preferences package)');
  }

  /// Select a single category (clears previous selection)
  /// Use this for single-selection screens
  void selectCategory(String categoryId) {
    state = state.copyWith(
      selectedIds: {categoryId},
      isSaved: false,
      clearError: true,
    );
  }

  /// Toggle selection of a category
  void toggleSelection(String categoryId) {
    final newSelectedIds = Set<String>.from(state.selectedIds);

    if (newSelectedIds.contains(categoryId)) {
      newSelectedIds.remove(categoryId);
    } else {
      newSelectedIds.add(categoryId);
    }

    state = state.copyWith(
      selectedIds: newSelectedIds,
      isSaved: false,
      clearError: true,
    );
  }

  /// Select multiple categories at once
  void selectMultiple(List<String> categoryIds) {
    final newSelectedIds = Set<String>.from(state.selectedIds);
    newSelectedIds.addAll(categoryIds);

    state = state.copyWith(
      selectedIds: newSelectedIds,
      isSaved: false,
      clearError: true,
    );
  }

  /// Clear all selections
  void clearSelections() {
    state = state.copyWith(
      selectedIds: const {},
      isSaved: false,
      clearError: true,
    );
  }

  /// Clear selection (alias for clearSelections for backward compatibility)
  void clearSelection() {
    clearSelections();
  }

  /// Validate selection (minimum 1 required)
  bool validate() {
    if (!state.isValid) {
      state = state.copyWith(
        errorMessage: '최소 1개 이상의 연령/세대를 선택해주세요',
      );
      return false;
    }

    state = state.copyWith(clearError: true);
    return true;
  }

  /// Save selections to Supabase and local storage
  Future<bool> saveToSupabase() async {
    // Validate before saving
    if (!validate()) {
      return false;
    }

    try {
      state = state.copyWith(isSaving: true, clearError: true);

      final supabase = ref.read(supabaseServiceProvider);

      // Save to local storage first (always)
      await _saveToLocalStorage(state.selectedIds);

      // If Supabase is initialized and user is authenticated, also save to Supabase
      if (supabase.isInitialized && supabase.client != null) {
        final userId = supabase.currentUserId;

        if (userId != null) {
          final selectedList = state.selectedIds.toList();

          // Validate that the category IDs exist in the database
          final repository = ref.read(ageCategoryRepositoryProvider);
          final areValid = await repository.validateCategoryIds(selectedList);

          if (!areValid) {
            state = state.copyWith(
              isSaving: false,
              errorMessage: '선택한 카테고리가 유효하지 않습니다',
            );
            return false;
          }

          // Upsert user profile with selected categories
          await supabase.client!.from('user_profiles').upsert({
            'user_id': userId,
            'selected_categories': selectedList,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id');
        }
      }

      state = state.copyWith(
        isSaving: false,
        isSaved: true,
      );

      return true;
    } catch (e, stackTrace) {
      debugPrint('Error saving age category selections: $e');
      debugPrint('Stack trace: $stackTrace');

      state = state.copyWith(
        isSaving: false,
        errorMessage: '저장에 실패했습니다. 다시 시도해주세요.',
      );

      return false;
    }
  }

  /// Save selections and continue (for onboarding flow)
  /// This is the main method called by the UI when user taps "다음" button
  Future<bool> saveAndContinue() async {
    return await saveToSupabase();
  }

  /// Save and proceed to next onboarding screen
  /// This is the main method called by the UI when user taps "다음" button
  Future<bool> saveAndProceed(BuildContext context) async {
    // Save selections
    final success = await saveToSupabase();

    if (success) {
      // TODO: Navigate to next onboarding screen
      // Example navigation (requires go_router or Navigator):
      // context.go('/onboarding/next-screen');
      // OR
      // Navigator.of(context).pushNamed('/onboarding/next-screen');

      debugPrint('Navigation not implemented yet (requires routing setup)');
      debugPrint('Would navigate to next onboarding screen with selections: ${state.selectedIds}');
    }

    return success;
  }

  /// Refresh saved selections from server
  Future<void> refresh() async {
    await _loadSavedSelections();
  }

  /// Reset state to initial
  void reset() {
    state = const AgeCategorySelectionState();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for age category selection controller
final ageCategoryControllerProvider =
    StateNotifierProvider<AgeCategoryController, AgeCategorySelectionState>(
  (ref) => AgeCategoryController(ref),
);

/// Convenience provider to check if current selection is valid
final isAgeCategorySelectionValidProvider = Provider<bool>((ref) {
  final selectionState = ref.watch(ageCategoryControllerProvider);
  return selectionState.isValid;
});

/// Provider to get selected category IDs as a list
final selectedAgeCategoryIdsProvider = Provider<List<String>>((ref) {
  final selectionState = ref.watch(ageCategoryControllerProvider);
  return selectionState.selectedIds.toList();
});

/// Provider to get count of selected categories
final selectedAgeCategoryCountProvider = Provider<int>((ref) {
  final selectionState = ref.watch(ageCategoryControllerProvider);
  return selectionState.selectedCount;
});

/// Provider to check if a specific category is selected
final isAgeCategorySelectedProvider = Provider.family<bool, String>((ref, categoryId) {
  final selectionState = ref.watch(ageCategoryControllerProvider);
  return selectionState.isSelected(categoryId);
});

/// Provider to check if "Next" button should be enabled
/// Returns true when at least 1 category is selected and not currently saving
final isNextButtonEnabledProvider = Provider<bool>((ref) {
  final selectionState = ref.watch(ageCategoryControllerProvider);
  return selectionState.isValid && !selectionState.isSaving;
});

/// Provider to check if data is currently being loaded
final isLoadingAgeCategoriesProvider = Provider<bool>((ref) {
  final selectionState = ref.watch(ageCategoryControllerProvider);
  final asyncCategories = ref.watch(ageCategoryProvider);
  return selectionState.isLoading || asyncCategories.isLoading;
});

/// Provider to get the current error message (if any)
final ageCategoryErrorMessageProvider = Provider<String?>((ref) {
  final selectionState = ref.watch(ageCategoryControllerProvider);
  return selectionState.errorMessage;
});
