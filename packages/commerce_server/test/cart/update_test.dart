import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient client;
  var counter = 0;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_cart');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await _seed(database);
    client = TestClient(
      buildApp(
        database,
        nextId: () => 'id_${++counter}',
        now: () => DateTime.utc(2026, 9, 5),
      ),
    );
  });

  tearDown(() async {
    await client.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  Future<String> newCart() async {
    final response = await client.post('/store/carts').send();
    return CartView.fromJson(response.json! as Map<String, Object?>).cart.id;
  }

  Future<TestResponse> addLine(
    String cartId,
    String variantId, {
    int? quantity,
  }) =>
      (client.post('/store/carts/$cartId/line-items')
            ..json({
              'variant_id': variantId,
              if (quantity != null) 'quantity': quantity,
            }))
          .send();

  group('POST /store/carts', () {
    test('starts an empty cart in the default region', () async {
      final response = await client.post('/store/carts').send();

      response.assertCreated();
      final cart =
          CartView.fromJson(response.json! as Map<String, Object?>).cart;

      expect(cart.isEmpty, isTrue);
      expect(cart.region.currencyCode, 'usd');
      expect(cart.total, Money.zero('usd'));
    });
  });

  group('GET /store/carts/{id}', () {
    test('answers 404 for a cart nobody started', () async {
      (await client.get('/store/carts/nope').send()).assertNotFound();
    });

    test('carries the totals a storefront renders', () async {
      final cartId = await newCart();
      await addLine(cartId, 'var_small', quantity: 2);

      final response = await client.get('/store/carts/$cartId').send();

      response
        ..assertOk()
        ..assertJsonContains({
          'item_count': 2,
          'subtotal': {'amount': 3998, 'currency_code': 'usd'},
          'tax': {'amount': 400, 'currency_code': 'usd'},
          'total': {'amount': 4398, 'currency_code': 'usd'},
        });
    });
  });

  group('POST /store/carts/{id}/line-items', () {
    test('adds a line and returns the cart', () async {
      final cartId = await newCart();

      final response = await addLine(cartId, 'var_small', quantity: 2);

      response.assertOk();
      final cart =
          CartView.fromJson(response.json! as Map<String, Object?>).cart;

      expect(cart.items, hasLength(1));
      expect(cart.items.single.quantity, 2);
      expect(cart.items.single.unitPrice, Money.of(1999, 'usd'));
      expect(cart.items.single.title, 'T-Shirt');
      expect(cart.items.single.variantTitle, 'Small');
      expect(cart.items.single.productHandle, 't-shirt');
    });

    test('defaults the quantity to one', () async {
      final cartId = await newCart();

      final response = await addLine(cartId, 'var_small');
      final cart =
          CartView.fromJson(response.json! as Map<String, Object?>).cart;

      expect(cart.items.single.quantity, 1);
    });

    test('merges a second add of the same variant', () async {
      final cartId = await newCart();
      await addLine(cartId, 'var_small', quantity: 1);

      final response = await addLine(cartId, 'var_small', quantity: 2);
      final cart =
          CartView.fromJson(response.json! as Map<String, Object?>).cart;

      expect(cart.items, hasLength(1));
      expect(cart.items.single.quantity, 3);
    });

    test('holds the price the line was added at, not the current one',
        () async {
      final cartId = await newCart();
      await addLine(cartId, 'var_small', quantity: 1);

      await queryExecute(
        r"UPDATE variant_prices SET amount = 9999 "
        r"WHERE variant_id = 'var_small' AND currency_code = 'usd'",
        [],
      ).execute(database.executor);

      final response = await client.get('/store/carts/$cartId').send();
      final cart =
          CartView.fromJson(response.json! as Map<String, Object?>).cart;

      expect(cart.items.single.unitPrice, Money.of(1999, 'usd'));
      expect(cart.subtotal, Money.of(1999, 'usd'));
    });

    test('answers 409 when the stock runs out, not 422', () async {
      final cartId = await newCart();

      final response = await addLine(cartId, 'var_large', quantity: 3);

      response
        ..assertConflict()
        ..assertJsonContains({'error': 'Not enough stock for "var_large"'});
    });

    test('counts what is already in the cart against the stock', () async {
      final cartId = await newCart();
      (await addLine(cartId, 'var_large', quantity: 2)).assertOk();

      (await addLine(cartId, 'var_large')).assertConflict();
    });

    test('answers 422 for a variant not sold in this currency', () async {
      final cartId = await newCart();

      (await addLine(cartId, 'var_euro_only')).assertUnprocessable();
    });

    test('answers 404 for a cart nobody started', () async {
      (await addLine('nope', 'var_small')).assertNotFound();
    });

    test('answers 422 without a variant id', () async {
      final cartId = await newCart();

      (await (client.post('/store/carts/$cartId/line-items')..json({})).send())
          .assertUnprocessable();
    });

    test('answers 422 for a quantity below one', () async {
      final cartId = await newCart();

      (await addLine(cartId, 'var_small', quantity: 0)).assertUnprocessable();
    });

    test('answers 415 for a body that is not JSON at all', () async {
      final cartId = await newCart();

      // text/plain to a JSON endpoint is the wrong media type, not a malformed
      // body, and the runtime says so rather than collapsing both into 400.
      (await (client.post('/store/carts/$cartId/line-items')..text('not json'))
              .send())
          .assertUnsupportedMediaType();
    });
  });
}

Future<void> _seed(CommerceDatabase database) async {
  Future<void> run(String sql) =>
      queryExecute(sql, []).execute(database.executor);

  await run(
    r"INSERT INTO regions (id, name, currency_code, tax_rate, countries) "
    r"VALUES ('reg_us', 'United States', 'usd', 1000, 'us')",
  );
  await run(
    r"INSERT INTO products (id, title, handle, status) VALUES "
    r"('prod_shirt', 'T-Shirt', 't-shirt', 'published')",
  );
  await run(
    r"INSERT INTO product_variants "
    r"(id, product_id, title, inventory_quantity) VALUES "
    r"('var_small', 'prod_shirt', 'Small', 50), "
    r"('var_large', 'prod_shirt', 'Large', 2), "
    r"('var_euro_only', 'prod_shirt', 'Euro', 5)",
  );
  await run(
    r"INSERT INTO variant_prices (variant_id, currency_code, amount) VALUES "
    r"('var_small', 'usd', 1999), "
    r"('var_large', 'usd', 2199), "
    r"('var_euro_only', 'eur', 1799)",
  );
}
