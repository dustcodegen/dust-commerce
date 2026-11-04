import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

void main() {
  ProductVariant variant({
    int inventoryQuantity = 5,
    bool manageInventory = true,
    bool allowBackorder = false,
  }) =>
      ProductVariant.of(
        id: 'variant_1',
        title: 'Small / Black',
        sku: 'TSHIRT-S-BLK',
        prices: [Money.of(1999, 'usd'), Money.of(1799, 'eur')],
        originalPrices: [Money.of(2499, 'usd')],
        inventoryQuantity: inventoryQuantity,
        manageInventory: manageInventory,
        allowBackorder: allowBackorder,
        optionValues: const {'opt_size': 'Small', 'opt_colour': 'Black'},
      );

  group('ProductVariant.of', () {
    test('rejects two prices in the same currency', () {
      expect(
        () => ProductVariant.of(
          id: 'v',
          title: 't',
          prices: [Money.of(1, 'usd'), Money.of(2, 'usd')],
        ),
        throwsArgumentError,
      );
    });

    test('rejects two original prices in the same currency', () {
      expect(
        () => ProductVariant.of(
          id: 'v',
          title: 't',
          prices: [Money.of(1, 'usd')],
          originalPrices: [Money.of(2, 'usd'), Money.of(3, 'usd')],
        ),
        throwsArgumentError,
      );
    });

    test('rejects a negative inventory quantity', () {
      expect(() => variant(inventoryQuantity: -1), throwsArgumentError);
    });

    test('allows a variant with no prices, which is not yet sellable', () {
      final draft = ProductVariant.of(id: 'v', title: 't', prices: const []);

      expect(draft.prices, isEmpty);
      expect(draft.priceIn('usd'), isNull);
    });
  });

  group('priceIn', () {
    test('finds the price for a currency, case insensitively', () {
      expect(variant().priceIn('USD'), Money.of(1999, 'usd'));
      expect(variant().priceIn('eur'), Money.of(1799, 'eur'));
    });

    test('returns null for a currency it is not sold in', () {
      expect(variant().priceIn('gbp'), isNull);
    });

    test('reports sale state only when original exceeds active price', () {
      expect(variant().originalPriceIn('usd'), Money.of(2499, 'usd'));
      expect(variant().isOnSaleIn('usd'), isTrue);
      expect(variant().isOnSaleIn('eur'), isFalse);
    });

    test('reports the rounded sale percentage used by the storefront', () {
      expect(variant().salePercentageDiffIn('usd'), 20);
      expect(variant().salePercentageDiffIn('eur'), isNull);
    });
  });

  group('availability', () {
    test('is limited by stock when inventory is managed', () {
      expect(variant(inventoryQuantity: 5).canFulfil(5), isTrue);
      expect(variant(inventoryQuantity: 5).canFulfil(6), isFalse);
    });

    test('is unlimited when inventory is not managed', () {
      final digital = variant(inventoryQuantity: 0, manageInventory: false);

      expect(digital.canFulfil(1000), isTrue);
      expect(digital.isInStock, isTrue);
    });

    test('is unlimited when backorders are allowed', () {
      final backordered = variant(inventoryQuantity: 0, allowBackorder: true);

      expect(backordered.canFulfil(10), isTrue);
      expect(backordered.isInStock, isTrue);
    });

    test('is out of stock at zero when inventory is managed', () {
      expect(variant(inventoryQuantity: 0).isInStock, isFalse);
    });

    test('refuses a quantity below one', () {
      expect(() => variant().canFulfil(0), throwsArgumentError);
    });
  });

  group('json', () {
    test('round-trips through the generated codec', () {
      final subject = variant();

      expect(ProductVariant.fromJson(subject.toJson()), subject);
    });
  });
}
