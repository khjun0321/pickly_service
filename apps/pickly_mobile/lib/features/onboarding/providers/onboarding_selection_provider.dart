import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier for onboarding selections
class OnboardingSelectionNotifier extends Notifier<OnboardingSelectionState> {
  @override
  OnboardingSelectionState build() {
    return const OnboardingSelectionState();
  }

  /// Set selected age category ID
  void setAgeCategoryId(String? ageCategoryId) {
    state = state.copyWith(ageCategoryId: ageCategoryId);
  }

  /// Set selected region IDs
  void setRegionIds(Set<String> regionIds) {
    state = state.copyWith(regionIds: regionIds);
  }

  /// Clear all selections
  void clear() {
    state = const OnboardingSelectionState();
  }
}

/// State for onboarding selections
class OnboardingSelectionState {
  final String? ageCategoryId;
  final Set<String> regionIds;

  const OnboardingSelectionState({
    this.ageCategoryId,
    this.regionIds = const {},
  });

  OnboardingSelectionState copyWith({
    String? ageCategoryId,
    Set<String>? regionIds,
  }) {
    return OnboardingSelectionState(
      ageCategoryId: ageCategoryId ?? this.ageCategoryId,
      regionIds: regionIds ?? this.regionIds,
    );
  }
}

/// Provider for onboarding selections
final onboardingSelectionProvider =
    NotifierProvider<OnboardingSelectionNotifier, OnboardingSelectionState>(
  OnboardingSelectionNotifier.new,
);
