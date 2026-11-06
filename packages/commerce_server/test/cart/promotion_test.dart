import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

import 'promotion_test_support.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient client;
  var counter = 0;

  setUp(() async {
    counter = 0;
    directory = await Directory.systemTemp.createTemp('commerce_promo');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedPromotionFixture(database);
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

  Future<String> cartWorth(int unitPrice) async {
    final created = await client.post('/store/carts').send();
    final id = CartView.fromJson(created.json! as Map<String, Object?>).cart.id;
    (await (client.post('/store/carts/$id/line-items')
              ..json({'variant_id': 'var_small', 'quantity': 1}))
            .send())
        .assertOk();
    return id;
  }

  Future<TestResponse> apply(String cartId, String code) =>
      (client.post('/store/carts/$cartId/promotions')..json({'code': code}))
          .send();

  group('POST /store/carts/{id}/promotions', () {
    test('a percentage comes off, and tax follows it down', () async {
      final cartId = await cartWorth(2000);

      final response = await apply(cartId, 'SAVE10');

      response
        ..assertOk()
        ..assertJsonContains({
          'subtotal': {'amount': 2000, 'currency_code': 'usd'},
          'discount_total': {'amount': 200, 'currency_code': 'usd'},
          // 10% tax on (2000 - 200)
          'tax': {'amount': 180, 'currency_code': 'usd'},
          'total': {'amount': 1980, 'currency_code': 'usd'},
        });
      final applied = CartView.fromJson(
        response.json! as Map<String, Object?>,
      ).cart.promotions.single;
      expect(applied.id, 'p1');
      expect(applied.code, 'SAVE10');
      expect(applied.type, PromotionType.percentage);
      expect(applied.value, 1000);
      expect(applied.currencyCode, isNull);
      expect(applied.amount, Money.of(200, 'usd'));
    });

    test('a fixed amount comes off', () async {
      final cartId = await cartWorth(2000);

      (await apply(cartId, 'TENOFF')).assertJsonContains({
        'discount_total': {'amount': 1000, 'currency_code': 'usd'},
        'total': {'amount': 1100, 'currency_code': 'usd'},
      });
    });

    test('the code is not case sensitive', () async {
      final cartId = await cartWorth(2000);

      (await apply(cartId, 'save10')).assertOk();
    });

    test('recalculates its snapshot when line quantity changes', () async {
      final cartId = await cartWorth(2000);
      await apply(cartId, 'SAVE10');
      final current = await client.get('/store/carts/$cartId').send();
      final lineId = CartView.fromJson(
        current.json! as Map<String, Object?>,
      ).cart.items.single.id;

      final changed = await (client.patch(
        '/store/carts/$cartId/line-items/$lineId',
      )..json({'quantity': 2}))
          .send();

      changed
        ..assertOk()
        ..assertJsonContains({
          'discount_total': {'amount': 400, 'currency_code': 'usd'},
        });
      final applied = CartView.fromJson(
        changed.json! as Map<String, Object?>,
      ).cart.promotions.single;
      expect(applied.code, 'SAVE10');
      expect(applied.amount, Money.of(400, 'usd'));
    });

    test('applying a second code replaces the first', () async {
      final cartId = await cartWorth(2000);
      await apply(cartId, 'SAVE10');

      (await apply(cartId, 'TENOFF')).assertJsonContains({
        'discount_total': {'amount': 1000, 'currency_code': 'usd'},
      });
    });

    test('a discount never makes a total negative', () async {
      final cartId = await cartWorth(2000);

      (await apply(cartId, 'HUGE')).assertJsonContains({
        'discount_total': {'amount': 2000, 'currency_code': 'usd'},
        'total': {'amount': 0, 'currency_code': 'usd'},
      });
    });

    test('an unknown code and an expired one answer differently', () async {
      final cartId = await cartWorth(2000);

      final unknown = await apply(cartId, 'NOPE');
      final expired = await apply(cartId, 'LASTYEAR');

      unknown
        ..assertUnprocessable()
        ..assertTextContains('no promotion with the code');
      expired
        ..assertUnprocessable()
        ..assertTextContains('is not available');
    });

    test('a code that has run out of redemptions is refused', () async {
      final cartId = await cartWorth(2000);

      (await apply(cartId, 'SPENT')).assertUnprocessable();
    });

    test('a retired promotion cannot be redeemed again', () async {
      final cartId = await cartWorth(2000);
      await queryExecute('''
UPDATE promotions
SET deleted_at = CURRENT_TIMESTAMP
WHERE code = 'SAVE10'
''', []).execute(database.executor);

      final response = await apply(cartId, 'SAVE10');

      response
        ..assertUnprocessable()
        ..assertTextContains('no promotion with the code');
    });

    test('a fixed code in another currency is refused', () async {
      final cartId = await cartWorth(2000);

      (await apply(cartId, 'EUROOFF')).assertUnprocessable();
    });

    test('answers 404 for a cart nobody started', () async {
      (await apply('nope', 'SAVE10')).assertNotFound();
    });

    test('answers 422 without a code', () async {
      final cartId = await cartWorth(2000);

      (await (client.post('/store/carts/$cartId/promotions')..json({})).send())
          .assertUnprocessable();
    });
  });

  group('DELETE /store/carts/{id}/promotions', () {
    test('takes the discount back off', () async {
      final cartId = await cartWorth(2000);
      await apply(cartId, 'SAVE10');

      final response =
          await client.delete('/store/carts/$cartId/promotions').send();

      response
        ..assertOk()
        ..assertJsonContains({
          'discount_total': {'amount': 0, 'currency_code': 'usd'},
          'total': {'amount': 2200, 'currency_code': 'usd'},
        });
    });

    test('removing nothing is not an error', () async {
      final cartId = await cartWorth(2000);

      (await client.delete('/store/carts/$cartId/promotions').send())
          .assertOk();
    });
  });
}
