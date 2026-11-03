import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async {
    harness = await AdminHarness.start(seedStore: true);
    await queryExecute(
      "INSERT INTO shipping_profile (id, name, type) "
      "VALUES ('sp_fragile', 'Fragile', 'fragile')",
      [],
    ).execute(harness.database.executor);
  });
  tearDown(() => harness.stop());

  test('assignment replacement requires a proven Admin bearer', () async {
    final request = harness.client.patch(
      '/admin/products/prod_tshirt/shipping-profile',
    )..json({'shipping_profile_id': 'sp_fragile'});

    (await request.send()).assertUnauthorized();
  });

  test('replaces the scalar profile and refreshes product detail', () async {
    final token = await harness.adminToken();
    final request = harness.client.patch(
      '/admin/products/prod_tshirt/shipping-profile',
    )
      ..bearer(token)
      ..json({'shipping_profile_id': 'sp_fragile'});

    final response = await request.send();

    response.assertOk();
    expect(_profileId(response.json!), 'sp_fragile');
    final detail = harness.client.get('/admin/products/prod_tshirt')
      ..bearer(token);
    expect(_profileId((await detail.send()).json!), 'sp_fragile');
    final rows = await harness.raw('''
SELECT shipping_profile_id, deleted_at IS NULL
FROM product_shipping_profile
WHERE product_id = 'prod_tshirt'
ORDER BY created_at, id
''');
    expect(rows, hasLength(2));
    expect(rows.where((row) => row.readIndex<bool>(1)), hasLength(1));
  });

  test('null clears the optional product profile', () async {
    final token = await harness.adminToken();
    final request = harness.client.patch(
      '/admin/products/prod_tshirt/shipping-profile',
    )
      ..bearer(token)
      ..json({'shipping_profile_id': null});

    final response = await request.send();

    response.assertOk();
    expect(_profileId(response.json!), isNull);
    final links = await harness.raw('''
SELECT count(*) FROM product_shipping_profile
WHERE product_id = 'prod_tshirt' AND deleted_at IS NULL
''');
    expect(links.single.readIndex<int>(0), 0);
  });

  test('invalid profile rolls back and unknown product stays hidden', () async {
    final token = await harness.adminToken();
    final invalid = harness.client.patch(
      '/admin/products/prod_tshirt/shipping-profile',
    )
      ..bearer(token)
      ..json({'shipping_profile_id': 'sp_missing'});
    (await invalid.send()).assertUnprocessable();
    final detail = harness.client.get('/admin/products/prod_tshirt')
      ..bearer(token);
    expect(_profileId((await detail.send()).json!), 'sp_default');

    final missing = harness.client.patch(
      '/admin/products/prod_missing/shipping-profile',
    )
      ..bearer(token)
      ..json({'shipping_profile_id': 'sp_fragile'});
    (await missing.send()).assertNotFound();
  });
}

String? _profileId(Object json) {
  final body = json as Map<String, Object?>;
  final profile = body['shipping_profile'] as Map<String, Object?>?;
  return profile?['id'] as String?;
}
