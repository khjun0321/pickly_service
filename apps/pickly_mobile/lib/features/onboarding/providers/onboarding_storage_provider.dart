import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pickly_mobile/features/onboarding/services/onboarding_storage_service.dart';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

/// Provider for OnboardingStorageService
final onboardingStorageServiceProvider = Provider<OnboardingStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingStorageService(prefs);
});

/// Provider to check if onboarding is completed
final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  final storage = ref.watch(onboardingStorageServiceProvider);
  final value = storage.hasCompletedOnboarding();
  print('📦 [Storage] hasCompletedOnboarding: $value');
  return value;
});

/// Provider to get selected age category ID
final selectedAgeCategoryIdProvider = Provider<String?>((ref) {
  final storage = ref.watch(onboardingStorageServiceProvider);
  return storage.getSelectedAgeCategoryId();
});

/// Provider to get selected region IDs
final selectedRegionIdsProvider = Provider<List<String>>((ref) {
  final storage = ref.watch(onboardingStorageServiceProvider);
  return storage.getSelectedRegionIds();
});
