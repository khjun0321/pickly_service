/// Pickly Design System - Bottom Navigation Bar
///
/// A reusable bottom navigation bar component with rounded top corners,
/// shadow, and iPhone home indicator support.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../tokens/design_tokens.dart';

/// Navigation item data model
class PicklyNavigationItem {
  const PicklyNavigationItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  /// Icon asset path (relative to assets/)
  final String icon;

  /// Label text
  final String label;

  /// Callback when tapped
  final VoidCallback? onTap;
}

/// Bottom navigation bar component with Pickly design system styling
///
/// Features:
/// - 5 navigation items (home, benefits, calendar, ai, my page)
/// - Rounded top corners (24px)
/// - Shadow effect
/// - Active/inactive states
/// - iPhone home indicator area
class PicklyBottomNavigationBar extends StatelessWidget {
  /// Creates a Pickly bottom navigation bar
  const PicklyBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.items,
    this.onTap,
  });

  /// Current selected index (0-4)
  final int currentIndex;

  /// Navigation items
  final List<PicklyNavigationItem> items;

  /// Called when a navigation item is tapped
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    // Get bottom safe area padding for iOS home indicator
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: SurfaceColors.base,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x14000000), // rgba(0, 0, 0, 0.08)
            blurRadius: 6,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 16,
          bottom: bottomPadding > 0 ? bottomPadding : 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            items.length,
            (index) => _buildNavigationItem(
              item: items[index],
              isActive: index == currentIndex,
              onTap: () => onTap?.call(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required PicklyNavigationItem item,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final textColor = isActive ? TextColors.primary : TextColors.tertiary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            SvgPicture.asset(
              item.icon,
              width: 24,
              height: 24,
              package: 'pickly_design_system',
              colorFilter: ColorFilter.mode(
                textColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),

            // Label
            Text(
              item.label,
              style: PicklyTypography.captionSmall.copyWith(
                color: textColor,
                height: 1.50,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pre-defined navigation items for Pickly app
class PicklyNavigationItems {
  PicklyNavigationItems._();

  static const home = PicklyNavigationItem(
    icon: 'assets/icons/ic_home.svg',
    label: '홈',
  );

  static const benefits = PicklyNavigationItem(
    icon: 'assets/icons/ic_present.svg',
    label: '혜택',
  );

  static const calendar = PicklyNavigationItem(
    icon: 'assets/icons/ic_calendar.svg',
    label: '일정',
  );

  static const ai = PicklyNavigationItem(
    icon: 'assets/icons/ic_ai.svg',
    label: '에이아이',
  );

  static const myPage = PicklyNavigationItem(
    icon: 'assets/icons/ic_profile.svg',
    label: '마이페이지',
  );

  /// Default navigation items list
  static const List<PicklyNavigationItem> defaults = [
    home,
    benefits,
    calendar,
    ai,
    myPage,
  ];
}
