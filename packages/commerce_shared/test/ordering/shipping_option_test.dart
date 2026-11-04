import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

void main() {
  const rule = ShippingPriceRule(
    attribute: ShippingPriceRuleAttribute.itemTotal,
    operator: ShippingPriceRuleOperator.gte,
    value: 10000,
  );
  const option = ShippingOption(
    optionId: 'ship_free',
    name: 'Free shipping',
    amount: Money(amount: 0, currencyCode: 'usd'),
    priceRules: [rule],
  );

  test('a minimum item-total rule includes its exact boundary', () {
    expect(option.isAvailableFor(Money.of(9999, 'usd')), isFalse);
    expect(option.isAvailableFor(Money.of(10000, 'usd')), isTrue);
  });

  test('an option never compares totals from another currency', () {
    expect(option.isAvailableFor(Money.of(10000, 'eur')), isFalse);
  });

  test('the public rule survives its wire representation', () {
    final decoded = ShippingOption.fromJson(option.toJson());

    expect(decoded, option);
    expect(decoded.priceRules.single, rule);
  });
}
