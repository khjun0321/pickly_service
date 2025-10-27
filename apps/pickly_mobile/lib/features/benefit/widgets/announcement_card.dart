import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

import '../../../contexts/benefit/models/announcement.dart';

/// 공고 카드 위젯
/// 혜택 공고 목록에서 사용되는 카드 UI
/// - 썸네일 이미지
/// - 상태 배지 (모집중/마감)
/// - D-day 표시
/// - 기관명, 제목, 요약
class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback? onTap;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SurfaceColors.base,
        border: Border.all(
          color: BorderColors.subtle,
          width: 1,
        ),
        borderRadius: PicklyBorderRadius.radiusXl,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: PicklyBorderRadius.radiusXl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 이미지 섹션
            if (announcement.thumbnailUrl != null)
              Stack(
                children: [
                  // 썸네일 이미지
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: announcement.thumbnailUrl!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 160,
                        color: BackgroundColors.muted,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 160,
                        color: BackgroundColors.muted,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: TextColors.tertiary,
                        ),
                      ),
                    ),
                  ),

                  // 상태 배지 (좌상단)
                  Positioned(
                    top: Spacing.md,
                    left: Spacing.md,
                    child: _StatusBadge(status: announcement.status),
                  ),

                  // D-day 배지 제거 (applicationPeriodEnd 필드 제거됨)
                ],
              ),

            // 컨텐츠 섹션
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 기관명
                  if (announcement.organization != null) ...[
                    Text(
                      announcement.organization!,
                      style: PicklyTypography.captionMidium.copyWith(
                        color: TextColors.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],

                  // 제목
                  Text(
                    announcement.title,
                    style: PicklyTypography.titleSmall.copyWith(
                      color: TextColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // 부제목
                  if (announcement.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      announcement.subtitle!,
                      style: PicklyTypography.bodyMedium.copyWith(
                        color: TextColors.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: Spacing.md),

                  // 하단 정보: 조회수
                  Row(
                    children: [
                      const Spacer(),
                      // 조회수
                      Icon(
                        Icons.visibility,
                        size: 14,
                        color: TextColors.tertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${announcement.viewsCount}',
                        style: PicklyTypography.captionSmall.copyWith(
                          color: TextColors.tertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 상태 배지 위젯
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case 'recruiting':
        backgroundColor = const Color(0xFFC6ECFF);
        textColor = const Color(0xFF5090FF);
        label = '모집중';
        break;
      case 'closed':
        backgroundColor = const Color(0xFFE0E0E0);
        textColor = const Color(0xFF757575);
        label = '마감';
        break;
      case 'upcoming':
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF2196F3);
        label = '예정';
        break;
      default:
        backgroundColor = const Color(0xFFE0E0E0);
        textColor = const Color(0xFF757575);
        label = '알 수 없음';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: PicklyTypography.captionSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 공고 카드 스켈레톤 (로딩 상태)
class AnnouncementCardSkeleton extends StatelessWidget {
  const AnnouncementCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
