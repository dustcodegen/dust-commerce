import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

import '../checkout/support.dart';

void main() {
  late CheckoutHarness harness;

  setUp(() async => harness = await CheckoutHarness.start());
  tearDown(() => harness.stop());

  Future<TestResponse> choose(String cartId, String providerId) =>
      (harness.client.post('/store/carts/$cartId/payment-sessions')
            ..json({'provider_id': providerId}))
          .send();

  test('retains the allowlisted provider across cart reloads', () async {
    final cartId = await harness.cartWith('var_small');

    final selected = await choose(cartId, 'manual');

    selected.assertOk();
    expect(
      CartView.fromJson(selected.json! as Map<String, Object?>)
          .cart
          .paymentSession,
      const CartPaymentSession(providerId: 'manual'),
    );
    final reloaded = await harness.client.get('/store/carts/$cartId').send();
    expect(
      CartView.fromJson(reloaded.json! as Map<String, Object?>)
          .cart
          .paymentSession,
      const CartPaymentSession(providerId: 'manual'),
    );
  });

  test('retrying the same selection keeps one session', () async {
    final cartId = await harness.cartWith('var_small');

    (await choose(cartId, 'manual')).assertOk();
    (await choose(cartId, 'manual')).assertOk();

    final rows = await queryRaw(
      'SELECT COUNT(*) FROM cart_payment_sessions WHERE cart_id = \$1',
      [cartId],
    ).fetch(harness.database.connection as Executor);
    expect(rows.single.readIndex<int>(0), 1);
  });

  test('rejects a provider the storefront does not offer', () async {
    final cartId = await harness.cartWith('var_small');

    final response = await choose(cartId, 'invented');

    response.assertUnprocessable();
    final reloaded = await harness.client.get('/store/carts/$cartId').send();
    expect(
      CartView.fromJson(reloaded.json! as Map<String, Object?>)
          .cart
          .paymentSession,
      isNull,
    );
  });

  test('rejects a configured provider after the region disables it', () async {
    final cartId = await harness.cartWith('var_small');
    await queryExecute(
      r"UPDATE region_payment_providers SET enabled = 0 "
      r"WHERE region_id = 'reg_us' AND provider_id = 'manual'",
      const [],
    ).execute(harness.database.executor);

    final response = await choose(cartId, 'manual');

    response.assertUnprocessable();
  });

  test('uses the shared route guard for a customer-owned cart', () async {
    final owner = await harness.account('owner@example.com');
    final stranger = await harness.account('stranger@example.com');
    final cartId = await harness.cartWith('var_small', token: owner.token);

    (await choose(cartId, 'manual')).assertNotFound();
    final wrong = harness.client.post('/store/carts/$cartId/payment-sessions')
      ..bearer(stranger.token)
      ..json({'provider_id': 'manual'});
    (await wrong.send()).assertNotFound();
    final right = harness.client.post('/store/carts/$cartId/payment-sessions')
      ..bearer(owner.token)
      ..json({'provider_id': 'manual'});
    (await right.send()).assertOk();
  });
}
