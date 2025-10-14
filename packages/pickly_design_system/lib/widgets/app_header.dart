/// AppHeader Component
///
/// A versatile header component supporting three different types:
/// - Home: Logo + hamburger menu
/// - Detail: Back button + centered title + optional actions
/// - Onboarding: Back button only
///
/// All designs follow Figma specifications with exact measurements.
///
/// Usage examples:
/// ```dart
/// // Home header with menu
/// AppHeader.home(
///   onMenuTap: () => print('Menu tapped'),
/// )
///
/// // Detail header with title
/// AppHeader.detail(
///   title: 'Product Details',
///   onBack: () => Navigator.pop(context),
///   actions: [
///     IconButton(
///       icon: Icon(Icons.share),
///       onPressed: () => print('Share'),
///     ),
///   ],
/// )
///
/// // Onboarding header with back button only
/// AppHeader.onboarding(
///   onBack: () => Navigator.pop(context),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Enum defining the three header types
enum AppHeaderType {
  /// Home header: Logo + hamburger menu
  home,

  /// Detail header: Back + centered title + optional actions
  detail,

  /// Onboarding header: Back button only
  onboarding,
}

/// AppHeader component with three variations
///
/// Implements [PreferredSizeWidget] to work with [Scaffold.appBar]
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  /// The type of header to display
  final AppHeaderType type;

  /// Title text (used only for detail type)
  final String? title;

  /// Callback when back button is pressed
  final VoidCallback? onBack;

  /// Callback when menu button is pressed (home type only)
  final VoidCallback? onMenuTap;

  /// Optional action widgets (detail type only)
  final List<Widget>? actions;

  /// Private constructor for internal use
  const AppHeader._({
    required this.type,
    this.title,
    this.onBack,
    this.onMenuTap,
    this.actions,
  });

  /// Creates a home header with logo and hamburger menu
  ///
  /// [onMenuTap] callback is required for menu button interaction
  factory AppHeader.home({
    required VoidCallback onMenuTap,
  }) {
    return AppHeader._(
      type: AppHeaderType.home,
      onMenuTap: onMenuTap,
    );
  }

  /// Creates a detail header with back button, centered title, and optional actions
  ///
  /// [title] is required and will be displayed in the center
  /// [onBack] callback is optional, defaults to Navigator.pop if null
  /// [actions] optional list of widgets displayed on the right side
  factory AppHeader.detail({
    required String title,
    VoidCallback? onBack,
    List<Widget>? actions,
  }) {
    assert(title.isNotEmpty, 'Title cannot be empty for detail header');
    return AppHeader._(
      type: AppHeaderType.detail,
      title: title,
      onBack: onBack,
      actions: actions,
    );
  }

  /// Creates an onboarding header with only a back button
  ///
  /// [onBack] callback is required for back button interaction
  factory AppHeader.onboarding({
    required VoidCallback onBack,
  }) {
    return AppHeader._(
      type: AppHeaderType.onboarding,
      onBack: onBack,
    );
  }

  /// Fixed header height: 48px as per Figma specs
  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AppHeaderType.home:
        return _buildHomeHeader();
      case AppHeaderType.detail:
        return _buildDetailHeader(context);
      case AppHeaderType.onboarding:
        return _buildOnboardingHeader();
    }
  }

  /// Builds the home header: Logo + hamburger menu
  Widget _buildHomeHeader() {
    assert(onMenuTap != null, 'onMenuTap callback is required for home header');

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg), // 16px
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          // Pickly logo (28px height)
          SvgPicture.asset(
            'assets/images/pickly_logo_text.svg',
            package: 'pickly_design_system',
            height: 28,
          ),
          const Spacer(),
          // Hamburger menu button (20x20 icon, 32x32 tap target)
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ic_hamburger.svg',
              package: 'pickly_design_system',
              width: 20,
              height: 20,
            ),
            iconSize: 32,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            onPressed: onMenuTap,
          ),
        ],
      ),
    );
  }

  /// Builds the detail header: Back button + centered title + optional actions
  Widget _buildDetailHeader(BuildContext context) {
    assert(title != null && title!.isNotEmpty, 'Title is required for detail header');

    // Default back action: Navigator.pop
    final backAction = onBack ?? () => Navigator.of(context).maybePop();

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg), // 16px
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          // Back button (20px icon, 32x32 tap target)
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ic_back.svg',
              package: 'pickly_design_system',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                TextColors.primary,
                BlendMode.srcIn,
              ),
            ),
            iconSize: 32,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            onPressed: backAction,
          ),
          // Centered title
          Expanded(
            child: Text(
              title!,
              style: PicklyTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700, // Bold
                fontSize: 18,
                height: 1.33, // Line height: 24px / 18px = 1.33
                color: TextColors.primary, // #3E3E3E
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Optional actions or spacer to balance the back button
          if (actions != null && actions!.isNotEmpty)
            ...actions!
          else
            const SizedBox(width: 32), // Balance space for centered title
        ],
      ),
    );
  }

  /// Builds the onboarding header: Back button only
  Widget _buildOnboardingHeader() {
    assert(onBack != null, 'onBack callback is required for onboarding header');

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg), // 16px
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          // Back button (20px icon, 32x32 tap target)
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/ic_back.svg',
              package: 'pickly_design_system',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                TextColors.primary,
                BlendMode.srcIn,
              ),
            ),
            iconSize: 32,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            onPressed: onBack,
          ),
        ],
      ),
    );
  }
}
