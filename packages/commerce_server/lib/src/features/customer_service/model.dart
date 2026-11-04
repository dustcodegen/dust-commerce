import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'model.g.dart';

/// Store acknowledgement populated directly from the insert projection.
@Derive([FromRow(), Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class CustomerServiceSubmissionResponse
    with _$CustomerServiceSubmissionResponse {
  /// Creates one explicit Store response allowlist.
  const CustomerServiceSubmissionResponse({
    required this.id,
    required this.createdAt,
  });

  /// Database-generated UTC submission instant.
  @Sqlx(rename: 'created_at', tryFrom: _CustomerServiceDateTime())
  final DateTime createdAt;

  /// Stable opaque request identifier.
  final String id;
}

final class _CustomerServiceDateTime
    implements SqlxTryFrom<DateTime, DateTime> {
  const _CustomerServiceDateTime();

  @override
  DateTime decode(DateTime value) => value.toUtc();
}
