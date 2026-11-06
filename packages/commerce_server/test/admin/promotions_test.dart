import 'dart:convert';

import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('promotion list requires a proven admin bearer', () async {
    (await harness.client.get('/admin/promotions').send()).assertUnauthorized();
  });

  test('lists direct Medusa table columns with paging and search', () async {
    final token = await harness.adminToken();
    final response = await (harness.client
            .get('/admin/promotions?q=welcome&limit=1&offset=0')
          ..bearer(token))
        .send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body['count'], 1);
    expect(body['limit'], 1);
    expect(body['offset'], 0);
    final row =
        (body['promotions']! as List<Object?>).single! as Map<String, Object?>;
    expect(row.keys, {
      'id',
      'code',
      'type',
      'value',
      'currency_code',
      'starts_at',
      'ends_at',
      'usage_limit',
      'usage_count',
      'is_automatic',
      'status',
      'created_at',
      'updated_at',
    });
    expect(row['code'], 'WELCOME10');
    expect(row['is_automatic'], isFalse);
    expect(row['status'], 'active');
    expect(DateTime.parse(row['created_at']! as String).isUtc, isTrue);
    expect(DateTime.parse(row['updated_at']! as String).isUtc, isTrue);
  });

  test('reads one active promotion detail envelope', () async {
    final token = await harness.adminToken();
    final response =
        await (harness.client.get('/admin/promotions/promo_welcome')
              ..bearer(token))
            .send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body.keys, {'promotion'});
    final promotion = body['promotion']! as Map<String, Object?>;
    expect(promotion['id'], 'promo_welcome');
    expect(promotion['code'], 'WELCOME10');
    expect(promotion['status'], 'active');
    expect(promotion, isNot(contains('deleted_at')));
  });

  test('missing and retired promotions are hidden', () async {
    final token = await harness.adminToken();
    await harness.raw(r'''
UPDATE promotions
SET deleted_at = '2026-01-02T00:00:00.000Z'
WHERE id = 'promo_welcome'
''');

    final retired = harness.client.get('/admin/promotions/promo_welcome')
      ..bearer(token);
    final missing = harness.client.get('/admin/promotions/promo_missing')
      ..bearer(token);

    (await retired.send()).assertNotFound();
    (await missing.send()).assertNotFound();
  });

  test('filters and orders promotions before the page boundary', () async {
    final token = await harness.adminToken();
    await harness.raw(r'''
INSERT INTO promotions
  (id, code, type, value, starts_at, created_at, updated_at)
VALUES
  ('promo_later', 'LATER10', 'percentage', 1000,
   '2099-01-01T00:00:00.000Z', '2026-01-02T00:00:00.000Z',
   '2026-01-02T00:00:00.000Z')
''');
    final created = Uri.encodeQueryComponent(jsonEncode({
      r'$gte': '2026-01-02T00:00:00+00:00',
      r'$lte': '2026-01-02T00:00:00Z',
    }));
    final response = await (harness.client.get(
      '/admin/promotions?created_at=$created&order=created_at',
    )..bearer(token))
        .send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    final rows = body['promotions']! as List<Object?>;
    expect(body['count'], 1);
    expect((rows.single! as Map<String, Object?>)['code'], 'LATER10');
    expect((rows.single! as Map<String, Object?>)['status'], 'scheduled');
  });

  test('rejects malformed date and order filters', () async {
    final token = await harness.adminToken();
    final invalidDate = harness.client
        .get('/admin/promotions?created_at=not-json')
      ..bearer(token);
    final invalidOrder = harness.client.get('/admin/promotions?order=code')
      ..bearer(token);

    (await invalidDate.send()).assertBadRequest();
    (await invalidOrder.send()).assertBadRequest();
  });

  test('promotion creation requires a proven admin bearer', () async {
    final request = harness.client.post('/admin/promotions')
      ..json({'code': 'NEW10', 'type': 'percentage', 'value': 1000});

    (await request.send()).assertUnauthorized();
  });

  test('creates a normalized percentage promotion through one response',
      () async {
    final token = await harness.adminToken();
    final request = harness.client.post('/admin/promotions')
      ..bearer(token)
      ..json({
        'code': '  spring_10  ',
        'type': 'percentage',
        'value': 1000,
        'usage_limit': 25,
      });

    final response = await request.send();

    response.assertCreated();
    final body = response.json! as Map<String, Object?>;
    expect(body.keys, {'promotion'});
    final promotion = body['promotion']! as Map<String, Object?>;
    expect(promotion['code'], 'SPRING_10');
    expect(promotion['type'], 'percentage');
    expect(promotion['value'], 1000);
    expect(promotion['currency_code'], isNull);
    expect(promotion['usage_limit'], 25);
    expect(promotion['usage_count'], 0);
    expect(promotion['status'], 'active');
    expect(DateTime.parse(promotion['created_at']! as String).isUtc, isTrue);
    expect(promotion['updated_at'], promotion['created_at']);

    final rows = await harness.raw('''
SELECT code, type, value, currency_code, usage_limit, usage_count
FROM promotions
WHERE code = 'SPRING_10'
''');
    expect(rows.single.readIndex<String>(0), 'SPRING_10');
    expect(rows.single.readIndex<String>(1), 'percentage');
    expect(rows.single.readIndex<int>(2), 1000);
    expect(rows.single.readNullable<String>('currency_code'), isNull);
    expect(rows.single.readIndex<int>(4), 25);
    expect(rows.single.readIndex<int>(5), 0);
  });

  test('creates a fixed promotion with a normalized currency', () async {
    final token = await harness.adminToken();
    final request = harness.client.post('/admin/promotions')
      ..bearer(token)
      ..json({
        'code': 'SAVE5',
        'type': 'fixed',
        'value': 500,
        'currency_code': ' USD ',
        'starts_at': '2099-01-01T00:00:00Z',
        'ends_at': '2099-02-01T00:00:00Z',
      });

    final response = await request.send();

    response.assertCreated();
    final promotion = (response.json! as Map<String, Object?>)['promotion']!
        as Map<String, Object?>;
    expect(promotion['currency_code'], 'usd');
    expect(promotion['status'], 'scheduled');
    expect(promotion['starts_at'], '2099-01-01T00:00:00.000Z');
    expect(promotion['ends_at'], '2099-02-01T00:00:00.000Z');
  });

  test('rejects duplicate and internally invalid promotion definitions',
      () async {
    final token = await harness.adminToken();
    final duplicate = harness.client.post('/admin/promotions')
      ..bearer(token)
      ..json({'code': ' welcome10 ', 'type': 'percentage', 'value': 500});
    final tooLarge = harness.client.post('/admin/promotions')
      ..bearer(token)
      ..json({'code': 'TOO_LARGE', 'type': 'percentage', 'value': 10001});
    final missingCurrency = harness.client.post('/admin/promotions')
      ..bearer(token)
      ..json({'code': 'FIXED_NO_CURRENCY', 'type': 'fixed', 'value': 100});
    final percentageCurrency = harness.client.post('/admin/promotions')
      ..bearer(token)
      ..json({
        'code': 'PERCENTAGE_CURRENCY',
        'type': 'percentage',
        'value': 100,
        'currency_code': 'usd',
      });
    final invertedDates = harness.client.post('/admin/promotions')
      ..bearer(token)
      ..json({
        'code': 'INVERTED',
        'type': 'percentage',
        'value': 100,
        'starts_at': '2099-02-01T00:00:00Z',
        'ends_at': '2099-01-01T00:00:00Z',
      });

    (await duplicate.send()).assertConflict();
    (await tooLarge.send()).assertUnprocessable();
    (await missingCurrency.send()).assertUnprocessable();
    (await percentageCurrency.send()).assertUnprocessable();
    (await invertedDates.send()).assertUnprocessable();

    final rows = await harness.raw('''
SELECT count(*) FROM promotions
WHERE code IN ('TOO_LARGE', 'FIXED_NO_CURRENCY', 'PERCENTAGE_CURRENCY', 'INVERTED')
''');
    expect(rows.single.readIndex<int>(0), 0);
  });
}
