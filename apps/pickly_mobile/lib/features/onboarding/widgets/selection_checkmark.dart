// Selection Checkmark Widget
//
// A reusable checkmark indicator component for selection UI patterns.
// Displays a circular indicator with an animated checkmark when selected.
//
// Features:
// - Animated selection state transition
// - Circular border with fill on selection
// - White checkmark icon when selected
// - Customizable size
// - Accessibility support
//
// Example:
// ```dart
// SelectionCheckmark(
//   isSelected: true,
//   size: 24,
// )
// ```

import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// A reusable checkmark indicator widget for selection states
///
/// This widget displays a circular indicator that:
/// - Shows an empty circle when not selected
/// - Shows a filled circle with white checkmark when selected
/// - Animates smoothly between states
///
/// Designed for use in selection lists, forms, and filter screens
/// where users need visual feedback for their selections.
class SelectionCheckmark extends StatelessWidget {
  /// Creates a selection checkmark widget
  ///
  /// The [isSelected] determines the visual state.
  /// The [size] controls the diameter of the circle (default: 24).
  const SelectionCheckmark({
    super.key,
    required this.isSelected,
    this.size = 24,
  });

  /// Whether this checkmark is in selected state
  final bool isSelected;

  /// The diameter of the circular indicator
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isSelected ? 'Selected' : 'Not selected',
      selected: isSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? BrandColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? BrandColors.primary : BorderColors.subtle,
            width: 2.0,
          ),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: size * 0.67, // Icon is ~67% of container size
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
