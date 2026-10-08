import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import 'list_support.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late CatalogCountRepository counts;
  late CatalogListRepository lists;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_repo');
    database = CommerceDatabase.open(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    counts = CatalogCountRepository(database.executor);
    lists = CatalogListRepository(database.executor);
    await seedCatalogList(database);
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  group('listPublished', () {
    Future<Result<List<ProductResponse>, SqlxError>> list({
      String currency = 'usd',
      int limit = 10,
      int offset = 0,
      String? collection,
      String categories = '[]',
      String labels = '[]',
      int? minPrice,
      int? maxPrice,
      int onSale = 0,
      String options = '[]',
      String sortBy = 'created_at',
    }) =>
        lists.listPublished(
          currency,
          limit,
          offset,
          null,
          collection,
          categories,
          labels,
          sortBy,
          minPrice,
          maxPrice,
          onSale,
          options,
        );

    Future<Result<int, SqlxError>> count({
      String currency = 'usd',
      String categories = '[]',
      String labels = '[]',
      int? minPrice,
      int? maxPrice,
      int onSale = 0,
      String options = '[]',
    }) =>
        counts.countPublished(
          currency,
          null,
          null,
          categories,
          labels,
          minPrice,
          maxPrice,
          onSale,
          options,
        );

    test('returns only published products', () async {
      final result = await list();
      final handles = ok(result).map((row) => row.handle);

      expect(handles, ['mug', 't-shirt']);
      expect(handles, isNot(contains('secret-hoodie')));
    });

    test('lists only products sold through the storefront channel', () async {
      await _run(
        database,
        "INSERT INTO sales_channels (id, name) VALUES "
        "('sc_web', 'Online Store'), ('sc_wholesale', 'Wholesale')",
      );
      await _run(
        database,
        "INSERT INTO product_sales_channels "
        "(id, product_id, sales_channel_id) VALUES "
        "('psc_shirt', 'prod_shirt', 'sc_web'), "
        "('psc_mug', 'prod_mug', 'sc_wholesale')",
      );

      expect(ok(await list()).map((row) => row.handle), ['t-shirt']);
      expect(ok(await count()), 1);
    });

    test('pages, so a large catalogue does not arrive at once', () async {
      final first = await list(limit: 1);
      final second = await list(limit: 1, offset: 1);

      expect(ok(first).single.handle, 'mug');
      expect(ok(second).single.handle, 't-shirt');
    });

    test('sorts before paging through the Store API order values', () async {
      expect(
          ok(await list(limit: 1, sortBy: 'relevance')).single.handle, 'mug');
      expect(ok(await list(limit: 1, sortBy: 'title_desc')).single.handle,
          't-shirt');
      expect(
          ok(await list(limit: 1, sortBy: 'price_asc')).single.handle, 'mug');
      expect(ok(await list(limit: 1, sortBy: 'price_desc')).single.handle,
          't-shirt');
    });

    test('counts what it would page through', () async {
      expect(ok(await count()), 2);
    });

    test('filters products with active sale prices', () async {
      expect(ok(await list(onSale: 1)).map((row) => row.handle), ['t-shirt']);
      expect(ok(await count(onSale: 1)), 1);
    });

    test('filters by collection, category and tag', () async {
      final byCollection = await list(collection: 'summer');
      final byCategory = await list(categories: '["shirts"]');
      final byTag = await list(labels: '["Cotton"]');
      final byEitherCategory = await list(categories: '["shirts","missing"]');

      expect(ok(byCollection).map((row) => row.handle), ['t-shirt']);
      expect(ok(byCategory).map((row) => row.handle), ['t-shirt']);
      expect(ok(byTag).map((row) => row.handle), ['t-shirt']);
      expect(ok(byEitherCategory).map((row) => row.handle), ['t-shirt']);
    });

    test('filters by stable option value id', () async {
      final matching = await list(options: '["optval_large"]');
      final impossible = await list(options: '["optval_large","missing"]');
      final missing = await list(options: '["not-a-value"]');

      expect(ok(matching).map((row) => row.handle), ['t-shirt']);
      expect(ok(impossible), isEmpty);
      expect(ok(missing), isEmpty);
      expect(
        ok(await count(options: '["optval_large"]')),
        1,
      );
      expect(ok(await count(options: '["optval_large","missing"]')), 0);
    });

    test('excludes products and option choices unavailable in the currency',
        () async {
      final eur = await list(currency: 'eur');
      final unavailableChoice =
          await list(currency: 'eur', options: '["optval_large"]');

      expect(ok(eur).map((row) => row.handle), ['t-shirt']);
      expect(ok(eur).single.variants.map((variant) => variant.id), [
        'var_small',
      ]);
      expect(ok(unavailableChoice), isEmpty);
      expect(
        ok(await count(currency: 'eur')),
        1,
      );
    });

    test('filters by cheapest price in the requested currency', () async {
      final fromTen = await list(minPrice: 1000);
      final upToTen = await list(maxPrice: 1000);

      expect(ok(fromTen).map((row) => row.handle), ['t-shirt']);
      expect(ok(upToTen).map((row) => row.handle), ['mug']);
      expect(
        ok(await count(minPrice: 1000)),
        1,
      );
    });
  });
}

Future<void> _run(CommerceDatabase database, String sql) =>
    queryExecute(sql, const []).execute(database.executor);
