import 'package:test/test.dart';

import '../checkout/support.dart';

void main() {
  late CheckoutHarness harness;

  setUp(() async => harness = await CheckoutHarness.start());
  tearDown(() => harness.stop());

  test('a customer order can only be paid by its authenticated owner',
      () async {
    final owner = await harness.account('owner@example.com');
    final stranger = await harness.account('stranger@example.com');
    final cartId = await harness.cartWith('var_small', token: owner.token);
    final placed = await harness.checkout(cartId, token: owner.token);
    final orderId = (placed.json! as Map<String, Object?>)['id']! as String;

    (await harness.client
            .post('/store/orders/$orderId/payments?email=owner@example.com')
            .send())
        .assertNotFound();

    final wrong = harness.client.post('/store/orders/$orderId/payments')
      ..bearer(stranger.token);
    (await wrong.send()).assertNotFound();

    final own = harness.client.post('/store/orders/$orderId/payments')
      ..bearer(owner.token);
    (await own.send()).assertCreated();
  });
}
