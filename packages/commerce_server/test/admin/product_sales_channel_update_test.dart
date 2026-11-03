import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('sales-channel replacement requires a proven admin bearer', () async {
    final request = harness.client.put(
      '/admin/products/prod_tshirt/sales-channels',
    )..json({
        'sales_channel_ids': ['sc_wholesale']
      });

    (await request.send()).assertUnauthorized();
  });

  test('replacement is atomic and immediately updates product reads', () async {
    final token = await harness.adminToken();
    final request = harness.client.put(
      '/admin/products/prod_tshirt/sales-channels',
    )
      ..bearer(token)
      ..json({
        'sales_channel_ids': ['sc_wholesale']
      });

    final response = await request.send();

    response.assertOk();
    expect(_channelIds(response.json!), ['sc_wholesale']);
    final detail = harness.client.get(
      '/admin/products/prod_tshirt/sales-channels',
    )..bearer(token);
    expect(_channelIds((await detail.send()).json!), ['sc_wholesale']);
    final list = harness.client.get(
      '/admin/products?q=t-shirt&limit=20&offset=0',
    )..bearer(token);
    final listBody = (await list.send()).json! as Map<String, Object?>;
    final product = (listBody['products']! as List<Object?>).single!
        as Map<String, Object?>;
    expect(product['sales_channels'], [
      {'id': 'sc_wholesale', 'name': 'Wholesale'},
    ]);
    final links = await harness.raw('''
SELECT sales_channel_id, deleted_at IS NULL, created_at, updated_at
FROM product_sales_channels
WHERE product_id = 'prod_tshirt'
ORDER BY sales_channel_id
''');
    expect(links, hasLength(2));
    expect(links.first.readIndex<String>(0), 'sc_web');
    expect(links.first.readIndex<bool>(1), isFalse);
    expect(links.last.readIndex<String>(0), 'sc_wholesale');
    expect(links.last.readIndex<bool>(1), isTrue);
    expect(links.last.readIndex<DateTime>(2), isNotNull);
    expect(links.last.readIndex<DateTime>(3), isNotNull);
  });

  test('empty selection removes every active product channel', () async {
    final token = await harness.adminToken();
    final request = harness.client.put(
      '/admin/products/prod_tshirt/sales-channels',
    )
      ..bearer(token)
      ..json({'sales_channel_ids': <String>[]});

    final response = await request.send();

    response.assertOk();
    expect(_channelIds(response.json!), isEmpty);
    final links = await harness.raw('''
SELECT count(*)
FROM product_sales_channels
WHERE product_id = 'prod_tshirt' AND deleted_at IS NULL
''');
    expect(links.single.readIndex<int>(0), 0);
  });

  test('invalid channel selections roll back without partial writes', () async {
    final token = await harness.adminToken();
    for (final ids in [
      ['sc_wholesale', 'sc_wholesale'],
      ['sc_wholesale', 'sc_missing'],
    ]) {
      final request = harness.client.put(
        '/admin/products/prod_tshirt/sales-channels',
      )
        ..bearer(token)
        ..json({'sales_channel_ids': ids});
      (await request.send()).assertUnprocessable();
    }
    final links = await harness.raw('''
SELECT sales_channel_id
FROM product_sales_channels
WHERE product_id = 'prod_tshirt' AND deleted_at IS NULL
''');
    expect(links.single.readIndex<String>(0), 'sc_web');
  });

  test('unknown product cannot receive sales-channel links', () async {
    final token = await harness.adminToken();
    final request = harness.client.put('/admin/products/missing/sales-channels')
      ..bearer(token)
      ..json({
        'sales_channel_ids': ['sc_web']
      });

    (await request.send()).assertNotFound();
  });
}

List<String> _channelIds(Object json) {
  final body = json as Map<String, Object?>;
  return [
    for (final item in body['sales_channels']! as List<Object?>)
      (item! as Map<String, Object?>)['id']! as String,
  ];
}
