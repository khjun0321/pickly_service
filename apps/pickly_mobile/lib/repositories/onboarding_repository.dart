import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for managing onboarding data in Supabase
///
/// Handles:
/// - Saving user age category selections
/// - Updating user profiles
/// - Error handling and validation
class OnboardingRepository {
  final SupabaseClient _client;
  static const String _tableName = 'user_profiles';

  OnboardingRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Saves selected age category IDs to user profile
  ///
  /// Creates or updates the user profile with selected categories
  /// Returns true if successful
  /// Throws [OnboardingException] on error
  Future<bool> saveSelectedCategories({
    required String userId,
    required List<String> categoryIds,
  }) async {
    if (categoryIds.isEmpty) {
      throw OnboardingException('Category IDs cannot be empty');
    }

    try {
      // Check if profile exists
      final existing = await _client
          .from(_tableName)
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existing != null) {
        // Update existing profile
        await _client
            .from(_tableName)
            .update({
              'selected_categories': categoryIds,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      } else {
        // Insert new profile
        await _client.from(_tableName).insert({
          'id': userId,
          'selected_categories': categoryIds,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      return true;
    } on PostgrestException catch (e) {
      throw OnboardingException(
        'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      throw OnboardingException(
        'Failed to save selected categories: $e',
      );
    }
  }

  /// Updates user profile with onboarding completion status
  ///
  /// Marks onboarding as complete and optionally saves additional data
  /// Returns true if successful
  /// Throws [OnboardingException] on error
  Future<bool> completeOnboarding({
    required String userId,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final updateData = {
        'onboarding_completed': true,
        'onboarding_completed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      await _client
          .from(_tableName)
          .update(updateData)
          .eq('id', userId);

      return true;
    } on PostgrestException catch (e) {
      throw OnboardingException(
        'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      throw OnboardingException(
        'Failed to complete onboarding: $e',
      );
    }
  }

  /// Fetches user profile with selected categories
  ///
  /// Returns user profile data including selected categories
  /// Returns null if profile doesn't exist
  /// Throws [OnboardingException] on error
  Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('*, selected_categories')
          .eq('id', userId)
          .maybeSingle();

      return response as Map<String, dynamic>?;
    } on PostgrestException catch (e) {
      throw OnboardingException(
        'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      throw OnboardingException(
        'Failed to fetch user profile: $e',
      );
    }
  }

  /// Checks if user has completed onboarding
  ///
  /// Returns true if onboarding is complete, false otherwise
  /// Throws [OnboardingException] on error
  Future<bool> hasCompletedOnboarding(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('onboarding_completed')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return false;
      }

      return response['onboarding_completed'] == true;
    } on PostgrestException catch (e) {
      throw OnboardingException(
        'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      throw OnboardingException(
        'Failed to check onboarding status: $e',
      );
    }
  }

  /// Saves additional onboarding data to user profile
  ///
  /// Allows saving custom onboarding data (e.g., preferences, settings)
  /// Returns true if successful
  /// Throws [OnboardingException] on error
  Future<bool> saveOnboardingData({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    if (data.isEmpty) {
      throw OnboardingException('Onboarding data cannot be empty');
    }

    try {
      final updateData = {
        ...data,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client
          .from(_tableName)
          .update(updateData)
          .eq('id', userId);

      return true;
    } on PostgrestException catch (e) {
      throw OnboardingException(
        'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      throw OnboardingException(
        'Failed to save onboarding data: $e',
      );
    }
  }

  /// Resets user onboarding status
  ///
  /// Clears selected categories and onboarding completion status
  /// Useful for testing or allowing users to re-do onboarding
  /// Returns true if successful
  /// Throws [OnboardingException] on error
  Future<bool> resetOnboarding(String userId) async {
    try {
      await _client
          .from(_tableName)
          .update({
            'selected_categories': null,
            'onboarding_completed': false,
            'onboarding_completed_at': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      return true;
    } on PostgrestException catch (e) {
      throw OnboardingException(
        'Database error: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      throw OnboardingException(
        'Failed to reset onboarding: $e',
      );
    }
  }
}

/// Custom exception for onboarding operations
class OnboardingException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  OnboardingException(
    this.message, {
    this.code,
    this.details,
  });

  @override
  String toString() {
    final buffer = StringBuffer('OnboardingException: $message');
    if (code != null) {
      buffer.write(' (code: $code)');
    }
    if (details != null) {
      buffer.write(' - Details: $details');
    }
    return buffer.toString();
  }
}
