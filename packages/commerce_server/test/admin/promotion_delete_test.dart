import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('promotion deletion requires a proven admin bearer', () async {
    (await harness.client.delete('/admin/promotions/promo_welcome').send())
        .assertUnauthorized();
  });

  test('retires an active promotion and returns an acknowledgement', () async {
    final token = await harness.adminToken();
    final response =
        await (harness.client.delete('/admin/promotions/promo_welcome')
              ..bearer(token))
            .send();

    response.assertOk();
    expect(response.json, {
      'id': 'promo_welcome',
      'object': 'promotion',
      'deleted': true,
    });
    final row = await harness.raw('''
SELECT deleted_at FROM promotions WHERE id = 'promo_welcome'
''');
    expect(row, hasLength(1));
    expect(row.single.readNullable<Object>('deleted_at'), isNotNull);

    (await (harness.client.get('/admin/promotions/promo_welcome')
              ..bearer(token))
            .send())
        .assertNotFound();
  });

  test('unknown and already retired promotions are not found', () async {
    final token = await harness.adminToken();
    final unknown = harness.client.delete('/admin/promotions/promo_missing')
      ..bearer(token);
    expect((await unknown.send()).statusCode, 404);

    final first = harness.client.delete('/admin/promotions/promo_welcome')
      ..bearer(token);
    expect((await first.send()).statusCode, 200);
    final repeated = harness.client.delete('/admin/promotions/promo_welcome')
      ..bearer(token);
    expect((await repeated.send()).statusCode, 404);
  });
}
