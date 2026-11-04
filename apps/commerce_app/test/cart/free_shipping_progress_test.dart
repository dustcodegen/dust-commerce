import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const free = ShippingOption(
    optionId: 'ship_free',
    name: 'Free shipping',
    amount: Money(amount: 0, currencyCode: 'usd'),
    priceRules: [
      ShippingPriceRule(
        attribute: ShippingPriceRuleAttribute.itemTotal,
        operator: ShippingPriceRuleOperator.gte,
        value: 10000,
      ),
    ],
  );

  test('reports the server-owned amount remaining and clamped progress', () {
    final progress = freeShippingProgressOf(_cart(2500), const [free]);

    expect(progress, isA<Some<FreeShippingProgress>>());
    final value = (progress as Some<FreeShippingProgress>).value;
    expect(value.remaining, Money.of(7500, 'usd'));
    expect(value.fraction, 0.25);
    expect(value.targetReached, isFalse);
  });

  test('marks the exact greater-than-or-equal boundary as unlocked', () {
    final progress = freeShippingProgressOf(_cart(10000), const [free]);

    final value = (progress as Some<FreeShippingProgress>).value;
    expect(value.remaining, Money.zero('usd'));
    expect(value.fraction, 1);
    expect(value.targetReached, isTrue);
  });

  test('ignores paid, unconditional, and wrong-currency options', () {
    const paid = ShippingOption(
      optionId: 'paid',
      name: 'Paid',
      amount: Money(amount: 500, currencyCode: 'usd'),
    );
    const wrongCurrency = ShippingOption(
      optionId: 'free_eur',
      name: 'Free EU',
      amount: Money(amount: 0, currencyCode: 'eur'),
      priceRules: [
        ShippingPriceRule(
          attribute: ShippingPriceRuleAttribute.itemTotal,
          operator: ShippingPriceRuleOperator.gte,
          value: 10000,
        ),
      ],
    );

    expect(
      freeShippingProgressOf(_cart(2500), const [paid, wrongCurrency]),
      const None<FreeShippingProgress>(),
    );
  });

  test('does not treat free pickup as a free-shipping threshold', () {
    const pickup = ShippingOption(
      optionId: 'pickup',
      name: 'Store pickup',
      amount: Money(amount: 0, currencyCode: 'usd'),
      fulfillmentType: ShippingFulfillmentType.pickup,
      priceRules: [
        ShippingPriceRule(
          attribute: ShippingPriceRuleAttribute.itemTotal,
          operator: ShippingPriceRuleOperator.gte,
          value: 10000,
        ),
      ],
    );

    expect(
      freeShippingProgressOf(_cart(2500), const [pickup]),
      const None<FreeShippingProgress>(),
    );
  });

  test('supports every declared Medusa comparison operator', () {
    const lt = ShippingOption(
      optionId: 'lt',
      name: 'Free below limit',
      amount: Money(amount: 0, currencyCode: 'usd'),
      priceRules: [
        ShippingPriceRule(
          attribute: ShippingPriceRuleAttribute.itemTotal,
          operator: ShippingPriceRuleOperator.lt,
          value: 10000,
        ),
      ],
    );
    const lte = ShippingOption(
      optionId: 'lte',
      name: 'Free at limit',
      amount: Money(amount: 0, currencyCode: 'usd'),
      priceRules: [
        ShippingPriceRule(
          attribute: ShippingPriceRuleAttribute.itemTotal,
          operator: ShippingPriceRuleOperator.lte,
          value: 10000,
        ),
      ],
    );
    const eq = ShippingOption(
      optionId: 'eq',
      name: 'Free exact total',
      amount: Money(amount: 0, currencyCode: 'usd'),
      priceRules: [
        ShippingPriceRule(
          attribute: ShippingPriceRuleAttribute.itemTotal,
          operator: ShippingPriceRuleOperator.eq,
          value: 10000,
        ),
      ],
    );

    final ltProgress = freeShippingProgressOf(_cart(2500), const [lt]);
    final lteProgress = freeShippingProgressOf(_cart(10000), const [lte]);
    final eqProgress = freeShippingProgressOf(_cart(9000), const [eq]);

    expect(
      (ltProgress as Some<FreeShippingProgress>).value.targetReached,
      isTrue,
    );
    expect(
      (lteProgress as Some<FreeShippingProgress>).value.targetReached,
      isTrue,
    );
    expect(
      (eqProgress as Some<FreeShippingProgress>).value.remaining,
      Money.of(1000, 'usd'),
    );
  });

  test('dismissal is scoped to one cart capability', () {
    const state = CartState(
      dismissedFreeShippingCartId: Some('cart_1'),
    );

    expect(state.isFreeShippingNudgeDismissedFor('cart_1'), isTrue);
    expect(state.isFreeShippingNudgeDismissedFor('cart_2'), isFalse);
  });
}

CartView _cart(int subtotal) => CartView(
      cart: const Cart(
        id: 'cart_1',
        region: Region(
          id: 'reg_us',
          name: 'United States',
          currencyCode: 'usd',
          taxRate: 0,
          countries: ['us'],
        ),
        items: [],
      ),
      subtotal: Money.of(subtotal, 'usd'),
      shippingTotal: Money.zero('usd'),
      discountTotal: Money.zero('usd'),
      tax: Money.zero('usd'),
      total: Money.of(subtotal, 'usd'),
      itemCount: 0,
    );
