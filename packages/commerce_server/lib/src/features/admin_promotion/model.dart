import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'model.g.dart';

/// One promotion row selected directly from the final promotion table.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminPromotionResponse with _$AdminPromotionResponse {
  /// Creates the explicit merchant allowlist.
  const AdminPromotionResponse({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.isAutomatic,
    required this.status,
    required this.currencyCode,
    required this.startsAt,
    required this.endsAt,
    required this.usageLimit,
    required this.usageCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Merchant-entered promotion code.
  final String code;

  /// Database-generated creation instant decoded from PostgreSQL TIMESTAMPTZ.
  @Sqlx(rename: 'created_at', tryFrom: _AdminPromotionUtcDateTime())
  final DateTime createdAt;

  /// Fixed-promotion currency, absent for percentage promotions.
  @Sqlx(rename: 'currency_code')
  final String? currencyCode;

  /// Optional expiry instant.
  @Sqlx(
    rename: 'ends_at',
    defaultValue: null,
    tryFrom: _AdminPromotionUtcDateTime(),
  )
  final DateTime? endsAt;

  /// Stable promotion identifier.
  final String id;

  /// Medusa method column; this slice has code promotions only.
  @Sqlx(rename: 'is_automatic')
  final bool isAutomatic;

  /// Optional start instant.
  @Sqlx(
    rename: 'starts_at',
    defaultValue: null,
    tryFrom: _AdminPromotionUtcDateTime(),
  )
  final DateTime? startsAt;

  /// Derived merchant lifecycle.
  @SerDe(using: AdminPromotionStatusCodec())
  @Sqlx(tryFrom: _AdminPromotionStatusSqlx())
  final AdminPromotionStatus status;

  /// Current supported policy kind.
  final String type;

  /// Database-generated mutation instant decoded from PostgreSQL TIMESTAMPTZ.
  @Sqlx(rename: 'updated_at', tryFrom: _AdminPromotionUtcDateTime())
  final DateTime updatedAt;

  /// Committed redemption count.
  @Sqlx(rename: 'usage_count')
  final int usageCount;

  /// Optional global redemption limit.
  @Sqlx(rename: 'usage_limit')
  final int? usageLimit;

  /// Basis points for percentage, minor units for fixed.
  final int value;
}

/// One bounded page of direct promotion projections.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminPromotionListResponse with _$AdminPromotionListResponse {
  /// Creates rows and paging metadata.
  const AdminPromotionListResponse({
    required this.promotions,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total matching active rows.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit merchant promotion rows.
  final List<AdminPromotionResponse> promotions;
}

/// Medusa-compatible envelope for promotion detail retrieval.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminPromotionDetailResponse with _$AdminPromotionDetailResponse {
  /// Creates one explicit promotion detail envelope.
  const AdminPromotionDetailResponse({required this.promotion});

  /// Direct SQLx row without persistence-only fields.
  final AdminPromotionResponse promotion;
}

final class _AdminPromotionStatusSqlx
    implements SqlxTryFrom<AdminPromotionStatus, String> {
  const _AdminPromotionStatusSqlx();

  @override
  AdminPromotionStatus decode(String value) =>
      AdminPromotionStatus.values.byName(value);
}

final class _AdminPromotionUtcDateTime
    implements SqlxTryFrom<DateTime, DateTime> {
  const _AdminPromotionUtcDateTime();

  @override
  DateTime decode(DateTime value) => value.toUtc();
}
