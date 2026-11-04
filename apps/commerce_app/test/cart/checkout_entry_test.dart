import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resumes the first incomplete Medusa checkout step', () {
    const cart = Cart(id: 'cart_1', region: _region, items: []);
    const address = Address(
      firstName: 'Ada',
      lastName: 'Lovelace',
      line1: '1 Computing Lane',
      city: 'London',
      postalCode: 'SW1A 1AA',
      countryCode: 'gb',
    );
    const shipping = ShippingMethod(
      optionId: 'ship_standard',
      name: 'Standard',
      amount: Money(amount: 500, currencyCode: 'usd'),
    );

    expect(checkoutEntryStep(cart), 'address');
    expect(
      checkoutEntryStep(cart.copyWith(email: '', shippingAddress: address)),
      'address',
    );
    expect(
      checkoutEntryStep(
        cart.copyWith(email: 'ada@example.com', shippingAddress: address),
      ),
      'delivery',
    );
    expect(
      checkoutEntryStep(cart.copyWith(
        email: 'ada@example.com',
        shippingAddress: address,
        shippingMethod: shipping,
      )),
      'payment',
    );
  });
}

const _region = Region(
  id: 'reg_us',
  name: 'United States',
  currencyCode: 'usd',
  taxRate: 1000,
  countries: ['us'],
);
