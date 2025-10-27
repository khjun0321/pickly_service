/// Custom exception for region operations
///
/// Used by [RegionRepository] to provide detailed error information
/// for region-related database operations.
class RegionException implements Exception {
  /// Error message describing what went wrong
  final String message;

  /// Optional error code from the database or API
  final String? code;

  /// Optional additional details about the error
  final dynamic details;

  /// Optional stack trace for debugging
  final StackTrace? stackTrace;

  /// Creates a new [RegionException] with the given parameters.
  RegionException(
    this.message, {
    this.code,
    this.details,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('RegionException: $message');
    if (code != null) {
      buffer.write(' (code: $code)');
    }
    if (details != null) {
      buffer.write(' - Details: $details');
    }
    return buffer.toString();
  }
}
