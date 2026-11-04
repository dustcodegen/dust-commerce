import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('stock mutation requires a proven admin bearer', () async {
    final response = await (harness.client.put(
      '/admin/products/prod_sweatpants/stock',
    )..json(_stock()))
        .send();

    response.assertUnauthorized();
  });

  test('batch stock update is atomic and visible to the storefront', () async {
    await harness.raw(
      "UPDATE product_variants SET updated_at = '2000-01-01T00:00:00.000Z' "
      "WHERE id = 'var_sweatpants_s'",
    );
    final token = await harness.adminToken();
    final response = await (harness.client.put(
      '/admin/products/prod_sweatpants/stock',
    )
          ..bearer(token)
          ..json(_stock(quantity: 7, managed: false)))
        .send();

    response.assertOk();
    final variant = _variant(response.json!, 'var_sweatpants_s');
    expect(variant['inventory_quantity'], 7);
    expect(variant['manage_inventory'], isFalse);
    final stored = await harness.raw(
      'SELECT updated_at FROM product_variants '
      "WHERE id = 'var_sweatpants_s'",
    );
    expect(
      stored.single.readIndex<DateTime>(0).toUtc(),
      isNot(DateTime.parse('2000-01-01T00:00:00.000Z')),
    );

    final storefront = await harness.client
        .get('/store/products/sweatpants?currency=eur')
        .send();
    expect(
        _variant(storefront.json!, 'var_sweatpants_s'),
        containsPair(
          'inventory_quantity',
          7,
        ));
  });

  test('invalid stock selections do not write any row', () async {
    final token = await harness.adminToken();
    final invalid = [
      {
        'variants': [
          {
            'id': 'var_sweatpants_s',
            'inventory_quantity': -1,
            'manage_inventory': true,
          },
        ],
      },
      {
        'variants': [
          {
            'id': 'var_sweatpants_s',
            'inventory_quantity': 7,
            'manage_inventory': true,
          },
          {
            'id': 'var_sweatpants_s',
            'inventory_quantity': 8,
            'manage_inventory': false,
          },
        ],
      },
    ];

    for (final body in invalid) {
      final response = await (harness.client.put(
        '/admin/products/prod_sweatpants/stock',
      )
            ..bearer(token)
            ..json(body))
          .send();
      response.assertUnprocessable();
    }
    final rows = await harness.raw(
      "SELECT inventory_quantity, manage_inventory FROM product_variants "
      "WHERE id = 'var_sweatpants_s'",
    );
    expect(rows.single.readIndex<int>(0), 20);
    expect(rows.single.readIndex<int>(1), 1);
  });

  test('unknown variants roll back every submitted stock change', () async {
    final token = await harness.adminToken();
    final response = await (harness.client.put(
      '/admin/products/prod_sweatpants/stock',
    )
          ..bearer(token)
          ..json({
            'variants': [
              {
                'id': 'var_sweatpants_s',
                'inventory_quantity': 7,
                'manage_inventory': true,
              },
              {
                'id': 'var_tshirt_s_black',
                'inventory_quantity': 8,
                'manage_inventory': true,
              },
            ],
          }))
        .send();

    response.assertNotFound();
    final rows = await harness.raw(
      "SELECT inventory_quantity FROM product_variants "
      "WHERE id = 'var_sweatpants_s'",
    );
    expect(rows.single.readIndex<int>(0), 20);
  });
}

Map<String, Object?> _stock({int quantity = 20, bool managed = true}) => {
      'variants': [
        {
          'id': 'var_sweatpants_s',
          'inventory_quantity': quantity,
          'manage_inventory': managed,
        },
      ],
    };

Map<String, Object?> _variant(Object? json, String id) =>
    ((json! as Map<String, Object?>)['variants']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .singleWhere((variant) => variant['id'] == id);
