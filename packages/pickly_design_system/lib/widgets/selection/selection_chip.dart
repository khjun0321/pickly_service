import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Size variants for SelectionChip
enum ChipSize {
  /// Small chip with 14px font (for grids)
  small,

  /// Large chip with 16px font (default)
  large,
}

/// Selection chip for multi-selection UI patterns
///
/// Figma Design Spec (exact copy):
/// - Padding: horizontal 16px, vertical 12px
/// - Border radius: 16px
/// - Default: white background, gray border (#EBEBEB)
/// - Selected: white background, green border (#27B473)
/// - Layout: [Label] [20px spacing] [Checkmark]
/// - Text: Pretendard, w700
///   - Large: 16px, height 1.50
///   - Small: 14px, height 1.43
///
/// Usage:
/// ```dart
/// SelectionChip(
///   label: '서울',
///   isSelected: true,
///   size: ChipSize.small,
///   onTap: () => print('tapped'),
/// )
/// ```
class SelectionChip extends StatelessWidget {
  /// Text label displayed in the chip
  final String label;

  /// Whether this chip is currently selected
  final bool isSelected;

  /// Callback when chip is tapped
  final VoidCallback? onTap;

  /// Optional custom width (null for auto-sizing)
  final double? width;

  /// Chip size variant (affects font size and line height)
  final ChipSize size;

  const SelectionChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.width,
    this.size = ChipSize.large,
  });

  @override
  Widget build(BuildContext context) {
    // Figma text specs
    final fontSize = size == ChipSize.large ? 16.0 : 14.0;
    final lineHeight = size == ChipSize.large ? 1.50 : 1.43;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white, // surface-base
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isSelected
                  ? const Color(0xFF27B473) // border-active
                  : const Color(0xFFEBEBEB), // border-subtle
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Label text
                  Text(
                    label,
                    style: TextStyle(
                      color: const Color(0xFF3E3E3E), // text-primary
                      fontSize: fontSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: lineHeight,
                    ),
                  ),

                  const SizedBox(width: 20), // spacing: 20

                  // Checkmark
                  SelectionCheckmark(isSelected: isSelected),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
