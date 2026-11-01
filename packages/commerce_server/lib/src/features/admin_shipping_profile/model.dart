import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'model.g.dart';

/// One profile response selected directly from the fulfillment table.
@Derive([Serialize(), Deserialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminShippingProfileResponse with _$AdminShippingProfileResponse {
  /// Creates the explicit merchant allowlist.
  const AdminShippingProfileResponse({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Decodes an embedded product-profile projection.
  factory AdminShippingProfileResponse.fromJson(Map<String, Object?> json) =>
      _$AdminShippingProfileResponseFromJson(json);

  /// Database-generated creation instant decoded from PostgreSQL TIMESTAMPTZ.
  @Sqlx(rename: 'created_at', tryFrom: _AdminShippingProfileUtcDateTime())
  final DateTime createdAt;

  /// Stable fulfillment profile identifier.
  final String id;

  /// Merchant-facing selection label.
  final String name;

  /// Open fulfillment behavior classification matching Medusa.
  final String type;

  /// Database-generated last mutation instant decoded from PostgreSQL TIMESTAMPTZ.
  @Sqlx(rename: 'updated_at', tryFrom: _AdminShippingProfileUtcDateTime())
  final DateTime updatedAt;
}

/// One bounded page of direct shipping-profile projections.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminShippingProfileListResponse
    with _$AdminShippingProfileListResponse {
  /// Creates profile rows and their paging metadata.
  const AdminShippingProfileListResponse({
    required this.shippingProfiles,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total matching active profiles.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit merchant fulfillment rows.
  final List<AdminShippingProfileResponse> shippingProfiles;
}

/// Optional product assignment returned after one atomic replacement.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminProductShippingProfileResponse
    with _$AdminProductShippingProfileResponse {
  /// Creates the explicit optional relationship response.
  const AdminProductShippingProfileResponse({required this.shippingProfile});

  /// Current active profile, or null when the assignment was cleared.
  final AdminShippingProfileResponse? shippingProfile;
}

final class _AdminShippingProfileUtcDateTime
    implements SqlxTryFrom<DateTime, String> {
  const _AdminShippingProfileUtcDateTime();

  @override
  DateTime decode(String value) => DateTime.parse(value).toUtc();
}
