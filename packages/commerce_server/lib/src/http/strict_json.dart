import 'package:dust_server/server.dart';

/// JSON body extractor that refuses fields outside an explicit allowlist.
final class StrictJsonExtractable<T> implements FromRequest<T> {
  /// Creates an allowlisted JSON extractor.
  const StrictJsonExtractable(
    this.deserialize, {
    required this.fields,
    this.limit = defaultBodyLimit,
  });

  /// Builds [T] after the body keys pass the allowlist.
  final T Function(Map<String, Object?> json) deserialize;

  /// Accepted wire field names.
  final Set<String> fields;

  /// Maximum request body size in bytes.
  final int limit;

  @override
  Future<Result<T, Rejection>> extract(Request request) => JsonExtractable<T>(
        _deserialize,
        limit: limit,
      ).extract(request);

  T _deserialize(Map<String, Object?> json) {
    final unknown = json.keys.where((key) => !fields.contains(key)).toList();
    if (unknown.isNotEmpty) {
      throw FormatException('unknown field: ${unknown.join(', ')}');
    }
    return deserialize(json);
  }
}
