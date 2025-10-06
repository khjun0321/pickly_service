/// Pickly Design System - Design Tokens
/// 피그마 Variables에서 추출한 정확한 토큰입니다.
library design_tokens;

import 'package:flutter/material.dart';

// ========================================
// 🎨 Brand Colors (브랜드 색상)
// ========================================
class BrandColors {
  BrandColors._();

  static const Color primary = Color(0xFF27B473); // 녹색 (메인 브랜드 컬러)
  static const Color secondary = Color(0xFF327DFF); // 파란색
  static const Color banner = Color(0xFF327DFF); // 배너 색상
  static const Color splashBg = Color(0xFF27B473); // 스플래시 배경
}

// ========================================
// 🖼️ Background Colors (배경 색상)
// ========================================
class BackgroundColors {
  BackgroundColors._();

  static const Color app = Color(0xFFF4F4F4); // 앱 기본 배경
  static const Color muted = Color(0xFFDDDDDD); // 비활성 배경
  static const Color inverse = Color(0xFFFFFFFF); // 반전 배경
  static const Color surface = Color(0xFFFFFFFF); // 표면 배경
}

// ========================================
// 📄 Surface Colors (표면 색상)
// ========================================
class SurfaceColors {
  SurfaceColors._();

  static const Color base = Color(0xFFFFFFFF); // 기본 표면
  static const Color elevated = Color(0xFFFFFFFF); // 상승된 표면
  static const Color highlight = Color(0xFFFFFFFF); // 강조 표면
}

// ========================================
// ✍️ Text Colors (텍스트 색상)
// ========================================
class TextColors {
  TextColors._();

  static const Color primary = Color(0xFF3E3E3E); // 기본 텍스트
  static const Color secondary = Color(0xFF828282); // 보조 텍스트
  static const Color tertiary = Color(0xFFBABABA); // 3차 텍스트
  static const Color muted = Color(0xFFB0B0B0); // 비활성 텍스트
  static const Color disabled = Color(0xFFFFFFFF); // 비활성 상태 텍스트
  static const Color inverse = Color(0xFFFFFFFF); // 반전 텍스트
  static const Color active = Color(0xFF27B473); // 활성 텍스트
}

// ========================================
// 🎯 State Colors (상태 색상)
// ========================================
class StateColors {
  StateColors._();

  static const Color error = Color(0xFFFF4257); // 에러
  static const Color warning = Color(0xFFFF4257); // 경고
  static const Color success = Color(0xFFFFFFFF); // 성공
  static const Color info = Color(0xFFFFFFFF); // 정보
  static const Color active = Color(0xFF27B473); // 활성
}

// ========================================
// 🔲 Border Colors (테두리 색상)
// ========================================
class BorderColors {
  BorderColors._();

  static const Color subtle = Color(0xFFEBEBEB); // 미묘한 테두리
  static const Color divider = Color(0xFFEBEBEB); // 구분선
  static const Color strong = Color(0xFF3E3E3E); // 강한 테두리
  static const Color active = Color(0xFF27B473); // 활성 테두리
  static const Color disabled = Color(0xFFDDDDDD); // 비활성 테두리
}

// ========================================
// 🔘 Component Colors (컴포넌트 색상)
// ========================================
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

class ChipColors {
  ChipColors._();

  // Default
  static const Color defaultBg = BackgroundColors.surface;
  static const Color defaultText = TextColors.secondary;
  static const Color defaultBorder = BorderColors.subtle;

  // Disabled
  static const Color disabledBg = BackgroundColors.muted;
  static const Color disabledText = TextColors.disabled;
  static const Color disabledBorder = BorderColors.disabled;

  // Active
  static const Color activeBg = BackgroundColors.surface;
  static const Color activeText = TextColors.active;
  static const Color activeBorder = BorderColors.active;
}

class TabColors {
  TabColors._();

  // Default
  static const Color defaultText = TextColors.secondary;
  static const Color defaultBg = SurfaceColors.base;
  static const Color defaultBorder = BorderColors.subtle;

  // Active
  static const Color activeText = TextColors.active;
  static const Color activeBg = SurfaceColors.base;
  static const Color activeBorder = BorderColors.active;

  // Disabled
  static const Color disabledText = TextColors.disabled;
  static const Color disabledBg = BackgroundColors.muted;
  static const Color disabledBorder = BorderColors.disabled;
}

// ========================================
// 📝 Typography (타이포그래피)
// ========================================
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

  // Text Styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: size22,
    fontWeight: bold,
    height: lineHeight32 / size22,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: size18,
    fontWeight: bold,
    height: lineHeight24 / size18,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: size15,
    fontWeight: semibold,
    height: lineHeight24 / size15,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: size14,
    fontWeight: semibold,
    height: lineHeight20 / size14,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: size16,
    fontWeight: semibold,
    height: lineHeight24 / size16,
  );

  static const TextStyle captionLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: size16,
    fontWeight: semibold,
    height: lineHeight24 / size16,
  );

  static const TextStyle captionSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: size12,
    fontWeight: semibold,
    height: lineHeight18 / size12,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: size16,
    fontWeight: bold,
    height: lineHeight24 / size16,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: size14,
    fontWeight: bold,
    height: lineHeight20 / size14,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: size12,
    fontWeight: semibold,
    height: lineHeight18 / size12,
  );
}

// ========================================
// 📏 Spacing (간격)
// ========================================
class Spacing {
  Spacing._();

  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double massive = 48.0;
}

// ========================================
// 🔲 Border Radius (모서리)
// ========================================
class PicklyBorderRadius {
  PicklyBorderRadius._();

  static const double none = 0.0;
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 13.5;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double full = 9999.0;

  // BorderRadius 객체
  static const BorderRadius radiusNone = BorderRadius.zero;
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(full));
}

// ========================================
// 🎭 Shadows (그림자)
// ========================================
class PicklyShadows {
  PicklyShadows._();

  static const List<BoxShadow> none = [];

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000), // rgba(0, 0, 0, 0.1)
      offset: Offset(0, 4),
      blurRadius: 6,
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14000000), // rgba(0, 0, 0, 0.08)
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];
}

// ========================================
// ⏱️ Animations (애니메이션)
// ========================================
class PicklyAnimations {
  PicklyAnimations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);

  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
}

// ========================================
// 📱 Layout (레이아웃)
// ========================================
class PicklyLayout {
  PicklyLayout._();

  static const double maxWidth = 1200.0;
  static const double containerPadding = 16.0;
  static const double headerHeight = 60.0;
  static const double navigationHeight = 72.0;
}

// ========================================
// 📦 편의 클래스 - 모든 토큰 통합
// ========================================
class PicklyTokens {
  PicklyTokens._();

  // Colors
  static final brand = BrandColors;
  static final background = BackgroundColors;
  static final surface = SurfaceColors;
  static final text = TextColors;
  static final state = StateColors;
  static final border = BorderColors;
  static final button = ButtonColors;
  static final input = InputColors;
  static final chip = ChipColors;
  static final tab = TabColors;

  // Typography
  static final typography = PicklyTypography;

  // Spacing
  static final spacing = Spacing;

  // Border Radius
  static final borderRadius = PicklyBorderRadius;

  // Shadows
  static final shadows = PicklyShadows;

  // Animations
  static final animations = PicklyAnimations;

  // Layout
  static final layout = PicklyLayout;
}
