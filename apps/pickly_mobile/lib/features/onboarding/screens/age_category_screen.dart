import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Age category selection screen (Step 3/5)
///
/// Allows users to select ONE age category/generation
/// for personalized policy recommendations.
/// Based on Figma: https://www.figma.com/design/xOpx8v3FiYmCxSLkj9sgcu/pickly?node-id=287-5211
///
/// Uses Figma components:
/// - button (componentSetId: 2:757)
/// - list_card (componentSetId: 430:8969)
/// - progressbar (componentSetId: 472:7770)
class AgeCategoryScreen extends StatefulWidget {
  const AgeCategoryScreen({super.key});

  @override
  State<AgeCategoryScreen> createState() => _AgeCategoryScreenState();
}

class _AgeCategoryScreenState extends State<AgeCategoryScreen> {
  // ✅ Single selection (not multiple)
  String? _selectedCategory;

  // Loading state for data fetching
  bool _isLoading = false;

  // Error state
  String? _errorMessage;

  // Saving state for next button
  bool _isSaving = false;

  // Category data with SVG icons from design system
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'young_man',
      'iconPath': 'assets/icons/age_categories/young_man.svg',
      'title': '청년',
      'subtitle': '(만 19세~39세) 대학생, 취업준비생, 직장인',
    },
    {
      'id': 'bride',
      'iconPath': 'assets/icons/age_categories/bride.svg',
      'title': '신혼부부·예비부부',
      'subtitle': '결혼 예정 또는 결혼 7년이내',
    },
    {
      'id': 'baby',
      'iconPath': 'assets/icons/age_categories/baby.svg',
      'title': '육아중인 부모',
      'subtitle': '영유아~초등 자녀 양육 중',
    },
    {
      'id': 'kinder',
      'iconPath': 'assets/icons/age_categories/kinder.svg',
      'title': '다자녀 가구',
      'subtitle': '자녀 2명 이상 양육중',
    },
    {
      'id': 'old_man',
      'iconPath': 'assets/icons/age_categories/old_man.svg',
      'title': '어르신',
      'subtitle': '만 65세 이상',
    },
    {
      'id': 'wheel_chair',
      'iconPath': 'assets/icons/age_categories/wheel_chair.svg',
      'title': '장애인',
      'subtitle': '장애인 등록 대상',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement Supabase realtime subscription
      // final response = await supabase
      //     .from('age_categories')
      //     .select()
      //     .eq('is_active', true)
      //     .order('sort_order');

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '데이터를 불러오는 데 실패했습니다';
      });
    }
  }

  // ✅ Single selection method (replaces toggle)
  void _selectCategory(String categoryId) {
    setState(() {
      _selectedCategory = categoryId;
    });
    // ✅ NO TOAST MESSAGE - requirement met
  }

  Future<void> _handleNext() async {
    // ✅ Validate single selection
    if (_selectedCategory == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // TODO: Save to Supabase user_profiles table
      // await supabase
      //     .from('user_profiles')
      //     .update({
      //       'selected_category': _selectedCategory,
      //     })
      //     .eq('user_id', currentUserId);

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      // Navigate to next screen
      // Navigator.of(context).pushNamed('/onboarding/004-income');
    } catch (e) {
      if (!mounted) return;

      // Error handling without toast
      setState(() {
        _errorMessage = '저장에 실패했습니다. 다시 시도해주세요.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColors.app,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Spacing.lg),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Text(
                '맞춤 혜택을 위해 내 상황을 알려주세요.',
                style: PicklyTypography.titleMedium.copyWith(
                  color: TextColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: Spacing.lg),

            // Content area (scrollable cards)
            Expanded(
              child: _buildContent(),
            ),

            const SizedBox(height: Spacing.lg),

            // Bottom subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Center(
                child: Text(
                  '나에게 맞는 정책과 혜택에 대해 안내해드려요',
                  style: PicklyTypography.bodySmall.copyWith(
                    color: TextColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: Spacing.md),

            // ✅ Progress bar (moved to bottom)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: PicklyProgressBar(
                currentStep: 3,
                totalSteps: 6,
              ),
            ),

            const SizedBox(height: Spacing.lg),

            // ✅ PicklyButton component (Figma button component)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: PicklyButton.primary(
                text: '다음',
                onPressed: _selectedCategory != null ? _handleNext : null,
                isLoading: _isSaving,
              ),
            ),

            const SizedBox(height: Spacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(BrandColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
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
              _errorMessage!,
              style: PicklyTypography.bodyMedium.copyWith(
                color: TextColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.xxl),
            PicklyButton.primary(
              text: '다시 시도',
              onPressed: _loadData,
            ),
          ],
        ),
      );
    }

    // ✅ ListView with ListCard component (Figma list_card component)
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      itemCount: _categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = _selectedCategory == category['id'];

        return ListCard(
          iconPath: category['iconPath'] as String,
          title: category['title'] as String,
          subtitle: category['subtitle'] as String,
          isSelected: isSelected,
          onTap: () => _selectCategory(category['id'] as String),
        );
      },
    );
  }
}
