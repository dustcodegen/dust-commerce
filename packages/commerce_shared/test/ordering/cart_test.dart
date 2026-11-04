import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

void main() {
  final region = Region.of(
    id: 'reg_eu',
    name: 'Europe',
    currencyCode: 'eur',
    taxRate: 2000,
    countries: const ['de'],
  );

  LineItem line(String id, {int unitPrice = 1000, int quantity = 1}) =>
      LineItem.of(
        id: id,
        variantId: 'variant_$id',
        productId: 'prod_1',
        productHandle: 't-shirt',
        title: 'T-Shirt',
        unitPrice: Money.of(unitPrice, 'eur'),
        quantity: quantity,
      );

  Cart cart({List<LineItem>? items}) =>
      Cart.of(id: 'cart_1', region: region, items: items ?? [line('a')]);

  group('Cart.of', () {
    test('refuses a line priced in another currency than the region', () {
      final wrong = LineItem.of(
        id: 'x',
        variantId: 'v',
        productId: 'p',
        productHandle: 't',
        title: 'T',
        unitPrice: Money.of(1000, 'usd'),
        quantity: 1,
      );

      expect(() => cart(items: [wrong]), throwsArgumentError);
    });

    test('refuses two lines sharing an id', () {
      expect(() => cart(items: [line('a'), line('a')]), throwsArgumentError);
    });

    test('starts empty, which is the state a new cart is in', () {
      final empty = Cart.of(id: 'cart_1', region: region);

      expect(empty.isEmpty, isTrue);
      expect(empty.subtotal, Money.zero('eur'));
      expect(empty.total, Money.zero('eur'));
      expect(empty.itemCount, 0);
    });
  });

  group('totals', () {
    test('subtotal adds every line', () {
      final subject = cart(items: [
        line('a', unitPrice: 1000, quantity: 2),
        line('b', unitPrice: 500, quantity: 3),
      ]);

      expect(subject.subtotal, Money.of(3500, 'eur'));
    });

    test('tax comes from the region, and total adds it on', () {
      final subject = cart(items: [line('a', unitPrice: 1000)]);

      expect(subject.tax, Money.of(200, 'eur'));
      expect(subject.total, Money.of(1200, 'eur'));
    });

    test('a tax-inclusive region leaves the total alone', () {
      final inclusive = Cart.of(
        id: 'cart_1',
        region: Region.of(
          id: 'reg_eu',
          name: 'Europe',
          currencyCode: 'eur',
          taxRate: 2000,
          countries: const ['de'],
          taxInclusive: true,
        ),
        items: [line('a', unitPrice: 1200)],
      );

      expect(inclusive.tax, Money.of(200, 'eur'));
      expect(inclusive.total, Money.of(1200, 'eur'));
    });

    test('itemCount counts units, not lines', () {
      final subject = cart(items: [
        line('a', quantity: 2),
        line('b', quantity: 3),
      ]);

      expect(subject.itemCount, 5);
    });
  });

  group('adding', () {
    test('merges a line for a variant already in the cart', () {
      final again = LineItem.of(
        id: 'b',
        variantId: 'variant_a',
        productId: 'prod_1',
        productHandle: 't-shirt',
        title: 'T-Shirt',
        unitPrice: Money.of(1000, 'eur'),
        quantity: 2,
      );

      final subject = cart(items: [line('a', quantity: 1)]).withLine(again);

      expect(subject.items, hasLength(1));
      expect(subject.items.single.quantity, 3);
      expect(subject.items.single.id, 'a');
    });

    test('keeps the first price when merging, not the newer one', () {
      final subject = cart(items: [line('a', unitPrice: 1000)]).withLine(
        LineItem.of(
          id: 'b',
          variantId: 'variant_a',
          productId: 'prod_1',
          productHandle: 't-shirt',
          title: 'T-Shirt',
          unitPrice: Money.of(9999, 'eur'),
          quantity: 1,
        ),
      );

      expect(subject.items.single.unitPrice, Money.of(1000, 'eur'));
    });

    test('appends a line for a variant not yet in the cart', () {
      final other = LineItem.of(
        id: 'b',
        variantId: 'variant_other',
        productId: 'prod_2',
        productHandle: 'mug',
        title: 'Mug',
        unitPrice: Money.of(500, 'eur'),
        quantity: 1,
      );

      expect(cart().withLine(other).items, hasLength(2));
    });
  });

  group('removing', () {
    test('drops the line with that id', () {
      final subject = cart(items: [line('a'), line('b')]).withoutLine('a');

      expect(subject.items.single.id, 'b');
    });

    test('is a no-op for an id the cart does not hold', () {
      expect(cart().withoutLine('nope').items, hasLength(1));
    });
  });

  group('json', () {
    test('round-trips through the generated codec', () {
      expect(Cart.fromJson(cart().toJson()), cart());
    });
  });
}
