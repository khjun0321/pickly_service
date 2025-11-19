import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pickly_mobile/core/router.dart';
import '../providers/announcement_provider.dart';
import '../../../contexts/benefit/models/announcement_tab.dart';
import '../../../contexts/benefit/models/announcement_section.dart';

/// 공고 상세 화면
/// SafeArea + Column 레이아웃 구조로 온보딩 화면과 동일한 스타일 적용
/// 소득 기준 섹션은 IncomeSectionWidget을 사용하여 특별한 UI로 표시
/// TabBar를 통한 평형별/연령별 정보 표시
class AnnouncementDetailScreen extends ConsumerStatefulWidget {
  final String announcementId;

  const AnnouncementDetailScreen({
    super.key,
    required this.announcementId,
  });

  @override
  ConsumerState<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends ConsumerState<AnnouncementDetailScreen> {
  bool isBookmarked = false;
  int selectedTabIndex = 0;

  void _onShare() {
    // TODO: 공유 기능 구현
    debugPrint('Share announcement: ${widget.announcementId}');
  }

  void _onBookmark() {
    setState(() {
      isBookmarked = !isBookmarked;
    });
    // TODO: 북마크 API 호출
    debugPrint('🔖 Bookmark toggled: $isBookmarked');
  }

  @override
  Widget build(BuildContext context) {
    // Fetch announcement data
    final announcementAsync = ref.watch(announcementDetailProvider(widget.announcementId));
    final tabsAsync = ref.watch(announcementTabsProvider(widget.announcementId));
    final sectionsAsync = ref.watch(announcementSectionsProvider(widget.announcementId));

    return Scaffold(
      backgroundColor: BackgroundColors.app, // #F4F4F4
      body: SafeArea(
        child: announcementAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
          data: (announcement) {
            return Column(
              children: [
                // Header - Portal type with bookmark and share
                AppHeader.portal(
                  title: announcement.title,
                  onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(Routes.benefits);
                    }
                  },
                  onBookmark: _onBookmark,
                  onShare: _onShare,
                  isBookmarked: isBookmarked,
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: Spacing.xl),
                        // 마감 알림 배너
                        _DeadlineBanner(
                          daysLeft: 3,
                          status: announcement.statusDisplay,
                        ),
                        const SizedBox(height: Spacing.lg),

                        // Dynamic sections
                        sectionsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => const SizedBox.shrink(),
                          data: (sections) {
                            return Column(
                              children: sections.map((section) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: Spacing.md),
                                  child: _buildSectionFromData(section),
                                );
                              }).toList(),
                            );
                          },
                        ),

                        // TabBar for unit types (평형별 정보)
                        tabsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => const SizedBox.shrink(),
                          data: (tabs) {
                            if (tabs.isEmpty) return const SizedBox.shrink();

                            return Column(
                              children: [
                                const SizedBox(height: Spacing.md),
                                _UnitTypeTabBar(
                                  tabs: tabs,
                                  selectedIndex: selectedTabIndex,
                                  onTabSelected: (index) {
                                    setState(() {
                                      selectedTabIndex = index;
                                    });
                                  },
                                ),
                                const SizedBox(height: Spacing.md),
                                _UnitTypeContent(tab: tabs[selectedTabIndex]),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: Spacing.xl),
                      ],
                    ),
                  ),
                ),

                // Bottom button - matches onboarding style
                Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: PicklyButton.primary(
                      onPressed: () async {
                        final url = announcement.externalUrl ?? 'https://www.lh.or.kr';
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      text: '공고문 보러가기',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionFromData(AnnouncementSection section) {
    // Parse content based on section type
    final content = section.content;
    final children = <Widget>[];

    // Handle different content structures
    if (content['items'] is List) {
      for (final item in content['items']) {
        if (item is Map) {
          children.add(_InfoItem(
            icon: item['icon']?.toString() ?? '',
            label: item['label']?.toString() ?? '',
            value: item['value']?.toString() ?? '',
          ));
        }
      }
    } else if (content['text'] != null) {
      children.add(_InfoItem(
        icon: '',
        label: '',
        value: content['text'].toString(),
      ));
    } else {
      // Fallback: render key-value pairs
      content.forEach((key, value) {
        if (key != 'images' && key != 'pdfs') {
          children.add(_InfoItem(
            icon: '',
            label: key,
            value: value.toString(),
          ));
        }
      });
    }

    // Add images if present
    if (section.imageUrls.isNotEmpty) {
      children.add(
        _ImagesRow(imageUrls: section.imageUrls),
      );
    }

    return _SectionCard(
      title: section.title ?? section.sectionTypeDisplay,
      children: children.isNotEmpty ? children : [
        const _InfoItem(
          icon: '',
          label: '',
          value: '내용이 없습니다.',
        ),
      ],
    );
  }
}

/// 마감 알림 배너
class _DeadlineBanner extends StatelessWidget {
  final int daysLeft;
  final String status;

  const _DeadlineBanner({
    required this.daysLeft,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: PicklyBorderRadius.radiusXl,
      ),
      child: Row(
        children: [
          // 시계 아이콘
          SvgPicture.asset(
            'assets/icons/timer.svg',
            package: 'pickly_design_system',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: Spacing.md),
          // 텍스트
          Expanded(
            child: Text(
              '공고 마감까지 $daysLeft일 남았어요',
              style: PicklyTypography.bodyMedium.copyWith(
                color: TextColors.inverse,
                fontWeight: FontWeight.w700,
                height: 1.20,
              ),
            ),
          ),
          // 상태 뱃지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFC6ECFF),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              status,
              style: PicklyTypography.captionSmall.copyWith(
                color: const Color(0xFF5090FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 섹션 카드
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: SurfaceColors.base,
        border: Border.all(
          color: BorderColors.subtle,
          width: 1,
        ),
        borderRadius: PicklyBorderRadius.radiusXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: PicklyTypography.titleSmall.copyWith(
              color: TextColors.primary,
            ),
          ),
          const SizedBox(height: Spacing.xl),
          ...children,
        ],
      ),
    );
  }
}

/// 정보 항목
class _InfoItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘 (있는 경우)
          if (icon.isNotEmpty) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFF4ECE0),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: Spacing.md),
          ],
          // 레이블과 값
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: PicklyTypography.captionMidium.copyWith(
                    color: TextColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: PicklyTypography.bodyMedium.copyWith(
                    color: TextColors.primary,
                    height: 1.60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Images row widget for sections
class _ImagesRow extends StatelessWidget {
  final List<String> imageUrls;

  const _ImagesRow({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.lg),
      child: SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: imageUrls.length,
          separatorBuilder: (context, index) => const SizedBox(width: Spacing.md),
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: PicklyBorderRadius.radiusMd,
              child: Image.network(
                imageUrls[index],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: BackgroundColors.muted,
                      borderRadius: PicklyBorderRadius.radiusMd,
                    ),
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: TextColors.tertiary,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 상세 정보 행
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: PicklyTypography.captionMidium.copyWith(
              color: TextColors.secondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: PicklyTypography.bodyMedium.copyWith(
              color: TextColors.primary,
              height: 1.60,
            ),
          ),
        ],
      ),
    );
  }
}

/// TabBar for unit types
class _UnitTypeTabBar extends StatelessWidget {
  final List<AnnouncementTab> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const _UnitTypeTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final tab = tabs[index];
            final isSelected = index == selectedIndex;

            return Padding(
              padding: EdgeInsets.only(
                right: index < tabs.length - 1 ? Spacing.md : 0,
              ),
              child: GestureDetector(
                onTap: () => onTabSelected(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg,
                    vertical: Spacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2E2E2E) : SurfaceColors.base,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF2E2E2E) : BorderColors.subtle,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    tab.tabName,
                    style: PicklyTypography.bodyMedium.copyWith(
                      color: isSelected ? TextColors.inverse : TextColors.primary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Content for selected unit type tab
class _UnitTypeContent extends StatelessWidget {
  final AnnouncementTab tab;

  const _UnitTypeContent({
    required this.tab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: SurfaceColors.base,
        border: Border.all(
          color: BorderColors.subtle,
          width: 1,
        ),
        borderRadius: PicklyBorderRadius.radiusXl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unit type title
          Text(
            tab.unitType ?? tab.tabName,
            style: PicklyTypography.titleSmall.copyWith(
              color: TextColors.primary,
            ),
          ),
          const SizedBox(height: Spacing.lg),

          // Floor plan image
          if (tab.floorPlanImageUrl != null) ...[
            ClipRRect(
              borderRadius: PicklyBorderRadius.radiusMd,
              child: Image.network(
                tab.floorPlanImageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: BackgroundColors.muted,
                      borderRadius: PicklyBorderRadius.radiusMd,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: TextColors.tertiary,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: Spacing.xl),
          ],

          // Supply count
          if (tab.supplyCount != null)
            _DetailRow(
              label: '공급 호수',
              value: '${tab.supplyCount}호',
            ),

          // Income conditions
          if (tab.deposit != null || tab.monthlyRent != null) ...[
            _DetailRow(
              label: '임대 조건',
              value: '${tab.deposit != null ? '보증금: ${tab.deposit}' : ''}'
                  '${tab.monthlyRent != null ? '\n월세: ${tab.monthlyRent}' : ''}',
            ),
          ],

          // Eligible condition
          if (tab.eligibleCondition != null) ...[
            _DetailRow(
              label: '자격 조건',
              value: tab.eligibleCondition!,
            ),
          ],

          // Additional info
          if (tab.additionalInfo != null && tab.additionalInfo!.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            ...tab.additionalInfo!.entries.map((entry) {
              return _DetailRow(
                label: entry.key,
                value: entry.value.toString(),
              );
            }),
          ],
        ],
      ),
    );
  }
}
