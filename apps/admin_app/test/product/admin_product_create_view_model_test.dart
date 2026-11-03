import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/product/admin_product_create_state.dart';
import 'package:admin_app/src/product/admin_product_create_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminProductCreateViewModel create;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_product_create');
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
      nextKey: () => 'test_media_key',
    );
    await mediaStorage.prepare();
    server = await TestClient.serve(buildApp(
      database,
      mediaStorage: mediaStorage,
    ));
    final authApi = AdminApi(Dio(), baseUrl: server.origin);
    final token = await authApi.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    create = AdminProductCreateViewModel(
      AdminProductCreateViewModelArgs(
        api: AdminApi(dio, baseUrl: server.origin),
      ),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads regional currencies and retains the created product', () async {
    await create.load();

    expect(create.state.status, AdminProductCreateStatus.ready);
    expect(create.state.currencyCodes, ['eur', 'usd']);
    expect(create.state.productTypes.map((item) => item.value), [
      'Pants',
      'Shirt',
      'Shorts',
      'Sweatshirt',
    ]);

    final created = await create.create(_product(typeId: 'ptyp_shirt'));

    expect(created, isA<Some<AdminProductDetail>>());
    expect(create.state.status, AdminProductCreateStatus.ready);
    expect(create.state.failure, const None<String>());
    expect(
      (create.state.created as Some<AdminProductDetail>).value.handle,
      'desk-lamp',
    );
    expect(
      (create.state.created as Some<AdminProductDetail>).value.productTypeId,
      'ptyp_shirt',
    );
  });

  test('maps a server conflict without replacing typed state', () async {
    await create.load();
    await create.create(_product());

    final duplicate = await create.create(_product());

    expect(duplicate, const None<AdminProductDetail>());
    expect(create.state.status, AdminProductCreateStatus.ready);
    expect(create.state.created, const None<AdminProductDetail>());
    expect(create.state.failure,
        const Some('That handle or SKU is already in use.'));
  });

  test('uploads and discards typed staged media', () async {
    await create.load();

    final uploaded = await create.uploadMedia([
      MultipartFile.fromBytes(_png, filename: 'lamp.png'),
    ]);

    expect(uploaded, isA<Some<List<AdminUploadedFile>>>());
    final file = (uploaded as Some<List<AdminUploadedFile>>).value.single;
    expect(file.id, 'test_media_key.png');
    expect(file.mimeType, 'image/png');
    expect(create.state.status, AdminProductCreateStatus.ready);
    expect(await create.discardUpload(file.id), isTrue);
  });
}

AdminCreateProduct _product({String? typeId}) => AdminCreateProduct(
      status: AdminProductLifecycle.published,
      title: 'Desk Lamp',
      handle: 'desk-lamp',
      typeId: typeId,
      discountable: true,
      media: [],
      options: [
        const AdminCreateProductOption(title: 'Finish', values: ['Black']),
      ],
      variants: [
        const AdminCreateProductVariant(
          title: 'Black',
          sku: 'LAMP-BLACK',
          inventoryQuantity: 5,
          manageInventory: true,
          allowBackorder: false,
          optionValues: {'Finish': 'Black'},
          prices: [
            AdminCreateProductPrice(currencyCode: 'eur', amount: 4500),
            AdminCreateProductPrice(currencyCode: 'usd', amount: 4900),
          ],
        ),
      ],
    );

const _png = <int>[0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
