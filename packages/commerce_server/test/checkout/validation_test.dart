import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late CheckoutHarness harness;

  setUp(() async => harness = await CheckoutHarness.start());
  tearDown(() async => harness.stop());

  group('checkout validation', () {
    test('an invalid bearer token cannot downgrade to a guest', () async {
      final request = harness.client.post('/store/carts')
        ..bearer('not-a-real-token');

      (await request.send()).assertUnauthorized();
    });

    test('a cart nobody started', () async {
      (await harness.checkout('nope')).assertNotFound();
    });

    test('an empty cart', () async {
      final created = await harness.client.post('/store/carts').send();
      final cartId =
          CartView.fromJson(created.json! as Map<String, Object?>).cart.id;

      (await harness.checkout(cartId)).assertUnprocessable();
    });

    test('a cart without a payment selection', () async {
      final cartId = await harness.cartWith('var_small');
      (await harness.chooseStandardShipping(cartId)).assertOk();

      final response = await (harness.client.post('/store/checkout')
            ..json({
              'cart_id': cartId,
              'email': 'ada@example.com',
              'shipping_address': harness.address(),
            }))
          .send();

      response
        ..assertUnprocessable()
        ..assertJsonContains({
          'error': 'Select a payment method before checkout',
        });
    });

    test('a cart without a delivery selection', () async {
      final cartId = await harness.cartWith('var_small');
      final payment = harness.client
          .post('/store/carts/$cartId/payment-sessions')
        ..json({'provider_id': 'manual'});
      (await payment.send()).assertOk();

      final response = await (harness.client.post('/store/checkout')
            ..json({
              'cart_id': cartId,
              'email': 'ada@example.com',
              'shipping_address': harness.address(),
            }))
          .send();

      response
        ..assertUnprocessable()
        ..assertJsonContains({
          'error': 'Select a delivery method before checkout',
        });
      expect(await harness.stockOf('var_small'), 50);
      final orders = await queryRaw(
        'SELECT COUNT(*) FROM orders WHERE cart_id = \$1',
        [cartId],
      ).fetch(harness.database.connection as Executor);
      expect(orders.single.readIndex<int>(0), 0);
    });

    test('a provider disabled after selection', () async {
      final cartId = await harness.cartWith('var_small');
      (await harness.chooseStandardShipping(cartId)).assertOk();
      final selected = harness.client
          .post('/store/carts/$cartId/payment-sessions')
        ..json({'provider_id': 'manual'});
      (await selected.send()).assertOk();
      await queryExecute(
        r"UPDATE region_payment_providers SET enabled = 0 "
        r"WHERE region_id = 'reg_us' AND provider_id = 'manual'",
        const [],
      ).execute(harness.database.executor);

      final request = harness.client.post('/store/checkout')
        ..json({
          'cart_id': cartId,
          'email': 'ada@example.com',
          'shipping_address': harness.address(),
        });

      (await request.send()).assertUnprocessable();
    });

    test('an address that is not an email, naming the field', () async {
      final cartId = await harness.cartWith('var_small');

      (await harness.checkout(cartId, email: 'not-an-email'))
        ..assertUnprocessable()
        ..assertJsonContains({
          'error': 'Validation failed',
          'fields': {
            'email': ['Enter a valid email address'],
          },
        });
    });

    test('a shipping address missing its recipient, named as nested', () async {
      final cartId = await harness.cartWith('var_small');

      (await harness.checkout(
        cartId,
        shipping: harness.address(firstName: ''),
      ))
        ..assertUnprocessable()
        ..assertJsonContains({
          'error': 'Validation failed',
          'fields': {
            'shippingAddress.firstName': ['Enter a first name'],
          },
        });
    });
  });
}
