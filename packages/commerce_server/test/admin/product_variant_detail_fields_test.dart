import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('complete variant detail changes admin and storefront readback',
      () async {
    await harness.raw(
      "INSERT INTO product_product_option_values "
      "(id, product_product_option_id, product_option_value_id) "
      "VALUES ('prodoptval_sweatpants_size_l', "
      "'prodopt_sweatpants_size', 'optval_size_l')",
    );
    await harness.raw(
      "UPDATE product_variants SET updated_at = '2000-01-01T00:00:00.000Z' "
      "WHERE id = 'var_sweatpants_s'",
    );
    final token = await harness.adminToken();
    final request = harness.client.patch(
      '/admin/products/prod_sweatpants/variants/var_sweatpants_s',
    )
      ..bearer(token)
      ..json(_body());

    final response = await request.send();

    response.assertOk();
    final variant = _variant(
      response.json! as Map<String, Object?>,
      'var_sweatpants_s',
    );
    expect(variant, containsPair('title', 'Large / Limited'));
    expect(variant, containsPair('sku', 'SWEATPANTS-LIMITED'));
    expect(variant, containsPair('material', 'Organic cotton'));
    expect(variant, containsPair('ean', '4006381333931'));
    expect(variant, containsPair('upc', '012345678905'));
    expect(variant, containsPair('barcode', '0123456789012'));
    expect(variant, containsPair('weight', 400.5));
    expect(variant, containsPair('width', 30.25));
    expect(variant, containsPair('length', 2.5));
    expect(variant, containsPair('height', 40.75));
    expect(variant, containsPair('mid_code', 'MMABC1234'));
    expect(variant, containsPair('hs_code', '610910'));
    expect(variant, containsPair('origin_country', 'dk'));
    expect(variant, containsPair('manage_inventory', false));
    expect(variant, containsPair('allow_backorder', true));
    expect(variant, containsPair('inventory_quantity', 20));
    expect(
      variant,
      containsPair('option_values', {'opt_size': 'L'}),
    );

    final stored = await harness.raw(
      "SELECT title, sku, material, ean, upc, barcode, weight, width, "
      "length, height, mid_code, hs_code, origin_country, manage_inventory, "
      "allow_backorder, inventory_quantity, updated_at FROM product_variants "
      "WHERE id = 'var_sweatpants_s'",
    );
    expect(stored.single.readIndex<String>(0), 'Large / Limited');
    expect(stored.single.readIndex<String>(1), 'SWEATPANTS-LIMITED');
    expect(stored.single.readIndex<String>(2), 'Organic cotton');
    expect(stored.single.readIndex<String>(3), '4006381333931');
    expect(stored.single.readIndex<String>(4), '012345678905');
    expect(stored.single.readIndex<String>(5), '0123456789012');
    expect(stored.single.readIndex<double>(6), 400.5);
    expect(stored.single.readIndex<double>(7), 30.25);
    expect(stored.single.readIndex<double>(8), 2.5);
    expect(stored.single.readIndex<double>(9), 40.75);
    expect(stored.single.readIndex<String>(10), 'MMABC1234');
    expect(stored.single.readIndex<String>(11), '610910');
    expect(stored.single.readIndex<String>(12), 'dk');
    expect(stored.single.readIndex<int>(13), 0);
    expect(stored.single.readIndex<int>(14), 1);
    expect(stored.single.readIndex<int>(15), 20);
    expect(
      stored.single.readIndex<DateTime>(16).toUtc(),
      isNot(DateTime.utc(2000)),
    );

    final storefront = await harness.client
        .get('/store/products/sweatpants?currency=usd')
        .send();
    storefront.assertOk();
    final publicVariant = _variant(
      storefront.json! as Map<String, Object?>,
      'var_sweatpants_s',
    );
    expect(publicVariant, containsPair('title', 'Large / Limited'));
    expect(
      publicVariant,
      containsPair('option_values', {'opt_size': 'L'}),
    );
  });
}

Map<String, Object?> _body() => {
      'title': '  Large / Limited  ',
      'sku': '  SWEATPANTS-LIMITED  ',
      'material': '  Organic cotton  ',
      'ean': '  4006381333931  ',
      'upc': '  012345678905  ',
      'barcode': '  0123456789012  ',
      'manage_inventory': false,
      'allow_backorder': true,
      'option_values': {'opt_size': 'L'},
      'weight': 400.5,
      'width': 30.25,
      'length': 2.5,
      'height': 40.75,
      'mid_code': '  MMABC1234  ',
      'hs_code': '  610910  ',
      'origin_country': '  DK  ',
    };

Map<String, Object?> _variant(Map<String, Object?> product, String id) =>
    (product['variants']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .singleWhere((variant) => variant['id'] == id);
