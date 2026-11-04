import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

import 'read_support.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient client;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_search');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedCatalogRead(database);
    client = TestClient(buildApp(database));
  });

  tearDown(() async {
    await client.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('searches published product titles and handles', () async {
    final shirt = await client.get('/store/products?q=shirt').send();
    final mug = await client.get('/store/products?q=MUG').send();

    shirt
      ..assertOk()
      ..assertJsonContains({'total': 1, 'count': 1});
    mug
      ..assertOk()
      ..assertJsonContains({'total': 1, 'count': 1});
    expect(_handles(shirt), ['t-shirt']);
    expect(_handles(mug), ['mug']);
  });

  test('rejects unbounded search terms', () async {
    final query = 'x' * 121;

    (await client.get('/store/products?q=$query').send()).assertBadRequest();
  });
}

List<Object?> _handles(TestResponse response) {
  final body = response.json! as Map<String, Object?>;
  final products = body['products']! as List<Object?>;
  return products.map((it) => (it! as Map<String, Object?>)['handle']).toList();
}
