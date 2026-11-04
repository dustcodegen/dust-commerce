import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

void main() {
  final region = Region.of(
    id: 'reg_us',
    name: 'United States',
    currencyCode: 'usd',
    taxRate: 1000,
    countries: const ['us'],
  );

  LineItem line({int unitPrice = 1000, int quantity = 1}) => LineItem.of(
        id: 'item_1',
        variantId: 'var_1',
        productId: 'prod_1',
        productHandle: 't-shirt',
        title: 'T-Shirt',
        unitPrice: Money.of(unitPrice, 'usd'),
        quantity: quantity,
      );

  Cart cart({
    List<LineItem>? items,
    ShippingMethod? shipping,
    Money? discount,
  }) =>
      Cart.of(
        id: 'cart_1',
        region: region,
        items: items ?? [line(unitPrice: 2000)],
        shippingMethod: shipping,
        promotions: discount == null
            ? const []
            : [
                CartPromotion(
                  id: 'promo_1',
                  code: 'SAVE',
                  type: PromotionType.fixed,
                  value: discount.amount,
                  amount: discount,
                  currencyCode: discount.currencyCode,
                ),
              ],
      );

  final standard = ShippingMethod.of(
    optionId: 'so_standard',
    name: 'Standard',
    amount: Money.of(500, 'usd'),
  );

  group('the totals formula', () {
    test('without shipping or discount, is subtotal plus tax', () {
      final subject = cart();

      expect(subject.subtotal, Money.of(2000, 'usd'));
      expect(subject.shippingTotal, Money.zero('usd'));
      expect(subject.discountTotal, Money.zero('usd'));
      expect(subject.tax, Money.of(200, 'usd'));
      expect(subject.total, Money.of(2200, 'usd'));
    });

    test('shipping is added, and taxed with the goods', () {
      final subject = cart(shipping: standard);

      expect(subject.shippingTotal, Money.of(500, 'usd'));
      // 10% of (2000 + 500)
      expect(subject.tax, Money.of(250, 'usd'));
      expect(subject.total, Money.of(2750, 'usd'));
    });

    test('a discount comes off before tax is worked out', () {
      final subject = cart(discount: Money.of(400, 'usd'));

      expect(subject.discountTotal, Money.of(400, 'usd'));
      // 10% of (2000 - 400)
      expect(subject.tax, Money.of(160, 'usd'));
      expect(subject.total, Money.of(1760, 'usd'));
    });

    test("all four together, in Medusa's order", () {
      final subject = cart(shipping: standard, discount: Money.of(400, 'usd'));

      // taxable = 2000 + 500 - 400 = 2100, tax = 210
      expect(subject.taxableTotal, Money.of(2100, 'usd'));
      expect(subject.tax, Money.of(210, 'usd'));
      expect(subject.total, Money.of(2310, 'usd'));
    });

    test('a discount larger than the goods cannot make a total negative', () {
      final subject = cart(discount: Money.of(9999, 'usd'));

      expect(subject.discountTotal, Money.of(2000, 'usd'));
      expect(subject.taxableTotal, Money.zero('usd'));
      expect(subject.total, Money.zero('usd'));
    });

    test('a discount does not eat the shipping the courier still charges', () {
      final subject = cart(shipping: standard, discount: Money.of(9999, 'usd'));

      expect(subject.discountTotal, Money.of(2000, 'usd'));
      expect(subject.taxableTotal, Money.of(500, 'usd'));
      expect(subject.total, Money.of(550, 'usd'));
    });

    test('a tax-inclusive region takes tax out rather than adding it', () {
      final inclusive = Cart.of(
        id: 'cart_1',
        region: Region.of(
          id: 'reg_eu',
          name: 'Europe',
          currencyCode: 'usd',
          taxRate: 1000,
          countries: const ['de'],
          taxInclusive: true,
        ),
        items: [line(unitPrice: 2200)],
      );

      expect(inclusive.tax, Money.of(200, 'usd'));
      expect(inclusive.total, Money.of(2200, 'usd'));
    });
  });

  group('ShippingMethod', () {
    test('refuses an amount below zero', () {
      expect(
        () => ShippingMethod.of(
          optionId: 'so',
          name: 'Broken',
          amount: Money.of(-1, 'usd'),
        ),
        throwsArgumentError,
      );
    });

    test('allows free shipping, which a promotion needs', () {
      final free = ShippingMethod.of(
        optionId: 'so_free',
        name: 'Free',
        amount: Money.zero('usd'),
      );

      expect(free.amount.isZero, isTrue);
    });

    test('round-trips through the generated codec', () {
      expect(ShippingMethod.fromJson(standard.toJson()), standard);
    });
  });

  group('a cart refuses what it cannot total', () {
    test('a shipping method in another currency', () {
      expect(
        () => cart(
          shipping: ShippingMethod.of(
            optionId: 'so',
            name: 'Euro post',
            amount: Money.of(500, 'eur'),
          ),
        ),
        throwsArgumentError,
      );
    });

    test('a discount in another currency', () {
      expect(() => cart(discount: Money.of(100, 'eur')), throwsArgumentError);
    });

    test('a negative discount, which would be a surcharge', () {
      expect(() => cart(discount: Money.of(-100, 'usd')), throwsArgumentError);
    });
  });
}
