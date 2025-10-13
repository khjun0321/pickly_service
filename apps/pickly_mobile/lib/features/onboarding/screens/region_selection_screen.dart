import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/features/onboarding/providers/region_provider.dart';
import 'package:pickly_mobile/features/onboarding/widgets/widgets.dart';

/// Region selection screen (Step 2/5)
///
/// Multi-selection chip view with Wrap layout (3 columns)
/// Uses SelectionChip component for compact region selection
class RegionSelectionScreen extends ConsumerStatefulWidget {
  const RegionSelectionScreen({super.key});

  @override
  ConsumerState<RegionSelectionScreen> createState() => _RegionSelectionScreenState();
}

class _RegionSelectionScreenState extends ConsumerState<RegionSelectionScreen> {
  final Set<String> _selectedRegionIds = {};

  void _handleRegionToggle(String regionId) {
    setState(() {
      // Multi-selection: toggle add/remove
      if (_selectedRegionIds.contains(regionId)) {
        _selectedRegionIds.remove(regionId);
      } else {
        _selectedRegionIds.add(regionId);
      }
    });
  }

  Future<void> _handleComplete() async {
    if (_selectedRegionIds.isEmpty) return;

    // TODO: Save selections to user preferences/profile
    // For now, just show confirmation and navigate

    // Show confirmation message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('선택 완료: ${_selectedRegionIds.length}개 지역'),
          duration: const Duration(seconds: 1),
        ),
      );

      // Navigate to next onboarding screen or home
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // TODO: Replace with actual next screen route when implemented
        // For now, go to age category screen as next step
        context.go('/onboarding/age_category');
      }
    }
  }

  void _handleBack() {
    setState(() {
      _selectedRegionIds.clear();
    });
    // Use go_router to navigate back
    context.pop();
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
        appBar: AppBar(
          backgroundColor: BackgroundColors.app,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: TextColors.primary),
            onPressed: _handleBack,
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top spacing - Figma spec: Title at ~116px from top
              const SizedBox(height: 72),

              // Title - Figma spec: 18px w700, #3E3E3E
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

              // Chips section - Wrap with 3 columns layout
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: regions.map((region) {
                      final isSelected = _selectedRegionIds.contains(region.id);
                      return SelectionChip(
                        label: region.name,
                        isSelected: isSelected,
                        size: ChipSize.small, // 14px font for compact layout
                        onTap: () => _handleRegionToggle(region.id),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Spacing between chips and guidance text
              const SizedBox(height: 36),

              // Guidance text - Figma spec: centered, secondary color
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

              const SizedBox(height: Spacing.xxl),

              // Progress bar - Figma spec: 2/5 steps = 40% progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: 0.4, // Step 2/5 = 40%
                    minHeight: 4,
                    backgroundColor: const Color(0xFFDDDDDD),
                    valueColor: const AlwaysStoppedAnimation<Color>(BrandColors.primary),
                  ),
                ),
              ),

              const SizedBox(height: Spacing.xxl),

              // Complete button - Text: "완료" instead of "다음"
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
                        borderRadius: BorderRadius.circular(16), // Figma spec: 16px
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
