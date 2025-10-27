import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final dateFormat = DateFormat('yyyy.MM.dd');

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

                  // D-day 배지 (우상단)
                  if (announcement.applicationPeriodEnd != null &&
                      !announcement.hasDeadlinePassed)
                    Positioned(
                      top: Spacing.md,
                      right: Spacing.md,
                      child: _DDayBadge(
                        deadline: announcement.applicationPeriodEnd!,
                      ),
                    ),
                ],
              ),

            // 컨텐츠 섹션
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 기관명
                  if (announcement.agency != null ||
                      announcement.organization != null) ...[
                    Text(
                      announcement.agency ?? announcement.organization!,
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

                  // 요약
                  if (announcement.summary != null) ...[
                    const SizedBox(height: Spacing.sm),
                    Text(
                      announcement.summary!,
                      style: PicklyTypography.bodySmall.copyWith(
                        color: TextColors.tertiary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: Spacing.md),

                  // 하단 정보: 마감일
                  Row(
                    children: [
                      if (announcement.applicationPeriodEnd != null) ...[
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: TextColors.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '마감: ${dateFormat.format(announcement.applicationPeriodEnd!)}',
                          style: PicklyTypography.captionSmall.copyWith(
                            color: TextColors.tertiary,
                          ),
                        ),
                      ],
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
  final AnnouncementStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case AnnouncementStatus.recruiting:
        backgroundColor = const Color(0xFFC6ECFF);
        textColor = const Color(0xFF5090FF);
        break;
      case AnnouncementStatus.closed:
        backgroundColor = const Color(0xFFE0E0E0);
        textColor = const Color(0xFF757575);
        break;
      case AnnouncementStatus.upcoming:
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF2196F3);
        break;
      default:
        backgroundColor = const Color(0xFFE0E0E0);
        textColor = const Color(0xFF757575);
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
        status.label,
        style: PicklyTypography.captionSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// D-day 배지 위젯
class _DDayBadge extends StatelessWidget {
  final DateTime deadline;

  const _DDayBadge({required this.deadline});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;

    // D-day 텍스트 생성
    String dDayText;
    if (difference == 0) {
      dDayText = 'D-Day';
    } else if (difference > 0) {
      dDayText = 'D-$difference';
    } else {
      return const SizedBox.shrink(); // 마감된 경우 표시 안함
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        dDayText,
        style: PicklyTypography.captionSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
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
