/// Benefit Category Provider (v9.0)
///
/// Manages benefit categories with Supabase + Riverpod
/// Syncs with Admin via realtime updates
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pickly_mobile/features/benefits/models/benefit_category.dart';

/// Supabase client provider
final _supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// AsyncNotifier for managing benefit categories
class BenefitCategoryNotifier extends AsyncNotifier<List<BenefitCategory>> {
  @override
  Future<List<BenefitCategory>> build() async {
    return _fetchCategories();
  }

  /// Fetch categories from Supabase
  Future<List<BenefitCategory>> _fetchCategories() async {
    try {
      final supabase = ref.read(_supabaseProvider);
      debugPrint('📡 Fetching benefit categories from Supabase...');

      final response = await supabase
          .from('benefit_categories')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final categories = (response as List)
          .map((json) => BenefitCategory.fromJson(json))
          .toList();

      debugPrint('✅ Loaded ${categories.length} benefit categories');
      return categories;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching benefit categories: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Refresh categories manually
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchCategories());
  }
}

/// Main provider for benefit categories
final benefitCategoryProvider =
    AsyncNotifierProvider<BenefitCategoryNotifier, List<BenefitCategory>>(
  () => BenefitCategoryNotifier(),
);

/// Provider to get category by slug
final categoryBySlugProvider =
    Provider.family<BenefitCategory?, String>((ref, slug) {
  final asyncCategories = ref.watch(benefitCategoryProvider);

  return asyncCategories.maybeWhen(
    data: (categories) {
      try {
        return categories.firstWhere((c) => c.slug == slug);
      } catch (e) {
        debugPrint('⚠️ Category not found for slug: $slug');
        return null;
      }
    },
    orElse: () => null,
  );
});

/// Provider to get all categories as list (non-nullable)
final categoriesListProvider = Provider<List<BenefitCategory>>((ref) {
  final asyncCategories = ref.watch(benefitCategoryProvider);
  return asyncCategories.maybeWhen(
    data: (categories) => categories,
    orElse: () => [],
  );
});
