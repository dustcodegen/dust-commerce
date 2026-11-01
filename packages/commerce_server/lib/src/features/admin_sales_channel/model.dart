import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'model.g.dart';

/// One Admin sales-channel choice populated directly from its final table.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminSalesChannelResponse with _$AdminSalesChannelResponse {
  /// Creates the explicit merchant allowlist.
  const AdminSalesChannelResponse({required this.id, required this.name});

  /// Stable commercial-origin identifier.
  final String id;

  /// Merchant-facing sales-channel name.
  final String name;
}

/// One bounded page of explicit Admin sales-channel responses.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminSalesChannelListResponse with _$AdminSalesChannelListResponse {
  /// Creates list metadata and direct SQLx rows.
  const AdminSalesChannelListResponse({
    required this.salesChannels,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total non-deleted rows matching the query.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit merchant sales-channel rows.
  final List<AdminSalesChannelResponse> salesChannels;
}

/// One Medusa-shaped editor row populated directly from `sales_channels`.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminSalesChannelDetailResponse
    with _$AdminSalesChannelDetailResponse {
  /// Creates the explicit table-row response.
  const AdminSalesChannelDetailResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.isDisabled,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Database-generated creation instant decoded from PostgreSQL TIMESTAMPTZ.
  @Sqlx(rename: 'created_at', tryFrom: _AdminSalesChannelUtcDateTime())
  final DateTime createdAt;

  /// Optional merchant context shown in the editor table.
  final String? description;

  /// Stable commercial-origin identifier.
  final String id;

  /// Whether the channel rejects new commercial activity.
  @Sqlx(rename: 'is_disabled', tryFrom: _AdminSalesChannelBoolFromInt())
  final bool isDisabled;

  /// Merchant-facing sales-channel name.
  final String name;

  /// Database-generated last mutation instant decoded from PostgreSQL TIMESTAMPTZ.
  @Sqlx(rename: 'updated_at', tryFrom: _AdminSalesChannelUtcDateTime())
  final DateTime updatedAt;
}

/// One bounded page of direct editor-row projections.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminSalesChannelDetailListResponse
    with _$AdminSalesChannelDetailListResponse {
  /// Creates rows and their paging metadata.
  const AdminSalesChannelDetailListResponse({
    required this.salesChannels,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total non-deleted rows matching the query.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit merchant editor rows.
  final List<AdminSalesChannelDetailResponse> salesChannels;
}

final class _AdminSalesChannelUtcDateTime
    implements SqlxTryFrom<DateTime, String> {
  const _AdminSalesChannelUtcDateTime();

  @override
  DateTime decode(String value) => DateTime.parse(value).toUtc();
}

final class _AdminSalesChannelBoolFromInt implements SqlxTryFrom<bool, int> {
  const _AdminSalesChannelBoolFromInt();

  @override
  bool decode(int value) => value != 0;
}
