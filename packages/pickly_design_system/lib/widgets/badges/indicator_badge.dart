/// IndicatorBadge Component
///
/// A badge component displaying counter information (e.g., "1/8")
/// with a semi-transparent dark background and white text.
///
/// Specifications:
/// - Padding: 12px horizontal, 2px vertical
/// - Background: rgba(36, 36, 36, 0.4) (#242424 with 40% opacity)
/// - Text: White, 12px font, 600 weight
/// - Border radius: 100px (fully rounded)
///
/// Usage:
/// ```dart
/// IndicatorBadge(
///   current: 1,
///   total: 8,
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../tokens/design_tokens.dart';

/// Badge component for displaying counter information
class IndicatorBadge extends StatelessWidget {
  /// Current index or count
  final int current;

  /// Total count
  final int total;

  /// Optional custom text (overrides current/total)
  final String? customText;

  const IndicatorBadge({
    super.key,
    required this.current,
    required this.total,
    this.customText,
  });

  /// Creates a badge with custom text
  factory IndicatorBadge.custom({
    Key? key,
    required String text,
  }) {
    return IndicatorBadge(
      key: key,
      current: 0,
      total: 0,
      customText: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayText = customText ?? '$current/$total';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0x66242424), // rgba(36, 36, 36, 0.4)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      child: Text(
        displayText,
        style: PicklyTypography.bodyMedium.copyWith(
          color: Colors.white, // text-inverse
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.50,
        ),
      ),
    );
  }
}
