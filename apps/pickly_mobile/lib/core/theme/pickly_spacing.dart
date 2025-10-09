// Pickly Spacing - Mobile App Theme
//
// Spacing system derived from design_tokens.dart
// Provides consistent spacing values across the mobile application.

import 'package:flutter/material.dart';

// ========================================
// 📏 Spacing System
// ========================================

/// Standard spacing scale for Pickly application
/// Based on 4px increments for consistency
class Spacing {
  Spacing._();

  /// No spacing (0px)
  /// Use for: Removing padding/margin
  static const double none = 0.0;

  /// Extra small spacing (4px)
  /// Use for: Tight spacing, icon padding
  static const double xs = 4.0;

  /// Small spacing (8px)
  /// Use for: Compact layouts, list item padding
  static const double sm = 8.0;

  /// Medium spacing (12px)
  /// Use for: Standard element spacing
  static const double md = 12.0;

  /// Large spacing (16px)
  /// Use for: Section padding, card padding
  static const double lg = 16.0;

  /// Extra large spacing (20px)
  /// Use for: Component separation
  static const double xl = 20.0;

  /// Double extra large spacing (24px)
  /// Use for: Section breaks, major component spacing
  static const double xxl = 24.0;

  /// Triple extra large spacing (32px)
  /// Use for: Screen padding, major section separation
  static const double xxxl = 32.0;

  /// Huge spacing (40px)
  /// Use for: Large content gaps
  static const double huge = 40.0;

  /// Massive spacing (48px)
  /// Use for: Hero sections, major page divisions
  static const double massive = 48.0;

  // ========================================
  // EdgeInsets Helpers
  // ========================================

  /// Common padding values as EdgeInsets
  static const EdgeInsets paddingNone = EdgeInsets.zero;
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);
  static const EdgeInsets paddingXxxl = EdgeInsets.all(xxxl);

  /// Horizontal padding
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets horizontalXxl = EdgeInsets.symmetric(horizontal: xxl);
  static const EdgeInsets horizontalXxxl = EdgeInsets.symmetric(horizontal: xxxl);

  /// Vertical padding
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets verticalXxl = EdgeInsets.symmetric(vertical: xxl);
  static const EdgeInsets verticalXxxl = EdgeInsets.symmetric(vertical: xxxl);
}

// ========================================
// 🔲 Border Radius
// ========================================

/// Border radius system for consistent rounded corners
class PicklyBorderRadius {
  PicklyBorderRadius._();

  // Radius values
  static const double none = 0.0;
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 13.5;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double full = 9999.0;

  // BorderRadius objects for direct use
  static const BorderRadius radiusNone = BorderRadius.zero;
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(full));
}

// ========================================
// 🎭 Shadows
// ========================================

/// Shadow system for elevation and depth
class PicklyShadows {
  PicklyShadows._();

  /// No shadow
  static const List<BoxShadow> none = [];

  /// Small shadow (for subtle elevation)
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  /// Medium shadow (for standard elevation)
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000), // rgba(0, 0, 0, 0.1)
      offset: Offset(0, 4),
      blurRadius: 6,
    ),
  ];

  /// Card shadow (for card components)
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14000000), // rgba(0, 0, 0, 0.08)
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];
}

// ========================================
// ⏱️ Animations
// ========================================

/// Animation durations and curves
class PicklyAnimations {
  PicklyAnimations._();

  /// Fast animation (150ms)
  /// Use for: Micro-interactions, button presses
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal animation (250ms)
  /// Use for: Standard transitions, page changes
  static const Duration normal = Duration(milliseconds: 250);

  /// Slow animation (350ms)
  /// Use for: Complex animations, modal appearances
  static const Duration slow = Duration(milliseconds: 350);

  /// Standard curves
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
}

// ========================================
// 📱 Layout Constants
// ========================================

/// Layout dimensions and constraints
class PicklyLayout {
  PicklyLayout._();

  /// Maximum content width
  static const double maxWidth = 1200.0;

  /// Standard container padding
  static const double containerPadding = 16.0;

  /// Header/AppBar height
  static const double headerHeight = 60.0;

  /// Bottom navigation height
  static const double navigationHeight = 72.0;
}
