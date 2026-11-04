import 'dart:convert';

import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'shipping.g.dart';

/// Explicit shipping-option response populated directly by SQLx.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ShippingOptionResponse with _$ShippingOptionResponse {
  /// Creates an allowlisted option and its public eligibility rules.
  const ShippingOptionResponse({
    required this.optionId,
    required this.name,
    required this.amount,
    required this.priceRules,
  });

  /// Delivery price when the option is eligible.
  @Sqlx(tryFrom: ShippingMoneyFromJson())
  final Money amount;

  /// Delivery service display name.
  final String name;

  /// Stable shipping-option identifier.
  @Sqlx(rename: 'option_id')
  final String optionId;

  /// Explicit conditions the cart must satisfy.
  @Sqlx(
    rename: 'price_rules',
    tryFrom: ShippingPriceRulesFromJson(),
  )
  final List<ShippingPriceRuleResponse> priceRules;

  /// Whether the server-authoritative [itemTotal] satisfies every rule.
  bool isAvailableFor(Money itemTotal) {
    if (itemTotal.currencyCode != amount.currencyCode) return false;
    return priceRules.every((rule) => rule.accepts(itemTotal.amount));
  }
}

/// Explicit public comparison attached to a shipping option.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ShippingPriceRuleResponse with _$ShippingPriceRuleResponse {
  /// Creates an allowlisted price rule.
  const ShippingPriceRuleResponse({
    required this.attribute,
    required this.operator,
    required this.value,
  });

  /// Public cart fact name.
  final String attribute;

  /// Public comparison name.
  final String operator;

  /// Threshold in integer minor currency units.
  final int value;

  /// Whether [itemTotal] satisfies this supported rule.
  bool accepts(int itemTotal) {
    if (attribute != 'item_total') return false;
    return switch (operator) {
      'gt' => itemTotal > value,
      'gte' => itemTotal >= value,
      'lt' => itemTotal < value,
      'lte' => itemTotal <= value,
      'eq' => itemTotal == value,
      _ => false,
    };
  }
}

/// Explicit shipping-method response populated directly by SQLx.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ShippingMethodResponse with _$ShippingMethodResponse {
  /// Creates an allowlisted shipping method.
  const ShippingMethodResponse({
    required this.optionId,
    required this.name,
    required this.amount,
  });

  /// Delivery price snapshot.
  @Sqlx(tryFrom: ShippingMoneyFromJson())
  final Money amount;

  /// Delivery service display name.
  final String name;

  /// Stable shipping-option identifier.
  @Sqlx(rename: 'option_id')
  final String optionId;
}

/// Converts the shipping amount selected as a JSON object.
final class ShippingMoneyFromJson implements SqlxTryFrom<Money, String> {
  /// Creates the stateless converter.
  const ShippingMoneyFromJson();

  @override
  Money decode(String value) => Money.fromJson(
        jsonDecode(value) as Map<String, Object?>,
      );
}

/// Converts ordered SQL JSON rows into explicit response allowlists.
final class ShippingPriceRulesFromJson
    implements SqlxTryFrom<List<ShippingPriceRuleResponse>, String> {
  /// Creates the stateless converter.
  const ShippingPriceRulesFromJson();

  @override
  List<ShippingPriceRuleResponse> decode(String value) => [
        for (final item in jsonDecode(value) as List<Object?>)
          _decode(item! as Map<String, Object?>),
      ];

  static ShippingPriceRuleResponse _decode(Map<String, Object?> item) =>
      ShippingPriceRuleResponse(
        attribute: item['attribute']! as String,
        operator: item['operator']! as String,
        value: item['value']! as int,
      );
}
