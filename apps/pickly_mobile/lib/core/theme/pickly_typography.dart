// Pickly Typography - Mobile App Theme
//
// Typography styles derived from design_tokens.dart
// Provides consistent text styling across the mobile application.

import 'package:flutter/material.dart';

/// Typography system for Pickly mobile app
/// Based on Pretendard font family with Korean support
class PicklyTypography {
  PicklyTypography._();

  // Font Family
  static const String fontFamily = 'Pretendard';

  // Font Sizes
  static const double size12 = 12.0;
  static const double size14 = 14.0;
  static const double size15 = 15.0;
  static const double size16 = 16.0;
  static const double size18 = 18.0;
  static const double size22 = 22.0;

  // Font Weights
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Line Heights
  static const double lineHeight18 = 18.0;
  static const double lineHeight20 = 20.0;
  static const double lineHeight24 = 24.0;
  static const double lineHeight32 = 32.0;

  // ========================================
  // Title Styles
  // ========================================

  /// Large title style (22px, bold)
  /// Use for: Screen titles, major headings
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: size22,
    fontWeight: bold,
    height: lineHeight32 / size22,
  );

  /// Medium title style (18px, bold)
  /// Use for: Section headers, card titles
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: size18,
    fontWeight: bold,
    height: lineHeight24 / size18,
  );

  // ========================================
  // Body Styles
  // ========================================

  /// Large body text (16px, semibold)
  /// Use for: Primary content, emphasized text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: size16,
    fontWeight: semibold,
    height: lineHeight24 / size16,
  );

  /// Medium body text (15px, semibold)
  /// Use for: Standard body text, descriptions
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: size15,
    fontWeight: semibold,
    height: lineHeight24 / size15,
  );

  /// Small body text (14px, semibold)
  /// Use for: Secondary content, labels
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: size14,
    fontWeight: semibold,
    height: lineHeight20 / size14,
  );

  // ========================================
  // Caption Styles
  // ========================================

  /// Large caption (16px, semibold)
  /// Use for: Emphasized captions, metadata
  static const TextStyle captionLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: size16,
    fontWeight: semibold,
    height: lineHeight24 / size16,
  );

  /// Small caption (12px, semibold)
  /// Use for: Timestamps, hints, fine print
  static const TextStyle captionSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: size12,
    fontWeight: semibold,
    height: lineHeight18 / size12,
  );

  // ========================================
  // Button Styles
  // ========================================

  /// Large button text (16px, bold)
  /// Use for: Primary buttons, CTAs
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: size16,
    fontWeight: bold,
    height: lineHeight24 / size16,
  );

  /// Medium button text (14px, bold)
  /// Use for: Secondary buttons
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: size14,
    fontWeight: bold,
    height: lineHeight20 / size14,
  );

  /// Small button text (12px, semibold)
  /// Use for: Tertiary buttons, chips
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: size12,
    fontWeight: semibold,
    height: lineHeight18 / size12,
  );
}
