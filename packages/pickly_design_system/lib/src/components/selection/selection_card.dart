// Selection Card Widget
//
// A reusable card component for icon-based multiple selection in onboarding flows.
// Supports single and multiple selection modes with visual feedback.
//
// Features:
// - Icon-based selection with labels
// - Active/inactive states with visual feedback
// - Multiple selection support
// - Accessibility support
// - Material Design 3 compliant
// - Responsive design
// - Smooth animations
//
// Example:
// ```dart
// SelectionCard(
//   icon: Icons.fitness_center,
//   label: 'Fitness',
//   isSelected: true,
//   onTap: () => handleSelection('fitness'),
// )
// ```

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// A card widget for selectable options with icons
///
/// This widget provides a visual card that can be selected/deselected.
/// It's commonly used in onboarding flows for:
/// - Goal selection
/// - Interest selection
/// - Preference selection
/// - Feature selection
class SelectionCard extends StatefulWidget {
  /// Creates a selection card widget
  ///
  /// The [label] is required to display the card content.
  /// Provide either [icon] for IconData or [iconUrl] for SVG assets.
  /// Use [isSelected] to control the selection state.
  /// Provide [onTap] to handle user interactions.
  const SelectionCard({
    super.key,
    this.icon,
    this.iconUrl,
    required this.label,
    this.subtitle,
    this.isSelected = false,
    this.onTap,
    this.width,
    this.height,
    this.iconSize = 32.0,
    this.enabled = true,
  });

  /// The icon to display in the card (backward compatibility)
  final IconData? icon;

  /// The SVG asset path to display in the card (new approach)
  final String? iconUrl;

  /// The main label text
  final String label;

  /// Optional subtitle text below the label
  final String? subtitle;

  /// Whether this card is currently selected
  final bool isSelected;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Optional fixed width for the card
  final double? width;

  /// Optional fixed height for the card
  final double? height;

  /// Size of the icon in logical pixels
  final double iconSize;

  /// Whether the card is enabled for interaction
  final bool enabled;

  @override
  State<SelectionCard> createState() => _SelectionCardState();
}

class _SelectionCardState extends State<SelectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: PicklyAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      hint: widget.subtitle,
      selected: widget.isSelected,
      enabled: widget.enabled,
      button: true,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.enabled ? widget.onTap : null,
          child: AnimatedContainer(
            duration: PicklyAnimations.normal,
            curve: Curves.easeInOut,
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: _buildDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                _buildIcon(),

                // Spacing
                const SizedBox(height: Spacing.md),

                // Label
                _buildLabel(),

                // Subtitle (if provided)
                if (widget.subtitle != null) ...[
                  const SizedBox(height: Spacing.xs),
                  _buildSubtitle(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the card decoration based on state
  BoxDecoration _buildDecoration() {
    Color backgroundColor;
    Color borderColor;
    List<BoxShadow> shadows;

    if (!widget.enabled) {
      backgroundColor = ChipColors.disabledBg;
      borderColor = BorderColors.disabled;
      shadows = PicklyShadows.none;
    } else if (widget.isSelected) {
      backgroundColor = SurfaceColors.base;
      borderColor = BorderColors.active;
      shadows = PicklyShadows.card;
    } else {
      backgroundColor = SurfaceColors.base;
      borderColor = BorderColors.subtle;
      shadows = _isPressed ? PicklyShadows.none : PicklyShadows.sm;
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: PicklyBorderRadius.radiusLg,
      border: Border.all(
        color: borderColor,
        width: widget.isSelected ? 2.0 : 1.0,
      ),
      boxShadow: shadows,
    );
  }

  /// Builds the icon widget
  Widget _buildIcon() {
    Color iconColor;

    if (!widget.enabled) {
      iconColor = TextColors.disabled;
    } else if (widget.isSelected) {
      iconColor = BrandColors.primary;
    } else {
      iconColor = TextColors.secondary;
    }

    return AnimatedContainer(
      duration: PicklyAnimations.normal,
      curve: Curves.easeInOut,
      child: _buildIconContent(iconColor),
    );
  }

  /// Builds the actual icon content (SVG or Icon)
  Widget _buildIconContent(Color iconColor) {
    // 1. SVG 우선 (새로운 방식)
    if (widget.iconUrl != null) {
      return SvgPicture.asset(
        widget.iconUrl!,
        width: widget.iconSize,
        height: widget.iconSize,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      );
    }

    // 2. Icon fallback (기존 방식, 하위 호환)
    if (widget.icon != null) {
      return Icon(
        widget.icon,
        size: widget.iconSize,
        color: iconColor,
      );
    }

    // 3. 아무것도 없을 경우 빈 위젯
    return SizedBox(
      width: widget.iconSize,
      height: widget.iconSize,
    );
  }

  /// Builds the label text
  Widget _buildLabel() {
    Color textColor;

    if (!widget.enabled) {
      textColor = TextColors.disabled;
    } else if (widget.isSelected) {
      textColor = TextColors.active;
    } else {
      textColor = TextColors.primary;
    }

    return Text(
      widget.label,
      style: PicklyTypography.bodyMedium.copyWith(
        color: textColor,
        fontWeight:
            widget.isSelected ? FontWeight.w700 : PicklyTypography.semibold,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the subtitle text
  Widget _buildSubtitle() {
    return Text(
      widget.subtitle!,
      style: PicklyTypography.bodySmall.copyWith(
        color: widget.enabled ? TextColors.secondary : TextColors.disabled,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Example usage in a grid layout:
///
/// ```dart
/// class GoalSelectionScreen extends StatefulWidget {
///   @override
///   State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
/// }
///
/// class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
///   final Set<String> _selectedGoals = {};
///
///   @override
///   Widget build(BuildContext context) {
///     return GridView.count(
///       crossAxisCount: 2,
///       mainAxisSpacing: Spacing.lg,
///       crossAxisSpacing: Spacing.lg,
///       padding: const EdgeInsets.all(Spacing.lg),
///       children: [
///         // Using SVG icons (new approach)
///         SelectionCard(
///           iconUrl: 'packages/pickly_design_system/assets/icons/fitness.svg',
///           label: 'Fitness',
///           subtitle: 'Stay active',
///           isSelected: _selectedGoals.contains('fitness'),
///           onTap: () => _toggleSelection('fitness'),
///         ),
///         // Using IconData (backward compatibility)
///         SelectionCard(
///           icon: Icons.restaurant,
///           label: 'Nutrition',
///           subtitle: 'Eat healthy',
///           isSelected: _selectedGoals.contains('nutrition'),
///           onTap: () => _toggleSelection('nutrition'),
///         ),
///         SelectionCard(
///           icon: Icons.spa,
///           label: 'Wellness',
///           subtitle: 'Mental health',
///           isSelected: _selectedGoals.contains('wellness'),
///           onTap: () => _toggleSelection('wellness'),
///         ),
///       ],
///     );
///   }
///
///   void _toggleSelection(String goal) {
///     setState(() {
///       if (_selectedGoals.contains(goal)) {
///         _selectedGoals.remove(goal);
///       } else {
///         _selectedGoals.add(goal);
///       }
///     });
///   }
/// }
/// ```
///
/// Single selection example:
///
/// ```dart
/// String? _selectedOption;
///
/// SelectionCard(
///   icon: Icons.person,
///   label: 'Individual',
///   isSelected: _selectedOption == 'individual',
///   onTap: () => setState(() => _selectedOption = 'individual'),
/// )
/// ```
///
/// Using with AgeCategory model:
///
/// ```dart
/// SelectionCard(
///   iconUrl: category.iconUrl,
///   icon: category.iconUrl == null ? _getIconData(category.iconComponent) : null,
///   label: category.title,
///   subtitle: category.description,
///   isSelected: isSelected,
///   onTap: () => toggleSelection(category.id),
/// )
/// ```
