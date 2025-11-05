/// TabCircleWithLabel Component
///
/// A circular tab button with a label below it, supporting three states:
/// - default: White background with light border, gray text
/// - active: White background with green border (2px), gray text
/// - disabled: Gray background with gray border, gray text
///
/// Specifications:
/// - Circle size: 48x48 (padding 12px + icon 24x24)
/// - Label: 12px font, 600 weight, below the circle
/// - Total height: 70px (48px circle + 4px spacing + 18px text)
/// - Circular shape for button (border radius 9999)
///
/// Usage:
/// ```dart
/// TabCircleWithLabel.active(
///   iconPath: 'assets/icons/ic_home.svg',
///   label: '인기',
///   onTap: () => print('Tab tapped'),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../tokens/design_tokens.dart';

/// Tab circle with label state enum
enum TabCircleWithLabelState {
  /// Default state - white background, light border, gray text
  default_,

  /// Active state - white background, green border (2px), gray text
  active,

  /// Disabled state - gray background, gray border, gray text
  disabled,
}

/// Circular tab button component with label below
class TabCircleWithLabel extends StatelessWidget {
  /// The icon path from assets
  final String iconPath;

  /// The label text to display below the circle
  final String label;

  /// The current state of the tab
  final TabCircleWithLabelState state;

  /// Callback when the tab is tapped (not called when disabled)
  final VoidCallback? onTap;

  const TabCircleWithLabel({
    super.key,
    required this.iconPath,
    required this.label,
    required this.state,
    this.onTap,
  });

  /// Creates a default state tab circle with label
  factory TabCircleWithLabel.default_({
    Key? key,
    required String iconPath,
    required String label,
    VoidCallback? onTap,
  }) {
    return TabCircleWithLabel(
      key: key,
      iconPath: iconPath,
      label: label,
      state: TabCircleWithLabelState.default_,
      onTap: onTap,
    );
  }

  /// Creates an active state tab circle with label
  factory TabCircleWithLabel.active({
    Key? key,
    required String iconPath,
    required String label,
    VoidCallback? onTap,
  }) {
    return TabCircleWithLabel(
      key: key,
      iconPath: iconPath,
      label: label,
      state: TabCircleWithLabelState.active,
      onTap: onTap,
    );
  }

  /// Creates a disabled state tab circle with label
  factory TabCircleWithLabel.disabled({
    Key? key,
    required String iconPath,
    required String label,
  }) {
    return TabCircleWithLabel(
      key: key,
      iconPath: iconPath,
      label: label,
      state: TabCircleWithLabelState.disabled,
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
    final textColor = _getTextColor();

    final isDisabled = state == TabCircleWithLabelState.disabled;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: SizedBox(
        width: 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circle button
            Container(
              width: 48,
              height: 48,
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
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: _buildIcon(iconColor),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: PicklyTypography.bodyMedium.copyWith(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.33,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (state) {
      case TabCircleWithLabelState.default_:
        return Colors.white; // tab-default-bg
      case TabCircleWithLabelState.active:
        return Colors.white; // surface-default
      case TabCircleWithLabelState.disabled:
        return const Color(0xFFDDDDDD); // background-muted
    }
  }

  Color _getBorderColor() {
    switch (state) {
      case TabCircleWithLabelState.default_:
        return const Color(0xFFEBEBEB); // tab-default-border
      case TabCircleWithLabelState.active:
        return BrandColors.primary; // tab-active-border (#27B473)
      case TabCircleWithLabelState.disabled:
        return const Color(0xFFDDDDDD); // tab-disabled-border
    }
  }

  double _getBorderWidth() {
    switch (state) {
      case TabCircleWithLabelState.default_:
        return 1.0;
      case TabCircleWithLabelState.active:
        return 2.0;
      case TabCircleWithLabelState.disabled:
        return 1.0;
    }
  }

  Color? _getIconColor() {
    switch (state) {
      case TabCircleWithLabelState.default_:
        return null; // Use icon's original color
      case TabCircleWithLabelState.active:
        return null; // Use icon's original color
      case TabCircleWithLabelState.disabled:
        return const Color(0xFF999999); // Dim the icon
    }
  }

  Color _getTextColor() {
    switch (state) {
      case TabCircleWithLabelState.default_:
        return const Color(0xFF828282); // text-secondary
      case TabCircleWithLabelState.active:
        return const Color(0xFF828282); // text-secondary
      case TabCircleWithLabelState.disabled:
        return const Color(0xFF999999); // text-disabled
    }
  }

  /// Build icon widget - supports both asset:// and network URLs
  ///
  /// PRD v9.9.2: Dynamic icon loading
  Widget _buildIcon(Color? iconColor) {
    if (iconPath.startsWith('asset://')) {
      // Load from local asset
      final assetPath = iconPath.replaceFirst('asset://', '');

      return SvgPicture.asset(
        assetPath,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        colorFilter: iconColor != null
            ? ColorFilter.mode(iconColor, BlendMode.srcIn)
            : null,
      );
    } else if (iconPath.startsWith('http://') || iconPath.startsWith('https://')) {
      // Load from network
      return SvgPicture.network(
        iconPath,
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        colorFilter: iconColor != null
            ? ColorFilter.mode(iconColor, BlendMode.srcIn)
            : null,
        placeholderBuilder: (context) => const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else {
      // Fallback: treat as asset path (backward compatibility)
      return SvgPicture.asset(
        iconPath,
        package: 'pickly_design_system',
        width: 24,
        height: 24,
        fit: BoxFit.contain,
        colorFilter: iconColor != null
            ? ColorFilter.mode(iconColor, BlendMode.srcIn)
            : null,
      );
    }
  }
}
