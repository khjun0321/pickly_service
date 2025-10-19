/// BenefitListItem Component
///
/// A horizontal list item for benefit categories in the Benefits screen.
/// Used in the residence tab to display various housing benefit types.
///
/// Specifications:
/// - Container width: 343px (full width minus 32px horizontal margin)
/// - Padding: 16px all sides
/// - Border: 1px solid, color: 0xFFEBEBEB (border-subtle)
/// - Border radius: 16px
/// - Icon: 32x32
/// - Spacing between icon and text: 12px
/// - Title: 14px, weight 700, color: 0xFF3E3E3E (text-primary)
/// - Subtitle: 12px, weight 600, color: 0xFF828282 (text-secondary)
/// - Spacing between title and subtitle: 4px
///
/// Usage:
/// ```dart
/// BenefitListItem(
///   iconPath: 'assets/icons/happy_apt.svg',
///   title: '행복주택',
///   subtitle: 'LH 행복주택',
///   onTap: () => Navigator.push(...),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../tokens/design_tokens.dart';

/// Benefit list item widget for benefits screen
class BenefitListItem extends StatelessWidget {
  /// The icon path from assets
  final String iconPath;

  /// The title text (e.g., "행복주택")
  final String title;

  /// The subtitle text (e.g., "LH 행복주택")
  final String subtitle;

  /// Callback when the item is tapped
  final VoidCallback? onTap;

  const BenefitListItem({
    super.key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 343,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white, // surface-base
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFFEBEBEB), // border-subtle
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon (32x32)
            SizedBox(
              width: 32,
              height: 32,
              child: SvgPicture.asset(
                iconPath,
                package: 'pickly_design_system',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12), // spacing between icon and text
            // Text area
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: PicklyTypography.bodyMedium.copyWith(
                    color: const Color(0xFF3E3E3E), // text-primary
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 4), // spacing between title and subtitle
                // Subtitle
                Text(
                  subtitle,
                  style: PicklyTypography.bodySmall.copyWith(
                    color: const Color(0xFF828282), // text-secondary
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
