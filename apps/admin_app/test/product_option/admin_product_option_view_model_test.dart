import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/product_option/admin_product_option_detail_state.dart';
import 'package:admin_app/src/product_option/admin_product_option_detail_view_model.dart';
import 'package:admin_app/src/product_option/admin_product_option_state.dart';
import 'package:admin_app/src/product_option/admin_product_option_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late AdminProductOptionViewModel options;
  late AdminProductOptionDetailViewModel detail;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_options');
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
    final api = AdminApi(dio, baseUrl: server.origin);
    options = AdminProductOptionViewModel(
      AdminProductOptionViewModelArgs(api: api),
    );
    detail = AdminProductOptionDetailViewModel(
      AdminProductOptionDetailViewModelArgs(api: api),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads and searches global product options', () async {
    await options.load();

    expect(options.state.status, AdminProductOptionStatus.ready);
    expect(options.state.count, 2);
    expect(options.state.productOptions.map((item) => item.title), [
      'Size',
      'Color',
    ]);

    await options.search('color');
    expect(options.state.count, 1);
    expect(options.state.productOptions.single.title, 'Color');
  });

  test('creates a global option and refreshes the list', () async {
    await options.load();
    final created = await options.create(const AdminCreateProductOption(
      title: 'Material',
      values: ['Cotton', 'Linen'],
    ));

    expect(created, isA<Some<AdminProductOptionDetail>>());
    expect(options.state.status, AdminProductOptionStatus.ready);
    expect(options.state.count, 3);
  });

  test('deletes unused options and reports linked options', () async {
    await options.load();
    final created = await options.create(const AdminCreateProductOption(
      title: 'Material',
      values: ['Cotton', 'Linen'],
    ));
    final option = (created as Some<AdminProductOptionDetail>).value;

    expect(
      await options.delete(option.id),
      AdminProductOptionDeleteOutcome.deleted,
    );
    expect(options.state.count, 2);
    expect(
      await options.delete('opt_size'),
      AdminProductOptionDeleteOutcome.inUse,
    );
    expect(options.state.count, 2);
  });

  test('loads and publishes a safe refreshed detail after edit', () async {
    await detail.load('opt_size');
    final saved = await detail.update(
      'opt_size',
      const AdminUpdateProductOption(
        title: 'Clothing size',
        values: ['M', 'S', 'L', 'XL', 'XXL'],
      ),
    );

    expect(saved, isTrue);
    expect(detail.state.status, AdminProductOptionDetailStatus.ready);
    final option =
        (detail.state.productOption as Some<AdminProductOptionDetail>).value;
    expect(option.title, 'Clothing size');
    expect(option.values.map((item) => item.value), [
      'M',
      'S',
      'L',
      'XL',
      'XXL',
    ]);
  });

  test('keeps detail when a selected value cannot be removed', () async {
    await detail.load('opt_size');
    final saved = await detail.update(
      'opt_size',
      const AdminUpdateProductOption(
        title: 'Must not persist',
        values: ['M', 'L', 'XL'],
      ),
    );

    expect(saved, isFalse);
    expect(detail.state.productOption, isA<Some<AdminProductOptionDetail>>());
    expect(
      detail.state.failure,
      const Some('A product variant still uses one of these values.'),
    );
  });
}
