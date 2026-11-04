import 'package:test/test.dart';

import 'order_detail_fixture.dart';
import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async {
    harness = await AdminHarness.start(seedStore: true);
    await seedOrderDetail(harness);
  });
  tearDown(() => harness.stop());

  test('order export requires the route-level admin bearer', () async {
    (await harness.client.get('/admin/orders/export').send())
        .assertUnauthorized();
  });

  test('exports every filtered item as an allowlisted CSV row', () async {
    await harness.raw('''
UPDATE order_items
SET title = 'Espresso, "cup"'
WHERE id = 'item_cup'
''');
    final token = await harness.adminToken();
    final request = harness.client.get(
      '/admin/orders/export?q=%231001&status=completed&order=display_id',
    )..bearer(token);

    final response = await request.send();

    response.assertOk();
    response.assertHeader('content-type', 'text/csv; charset=utf-8');
    response.assertHeader(
      'content-disposition',
      'attachment; filename="order-export.csv"',
    );
    final lines = response.body.trim().split('\r\n');
    expect(lines, hasLength(3));
    expect(lines.first, contains('Order Id,Display Id'));
    expect(lines.first, contains('Shipping Address 1'));
    expect(lines.first, contains('Payment Provider'));
    expect(response.body, contains('ord_detail,1001,completed,captured'));
    expect(response.body, contains('EUR,45.00,5.00,5.00,9.00,54.00'));
    expect(
      response.body,
      contains(',item_cup,"Espresso, ""cup""",Default,1,15.00,15.00,'),
    );
    expect(
      response.body,
      contains(',item_shirt,T-shirt,M / Black,2,15.00,30.00,'),
    );
    expect(response.body, contains(',manual,54.00,captured,'));
    expect(response.body, isNot(contains('cart_detail')));
    expect(response.body, isNot(contains('cus_ada')));
  });

  test('rejects export filters outside the order-list allowlist', () async {
    final token = await harness.adminToken();
    for (final query in [
      'status=deleted',
      'order=total',
      'region_id=bad%20id'
    ]) {
      final request = harness.client.get('/admin/orders/export?$query')
        ..bearer(token);
      (await request.send()).assertBadRequest();
    }
  });
}
