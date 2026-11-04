import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async {
    harness = await AdminHarness.start(seedStore: true);
    await harness.raw(r'''
UPDATE sales_channels SET is_disabled = 1 WHERE id = 'sc_wholesale'
''');
  });
  tearDown(() => harness.stop());

  test('sales channel discovery requires a proven admin bearer', () async {
    (await harness.client.get('/admin/sales-channels').send())
        .assertUnauthorized();
  });

  test('sales channel discovery returns ordered Medusa editor fields',
      () async {
    final token = await harness.adminToken();
    final response =
        await (harness.client.get('/admin/sales-channels?limit=1000&offset=0')
              ..bearer(token))
            .send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body, containsPair('count', 2));
    expect(body, containsPair('limit', 1000));
    expect(body, containsPair('offset', 0));
    final channels = body['sales_channels']! as List<Object?>;
    final online = channels.first! as Map<String, Object?>;
    final wholesale = channels.last! as Map<String, Object?>;
    expect(online.keys.toSet(), {
      'id',
      'name',
      'description',
      'is_disabled',
      'created_at',
      'updated_at',
    });
    expect(online, containsPair('id', 'sc_web'));
    expect(online, containsPair('name', 'Online Store'));
    expect(
      online,
      containsPair('description', 'Primary direct-to-consumer storefront'),
    );
    expect(online, containsPair('is_disabled', false));
    expect(DateTime.parse(online['created_at']! as String).isUtc, isTrue);
    expect(DateTime.parse(online['updated_at']! as String).isUtc, isTrue);
    expect(wholesale, containsPair('id', 'sc_wholesale'));
    expect(wholesale, containsPair('is_disabled', true));
  });

  test('sales channel discovery searches before bounded paging', () async {
    final token = await harness.adminToken();
    final response =
        await (harness.client.get('/admin/sales-channels?q=WHOLE&limit=5000')
              ..bearer(token))
            .send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body, containsPair('count', 1));
    expect(body, containsPair('limit', 1000));
    final channels = body['sales_channels']! as List<Object?>;
    expect(channels, hasLength(1));
    expect(
      channels.single! as Map<String, Object?>,
      containsPair('id', 'sc_wholesale'),
    );
  });

  test('product sales channels require a proven admin bearer', () async {
    final response = await harness.client
        .get('/admin/products/prod_tshirt/sales-channels')
        .send();

    response.assertUnauthorized();
  });

  test('product sales channels return only the attached explicit rows',
      () async {
    final token = await harness.adminToken();
    final response =
        await (harness.client.get('/admin/products/prod_tshirt/sales-channels')
              ..bearer(token))
            .send();

    response.assertOk();
    expect(response.json, {
      'sales_channels': [
        {'id': 'sc_web', 'name': 'Online Store'},
      ],
      'count': 1,
      'limit': 1,
      'offset': 0,
    });
  });

  test('product sales channels hide an unknown product', () async {
    final token = await harness.adminToken();
    final response =
        await (harness.client.get('/admin/products/prod_missing/sales-channels')
              ..bearer(token))
            .send();

    response.assertNotFound();
  });
}
