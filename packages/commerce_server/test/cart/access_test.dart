import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import '../checkout/support.dart';

void main() {
  late CheckoutHarness harness;

  setUp(() async => harness = await CheckoutHarness.start());
  tearDown(() => harness.stop());

  test('only the owning customer can read or mutate an account cart', () async {
    final owner = await harness.account('owner@example.com');
    final stranger = await harness.account('stranger@example.com');
    final created = harness.client.post('/store/carts')..bearer(owner.token);
    final response = await created.send();
    final cartId =
        CartView.fromJson(response.json! as Map<String, Object?>).cart.id;

    (await harness.client.get('/store/carts/$cartId').send()).assertNotFound();
    final wrongRead = harness.client.get('/store/carts/$cartId')
      ..bearer(stranger.token);
    (await wrongRead.send()).assertNotFound();

    final anonymousWrite = harness.client
        .post('/store/carts/$cartId/line-items')
      ..json({'variant_id': 'var_small'});
    (await anonymousWrite.send()).assertNotFound();
    final wrongWrite = harness.client.post('/store/carts/$cartId/line-items')
      ..bearer(stranger.token)
      ..json({'variant_id': 'var_small'});
    (await wrongWrite.send()).assertNotFound();

    final ownerWrite = harness.client.post('/store/carts/$cartId/line-items')
      ..bearer(owner.token)
      ..json({'variant_id': 'var_small'});
    final added = await ownerWrite.send();
    added.assertOk();
    final lineId = CartView.fromJson(
      added.json! as Map<String, Object?>,
    ).cart.items.single.id;

    final anonymousQuantity = harness.client
        .patch('/store/carts/$cartId/line-items/$lineId')
      ..json({'quantity': 2});
    (await anonymousQuantity.send()).assertNotFound();
    final wrongQuantity =
        harness.client.patch('/store/carts/$cartId/line-items/$lineId')
          ..bearer(stranger.token)
          ..json({'quantity': 2});
    (await wrongQuantity.send()).assertNotFound();

    final wrongRemoval = harness.client
        .delete('/store/carts/$cartId/line-items/$lineId')
      ..bearer(stranger.token);
    (await wrongRemoval.send()).assertNotFound();
    final ownerQuantity =
        harness.client.patch('/store/carts/$cartId/line-items/$lineId')
          ..bearer(owner.token)
          ..json({'quantity': 2});
    (await ownerQuantity.send()).assertOk();
  });

  test('guest carts remain capability-addressed and accept no token', () async {
    final cartId = await harness.cartWith('var_small');

    (await harness.client.get('/store/carts/$cartId').send()).assertOk();
  });

  test('completed carts no longer expose a resume capability', () async {
    final cartId = await harness.cartWith('var_small');

    (await harness.checkout(cartId)).assertCreated();

    (await harness.client.get('/store/carts/$cartId').send()).assertNotFound();
  });

  test('an invalid bearer token is rejected instead of treated as a guest',
      () async {
    final cartId = await harness.cartWith('var_small');
    final request = harness.client.get('/store/carts/$cartId')
      ..bearer('invalid');

    (await request.send()).assertUnauthorized();
  });
}
