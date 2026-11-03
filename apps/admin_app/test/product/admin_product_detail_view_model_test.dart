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
    directory = await Directory.systemTemp.createTemp('admin_product_detail');
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
      nextKey: () => 'detail_media_key',
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
        salesChannels: AdminProductSalesChannelApi(dio, baseUrl: server.origin),
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

  test('uses an Option failure for an unknown product', () async {
    await detail.load('prod_missing');

    expect(detail.state.status, AdminProductDetailStatus.failed);
    expect(detail.state.product, const None<AdminProductDetail>());
    expect(
      detail.state.failure,
      const Some('This product no longer exists.'),
    );
  });

  test('publishes refreshed detail after a successful update', () async {
    await detail.load('prod_sweatpants');

    final saved = await detail.update(
      'prod_sweatpants',
      const AdminUpdateProduct(
        status: AdminProductLifecycle.draft,
        title: 'Everyday Trousers',
        handle: 'everyday-trousers',
        subtitle: 'A softer name',
        material: 'Cotton twill',
        description: 'Built for daily wear.',
        discountable: false,
      ),
    );

    expect(saved, isTrue);
    expect(detail.state.status, AdminProductDetailStatus.ready);
    final product = (detail.state.product as Some<AdminProductDetail>).value;
    expect(product.title, 'Everyday Trousers');
    expect(product.handle, 'everyday-trousers');
    expect(product.status, AdminProductLifecycle.draft);
    expect(product.subtitle, 'A softer name');
    expect(product.discountable, isFalse);
    expect(detail.state.failure, const None<String>());
  });

  test('keeps loaded detail and exposes a typed conflict failure', () async {
    await detail.load('prod_sweatpants');

    final saved = await detail.update(
      'prod_sweatpants',
      const AdminUpdateProduct(
        status: AdminProductLifecycle.published,
        title: 'Relaxed Sweatpants',
        handle: 't-shirt',
        material: 'Cotton',
        description: 'Must not persist.',
        discountable: true,
      ),
    );

    expect(saved, isFalse);
    expect(detail.state.status, AdminProductDetailStatus.ready);
    expect(detail.state.product, isA<Some<AdminProductDetail>>());
    expect(
      detail.state.failure,
      const Some('This handle is already in use.'),
    );
  });

  test('uploads and publishes an ordered media replacement', () async {
    await detail.load('prod_sweatpants');
    final uploaded = await detail.uploadMedia([
      MultipartFile.fromBytes(_png, filename: 'detail.png'),
    ]);
    final file = (uploaded as Some<List<AdminUploadedFile>>).value.single;
    final current =
        (detail.state.product as Some<AdminProductDetail>).value.images;

    final saved = await detail.updateMedia(
      'prod_sweatpants',
      AdminUpdateProductMedia(media: [
        AdminCreateProductMedia(
          id: current.last.id,
          url: current.last.url,
          isThumbnail: true,
        ),
        AdminCreateProductMedia(
          id: file.id,
          url: file.url,
          isThumbnail: false,
        ),
      ]),
    );

    expect(saved, isTrue);
    expect(detail.state.status, AdminProductDetailStatus.ready);
    final product = (detail.state.product as Some<AdminProductDetail>).value;
    expect(
        product.images.map((image) => image.url), [current.last.url, file.url]);
    expect(product.thumbnail, current.last.url);
    expect(detail.state.failure, const None<String>());
  });

  test('associates an image with selected product variants', () async {
    await detail.load('prod_sweatpants');

    final saved = await detail.batchImageVariants(
      'prod_sweatpants',
      'img_sweatpants_1',
      const AdminBatchImageVariants(add: ['var_sweatpants_m']),
    );

    expect(saved, isTrue);
    final product = (detail.state.product as Some<AdminProductDetail>).value;
    expect(product.images.first.variantIds, ['var_sweatpants_m']);
    expect(detail.state.failure, const None<String>());
  });
}

const _png = <int>[0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
