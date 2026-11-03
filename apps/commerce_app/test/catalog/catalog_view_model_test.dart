import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/http.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

/// View model tests come first and outnumber widget tests, as the structure
/// doc says: a view model is pure Dart and a widget test is not, and the logic
/// worth testing lives in the former.
void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late CatalogViewModel viewModel;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_vm');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await _seed(database);
    server = await TestClient.serve(buildApp(database));

    viewModel = CatalogViewModel(
      CatalogViewModelArgs(api: CommerceApi(Dio(), baseUrl: server.origin)),
    );
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  group('load', () {
    test('starts idle, holding nothing', () {
      expect(viewModel.state.status, CatalogStatus.idle);
      expect(viewModel.state.rails, isEmpty);
      expect(viewModel.state.isLoading, isFalse);
    });

    test('ends ready with the products the server sent', () async {
      await viewModel.load();

      expect(viewModel.state.status, CatalogStatus.ready);
      expect(viewModel.state.rails, hasLength(1));
      expect(viewModel.state.rails.single.collection.handle, 'featured');
      expect(viewModel.state.rails.single.products.single.handle, 't-shirt');
    });

    test('passes through loading on the way', () async {
      final seen = <CatalogStatus>[];
      viewModel.addListener(() => seen.add(viewModel.state.status));

      await viewModel.load();

      expect(seen, [CatalogStatus.loading, CatalogStatus.ready]);
    });

    test('carries prices as the shared Money type, not strings', () async {
      await viewModel.load();

      final price =
          viewModel.state.rails.single.products.single.cheapestIn('usd');

      expect(price, isA<Money>());
      expect(price, Money.of(1999, 'usd'));
    });
  });

  group('changeCurrency', () {
    test('reloads in the currency asked for', () async {
      await viewModel.load();
      await viewModel.changeCurrency('eur');

      expect(viewModel.state.currencyCode, 'eur');
      expect(
        viewModel.state.rails.single.products.single.cheapestIn('eur'),
        Money.of(1799, 'eur'),
      );
    });
  });

  group('failure', () {
    test('reports failure rather than throwing at the screen', () async {
      final broken = CatalogViewModel(
        CatalogViewModelArgs(
          api: CommerceApi(Dio(), baseUrl: 'http://127.0.0.1:1'),
        ),
      );

      await broken.load();

      expect(broken.state.status, CatalogStatus.failed);
      expect(broken.state.isLoading, isFalse);
    });

    test('a retry after a failure can still succeed', () async {
      final broken = CatalogViewModel(
        CatalogViewModelArgs(
          api: CommerceApi(Dio(), baseUrl: 'http://127.0.0.1:1'),
        ),
      );
      await broken.load();
      expect(broken.state.status, CatalogStatus.failed);

      await viewModel.load();

      expect(viewModel.state.status, CatalogStatus.ready);
    });
  });

  group('emptiness', () {
    test('is not empty while it is still loading', () {
      expect(viewModel.state.isEmpty, isFalse);
    });

    test('is empty once a load returns nothing', () async {
      await queryExecute('DELETE FROM products', []).execute(database.executor);

      await viewModel.load();

      expect(viewModel.state.status, CatalogStatus.ready);
      expect(viewModel.state.isEmpty, isTrue);
    });
  });
}

Future<void> _seed(CommerceDatabase database) async {
  Future<void> run(String sql) =>
      queryExecute(sql, []).execute(database.executor);

  await run(
    r"INSERT INTO product_collections (id, title, handle) VALUES "
    r"('col_featured', 'Featured', 'featured')",
  );
  await run(
    r"INSERT INTO regions (id, name, currency_code, tax_rate, countries) "
    r"VALUES ('reg_us', 'United States', 'usd', 1000, 'us')",
  );
  await run(
    r"INSERT INTO products "
    r"(id, collection_id, title, handle, status) VALUES "
    r"('prod_shirt', 'col_featured', 'T-Shirt', 't-shirt', 'published')",
  );
  await run(
    r"INSERT INTO product_variants "
    r"(id, product_id, title, inventory_quantity) VALUES "
    r"('var_small', 'prod_shirt', 'Small', 50)",
  );
  await run(
    r"INSERT INTO variant_prices (variant_id, currency_code, amount) VALUES "
    r"('var_small', 'usd', 1999), "
    r"('var_small', 'eur', 1799)",
  );
}
