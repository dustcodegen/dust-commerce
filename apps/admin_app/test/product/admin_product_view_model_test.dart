import 'dart:io';

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/product/admin_product_state.dart';
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
  late AdminApi api;
  late AdminProductViewModel products;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('admin_products');
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
    api = AdminApi(dio, baseUrl: server.origin);
    products = AdminProductViewModel(AdminProductViewModelArgs(api: api));
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads allowlisted products and page metadata', () async {
    await products.load();

    expect(products.state.status, AdminProductStatus.ready);
    expect(products.state.count, 4);
    expect(products.state.products, hasLength(4));
    expect(products.state.products.first.variantCount, greaterThan(0));
  });

  test('search replaces the first page with matching products', () async {
    await products.search(' SWEAT ');

    expect(products.state.status, AdminProductStatus.ready);
    expect(products.state.query, 'SWEAT');
    expect(products.state.count, 2);
    expect(
      products.state.products.map((product) => product.title),
      containsAll(['Vintage Sweatshirt', 'Relaxed Sweatpants']),
    );
  });

  test('filters by selected lifecycle states through the server', () async {
    await database.connection.execute(
      "UPDATE products SET status = 'draft' WHERE id = 'prod_tshirt'",
      const [],
    );

    await products.filterByStatuses(const [AdminProductLifecycle.draft]);

    expect(products.state.statuses, const [AdminProductLifecycle.draft]);
    expect(products.state.count, 1);
    expect(products.state.products.single.id, 'prod_tshirt');
    expect(products.state.offset, 0);
  });

  test('discovers and filters normalized product types', () async {
    final types = await api.listProductTypes('', 20, 0);

    expect(types.count, 4);
    expect(types.productTypes.first.createdAt.isUtc, isTrue);
    await products.filterByTypes(const ['ptyp_shirt']);
    expect(products.state.typeIds, const ['ptyp_shirt']);
    expect(products.state.count, 1);
    expect(products.state.products.single.id, 'prod_tshirt');
  });

  test('loads real filter options and clears every active filter', () async {
    await products.loadFilterOptions();

    expect(products.state.filterOptionsStatus, AdminFilterOptionsStatus.ready);
    expect(products.state.productTypes.map((type) => type.value),
        contains('Shirt'));
    expect(
        products.state.productTags.map((tag) => tag.value), contains('Cotton'));

    await products.filterByStatuses(const [AdminProductLifecycle.published]);
    await products.filterByTypes(const ['ptyp_shirt']);
    await products.filterByTags(const ['ptag_cotton']);
    await products.clearFilters();

    expect(products.state.statuses, isEmpty);
    expect(products.state.typeIds, isEmpty);
    expect(products.state.tagIds, isEmpty);
    expect(products.state.createdAt.isEmpty, isTrue);
    expect(products.state.updatedAt.isEmpty, isTrue);
    expect(products.state.count, 4);
  });

  test('orders products using the Medusa query contract', () async {
    await products.orderBy(AdminProductOrder.titleAsc);

    expect(products.state.order, AdminProductOrder.titleAsc);
    expect(
      products.state.products.map((product) => product.title),
      orderedEquals([
        'Essential T-Shirt',
        'Everyday Shorts',
        'Relaxed Sweatpants',
        'Vintage Sweatshirt',
      ]),
    );
  });

  test('keeps tag and date filters in generated query state', () async {
    await database.connection.execute(
      "INSERT INTO product_tags (id, value) VALUES ('ptag_featured', 'Featured')",
      const [],
    );
    await database.connection.execute(
      "INSERT INTO product_tag_products (product_id, tag_id) "
      "VALUES ('prod_shorts', 'ptag_featured')",
      const [],
    );
    await database.connection.execute(
      "UPDATE products SET created_at = '2026-01-04T00:00:00.000Z' "
      "WHERE id = 'prod_shorts'",
      const [],
    );

    await products.filterByTags(const ['ptag_featured']);
    await products.filterByCreatedAt(
      from: Some(DateTime.utc(2026, 1, 4)),
      to: Some(DateTime.utc(2026, 1, 4, 23, 59, 59)),
    );

    expect(products.state.tagIds, const ['ptag_featured']);
    expect(
      products.state.createdAt.greaterThanOrEqual,
      Some(DateTime.utc(2026, 1, 4)),
    );
    expect(products.state.count, 1);
    expect(products.state.products.single.id, 'prod_shorts');
  });

  test('reports expired sessions when filter discovery is unauthorized',
      () async {
    final unauthorized = AdminProductViewModel(
      AdminProductViewModelArgs(api: AdminApi(Dio(), baseUrl: server.origin)),
    );

    await unauthorized.loadFilterOptions();

    expect(unauthorized.state.filterOptionsStatus,
        AdminFilterOptionsStatus.failed);
    expect(
      unauthorized.state.filterOptionsFailure,
      const Some('Your admin session has expired.'),
    );
  });

  test('removes a deleted product from the current page', () async {
    await products.load();

    final deleted = await products.delete('prod_sweatpants');

    expect(deleted, isTrue);
    expect(products.state.status, AdminProductStatus.ready);
    expect(products.state.count, 3);
    expect(
      products.state.products.map((product) => product.id),
      isNot(contains('prod_sweatpants')),
    );
    expect(products.state.failure, const None<String>());
  });

  test('keeps the current page when a product is already gone', () async {
    await products.load();

    final deleted = await products.delete('prod_missing');

    expect(deleted, isFalse);
    expect(products.state.products, hasLength(4));
    expect(
      products.state.failure,
      const Some('This product no longer exists.'),
    );
  });
}
