import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Custom scrollbar matching Figma design
///
/// Features:
/// - Width: 4px
/// - Color: #BABABA (TextColors.tertiary)
/// - Border radius: 4px
/// - Auto-hide when not scrolling
class PicklyScrollbar extends StatelessWidget {
  const PicklyScrollbar({
    super.key,
    required this.child,
    this.controller,
    this.thumbVisibility = false,
    this.thickness = 4.0,
    this.radius = const Radius.circular(4),
  });

  final Widget child;
  final ScrollController? controller;
  final bool thumbVisibility;
  final double thickness;
  final Radius radius;

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      controller: controller,
      thumbVisibility: thumbVisibility,
      thickness: thickness,
      radius: radius,
      thumbColor: TextColors.tertiary,
      child: child,
    );
  }
}
