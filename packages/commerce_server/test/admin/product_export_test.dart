import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('product export requires the route-level admin bearer', () async {
    (await harness.client.get('/admin/products/export').send())
        .assertUnauthorized();
  });

  test('exports the filtered multi-axis product as Medusa-shaped CSV',
      () async {
    final token = await harness.adminToken();
    final request = harness.client.get(
      '/admin/products/export?q=t-shirt&type_id=ptyp_shirt&order=title',
    )..bearer(token);

    final response = await request.send();

    response.assertOk();
    response.assertHeader('content-type', 'text/csv; charset=utf-8');
    response.assertHeader(
      'content-disposition',
      'attachment; filename="product-export.csv"',
    );
    final lines = response.body.trim().split('\n');
    expect(lines, hasLength(9));
    expect(lines.first, contains('Variant Price EUR'));
    expect(lines.first, contains('Variant Option 2 Value'));
    expect(lines.first, contains('Product Image 4 Url'));
    expect(response.body, contains('prod_tshirt,t-shirt,Essential T-Shirt'));
    expect(response.body, contains('S / Black'));
    expect(response.body, contains(',10.00,15.00,Size,S,Color,Black,'));
    expect(response.body, isNot(contains('prod_sweatpants')));
  });
}
