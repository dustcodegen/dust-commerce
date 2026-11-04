import 'package:dust_dart/serde.dart';

part 'shipping_price_rule.g.dart';

/// Cart fact a delivery-price rule compares.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum ShippingPriceRuleAttribute {
  /// Goods subtotal before delivery, discount, and tax.
  itemTotal,
}

/// Comparison used to decide whether a delivery option is available.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum ShippingPriceRuleOperator {
  /// Current value must be greater than the configured value.
  gt,

  /// Current value must be greater than or equal to the configured value.
  gte,

  /// Current value must be less than the configured value.
  lt,

  /// Current value must be less than or equal to the configured value.
  lte,

  /// Current value must equal the configured value.
  eq,
}

/// Public condition attached to one shipping option.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class ShippingPriceRule with _$ShippingPriceRule {
  /// Creates an already-validated shipping-price rule.
  const ShippingPriceRule({
    required this.attribute,
    required this.operator,
    required this.value,
  });

  /// Creates a rule from JSON.
  factory ShippingPriceRule.fromJson(Map<String, Object?> json) =>
      _$ShippingPriceRuleFromJson(json);

  /// Cart fact this rule reads.
  final ShippingPriceRuleAttribute attribute;

  /// Comparison applied to the cart fact.
  final ShippingPriceRuleOperator operator;

  /// Threshold in integer minor currency units.
  final int value;

  /// Whether [itemTotal] satisfies this rule.
  bool acceptsItemTotal(int itemTotal) => switch (operator) {
        ShippingPriceRuleOperator.gt => itemTotal > value,
        ShippingPriceRuleOperator.gte => itemTotal >= value,
        ShippingPriceRuleOperator.lt => itemTotal < value,
        ShippingPriceRuleOperator.lte => itemTotal <= value,
        ShippingPriceRuleOperator.eq => itemTotal == value,
      };
}
