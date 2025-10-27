import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider to get category ID by slug
final categoryIdBySlugProvider = FutureProvider.family<String?, String>((ref, slug) async {
  try {
    final response = await Supabase.instance.client
        .from('benefit_categories')
        .select('id')
        .eq('slug', slug)
        .single();

    return response['id'] as String;
  } catch (e) {
    print('❌ Error fetching category ID by slug: $e');
    return null;
  }
});

/// Provider to get housing category ID (parent)
final housingCategoryIdProvider = FutureProvider<String?>((ref) async {
  return ref.watch(categoryIdBySlugProvider('housing')).when(
    data: (id) => id,
    loading: () => null,
    error: (_, __) => null,
  );
});
