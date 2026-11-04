import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dust_dart/http.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generated storefront loads the complete development demo', () async {
    final directory = await Directory.systemTemp.createTemp('storefront_demo');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedDevelopmentStore(database);
    await seedDevelopmentDemoCatalog(database);
    final server = await TestClient.serve(buildApp(database));
    addTearDown(() async {
      await server.close();
      await database.close();
      await directory.delete(recursive: true);
    });
    final api = CommerceApi(Dio(), baseUrl: server.origin);
    final products = ProductListingViewModel(
      ProductListingViewModelArgs(api: api),
    );

    final page = await api.products(currency: 'usd', limit: 100);
    await products.loadStore();

    expect(page.total, 21);
    expect(page.products, hasLength(21));
    expect(products.state.status, ProductListingStatus.ready);
    expect(products.state.products, hasLength(12));
    expect(products.state.totalPages, 2);
  });
}
