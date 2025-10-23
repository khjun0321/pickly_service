import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Policy list card widget for displaying policy announcements
///
/// Displays a horizontal card with:
/// - Thumbnail image (72x72)
/// - Policy title with status chip
/// - Organization name
/// - Posted date
///
/// Example:
/// ```dart
/// PolicyListCard(
///   imageUrl: 'https://example.com/image.png',
///   title: '화성동탄2 A93 동탄호수공...',
///   organization: '장기전세주택(GH)',
///   postedDate: '2025/04/12',
///   status: RecruitmentStatus.recruiting,
///   onTap: () {
///     // Navigate to policy detail
///   },
/// )
/// ```
class PolicyListCard extends StatelessWidget {
  /// Image URL for the policy thumbnail
  /// Can be a network URL or asset path
  final String imageUrl;

  /// Policy title (will be truncated with ellipsis if too long)
  final String title;

  /// Organization or policy type name
  final String organization;

  /// Posted date in format '2025/04/12'
  final String postedDate;

  /// Recruitment status (recruiting or closed)
  final RecruitmentStatus status;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  const PolicyListCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.organization,
    required this.postedDate,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 343,
        height: 72,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail image
            Container(
              width: 72,
              height: 72,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.50),
                ),
              ),
              child: _buildImage(),
            ),
            const SizedBox(width: 12),

            // Policy information
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with status chip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: PicklyTypography.bodyMedium.copyWith(
                            color: TextColors.primary,
                            fontWeight: FontWeight.w700,
                            height: 1.20, // Keep original height to fit in 72px container
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      StatusChip(status: status),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Organization name
                  Text(
                    organization,
                    style: PicklyTypography.bodySmall.copyWith(
                      color: TextColors.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Posted date
                  Text(
                    '작성일: $postedDate',
                    style: PicklyTypography.captionSmall.copyWith(
                      color: TextColors.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build image widget based on URL type
  Widget _buildImage() {
    // Check if it's an asset path
    final isAsset = imageUrl.startsWith('assets/');

    if (isAsset) {
      return Image.asset(
        imageUrl,
        package: 'pickly_design_system',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
      );
    }
  }

  /// Build placeholder when image fails to load
  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 32,
          color: Color(0xFFDDDDDD),
        ),
      ),
    );
  }
}
