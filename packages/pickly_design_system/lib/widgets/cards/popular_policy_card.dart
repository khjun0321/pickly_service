/// PopularPolicyCard Component
///
/// A card component for displaying popular policy announcements.
/// Features a large image area and a prominent "구경하기" (View) button.
///
/// Specifications:
/// - Size: 343x342
/// - White background with subtle border
/// - Rounded corners (24px)
/// - Primary green button at bottom
///
/// Usage:
/// ```dart
/// PopularPolicyCard(
///   imageWidget: Image.asset('path/to/image'),
///   onTap: () => print('View policy'),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Card component for displaying popular policy announcements
class PopularPolicyCard extends StatelessWidget {
  /// The image or widget to display in the card
  final Widget imageWidget;

  /// Callback when the "구경하기" button is tapped
  final VoidCallback? onTap;

  const PopularPolicyCard({
    super.key,
    required this.imageWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 343,
      height: 342,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFEBEBEB),
          ),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // Image area (same size as container)
          Positioned(
            left: 0,
            top: 0,
            child: SizedBox(
              width: 343,
              height: 342,
              child: imageWidget,
            ),
          ),

          // "구경하기" button at bottom
          Positioned(
            left: 16,
            top: 278,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 311,
                padding: const EdgeInsets.symmetric(
                  horizontal: 80,
                  vertical: 12,
                ),
                decoration: ShapeDecoration(
                  color: BrandColors.primary, // #27B473
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '구경하기',
                      style: PicklyTypography.bodyLarge.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.50,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
