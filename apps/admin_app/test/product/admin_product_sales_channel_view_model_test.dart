import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/product/admin_product_detail_state.dart';
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
    directory = await Directory.systemTemp.createTemp('admin_product_channel');
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

  test('loads product availability and the total channel count', () async {
    await detail.load('prod_tshirt');

    expect(detail.state.status, AdminProductDetailStatus.ready);
    expect(
      detail.state.salesChannels.map((channel) => channel.name),
      ['Online Store'],
    );
    expect(detail.state.totalSalesChannels, const Some(2));
  });

  test('publishes the complete saved channel selection', () async {
    await detail.load('prod_tshirt');

    final saved = await detail.updateSalesChannels(
      'prod_tshirt',
      const AdminUpdateProductSalesChannels(
        salesChannelIds: ['sc_wholesale'],
      ),
    );

    expect(saved, isTrue);
    expect(detail.state.status, AdminProductDetailStatus.ready);
    expect(
      detail.state.salesChannels.map((channel) => channel.name),
      ['Wholesale'],
    );
    expect(detail.state.totalSalesChannels, const Some(2));
    expect(detail.state.failure, const None<String>());
  });

  test('loads typed editor rows without exposing nullable descriptions',
      () async {
    await detail.load('prod_tshirt');

    final result = await detail.salesChannelChoices();
    final page = switch (result) {
      Some(:final value) => value,
      None() => fail('Expected sales-channel choices'),
    };

    expect(page.salesChannels, hasLength(2));
    expect(
      page.salesChannels.first.description,
      const Some('Primary direct-to-consumer storefront'),
    );
    expect(page.salesChannels.first.createdAt.isUtc, isTrue);
    expect(page.salesChannels.first.updatedAt.isUtc, isTrue);
  });

  test('keeps loaded detail when the selection is invalid', () async {
    await detail.load('prod_tshirt');

    final saved = await detail.updateSalesChannels(
      'prod_tshirt',
      const AdminUpdateProductSalesChannels(
        salesChannelIds: ['sc_web', 'sc_web'],
      ),
    );

    expect(saved, isFalse);
    expect(detail.state.product, isA<Some<AdminProductDetail>>());
    expect(
      detail.state.failure,
      const Some('Choose unique available sales channels.'),
    );
    expect(
      detail.state.salesChannels.map((channel) => channel.id),
      ['sc_web'],
    );
  });
}
