import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('fulfillment choices require the Admin route guard', () async {
    (await harness.client.get('/admin/stock-locations').send())
        .assertUnauthorized();
    (await harness.client
            .get('/admin/shipping-options?stock_location_id=sloc_main&'
                'region_id=reg_eu')
            .send())
        .assertUnauthorized();
  });

  test('lists active stock locations with safe Medusa paging fields', () async {
    final request = harness.client.get('/admin/stock-locations?q=morrow')
      ..bearer(await harness.adminToken());

    final response = await request.send();

    response.assertOk();
    expect(response.json, {
      'stock_locations': [
        {'id': 'sloc_main', 'name': 'Morrow Warehouse'},
      ],
      'count': 1,
      'limit': 20,
      'offset': 0,
    });
  });

  test('lists only location and region compatible shipping methods', () async {
    final token = await harness.adminToken();
    final request = harness.client.get(
      '/admin/shipping-options?stock_location_id=sloc_main&region_id=reg_eu',
    )..bearer(token);

    final response = await request.send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body.keys, {'shipping_options', 'count', 'limit', 'offset'});
    expect(body['count'], 3);
    final options = body['shipping_options']! as List<Object?>;
    expect(
      options.map((row) => (row! as Map<String, Object?>).keys),
      everyElement({'id', 'name', 'shipping_profile_id'}),
    );
    expect(
      options.map((row) => (row! as Map<String, Object?>)['id']),
      ['ship_eu_express', 'ship_eu_free', 'ship_eu_standard'],
    );
    expect(
      options.map(
        (row) => (row! as Map<String, Object?>)['shipping_profile_id'],
      ),
      everyElement('sp_default'),
    );
  });

  test('rejects incomplete option scope and hides inactive resolution',
      () async {
    final token = await harness.adminToken();
    final missing = harness.client.get('/admin/shipping-options')
      ..bearer(token);
    (await missing.send()).assertBadRequest();

    await harness.raw("UPDATE shipping_option_shipping_profile "
        "SET deleted_at = created_at WHERE shipping_option_id = 'ship_eu_free'");
    final filtered = harness.client.get(
      '/admin/shipping-options?stock_location_id=sloc_main&region_id=reg_eu',
    )..bearer(token);
    final response = await filtered.send();
    response.assertOk();
    expect(
      (response.json! as Map<String, Object?>)['count'],
      2,
    );
  });
}
