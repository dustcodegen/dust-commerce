import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('shipping profile management requires a proven admin bearer', () async {
    final responses = await Future.wait([
      harness.client.get('/admin/shipping-profiles/sp_default').send(),
      (harness.client.post('/admin/shipping-profiles')..json(_body())).send(),
      harness.client.delete('/admin/shipping-profiles/sp_default').send(),
    ]);

    for (final response in responses) {
      response.assertUnauthorized();
    }
  });

  test('creates and reads a trimmed direct profile response', () async {
    final token = await harness.adminToken();
    final created = await (harness.client.post('/admin/shipping-profiles')
          ..bearer(token)
          ..json(_body(name: '  Fragile Goods  ', type: '  fragile  ')))
        .send();

    created.assertCreated();
    final json = created.json! as Map<String, Object?>;
    expect(
      json.keys,
      unorderedEquals(['id', 'name', 'type', 'created_at', 'updated_at']),
    );
    expect(json['name'], 'Fragile Goods');
    expect(json['type'], 'fragile');
    expect(DateTime.parse(json['created_at']! as String).isUtc, isTrue);

    final read =
        await (harness.client.get('/admin/shipping-profiles/${json['id']}')
              ..bearer(token))
            .send();
    read.assertOk();
    expect(read.json, json);
  });

  test('duplicate or invalid profiles do not create rows', () async {
    final token = await harness.adminToken();
    final duplicate = await (harness.client.post('/admin/shipping-profiles')
          ..bearer(token)
          ..json(_body(name: ' default shipping profile ')))
        .send();
    final invalid = await (harness.client.post('/admin/shipping-profiles')
          ..bearer(token)
          ..json(_body(type: '   ')))
        .send();

    duplicate.assertConflict();
    invalid.assertUnprocessable();
    final rows = await harness.raw(
      "SELECT count(*) FROM shipping_profile WHERE lower(name) = "
      "'default shipping profile' AND deleted_at IS NULL",
    );
    expect(rows.single.readIndex<int>(0), 1);
  });

  test('soft deletion hides the profile and its product assignment', () async {
    final token = await harness.adminToken();
    final deleted =
        await (harness.client.delete('/admin/shipping-profiles/sp_default')
              ..bearer(token))
            .send();

    deleted.assertNoContent();
    final missing =
        await (harness.client.get('/admin/shipping-profiles/sp_default')
              ..bearer(token))
            .send();
    missing.assertNotFound();
    final product = await (harness.client.get('/admin/products/prod_tshirt')
          ..bearer(token))
        .send();
    product.assertOk();
    expect((product.json! as Map<String, Object?>)['shipping_profile'], isNull);
    final links = await harness.raw('''
SELECT count(*) FROM product_shipping_profile
WHERE shipping_profile_id = 'sp_default' AND deleted_at IS NULL
''');
    expect(links.single.readIndex<int>(0), 0);
  });

  test('deleting an unknown profile is not idempotent success', () async {
    final token = await harness.adminToken();
    final response =
        await (harness.client.delete('/admin/shipping-profiles/sp_missing')
              ..bearer(token))
            .send();

    response.assertNotFound();
  });
}

Map<String, Object?> _body({
  String name = 'Fragile Goods',
  String type = 'fragile',
}) =>
    {'name': name, 'type': type};
