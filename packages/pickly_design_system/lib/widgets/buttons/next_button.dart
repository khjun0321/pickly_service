// Next Button Widget
//
// A reusable bottom CTA (Call-To-Action) button for onboarding flows.
// Handles enabled/disabled states with appropriate visual feedback.
//
// Features:
// - Primary button styling
// - Enabled/disabled states
// - Loading state support
// - Fixed bottom positioning
// - Safe area support
// - Material Design 3 compliant
// - Accessibility support
// - Smooth animations
//
// Example:
// ```dart
// NextButton(
//   label: 'Next',
//   enabled: hasSelection,
//   onPressed: () => navigateToNextScreen(),
// )
// ```

import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// A bottom CTA button widget for onboarding navigation
///
/// This widget provides a consistent button style for moving forward
/// in the onboarding flow. It automatically handles:
/// - Visual states (enabled/disabled)
/// - Loading states
/// - Safe area padding
/// - Accessibility
///
/// Typically used at the bottom of onboarding screens to proceed
/// to the next step after user input.
class NextButton extends StatelessWidget {
  /// Creates a next button widget
  ///
  /// The [label] and [onPressed] are required.
  /// Set [enabled] to false to disable the button.
  /// Set [isLoading] to true to show a loading indicator.
  const NextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  /// The text to display on the button
  final String label;

  /// Callback when the button is pressed (only called when enabled)
  final VoidCallback onPressed;

  /// Whether the button is enabled for interaction
  final bool enabled;

  /// Whether to show a loading indicator
  final bool isLoading;

  /// Whether the button should take full width
  final bool fullWidth;

  /// Optional icon to display before the label
  final IconData? icon;

  /// Optional custom background color (overrides theme)
  final Color? backgroundColor;

  /// Optional custom text color (overrides theme)
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: BackgroundColors.surface,
        boxShadow: PicklyShadows.md,
      ),
      child: SafeArea(
        top: false,
        child: AnimatedOpacity(
          duration: PicklyAnimations.normal,
          opacity: enabled && !isLoading ? 1.0 : 0.6,
          child: SizedBox(
            width: fullWidth ? double.infinity : null,
            height: 56.0,
            child: _buildButton(context),
          ),
        ),
      ),
    );
  }

  /// Builds the main button widget
  Widget _buildButton(BuildContext context) {
    final bool isInteractive = enabled && !isLoading;

    return Semantics(
      button: true,
      enabled: isInteractive,
      label: label,
      hint: isLoading
          ? 'Loading'
          : (!enabled ? 'Button is disabled' : 'Tap to continue'),
      child: ElevatedButton(
        onPressed: isInteractive ? onPressed : null,
        style: _buildButtonStyle(),
        child: isLoading ? _buildLoadingIndicator() : _buildButtonContent(),
      ),
    );
  }

  /// Builds the button style based on state
  ButtonStyle _buildButtonStyle() {
    final bool isInteractive = enabled && !isLoading;

    Color bgColor;
    Color fgColor;

    if (isInteractive) {
      bgColor = backgroundColor ?? ButtonColors.primaryBg;
      fgColor = textColor ?? ButtonColors.primaryText;
    } else {
      bgColor = ButtonColors.disabledBg;
      fgColor = ButtonColors.disabledText;
    }

    return ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      disabledBackgroundColor: ButtonColors.disabledBg,
      disabledForegroundColor: ButtonColors.disabledText,
      elevation: isInteractive ? 2 : 0,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: PicklyBorderRadius.radiusLg,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xxl,
        vertical: Spacing.lg,
      ),
    );
  }

  /// Builds the button content (label and optional icon)
  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20.0,
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            label,
            style: PicklyTypography.buttonLarge,
          ),
        ],
      );
    }

    return Text(
      label,
      style: PicklyTypography.buttonLarge,
    );
  }

  /// Builds the loading indicator
  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 24.0,
      height: 24.0,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          textColor ?? ButtonColors.primaryText,
        ),
      ),
    );
  }
}

/// A variant of NextButton that's more compact for inline use
class CompactNextButton extends StatelessWidget {
  const CompactNextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.0,
      child: NextButton(
        label: label,
        onPressed: onPressed,
        enabled: enabled,
        isLoading: isLoading,
        fullWidth: false,
        icon: icon,
      ),
    );
  }
}

/// Example usage in an onboarding screen:
///
/// ```dart
/// class OnboardingScreen extends StatefulWidget {
///   @override
///   State<OnboardingScreen> createState() => _OnboardingScreenState();
/// }
///
/// class _OnboardingScreenState extends State<OnboardingScreen> {
///   bool _hasSelection = false;
///   bool _isLoading = false;
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: SafeArea(
///         child: Column(
///           children: [
///             // Header
///             OnboardingHeader(currentStep: 1, totalSteps: 5),
///
///             // Content
///             Expanded(
///               child: YourOnboardingContent(
///                 onSelectionChanged: (hasSelection) {
///                   setState(() => _hasSelection = hasSelection);
///                 },
///               ),
///             ),
///
///             // Bottom button
///             NextButton(
///               label: 'Next',
///               enabled: _hasSelection,
///               isLoading: _isLoading,
///               onPressed: _handleNext,
///             ),
///           ],
///         ),
///       ),
///     );
///   }
///
///   Future<void> _handleNext() async {
///     setState(() => _isLoading = true);
///
///     try {
///       await saveSelectionAndNavigate();
///     } finally {
///       if (mounted) {
///         setState(() => _isLoading = false);
///       }
///     }
///   }
/// }
/// ```
///
/// Custom styling example:
///
/// ```dart
/// NextButton(
///   label: 'Continue',
///   enabled: true,
///   onPressed: () => print('Pressed'),
///   backgroundColor: Colors.blue,
///   textColor: Colors.white,
///   icon: Icons.arrow_forward,
/// )
/// ```
///
/// Compact button example:
///
/// ```dart
/// CompactNextButton(
///   label: 'Skip',
///   enabled: true,
///   onPressed: () => skipOnboarding(),
///   icon: Icons.skip_next,
/// )
/// ```
