import 'dart:convert';

import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('shipping-profile discovery requires the Admin route guard', () async {
    final request = harness.client.get('/admin/shipping-profiles');

    (await request.send()).assertUnauthorized();
  });

  test('lists typed Medusa profile fields with search and paging', () async {
    final token = await harness.adminToken();
    final request = harness.client.get(
      '/admin/shipping-profiles?q=default&limit=1&offset=0',
    )..bearer(token);

    final response = await request.send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(
        body.keys,
        unorderedEquals([
          'shipping_profiles',
          'count',
          'limit',
          'offset',
        ]));
    expect(body['count'], 1);
    expect(body['limit'], 1);
    expect(body['offset'], 0);
    final profile = (body['shipping_profiles']! as List<Object?>).single!
        as Map<String, Object?>;
    expect(
        profile.keys,
        unorderedEquals([
          'id',
          'name',
          'type',
          'created_at',
          'updated_at',
        ]));
    expect(profile['id'], 'sp_default');
    expect(profile['name'], 'Default Shipping Profile');
    expect(profile['type'], 'default');
    expect(DateTime.parse(profile['created_at']! as String).isUtc, isTrue);
    expect(DateTime.parse(profile['updated_at']! as String).isUtc, isTrue);
  });

  test('product detail embeds its current shipping profile', () async {
    final token = await harness.adminToken();
    final request = harness.client.get('/admin/products/prod_tshirt')
      ..bearer(token);

    final response = await request.send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    final profile = body['shipping_profile']! as Map<String, Object?>;
    expect(profile['id'], 'sp_default');
    expect(profile['name'], 'Default Shipping Profile');
    expect(profile['type'], 'default');
  });

  test('filters and orders profiles before the page boundary', () async {
    final token = await harness.adminToken();
    await (harness.client.post('/admin/shipping-profiles')
          ..bearer(token)
          ..json({'name': 'Fragile Goods', 'type': 'fragile'}))
        .send();
    final createdAt = Uri.encodeQueryComponent(jsonEncode({
      r'$gte': '2000-01-01T00:00:00.000Z',
      r'$lte': '2099-01-01T00:00:00.000Z',
    }));
    final request = harness.client.get(
      '/admin/shipping-profiles?name=goods&type=fragile&'
      'created_at=$createdAt&order=-name&limit=20&offset=0',
    )..bearer(token);

    final response = await request.send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body['count'], 1);
    final rows = body['shipping_profiles']! as List<Object?>;
    expect((rows.single! as Map<String, Object?>)['name'], 'Fragile Goods');
  });

  test('rejects malformed profile date and order filters', () async {
    final token = await harness.adminToken();
    final invalidDate = harness.client.get(
      '/admin/shipping-profiles?created_at=not-json',
    )..bearer(token);
    final invalidOrder = harness.client.get(
      '/admin/shipping-profiles?order=deleted_at',
    )..bearer(token);

    (await invalidDate.send()).assertBadRequest();
    (await invalidOrder.send()).assertBadRequest();
  });
}
