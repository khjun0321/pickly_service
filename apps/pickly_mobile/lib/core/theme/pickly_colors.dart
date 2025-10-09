// Pickly Colors - Mobile App Theme
//
// Color palette derived from design_tokens.dart
// Provides consistent color usage across the mobile application.

import 'package:flutter/material.dart';

// ========================================
// 🎨 Brand Colors (브랜드 색상)
// ========================================

/// Primary brand colors for Pickly application
class BrandColors {
  BrandColors._();

  /// Primary brand color (Green)
  /// Use for: Main CTAs, active states, primary actions
  static const Color primary = Color(0xFF27B473);

  /// Secondary brand color (Blue)
  /// Use for: Secondary actions, informational elements
  static const Color secondary = Color(0xFF327DFF);

  /// Banner background color
  /// Use for: Promotional banners, featured content
  static const Color banner = Color(0xFF327DFF);

  /// Splash screen background
  /// Use for: App launch screen
  static const Color splashBg = Color(0xFF27B473);
}

// ========================================
// 🖼️ Background Colors (배경 색상)
// ========================================

/// Background colors for different contexts
class BackgroundColors {
  BackgroundColors._();

  /// App default background (Light gray)
  /// Use for: Main screen backgrounds
  static const Color app = Color(0xFFF4F4F4);

  /// Muted background (Gray)
  /// Use for: Disabled states, inactive elements
  static const Color muted = Color(0xFFDDDDDD);

  /// Inverse background (White)
  /// Use for: Overlays, modals
  static const Color inverse = Color(0xFFFFFFFF);

  /// Surface background (White)
  /// Use for: Cards, containers, elevated surfaces
  static const Color surface = Color(0xFFFFFFFF);
}

// ========================================
// 📄 Surface Colors (표면 색상)
// ========================================

/// Surface colors for elevated UI elements
class SurfaceColors {
  SurfaceColors._();

  /// Base surface color (White)
  /// Use for: Standard cards, containers
  static const Color base = Color(0xFFFFFFFF);

  /// Elevated surface (White)
  /// Use for: Floating action buttons, raised cards
  static const Color elevated = Color(0xFFFFFFFF);

  /// Highlighted surface (White)
  /// Use for: Focus states, selected items
  static const Color highlight = Color(0xFFFFFFFF);
}

// ========================================
// ✍️ Text Colors (텍스트 색상)
// ========================================

/// Text colors for different contexts
class TextColors {
  TextColors._();

  /// Primary text color (Dark gray)
  /// Use for: Main content, headings, body text
  static const Color primary = Color(0xFF3E3E3E);

  /// Secondary text color (Medium gray)
  /// Use for: Supporting text, descriptions
  static const Color secondary = Color(0xFF828282);

  /// Tertiary text color (Light gray)
  /// Use for: Placeholders, hints
  static const Color tertiary = Color(0xFFBABABA);

  /// Muted text color (Light gray)
  /// Use for: De-emphasized content
  static const Color muted = Color(0xFFB0B0B0);

  /// Disabled text color (White)
  /// Use for: Disabled buttons, inactive text
  static const Color disabled = Color(0xFFFFFFFF);

  /// Inverse text color (White)
  /// Use for: Text on dark backgrounds
  static const Color inverse = Color(0xFFFFFFFF);

  /// Active text color (Green)
  /// Use for: Selected items, active states
  static const Color active = Color(0xFF27B473);
}

// ========================================
// 🎯 State Colors (상태 색상)
// ========================================

/// Colors representing different UI states
class StateColors {
  StateColors._();

  /// Error state (Red)
  /// Use for: Error messages, failed actions
  static const Color error = Color(0xFFFF4257);

  /// Warning state (Red)
  /// Use for: Warnings, cautionary messages
  static const Color warning = Color(0xFFFF4257);

  /// Success state (White)
  /// Use for: Success messages, completed actions
  static const Color success = Color(0xFFFFFFFF);

  /// Info state (White)
  /// Use for: Informational messages
  static const Color info = Color(0xFFFFFFFF);

  /// Active state (Green)
  /// Use for: Active selections, current state
  static const Color active = Color(0xFF27B473);
}

// ========================================
// 🔲 Border Colors (테두리 색상)
// ========================================

/// Border colors for different contexts
class BorderColors {
  BorderColors._();

  /// Subtle border (Light gray)
  /// Use for: Input fields, cards, dividers
  static const Color subtle = Color(0xFFEBEBEB);

  /// Divider color (Light gray)
  /// Use for: List separators, section dividers
  static const Color divider = Color(0xFFEBEBEB);

  /// Strong border (Dark gray)
  /// Use for: Emphasized borders, focus states
  static const Color strong = Color(0xFF3E3E3E);

  /// Active border (Green)
  /// Use for: Selected inputs, active elements
  static const Color active = Color(0xFF27B473);

  /// Disabled border (Gray)
  /// Use for: Disabled inputs, inactive elements
  static const Color disabled = Color(0xFFDDDDDD);
}

// ========================================
// 🔘 Component Colors (컴포넌트 색상)
// ========================================

/// Button-specific colors
class ButtonColors {
  ButtonColors._();

  // Primary Button
  static const Color primaryBg = BrandColors.primary;
  static const Color primaryText = TextColors.inverse;

  // Secondary Button
  static const Color secondaryBg = BackgroundColors.surface;
  static const Color secondaryText = TextColors.secondary;

  // Disabled Button
  static const Color disabledBg = BackgroundColors.muted;
  static const Color disabledText = TextColors.disabled;
}

/// Input field colors
class InputColors {
  InputColors._();

  static const Color bg = Color(0xFFFFFFFF);
  static const Color text = TextColors.primary;
  static const Color placeholder = TextColors.secondary;
  static const Color border = BorderColors.subtle;
  static const Color borderActive = BorderColors.active;
  static const Color borderDisabled = BorderColors.disabled;
  static const Color disabledBg = BackgroundColors.muted;
}

/// Chip/tag colors
class ChipColors {
  ChipColors._();

  // Default state
  static const Color defaultBg = BackgroundColors.surface;
  static const Color defaultText = TextColors.secondary;
  static const Color defaultBorder = BorderColors.subtle;

  // Disabled state
  static const Color disabledBg = BackgroundColors.muted;
  static const Color disabledText = TextColors.disabled;
  static const Color disabledBorder = BorderColors.disabled;

  // Active/selected state
  static const Color activeBg = BackgroundColors.surface;
  static const Color activeText = TextColors.active;
  static const Color activeBorder = BorderColors.active;
}

/// Tab navigation colors
class TabColors {
  TabColors._();

  // Default state
  static const Color defaultText = TextColors.secondary;
  static const Color defaultBg = SurfaceColors.base;
  static const Color defaultBorder = BorderColors.subtle;

  // Active state
  static const Color activeText = TextColors.active;
  static const Color activeBg = SurfaceColors.base;
  static const Color activeBorder = BorderColors.active;

  // Disabled state
  static const Color disabledText = TextColors.disabled;
  static const Color disabledBg = BackgroundColors.muted;
  static const Color disabledBorder = BorderColors.disabled;
}
