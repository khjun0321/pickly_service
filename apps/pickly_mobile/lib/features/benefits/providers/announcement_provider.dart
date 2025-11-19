/// Announcement Provider
///
/// Manages announcement and announcement type data using Riverpod.
/// Handles fetching, caching, and state management for announcements.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_mobile/features/benefits/models/announcement.dart';
import 'package:pickly_mobile/features/benefits/models/announcement_type.dart';
import 'package:pickly_mobile/features/benefits/repositories/announcement_repository.dart';

/// Provider for AnnouncementRepository instance
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository();
});

// ==================== Announcement Types ====================

/// AsyncNotifier for managing announcement types
///
/// This provider:
/// - Loads all announcement types on initialization
/// - Caches types in memory
/// - Supports manual refresh
/// - Handles loading and error states
class AnnouncementTypeNotifier extends AsyncNotifier<List<AnnouncementType>> {
  @override
  Future<List<AnnouncementType>> build() async {
    return _fetchAnnouncementTypes();
  }

  /// Fetch announcement types from data source
  Future<List<AnnouncementType>> _fetchAnnouncementTypes() async {
    try {
      final repository = ref.read(announcementRepositoryProvider);
      final types = await repository.fetchAllAnnouncementTypes();
      debugPrint('✅ Loaded ${types.length} announcement types from Supabase');
      return types;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching announcement types: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Manually refresh announcement types from the data source
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAnnouncementTypes());
  }
}

/// Main provider for announcement types
final announcementTypeProvider = AsyncNotifierProvider<AnnouncementTypeNotifier, List<AnnouncementType>>(
  () => AnnouncementTypeNotifier(),
);

/// Provider to get announcement types for a specific category
///
/// Returns:
/// - Empty list `[]` if loading, error, or category has no types
/// - List of [AnnouncementType] sorted by sortOrder
final announcementTypesByCategoryProvider = Provider.family<List<AnnouncementType>, String>((ref, categoryId) {
  final asyncTypes = ref.watch(announcementTypeProvider);

  return asyncTypes.maybeWhen(
    data: (types) {
      final filtered = types
          .where((type) => type.benefitCategoryId == categoryId && type.isActive)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      debugPrint('🎯 [Type Filter] Category: $categoryId, Found: ${filtered.length} types');
      return filtered;
    },
    orElse: () {
      debugPrint('⚠️ [Type Filter] No data available for category: $categoryId');
      return [];
    },
  );
});

/// Provider to get all announcement types as a simple list
final announcementTypesListProvider = Provider<List<AnnouncementType>>((ref) {
  final asyncTypes = ref.watch(announcementTypeProvider);
  return asyncTypes.maybeWhen(
    data: (types) => types,
    orElse: () => [],
  );
});

// ==================== Announcements ====================

/// AsyncNotifier for managing announcements
///
/// This provider:
/// - Loads all announcements on initialization
/// - Caches announcements in memory
/// - Supports manual refresh
/// - Handles loading and error states
class AnnouncementNotifier extends AsyncNotifier<List<Announcement>> {
  @override
  Future<List<Announcement>> build() async {
    return _fetchAnnouncements();
  }

  /// Fetch announcements from data source
  Future<List<Announcement>> _fetchAnnouncements() async {
    try {
      final repository = ref.read(announcementRepositoryProvider);
      final announcements = await repository.fetchAllAnnouncements();
      debugPrint('✅ Loaded ${announcements.length} announcements from Supabase');
      return announcements;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching announcements: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Manually refresh announcements from the data source
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAnnouncements());
  }
}

/// Main provider for announcements
final announcementProvider = AsyncNotifierProvider<AnnouncementNotifier, List<Announcement>>(
  () => AnnouncementNotifier(),
);

/// Provider to get announcements for a specific type
///
/// Returns:
/// - Empty list `[]` if loading, error, or type has no announcements
/// - List of [Announcement] sorted by priority then postedDate DESC
final announcementsByTypeProvider = Provider.family<List<Announcement>, String>((ref, typeId) {
  final asyncAnnouncements = ref.watch(announcementProvider);

  return asyncAnnouncements.maybeWhen(
    data: (announcements) {
      final filtered = announcements.where((a) => a.typeId == typeId).toList()
        ..sort((a, b) {
          // Sort by priority first (isPriority DESC)
          final priorityCompare = b.isPriority ? 1 : (a.isPriority ? -1 : 0);
          if (priorityCompare != 0) return priorityCompare;
          // Then by posted date (DESC)
          return b.postedDate.compareTo(a.postedDate);
        });

      debugPrint('🎯 [Announcement Filter] Type: $typeId, Found: ${filtered.length} announcements');
      return filtered;
    },
    orElse: () {
      debugPrint('⚠️ [Announcement Filter] No data available for type: $typeId');
      return [];
    },
  );
});

/// Provider to get announcements filtered by status
///
/// Parameters:
/// - [status]: 'open', 'closed', or 'upcoming'
final announcementsByStatusProvider = Provider.family<List<Announcement>, String>((ref, status) {
  final asyncAnnouncements = ref.watch(announcementProvider);

  return asyncAnnouncements.maybeWhen(
    data: (announcements) {
      final filtered = announcements.where((a) => a.status == status).toList()
        ..sort((a, b) {
          final priorityCompare = b.isPriority ? 1 : (a.isPriority ? -1 : 0);
          if (priorityCompare != 0) return priorityCompare;
          return b.postedDate.compareTo(a.postedDate);
        });

      debugPrint('🎯 [Announcement Filter] Status: $status, Found: ${filtered.length} announcements');
      return filtered;
    },
    orElse: () => [],
  );
});

/// Provider to get all announcements as a simple list
final announcementsListProvider = Provider<List<Announcement>>((ref) {
  final asyncAnnouncements = ref.watch(announcementProvider);
  return asyncAnnouncements.maybeWhen(
    data: (announcements) => announcements,
    orElse: () => [],
  );
});

/// Provider to get priority announcements only
final priorityAnnouncementsProvider = Provider<List<Announcement>>((ref) {
  final asyncAnnouncements = ref.watch(announcementProvider);

  return asyncAnnouncements.maybeWhen(
    data: (announcements) {
      final filtered = announcements.where((a) => a.isPriority).toList()
        ..sort((a, b) => b.postedDate.compareTo(a.postedDate));

      debugPrint('🎯 [Priority Filter] Found: ${filtered.length} priority announcements');
      return filtered;
    },
    orElse: () => [],
  );
});

/// Provider to get open announcements only
final openAnnouncementsProvider = Provider<List<Announcement>>((ref) {
  return ref.watch(announcementsByStatusProvider('open'));
});

/// Provider to check if announcements are currently loading
final announcementsLoadingProvider = Provider<bool>((ref) {
  final asyncAnnouncements = ref.watch(announcementProvider);
  return asyncAnnouncements.isLoading;
});

/// Provider to get the current error state
final announcementsErrorProvider = Provider<Object?>((ref) {
  final asyncAnnouncements = ref.watch(announcementProvider);
  return asyncAnnouncements.error;
});

/// Provider to get a specific announcement by ID
final announcementByIdProvider = Provider.family<Announcement?, String>((ref, id) {
  final announcements = ref.watch(announcementsListProvider);
  try {
    return announcements.firstWhere((announcement) => announcement.id == id);
  } catch (e) {
    return null;
  }
});

/// Provider to get the count of announcements for a specific type
final announcementCountByTypeProvider = Provider.family<int, String>((ref, typeId) {
  return ref.watch(announcementsByTypeProvider(typeId)).length;
});

/// Provider to check if a type has any announcements
final hasAnnouncementsProvider = Provider.family<bool, String>((ref, typeId) {
  return ref.watch(announcementsByTypeProvider(typeId)).isNotEmpty;
});

/// Provider to get announcement count by status
final announcementCountByStatusProvider = Provider.family<int, String>((ref, status) {
  return ref.watch(announcementsByStatusProvider(status)).length;
});

// ==================== Realtime Streams (v8.6) ====================

/// StreamProvider for watching announcements in realtime
///
/// This provider:
/// - Creates a realtime stream from Supabase
/// - Automatically updates UI when data changes in Admin
/// - Maintains loading and error states
/// - Supports optional status and priority filters
///
/// Usage:
/// ```dart
/// // In your widget
/// final announcementsAsync = ref.watch(announcementsStreamProvider);
///
/// announcementsAsync.when(
///   data: (announcements) => ListView(children: announcements.map(...)),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
///
/// The stream will automatically emit updates when:
/// - Admin creates a new announcement
/// - Admin updates an existing announcement
/// - Admin deletes an announcement
/// - Any other client modifies the announcements table
final announcementsStreamProvider = StreamProvider<List<Announcement>>((ref) {
  final repository = ref.watch(announcementRepositoryProvider);
  debugPrint('🌊 [Stream Provider] Starting announcements stream');
  return repository.watchAnnouncements();
});

/// StreamProvider for watching announcements with status filter
///
/// Parameters:
/// - [status]: 'open', 'closed', or 'upcoming'
///
/// Returns a stream of filtered announcements
final announcementsStreamByStatusProvider = StreamProvider.family<List<Announcement>, String>((ref, status) {
  final repository = ref.watch(announcementRepositoryProvider);
  debugPrint('🌊 [Stream Provider] Starting announcements stream for status: $status');
  return repository.watchAnnouncements(status: status);
});

/// StreamProvider for watching priority announcements only
///
/// Returns a stream of only priority announcements
final priorityAnnouncementsStreamProvider = StreamProvider<List<Announcement>>((ref) {
  final repository = ref.watch(announcementRepositoryProvider);
  debugPrint('🌊 [Stream Provider] Starting priority announcements stream');
  return repository.watchAnnouncements(priorityOnly: true);
});

/// StreamProvider for watching announcements by type
///
/// Parameters:
/// - [typeId]: UUID of the announcement type
///
/// Returns a stream of announcements for the specified type
final announcementsStreamByTypeProvider = StreamProvider.family<List<Announcement>, String>((ref, typeId) {
  final repository = ref.watch(announcementRepositoryProvider);
  debugPrint('🌊 [Stream Provider] Starting announcements stream for type: $typeId');
  return repository.watchAnnouncementsByType(typeId);
});

/// StreamProvider for watching a single announcement by ID
///
/// Parameters:
/// - [id]: Announcement UUID
///
/// Returns a stream of the announcement (or null if not found/deleted)
final announcementStreamByIdProvider = StreamProvider.family<Announcement?, String>((ref, id) {
  final repository = ref.watch(announcementRepositoryProvider);
  debugPrint('🌊 [Stream Provider] Starting announcement stream for ID: $id');
  return repository.watchAnnouncementById(id);
});

/// Provider to get announcements list from stream
///
/// This is a convenience provider that extracts the data from AsyncValue
/// and returns an empty list if loading or error.
final announcementsStreamListProvider = Provider<List<Announcement>>((ref) {
  final asyncAnnouncements = ref.watch(announcementsStreamProvider);
  return asyncAnnouncements.maybeWhen(
    data: (announcements) => announcements,
    orElse: () => [],
  );
});

/// Provider to check if stream is currently loading
final announcementsStreamLoadingProvider = Provider<bool>((ref) {
  final asyncAnnouncements = ref.watch(announcementsStreamProvider);
  return asyncAnnouncements.isLoading;
});

/// Provider to get stream error state
final announcementsStreamErrorProvider = Provider<Object?>((ref) {
  final asyncAnnouncements = ref.watch(announcementsStreamProvider);
  return asyncAnnouncements.error;
});

/// Provider to get announcement count from stream
final announcementsStreamCountProvider = Provider<int>((ref) {
  final announcements = ref.watch(announcementsStreamListProvider);
  return announcements.length;
});

/// Provider to get open announcements from stream
final openAnnouncementsStreamProvider = Provider<List<Announcement>>((ref) {
  final asyncAnnouncements = ref.watch(announcementsStreamByStatusProvider('open'));
  return asyncAnnouncements.maybeWhen(
    data: (announcements) => announcements,
    orElse: () => [],
  );
});
