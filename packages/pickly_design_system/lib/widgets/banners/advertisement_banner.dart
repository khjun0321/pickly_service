/// AdvertisementBanner Component
///
/// A banner component for displaying advertisements with image background,
/// text content, and an optional badge indicator.
///
/// Specifications:
/// - Height: 80px
/// - Background: Dark green (#074D43) with background image
/// - Title: White, 16px font, 700 weight
/// - Subtitle: White, 14px font, 600 weight
/// - Badge: Position at bottom-right with indicator
///
/// Usage:
/// ```dart
/// AdvertisementBanner(
///   title: '당첨 후기 작성하고\n선물 받자',
///   subtitle: '경험을 함께 나누어 주세요.',
///   imageUrl: 'https://example.com/image.png',
///   currentIndex: 1,
///   totalCount: 8,
///   onTap: () => print('Banner tapped'),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import '../../tokens/design_tokens.dart';
import '../badges/indicator_badge.dart';

/// Advertisement banner component with image background
class AdvertisementBanner extends StatelessWidget {
  /// The main title text
  final String title;

  /// The subtitle text
  final String subtitle;

  /// Background image URL (optional)
  final String? imageUrl;

  /// Current index for the badge indicator (optional)
  final int? currentIndex;

  /// Total count for the badge indicator (optional)
  final int? totalCount;

  /// Callback when the banner is tapped
  final VoidCallback? onTap;

  /// Background color (defaults to dark green #074D43)
  final Color? backgroundColor;

  const AdvertisementBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.currentIndex,
    this.totalCount,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final showBadge = currentIndex != null && totalCount != null;
    final bgColor = backgroundColor ?? const Color(0xFF074D43);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 80,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
        child: Stack(
          children: [
            // Background image (if provided)
            if (imageUrl != null)
              Positioned(
                right: -15,
                top: -15,
                child: Transform.rotate(
                  angle: 0.36,
                  child: Container(
                    width: 83.59,
                    height: 83.59,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

            // Text content
            Positioned(
              left: 32,
              top: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: PicklyTypography.bodyLarge.copyWith(
                      color: Colors.white, // text-inverse
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: PicklyTypography.bodyMedium.copyWith(
                      color: Colors.white, // text-inverse
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ),

            // Badge indicator
            if (showBadge)
              Positioned(
                right: 11,
                bottom: 14,
                child: IndicatorBadge(
                  current: currentIndex!,
                  total: totalCount!,
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}
