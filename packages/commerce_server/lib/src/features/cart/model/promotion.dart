import 'dart:convert';

import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'promotion.g.dart';

/// Direct-query, customer-safe response for one applied cart promotion.
@Derive([ToString(), Eq(), Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AppliedPromotionResponse with _$AppliedPromotionResponse {
  /// Creates an explicit applied-promotion response.
  const AppliedPromotionResponse({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.amount,
    this.currencyCode,
  });

  /// What it took off, snapshotted when applied.
  @Sqlx(tryFrom: AppliedPromotionMoneyFromJson())
  final Money amount;

  /// The code as typed.
  final String code;

  /// Currency of [value] for a fixed promotion.
  @Sqlx(rename: 'currency_code')
  final String? currencyCode;

  /// Stable promotion identifier.
  final String id;

  /// How [value] is interpreted.
  final String type;

  /// Basis points for percentages, or minor units for fixed promotions.
  final int value;

  /// Recalculates this snapshot against a changed cart subtotal.
  Money discountOn(Money subtotal) {
    final recalculated = switch (type) {
      'percentage' => Money(
          amount: (subtotal.amount * value + 5000) ~/ 10000,
          currencyCode: subtotal.currencyCode,
        ),
      'fixed' => Money.of(value, currencyCode!),
      _ => throw StateError('Unknown applied promotion type: $type'),
    };
    return recalculated > subtotal ? subtotal : recalculated;
  }
}

/// Decodes a customer-facing applied amount selected as SQLite JSON.
final class AppliedPromotionMoneyFromJson
    implements SqlxTryFrom<Money, String> {
  /// Creates the stateless converter.
  const AppliedPromotionMoneyFromJson();

  @override
  Money decode(String value) =>
      Money.fromJson(jsonDecode(value) as Map<String, Object?>);
}

/// Decodes the explicit applied-promotion aggregate selected for a cart.
final class AppliedPromotionsFromJson
    implements SqlxTryFrom<List<AppliedPromotionResponse>, String> {
  /// Creates the stateless converter.
  const AppliedPromotionsFromJson();

  @override
  List<AppliedPromotionResponse> decode(String value) => [
        for (final item in jsonDecode(value) as List<Object?>)
          _decodeAppliedPromotion(item! as Map<String, Object?>),
      ];
}

AppliedPromotionResponse _decodeAppliedPromotion(Map<String, Object?> item) =>
    AppliedPromotionResponse(
      id: item['id']! as String,
      code: item['code']! as String,
      type: item['type']! as String,
      value: item['value']! as int,
      currencyCode: item['currency_code'] as String?,
      amount: Money.fromJson(item['amount']! as Map<String, Object?>),
    );

/// Internal promotion query result used directly by cart policy.
@Derive([FromRow()])
final class PromotionPolicy {
  /// Constructs the policy input directly from its query row.
  PromotionPolicy({
    required this.promotionId,
    required this.promotionCode,
    required this.storedType,
    required this.promotionValue,
    required this.promotionUsageCount,
    this.promotionCurrencyCode,
    this.startsAt,
    this.endsAt,
    this.promotionUsageLimit,
  });

  /// Stored exclusive validity end.
  @Sqlx(rename: 'ends_at', defaultValue: null, tryFrom: _PromotionDateTime())
  final DateTime? endsAt;

  /// Promotion code matched case-insensitively in SQL.
  @Sqlx(rename: 'code')
  final String promotionCode;

  /// Currency required by fixed promotions.
  @Sqlx(rename: 'currency_code')
  final String? promotionCurrencyCode;

  /// Stable promotion identifier.
  @Sqlx(rename: 'id')
  final String promotionId;

  /// Number of redemptions recorded so far.
  @Sqlx(rename: 'usage_count')
  final int promotionUsageCount;

  /// Maximum redemptions, when the merchant set one.
  @Sqlx(rename: 'usage_limit')
  final int? promotionUsageLimit;

  /// Percentage basis points or fixed minor-unit amount.
  @Sqlx(rename: 'value')
  final int promotionValue;

  /// Stored inclusive validity start.
  @Sqlx(rename: 'starts_at', defaultValue: null, tryFrom: _PromotionDateTime())
  final DateTime? startsAt;

  /// Stored promotion type name.
  @Sqlx(rename: 'type')
  final String storedType;

  /// Customer-entered promotion code.
  String get code => promotionCode;

  /// Currency required by a fixed promotion.
  String? get currencyCode => promotionCurrencyCode;

  /// Stable promotion identifier.
  String get id => promotionId;

  /// Decoded promotion strategy.
  PromotionType get type =>
      storedType == 'fixed' ? PromotionType.fixed : PromotionType.percentage;

  /// Computes the discount without constructing a second promotion model.
  Money discountOn(Money subtotal) {
    final amount = type == PromotionType.fixed
        ? promotionValue
        : (subtotal.amount * promotionValue + 5000) ~/ 10000;
    final discount = Money(
      amount: amount,
      currencyCode: promotionCurrencyCode ?? subtotal.currencyCode,
    );
    return discount > subtotal ? subtotal : discount;
  }

  /// Whether the promotion is within its configured window and usage limit.
  bool isUsableAt(DateTime when) {
    if (startsAt != null && when.isBefore(startsAt!)) return false;
    if (endsAt != null && !when.isBefore(endsAt!)) return false;
    final limit = promotionUsageLimit;
    return limit == null || promotionUsageCount < limit;
  }
}

final class _PromotionDateTime implements SqlxTryFrom<DateTime, DateTime> {
  const _PromotionDateTime();

  @override
  DateTime decode(DateTime value) => value.toUtc();
}
