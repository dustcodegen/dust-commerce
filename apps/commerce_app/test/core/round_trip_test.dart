import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/http.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

/// The claim this repository exists to make, checked end to end.
///
/// The API is the real one, serving over a real socket. The client is the one
/// Dust generated from `CommerceApi`. Nothing here hand-writes a JSON map: the
/// server encodes with the shared models and the client decodes with the same
/// ones, so a field renamed in `commerce_shared` breaks this test at compile
/// time rather than in production.
void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late Dio dio;
  late CommerceApi api;
  var counter = 0;

  setUp(() async {
    counter = 0;
    directory = await Directory.systemTemp.createTemp('commerce_round_trip');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedRoundTripCatalog(database);

    server = await TestClient.serve(
      buildApp(
        database,
        nextId: () => 'id_${++counter}',
        now: () => DateTime.utc(2100, 1, 1, 12),
      ),
    );
    dio = Dio();
    api = CommerceApi(dio, baseUrl: server.origin);
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  group('the catalogue', () {
    test('decodes a page into the shared Product type', () async {
      final page = await api.products();

      expect(page.total, 1);
      expect(page.products, hasLength(1));

      final product = page.products.single;
      expect(product, isA<Product>());
      expect(product.handle, 't-shirt');
      expect(product.cheapestIn('usd'), Money.of(1999, 'usd'));
      expect(product.isPurchasable, isTrue);
      expect(product.collection?.handle, 'summer');
      expect(product.categories.single.handle, 'clothing/shirts');
      expect(product.tags.single.value, 'Cotton');
    });

    test('decodes one product, keeping money as integer minor units', () async {
      final product = await api.product('t-shirt');

      expect(product.variants, hasLength(2));

      final small = product.variantById('var_small')!.priceIn('usd')!;
      expect(small.amount, isA<int>());
      expect(small, Money.of(1999, 'usd'));
      expect(product.cheapestIn('usd'), Money.of(1999, 'usd'));
    });

    test('prices in the currency the client asks for', () async {
      final product = await api.product('t-shirt', currency: 'eur');

      expect(product.cheapestIn('eur'), Money.of(1799, 'eur'));
      expect(product.cheapestIn('usd'), isNull);
    });

    test('decodes taxonomy endpoints and product filters', () async {
      final collections = await api.collections(handle: 'summer');
      final categories = await api.categories(handle: 'clothing/shirts');
      final options = await api.productOptions();
      final filtered = await api.products(
        labels: const ['cotton'],
        optionValueIds: const ['optval_small'],
      );

      expect(collections.collections.single.title, 'Summer');
      expect(categories.categories.single.name, 'Shirts');
      expect(options.productOptions.single.values.first.id, 'optval_small');
      expect(filtered.products.single.handle, 't-shirt');
    });
  });

  group('the cart', () {
    test('is created, added to, and totalled by the server', () async {
      final created = await api.createCart(const CreateCartBody());
      expect(created.cart.isEmpty, isTrue);

      final withLine = await api.addLine(
        created.cart.id,
        const AddLineBody(variantId: 'var_small', quantity: 2),
      );

      expect(withLine.itemCount, 2);
      expect(withLine.cart.items.single.unitPrice, Money.of(1999, 'usd'));
      expect(withLine.subtotal, Money.of(3998, 'usd'));
      expect(withLine.tax, Money.of(400, 'usd'));
      expect(withLine.total, Money.of(4398, 'usd'));
    });

    test('adds a product through the form-compatible atomic boundary',
        () async {
      final response = await api.addFormLine(
        variantId: 'var_small',
        quantity: 2,
        regionId: 'reg_us',
      );

      expect(response.cart.items.single.variantId, 'var_small');
      expect(response.itemCount, 2);
      expect(response.total, Money.of(4398, 'usd'));
    });

    test('agrees with the domain model computing the same totals', () async {
      final created = await api.createCart(const CreateCartBody());
      final response = await api.addLine(
        created.cart.id,
        const AddLineBody(variantId: 'var_small', quantity: 3),
      );

      final locally = Cart.of(
        id: response.cart.id,
        region: response.cart.region,
        items: response.cart.items,
      );

      expect(locally.subtotal, response.subtotal);
      expect(locally.tax, response.tax);
      expect(locally.total, response.total);
    });
  });
}
