import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'product_type_model.g.dart';

/// One Admin product type selected directly from its final table.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductTypeResponse with _$AdminProductTypeResponse {
  /// Creates the explicit merchant allowlist.
  const AdminProductTypeResponse({
    required this.id,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Database-generated creation instant converted from PostgreSQL TIMESTAMPTZ.
  @Sqlx(rename: 'created_at', tryFrom: _AdminUtcDateTime())
  final DateTime createdAt;

  /// Stable type identifier accepted by `type_id` filters.
  final String id;

  /// Database-generated mutation instant converted from PostgreSQL TIMESTAMPTZ.
  @Sqlx(rename: 'updated_at', tryFrom: _AdminUtcDateTime())
  final DateTime updatedAt;

  /// Merchant-facing type value.
  final String value;
}

/// One bounded page of explicit product-type responses.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductTypeListResponse with _$AdminProductTypeListResponse {
  /// Creates list metadata and direct SQLx rows.
  const AdminProductTypeListResponse({
    required this.productTypes,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total active rows matching the query.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit merchant product-type rows.
  final List<AdminProductTypeResponse> productTypes;
}

final class _AdminUtcDateTime implements SqlxTryFrom<DateTime, String> {
  const _AdminUtcDateTime();

  @override
  DateTime decode(String value) => DateTime.parse(value).toUtc();
}
