/// TabPill Component
///
/// A pill-shaped tab button component with icon and text, supporting two states:
/// - default: White background with light border, gray text
/// - disabled: Gray background with gray border, white text
///
/// Specifications:
/// - Height: 36 (padding 8px vertical + icon 20px)
/// - Pill shape (border radius 9999)
/// - Icon (20x20) + Text with 8px spacing
/// - Icons from pickly_design_system assets
///
/// Usage:
/// ```dart
/// TabPill.default_(
///   iconPath: 'assets/icons/ic_location.svg',
///   text: '서울',
///   onTap: () => print('Tab tapped'),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../tokens/design_tokens.dart';

/// Tab pill state enum
enum TabPillState {
  /// Default state - white background, light border, gray text
  default_,

  /// Disabled state - gray background, gray border, white text
  disabled,
}

/// Pill-shaped tab button component with icon and text
class TabPill extends StatelessWidget {
  /// The icon path from assets
  final String iconPath;

  /// The text to display
  final String text;

  /// The current state of the tab
  final TabPillState state;

  /// Callback when the tab is tapped (not called when disabled)
  final VoidCallback? onTap;

  const TabPill({
    super.key,
    required this.iconPath,
    required this.text,
    required this.state,
    this.onTap,
  });

  /// Creates a default state tab pill
  factory TabPill.default_({
    Key? key,
    required String iconPath,
    required String text,
    VoidCallback? onTap,
  }) {
    return TabPill(
      key: key,
      iconPath: iconPath,
      text: text,
      state: TabPillState.default_,
      onTap: onTap,
    );
  }

  /// Creates a disabled state tab pill
  factory TabPill.disabled({
    Key? key,
    required String iconPath,
    required String text,
  }) {
    return TabPill(
      key: key,
      iconPath: iconPath,
      text: text,
      state: TabPillState.disabled,
      onTap: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get colors based on state
    final backgroundColor = _getBackgroundColor();
    final borderColor = _getBorderColor();
    final textColor = _getTextColor();
    final iconColor = _getIconColor();

    final isDisabled = state == TabPillState.disabled;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: borderColor,
            ),
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildIcon(iconColor),
            const SizedBox(width: 8),
            Text(
              text,
              style: PicklyTypography.bodyMedium.copyWith(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build SVG icon widget (supports network and asset URLs)
  Widget _buildIcon(Color? iconColor) {
    // Check if it's a network URL
    if (iconPath.startsWith('http://') || iconPath.startsWith('https://')) {
      return SvgPicture.network(
        iconPath,
        width: 20,
        height: 20,
        colorFilter: iconColor != null
            ? ColorFilter.mode(iconColor, BlendMode.srcIn)
            : null,
        placeholderBuilder: (context) => SizedBox(
          width: 20,
          height: 20,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: iconColor ?? const Color(0xFF828282),
            ),
          ),
        ),
      );
    }

    // Asset path - remove asset:// prefix if present
    final assetPath = iconPath.startsWith('asset://')
        ? iconPath.replaceFirst('asset://', '')
        : iconPath;

    // Check if path already includes package prefix
    final bool hasPackagePrefix = assetPath.startsWith('packages/');

    return SvgPicture.asset(
      assetPath,
      package: hasPackagePrefix ? null : 'pickly_design_system',
      width: 20,
      height: 20,
      colorFilter: iconColor != null
          ? ColorFilter.mode(iconColor, BlendMode.srcIn)
          : null,
    );
  }

  Color _getBackgroundColor() {
    switch (state) {
      case TabPillState.default_:
        return Colors.white; // tab-default-bg
      case TabPillState.disabled:
        return const Color(0xFFDDDDDD); // tab-disabled-bg
    }
  }

  Color _getBorderColor() {
    switch (state) {
      case TabPillState.default_:
        return const Color(0xFFEBEBEB); // tab-default-border
      case TabPillState.disabled:
        return const Color(0xFFDDDDDD); // tab-disabled-border
    }
  }

  Color _getTextColor() {
    switch (state) {
      case TabPillState.default_:
        return const Color(0xFF828282); // tab-default-text
      case TabPillState.disabled:
        return Colors.white; // tab-disabled-text
    }
  }

  Color? _getIconColor() {
    switch (state) {
      case TabPillState.default_:
        return null; // Use icon's original color
      case TabPillState.disabled:
        return Colors.white; // White icon for disabled state
    }
  }
}
