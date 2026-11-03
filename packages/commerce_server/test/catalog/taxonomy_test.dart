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
    directory = await Directory.systemTemp.createTemp('commerce_taxonomy');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedCatalogRead(database);
    await queryExecute(
      r"INSERT INTO regions "
      r"(id, name, currency_code, tax_rate, tax_inclusive, countries, deleted_at) "
      r"VALUES "
      r"('reg_us', 'United States', 'usd', 0, 0, 'us,ca', NULL), "
      r"('reg_old', 'Retired', 'usd', 0, 0, 'gb', "
      r"'2026-09-05T00:00:00.000Z')",
      const [],
    ).execute(database.executor);
    await queryExecute(
      r"INSERT INTO region_payment_providers (region_id, provider_id, enabled) "
      r"VALUES ('reg_us', 'manual', 1), ('reg_us', 'invented', 1), "
      r"('reg_old', 'retired', 1)",
      const [],
    ).execute(database.executor);
    client = TestClient(buildApp(database));
  });

  tearDown(() async {
    await client.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('lists and filters public collections', () async {
    final response =
        await client.get('/store/collections?handle=summer').send();

    response.assertOk();
    final view = ProductCollectionListView.fromJson(
      response.json! as Map<String, Object?>,
    );
    expect(view.count, 1);
    expect(view.collections.single.handle, 'summer');
  });

  test('lists active category hierarchy nodes', () async {
    final response = await client
        .get('/store/product-categories?handle=clothing%2Fshirts')
        .send();

    response.assertOk();
    final view = ProductCategoryListView.fromJson(
      response.json! as Map<String, Object?>,
    );
    expect(view.count, 1);
    expect(view.categories.single.name, 'Shirts');
    expect(view.categories.single.parentId, 'cat_clothing');
  });

  test('lists only the explicit active selling-region allowlist', () async {
    final response = await client.get('/store/regions').send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    final view = SellingRegionListView.fromJson(json);
    expect(view.count, 1);
    expect(view.regions.single.countries, ['us', 'ca']);
    expect((json['regions']! as List<Object?>).single, {
      'countries': ['us', 'ca'],
      'currency_code': 'usd',
      'id': 'reg_us',
      'name': 'United States',
      'tax_inclusive': false,
      'tax_rate': 0,
    });
  });

  test('lists only enabled providers for the requested active region',
      () async {
    final response =
        await client.get('/store/payment-providers?region_id=reg_us').send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    expect(
      PaymentProviderListView.fromJson(json).paymentProviders,
      const [PaymentProviderView(id: 'manual')],
    );
    expect(json, {
      'payment_providers': [
        {'id': 'manual'},
      ],
    });
  });

  test('requires a region and hides providers for retired regions', () async {
    (await client.get('/store/payment-providers').send()).assertBadRequest();

    final retired =
        await client.get('/store/payment-providers?region_id=reg_old').send();
    retired.assertOk();
    expect(
      PaymentProviderListView.fromJson(
        retired.json! as Map<String, Object?>,
      ).paymentProviders,
      isEmpty,
    );
  });

  test('filters product pages by collection, category and tag', () async {
    for (final query in [
      'collection=summer',
      'category=clothing%2Fshirts',
      'tag=cotton',
    ]) {
      final response = await client.get('/store/products?$query').send();
      response.assertOk();
      final view = ProductPageView.fromJson(
        response.json! as Map<String, Object?>,
      );
      expect(view.products.map((product) => product.handle), ['t-shirt']);
      expect(view.total, 1);
    }
  });

  test('unknown filters return an empty page without leaking drafts', () async {
    final response =
        await client.get('/store/products?category=unknown').send();

    response.assertOk();
    final view = ProductPageView.fromJson(
      response.json! as Map<String, Object?>,
    );
    expect(view.products, isEmpty);
    expect(view.total, 0);
  });
}
