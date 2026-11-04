import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('product deletion requires a proven admin bearer', () async {
    final response =
        await harness.client.delete('/admin/products/prod_sweatpants').send();

    response.assertUnauthorized();
  });

  test('soft delete hides the product and preserves historical rows', () async {
    await harness.raw(
      "INSERT INTO product_options (id, title, is_exclusive) "
      "VALUES ('opt_sweatpants_fit', 'Fit', 1)",
    );
    await harness.raw(
      'INSERT INTO product_option_values (id, option_id, value) '
      "VALUES ('optval_sweatpants_fit', 'opt_sweatpants_fit', 'Relaxed')",
    );
    await harness.raw(
      'INSERT INTO product_product_options '
      '(id, product_id, product_option_id) VALUES '
      "('prodopt_sweatpants_fit', 'prod_sweatpants', "
      "'opt_sweatpants_fit')",
    );
    await harness.raw(
      'INSERT INTO product_product_option_values '
      '(id, product_product_option_id, product_option_value_id) VALUES '
      "('prodoptval_sweatpants_fit', 'prodopt_sweatpants_fit', "
      "'optval_sweatpants_fit')",
    );
    await harness.raw(
      "UPDATE products SET updated_at = '2000-01-01T00:00:00.000Z' "
      "WHERE id = 'prod_sweatpants'",
    );
    final token = await harness.adminToken();
    final response = await (harness.client.delete(
      '/admin/products/prod_sweatpants',
    )..bearer(token))
        .send();

    response.assertOk();
    expect(response.json, {
      'id': 'prod_sweatpants',
      'object': 'product',
      'deleted': true,
    });
    (await (harness.client.get('/admin/products/prod_sweatpants')
              ..bearer(token))
            .send())
        .assertNotFound();
    (await harness.client.get('/store/products/sweatpants?currency=eur').send())
        .assertNotFound();

    final product = await harness.raw(
      'SELECT deleted_at, updated_at FROM products '
      "WHERE id = 'prod_sweatpants'",
    );
    expect(product.single.readIndex<DateTime>(0).toUtc().isUtc, isTrue);
    expect(
      product.single.readIndex<DateTime>(1).toUtc(),
      isNot(DateTime.utc(2000)),
    );
    final variants = await harness.raw(
      'SELECT count(*), count(deleted_at) FROM product_variants '
      "WHERE product_id = 'prod_sweatpants'",
    );
    expect(variants.single.readIndex<int>(0), 2);
    expect(variants.single.readIndex<int>(1), 2);
    final prices = await harness.raw(
      'SELECT count(*) FROM variant_prices price '
      'JOIN product_variants variant ON variant.id = price.variant_id '
      "WHERE variant.product_id = 'prod_sweatpants'",
    );
    expect(prices.single.readIndex<int>(0), 4);
    final links = await harness.raw(
      'SELECT count(*), count(deleted_at) FROM product_product_options '
      "WHERE product_id = 'prod_sweatpants'",
    );
    expect(links.single.readIndex<int>(0), 2);
    expect(links.single.readIndex<int>(1), 2);
    final linkValues = await harness.raw(
      'SELECT count(*), count(link_value.deleted_at) '
      'FROM product_product_option_values link_value '
      'JOIN product_product_options link '
      'ON link.id = link_value.product_product_option_id '
      "WHERE link.product_id = 'prod_sweatpants'",
    );
    expect(linkValues.single.readIndex<int>(0), 3);
    expect(linkValues.single.readIndex<int>(1), 3);
    final exclusive = await harness.raw(
      'SELECT option.deleted_at, value.deleted_at '
      'FROM product_options option '
      'JOIN product_option_values value ON value.option_id = option.id '
      "WHERE option.id = 'opt_sweatpants_fit'",
    );
    expect(exclusive.single.readIndex<DateTime>(0).toUtc().isUtc, isTrue);
    expect(exclusive.single.readIndex<DateTime>(1).toUtc().isUtc, isTrue);
    final global = await harness.raw(
      "SELECT deleted_at FROM product_options WHERE id = 'opt_size'",
    );
    expect(global.single.readIndexNullable<DateTime>(0), isNull);
  });

  test('deletion releases active handles and SKUs without erasing rows',
      () async {
    final token = await harness.adminToken();
    final response = await (harness.client.delete(
      '/admin/products/prod_sweatpants',
    )..bearer(token))
        .send();
    response.assertOk();

    await harness.raw(
      "INSERT INTO products (id, title, handle) "
      "VALUES ('prod_replacement', 'Replacement', 'sweatpants')",
    );
    await harness.raw(
      'INSERT INTO product_variants (id, product_id, title, sku) '
      "VALUES ('var_replacement', 'prod_replacement', 'Default', "
      "'SWEATPANTS-S')",
    );
    final rows = await harness.raw(
      "SELECT count(*) FROM product_variants WHERE sku = 'SWEATPANTS-S'",
    );
    expect(rows.single.readIndex<int>(0), 2);
  });

  test('an already deleted or unknown product is not found', () async {
    final token = await harness.adminToken();
    final first = await (harness.client.delete(
      '/admin/products/prod_sweatpants',
    )..bearer(token))
        .send();
    first.assertOk();

    final repeated = await (harness.client.delete(
      '/admin/products/prod_sweatpants',
    )..bearer(token))
        .send();
    repeated.assertNotFound();
    final unknown = await (harness.client.delete(
      '/admin/products/prod_missing',
    )..bearer(token))
        .send();
    unknown.assertNotFound();
  });
}
