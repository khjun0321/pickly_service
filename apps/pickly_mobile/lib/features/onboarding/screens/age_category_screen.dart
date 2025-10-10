import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/selection_list_item.dart';
import '../providers/age_category_provider.dart';

/// Age category selection screen (Step 3/5)
///
/// Multiple selection list view with checkmarks
class AgeCategoryScreen extends ConsumerStatefulWidget {
  const AgeCategoryScreen({super.key});

  @override
  ConsumerState<AgeCategoryScreen> createState() => _AgeCategoryScreenState();
}

class _AgeCategoryScreenState extends ConsumerState<AgeCategoryScreen> {
  final Set<String> _selectedCategoryIds = {};

  void _handleCategorySelection(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  Future<void> _handleNext() async {
    if (_selectedCategoryIds.isEmpty) return;

    // TODO: Save selection and navigate
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected: ${_selectedCategoryIds.length} categories'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleBack() {
    setState(() {
      _selectedCategoryIds.clear();
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
              // Header
              OnboardingHeader(
                currentStep: 2,
                totalSteps: 5,
                showBackButton: true,
                onBack: _handleBack,
              ),

              const SizedBox(height: Spacing.lg),

              // Title - Figma spec: top 116px, 18px w700, #3E3E3E
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

              const SizedBox(height: Spacing.xl),

              // Content - Figma spec: List starts at top 156px
              Expanded(
                child: categoriesAsync.when(
                  data: (categories) => _buildCategoryList(categories),
                  loading: () => _buildLoadingState(),
                  error: (error, stack) => _buildErrorState(error),
                ),
              ),

              // Bottom section - Figma spec: guidance text at top 656px
              Padding(
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

              const SizedBox(height: Spacing.xl),

              // Progress bar - Figma spec: top 704px, height 4px, 50% progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: 0.5, // Step 3/5 = 60%, but Figma shows ~50%
                    minHeight: 4,
                    backgroundColor: const Color(0xFFDDDDDD),
                    valueColor: const AlwaysStoppedAnimation<Color>(BrandColors.primary),
                  ),
                ),
              ),

              const SizedBox(height: Spacing.xl),

              // Bottom button - Figma spec: top 732px, height 56px, border radius 16px
              Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedCategoryIds.isNotEmpty ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BrandColors.primary,
                      disabledBackgroundColor: BrandColors.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16), // Figma spec: 16px
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
      separatorBuilder: (context, index) => const SizedBox(height: Spacing.md),
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = _selectedCategoryIds.contains(category.id);

        return SelectionListItem(
          iconUrl: category.iconUrl,
          title: category.title,
          description: category.description,
          isSelected: isSelected,
          onTap: () => _handleCategorySelection(category.id),
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
