import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import '../providers/age_category_provider.dart';
import '../providers/age_category_controller.dart';

/// Example implementation of age category selection screen (Screen 003)
/// This demonstrates how to use the providers and controller
class AgeCategoryScreenExample extends ConsumerWidget {
  const AgeCategoryScreenExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(ageCategoryProvider);
    final selectionState = ref.watch(ageCategoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('연령/세대 선택'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(ageCategoryProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with instructions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '해당하는 연령/세대를 선택해주세요',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '선택된 항목: ${selectionState.selectedCount}개',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Error message display
          if (selectionState.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectionState.errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      ref.read(ageCategoryControllerProvider.notifier).clearError();
                    },
                  ),
                ],
              ),
            ),

          // Category list
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return const Center(
                    child: Text('표시할 카테고리가 없습니다'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return CategoryCard(
                      category: category,
                      key: ValueKey(category.id),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '데이터를 불러오는데 실패했습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('다시 시도'),
                      onPressed: () {
                        ref.read(ageCategoryProvider.notifier).retry();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Clear selections button
                if (selectionState.selectedCount > 0)
                  TextButton(
                    onPressed: () {
                      ref.read(ageCategoryControllerProvider.notifier).clearSelections();
                    },
                    child: const Text('선택 초기화'),
                  ),

                const SizedBox(height: 8),

                // Save and continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectionState.isSaving
                        ? null
                        : () => _handleSave(context, ref),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: selectionState.isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            selectionState.selectedCount > 0
                                ? '다음 (${selectionState.selectedCount}개 선택)'
                                : '다음',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(ageCategoryControllerProvider.notifier);
    final success = await controller.saveToSupabase();

    if (!context.mounted) return;

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('저장되었습니다'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to next screen (Screen 004 - Income Level)
      // Navigator.push(context, MaterialPageRoute(builder: (_) => NextScreen()));
    } else {
      // Error message is already displayed in the UI via errorMessage field
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('저장에 실패했습니다. 다시 시도해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Individual category card widget
class CategoryCard extends ConsumerWidget {
  final AgeCategory category;

  const CategoryCard({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(
      isAgeCategorySelectedProvider(category.id),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF27B473) : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          ref.read(ageCategoryControllerProvider.notifier)
              .toggleSelection(category.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon (placeholder - replace with actual icon component)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF27B473).withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconData(category.iconComponent),
                  size: 32,
                  color: isSelected ? const Color(0xFF27B473) : Colors.grey[600],
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          category.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? const Color(0xFF27B473) : Colors.black87,
                          ),
                        ),
                        if (category.ageRangeText.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            category.ageRangeText,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? const Color(0xFF27B473) : Colors.grey[400],
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Map icon component names to Flutter icons (placeholder)
  IconData _getIconData(String iconComponent) {
    switch (iconComponent) {
      case 'young_man':
        return Icons.person;
      case 'bride':
        return Icons.favorite;
      case 'baby':
        return Icons.child_care;
      case 'kinder':
        return Icons.family_restroom;
      case 'old_man':
        return Icons.elderly;
      case 'wheel_chair':
        return Icons.accessible;
      default:
        return Icons.category;
    }
  }
}
