import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import '../checkout/support.dart';

void main() {
  late CheckoutHarness harness;

  setUp(() async => harness = await CheckoutHarness.start());
  tearDown(() => harness.stop());

  test('authenticated customer atomically claims a guest cart', () async {
    final customer = await harness.account('owner@example.com');
    final cartId = await harness.cartWith('var_small');

    final request = harness.client.post('/store/carts/$cartId/transfer')
      ..bearer(customer.token);
    final response = await request.send();

    response.assertOk();
    final cart = CartView.fromJson(response.json! as Map<String, Object?>).cart;
    expect(cart.customerId, customer.customerId);
    expect(cart.email, 'owner@example.com');
    expect(cart.items.single.variantId, 'var_small');

    (await harness.client.get('/store/carts/$cartId').send()).assertNotFound();
    final ownerRead = harness.client.get('/store/carts/$cartId')
      ..bearer(customer.token);
    (await ownerRead.send()).assertOk();
  });

  test('same customer can safely retry after a lost response', () async {
    final customer = await harness.account('owner@example.com');
    final cartId = await harness.cartWith('var_small');

    for (var attempt = 0; attempt < 2; attempt++) {
      final request = harness.client.post('/store/carts/$cartId/transfer')
        ..bearer(customer.token);
      (await request.send()).assertOk();
    }
  });

  test('missing auth is rejected by the route guard', () async {
    final cartId = await harness.cartWith('var_small');

    (await harness.client.post('/store/carts/$cartId/transfer').send())
        .assertUnauthorized();
  });

  test('foreign and terminal carts are hidden as not found', () async {
    final owner = await harness.account('owner@example.com');
    final stranger = await harness.account('stranger@example.com');
    final ownedCart = await harness.cartWith('var_small', token: owner.token);
    final foreignTransfer = harness.client
        .post('/store/carts/$ownedCart/transfer')
      ..bearer(stranger.token);

    (await foreignTransfer.send()).assertNotFound();

    final terminalCart = await harness.cartWith('var_small');
    (await harness.checkout(terminalCart)).assertCreated();
    final terminalTransfer = harness.client
        .post('/store/carts/$terminalCart/transfer')
      ..bearer(owner.token);
    (await terminalTransfer.send()).assertNotFound();
  });

  test('two customers racing can produce only one owner', () async {
    final first = await harness.account('first@example.com');
    final second = await harness.account('second@example.com');
    final cartId = await harness.cartWith('var_small');
    final firstRequest = harness.client.post('/store/carts/$cartId/transfer')
      ..bearer(first.token);
    final secondRequest = harness.client.post('/store/carts/$cartId/transfer')
      ..bearer(second.token);

    final responses = await Future.wait([
      firstRequest.send(),
      secondRequest.send(),
    ]);

    expect(responses.map((response) => response.statusCode).toList()..sort(),
        [200, 404]);
    final rows = await queryRaw(
      r'SELECT customer_id FROM carts WHERE id = $1',
      [cartId],
    ).fetch(harness.database.connection as Executor);
    expect(
      rows.single.readIndex<String>(0),
      anyOf(first.customerId, second.customerId),
    );
  });
}
