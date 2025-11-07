import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_mobile/features/onboarding/providers/age_category_provider.dart';
import 'package:pickly_mobile/features/onboarding/providers/onboarding_selection_provider.dart';
import 'package:pickly_mobile/core/router.dart';

/// Age category selection screen (Step 1/2)
///
/// Single-selection grid view with 2 columns layout
/// Uses custom age category cards for selection
class AgeCategoryScreen extends ConsumerStatefulWidget {
  const AgeCategoryScreen({super.key});

  @override
  ConsumerState<AgeCategoryScreen> createState() => _AgeCategoryScreenState();
}

class _AgeCategoryScreenState extends ConsumerState<AgeCategoryScreen> {
  String? _selectedCategoryId;

  void _handleCategorySelect(String categoryId) {
    setState(() {
      // Single selection: toggle selection
      if (_selectedCategoryId == categoryId) {
        _selectedCategoryId = null; // Deselect if clicking same item
      } else {
        _selectedCategoryId = categoryId; // Select new item
      }
    });
  }

  void _handleNext() {
    if (_selectedCategoryId == null) return;

    // Save selection to provider (will be persisted after region selection)
    ref.read(onboardingSelectionProvider.notifier).setAgeCategoryId(_selectedCategoryId);

    // Navigate to region selection
    if (mounted) {
      context.go(Routes.region);
    }
  }

  void _handleBack() {
    // Note: No back button in UI (matches Figma design)
    // This method is called only by PopScope for gesture navigation
    setState(() {
      _selectedCategoryId = null;
    });
    // Use go_router instead of pop to avoid navigation stack error
    context.go('/splash');
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(ageCategoryProvider);

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
              // Invisible header spacer to match region_selection layout
              const SizedBox(height: 48), // AppHeader height

              const SizedBox(height: 24), // Same spacing as region_selection

              // Title - left aligned
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Text(
                  '맞춤 혜택을 위해 내 상황을 알려주세요.',
                  style: PicklyTypography.titleMedium.copyWith(
                    color: TextColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    height: 1.33,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Content - Category list
              Expanded(
                child: categoriesAsync.when(
                  data: (categories) => _buildCategoryList(categories),
                  loading: () => _buildLoadingState(),
                  error: (error, stack) => _buildErrorState(error),
                ),
              ),

              // Spacing between list and guidance text
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

              // Progress bar - Step 1 of 2
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: PicklyProgressBar(
                  currentStep: 1,
                  totalSteps: 2,
                ),
              ),

              const SizedBox(height: 24),

              // Bottom button
              Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _selectedCategoryId != null ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BrandColors.primary,
                      disabledBackgroundColor: BrandColors.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 80),
                    ),
                    child: Text(
                      '다음',
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

  Widget _buildCategoryList(List<AgeCategory> categories) {
    if (categories.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      itemCount: categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = _selectedCategoryId == category.id;

        // PRD v9.9.6: Pass icon_component directly to CategoryIcon
        // CategoryIcon has built-in age icon mapping (youth, newlywed, baby, etc.)
        return SelectionListItem(
          iconComponent: category.iconComponent,
          title: category.title,
          description: category.description,
          isSelected: isSelected,
          onTap: () => _handleCategorySelect(category.id),
        );
      },
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
              child: ElevatedButton(
                onPressed: () {
                  ref.read(ageCategoryProvider.notifier).refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BrandColors.primary,
                ),
                child: const Text('다시 시도'),
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
