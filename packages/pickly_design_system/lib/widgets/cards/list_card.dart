import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Horizontal list card for age category selection
/// Based on Figma design: 003.01_onboarding.png
///
/// Layout: [Icon 32x32] [Title + Subtitle] [Checkmark 24x24]
class ListCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const ListCard({
    super.key,
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(Spacing.lg), // 16px all sides
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(PicklyBorderRadius.xl), // 16px
          border: Border.all(
            color: isSelected ? BrandColors.primary : BorderColors.subtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon (32x32 SVG)
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

            // Text area (expanded)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title: bodyMedium bold (14px)
                  Text(
                    title,
                    style: PicklyTypography.bodyMedium.copyWith(
                      color: TextColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs), // 4px
                  // Subtitle: bodySmall (12px)
                  Text(
                    subtitle,
                    style: PicklyTypography.bodySmall.copyWith(
                      color: TextColors.secondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: Spacing.sm), // 8px

            // Checkmark (24x24)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? BrandColors.primary
                    : ButtonColors.disabledBg,
              ),
              child: Center(
                child: Icon(
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
