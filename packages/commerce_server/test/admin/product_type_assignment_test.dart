import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('creates a product with a stable active type assignment', () async {
    final token = await harness.adminToken();
    final request = harness.client.post('/admin/products')
      ..bearer(token)
      ..json(_body(typeId: 'ptyp_shirt'));

    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    expect(json['product_type_id'], 'ptyp_shirt');
    expect(json['product_type'], 'Shirt');
    final storefront = await harness.client
        .get('/store/products/canvas-tote?currency=usd')
        .send();
    storefront.assertOk();
    final product = Product.fromJson(
      storefront.json! as Map<String, Object?>,
    );
    expect(product.details.productType, 'Shirt');
  });

  test('rejects an unknown product type without creating a product', () async {
    final token = await harness.adminToken();
    final request = harness.client.post('/admin/products')
      ..bearer(token)
      ..json(_body(typeId: 'ptyp_missing'));

    (await request.send()).assertUnprocessable();

    final stored = await harness.raw(
      "SELECT count(*) FROM products WHERE handle = 'canvas-tote'",
    );
    expect(stored.single.readIndex<int>(0), 0);
  });

  test('replaces and clears a product type without changing other fields',
      () async {
    final token = await harness.adminToken();
    final assign =
        harness.client.patch('/admin/products/prod_sweatpants/organization')
          ..bearer(token)
          ..json({'type_id': 'ptyp_shirt'});

    final assigned = await assign.send();

    assigned.assertOk();
    final assignedJson = assigned.json! as Map<String, Object?>;
    expect(assignedJson['product_type_id'], 'ptyp_shirt');
    expect(assignedJson['product_type'], 'Shirt');
    expect(assignedJson['title'], 'Relaxed Sweatpants');

    final clear =
        harness.client.patch('/admin/products/prod_sweatpants/organization')
          ..bearer(token)
          ..json({'type_id': null});
    final cleared = await clear.send();
    cleared.assertOk();
    final clearedJson = cleared.json! as Map<String, Object?>;
    expect(clearedJson['product_type_id'], isNull);
    expect(clearedJson['product_type'], isNull);
    expect(clearedJson['handle'], 'sweatpants');
  });

  test('organization replacement requires auth and an active type', () async {
    final unauthorized = harness.client
        .patch('/admin/products/prod_sweatpants/organization')
      ..json({'type_id': 'ptyp_shirt'});
    (await unauthorized.send()).assertUnauthorized();

    final token = await harness.adminToken();
    final invalid =
        harness.client.patch('/admin/products/prod_sweatpants/organization')
          ..bearer(token)
          ..json({'type_id': 'ptyp_missing'});
    (await invalid.send()).assertUnprocessable();

    final stored = await harness.raw(
      "SELECT type_id FROM products WHERE id = 'prod_sweatpants'",
    );
    expect(stored.single.readIndexNullable<String>(0), 'ptyp_pants');
  });
}

Map<String, Object?> _body({required String typeId}) => {
      'title': 'Canvas Tote',
      'handle': 'canvas-tote',
      'type_id': typeId,
      'discountable': true,
      'status': 'published',
      'media': [],
      'options': [
        {
          'title': 'Color',
          'values': ['Black'],
        },
      ],
      'variants': [
        {
          'title': 'Black',
          'sku': 'TOTE-BLACK',
          'inventory_quantity': 12,
          'manage_inventory': true,
          'allow_backorder': false,
          'option_values': {'Color': 'Black'},
          'prices': [
            {'currency_code': 'eur', 'amount': 2300},
            {'currency_code': 'usd', 'amount': 2500},
          ],
        },
      ],
    };
