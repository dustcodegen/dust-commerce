import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late CheckoutHarness harness;

  setUp(() async => harness = await CheckoutHarness.start());
  tearDown(() async => harness.stop());

  test('freezes company separately from the second address line', () async {
    final cartId = await harness.cartWith('var_small');

    final placed = await harness.checkout(
      cartId,
      shipping: harness.address(
        company: 'Analytical Engines',
        line2: 'Suite 2',
      ),
    );

    placed.assertCreated();
    final order = Order.fromJson(placed.json! as Map<String, Object?>);
    expect(order.shippingAddress.company, 'Analytical Engines');
    expect(order.shippingAddress.line2, 'Suite 2');
    expect(order.billingAddress, order.shippingAddress);
  });

  test('separate billing nulls never inherit shipping optionals', () async {
    final cartId = await harness.cartWith('var_small');

    final placed = await harness.checkout(
      cartId,
      shipping: harness.address(
        company: 'Shipping Company',
        line2: 'Shipping Suite',
        province: 'Shipping Province',
        phone: '+44 20 0000 0000',
      ),
      billing: harness.address(),
    );

    placed.assertCreated();
    final order = Order.fromJson(placed.json! as Map<String, Object?>);
    expect(order.billingAddress.company, isNull);
    expect(order.billingAddress.line2, isNull);
    expect(order.billingAddress.province, isNull);
    expect(order.billingAddress.phone, isNull);
  });
}
