import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

import 'read_support.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient client;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_http');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedCatalogRead(database);
    client = TestClient(buildApp(database));
  });

  tearDown(() async {
    await client.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  group('GET /store/products', () {
    test('lists published products with their totals', () async {
      final response = await client.get('/store/products').send();

      response
        ..assertOk()
        ..assertJsonContains({'total': 2, 'count': 2, 'offset': 0});
    });

    test('never lists a draft', () async {
      final response = await client.get('/store/products').send();
      final body = response.json! as Map<String, Object?>;
      final products = body['products']! as List<Object?>;
      final handles = products
          .map((it) => (it! as Map<String, Object?>)['handle'])
          .toList();

      expect(handles, ['mug', 't-shirt']);
      expect(handles, isNot(contains('secret-hoodie')));
    });

    test('pages when asked', () async {
      (await client.get('/store/products?limit=1&offset=1').send())
        ..assertOk()
        ..assertJsonContains({'count': 1, 'limit': 1, 'offset': 1, 'total': 2});
    });

    test('caps a limit nobody should be allowed to ask for', () async {
      final response = await client.get('/store/products?limit=1000000').send();

      response
        ..assertOk()
        ..assertJsonContains({'limit': maxLimit});
    });

    test('falls back rather than failing on a nonsense limit', () async {
      final response = await client.get('/store/products?limit=abc').send();

      response
        ..assertOk()
        ..assertJsonContains({'limit': defaultLimit});
    });

    test('prices in the currency asked for', () async {
      final response = await client.get('/store/products?currency=eur').send();
      final body = response.json! as Map<String, Object?>;
      final products = body['products']! as List<Object?>;
      final shirt = products
          .map((it) => Product.fromJson(it! as Map<String, Object?>))
          .firstWhere((product) => product.handle == 't-shirt');

      expect(shirt.cheapestIn('eur'), Money.of(1799, 'eur'));
      expect(shirt.cheapestIn('usd'), isNull);
    });
  });

  group('GET /store/products/{handle}', () {
    test('returns one product, decodable by the shared model', () async {
      final response = await client.get('/store/products/t-shirt').send();

      response.assertOk();
      final product = Product.fromJson(response.json! as Map<String, Object?>);

      expect(product.title, 'T-Shirt');
      expect(product.cheapestIn('usd'), Money.of(1999, 'usd'));
      final urls = product.images.map((image) => image.url);
      expect(urls, [
        'https://example.test/shirt-front.png',
        'https://example.test/shirt-back.png',
      ]);
      expect(product.collection?.handle, 'summer');
      expect(product.details.productType, 'Shirt');
      expect(product.categories.single.handle, 'clothing/shirts');
      expect(product.categories.single.parentId, 'cat_clothing');
      expect(product.tags.single.value, 'Cotton');
    });

    test('answers 404 for a draft, not 403, so nothing leaks', () async {
      (await client.get('/store/products/secret-hoodie').send())
        ..assertNotFound()
        ..assertJsonContains({'error': 'Product "secret-hoodie"'});
    });

    test('answers 404 for a handle nobody has', () async {
      (await client.get('/store/products/nothing').send()).assertNotFound();
    });
  });

  group('the option matrix', () {
    test('a product carries the axes its variants vary along', () async {
      final response = await client.get('/store/products/t-shirt').send();
      final product = Product.fromJson(response.json! as Map<String, Object?>);

      expect(product.options, hasLength(1));
      expect(product.options.single.id, 'opt_size');
      expect(product.options.single.title, 'Size');
      expect(product.options.single.values, ['Small', 'Large']);
    });

    test('each variant carries the values it was built from', () async {
      final response = await client.get('/store/products/t-shirt').send();
      final product = Product.fromJson(response.json! as Map<String, Object?>);

      expect(
        product.variantById('var_small')!.optionValues,
        {'opt_size': 'Small'},
      );
      expect(
        product.variantById('var_large')!.optionValues,
        {'opt_size': 'Large'},
      );
    });

    test('serializes only the explicit storefront allowlist', () async {
      final response = await client.get('/store/products/t-shirt').send();
      final product = response.json! as Map<String, Object?>;
      final option = (product['options']! as List<Object?>).single!
          as Map<String, Object?>;
      final variant = (product['variants']! as List<Object?>).first!
          as Map<String, Object?>;

      expect(product.keys.toSet(), {
        'categories',
        'collection',
        'description',
        'details',
        'handle',
        'id',
        'images',
        'options',
        'status',
        'tags',
        'thumbnail',
        'title',
        'variants',
      });
      expect(option.keys.toSet(), {'id', 'title', 'values'});
      expect(variant.keys.toSet(), {
        'allow_backorder',
        'id',
        'inventory_quantity',
        'images',
        'manage_inventory',
        'option_values',
        'original_prices',
        'prices',
        'sku',
        'title',
      });
    });

    test('a size selector can find its variant, which is the point', () async {
      final response = await client.get('/store/products/t-shirt').send();
      final product = Product.fromJson(response.json! as Map<String, Object?>);

      expect(product.variantFor({'opt_size': 'Large'})?.id, 'var_large');
      expect(product.variantFor({'opt_size': 'Tiny'}), isNull);
    });

    test('a listed product carries them too, not only a fetched one', () async {
      final response = await client.get('/store/products').send();
      final body = response.json! as Map<String, Object?>;
      final products = (body['products']! as List<Object?>)
          .map((it) => Product.fromJson(it! as Map<String, Object?>))
          .toList();
      final shirt = products.firstWhere((it) => it.handle == 't-shirt');

      expect(shirt.options, hasLength(1));
      expect(shirt.variantById('var_small')!.optionValues, isNotEmpty);
    });
  });

  group('over real HTTP', () {
    test('answers the same as it does in process', () async {
      final served = await TestClient.serve(buildApp(database));
      addTearDown(served.close);

      (await served.get('/store/products/t-shirt').send())
        ..assertOk()
        ..assertHeader('content-type', 'application/json');
    });
  });
}
