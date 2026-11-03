import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/product_type/admin_product_type_detail_state.dart';
import 'package:admin_app/src/product_type/admin_product_type_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminProductTypeDetailViewModel detail;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('product_type_detail');
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
    final token = await AdminApi(Dio(), baseUrl: server.origin).signIn(
      const AdminCredentials(
        email: 'owner@example.com',
        password: 'correct horse battery staple',
      ),
    );
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    detail = AdminProductTypeDetailViewModel(
      AdminProductTypeDetailViewModelArgs(
        api: AdminApi(dio, baseUrl: server.origin),
      ),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads identity and pages only linked products', () async {
    await detail.load('ptyp_shirt');

    expect(detail.state.status, AdminProductTypeDetailStatus.ready);
    final productType =
        (detail.state.productType as Some<AdminProductType>).value;
    expect(productType.value, 'Shirt');
    expect(detail.state.count, 1);
    expect(detail.state.limit, 10);
    expect(detail.state.products.single.title, 'Essential T-Shirt');

    await detail.search('missing');
    expect(detail.state.count, 0);
    expect(detail.state.products, isEmpty);
    expect(detail.state.productType, Some(productType));
  });

  test('uses Option state for an unknown product type', () async {
    await detail.load('ptyp_missing');

    expect(detail.state.status, AdminProductTypeDetailStatus.failed);
    expect(detail.state.productType, const None<AdminProductType>());
    expect(detail.state.products, isEmpty);
    expect(
      detail.state.failure,
      const Some('This product type no longer exists.'),
    );
  });
}
