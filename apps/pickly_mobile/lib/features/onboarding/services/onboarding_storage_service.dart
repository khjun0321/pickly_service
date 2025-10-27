import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding data storage service using SharedPreferences
///
/// Stores and retrieves:
/// - Onboarding completion status
/// - Selected age category ID
/// - Selected region IDs
/// - Selected program types by category (혜택 화면의 공고 선택)
class OnboardingStorageService {
  // Storage keys
  static const String _keyHasCompletedOnboarding = 'has_completed_onboarding';
  static const String _keySelectedAgeCategoryId = 'selected_age_category_id';
  static const String _keySelectedRegionIds = 'selected_region_ids';
  static const String _keyProgramTypePrefix = 'selected_program_type_';

  final SharedPreferences _prefs;

  OnboardingStorageService(this._prefs);

  /// Check if user has completed onboarding
  bool hasCompletedOnboarding() {
    return _prefs.getBool(_keyHasCompletedOnboarding) ?? false;
  }

  /// Get selected age category ID
  String? getSelectedAgeCategoryId() {
    return _prefs.getString(_keySelectedAgeCategoryId);
  }

  /// Get selected region IDs
  List<String> getSelectedRegionIds() {
    return _prefs.getStringList(_keySelectedRegionIds) ?? [];
  }

  /// Save onboarding completion with selected values
  Future<void> saveOnboardingData({
    required String ageCategoryId,
    required List<String> regionIds,
  }) async {
    await _prefs.setBool(_keyHasCompletedOnboarding, true);
    await _prefs.setString(_keySelectedAgeCategoryId, ageCategoryId);
    await _prefs.setStringList(_keySelectedRegionIds, regionIds);
  }

  /// Clear all onboarding data (for testing/reset)
  Future<void> clearOnboardingData() async {
    await _prefs.remove(_keyHasCompletedOnboarding);
    await _prefs.remove(_keySelectedAgeCategoryId);
    await _prefs.remove(_keySelectedRegionIds);
  }

  /// Update age category selection
  Future<void> updateAgeCategoryId(String ageCategoryId) async {
    await _prefs.setString(_keySelectedAgeCategoryId, ageCategoryId);
  }

  /// Update region selections
  Future<void> updateRegionIds(List<String> regionIds) async {
    await _prefs.setStringList(_keySelectedRegionIds, regionIds);
  }

  // ============================================================
  // Program Type Selection (혜택 화면 공고 선택)
  // ============================================================

  /// Get selected program types for a specific category (supports multiple selection)
  ///
  /// Returns empty list if no program types are selected (전체 선택)
  ///
  /// Example:
  /// ```dart
  /// final programTypes = storage.getSelectedProgramTypes('housing');
  /// // Returns: ['행복주택', '국민임대주택'] or [] (전체)
  /// ```
  List<String> getSelectedProgramTypes(String categoryId) {
    return _prefs.getStringList('$_keyProgramTypePrefix$categoryId') ?? [];
  }

  /// Set selected program types for a specific category (supports multiple selection)
  ///
  /// Pass empty list to reset to '전체'
  ///
  /// Example:
  /// ```dart
  /// await storage.setSelectedProgramTypes('housing', ['행복주택', '국민임대주택']);
  /// await storage.setSelectedProgramTypes('housing', []); // Reset to 전체
  /// ```
  Future<void> setSelectedProgramTypes(
    String categoryId,
    List<String> programTypes,
  ) async {
    if (programTypes.isEmpty) {
      await _prefs.remove('$_keyProgramTypePrefix$categoryId');
    } else {
      await _prefs.setStringList('$_keyProgramTypePrefix$categoryId', programTypes);
    }
  }

  /// Get all selected program types as a map (supports multiple selection)
  ///
  /// Returns: { 'housing': ['행복주택', '국민임대주택'], 'education': ['학자금 지원'], ... }
  Map<String, List<String>> getAllSelectedProgramTypes() {
    final result = <String, List<String>>{};
    final keys = _prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_keyProgramTypePrefix)) {
        final categoryId = key.substring(_keyProgramTypePrefix.length);

        // Try to get as list first (new format)
        try {
          final programTypes = _prefs.getStringList(key);
          if (programTypes != null && programTypes.isNotEmpty) {
            result[categoryId] = programTypes;
          }
        } catch (e) {
          // If that fails, try to migrate from old String format
          try {
            final oldValue = _prefs.getString(key);
            if (oldValue != null && oldValue.isNotEmpty) {
              // Migrate to new format
              _prefs.setStringList(key, [oldValue]);
              result[categoryId] = [oldValue];
            }
          } catch (migrationError) {
            // If migration also fails, just skip this key
            print('Failed to migrate program type for $categoryId: $migrationError');
          }
        }
      }
    }

    return result;
  }

  // Legacy single selection methods (kept for backward compatibility)

  /// Get selected program type for a specific category (single selection - deprecated)
  @Deprecated('Use getSelectedProgramTypes instead')
  String? getSelectedProgramType(String categoryId) {
    final types = getSelectedProgramTypes(categoryId);
    return types.isNotEmpty ? types.first : null;
  }

  /// Set selected program type for a specific category (single selection - deprecated)
  @Deprecated('Use setSelectedProgramTypes instead')
  Future<void> setSelectedProgramType(
    String categoryId,
    String? programType,
  ) async {
    if (programType == null) {
      await setSelectedProgramTypes(categoryId, []);
    } else {
      await setSelectedProgramTypes(categoryId, [programType]);
    }
  }

  /// Clear all selected program types
  Future<void> clearAllProgramTypes() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyProgramTypePrefix)) {
        await _prefs.remove(key);
      }
    }
  }
}
