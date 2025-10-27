/// ImageBanner Component
///
/// A simple image-only banner component for displaying full-width promotional images.
/// Designed for category-specific advertisements that use uploaded images.
///
/// Specifications:
/// - Full-width image with 16px horizontal padding
/// - Border radius: 16px
/// - Height: 160px (adjustable)
/// - Badge indicator showing current position (e.g., "1/3")
/// - Supports horizontal scrolling with PageView
///
/// Usage:
/// ```dart
/// ImageBanner(
///   imageUrl: 'https://cdn.example.com/banner1.png',
///   currentIndex: 1,
///   totalCount: 3,
///   onTap: () => Navigator.push(...),
/// )
/// ```
library;

import 'package:flutter/material.dart';

/// Simple image banner with badge indicator
class ImageBanner extends StatelessWidget {
  /// Image URL to display
  final String imageUrl;

  /// Current banner index (1-based)
  final int currentIndex;

  /// Total number of banners
  final int totalCount;

  /// Banner height (default: 160px)
  final double height;

  /// Callback when banner is tapped
  final VoidCallback? onTap;

  const ImageBanner({
    super.key,
    required this.imageUrl,
    required this.currentIndex,
    required this.totalCount,
    this.height = 160,
    this.onTap,
  });

  /// Build image widget based on URL type (network or asset)
  Widget _buildImage() {
    final isAsset = imageUrl.startsWith('assets/');

    if (isAsset) {
      // Use asset image
      return Image.asset(
        imageUrl,
        package: 'pickly_design_system',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFF5F5F5),
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: Color(0xFFDDDDDD),
              ),
            ),
          );
        },
      );
    } else {
      // Use network image
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFF5F5F5),
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: Color(0xFFDDDDDD),
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFFF5F5F5),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full-width image (supports both network and asset images)
              _buildImage(),

              // Badge indicator (bottom-right)
              if (totalCount > 1)
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x66242424), // Semi-transparent black
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '$currentIndex/$totalCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
