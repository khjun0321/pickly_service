import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/contexts/benefit/models/benefit_category.dart';
import 'package:pickly_mobile/features/benefits/providers/benefit_category_provider.dart';

/// FilterBottomSheet - Hierarchical subcategory filter UI
///
/// PRD v9.10.1: Database-driven filter with category-specific selection state
///
/// Features:
/// - Uses SelectionListItem from design system (same as age category)
/// - Category-specific selection state (주거/교육/etc independent)
/// - Realtime updates when Admin modifies subcategories
/// - Same 3-section layout as age category screen
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (context) => FilterBottomSheet(category: category),
/// );
/// ```
class FilterBottomSheet extends ConsumerWidget {
  final BenefitCategory category;

  const FilterBottomSheet({
    required this.category,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch subcategories stream for realtime updates
    final subcategoriesAsync = ref.watch(subcategoriesStreamProvider(category.id));

    // Watch current selections for THIS category only
    final selectedIds = ref.watch(selectedSubcategoryIdsForCategoryProvider(category.id));

    return SafeArea(
      child: Container(
        height: 540, // PRD v9.10.2: Figma spec height
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            side: BorderSide(color: Color(0xFFEBEBEB), width: 1),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header: Title + Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${category.title} 공고 선택', // PRD v9.10.2: Specific format
                    style: PicklyTypography.titleMedium.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TextColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '해당 공고문을 안내해드립니다.', // PRD v9.10.2: Subtitle
                    style: PicklyTypography.bodyMedium.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: TextColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Body: Subcategory list with "전체 선택" first item
            Expanded(
              child: subcategoriesAsync.when(
                data: (subcategories) {
                  if (subcategories.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(Spacing.xxl),
                      child: Center(
                        child: Text(
                          '필터가 없습니다',
                          style: PicklyTypography.bodyMedium,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: subcategories.length + 1, // +1 for "전체 선택"
                    itemBuilder: (context, index) {
                      // First item: "전체 선택" (clears all selections)
                      if (index == 0) {
                        final isAllSelected = selectedIds.isEmpty;
                        return SelectionListItem(
                          iconUrl: null,
                          iconComponent: 'all',
                          title: '전체 선택',
                          description: '모든 ${category.title} 공고',
                          isSelected: isAllSelected,
                          onTap: () {
                            // Clear all selections for this category
                            ref
                                .read(subcategorySelectionsMapProvider.notifier)
                                .clear(category.id);
                          },
                        );
                      }

                      // Subsequent items: Individual subcategories
                      final subcategory = subcategories[index - 1];
                      final isSelected = selectedIds.contains(subcategory.id);

                      return SelectionListItem(
                        iconUrl: subcategory.iconUrl,
                        iconComponent: 'all', // fallback icon
                        title: subcategory.name,
                        description: '', // No subtitle for subcategories
                        isSelected: isSelected,
                        onTap: () {
                          // Toggle selection for THIS category only
                          ref
                              .read(subcategorySelectionsMapProvider.notifier)
                              .toggle(category.id, subcategory.id);
                        },
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(Spacing.xxl),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (error, stack) => const Padding(
                  padding: EdgeInsets.all(Spacing.xxl),
                  child: Center(
                    child: Text(
                      '필터를 불러올 수 없습니다',
                      style: PicklyTypography.bodyMedium,
                    ),
                  ),
                ),
              ),
            ),

            // Footer: 저장 button only (no reset button)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '저장',
                    style: PicklyTypography.bodyLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
