/// Pickly Design System - Search Bar Component
///
/// A reusable search bar component with three states:
/// - Default: Shows placeholder text with default border
/// - Active/Focus: Shows active border color when focused
/// - Filled: Shows text with default border when not focused
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../tokens/design_tokens.dart';

/// Search bar component with Pickly design system styling
///
/// Features:
/// - Rounded pill shape (border radius 9999)
/// - Search icon on the left
/// - Placeholder text support
/// - Active border color on focus
/// - Customizable callbacks
class PicklySearchBar extends StatefulWidget {
  /// Creates a Pickly search bar
  const PicklySearchBar({
    super.key,
    this.controller,
    this.placeholder = '검색어를 입력해주세요.',
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
  });

  /// Controller for the text field
  final TextEditingController? controller;

  /// Placeholder text shown when empty
  final String placeholder;

  /// Called when the text changes
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the text
  final ValueChanged<String>? onSubmitted;

  /// Whether the search bar is enabled
  final bool enabled;

  /// Whether to auto-focus the text field
  final bool autofocus;

  @override
  State<PicklySearchBar> createState() => _PicklySearchBarState();
}

class _PicklySearchBarState extends State<PicklySearchBar> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine border color based on state
    final borderColor = _isFocused ? InputColors.borderActive : InputColors.border;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: widget.enabled ? InputColors.bg : InputColors.disabledBg,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: borderColor,
          ),
          borderRadius: BorderRadius.circular(PicklyBorderRadius.full),
        ),
      ),
      child: Row(
        children: [
          // Search icon
          SvgPicture.asset(
            'assets/icons/ic_search.svg',
            width: 20,
            height: 20,
            package: 'pickly_design_system',
            colorFilter: ColorFilter.mode(
              widget.enabled ? InputColors.placeholder : InputColors.borderDisabled,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: PicklyTypography.bodyLarge.copyWith(
                color: InputColors.text,
                fontWeight: FontWeight.w600,
                height: 1.50,
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: PicklyTypography.bodyLarge.copyWith(
                  color: InputColors.placeholder,
                  fontWeight: FontWeight.w600,
                  height: 1.50,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Search action icon (right side)
          SvgPicture.asset(
            'assets/icons/ic_search.svg',
            width: 20,
            height: 20,
            package: 'pickly_design_system',
            colorFilter: ColorFilter.mode(
              widget.enabled ? InputColors.placeholder : InputColors.borderDisabled,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}
