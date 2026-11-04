import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import 'list_support.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  CatalogReadRepository reads() => CatalogReadRepository(database.executor);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_repo_read');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedCatalogList(database);
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('findByHandle returns the complete published product', () async {
    final row = ok(await reads().findByHandle('t-shirt', 'usd'));

    expect(row?.title, 'T-Shirt');
    expect(row?.status, 'published');
    expect(row?.variants.map((variant) => variant.id), [
      'var_large',
      'var_small',
    ]);
    expect(row?.variants.map((variant) => variant.prices.single.amount), [
      2199,
      1999,
    ]);
    expect(row?.images.map((image) => image.url), [
      'https://example.test/front.png',
      'https://example.test/back.png',
    ]);
    expect(
      row?.variants
          .singleWhere((variant) => variant.id == 'var_large')
          .images
          .map((image) => image.id),
      ['img_front'],
    );
  });

  test('findByHandle hides draft and unknown handles', () async {
    expect(ok(await reads().findByHandle('secret-hoodie', 'usd')), isNull);
    expect(ok(await reads().findByHandle('nothing', 'usd')), isNull);
  });

  test('findByHandle hides products outside the storefront channel', () async {
    await _run(
      database,
      "INSERT INTO sales_channels (id, name) VALUES "
      "('sc_web', 'Online Store'), ('sc_wholesale', 'Wholesale')",
    );
    await _run(
      database,
      "INSERT INTO product_sales_channels "
      "(id, product_id, sales_channel_id) VALUES "
      "('psc_shirt', 'prod_shirt', 'sc_web'), "
      "('psc_mug', 'prod_mug', 'sc_wholesale')",
    );

    expect(ok(await reads().findByHandle('t-shirt', 'usd'))?.id, 'prod_shirt');
    expect(ok(await reads().findByHandle('mug', 'usd')), isNull);
  });

  test('findVariant scopes variant reads to the requested currency', () async {
    final row = ok(await reads().findVariantForCart(
      'var_small',
      'usd',
      'legacy_cart',
    ));

    expect(row?.amount, 1999);
    expect(row?.inventoryQuantity, 5);
    expect(
      ok(await reads().findVariantForCart('var_large', 'eur', 'legacy_cart')),
      isNull,
    );
  });
}

Future<void> _run(CommerceDatabase database, String sql) =>
    queryExecute(sql, const []).execute(database.executor);
