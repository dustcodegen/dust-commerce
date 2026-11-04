import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('variant update requires a proven admin bearer', () async {
    final request = harness.client.patch(
      '/admin/products/prod_sweatpants/variants/var_sweatpants_s',
    )..json(_body());

    (await request.send()).assertUnauthorized();
  });

  test('duplicate SKU is a conflict and leaves the variant unchanged',
      () async {
    final token = await harness.adminToken();
    final request = harness.client.patch(
      '/admin/products/prod_sweatpants/variants/var_sweatpants_s',
    )
      ..bearer(token)
      ..json(_body(title: 'Must not persist', sku: 'SWEATPANTS-M'));

    (await request.send()).assertConflict();
    final stored = await harness.raw(
      "SELECT title, sku FROM product_variants "
      "WHERE id = 'var_sweatpants_s'",
    );
    expect(stored.single.readIndex<String>(0), 'S');
    expect(stored.single.readIndex<String>(1), 'SWEATPANTS-S');
  });

  test('duplicate option selection is rejected before persistence', () async {
    final token = await harness.adminToken();
    final request = harness.client.patch(
      '/admin/products/prod_sweatpants/variants/var_sweatpants_s',
    )
      ..bearer(token)
      ..json(_body(title: 'Must not persist', size: 'M'));

    (await request.send()).assertUnprocessable();
    final stored = await harness.raw(
      "SELECT title FROM product_variants WHERE id = 'var_sweatpants_s'",
    );
    expect(stored.single.readIndex<String>(0), 'S');
  });

  test('variant must belong to the product in the route', () async {
    final token = await harness.adminToken();
    final request = harness.client.patch(
      '/admin/products/prod_sweatpants/variants/var_tshirt_s_black',
    )
      ..bearer(token)
      ..json(_body());

    (await request.send()).assertNotFound();
  });
}

Map<String, Object?> _body({
  String title = 'S',
  String? sku = 'SWEATPANTS-S',
  bool manageInventory = true,
  bool allowBackorder = false,
  String size = 'S',
}) =>
    {
      'title': title,
      'sku': sku,
      'manage_inventory': manageInventory,
      'allow_backorder': allowBackorder,
      'option_values': {'opt_size': size},
    };
