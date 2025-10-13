// Selection List Item Widget
//
// A reusable list item component for selection screens in the onboarding flow.
// Displays an icon, title, description, and a checkmark when selected.
//
// Features:
// - SVG icon support (optional)
// - Title and description text
// - Checkmark indicator for selected state
// - Material ripple effect
// - Accessibility support
//
// Example:
// ```dart
// SelectionListItem(
//   iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/young_man.svg',
//   title: '청년',
//   description: '만 19세-39세 대학생, 취업준비생, 직장인',
//   isSelected: true,
//   onTap: () => handleSelection(),
// )
// ```

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'selection_checkmark.dart';

/// A list item widget for selection screens with icon, title, and description
///
/// This widget displays a selectable item with:
/// - An optional SVG icon on the left
/// - Title and description text in the center
/// - A checkmark icon on the right when selected
///
/// Designed for use in onboarding screens where users need to select
/// from a list of options (e.g., age categories, regions, household types).
class SelectionListItem extends StatelessWidget {
  /// Creates a selection list item widget
  ///
  /// The [title] and [description] are required.
  /// The [iconUrl] is optional and can be a local asset or network URL.
  /// [isSelected] determines whether the checkmark is shown.
  /// [onTap] is the callback when the item is tapped.
  const SelectionListItem({
    super.key,
    this.iconUrl,
    required this.title,
    required this.description,
    this.isSelected = false,
    this.onTap,
  });

  /// Optional URL for the icon (SVG or PNG)
  /// Can be an asset path or network URL
  final String? iconUrl;

  /// The main title text
  final String title;

  /// The description/subtitle text
  final String description;

  /// Whether this item is currently selected
  final bool isSelected;

  /// Callback when the item is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$title, $description',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.md,
            ),
            decoration: BoxDecoration(
              color: BackgroundColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? BrandColors.primary
                    : BorderColors.subtle,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Row(
              children: [
                // Icon
                if (iconUrl != null) ...[
                  _buildIcon(),
                  const SizedBox(width: Spacing.md),
                ],

                // Title and Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: PicklyTypography.bodyLarge.copyWith(
                          color: TextColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      // Description
                      Text(
                        description,
                        style: PicklyTypography.bodyMedium.copyWith(
                          color: TextColors.secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: Spacing.md),

                // Checkmark indicator
                _buildCheckmark(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the icon widget
  Widget _buildIcon() {
    if (iconUrl == null) return const SizedBox.shrink();

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: BackgroundColors.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: _buildIconContent(),
      ),
    );
  }

  /// Builds the icon content (SVG or placeholder)
  Widget _buildIconContent() {
    if (iconUrl == null) return const SizedBox.shrink();

    // Check if it's an SVG
    if (iconUrl!.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        iconUrl!,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => const Icon(
          Icons.image_outlined,
          size: 32,
          color: TextColors.tertiary,
        ),
      );
    }

    // For PNG/JPG or other formats
    return Image.asset(
      iconUrl!,
      width: 32,
      height: 32,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.image_outlined,
        size: 32,
        color: TextColors.tertiary,
      ),
    );
  }

  /// Builds the checkmark indicator
  Widget _buildCheckmark() {
    return SelectionCheckmark(
      isSelected: isSelected,
      size: 24,
    );
  }
}
