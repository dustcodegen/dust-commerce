import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('product type list requires a proven admin bearer', () async {
    (await harness.client.get('/admin/product-types').send())
        .assertUnauthorized();
  });

  test('product type list returns direct allowlisted rows and metadata',
      () async {
    final token = await harness.adminToken();
    final response = await (harness.client
            .get('/admin/product-types?q=shirt&limit=1&offset=0')
          ..bearer(token))
        .send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body['count'], 2);
    expect(body['limit'], 1);
    expect(body['offset'], 0);
    final rows = body['product_types']! as List<Object?>;
    expect(rows, hasLength(1));
    final first = rows.single! as Map<String, Object?>;
    expect(first.keys, {'id', 'value', 'created_at', 'updated_at'});
    expect(first['id'], 'ptyp_shirt');
    expect(first['value'], 'Shirt');
    expect(DateTime.parse(first['created_at']! as String).isUtc, isTrue);
    expect(DateTime.parse(first['updated_at']! as String).isUtc, isTrue);
  });
}
