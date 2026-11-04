import 'package:commerce_shared/src/money.dart';
import 'package:commerce_shared/src/ordering/shipping_price_rule.dart';
import 'package:dust_dart/serde.dart';

part 'shipping_option.g.dart';

/// A delivery choice advertised to a cart before it is selected.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
class ShippingOption with _$ShippingOption {
  /// Creates an explicitly priced shipping option.
  const ShippingOption({
    required this.optionId,
    required this.name,
    required this.amount,
    this.priceRules = const [],
  });

  /// Creates a [ShippingOption] from JSON.
  factory ShippingOption.fromJson(Map<String, Object?> json) =>
      _$ShippingOptionFromJson(json);

  /// Price charged when the option is available and selected.
  final Money amount;

  /// Customer-facing service name.
  final String name;

  /// Stable option identifier.
  final String optionId;

  /// Conditions that all have to match the current cart.
  final List<ShippingPriceRule> priceRules;

  /// Whether this option can be selected for [itemTotal].
  bool isAvailableFor(Money itemTotal) {
    if (itemTotal.currencyCode != amount.currencyCode) return false;
    return priceRules.every(
      (rule) =>
          rule.attribute != ShippingPriceRuleAttribute.itemTotal ||
          rule.acceptsItemTotal(itemTotal.amount),
    );
  }
}
