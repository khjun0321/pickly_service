/// Benefit Detail Provider (v9.0)
///
/// Manages benefit details (policies) with Supabase + Riverpod
/// Fetches details per category (e.g., 행복주택, 국민임대주택)
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pickly_mobile/features/benefits/models/benefit_detail.dart';

/// Supabase client provider
final _supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider to fetch details for a specific category
///
/// Usage:
/// ```dart
/// final details = ref.watch(benefitDetailsByCategoryProvider(categoryId));
/// ```
final benefitDetailsByCategoryProvider =
    FutureProvider.family<List<BenefitDetail>, String>((ref, categoryId) async {
  try {
    final supabase = ref.read(_supabaseProvider);
    debugPrint('📡 Fetching benefit details for category: $categoryId');

    final response = await supabase
        .from('benefit_details')
        .select()
        .eq('benefit_category_id', categoryId)
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    final details = (response as List)
        .map((json) => BenefitDetail.fromJson(json))
        .toList();

    debugPrint('✅ Loaded ${details.length} details for category $categoryId');
    return details;
  } catch (e, stackTrace) {
    debugPrint('❌ Error fetching benefit details: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
});

/// Provider to get a specific detail by ID
final benefitDetailByIdProvider =
    FutureProvider.family<BenefitDetail?, String>((ref, detailId) async {
  try {
    final supabase = ref.read(_supabaseProvider);
    debugPrint('📡 Fetching benefit detail by ID: $detailId');

    final response = await supabase
        .from('benefit_details')
        .select()
        .eq('id', detailId)
        .maybeSingle();

    if (response == null) {
      debugPrint('⚠️ Benefit detail not found: $detailId');
      return null;
    }

    return BenefitDetail.fromJson(response);
  } catch (e, stackTrace) {
    debugPrint('❌ Error fetching benefit detail by ID: $e');
    debugPrint('Stack trace: $stackTrace');
    return null;
  }
});
