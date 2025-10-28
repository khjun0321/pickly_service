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
      // 로컬 에셋 경로인지 확인 (packages/ 또는 assets/로 시작)
      if (iconUrl!.startsWith('packages/') || iconUrl!.startsWith('assets/')) {
        return _buildLocalIconFromUrl(iconUrl!);
      }
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

  /// iconUrl에 로컬 에셋 경로가 있을 때 사용
  /// (DB에 실수로 로컬 경로가 저장된 경우 대응)
  Widget _buildLocalIconFromUrl(String assetPath) {
    // SVG인지 확인
    final isSvg = assetPath.toLowerCase().endsWith('.svg');

    if (isSvg) {
      return SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        placeholderBuilder: (context) => _buildLoadingPlaceholder(),
        // 에러 시 iconComponent로 Fallback
      );
    }

    // PNG
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _buildLocalIcon(),
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
    const ageBasePath = '$basePath/age_categories';

    // 연령 카테고리 아이콘 매핑 (age_categories 폴더)
    final ageIconMap = {
      'youth': '$ageBasePath/young_man.svg',
      'baby': '$ageBasePath/baby.svg',
      'newlywed': '$ageBasePath/bride.svg',
      'parenting': '$ageBasePath/kinder.svg',
      'senior': '$ageBasePath/old_man.svg',
      'disabled': '$ageBasePath/wheel_chair.svg',
    };

    // 혜택 카테고리 아이콘 매핑 (icons 폴더 직접 사용)
    final benefitIconMap = {
      'popular': '$basePath/popular.svg',
      'housing': '$basePath/housing.svg',
      'education': '$basePath/education.svg',
      'health': '$basePath/health.svg',
      'transport': '$basePath/transportation.svg',
      'transportation': '$basePath/transportation.svg',
      'welfare': '$basePath/heart.svg',
      'employment': '$basePath/employment.svg',
      'support': '$basePath/support.svg',
      'culture': '$basePath/culture.svg',
    };

    // 1순위: age_categories 확인
    if (ageIconMap.containsKey(component)) {
      return ageIconMap[component];
    }

    // 2순위: benefit_categories 확인
    if (benefitIconMap.containsKey(component)) {
      return benefitIconMap[component];
    }

    // 3순위: null 반환하여 fallback 아이콘 사용
    return null;
  }
}
