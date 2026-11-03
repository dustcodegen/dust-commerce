import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

/// Raw SQL access required by `fetch` beyond `DatabaseClient.executor`.
extension on CommerceDatabase {
  Executor get raw => connection as Executor;
}

void main() {
  late Directory directory;
  late CommerceDatabase database;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_schema');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  Future<List<String>> columnsOf(String table) async {
    final rows =
        await queryRaw('PRAGMA table_info($table)', []).fetch(database.raw);
    return rows.map((row) => row.readIndex<String>(1)).toList();
  }

  group('the shape money is stored in', () {
    test('prices are integer minor units, keyed by variant and currency',
        () async {
      final columns = await columnsOf('variant_prices');

      expect(columns, containsAll(<String>['variant_id', 'currency_code']));
      expect(columns, contains('amount'));
    });

    test('an order stores its totals rather than deriving them', () async {
      final columns = await columnsOf('orders');

      expect(
        columns,
        containsAll(<String>['cart_id', 'subtotal', 'tax', 'total']),
      );
    });

    test('product facts and gallery order are explicit columns', () async {
      expect(
        await columnsOf('products'),
        containsAll(<String>[
          'material',
          'collection_id',
          'origin_country',
          'type_id',
          'weight',
          'length',
          'width',
          'height',
        ]),
      );
      expect(await columnsOf('product_images'), containsAll(['url', 'rank']));
      expect(
        await columnsOf('product_image_variants'),
        containsAll(['image_id', 'variant_id', 'created_at']),
      );
      expect(await columnsOf('product_options'), isNot(contains('values_csv')));
      expect(
        await columnsOf('product_options'),
        containsAll(['id', 'title', 'is_exclusive']),
      );
      expect(
        await columnsOf('product_product_options'),
        containsAll(['product_id', 'product_option_id']),
      );
      expect(
        await columnsOf('product_product_option_values'),
        containsAll(['product_product_option_id', 'product_option_value_id']),
      );
      expect(
        await columnsOf('product_option_values'),
        containsAll(['id', 'option_id', 'value', 'rank']),
      );
      expect(
        await columnsOf('variant_option_values'),
        containsAll(['option_id', 'option_value_id']),
      );
      expect(
        await columnsOf('product_categories'),
        containsAll(['handle', 'parent_category_id', 'is_active', 'rank']),
      );
    });
  });

  group('the constraints that protect the domain', () {
    test('a variant cannot hold two prices in one currency', () async {
      await _seedVariant(database);
      await queryExecute(
        'INSERT INTO variant_prices (variant_id, currency_code, amount) '
        r"VALUES ('var_1', 'usd', 1999)",
        [],
      ).execute(database.executor);

      Future<void> duplicate() => queryExecute(
            'INSERT INTO variant_prices (variant_id, currency_code, amount) '
            r"VALUES ('var_1', 'usd', 2999)",
            [],
          ).execute(database.executor);

      await expectLater(duplicate, throwsStateError);
    });

    test('a line cannot be ordered at a quantity of zero', () async {
      await _seedVariant(database);
      await queryExecute(
        r"INSERT INTO regions (id, name, currency_code, tax_rate, countries) "
        r"VALUES ('reg_1', 'US', 'usd', 0, 'us')",
        [],
      ).execute(database.executor);
      await queryExecute(
        r"INSERT INTO carts (id, region_id, created_at) "
        r"VALUES ('cart_1', 'reg_1', '2026-09-05')",
        [],
      ).execute(database.executor);

      Future<void> zeroQuantity() => queryExecute(
            'INSERT INTO line_items (id, cart_id, variant_id, product_id, '
            'title, unit_amount, currency_code, quantity) '
            r"VALUES ('li_1', 'cart_1', 'var_1', 'prod_1', 'T', 1999, 'usd', 0)",
            [],
          ).execute(database.executor);

      await expectLater(zeroQuantity, throwsStateError);
    });

    test('a handle cannot be reused, because the storefront routes on it',
        () async {
      await _seedVariant(database);

      Future<void> reusedHandle() => queryExecute(
            r"INSERT INTO products (id, title, handle) "
            r"VALUES ('prod_2', 'Other', 't-shirt')",
            [],
          ).execute(database.executor);

      await expectLater(reusedHandle, throwsStateError);
    });

    test('an image cannot be associated with another product variant',
        () async {
      await _seedVariant(database);
      await queryExecute(
        r"INSERT INTO product_images (id, product_id, url, rank) "
        r"VALUES ('img_1', 'prod_1', 'https://example.test/one.png', 0)",
        [],
      ).execute(database.executor);
      await queryExecute(
        r"INSERT INTO products (id, title, handle) "
        r"VALUES ('prod_2', 'Other', 'other')",
        [],
      ).execute(database.executor);
      await queryExecute(
        r"INSERT INTO product_variants (id, product_id, title) "
        r"VALUES ('var_2', 'prod_2', 'Other')",
        [],
      ).execute(database.executor);

      Future<void> crossProductLink() => queryExecute(
            r"INSERT INTO product_image_variants (image_id, variant_id) "
            r"VALUES ('img_1', 'var_2')",
            [],
          ).execute(database.executor);

      await expectLater(crossProductLink, throwsStateError);
    });
  });
}

Future<void> _seedVariant(CommerceDatabase database) async {
  await queryExecute(
    r"INSERT INTO products (id, title, handle, status) "
    r"VALUES ('prod_1', 'T-Shirt', 't-shirt', 'published')",
    [],
  ).execute(database.executor);
  await queryExecute(
    r"INSERT INTO product_variants (id, product_id, title, inventory_quantity) "
    r"VALUES ('var_1', 'prod_1', 'Small', 5)",
    [],
  ).execute(database.executor);
}
