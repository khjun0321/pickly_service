import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Generic progress bar widget with 0.0-1.0 value
///
/// A simple linear progress indicator that can be used anywhere.
/// For step-based progress, consider using PicklyProgressBar instead.
class ProgressBar extends StatelessWidget {
  final double value; // 0.0 ~ 1.0
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final BorderRadius? borderRadius;

  const ProgressBar({
    super.key,
    required this.value,
    this.height = 4.0,
    this.backgroundColor,
    this.progressColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? BackgroundColors.muted,
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clampedValue,
        child: Container(
          decoration: BoxDecoration(
            color: progressColor ?? BrandColors.primary,
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

/// Pickly 프로그레스바 컴포넌트 (2-Step Onboarding 전용)
///
/// Figma componentSetId: 472:7770
///
/// **Onboarding 단계**:
/// - Step 1/2: 50% (Age/Generation selection)
/// - Step 2/2: 100% (Region selection)
///
/// **Usage**:
/// ```dart
/// // Step 1/2: Age Category
/// PicklyProgressBar(currentStep: 1, totalSteps: 2)
///
/// // Step 2/2: Region Selection
/// PicklyProgressBar(currentStep: 2, totalSteps: 2)
/// ```
///
/// **Design Tokens**:
/// - Active: BrandColors.primary
/// - Inactive: BackgroundColors.muted
/// - Height: 4px
/// - Border radius: 2px
/// - Gap: 4px
class PicklyProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const PicklyProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  })  : assert(totalSteps == 2, 'PicklyProgressBar is designed for 2-step onboarding only'),
        assert(currentStep >= 1 && currentStep <= 2, 'currentStep must be 1 or 2');

  @override
  Widget build(BuildContext context) {
    // Figma spec: Step 1 = left green, Step 2 = right green
    return Row(
      children: [
        // Left bar (Step 1 indicator)
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: currentStep == 1
                  ? BrandColors.primary // Green for step 1
                  : BackgroundColors.muted, // Gray for step 2
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        const SizedBox(width: 8), // Gap between bars

        // Right bar (Step 2 indicator)
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: currentStep == 2
                  ? BrandColors.primary // Green for step 2
                  : BackgroundColors.muted, // Gray for step 1
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}
