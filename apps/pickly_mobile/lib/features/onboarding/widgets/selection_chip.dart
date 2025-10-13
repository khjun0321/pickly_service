// Selection Chip Component
//
// A reusable chip component for selection UI patterns throughout the app.
// Displays a label with a checkmark indicator that reflects selection state.
//
// Features:
// - Two size variants (large and small)
// - Animated selection state transitions
// - Integrated SelectionCheckmark component
// - Design system token integration
// - Full accessibility support
// - Touch-friendly tap area
//
// Example:
// ```dart
// SelectionChip(
//   label: '서울',
//   isSelected: true,
//   size: ChipSize.large,
//   onTap: () => handleSelection(),
// )
// ```

import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'selection_checkmark.dart';

/// Size variants for the SelectionChip component
///
/// - [large]: fontSize 16, fontWeight 700, height 1.50
/// - [small]: fontSize 14, fontWeight 700, height 1.43
enum ChipSize {
  /// Large chip variant (16pt font, for primary selections)
  large,

  /// Small chip variant (14pt font, for compact lists)
  small,
}

/// A reusable chip component for selection UI patterns
///
/// This widget displays a selectable chip with:
/// - Label text on the left
/// - Selection checkmark on the right
/// - Animated border color transitions
/// - Size variants for different contexts
///
/// The chip follows Figma design specifications:
/// - White background with subtle border when unselected
/// - Green border (BrandColors.primary) when selected
/// - 16pt border radius for rounded corners
/// - Proper padding and spacing
///
/// Designed for use in filter screens, category selectors,
/// and any multi-select interface patterns.
class SelectionChip extends StatelessWidget {
  /// Creates a selection chip widget
  ///
  /// The [label] is displayed as the chip's text content.
  /// The [isSelected] determines the visual state and border color.
  /// The [size] controls the typography and overall dimensions.
  /// The [onTap] callback is invoked when the chip is tapped.
  const SelectionChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.size = ChipSize.large,
    this.onTap,
  });

  /// The text label displayed in the chip
  final String label;

  /// Whether this chip is in selected state
  final bool isSelected;

  /// The size variant of the chip
  final ChipSize size;

  /// Callback invoked when the chip is tapped
  final VoidCallback? onTap;

  /// Returns the text style based on chip size
  TextStyle _getTextStyle() {
    switch (size) {
      case ChipSize.large:
        return PicklyTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w700,
          height: 1.50,
        );
      case ChipSize.small:
        return PicklyTypography.bodyMedium.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.43,
        );
    }
  }

  /// Returns the padding based on chip size
  EdgeInsets _getPadding() {
    return const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      selected: isSelected,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: _getPadding(),
          decoration: BoxDecoration(
            color: Colors.white, // surface-base
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? BrandColors.primary : BorderColors.subtle,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label text
              Text(
                label,
                style: _getTextStyle(),
              ),

              // Spacer between label and checkmark
              const SizedBox(width: 8),

              // Selection checkmark indicator
              SelectionCheckmark(
                isSelected: isSelected,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
