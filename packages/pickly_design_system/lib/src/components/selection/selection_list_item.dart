// Selection List Item Widget
//
// A reusable list item component for vertical list selection in onboarding flows.
// Displays icon, title, description on the left and a checkmark on the right.
//
// Features:
// - Horizontal layout with icon, text, and checkmark
// - Active/inactive states with visual feedback
// - Multiple selection support
// - Accessibility support
// - Smooth animations

import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// A list item widget for selectable options with checkmark
///
/// This widget provides a horizontal list item that can be selected/deselected.
/// It's used in onboarding flows for category selection.
class SelectionListItem extends StatelessWidget {
  /// Creates a selection list item widget
  const SelectionListItem({
    super.key,
    this.icon,
    this.iconUrl,
    this.iconComponent = 'category',
    required this.title,
    this.description,
    this.isSelected = false,
    this.onTap,
    this.enabled = true,
  });

  /// The icon to display (backward compatibility)
  final IconData? icon;

  /// The SVG asset path or network URL to display
  final String? iconUrl;

  /// The local icon component key (for CategoryIcon fallback)
  final String iconComponent;

  /// The main title text
  final String title;

  /// Optional description text below the title
  final String? description;

  /// Whether this item is currently selected
  final bool isSelected;

  /// Callback when the item is tapped
  final VoidCallback? onTap;

  /// Whether the item is enabled for interaction
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      hint: description,
      selected: isSelected,
      enabled: enabled,
      button: true,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: PicklyAnimations.normal,
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: _buildDecoration(),
          child: Row(
            children: [
              // Icon
              _buildIcon(),

              const SizedBox(width: Spacing.md),

              // Title and Description
              // Figma spec: Title 14px w700 #3E3E3E, Description 12px w600 #828282, gap 4px
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: PicklyTypography.bodyMedium.copyWith(
                        color: enabled ? TextColors.primary : TextColors.disabled,
                        fontWeight: FontWeight.w700, // Always bold per Figma
                        fontSize: 14,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4), // 4px gap per Figma
                      Text(
                        description!,
                        style: PicklyTypography.bodySmall.copyWith(
                          color: enabled ? TextColors.secondary : TextColors.disabled,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: Spacing.md),

              // Checkmark
              _buildCheckmark(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the container decoration based on state
  /// Figma spec: 64px height, 16px padding, 16px border radius, 1px border for all states
  BoxDecoration _buildDecoration() {
    Color backgroundColor;
    Color borderColor;

    if (!enabled) {
      backgroundColor = ChipColors.disabledBg;
      borderColor = BorderColors.disabled;
    } else if (isSelected) {
      backgroundColor = SurfaceColors.base;
      borderColor = BorderColors.active; // #27B473
    } else {
      backgroundColor = SurfaceColors.base;
      borderColor = BorderColors.subtle; // #EBEBEB
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: PicklyBorderRadius.radiusLg, // 16px
      border: Border.all(
        color: borderColor,
        width: 1.0, // Figma spec: always 1px
      ),
    );
  }

  /// Builds the icon widget
  Widget _buildIcon() {
    Color iconColor;

    if (!enabled) {
      iconColor = TextColors.disabled;
    } else if (isSelected) {
      iconColor = BrandColors.primary;
    } else {
      iconColor = TextColors.secondary;
    }

    return AnimatedContainer(
      duration: PicklyAnimations.normal,
      curve: Curves.easeInOut,
      child: _buildIconContent(iconColor),
    );
  }

  /// Builds the actual icon content using CategoryIcon
  /// Figma spec: 32x32px, color changes with selection (#27B473 selected, #828282 unselected)
  Widget _buildIconContent(Color iconColor) {
    const double iconSize = 32.0; // Figma spec: 32x32px

    // Legacy icon support (backward compatibility)
    if (icon != null) {
      return Icon(
        icon,
        size: iconSize,
        color: iconColor,
      );
    }

    // Use CategoryIcon for all image-based icons
    return CategoryIcon(
      iconUrl: iconUrl,
      iconComponent: iconComponent,
      size: iconSize,
      color: null, // Don't override colors - let CategoryIcon handle it
    );
  }

  /// Builds the checkmark circle
  /// Figma spec: 24x24px circle, #27B473 when selected, #DDDDDD when unselected, white check icon
  Widget _buildCheckmark() {
    const double checkmarkSize = 24.0; // Figma spec: 24x24px

    Color circleColor;
    Color checkColor;

    if (!enabled) {
      circleColor = BorderColors.disabled;
      checkColor = Colors.transparent;
    } else if (isSelected) {
      circleColor = BrandColors.primary; // #27B473
      checkColor = Colors.white;
    } else {
      circleColor = const Color(0xFFDDDDDD); // Figma spec: #DDDDDD
      checkColor = Colors.transparent;
    }

    return AnimatedContainer(
      duration: PicklyAnimations.normal,
      curve: Curves.easeInOut,
      width: checkmarkSize,
      height: checkmarkSize,
      decoration: BoxDecoration(
        color: circleColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.check,
          size: 16, // Checkmark icon size
          color: checkColor,
        ),
      ),
    );
  }
}
