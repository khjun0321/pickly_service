import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding data storage service using SharedPreferences
///
/// Stores and retrieves:
/// - Onboarding completion status
/// - Selected age category ID
/// - Selected region IDs
class OnboardingStorageService {
  // Storage keys
  static const String _keyHasCompletedOnboarding = 'has_completed_onboarding';
  static const String _keySelectedAgeCategoryId = 'selected_age_category_id';
  static const String _keySelectedRegionIds = 'selected_region_ids';

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
}
