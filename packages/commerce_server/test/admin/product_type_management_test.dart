import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('product type management requires a proven admin bearer', () async {
    final responses = await Future.wait([
      harness.client.get('/admin/product-types/ptyp_shirt').send(),
      (harness.client.post('/admin/product-types')..json(_body())).send(),
      (harness.client.patch('/admin/product-types/ptyp_shirt')..json(_body()))
          .send(),
      harness.client.delete('/admin/product-types/ptyp_shirt').send(),
    ]);

    for (final response in responses) {
      response.assertUnauthorized();
    }
  });

  test('creates and reads a trimmed direct product type response', () async {
    final token = await harness.adminToken();
    final created = await (harness.client.post('/admin/product-types')
          ..bearer(token)
          ..json(_body('  Accessories  ')))
        .send();

    created.assertCreated();
    final json = created.json! as Map<String, Object?>;
    expect(json.keys,
        unorderedEquals(['id', 'value', 'created_at', 'updated_at']));
    expect(json['value'], 'Accessories');
    expect(DateTime.parse(json['created_at']! as String).isUtc, isTrue);

    final read = await (harness.client.get('/admin/product-types/${json['id']}')
          ..bearer(token))
        .send();
    read.assertOk();
    expect(read.json, json);
  });

  test('duplicate or invalid values do not create rows', () async {
    final token = await harness.adminToken();
    final duplicate = await (harness.client.post('/admin/product-types')
          ..bearer(token)
          ..json(_body(' shirt ')))
        .send();
    final invalid = await (harness.client.post('/admin/product-types')
          ..bearer(token)
          ..json(_body('   ')))
        .send();

    duplicate.assertConflict();
    invalid.assertUnprocessable();
    final rows = await harness.raw(
      "SELECT count(*) FROM product_types WHERE lower(value) = 'shirt' "
      'AND deleted_at IS NULL',
    );
    expect(rows.single.readIndex<int>(0), 1);
  });

  test('updates value and lets SQLite generate the mutation timestamp',
      () async {
    await harness.raw(
      "UPDATE product_types SET updated_at = '2000-01-01T00:00:00.000Z' "
      "WHERE id = 'ptyp_shirt'",
    );
    final token = await harness.adminToken();
    final updated =
        await (harness.client.patch('/admin/product-types/ptyp_shirt')
              ..bearer(token)
              ..json(_body('  Tops  ')))
            .send();

    updated.assertOk();
    final json = updated.json! as Map<String, Object?>;
    expect(json['value'], 'Tops');
    expect(json['updated_at'], isNot('2000-01-01T00:00:00.000Z'));
  });

  test('conflicting and unknown updates leave the type unchanged', () async {
    final token = await harness.adminToken();
    final conflict =
        await (harness.client.patch('/admin/product-types/ptyp_shirt')
              ..bearer(token)
              ..json(_body(' Pants ')))
            .send();
    final missing =
        await (harness.client.patch('/admin/product-types/ptyp_missing')
              ..bearer(token)
              ..json(_body('Missing')))
            .send();

    conflict.assertConflict();
    missing.assertNotFound();
    final rows = await harness.raw(
      "SELECT value FROM product_types WHERE id = 'ptyp_shirt'",
    );
    expect(rows.single.readIndex<String>(0), 'Shirt');
  });

  test('soft deletion hides the type and its product assignment', () async {
    final token = await harness.adminToken();
    final deleted =
        await (harness.client.delete('/admin/product-types/ptyp_shirt')
              ..bearer(token))
            .send();

    deleted.assertNoContent();
    final missing = await (harness.client.get('/admin/product-types/ptyp_shirt')
          ..bearer(token))
        .send();
    missing.assertNotFound();
    final product = await (harness.client.get('/admin/products/prod_tshirt')
          ..bearer(token))
        .send();
    product.assertOk();
    expect((product.json! as Map<String, Object?>)['product_type'], isNull);
  });
}

Map<String, Object?> _body([String value = 'Accessories']) => {'value': value};
