import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/announcement_provider.dart';
import '../widgets/announcement_card.dart';
import 'announcement_detail_screen.dart';

/// 공고 목록 화면
/// 특정 카테고리의 혜택 공고 목록을 표시
class AnnouncementListScreen extends ConsumerWidget {
  final String categoryId;
  final String categoryName;

  const AnnouncementListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(
      announcementsByCategoryProvider(categoryId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('$categoryName 혜택'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 검색 화면으로 이동
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // 새로고침
          ref.invalidate(announcementsByCategoryProvider(categoryId));
        },
        child: announcementsAsync.when(
          data: (announcements) {
            if (announcements.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '등록된 공고가 없습니다',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return AnnouncementCard(
                  announcement: announcement,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnnouncementDetailScreen(
                          announcementId: announcement.id,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
          loading: () => ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const AnnouncementCardSkeleton(),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  '오류가 발생했습니다',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(announcementsByCategoryProvider(categoryId));
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
