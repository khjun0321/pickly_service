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

/// Pickly 프로그레스바 컴포넌트
///
/// Figma componentSetId: 472:7770
///
/// Variants:
/// - Property 1: type1 (3/5 = 60%) | type2 (다른 비율)
///
/// 구조:
/// - 활성 바 (primary color)
/// - 비활성 바 (muted color)
class PicklyProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const PicklyProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: currentStep,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: BrandColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        if (currentStep < totalSteps) const SizedBox(width: 4),
        if (currentStep < totalSteps)
          Expanded(
            flex: totalSteps - currentStep,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: BackgroundColors.muted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }
}
