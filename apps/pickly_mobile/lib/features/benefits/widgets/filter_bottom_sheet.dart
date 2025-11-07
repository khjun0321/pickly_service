import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickly_mobile/contexts/benefit/models/benefit_category.dart';
import 'package:pickly_mobile/contexts/benefit/models/benefit_subcategory.dart';
import 'package:pickly_mobile/features/benefits/providers/benefit_category_provider.dart';

/// FilterBottomSheet - Hierarchical subcategory filter UI
///
/// PRD v9.10.0: Database-driven filter replacing hardcoded _programTypesByCategory
///
/// Features:
/// - Loads subcategories from database via Riverpod providers
/// - Multi-select toggle for subcategory filtering
/// - Realtime updates when Admin modifies subcategories
/// - Preserves existing design (NO UI CHANGES)
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (context) => FilterBottomSheet(category: category),
/// );
/// ```
class FilterBottomSheet extends ConsumerWidget {
  final BenefitCategory category;

  const FilterBottomSheet({
    required this.category,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch subcategories stream for realtime updates
    final subcategoriesAsync = ref.watch(subcategoriesStreamProvider(category.id));

    // Watch current selections
    final selectedIds = ref.watch(selectedSubcategoryIdsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with category title and clear button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Category title
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),

                  // Clear all selections button
                  if (selectedIds.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        ref.read(selectedSubcategoryIdsProvider.notifier).state = {};
                      },
                      child: const Text(
                        '전체 해제',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

            // Subcategory list
            Flexible(
              child: subcategoriesAsync.when(
                data: (subcategories) {
                  if (subcategories.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          '필터가 없습니다',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: subcategories.length,
                    itemBuilder: (context, index) {
                      final subcategory = subcategories[index];
                      final isSelected = selectedIds.contains(subcategory.id);

                      return _SubcategoryTile(
                        subcategory: subcategory,
                        isSelected: isSelected,
                        onTap: () {
                          // Toggle selection
                          ref.read(selectedSubcategoryIdsProvider.notifier).update((state) {
                            final newSet = Set<String>.from(state);
                            if (newSet.contains(subcategory.id)) {
                              newSet.remove(subcategory.id);
                            } else {
                              newSet.add(subcategory.id);
                            }
                            return newSet;
                          });
                        },
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      '필터를 불러올 수 없습니다',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

            // Apply button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(selectedIds);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    selectedIds.isEmpty ? '전체 보기' : '${selectedIds.length}개 선택',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// _SubcategoryTile - Individual subcategory filter item
///
/// Displays subcategory name, icon, and selection state
class _SubcategoryTile extends StatelessWidget {
  final BenefitSubcategory subcategory;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubcategoryTile({
    required this.subcategory,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon (priority: iconUrl → iconName → fallback)
            SizedBox(
              width: 32,
              height: 32,
              child: _buildIcon(),
            ),

            const SizedBox(width: 12),

            // Subcategory name
            Expanded(
              child: Text(
                subcategory.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFF374151),
                ),
              ),
            ),

            // Selection indicator
            if (isSelected)
              const Icon(
                Icons.check_circle,
                size: 20,
                color: Color(0xFF3B82F6),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD1D5DB),
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    // Priority 1: iconUrl (Supabase Storage or full URL)
    if (subcategory.iconUrl != null && subcategory.iconUrl!.isNotEmpty) {
      // Check if it's a full HTTP URL or a storage path
      if (subcategory.iconUrl!.startsWith('http')) {
        return SvgPicture.network(
          subcategory.iconUrl!,
          fit: BoxFit.contain,
        );
      } else {
        // Assume it's a local asset path
        return SvgPicture.asset(
          subcategory.iconUrl!,
          package: 'pickly_design_system',
          fit: BoxFit.contain,
        );
      }
    }

    // Priority 2: iconName (local assets)
    if (subcategory.iconName != null && subcategory.iconName!.isNotEmpty) {
      return SvgPicture.asset(
        'assets/icons/${subcategory.iconName}.svg',
        package: 'pickly_design_system',
        fit: BoxFit.contain,
      );
    }

    // Priority 3: Fallback icon
    return SvgPicture.asset(
      'assets/icons/all.svg',
      package: 'pickly_design_system',
      fit: BoxFit.contain,
    );
  }
}
