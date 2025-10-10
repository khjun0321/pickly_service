import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

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
