import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('region discovery requires a proven admin bearer', () async {
    (await harness.client.get('/admin/regions').send()).assertUnauthorized();
  });

  test('region discovery returns only ordered filter fields', () async {
    final token = await harness.adminToken();
    final response =
        await (harness.client.get('/admin/regions?limit=1000&offset=0')
              ..bearer(token))
            .send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body, containsPair('count', 2));
    expect(body, containsPair('limit', 1000));
    expect(body, containsPair('offset', 0));
    final regions = body['regions']! as List<Object?>;
    expect(regions, [
      {'id': 'reg_eu', 'name': 'Europe'},
      {'id': 'reg_us', 'name': 'United States'},
    ]);
  });

  test('region discovery searches before bounded paging', () async {
    final token = await harness.adminToken();
    final response =
        await (harness.client.get('/admin/regions?q=UNITED&limit=5000')
              ..bearer(token))
            .send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body, containsPair('count', 1));
    expect(body, containsPair('limit', 1000));
    expect(body['regions'], [
      {'id': 'reg_us', 'name': 'United States'},
    ]);
  });
}
