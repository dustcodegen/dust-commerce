import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('variant_media');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedDevelopmentStore(database);
    server = await TestClient.serve(buildApp(database));
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('selected variant exposes only its associated gallery images', () async {
    final api = CommerceApi(Dio(), baseUrl: server.origin);
    final product = await api.product('t-shirt', currency: 'usd');

    expect(product.images, hasLength(4));
    expect(
      product.imagesForVariant('var_tshirt_m_white').map((image) => image.id),
      ['img_tshirt_3', 'img_tshirt_4'],
    );
    expect(
      product.imagesForVariant('var_tshirt_m_black').map((image) => image.id),
      ['img_tshirt_1', 'img_tshirt_2'],
    );
  });
}
