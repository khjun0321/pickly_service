import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../benefits/models/category_banner.dart' as banner_model;

/// 카테고리 배너 위젯
///
/// 카테고리 상세 화면 상단에 표시되는 배너입니다.
/// - 이미지와 텍스트 오버레이
/// - 탭하면 외부 링크로 이동
/// - 여러 배너가 있을 경우 PageView로 표시
class CategoryBannerWidget extends StatefulWidget {
  final List<banner_model.CategoryBanner> banners;

  const CategoryBannerWidget({
    super.key,
    required this.banners,
  });

  @override
  State<CategoryBannerWidget> createState() => _CategoryBannerWidgetState();
}

class _CategoryBannerWidgetState extends State<CategoryBannerWidget> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final showIndicator = widget.banners.length > 1;

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: _BannerCard(
                  banner: widget.banners[index],
                ),
              );
            },
          ),
        ),

        // 페이지 인디케이터
        if (showIndicator) ...[
          const SizedBox(height: Spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color(0xFF2E2E2E)
                      : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 개별 배너 카드
class _BannerCard extends StatelessWidget {
  final banner_model.CategoryBanner banner;

  const _BannerCard({
    required this.banner,
  });

  Future<void> _handleTap() async {
    try {
      final uri = Uri.parse(banner.actionUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint('⚠️ Cannot launch URL: ${banner.actionUrl}');
      }
    } catch (e) {
      debugPrint('❌ Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        decoration: BoxDecoration(
          color: banner.getBackgroundColor(),
          borderRadius: PicklyBorderRadius.radiusXl,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: PicklyBorderRadius.radiusXl,
          child: Stack(
            children: [
              // 배경 이미지
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: banner.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: banner.getBackgroundColor(),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: banner.getBackgroundColor(),
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: TextColors.tertiary,
                    ),
                  ),
                ),
              ),

              // 그라데이션 오버레이 (텍스트 가독성 향상)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),

              // 텍스트 오버레이
              Positioned(
                left: Spacing.lg,
                right: Spacing.lg,
                bottom: Spacing.lg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      banner.title,
                      style: PicklyTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      banner.subtitle,
                      style: PicklyTypography.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 링크 아이콘
              Positioned(
                top: Spacing.md,
                right: Spacing.md,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: Color(0xFF2E2E2E),
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
