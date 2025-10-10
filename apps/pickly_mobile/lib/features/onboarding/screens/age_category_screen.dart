import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/selection_card.dart';
import '../providers/age_category_provider.dart';

/// Age category selection screen (Step 3/5)
///
/// Simplified version without controller - uses local state
class AgeCategoryScreen extends ConsumerStatefulWidget {
  const AgeCategoryScreen({super.key});

  @override
  ConsumerState<AgeCategoryScreen> createState() => _AgeCategoryScreenState();
}

class _AgeCategoryScreenState extends ConsumerState<AgeCategoryScreen> {
  String? _selectedCategoryId;

  void _handleCategorySelection(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  Future<void> _handleNext() async {
    if (_selectedCategoryId == null) return;

    // TODO: Save selection and navigate
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected: $_selectedCategoryId'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleBack() {
    setState(() {
      _selectedCategoryId = null;
    });
    Navigator.of(context).pop();
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

              // Content
              Expanded(
                child: categoriesAsync.when(
                  data: (categories) => _buildCategoryGrid(categories),
                  loading: () => _buildLoadingState(),
                  error: (error, stack) => _buildErrorState(error),
                ),
              ),

              const SizedBox(height: Spacing.md),

              // Bottom button
              Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedCategoryId != null ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BrandColors.primary,
                      disabledBackgroundColor: BrandColors.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '다음',
                      style: PicklyTypography.buttonLarge.copyWith(
                        color: Colors.white,
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

  Widget _buildCategoryGrid(List<AgeCategory> categories) {
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
        final isSelected = _selectedCategoryId == category.id;

        return SelectionCard(
          iconUrl: category.iconUrl,
          label: category.title,
          subtitle: category.description,
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
