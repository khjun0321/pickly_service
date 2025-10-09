import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase service singleton for managing database connections
class SupabaseService {
  static SupabaseService? _instance;
  SupabaseClient? _client;
  bool _isInitialized = false;

  SupabaseService._();

  /// Get singleton instance
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Initialize Supabase with configuration
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      instance._client = Supabase.instance.client;
      instance._isInitialized = true;
    } catch (e) {
      // Supabase initialization failed (likely due to placeholder values)
      // App should continue to work without Supabase features
      instance._isInitialized = false;
      print('⚠️ Supabase initialization failed: $e');
      print('App will run without Supabase features. Update .env with real credentials.');
    }
  }

  /// Check if Supabase is initialized
  bool get isInitialized => _isInitialized;

  /// Get Supabase client (null if not initialized)
  SupabaseClient? get client => _client;

  /// Get current user (null if Supabase not initialized or user not authenticated)
  User? get currentUser => _client?.auth.currentUser;

  /// Get current user ID (null if not authenticated or not initialized)
  String? get currentUserId => currentUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => _isInitialized && currentUser != null;

  /// Sign out
  Future<void> signOut() async {
    if (_client != null) {
      await _client!.auth.signOut();
    }
  }

  /// Listen to auth state changes (returns empty stream if not initialized)
  Stream<AuthState> get authStateChanges =>
      _client?.auth.onAuthStateChange ?? const Stream.empty();
}
