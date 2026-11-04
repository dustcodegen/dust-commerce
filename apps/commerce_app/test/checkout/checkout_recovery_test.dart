import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  late CheckoutTestContext context;

  setUp(() async => context = await CheckoutTestContext.start());
  tearDown(() => context.stop());

  test('identity reset clears customer-derived checkout input', () async {
    final model = context.checkout()..prepare();
    await saveTestAddress(model);

    model.reset();

    expect(model.state, const CheckoutState());
  });

  test('a new checkout restores the server-owned address step', () async {
    final first = context.checkout()..prepare();
    expect(await saveTestAddress(first), isTrue);

    final restored = context.checkout()..prepare();

    expect(restored.state.email, 'ada@example.com');
    expect(restored.state.shipping.firstName, 'Ada');
    expect(restored.state.shipping.line1, '12 Analytical Way');
    expect(restored.state.shipping.countryCode, 'us');
    expect(restored.state.sameAsBilling, isTrue);
  });

  test('a new checkout restores the server-owned payment step', () async {
    final first = context.checkout()..prepare();
    await saveTestAddress(first);
    await first.chooseDelivery('ship_standard');
    expect(await first.selectPayment('manual'), isTrue);

    final restored = context.checkout()..prepare();

    expect(restored.state.isPaymentSelected('manual'), isTrue);
    expect(restored.state.status, CheckoutStatus.ready);
  });

  test('customer identity prefills only proven contact email', () {
    const customer = Customer(
      id: 'cus_ada',
      email: 'ada@example.com',
      firstName: 'Ada',
      lastName: 'Lovelace',
      phone: '+1 555 0101',
    );
    final model = context.checkout(customer: customer)..prepare();

    expect(model.state.email, customer.email);
    expect(model.state.shipping, const CheckoutAddressDraft());
  });
}
