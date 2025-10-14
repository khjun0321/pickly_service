import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/features/onboarding/providers/region_provider.dart';
import 'package:pickly_mobile/features/onboarding/providers/onboarding_selection_provider.dart';
import 'package:pickly_mobile/features/onboarding/providers/onboarding_storage_provider.dart';

/// Region selection screen (Step 2/2)
///
/// Multi-selection grid view with 3 columns layout
/// Uses SelectionChip component for region selection
///
/// Layout matches age_category_screen:
/// - SafeArea(~44px) + Header(48px) + Spacing(24px) = ~116px to title
class RegionSelectionScreen extends ConsumerStatefulWidget {
  const RegionSelectionScreen({super.key});

  @override
  ConsumerState<RegionSelectionScreen> createState() => _RegionSelectionScreenState();
}

class _RegionSelectionScreenState extends ConsumerState<RegionSelectionScreen> {
  final Set<String> _selectedRegionIds = {};

  void _handleRegionToggle(String regionId) {
    setState(() {
      if (_selectedRegionIds.contains(regionId)) {
        _selectedRegionIds.remove(regionId);
      } else {
        _selectedRegionIds.add(regionId);
      }
    });
  }

  Future<void> _handleComplete() async {
    if (_selectedRegionIds.isEmpty) return;

    // Get selected age category from provider
    final onboardingSelection = ref.read(onboardingSelectionProvider);
    final ageCategoryId = onboardingSelection.ageCategoryId;

    if (ageCategoryId == null) {
      // This shouldn't happen, but handle gracefully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('연령대를 먼저 선택해주세요')),
        );
        context.go('/onboarding/age-category');
      }
      return;
    }

    // Save to local storage
    final storage = ref.read(onboardingStorageServiceProvider);
    await storage.saveOnboardingData(
      ageCategoryId: ageCategoryId,
      regionIds: _selectedRegionIds.toList(),
    );

    // Clear provider state
    ref.read(onboardingSelectionProvider.notifier).clear();

    // Navigate to home
    if (mounted) {
      context.go('/home');
    }
  }

  void _handleBack() {
    setState(() {
      _selectedRegionIds.clear();
    });
    context.go('/onboarding/age-category');
  }

  @override
  Widget build(BuildContext context) {
    final regions = ref.watch(regionsListProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: BackgroundColors.app,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (48px) - inside SafeArea for consistent spacing
              AppHeader.onboarding(
                onBack: _handleBack,
              ),

              const SizedBox(height: 24),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Text(
                  '관심 지역을 선택해주세요.',
                  style: PicklyTypography.titleMedium.copyWith(
                    color: TextColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    height: 1.33,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Content - Region grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.0,
                  ),
                  itemCount: regions.length,
                  itemBuilder: (context, index) {
                    final region = regions[index];
                    final isSelected = _selectedRegionIds.contains(region.id);
                    return SelectionChip(
                      label: region.name,
                      isSelected: isSelected,
                      size: ChipSize.small,
                      onTap: () => _handleRegionToggle(region.id),
                    );
                  },
                ),
              ),

              const SizedBox(height: 36),

              // Guidance text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Text(
                  '나에게 맞는 정책과 혜택에 대해 안내해드려요',
                  style: PicklyTypography.bodyMedium.copyWith(
                    color: TextColors.secondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              // Progress bar - Step 2 of 2
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: PicklyProgressBar(
                  currentStep: 2,
                  totalSteps: 2,
                ),
              ),

              const SizedBox(height: 24),

              // Bottom button
              Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedRegionIds.isNotEmpty ? _handleComplete : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BrandColors.primary,
                      disabledBackgroundColor: BrandColors.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 80),
                    ),
                    child: Text(
                      '완료',
                      style: PicklyTypography.buttonLarge.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
