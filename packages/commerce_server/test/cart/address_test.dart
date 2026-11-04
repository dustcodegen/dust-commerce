import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import '../checkout/support.dart';

void main() {
  late CheckoutHarness harness;

  setUp(() async => harness = await CheckoutHarness.start());
  tearDown(() => harness.stop());

  test('guest address step persists, normalizes, and clears billing', () async {
    final cartId = await harness.cartWith('var_small');
    final shipping = harness.address(
      company: '  Analytical Engines  ',
      line2: '  Suite 2  ',
      province: '  DC  ',
      phone: '  +1 555 0101  ',
    )..['country_code'] = ' US ';
    final billing = harness.address(firstName: 'Grace')
      ..['country_code'] = 'us';

    final saved = await (harness.client.put('/store/carts/$cartId/addresses')
          ..json({
            'email': '  ada@example.com  ',
            'shipping_address': shipping,
            'billing_address': billing,
          }))
        .send();

    saved.assertOk();
    final reloaded = await harness.client.get('/store/carts/$cartId').send();
    final cart = CartView.fromJson(
      reloaded.json! as Map<String, Object?>,
    ).cart;
    expect(cart.email, 'ada@example.com');
    expect(cart.shippingAddress?.countryCode, 'us');
    expect(cart.shippingAddress?.company, 'Analytical Engines');
    expect(cart.shippingAddress?.line2, 'Suite 2');
    expect(cart.shippingAddress?.province, 'DC');
    expect(cart.shippingAddress?.phone, '+1 555 0101');
    expect(cart.billingAddress?.firstName, 'Grace');

    final cleared = await (harness.client.put('/store/carts/$cartId/addresses')
          ..json({
            'email': 'ada@example.com',
            'shipping_address': shipping,
          }))
        .send();
    cleared.assertOk();
    final clearedCart = CartView.fromJson(
      cleared.json! as Map<String, Object?>,
    ).cart;
    expect(clearedCart.billingAddress, isNull);
  });

  test('a country outside the region leaves the saved step unchanged',
      () async {
    final cartId = await harness.cartWith('var_small');
    final valid = harness.address()..['country_code'] = 'us';
    (await (harness.client.put('/store/carts/$cartId/addresses')
              ..json({
                'email': 'ada@example.com',
                'shipping_address': valid,
              }))
            .send())
        .assertOk();

    final invalid = harness.address(firstName: 'Changed')
      ..['country_code'] = 'dk';
    final rejected = await (harness.client.put('/store/carts/$cartId/addresses')
          ..json({
            'email': 'changed@example.com',
            'shipping_address': invalid,
          }))
        .send();
    rejected.assertUnprocessable();

    final reloaded = await harness.client.get('/store/carts/$cartId').send();
    final cart = CartView.fromJson(
      reloaded.json! as Map<String, Object?>,
    ).cart;
    expect(cart.email, 'ada@example.com');
    expect(cart.shippingAddress?.firstName, 'Ada');
    expect(cart.shippingAddress?.countryCode, 'us');
  });

  test('authenticated cart keeps the proven customer email', () async {
    final owner = await harness.account('owner@example.com');
    final cartId = await harness.cartWith('var_small', token: owner.token);
    final request = harness.client.put('/store/carts/$cartId/addresses')
      ..bearer(owner.token)
      ..json({
        'email': 'spoofed@example.com',
        'shipping_address': harness.address()..['country_code'] = 'us',
      });

    final response = await request.send();

    response.assertOk();
    final cart = CartView.fromJson(
      response.json! as Map<String, Object?>,
    ).cart;
    expect(cart.email, 'owner@example.com');
  });
}
