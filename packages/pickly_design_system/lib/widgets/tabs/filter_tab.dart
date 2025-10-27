import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Filter tab widget for list filtering
///
/// A tab with underline indicator when selected, used for filtering lists.
/// Supports active and inactive states with appropriate text colors and borders.
///
/// Example:
/// ```dart
/// FilterTab(
///   label: '등록순',
///   isSelected: true,
///   onTap: () {},
/// )
/// ```
class FilterTab extends StatelessWidget {
  /// The label text to display
  final String label;

  /// Whether this tab is currently selected
  final bool isSelected;

  /// Callback when tab is tapped
  final VoidCallback? onTap;

  const FilterTab({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          border: isSelected
              ? Border(
                  bottom: BorderSide(
                    width: 2,
                    color: TextColors.primary, // #3E3E3E
                  ),
                )
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: PicklyTypography.buttonLarge.copyWith(
              color: isSelected ? TextColors.primary : TextColors.secondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Filter tab bar widget for managing multiple filter tabs
///
/// A horizontal row of FilterTab widgets with proper spacing.
/// Manages the selected state internally or can be controlled externally.
///
/// Example:
/// ```dart
/// FilterTabBar(
///   tabs: ['등록순', '모집중', '마감'],
///   selectedIndex: 0,
///   onTabSelected: (index) {
///     // Handle tab selection
///   },
/// )
/// ```
class FilterTabBar extends StatelessWidget {
  /// List of tab labels
  final List<String> tabs;

  /// Currently selected tab index
  final int selectedIndex;

  /// Callback when a tab is selected
  final Function(int index)? onTabSelected;

  const FilterTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          tabs.length,
          (index) => FilterTab(
            label: tabs[index],
            isSelected: selectedIndex == index,
            onTap: onTabSelected != null ? () => onTabSelected!(index) : null,
          ),
        ),
      ),
    );
  }
}
