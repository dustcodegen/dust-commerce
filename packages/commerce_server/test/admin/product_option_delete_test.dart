import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('product option deletion requires a proven admin bearer', () async {
    final response =
        await harness.client.delete('/admin/product-options/opt_size').send();

    response.assertUnauthorized();
  });

  test('unused option and its values are soft deleted atomically', () async {
    final token = await harness.adminToken();
    final created = await (harness.client.post('/admin/product-options')
          ..bearer(token)
          ..json({
            'title': 'Material',
            'values': ['Cotton', 'Linen'],
          }))
        .send();
    created.assertCreated();
    final id = (created.json! as Map<String, Object?>)['id']! as String;

    final deleted = await (harness.client.delete('/admin/product-options/$id')
          ..bearer(token))
        .send();

    deleted.assertNoContent();
    (await (harness.client.get('/admin/product-options/$id')..bearer(token))
            .send())
        .assertNotFound();
    final rows = await harness.raw(
      'SELECT option.deleted_at, value.deleted_at '
      'FROM product_options option '
      'JOIN product_option_values value ON value.option_id = option.id '
      "WHERE option.id = '$id'",
    );
    expect(rows, hasLength(2));
    expect(rows.every((row) => row.readIndex<DateTime?>(0) != null), isTrue);
    expect(rows.every((row) => row.readIndex<DateTime?>(1) != null), isTrue);
  });

  test('linked and missing product options are not deleted', () async {
    final token = await harness.adminToken();
    final linked =
        await (harness.client.delete('/admin/product-options/opt_size')
              ..bearer(token))
            .send();
    final missing =
        await (harness.client.delete('/admin/product-options/opt_missing')
              ..bearer(token))
            .send();

    linked.assertConflict();
    missing.assertNotFound();
    (await (harness.client.get('/admin/product-options/opt_size')
              ..bearer(token))
            .send())
        .assertOk();
  });
}
