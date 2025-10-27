import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Popular category content (인기 카테고리 컨텐츠)
///
/// Displays popular policies and benefits with dynamic category banners
class PopularCategoryContent extends ConsumerWidget {
  const PopularCategoryContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Original popular content placeholder
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildOriginalContent(context),
        ),
      ],
    );
  }

  /// Original placeholder content
  Widget _buildOriginalContent(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 342,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFEBEBEB),
          ),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // Background image
          Image.network(
            'https://placehold.co/343x342',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFF5F5F5),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 64,
                    color: Color(0xFFDDDDDD),
                  ),
                ),
              );
            },
          ),
          // Button at bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 80,
                vertical: 12,
              ),
              decoration: ShapeDecoration(
                color: BrandColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                '구경하기',
                textAlign: TextAlign.center,
                style: PicklyTypography.bodyLarge.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
