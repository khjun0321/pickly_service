/// Media URL Resolver Utility
///
/// Resolves icon filenames to either local assets or Supabase Storage URLs.
///
/// PRD v9.9.2: CircleTab Dynamic Binding Implementation
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Resolves icon filename to asset path or network URL
///
/// Resolution Order:
/// 1. Check if local asset exists: assets/icons/{filename}
/// 2. If not found → Generate Supabase Storage URL
///
/// Returns:
/// - 'asset://assets/icons/{filename}' if local asset exists
/// - 'https://..../benefit-icons/{filename}' if remote only
///
/// Example:
/// ```dart
/// final url = await resolveIconUrl('popular.svg');
/// // Returns: 'asset://assets/icons/popular.svg' (if exists locally)
/// // OR: 'https://xyz.supabase.co/storage/v1/object/public/benefit-icons/popular.svg'
/// ```
Future<String> resolveIconUrl(String? filename) async {
  // Handle null or empty filename
  if (filename == null || filename.isEmpty) {
    print('⚠️ [MediaResolver] Null/empty filename, using placeholder');
    return 'asset://packages/pickly_design_system/assets/icons/placeholder.svg';
  }

  // Normalize filename (remove any accidental paths)
  final cleanFilename = filename.split('/').last;

  print('🔍 [MediaResolver] Resolving: $cleanFilename');

  // Check if local asset exists
  final assetPath = 'packages/pickly_design_system/assets/icons/$cleanFilename';

  try {
    await rootBundle.load(assetPath);
    // Asset exists locally - use it
    print('✅ [MediaResolver] Found local asset: $assetPath');
    return 'asset://$assetPath';
  } catch (e) {
    // Asset not found locally - use Supabase Storage
    print('🌐 [MediaResolver] Local asset not found, using Supabase Storage');

    try {
      final storageUrl = Supabase.instance.client.storage
          .from('benefit-icons')
          .getPublicUrl(cleanFilename);

      print('✅ [MediaResolver] Generated storage URL: $storageUrl');
      return storageUrl;
    } catch (storageError) {
      print('❌ [MediaResolver] Storage URL generation failed: $storageError');
      return 'asset://packages/pickly_design_system/assets/icons/placeholder.svg';
    }
  }
}

/// Load SVG from resolved URL
///
/// Automatically detects asset:// vs https:// protocol
///
/// Usage:
/// ```dart
/// final resolvedUrl = await resolveIconUrl(category.iconUrl);
/// final svgWidget = await loadSvgFromResolvedUrl(resolvedUrl);
/// ```
Future<Widget> loadSvgFromResolvedUrl(
  String resolvedUrl, {
  double? width,
  double? height,
  Color? color,
}) async {
  if (resolvedUrl.startsWith('asset://')) {
    // Load from local asset
    final assetPath = resolvedUrl.replaceFirst('asset://', '');

    print('📦 [MediaResolver] Loading local asset: $assetPath');

    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  } else {
    // Load from network
    print('🌐 [MediaResolver] Loading network SVG: $resolvedUrl');

    return SvgPicture.network(
      resolvedUrl,
      width: width,
      height: height,
      fit: BoxFit.contain,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
      placeholderBuilder: (context) => SizedBox(
        width: width ?? 24,
        height: height ?? 24,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
