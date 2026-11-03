import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/product/admin_product_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_export');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedDevelopmentStore(database);
    await bootstrapAdmin(
      database,
      const AdminCredentials(
        email: 'owner@example.com',
        password: 'correct horse battery staple',
      ),
      nextId: () => 'admin_owner',
      passwordWork: PasswordWorkLimiter(),
    );
    server = await TestClient.serve(buildApp(database));
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('exports the complete catalogue using the current table filters',
      () async {
    final signInApi = AdminApi(Dio(), baseUrl: server.origin);
    final token = await signInApi.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    final products = AdminProductViewModel(
      AdminProductViewModelArgs(api: AdminApi(dio, baseUrl: server.origin)),
    );

    await products.filterByTypes(const ['ptyp_shirt']);
    final result = await products.export();
    final csv = switch (result) {
      Ok(:final value) => value,
      Err(:final error) => fail(error),
    };

    expect(csv, contains('prod_tshirt,t-shirt,Essential T-Shirt'));
    expect(csv, isNot(contains('prod_sweatpants')));
    expect(csv.trim().split('\n'), hasLength(9));
  });
}
