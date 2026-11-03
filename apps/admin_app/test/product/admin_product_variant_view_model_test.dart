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
    directory = await Directory.systemTemp.createTemp('admin_variant_detail');
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
    final mediaStorage = LocalAdminMediaStorage(
      root: Directory('${directory.path}/media'),
      publicBaseUrl: Uri.parse('http://media.test'),
      nextKey: () => 'variant_media_key',
    );
    await mediaStorage.prepare();
    server = await TestClient.serve(buildApp(
      database,
      mediaStorage: mediaStorage,
    ));
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

  test('publishes refreshed detail after a variant update', () async {
    await detail.load('prod_sweatpants');

    final saved = await detail.updateVariant(
      'prod_sweatpants',
      'var_sweatpants_s',
      const AdminUpdateProductVariant(
        title: 'Small / Updated',
        sku: 'SWEATPANTS-S-NEW',
        material: 'Organic cotton',
        ean: '4006381333931',
        upc: '012345678905',
        barcode: '0123456789012',
        weight: 400.5,
        width: 30.25,
        length: 2.5,
        height: 40.75,
        midCode: 'MMABC1234',
        hsCode: '610910',
        originCountry: 'dk',
        manageInventory: false,
        allowBackorder: true,
        optionValues: {'opt_size': 'S'},
      ),
    );

    expect(saved, isTrue);
    expect(detail.state.status, AdminProductDetailStatus.ready);
    final product = (detail.state.product as Some<AdminProductDetail>).value;
    final variant = product.variants
        .singleWhere((variant) => variant.id == 'var_sweatpants_s');
    expect(variant.title, 'Small / Updated');
    expect(variant.sku, 'SWEATPANTS-S-NEW');
    expect(variant.material, 'Organic cotton');
    expect(variant.ean, '4006381333931');
    expect(variant.upc, '012345678905');
    expect(variant.barcode, '0123456789012');
    expect(variant.weight, 400.5);
    expect(variant.width, 30.25);
    expect(variant.length, 2.5);
    expect(variant.height, 40.75);
    expect(variant.midCode, 'MMABC1234');
    expect(variant.hsCode, '610910');
    expect(variant.originCountry, 'dk');
    expect(variant.manageInventory, isFalse);
    expect(variant.allowBackorder, isTrue);
    expect(detail.state.failure, const None<String>());
  });

  test('keeps loaded detail and exposes a typed SKU conflict', () async {
    await detail.load('prod_sweatpants');

    final saved = await detail.updateVariant(
      'prod_sweatpants',
      'var_sweatpants_s',
      const AdminUpdateProductVariant(
        title: 'Must not persist',
        sku: 'SWEATPANTS-M',
        manageInventory: true,
        allowBackorder: false,
        optionValues: {'opt_size': 'S'},
      ),
    );

    expect(saved, isFalse);
    expect(detail.state.status, AdminProductDetailStatus.ready);
    expect(detail.state.product, isA<Some<AdminProductDetail>>());
    expect(detail.state.failure, const Some('This SKU is already in use.'));
  });
}
