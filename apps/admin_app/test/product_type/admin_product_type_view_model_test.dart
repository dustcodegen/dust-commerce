import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/product_type/admin_product_type_state.dart';
import 'package:admin_app/src/product_type/admin_product_type_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminProductTypeViewModel productTypes;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_product_types');
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
    final signInApi = AdminApi(Dio(), baseUrl: server.origin);
    final token = await signInApi.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    productTypes = AdminProductTypeViewModel(
      AdminProductTypeViewModelArgs(
        api: AdminApi(dio, baseUrl: server.origin),
      ),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads and searches product types', () async {
    await productTypes.load();

    expect(productTypes.state.status, AdminProductTypeStatus.ready);
    expect(productTypes.state.count, 4);
    expect(
      productTypes.state.productTypes.map((item) => item.value),
      contains('Shirt'),
    );

    await productTypes.search('missing');
    expect(productTypes.state.count, 0);
    expect(productTypes.state.productTypes, isEmpty);
  });

  test('creates and renames one product type', () async {
    final created = await productTypes.create(
      const AdminCreateProductType(value: '  Accessory  '),
    );

    expect(created, isA<Some<AdminProductType>>());
    final productType = (created as Some<AdminProductType>).value;
    expect(productType.value, 'Accessory');
    expect(productTypes.state.count, 5);

    final updated = await productTypes.update(
      productType.id,
      const AdminUpdateProductType(value: 'Homeware'),
    );
    expect(updated, isA<Some<AdminProductType>>());
    expect((updated as Some<AdminProductType>).value.value, 'Homeware');
    expect(
      productTypes.state.productTypes
          .firstWhere((item) => item.id == productType.id)
          .value,
      'Homeware',
    );
  });

  test('deletes a product type and reports conflicts', () async {
    final created = await productTypes.create(
      const AdminCreateProductType(value: 'Accessory'),
    );
    final productType = (created as Some<AdminProductType>).value;

    expect(
      await productTypes.delete(productType.id),
      AdminProductTypeDeleteOutcome.deleted,
    );
    expect(productTypes.state.count, 4);
    expect(
      await productTypes.create(const AdminCreateProductType(value: 'Shirt')),
      const None<AdminProductType>(),
    );
    expect(
      productTypes.state.failure,
      const Some('Another product type already uses this value.'),
    );
  });
}
