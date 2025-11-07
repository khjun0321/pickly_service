/// Media URL Resolver Utility
///
/// Resolves icon filenames to either local assets or Supabase Storage URLs.
///
/// PRD v9.9.4: Unified Media Resolution (benefit-icons, age-icons, etc.)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Resolves media filename to asset path or network URL
///
/// Resolution Order:
/// 1. Check if local asset exists: assets/icons/{filename}
/// 2. If not found → Generate Supabase Storage URL from specified bucket
///
/// Parameters:
/// - filename: The file name (e.g., 'popular.svg', 'young_man.svg')
/// - bucket: Storage bucket name (default: 'benefit-icons')
///
/// Returns:
/// - 'asset://assets/icons/{filename}' if local asset exists
/// - 'https://..../[bucket]/{filename}' if remote only
///
/// Example:
/// ```dart
/// // Benefit icon
/// final url = await resolveMediaUrl('popular.svg');
///
/// // Age icon
/// final ageUrl = await resolveMediaUrl('young_man.svg', bucket: 'age-icons');
/// ```
Future<String> resolveMediaUrl(
  String? filename, {
  String bucket = 'benefit-icons',
}) async {
  // Handle null or empty filename
  if (filename == null || filename.isEmpty) {
    print('⚠️ [MediaResolver] Null/empty filename, using placeholder');
    return 'asset://packages/pickly_design_system/assets/icons/placeholder.svg';
  }

  // Normalize filename (remove any accidental paths)
  final cleanFilename = filename.split('/').last;

  print('🔍 [MediaResolver] Resolving: $cleanFilename (bucket: $bucket)');

  // Check if local asset exists
  // Try multiple paths: icons/ and icons/age_categories/
  final possiblePaths = [
    'packages/pickly_design_system/assets/icons/$cleanFilename',
    'packages/pickly_design_system/assets/icons/age_categories/$cleanFilename',
  ];

  for (final assetPath in possiblePaths) {
    try {
      await rootBundle.load(assetPath);
      // Asset exists locally - use it
      print('✅ [MediaResolver] Found local asset: $assetPath');
      return 'asset://$assetPath';
    } catch (e) {
      // Try next path
      continue;
    }
  }

  // Asset not found in any local path - use Supabase Storage
  print('🌐 [MediaResolver] Local asset not found, using Supabase Storage ($bucket)');

  try {
    final storageUrl = Supabase.instance.client.storage
        .from(bucket)
        .getPublicUrl(cleanFilename);

    print('✅ [MediaResolver] Generated storage URL: $storageUrl');
    return storageUrl;
  } catch (storageError) {
    print('❌ [MediaResolver] Storage URL generation failed: $storageError');
    return 'asset://packages/pickly_design_system/assets/icons/placeholder.svg';
  }
}

/// Convenience method for resolving benefit category icons
/// Uses 'benefit-icons' bucket
Future<String> resolveIconUrl(String? filename) async {
  return resolveMediaUrl(filename, bucket: 'benefit-icons');
}

/// Convenience method for resolving age category icons
/// Uses 'age-icons' bucket
Future<String> resolveAgeIconUrl(String? filename) async {
  return resolveMediaUrl(filename, bucket: 'age-icons');
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
