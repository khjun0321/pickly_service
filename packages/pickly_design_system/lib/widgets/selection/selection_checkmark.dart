import 'package:flutter/material.dart';

/// Selection checkmark indicator (24x24 circular)
///
/// Used in SelectionChip and SelectionCard components to show selection state.
///
/// Figma Design Spec (exact copy):
/// - Size: 24x24 circular
/// - Unselected: Gray background (#DDDDDD), no icon
/// - Selected: Green background (#27B473), white check icon (16x16)
class SelectionCheckmark extends StatelessWidget {
  /// Whether this checkmark is in selected state
  final bool isSelected;

  const SelectionCheckmark({
    super.key,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? const Color(0xFF27B473) // active green
            : const Color(0xFFDDDDDD), // muted gray
      ),
      child: isSelected
          ? const Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            )
          : null,
    );
  }
}
