import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 카테고리 아이콘 위젯
///
/// 하이브리드 아이콘 시스템:
/// 1. iconUrl이 있으면 → 네트워크에서 로드 (우선순위)
/// 2. iconUrl이 없으면 → 로컬 iconComponent 사용
/// 3. 둘 다 실패하면 → Fallback 아이콘 (Icons.help_outline)
///
/// ⚠️ 중요: 크기는 사용하는 위젯에서 정의!
/// 기존 SelectionListItem, SelectionChip 등의 크기 그대로 사용
class CategoryIcon extends StatelessWidget {
  /// 네트워크 아이콘 URL (Supabase Storage)
  final String? iconUrl;

  /// 로컬 에셋 아이콘 키 (예: "youth", "newlywed")
  final String iconComponent;

  /// 아이콘 크기 (외부에서 필수로 받음)
  final double size;

  /// 아이콘 색상 (선택)
  final Color? color;

  const CategoryIcon({
    super.key,
    this.iconUrl,
    required this.iconComponent,
    required this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // 1순위: 네트워크 아이콘 (iconUrl)
    if (iconUrl != null && iconUrl!.isNotEmpty) {
      return _buildNetworkIcon();
    }

    // 2순위: 로컬 아이콘 (iconComponent)
    return _buildLocalIcon();
  }

  /// 네트워크 아이콘 빌드 (캐싱 포함)
  Widget _buildNetworkIcon() {
    // SVG인지 확인
    final isSvg = iconUrl!.toLowerCase().endsWith('.svg');

    if (isSvg) {
      return SvgPicture.network(
        iconUrl!,
        width: size,
        height: size,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        placeholderBuilder: (context) => _buildLoadingPlaceholder(),
        // 에러 시 로컬 아이콘으로 Fallback
        // ignore: deprecated_member_use
        fit: BoxFit.contain,
      );
    }

    // PNG/JPG
    return CachedNetworkImage(
      imageUrl: iconUrl!,
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
      placeholder: (context, url) => _buildLoadingPlaceholder(),
      errorWidget: (context, url, error) => _buildLocalIcon(),
    );
  }

  /// 로컬 아이콘 빌드
  Widget _buildLocalIcon() {
    final iconPath = _getLocalIconPath(iconComponent);

    if (iconPath == null) {
      return _buildFallbackIcon();
    }

    // SVG인지 확인
    final isSvg = iconPath.toLowerCase().endsWith('.svg');

    if (isSvg) {
      return SvgPicture.asset(
        iconPath,
        width: size,
        height: size,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        placeholderBuilder: (context) => _buildFallbackIcon(),
      );
    }

    // PNG
    return Image.asset(
      iconPath,
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
    );
  }

  /// 로딩 중 플레이스홀더
  Widget _buildLoadingPlaceholder() {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: SizedBox(
          width: size * 0.5,
          height: size * 0.5,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  /// Fallback 아이콘 (모든 것이 실패했을 때)
  Widget _buildFallbackIcon() {
    return Icon(
      Icons.help_outline,
      size: size,
      color: color ?? Colors.grey,
    );
  }

  /// 로컬 아이콘 경로 매핑
  ///
  /// iconComponent 값에 따라 로컬 에셋 경로를 반환
  /// packages/pickly_design_system/assets/icons/ 경로 사용
  String? _getLocalIconPath(String component) {
    const basePath = 'packages/pickly_design_system/assets/icons';

    // 연령 카테고리 아이콘 매핑
    final iconMap = {
      'youth': '$basePath/category_youth.svg',
      'newlywed': '$basePath/category_newlywed.svg',
      'parenting': '$basePath/category_parenting.svg',
      'multi_child': '$basePath/category_multi_child.svg',
      'senior': '$basePath/category_senior.svg',
      'disabled': '$basePath/category_disabled.svg',

      // 혜택 카테고리 아이콘 (기존)
      'popular': '$basePath/benefit_popular.svg',
      'housing': '$basePath/benefit_housing.svg',
      'education': '$basePath/benefit_education.svg',
      'health': '$basePath/benefit_health.svg',
      'transportation': '$basePath/benefit_transportation.svg',
      'welfare': '$basePath/benefit_welfare.svg',
      'employment': '$basePath/benefit_employment.svg',
      'support': '$basePath/benefit_support.svg',
      'culture': '$basePath/benefit_culture.svg',
    };

    return iconMap[component];
  }
}
