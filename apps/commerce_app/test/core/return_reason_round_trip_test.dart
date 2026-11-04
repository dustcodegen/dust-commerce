import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dust_dart/http.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generated client reads one public return-reason page', () async {
    final directory =
        await Directory.systemTemp.createTemp('return_reason_client');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedDevelopmentStore(database);
    final server = await TestClient.serve(buildApp(database));
    final api = CommerceApi(Dio(), baseUrl: server.origin);
    addTearDown(() async {
      await server.close();
      await database.close();
      await directory.delete(recursive: true);
    });

    final page = await api.returnReasons(limit: 2, offset: 1);

    expect(page.count, 5);
    expect(page.limit, 2);
    expect(page.offset, 1);
    expect(page.returnReasons, hasLength(2));
    expect(
        page.returnReasons.every((reason) => reason.createdAt.isUtc), isTrue);
  });
}
