import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import '../../../models/age_category.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/selection_card.dart';
import '../widgets/next_button.dart';
import '../providers/age_category_provider.dart';
import '../providers/age_category_controller.dart';

/// Age category selection screen (Step 3/5)
///
/// Allows users to select ONE age category/generation
/// for personalized policy recommendations.
/// Based on Figma: https://www.figma.com/design/xOpx8v3FiYmCxSLkj9sgcu/pickly?node-id=287-5211
///
/// Uses reusable components:
/// - OnboardingHeader (with back button and progress bar)
/// - SelectionCard (for age category cards)
/// - NextButton (bottom CTA button)
///
/// Uses Riverpod providers:
/// - ageCategoryProvider (for fetching categories from Supabase)
/// - ageCategoryControllerProvider (for managing selection state)
class AgeCategoryScreen extends ConsumerStatefulWidget {
  const AgeCategoryScreen({super.key});

  @override
  ConsumerState<AgeCategoryScreen> createState() => _AgeCategoryScreenState();
}

class _AgeCategoryScreenState extends ConsumerState<AgeCategoryScreen> {
  Future<void> _handleNext() async {
    final notifier = ref.read(ageCategoryControllerProvider.notifier);
    await notifier.saveAndContinue();

    if (!mounted) return;

    final selectionState = ref.read(ageCategoryControllerProvider);

    if (selectionState.errorMessage != null) {
      // Error occurred - state already updated by notifier
      return;
    }

    // Navigate to next screen
    // TODO: Implement navigation
    // Navigator.of(context).pushNamed('/onboarding/004-income');
  }

  void _handleBack() {
    // Clear selection and navigate back
    ref.read(ageCategoryControllerProvider.notifier).clearSelection();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Watch category data from provider
    final categoriesAsync = ref.watch(ageCategoryProvider);

    // Watch selection state
    final selectionState = ref.watch(ageCategoryControllerProvider);
    final hasSelection = ref.watch(isAgeCategorySelectionValidProvider);

    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        backgroundColor: BackgroundColors.app,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button and progress bar
              OnboardingHeader(
                currentStep: 2,
                totalSteps: 5,
                showBackButton: true,
                onBack: _handleBack,
              ),

              const SizedBox(height: Spacing.lg),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Text(
                  '맞춤 혜택을 위해\n내 상황을 알려주세요.',
                  style: PicklyTypography.titleMedium.copyWith(
                    color: TextColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: Spacing.xs),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Text(
                  '나에게 맞는 정책과 혜택에 대해 안내해드려요',
                  style: PicklyTypography.bodyMedium.copyWith(
                    color: TextColors.secondary,
                  ),
                ),
              ),

              const SizedBox(height: Spacing.xl),

              // Content area (scrollable cards)
              Expanded(
                child: _buildContent(categoriesAsync, selectionState),
              ),

              const SizedBox(height: Spacing.md),

              // Bottom button
              NextButton(
                label: '다음',
                enabled: hasSelection,
                isLoading: selectionState.isLoading,
                onPressed: _handleNext,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    AsyncValue<List<AgeCategory>> categoriesAsync,
    AgeCategorySelectionState selectionState,
  ) {
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return _buildEmptyState();
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: Spacing.md,
            mainAxisSpacing: Spacing.md,
            childAspectRatio: 0.85,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectionState.isSelected(category.id);

            return SelectionCard(
              iconUrl: category.iconUrl,
              label: category.title,
              subtitle: category.description,
              isSelected: isSelected,
              onTap: () {
                ref
                    .read(ageCategoryControllerProvider.notifier)
                    .selectCategory(category.id);
              },
            );
          },
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(BrandColors.primary),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: StateColors.error,
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              '데이터를 불러오는 데 실패했습니다',
              style: PicklyTypography.bodyMedium.copyWith(
                color: TextColors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              error.toString(),
              style: PicklyTypography.bodySmall.copyWith(
                color: TextColors.secondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Spacing.xl),
            SizedBox(
              width: 160,
              child: PicklyButton.primary(
                text: '다시 시도',
                onPressed: () {
                  ref.read(ageCategoryProvider.notifier).retry();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: TextColors.tertiary,
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              '표시할 카테고리가 없습니다',
              style: PicklyTypography.bodyMedium.copyWith(
                color: TextColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
