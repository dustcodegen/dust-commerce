import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

void main() {
  test('GET /health answers ok', () async {
    final directory = await Directory.systemTemp.createTemp('commerce_health');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    final client = TestClient(buildApp(database));
    addTearDown(client.close);
    addTearDown(database.close);
    addTearDown(() => directory.delete(recursive: true));

    (await client.get('/health').send())
      ..assertOk()
      ..assertHeader('cache-control', 'no-store')
      ..assertJson({'status': 'ok'});
  });
}
