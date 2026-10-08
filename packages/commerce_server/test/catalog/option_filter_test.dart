import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

import 'list_support.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient client;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_filter_http');
    database = CommerceDatabase.open(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedCatalogList(database);
    client = await TestClient.serve(buildApp(database));
  });

  tearDown(() async {
    await client.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('product options expose only stable public fields', () async {
    final response = await client.get('/store/product-options').send();
    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    final option = (body['product_options']! as List<Object?>).single!
        as Map<String, Object?>;
    final value =
        (option['values']! as List<Object?>).first! as Map<String, Object?>;

    expect(body.keys.toSet(), {'count', 'product_options'});
    expect(option.keys.toSet(), {'id', 'title', 'values'});
    expect(value.keys.toSet(), {'id', 'count', 'value'});
    expect(value['count'], isA<int>());
  });

  test('product listing filters by repeated stable value ids', () async {
    final response =
        await client.get('/store/products?optionValueIds=optval_large').send();
    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    final products = body['products']! as List<Object?>;

    expect(body['total'], 1);
    expect((products.single! as Map<String, Object?>)['handle'], 't-shirt');
  });

  test('product listing requires every repeated option value', () async {
    final response = await client
        .get('/store/products?optionValueIds=optval_large'
            '&optionValueIds=missing')
        .send();
    response.assertOk();

    expect(response.json, containsPair('total', 0));
    expect(response.json, containsPair('products', isEmpty));
  });

  test('product listing filters by repeated category handles', () async {
    final response = await client
        .get('/store/products?category=shirts&category=missing')
        .send();
    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    final products = body['products']! as List<Object?>;

    expect(body['total'], 1);
    expect((products.single! as Map<String, Object?>)['handle'], 't-shirt');
  });

  test('product listing filters by repeated label values', () async {
    final response =
        await client.get('/store/products?labels=Cotton&labels=missing').send();
    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    final products = body['products']! as List<Object?>;

    expect(body['total'], 1);
    expect((products.single! as Map<String, Object?>)['handle'], 't-shirt');
  });

  test('product listing filters by cheapest price range', () async {
    final response =
        await client.get('/store/products?minPrice=1000&maxPrice=2000').send();
    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    final products = body['products']! as List<Object?>;

    expect(body['total'], 1);
    expect((products.single! as Map<String, Object?>)['handle'], 't-shirt');
  });

  test('invalid price range is rejected at the HTTP boundary', () async {
    final response = await client.get('/store/products?minPrice=-1').send();

    expect(response.statusCode, 400);
  });

  test('unknown option value answers an empty valid page', () async {
    final response =
        await client.get('/store/products?optionValueIds=not-a-value').send();
    response.assertOk();
    expect(response.json, containsPair('total', 0));
    expect(response.json, containsPair('products', isEmpty));
  });
}
