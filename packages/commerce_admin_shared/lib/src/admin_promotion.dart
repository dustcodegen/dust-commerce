import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_promotion.g.dart';

/// Merchant-visible promotion lifecycle supported by this smaller schema.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum AdminPromotionStatus {
  /// Promotion has no active blocking date or usage limit.
  active,

  /// Promotion starts in the future.
  scheduled,

  /// Promotion can no longer be redeemed.
  expired,
}

/// Promotion-list order values accepted by the Medusa-shaped Admin API.
enum AdminPromotionOrder {
  /// Oldest promotions first.
  createdAtAsc('created_at'),

  /// Newest promotions first.
  createdAtDesc('-created_at'),

  /// Least recently updated promotions first.
  updatedAtAsc('updated_at'),

  /// Most recently updated promotions first.
  updatedAtDesc('-updated_at');

  const AdminPromotionOrder(this.parameter);

  /// Stable Admin API query value.
  final String parameter;

  /// Parses one allowlisted Admin API query value.
  static Option<AdminPromotionOrder> parse(String parameter) {
    for (final order in values) {
      if (order.parameter == parameter) return Some(order);
    }
    return const None();
  }
}

/// Codec used by direct server projections for promotion lifecycle values.
final class AdminPromotionStatusCodec
    implements SerDeCodec<AdminPromotionStatus, String> {
  /// Creates the stateless codec.
  const AdminPromotionStatusCodec();

  @override
  AdminPromotionStatus deserialize(String value) =>
      AdminPromotionStatus.values.byName(value);

  @override
  String serialize(AdminPromotionStatus value) => value.name;
}

/// One explicit merchant promotion row.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminPromotion with _$AdminPromotion {
  /// Creates one direct Admin API promotion allowlist.
  const AdminPromotion({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.isAutomatic,
    required this.status,
    required this.currencyCodeValue,
    required this.startsAtValue,
    required this.endsAtValue,
    required this.usageLimitValue,
    required this.usageCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Decodes the generated Admin promotion response.
  factory AdminPromotion.fromJson(Map<String, Object?> json) =>
      _$AdminPromotionFromJson(json);

  /// Merchant-entered promotion code.
  final String code;

  /// Database-generated creation instant.
  final DateTime createdAt;

  /// Nullable JSON backing for [currencyCode].
  @SerDe(rename: 'currency_code')
  final String? currencyCodeValue;

  /// Fixed-promotion currency, absent for percentage promotions.
  Option<String> get currencyCode => adminOptionOf(currencyCodeValue);

  /// Nullable JSON backing for [endsAt].
  @SerDe(rename: 'ends_at')
  final DateTime? endsAtValue;

  /// Optional expiry instant.
  Option<DateTime> get endsAt => adminOptionOf(endsAtValue);

  /// Stable promotion identifier.
  final String id;

  /// Medusa method column; this slice has code promotions only.
  final bool isAutomatic;

  /// Nullable JSON backing for [startsAt].
  @SerDe(rename: 'starts_at')
  final DateTime? startsAtValue;

  /// Optional start instant.
  Option<DateTime> get startsAt => adminOptionOf(startsAtValue);

  /// Derived merchant status used by the list table.
  @SerDe(using: AdminPromotionStatusCodec())
  final AdminPromotionStatus status;

  /// Current supported policy kind: `percentage` or `fixed`.
  final String type;

  /// Database-generated last mutation instant.
  final DateTime updatedAt;

  /// Number of committed redemptions.
  final int usageCount;

  /// Nullable JSON backing for [usageLimit].
  @SerDe(rename: 'usage_limit')
  final int? usageLimitValue;

  /// Optional global redemption limit.
  Option<int> get usageLimit => adminOptionOf(usageLimitValue);

  /// Basis points for percentage, minor units for fixed.
  final int value;
}

/// One bounded page of protected promotion rows.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminPromotionList with _$AdminPromotionList {
  /// Creates generated-client paging metadata and rows.
  const AdminPromotionList({
    required this.promotions,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes one generated Admin API response.
  factory AdminPromotionList.fromJson(Map<String, Object?> json) =>
      _$AdminPromotionListFromJson(json);

  /// Total active rows matching the query.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Direct allowlisted promotion rows.
  final List<AdminPromotion> promotions;
}

/// Medusa-compatible envelope returned by promotion detail retrieval.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminPromotionDetail with _$AdminPromotionDetail {
  /// Creates one explicit promotion detail envelope.
  const AdminPromotionDetail({required this.promotion});

  /// Decodes one generated Admin API response.
  factory AdminPromotionDetail.fromJson(Map<String, Object?> json) =>
      _$AdminPromotionDetailFromJson(json);

  /// Merchant-visible promotion detail.
  final AdminPromotion promotion;
}
