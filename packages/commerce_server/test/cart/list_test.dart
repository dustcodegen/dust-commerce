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
    counter = 0;
    directory = await Directory.systemTemp.createTemp('commerce_ship');
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

  Future<String> cartWithGoods() async {
    final created = await (client.post('/store/carts')
          ..json({'region_id': 'reg_us'}))
        .send();
    final id = CartView.fromJson(created.json! as Map<String, Object?>).cart.id;
    (await (client.post('/store/carts/$id/line-items')
              ..json({'variant_id': 'var_small', 'quantity': 1}))
            .send())
        .assertOk();
    return id;
  }

  Future<TestResponse> choose(String cartId, String optionId) =>
      (client.post('/store/carts/$cartId/shipping-method')
            ..json({'option_id': optionId}))
          .send();

  group('GET /store/carts/{id}/shipping-options', () {
    test("offers what this cart's region sells, cheapest first", () async {
      final cartId = await cartWithGoods();

      final response =
          await client.get('/store/carts/$cartId/shipping-options').send();

      response
        ..assertOk()
        ..assertJsonContains({'count': 3});

      final body = response.json! as Map<String, Object?>;
      final freeJson = (body['shipping_options']! as List<Object?>).first!
          as Map<String, Object?>;
      expect(
        freeJson.keys.toSet(),
        {
          'amount',
          'fulfillment_type',
          'name',
          'option_id',
          'pickup_address',
          'pickup_name',
          'price_rules',
        },
      );
      expect(
        (freeJson['price_rules']! as List<Object?>).single,
        {'attribute': 'item_total', 'operator': 'gte', 'value': 3998},
      );
      final options = (body['shipping_options']! as List<Object?>)
          .map((it) => ShippingOption.fromJson(it! as Map<String, Object?>))
          .toList();

      expect(
        options.map((it) => it.optionId),
        ['so_free', 'so_standard', 'so_express'],
      );
      expect(options.first.amount, Money.zero('usd'));
      expect(options.first.priceRules.single.value, 3998);
    });

    test("never offers another region's option", () async {
      final cartId = await cartWithGoods();

      final response =
          await client.get('/store/carts/$cartId/shipping-options').send();
      final body = response.json! as Map<String, Object?>;
      final ids = (body['shipping_options']! as List<Object?>)
          .map((it) => (it! as Map<String, Object?>)['option_id'])
          .toList();

      expect(ids, isNot(contains('so_eu_only')));
    });

    test('answers 404 for a cart nobody started', () async {
      (await client.get('/store/carts/nope/shipping-options').send())
          .assertNotFound();
    });
  });

  group('POST /store/carts/{id}/shipping-method', () {
    test('adds shipping to the total, and taxes it with the goods', () async {
      final cartId = await cartWithGoods();

      final response = await choose(cartId, 'so_standard');

      response
        ..assertOk()
        ..assertJsonContains({
          'subtotal': {'amount': 1999, 'currency_code': 'usd'},
          'shipping_total': {'amount': 500, 'currency_code': 'usd'},
          // 10% of (1999 + 500) = 249.9, rounded half up
          'tax': {'amount': 250, 'currency_code': 'usd'},
          'total': {'amount': 2749, 'currency_code': 'usd'},
        });
    });

    test('replaces an earlier choice rather than adding a second', () async {
      final cartId = await cartWithGoods();
      await choose(cartId, 'so_standard');

      final response = await choose(cartId, 'so_express');

      response
        ..assertOk()
        ..assertJsonContains({
          'shipping_total': {'amount': 1500, 'currency_code': 'usd'},
        });
    });

    test('holds the price it was quoted, not a later one', () async {
      final cartId = await cartWithGoods();
      await choose(cartId, 'so_standard');

      await queryExecute(
        r"UPDATE shipping_options SET amount = 9999 WHERE id = 'so_standard'",
        [],
      ).execute(database.executor);

      final response = await client.get('/store/carts/$cartId').send();

      response.assertJsonContains({
        'shipping_total': {'amount': 500, 'currency_code': 'usd'},
      });
    });

    test('refuses an option from another region', () async {
      final cartId = await cartWithGoods();

      (await choose(cartId, 'so_eu_only')).assertUnprocessable();
    });

    test('refuses an option nobody offers', () async {
      final cartId = await cartWithGoods();

      (await choose(cartId, 'nope')).assertUnprocessable();
    });

    test('answers 404 for a cart nobody started', () async {
      (await choose('nope', 'so_standard')).assertNotFound();
    });

    test('answers 422 without an option id', () async {
      final cartId = await cartWithGoods();

      (await (client.post('/store/carts/$cartId/shipping-method')..json({}))
              .send())
          .assertUnprocessable();
    });
  });
}

Future<void> _seed(CommerceDatabase database) async {
  Future<void> run(String sql) =>
      queryExecute(sql, []).execute(database.executor);

  await run(
    r"INSERT INTO regions (id, name, currency_code, tax_rate, countries) "
    r"VALUES ('reg_us', 'United States', 'usd', 1000, 'us'), "
    r"('reg_eu', 'Europe', 'eur', 2000, 'de')",
  );
  await run(
    r"INSERT INTO shipping_options (id, region_id, name, amount, currency_code)"
    r" VALUES "
    r"('so_free', 'reg_us', 'Free shipping', 0, 'usd'), "
    r"('so_standard', 'reg_us', 'Standard', 500, 'usd'), "
    r"('so_express', 'reg_us', 'Express', 1500, 'usd'), "
    r"('so_eu_only', 'reg_eu', 'EU post', 400, 'eur')",
  );
  await run(
    r"INSERT INTO shipping_option_price_rules "
    r"(id, shipping_option_id, attribute, operator, value) VALUES "
    r"('rule_free', 'so_free', 'item_total', 'gte', 3998)",
  );
  await run(
    r"INSERT INTO products (id, title, handle, status) VALUES "
    r"('prod_shirt', 'T-Shirt', 't-shirt', 'published')",
  );
  await run(
    r"INSERT INTO product_variants "
    r"(id, product_id, title, inventory_quantity) VALUES "
    r"('var_small', 'prod_shirt', 'Small', 50)",
  );
  await run(
    r"INSERT INTO variant_prices (variant_id, currency_code, amount) VALUES "
    r"('var_small', 'usd', 1999)",
  );
}
