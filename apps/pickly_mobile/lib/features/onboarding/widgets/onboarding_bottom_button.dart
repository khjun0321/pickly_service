import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Bottom fixed button for onboarding screens
///
/// Features:
/// - Enabled/disabled states with visual feedback
/// - Loading state with spinner
/// - Uses design tokens for consistent styling
/// - Fixed at bottom with safe area support
class OnboardingBottomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;

  const OnboardingBottomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = isEnabled && !isLoading && onPressed != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: SurfaceColors.base,
        boxShadow: PicklyShadows.card,
      ),
      child: SafeArea(
        top: false,
        child: AnimatedContainer(
          duration: PicklyAnimations.normal,
          curve: PicklyAnimations.easeInOut,
          child: ElevatedButton(
            onPressed: isActive ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ButtonColors.primaryBg,
              disabledBackgroundColor: ButtonColors.disabledBg,
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                vertical: Spacing.lg,
                horizontal: Spacing.lg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: PicklyBorderRadius.radiusXl,
              ),
            ),
            child: SizedBox(
              height: 24,
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        text,
                        style: PicklyTypography.buttonLarge.copyWith(
                          color: isActive
                              ? ButtonColors.primaryText
                              : ButtonColors.disabledText,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
