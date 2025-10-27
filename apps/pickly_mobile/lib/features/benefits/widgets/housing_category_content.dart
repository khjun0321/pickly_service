import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/core/router.dart';
import 'package:pickly_mobile/contexts/benefit/models/announcement.dart';
import '../providers/benefit_announcement_provider.dart';

/// Housing category content (주거 카테고리 컨텐츠)
///
/// Displays housing-related policies and benefits with filter tabs
/// Navigates to announcement detail when policy card is tapped
class HousingCategoryContent extends ConsumerStatefulWidget {
  final String categoryId;

  const HousingCategoryContent({
    super.key,
    required this.categoryId,
  });

  @override
  ConsumerState<HousingCategoryContent> createState() => _HousingCategoryContentState();
}

class _HousingCategoryContentState extends ConsumerState<HousingCategoryContent> {
  int _filterIndex = 0; // 0: 등록순, 1: 모집중, 2: 마감

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(announcementsByCategoryProvider(widget.categoryId));

    return Column(
      children: [
        // Filter tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            children: [
              FilterTabBar(
                tabs: const ['등록순', '모집중', '마감'],
                selectedIndex: _filterIndex,
                onTabSelected: (index) {
                  setState(() {
                    _filterIndex = index;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Announcement list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: announcementsAsync.when(
            data: (announcements) {
              final filteredAnnouncements = _getFilteredAnnouncements(announcements);

              if (filteredAnnouncements.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      '공고가 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredAnnouncements.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final announcement = filteredAnnouncements[index];
                  return PolicyListCard(
                    imageUrl: announcement.thumbnailUrl ?? '',
                    title: announcement.title,
                    organization: announcement.organization ?? '',
                    postedDate: announcement.formattedAnnouncementDate,
                    status: announcement.isRecruiting
                        ? RecruitmentStatus.recruiting
                        : RecruitmentStatus.closed,
                    onTap: () {
                      // Navigate to announcement detail screen
                      context.go(Routes.announcementDetail(announcement.id));
                    },
                  );
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '공고를 불러오는데 실패했습니다',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Get filtered announcements based on selected tab
  List<Announcement> _getFilteredAnnouncements(List<Announcement> announcements) {
    switch (_filterIndex) {
      case 0: // 등록순 (all announcements, sorted by announcement date)
        return announcements;
      case 1: // 모집중 (recruiting only)
        return announcements.where((a) => a.isRecruiting).toList();
      case 2: // 마감 (closed only)
        return announcements.where((a) => a.isClosed).toList();
      default:
        return announcements;
    }
  }
}
