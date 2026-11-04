import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/product/admin_product_detail_view_model.dart';
import 'package:admin_app/src/product/admin_product_sales_channel_api.dart';
import 'package:admin_app/src/product/admin_product_shipping_profile_api.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminProductDetailViewModel detail;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_product_profile');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedDevelopmentStore(database);
    await queryExecute(
      "INSERT INTO shipping_profile (id, name, type) "
      "VALUES ('sp_fragile', 'Fragile', 'fragile')",
      [],
    ).execute(database.executor);
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
    detail = AdminProductDetailViewModel(
      AdminProductDetailViewModelArgs(
        api: AdminApi(dio, baseUrl: server.origin),
        salesChannels: AdminProductSalesChannelApi(
          dio,
          baseUrl: server.origin,
        ),
        shippingProfiles: AdminProductShippingProfileApi(
          dio,
          baseUrl: server.origin,
        ),
      ),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads typed profile choices and embedded assignment', () async {
    await detail.load('prod_tshirt');

    final choices = await detail.shippingProfileChoices(query: 'frag');

    expect(_profile(_product(detail)).id, 'sp_default');
    final page = switch (choices) {
      Some(:final value) => value,
      None() => fail('Expected shipping-profile choices'),
    };
    expect(page.shippingProfiles.single.name, 'Fragile');
    expect(page.count, 1);
  });

  test('replaces and refreshes the product profile', () async {
    await detail.load('prod_tshirt');

    final saved = await detail.updateShippingProfile(
      'prod_tshirt',
      const AdminUpdateProductShippingProfile(
        shippingProfileIdValue: 'sp_fragile',
      ),
    );

    expect(saved, isTrue);
    expect(_profile(_product(detail)).id, 'sp_fragile');
    expect(detail.state.failure, const None<String>());
  });

  test('clears the optional assignment', () async {
    await detail.load('prod_tshirt');

    final saved = await detail.updateShippingProfile(
      'prod_tshirt',
      const AdminUpdateProductShippingProfile(
        shippingProfileIdValue: null,
      ),
    );

    expect(saved, isTrue);
    expect(_product(detail).shippingProfile, const None());
  });

  test('keeps loaded detail when the profile is invalid', () async {
    await detail.load('prod_tshirt');

    final saved = await detail.updateShippingProfile(
      'prod_tshirt',
      const AdminUpdateProductShippingProfile(
        shippingProfileIdValue: 'sp_missing',
      ),
    );

    expect(saved, isFalse);
    expect(_profile(_product(detail)).id, 'sp_default');
    expect(
      detail.state.failure,
      const Some('Choose an active shipping profile.'),
    );
  });
}

AdminProductDetail _product(AdminProductDetailViewModel detail) =>
    switch (detail.state.product) {
      Some(:final value) => value,
      None() => throw StateError('Expected loaded product'),
    };

AdminShippingProfile _profile(AdminProductDetail product) =>
    switch (product.shippingProfile) {
      Some(:final value) => value,
      None() => throw StateError('Expected assigned shipping profile'),
    };
