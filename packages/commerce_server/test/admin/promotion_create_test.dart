import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

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

  test('rejects duplicate and internally invalid definitions', () async {
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
