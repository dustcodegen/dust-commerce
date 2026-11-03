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
    directory = await Directory.systemTemp.createTemp('product_stock');
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
    final anonymous = AdminApi(Dio(), baseUrl: server.origin);
    final token = await anonymous.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
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

  test('publishes refreshed aggregate stock after a successful batch',
      () async {
    await detail.load('prod_sweatpants');

    final saved = await detail.updateProductStock(
      'prod_sweatpants',
      _stock(quantity: 7, managed: false),
    );

    expect(saved, isTrue);
    expect(detail.state.status, AdminProductDetailStatus.ready);
    final product = (detail.state.product as Some<AdminProductDetail>).value;
    final variant =
        product.variants.singleWhere((item) => item.id == 'var_sweatpants_s');
    expect(variant.inventoryQuantity, 7);
    expect(variant.manageInventory, isFalse);
    expect(detail.state.failure, const None<String>());
  });

  test('keeps loaded detail when selected stock is invalid', () async {
    await detail.load('prod_sweatpants');

    final saved = await detail.updateProductStock(
      'prod_sweatpants',
      const AdminUpdateProductStock(variants: []),
    );

    expect(saved, isFalse);
    expect(detail.state.product, isA<Some<AdminProductDetail>>());
    expect(
      detail.state.failure,
      const Some('Choose at least one variant and enter valid stock.'),
    );
  });
}

AdminUpdateProductStock _stock(
        {required int quantity, required bool managed}) =>
    AdminUpdateProductStock(variants: [
      AdminUpdateVariantStock(
        id: 'var_sweatpants_s',
        inventoryQuantity: quantity,
        manageInventory: managed,
      ),
    ]);
