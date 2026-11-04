import 'package:test/test.dart';

import 'product_import_fixture.dart';
import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('development products belong to the Online Store channel', () async {
    final rows = await harness.raw('''
SELECT product_id, sales_channel_id
FROM product_sales_channels
ORDER BY product_id
''');

    expect(rows, hasLength(4));
    expect(
      rows.map((row) => row.readIndex<String>(1)).toSet(),
      {'sc_web'},
    );
  });

  test('admin product creation links the default active channel', () async {
    final token = await harness.adminToken();
    final request = harness.client.post('/admin/products')
      ..bearer(token)
      ..json(_productBody());

    final response = await request.send();

    response.assertOk();
    final links = await harness.raw('''
SELECT channel.id, channel.name
FROM product_sales_channels link
JOIN products product ON product.id = link.product_id
JOIN sales_channels channel ON channel.id = link.sales_channel_id
WHERE product.handle = 'channel-cap'
''');
    expect(links.single.readIndex<String>(0), 'sc_web');
    expect(links.single.readIndex<String>(1), 'Online Store');
  });

  test('new imported products link the default active channel', () async {
    final token = await harness.adminToken();
    final transactionId = await previewProductImport(
      harness,
      token,
      newOnlyProductImportCsv,
    );
    final request = harness.client.post(
      '/admin/products/import/$transactionId/confirm',
    )..bearer(token);

    (await request.send()).assertStatus(202);

    final links = await harness.raw('''
SELECT link.sales_channel_id
FROM product_sales_channels link
JOIN products product ON product.id = link.product_id
WHERE product.handle = 'imported-cap'
''');
    expect(links.single.readIndex<String>(0), 'sc_web');
  });
}

Map<String, Object?> _productBody() => {
      'title': 'Channel Cap',
      'handle': 'channel-cap',
      'discountable': true,
      'status': 'published',
      'media': [],
      'options': [
        {
          'title': 'Size',
          'values': ['One size'],
        },
      ],
      'variants': [
        {
          'title': 'One size',
          'sku': 'CHANNEL-CAP',
          'inventory_quantity': 5,
          'manage_inventory': true,
          'allow_backorder': false,
          'option_values': {'Size': 'One size'},
          'prices': [
            {'currency_code': 'eur', 'amount': 1000},
            {'currency_code': 'usd', 'amount': 1500},
          ],
        },
      ],
    };
