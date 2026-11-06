import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('promotion update requires a proven admin bearer', () async {
    final request = harness.client.patch('/admin/promotions/promo_welcome')
      ..json({
        'code': 'WELCOME20',
        'type': 'percentage',
        'value': 2000,
        'currency_code': null,
        'starts_at': null,
        'ends_at': null,
        'usage_limit': 25,
      });

    (await request.send()).assertUnauthorized();
  });

  test('updates a promotion and returns the refreshed envelope', () async {
    final token = await harness.adminToken();
    final request = harness.client.patch('/admin/promotions/promo_welcome')
      ..bearer(token)
      ..json({
        'code': ' welcome20 ',
        'type': 'percentage',
        'value': 2000,
        'currency_code': null,
        'starts_at': null,
        'ends_at': null,
        'usage_limit': 25,
      });

    final response = await request.send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body.keys, {'promotion'});
    final promotion = body['promotion']! as Map<String, Object?>;
    expect(promotion['id'], 'promo_welcome');
    expect(promotion['code'], 'WELCOME20');
    expect(promotion['type'], 'percentage');
    expect(promotion['value'], 2000);
    expect(promotion['usage_limit'], 25);
    expect(promotion['currency_code'], isNull);
    expect(DateTime.parse(promotion['updated_at']! as String).isUtc, isTrue);

    final rows = await harness.raw('''
SELECT code, value, usage_limit
FROM promotions
WHERE id = 'promo_welcome'
''');
    expect(rows.single.readIndex<String>(0), 'WELCOME20');
    expect(rows.single.readIndex<int>(1), 2000);
    expect(rows.single.readNullable<int>('usage_limit'), 25);
  });

  test('update rejects a duplicate code without changing the row', () async {
    final token = await harness.adminToken();
    await harness.raw('''
INSERT INTO promotions (id, code, type, value)
VALUES ('promo_other', 'OTHER10', 'percentage', 1000)
''');
    final request = harness.client.patch('/admin/promotions/promo_welcome')
      ..bearer(token)
      ..json({
        'code': 'OTHER10',
        'type': 'percentage',
        'value': 2000,
        'currency_code': null,
        'starts_at': null,
        'ends_at': null,
        'usage_limit': null,
      });

    (await request.send()).assertConflict();
    final rows = await harness.raw('''
SELECT code, value FROM promotions WHERE id = 'promo_welcome'
''');
    expect(rows.single.readIndex<String>(0), 'WELCOME10');
    expect(rows.single.readIndex<int>(1), 1000);
  });

  test('update rejects a limit below committed redemptions', () async {
    final token = await harness.adminToken();
    await harness.raw('''
UPDATE promotions SET usage_count = 3 WHERE id = 'promo_welcome'
''');
    final request = harness.client.patch('/admin/promotions/promo_welcome')
      ..bearer(token)
      ..json({
        'code': 'WELCOME10',
        'type': 'percentage',
        'value': 1000,
        'currency_code': null,
        'starts_at': null,
        'ends_at': null,
        'usage_limit': 2,
      });

    (await request.send()).assertUnprocessable();
    final rows = await harness.raw('''
SELECT usage_count, usage_limit FROM promotions WHERE id = 'promo_welcome'
''');
    expect(rows.single.readIndex<int>(0), 3);
    expect(rows.single.readNullable<int>('usage_limit'), isNull);
  });
}
