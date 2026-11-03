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
  late AdminProductViewModel products;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_import');
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
    final signIn = AdminApi(Dio(), baseUrl: server.origin);
    final token = await signIn.signIn(const AdminCredentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    ));
    final dio = Dio()
      ..options.headers['authorization'] = 'Bearer ${token.token}';
    products = AdminProductViewModel(
      AdminProductViewModelArgs(api: AdminApi(dio, baseUrl: server.origin)),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('previews a CSV through the generated authenticated client', () async {
    final before = await _productCount(database);
    final result = await products.previewImport(_csvFile(_validCsv));
    final preview = switch (result) {
      Ok(:final value) => value,
      Err(:final error) => fail(error),
    };

    expect(
        preview.summary,
        const AdminProductImportSummary(
          toCreate: 1,
          toUpdate: 1,
        ));
    expect(preview.transactionId, isNotEmpty);
    expect(await _productCount(database), before);
  });

  test('maps invalid CSV to a merchant-facing failure', () async {
    final result = await products.previewImport(_csvFile('not,a,product\r\n'));

    expect(
        result,
        const Err<AdminProductImportPreview, String>(
          'The product CSV is invalid.',
        ));
  });

  test('confirms the staged import through the generated client once',
      () async {
    final before = await _productCount(database);
    final preview = await products.previewImport(_csvFile(_validCsv));
    final transactionId = switch (preview) {
      Ok(:final value) => value.transactionId,
      Err(:final error) => fail(error),
    };

    final confirmed = await products.confirmImport(transactionId);
    expect(confirmed, const Ok<void, String>(null));
    expect(await _productCount(database), before + 1);
    expect(
      await products.confirmImport(transactionId),
      const Err<void, String>('This product import is no longer available.'),
    );
  });
}

MultipartFile _csvFile(String value) => MultipartFile.fromString(
      value,
      filename: 'products.csv',
      contentType: DioMediaType.parse('text/csv'),
    );

Future<int> _productCount(CommerceDatabase database) async {
  final rows = await queryRaw('SELECT count(*) FROM products', [])
      .fetch(database.connection as Executor);
  return rows.single.readIndex<int>(0);
}

const _validCsv =
    'Product Id,Product Handle,Product Title,Product Status,Variant Id,'
    'Variant Title,Variant SKU,Variant Price EUR,Variant Price USD\r\n'
    'prod_tshirt,t-shirt,Essential T-Shirt,published,var_tshirt_s_black,'
    'S / Black,TSHIRT-S-BLACK,10.00,15.00\r\n'
    ',new-cap,New Cap,published,,One size,NEW-CAP,10.00,15.00\r\n';
