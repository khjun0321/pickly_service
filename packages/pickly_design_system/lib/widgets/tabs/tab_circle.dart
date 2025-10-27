/// TabCircle Component
///
/// A circular tab button component with three states:
/// - default: White background with light border
/// - active: White background with green border (2px)
/// - disabled: Gray background with gray border
///
/// Specifications:
/// - Size: 48x48 (padding 12px + icon 24x24)
/// - Circular shape (border radius 9999)
/// - Icons from pickly_design_system assets
///
/// Usage:
/// ```dart
/// TabCircle.active(
///   iconPath: 'assets/icons/ic_home.svg',
///   onTap: () => print('Tab tapped'),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../tokens/design_tokens.dart';

/// Tab circle state enum
enum TabCircleState {
  /// Default state - white background, light border
  default_,

  /// Active state - white background, green border (2px)
  active,

  /// Disabled state - gray background, gray border
  disabled,
}

/// Circular tab button component
class TabCircle extends StatelessWidget {
  /// The icon path from assets
  final String iconPath;

  /// The current state of the tab
  final TabCircleState state;

  /// Callback when the tab is tapped (not called when disabled)
  final VoidCallback? onTap;

  const TabCircle({
    super.key,
    required this.iconPath,
    required this.state,
    this.onTap,
  });

  /// Creates a default state tab circle
  factory TabCircle.default_({
    Key? key,
    required String iconPath,
    VoidCallback? onTap,
  }) {
    return TabCircle(
      key: key,
      iconPath: iconPath,
      state: TabCircleState.default_,
      onTap: onTap,
    );
  }

  /// Creates an active state tab circle
  factory TabCircle.active({
    Key? key,
    required String iconPath,
    VoidCallback? onTap,
  }) {
    return TabCircle(
      key: key,
      iconPath: iconPath,
      state: TabCircleState.active,
      onTap: onTap,
    );
  }

  /// Creates a disabled state tab circle
  factory TabCircle.disabled({
    Key? key,
    required String iconPath,
  }) {
    return TabCircle(
      key: key,
      iconPath: iconPath,
      state: TabCircleState.disabled,
      onTap: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get colors based on state
    final backgroundColor = _getBackgroundColor();
    final borderColor = _getBorderColor();
    final borderWidth = _getBorderWidth();
    final iconColor = _getIconColor();

    final isDisabled = state == TabCircleState.disabled;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: borderWidth,
              color: borderColor,
            ),
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        child: SvgPicture.asset(
          iconPath,
          package: 'pickly_design_system',
          width: 24,
          height: 24,
          colorFilter: iconColor != null
              ? ColorFilter.mode(iconColor, BlendMode.srcIn)
              : null,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (state) {
      case TabCircleState.default_:
        return Colors.white; // tab-default-bg
      case TabCircleState.active:
        return Colors.white; // surface-default
      case TabCircleState.disabled:
        return const Color(0xFFDDDDDD); // background-muted
    }
  }

  Color _getBorderColor() {
    switch (state) {
      case TabCircleState.default_:
        return const Color(0xFFEBEBEB); // tab-default-border
      case TabCircleState.active:
        return BrandColors.primary; // tab-active-border (#27B473)
      case TabCircleState.disabled:
        return const Color(0xFFDDDDDD); // tab-disabled-border
    }
  }

  double _getBorderWidth() {
    switch (state) {
      case TabCircleState.default_:
        return 1.0;
      case TabCircleState.active:
        return 2.0;
      case TabCircleState.disabled:
        return 1.0;
    }
  }

  Color? _getIconColor() {
    switch (state) {
      case TabCircleState.default_:
        return null; // Use icon's original color
      case TabCircleState.active:
        return null; // Use icon's original color
      case TabCircleState.disabled:
        return const Color(0xFF999999); // Dim the icon
    }
  }
}
