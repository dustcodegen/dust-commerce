import 'package:dust_dart/serde.dart';

part 'admin_create_promotion.g.dart';

/// Merchant input for one code-based promotion.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCreatePromotion with _$AdminCreatePromotion {
  /// Creates one normalized promotion definition.
  const AdminCreatePromotion({
    required this.code,
    required this.type,
    required this.value,
    required this.currencyCodeValue,
    required this.startsAtValue,
    required this.endsAtValue,
    required this.usageLimitValue,
  });

  /// Decodes one generated Admin request.
  factory AdminCreatePromotion.fromJson(Map<String, Object?> json) =>
      _$AdminCreatePromotionFromJson(json);

  /// Uppercase customer-entered code.
  @SerDe(using: _PromotionCodeCodec())
  @Validate(length: Length(min: 1, max: 64), message: 'Enter a promotion code')
  @Validate(regex: r'^[A-Z0-9_-]+$', message: 'Use letters, numbers, _ or -')
  final String code;

  /// Fixed-promotion currency, absent for percentage promotions.
  @SerDe(rename: 'currency_code', using: _PromotionCurrencyCodec())
  @Validate(length: Length(max: 3), message: 'Use a three-letter currency')
  @Validate(regex: r'^[a-z]{3}$', message: 'Use a three-letter currency')
  final String? currencyCodeValue;

  /// Optional expiry instant.
  @SerDe(rename: 'ends_at')
  final DateTime? endsAtValue;

  /// Optional activation instant.
  @SerDe(rename: 'starts_at')
  final DateTime? startsAtValue;

  /// `percentage` stores basis points; `fixed` stores minor units.
  @Validate(regex: r'^(percentage|fixed)$', message: 'Choose a promotion type')
  final String type;

  /// Optional global redemption limit.
  @SerDe(rename: 'usage_limit')
  @Validate(range: Range(min: 1), message: 'Use a positive usage limit')
  final int? usageLimitValue;

  /// Percentage basis points or fixed minor units.
  @Validate(range: Range(min: 0), message: 'Use a non-negative value')
  final int value;
}

final class _PromotionCodeCodec implements SerDeCodec<String, String> {
  const _PromotionCodeCodec();

  @override
  String deserialize(String value) => value.trim().toUpperCase();

  @override
  String serialize(String value) => value.trim().toUpperCase();
}

final class _PromotionCurrencyCodec implements SerDeCodec<String, String> {
  const _PromotionCurrencyCodec();

  @override
  String deserialize(String value) => value.trim().toLowerCase();

  @override
  String serialize(String value) => value.trim().toLowerCase();
}
