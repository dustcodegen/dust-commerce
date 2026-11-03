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
    directory = await Directory.systemTemp.createTemp('commerce_cart_mutation');
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

  Future<CartView> addLine(String cartId, String variantId) async {
    final response = await (client.post('/store/carts/$cartId/line-items')
          ..json({'variant_id': variantId}))
        .send();
    return CartView.fromJson(response.json! as Map<String, Object?>);
  }

  group('POST /store/carts/{id}/line-items', () {
    test('rejects a variant outside the cart sales channel', () async {
      await _channel(database, 'sc_wholesale');
      final cartId = await newCart();

      final response = await (client.post('/store/carts/$cartId/line-items')
            ..json({'variant_id': 'var_small'}))
          .send();

      response.assertUnprocessable();
    });
  });

  group('PATCH /store/carts/{id}/line-items/{lineId}', () {
    test('replaces quantity and returns authoritative totals', () async {
      final cartId = await newCart();
      final lineId = (await addLine(cartId, 'var_small')).cart.items.single.id;

      final response = await (client.patch(
        '/store/carts/$cartId/line-items/$lineId',
      )..json({'quantity': 3}))
          .send();

      response.assertOk();
      final view = CartView.fromJson(response.json! as Map<String, Object?>);
      expect(view.cart.items.single.quantity, 3);
      expect(view.itemCount, 3);
      expect(view.subtotal, Money.of(5997, 'usd'));
      expect(view.total, Money.of(6597, 'usd'));
    });

    test('rejects inventory conflicts without changing the line', () async {
      final cartId = await newCart();
      final lineId = (await addLine(cartId, 'var_large')).cart.items.single.id;

      final response = await (client.patch(
        '/store/carts/$cartId/line-items/$lineId',
      )..json({'quantity': 3}))
          .send();

      response.assertConflict();
      final current = await client.get('/store/carts/$cartId').send();
      final unchanged =
          CartView.fromJson(current.json! as Map<String, Object?>);
      expect(unchanged.cart.items.single.quantity, 1);
    });

    test('rejects a line whose product left the cart channel', () async {
      await _channel(database, 'sc_web');
      final cartId = await newCart();
      final lineId = (await addLine(cartId, 'var_small')).cart.items.single.id;
      await _run(
        database,
        "UPDATE product_sales_channels SET deleted_at = "
        "'2026-09-26T00:00:00.000Z' WHERE product_id = 'prod_shirt'",
      );

      final response = await (client.patch(
        '/store/carts/$cartId/line-items/$lineId',
      )..json({'quantity': 2}))
          .send();

      response.assertConflict();
    });

    test('does not mutate a line from another cart', () async {
      final firstCart = await newCart();
      final secondCart = await newCart();
      final lineId =
          (await addLine(firstCart, 'var_small')).cart.items.single.id;

      final response = await (client.patch(
        '/store/carts/$secondCart/line-items/$lineId',
      )..json({'quantity': 2}))
          .send();

      response.assertNotFound();
    });

    test('validates replacement quantities', () async {
      final cartId = await newCart();
      final lineId = (await addLine(cartId, 'var_small')).cart.items.single.id;

      (await (client.patch('/store/carts/$cartId/line-items/$lineId')
                ..json({'quantity': 0}))
              .send())
          .assertUnprocessable();
    });
  });

  group('DELETE /store/carts/{id}/line-items/{lineId}', () {
    test('removes the line and returns the empty cart totals', () async {
      final cartId = await newCart();
      final lineId = (await addLine(cartId, 'var_small')).cart.items.single.id;

      final response =
          await client.delete('/store/carts/$cartId/line-items/$lineId').send();

      response.assertOk();
      final view = CartView.fromJson(response.json! as Map<String, Object?>);
      expect(view.cart.items, isEmpty);
      expect(view.itemCount, 0);
      expect(view.total, Money.zero('usd'));
    });

    test('does not remove a line from another cart', () async {
      final firstCart = await newCart();
      final secondCart = await newCart();
      final lineId =
          (await addLine(firstCart, 'var_small')).cart.items.single.id;

      (await client
              .delete('/store/carts/$secondCart/line-items/$lineId')
              .send())
          .assertNotFound();
      final response = await client.get('/store/carts/$firstCart').send();
      final first = CartView.fromJson(response.json! as Map<String, Object?>);
      expect(first.cart.items, hasLength(1));
    });
  });
}

Future<void> _channel(CommerceDatabase database, String productChannel) async {
  await _run(
    database,
    "INSERT INTO sales_channels (id, name) VALUES "
    "('sc_web', 'Online Store'), ('sc_wholesale', 'Wholesale')",
  );
  await _run(
    database,
    "INSERT INTO product_sales_channels "
    "(id, product_id, sales_channel_id) VALUES "
    "('psc_shirt', 'prod_shirt', '$productChannel')",
  );
}

Future<void> _seed(CommerceDatabase database) async {
  await _run(
    database,
    r"INSERT INTO regions (id, name, currency_code, tax_rate, countries) "
    r"VALUES ('reg_us', 'United States', 'usd', 1000, 'us')",
  );
  await _run(
    database,
    r"INSERT INTO products (id, title, handle, status) VALUES "
    r"('prod_shirt', 'T-Shirt', 't-shirt', 'published')",
  );
  await _run(
    database,
    r"INSERT INTO product_variants "
    r"(id, product_id, title, inventory_quantity) VALUES "
    r"('var_small', 'prod_shirt', 'Small', 50), "
    r"('var_large', 'prod_shirt', 'Large', 2)",
  );
  await _run(
    database,
    r"INSERT INTO variant_prices (variant_id, currency_code, amount) VALUES "
    r"('var_small', 'usd', 1999), ('var_large', 'usd', 2199)",
  );
}

Future<void> _run(CommerceDatabase database, String sql) =>
    queryExecute(sql, const []).execute(database.executor);
