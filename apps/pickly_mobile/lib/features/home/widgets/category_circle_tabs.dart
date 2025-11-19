/// Category Circle Tabs Widget
///
/// Horizontal scrollable list of category tabs using TabCircleWithLabel from design system.
/// Displays benefit categories with icons and labels, supporting realtime updates.
///
/// PRD v9.6.1 Phase 3: UI Layer Integration
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/contexts/benefit/models/benefit_category.dart';

/// Horizontal scrollable category tabs
class CategoryCircleTabs extends StatelessWidget {
  /// List of benefit categories to display
  final List<BenefitCategory> categories;

  /// Currently selected category ID (optional)
  final String? selectedCategoryId;

  /// Callback when a category is tapped
  final Function(BenefitCategory) onCategoryTap;

  const CategoryCircleTabs({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.selectedCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 70, // 48px circle + 4px spacing + 18px text
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedCategoryId;

          return _CategoryCircleItem(
            category: category,
            isSelected: isSelected,
            onTap: () => onCategoryTap(category),
          );
        },
      ),
    );
  }
}

/// Single category circle tab item
class _CategoryCircleItem extends StatelessWidget {
  final BenefitCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCircleItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine state based on selection
    final state = isSelected
        ? TabCircleWithLabelState.active
        : TabCircleWithLabelState.default_;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60, // Slightly wider for better touch target
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circle button with icon
            Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: isSelected ? 2.0 : 1.0,
                    color: isSelected
                        ? BrandColors.primary
                        : const Color(0xFFEBEBEB),
                  ),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              child: Center(
                child: _buildIcon(),
              ),
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              category.title,
              style: PicklyTypography.bodyMedium.copyWith(
                color: const Color(0xFF828282),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.33,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Build icon from URL or fallback
  Widget _buildIcon() {
    if (category.iconUrl == null || category.iconUrl!.isEmpty) {
      // Fallback icon when no URL provided
      return const Icon(
        Icons.category,
        size: 24,
        color: Color(0xFF828282),
      );
    }

    // Load icon from network URL
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: category.iconUrl!,
        width: 24,
        height: 24,
        fit: BoxFit.cover,
        placeholder: (context, url) => const SizedBox(
          width: 24,
          height: 24,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF828282),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => const Icon(
          Icons.category,
          size: 24,
          color: Color(0xFF828282),
        ),
      ),
    );
  }
}
