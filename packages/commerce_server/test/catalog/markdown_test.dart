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
    directory = await Directory.systemTemp.createTemp('commerce_markdown');
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

  test('returns an explicit text/markdown product projection', () async {
    final response =
        await client.get('/store/products/t-shirt/markdown?country=us').send();

    response
      ..assertOk()
      ..assertHeader('content-type', 'text/markdown; charset=utf-8');
    expect(response.body, contains('# T-Shirt'));
    expect(
      response.body,
      contains('| USD 19.99 | In stock | `var_small` |'),
    );
    expect(
      response.body,
      contains('POST `variant_id={variant_id}&quantity={n}`'),
    );
    expect(response.body, isNot(contains('inventory_quantity')));
  });

  test('keeps missing products private', () async {
    (await client.get('/store/products/secret-hoodie/markdown').send())
        .assertNotFound();
  });

  test('rejects malformed country selectors', () async {
    (await client.get('/store/products/t-shirt/markdown?country=USA').send())
        .assertBadRequest();
  });
}
