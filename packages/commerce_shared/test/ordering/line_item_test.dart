import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

void main() {
  LineItem item({int quantity = 2, int unitPrice = 1999}) => LineItem.of(
        id: 'item_1',
        variantId: 'variant_1',
        productId: 'prod_1',
        productHandle: 't-shirt',
        title: 'T-Shirt',
        variantTitle: 'Small / Black',
        unitPrice: Money.of(unitPrice, 'usd'),
        quantity: quantity,
      );

  group('LineItem.of', () {
    test('refuses a quantity below one', () {
      expect(() => item(quantity: 0), throwsArgumentError);
      expect(() => item(quantity: -1), throwsArgumentError);
    });

    test('refuses a negative unit price', () {
      expect(() => item(unitPrice: -1), throwsArgumentError);
    });

    test('allows a free line, which a gift needs', () {
      expect(item(unitPrice: 0).subtotal, Money.zero('usd'));
    });
  });

  group('subtotal', () {
    test('is the unit price times the quantity', () {
      expect(
          item(unitPrice: 1999, quantity: 3).subtotal, Money.of(5997, 'usd'));
    });

    test('stays in the currency of the unit price', () {
      expect(item().subtotal.currencyCode, 'usd');
    });
  });

  group('the price snapshot', () {
    test('keeps the price it was added at, not the current one', () {
      final variant = ProductVariant.of(
        id: 'variant_1',
        title: 'Small / Black',
        prices: [Money.of(1999, 'usd')],
        inventoryQuantity: 10,
      );
      final added = LineItem.fromVariant(
        id: 'item_1',
        productId: 'prod_1',
        productHandle: 't-shirt',
        productTitle: 'T-Shirt',
        variant: variant,
        currencyCode: 'usd',
        quantity: 2,
      );

      final repriced = variant.copyWith(prices: [Money.of(2999, 'usd')]);

      expect(repriced.priceIn('usd'), Money.of(2999, 'usd'));
      expect(added.unitPrice, Money.of(1999, 'usd'));
      expect(added.subtotal, Money.of(3998, 'usd'));
    });

    test('refuses a variant with no price in the cart currency', () {
      final variant = ProductVariant.of(
        id: 'variant_1',
        title: 'Small / Black',
        prices: [Money.of(1999, 'usd')],
      );

      expect(
        () => LineItem.fromVariant(
          id: 'item_1',
          productId: 'prod_1',
          productHandle: 't-shirt',
          productTitle: 'T-Shirt',
          variant: variant,
          currencyCode: 'gbp',
          quantity: 1,
        ),
        throwsArgumentError,
      );
    });
  });

  group('quantity changes', () {
    test('returns a new line at the new quantity, same unit price', () {
      final changed = item(quantity: 2).withQuantity(5);

      expect(changed.quantity, 5);
      expect(changed.unitPrice, item().unitPrice);
      expect(changed.subtotal, Money.of(9995, 'usd'));
    });

    test('refuses a quantity below one', () {
      expect(() => item().withQuantity(0), throwsArgumentError);
    });
  });

  group('json', () {
    test('round-trips through the generated codec', () {
      expect(LineItem.fromJson(item().toJson()), item());
    });
  });
}
