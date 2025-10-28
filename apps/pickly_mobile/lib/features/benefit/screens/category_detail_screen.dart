import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

import '../../../core/router.dart';
import '../../benefits/providers/category_banner_provider.dart';
import '../providers/announcement_provider.dart';
import '../widgets/announcement_card.dart';
import '../widgets/category_banner.dart';

/// 카테고리 상세 화면
///
/// 특정 카테고리의 배너와 공고 목록을 보여주는 화면입니다.
/// - 실시간 스트림을 통해 공고 목록 업데이트
/// - 카테고리별 배너 표시 (활성화된 경우)
/// - sort_order 기준 정렬
class CategoryDetailScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 공고 목록을 실시간 스트림으로 구독
    final announcementsAsync = ref.watch(announcementsStreamProvider(categoryId));

    // 카테고리별 배너 가져오기
    final banners = ref.watch(bannersByCategoryProvider(categoryId));
    final hasBanners = banners.isNotEmpty;

    return Scaffold(
      backgroundColor: BackgroundColors.app,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            AppHeader.portal(
              title: _getCategoryName(categoryId),
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(Routes.benefits);
                }
              },
            ),

            // Content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: SizedBox(height: Spacing.xl),
                  ),

                  // 배너 섹션 (활성화된 경우)
                  if (hasBanners)
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          CategoryBannerWidget(banners: banners),
                          const SizedBox(height: Spacing.xl),
                        ],
                      ),
                    ),

                  // 공고 목록
                  announcementsAsync.when(
                    data: (announcements) {
                      if (announcements.isEmpty) {
                        return const SliverFillRemaining(
                          child: _EmptyAnnouncementsView(),
                        );
                      }

                      // sort_order와 createdAt 기준 정렬
                      final sortedAnnouncements = [...announcements]
                        ..sort((a, b) {
                          // sort_order로 먼저 정렬 (내림차순)
                          final priorityCompare =
                              b.sortOrder.compareTo(a.sortOrder);
                          if (priorityCompare != 0) return priorityCompare;

                          // 우선순위가 같으면 createdAt으로 정렬 (최신순)
                          if (a.createdAt == null && b.createdAt == null) return 0;
                          if (a.createdAt == null) return 1;
                          if (b.createdAt == null) return -1;
                          return b.createdAt!.compareTo(a.createdAt!);
                        });

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.lg,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final announcement = sortedAnnouncements[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: Spacing.md,
                                ),
                                child: AnnouncementCard(
                                  announcement: announcement,
                                  onTap: () {
                                    context.go(
                                      Routes.announcementDetail(announcement.id),
                                    );
                                  },
                                ),
                              );
                            },
                            childCount: sortedAnnouncements.length,
                          ),
                        ),
                      );
                    },
                    loading: () => const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stackTrace) => SliverFillRemaining(
                      child: _ErrorView(
                        error: error,
                        onRetry: () {
                          ref.invalidate(announcementsStreamProvider(categoryId));
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: Spacing.xxl),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 카테고리 ID로 카테고리 이름 가져오기
  String _getCategoryName(String categoryId) {
    // TODO: 실제 카테고리 데이터에서 가져오기
    const categoryNames = {
      'popular': '인기',
      'housing': '주거',
      'education': '교육',
      'support': '지원',
      'transportation': '교통',
      'welfare': '복지',
    };
    return categoryNames[categoryId] ?? '카테고리';
  }
}

/// 공고가 없을 때 표시하는 뷰
class _EmptyAnnouncementsView extends StatelessWidget {
  const _EmptyAnnouncementsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: TextColors.tertiary,
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            '아직 등록된 공고가 없어요',
            style: PicklyTypography.bodyLarge.copyWith(
              color: TextColors.secondary,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            '새로운 공고가 등록되면 알려드릴게요',
            style: PicklyTypography.bodyMedium.copyWith(
              color: TextColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 에러 발생 시 표시하는 뷰
class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              '공고를 불러오는 중 오류가 발생했어요',
              style: PicklyTypography.bodyLarge.copyWith(
                color: TextColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              error.toString(),
              style: PicklyTypography.bodySmall.copyWith(
                color: TextColors.tertiary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Spacing.xl),
            SizedBox(
              width: 160,
              child: PicklyButton.primary(
                onPressed: onRetry,
                text: '다시 시도',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
