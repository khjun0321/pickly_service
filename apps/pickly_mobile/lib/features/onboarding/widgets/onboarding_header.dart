// Onboarding Header Widget
//
// A reusable header component that displays progress through the onboarding flow.
// Shows a visual progress indicator for the current step and an optional back button.
//
// Features:
// - Linear progress indicator
// - Optional back button with customizable callback
// - Material Design 3 compliant
// - Responsive design
// - Accessibility support
//
// Example:
// ```dart
// OnboardingHeader(
//   currentStep: 2,
//   totalSteps: 5,
//   showBackButton: true,
//   onBack: () => Navigator.pop(context),
// )
// ```

import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// A header widget that displays onboarding progress and navigation
///
/// This widget shows a linear progress indicator representing
/// the user's progress through the onboarding flow, along with
/// an optional back button for navigation.
///
/// The widget is designed to be placed at the top of onboarding screens
/// and provides visual feedback on the user's progress through the flow.
class OnboardingHeader extends StatelessWidget {
  /// Creates an onboarding header widget
  ///
  /// The [currentStep] must be between 1 and [totalSteps] inclusive.
  /// Both [currentStep] and [totalSteps] must be positive integers.
  ///
  /// If [showBackButton] is true, [onBack] callback is recommended
  /// to handle the back button press event.
  const OnboardingHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.showBackButton = false,
    this.onBack,
    this.showProgressBar = true,
    this.progressBarHeight = 4.0,
  })  : assert(currentStep > 0, 'currentStep must be greater than 0'),
        assert(totalSteps > 0, 'totalSteps must be greater than 0'),
        assert(
            currentStep <= totalSteps, 'currentStep cannot exceed totalSteps');

  /// The current step number (1-based index)
  final int currentStep;

  /// The total number of steps in the onboarding flow
  final int totalSteps;

  /// Whether to show the back button
  final bool showBackButton;

  /// Callback function when the back button is pressed
  ///
  /// If null and [showBackButton] is true, defaults to Navigator.pop
  final VoidCallback? onBack;

  /// Whether to show the progress bar
  final bool showProgressBar;

  /// The height of the progress bar in logical pixels
  final double progressBarHeight;

  /// Calculates the progress value (0.0 to 1.0)
  double get _progress => currentStep / totalSteps;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Onboarding progress: Step $currentStep of $totalSteps',
      value: '${(_progress * 100).toInt()} percent complete',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Back button row
            if (showBackButton) ...[
              _buildBackButton(context),
              const SizedBox(height: Spacing.sm),
            ],
            // Progress bar
            if (showProgressBar) _buildProgressBar(),
          ],
        ),
      ),
    );
  }

  /// Builds the back button
  Widget _buildBackButton(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Go back to previous step',
      child: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20.0,
        ),
        color: TextColors.primary,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 40.0,
          minHeight: 40.0,
        ),
        onPressed: () {
          if (onBack != null) {
            onBack!();
          } else {
            // Default behavior: pop the current route
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  /// Builds the linear progress indicator
  Widget _buildProgressBar() {
    return Semantics(
      label: 'Progress indicator',
      value: '${(_progress * 100).toInt()}%',
      child: ProgressBar(
        value: _progress,
        height: progressBarHeight,
        backgroundColor: BackgroundColors.muted,
        progressColor: BrandColors.primary,
      ),
    );
  }
}

/// Example usage:
///
/// ```dart
/// class OnboardingScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: SafeArea(
///         child: Column(
///           children: [
///             // Header with progress and back button
///             OnboardingHeader(
///               currentStep: 2,
///               totalSteps: 5,
///               showBackButton: true,
///               onBack: () {
///                 // Custom back logic
///                 Navigator.pop(context);
///               },
///             ),
///
///             // Rest of your onboarding content
///             Expanded(
///               child: YourOnboardingContent(),
///             ),
///           ],
///         ),
///       ),
///     );
///   }
/// }
/// ```
///
/// First screen example (no back button):
///
/// ```dart
/// OnboardingHeader(
///   currentStep: 1,
///   totalSteps: 5,
///   showBackButton: false, // Hide back button for first screen
/// )
/// ```
///
/// Customization example:
///
/// ```dart
/// OnboardingHeader(
///   currentStep: 3,
///   totalSteps: 5,
///   showBackButton: true,
///   showProgressBar: false, // Hide progress bar
///   progressBarHeight: 6.0, // Custom height
///   onBack: () {
///     // Custom navigation logic
///     print('Going back...');
///     Navigator.pop(context);
///   },
/// )
/// ```
