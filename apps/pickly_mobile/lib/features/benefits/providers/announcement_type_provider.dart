/// Announcement Type Provider (v7.3)
///
/// Riverpod providers for announcement type state management.
/// Manages announcement type data for benefit screens.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement_type.dart';
import '../repositories/announcement_type_repository.dart';

/// Provider for the Supabase client instance.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for the announcement type repository.
final announcementTypeRepositoryProvider =
    Provider<AnnouncementTypeRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AnnouncementTypeRepository(client);
});

/// Provider for announcement types by category.
///
/// Fetches all active announcement types for a given category ID.
/// Auto-disposes when no longer needed.
///
/// Example:
/// ```dart
/// final types = ref.watch(announcementTypesByCategoryProvider(categoryId));
/// types.when(
///   data: (types) => TypeFilterButtons(types: types),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => ErrorWidget(err),
/// );
/// ```
final announcementTypesByCategoryProvider = FutureProvider.autoDispose
    .family<List<AnnouncementType>, String>((ref, categoryId) async {
  final repository = ref.watch(announcementTypeRepositoryProvider);
  return repository.getTypesByCategory(categoryId);
});

/// Provider for all announcement types across all categories.
///
/// Useful for admin interfaces or global filtering.
final allAnnouncementTypesProvider =
    FutureProvider.autoDispose<List<AnnouncementType>>((ref) async {
  final repository = ref.watch(announcementTypeRepositoryProvider);
  return repository.getAllTypes();
});

/// Provider for selected announcement type IDs (for filtering).
///
/// Maintains a list of selected type IDs for announcement filtering.
/// Persists across navigation within the same benefit category.
///
/// Example:
/// ```dart
/// // Get selected types
/// final selectedTypes = ref.watch(selectedAnnouncementTypesProvider);
///
/// // Add a type to selection
/// ref.read(selectedAnnouncementTypesProvider.notifier).state =
///   [...selectedTypes, newTypeId];
///
/// // Clear selection
/// ref.read(selectedAnnouncementTypesProvider.notifier).state = [];
/// ```
final selectedAnnouncementTypesProvider =
    StateProvider<List<String>>((ref) => []);

/// Provider for filtered announcements based on selected types.
///
/// Combines announcement list with selected type filters.
/// Returns announcements that match any of the selected types.
///
/// If no types are selected, returns all announcements.
final filteredAnnouncementsByTypeProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, categoryId) async {
  final selectedTypes = ref.watch(selectedAnnouncementTypesProvider);
  final client = ref.watch(supabaseClientProvider);

  // Get all type IDs for this category
  final typeRepository = ref.watch(announcementTypeRepositoryProvider);
  final types = await typeRepository.getTypesByCategory(categoryId);
  final typeIds = types.map((t) => t.id).toList();

  if (typeIds.isEmpty) {
    return [];
  }

  // Build query
  var query = client
      .from('announcements')
      .select()
      .inFilter('type_id', typeIds)
      .order('is_priority', ascending: false)
      .order('posted_date', ascending: false);

  // Apply type filter if types are selected
  if (selectedTypes.isNotEmpty) {
    query = query.inFilter('type_id', selectedTypes);
  }

  final response = await query;
  return response as List<Map<String, dynamic>>;
});

/// Provider for announcement counts by type.
///
/// Returns a map of type ID to announcement count.
/// Useful for displaying counts on filter buttons.
final announcementCountsByTypeProvider = FutureProvider.autoDispose
    .family<Map<String, int>, String>((ref, categoryId) async {
  final repository = ref.watch(announcementTypeRepositoryProvider);
  return repository.getAnnouncementCountsByCategory(categoryId);
});
