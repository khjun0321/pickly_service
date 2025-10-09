import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Age category selection card with fixed sizing to prevent position shift
///
/// Design specs:
/// - Selected: border 2px + inner padding 15px
/// - Unselected: border 1px + inner padding 16px
/// - Fixed container size prevents layout shift
/// - Shows check icon when selected
/// - Smooth animation on state change
class AgeSelectionCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const AgeSelectionCard({
    super.key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Fixed total size to prevent shift: 16px outer + 1px border + content
    // When selected: 2px border reduces inner padding by 1px on each side
    const double totalPadding = Spacing.lg; // 16px
    final double borderWidth = isSelected ? 2.0 : 1.0;
    final double innerPadding = totalPadding - borderWidth;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: PicklyAnimations.normal,
        curve: PicklyAnimations.easeInOut,
        padding: EdgeInsets.all(innerPadding),
        decoration: BoxDecoration(
          color: SurfaceColors.base,
          borderRadius: PicklyBorderRadius.radiusXl,
          border: Border.all(
            color: isSelected ? BorderColors.active : BorderColors.subtle,
            width: borderWidth,
          ),
        ),
        child: Row(
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

            const SizedBox(width: Spacing.md), // 12px

            // Text area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    title,
                    style: PicklyTypography.bodyMedium.copyWith(
                      color: TextColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs), // 4px
                  // Subtitle
                  Text(
                    subtitle,
                    style: PicklyTypography.captionSmall.copyWith(
                      color: TextColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: Spacing.sm), // 8px

            // Checkmark indicator (24x24)
            AnimatedContainer(
              duration: PicklyAnimations.fast,
              curve: PicklyAnimations.easeInOut,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? StateColors.active : BackgroundColors.muted,
              ),
              child: AnimatedOpacity(
                duration: PicklyAnimations.fast,
                opacity: isSelected ? 1.0 : 0.0,
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
