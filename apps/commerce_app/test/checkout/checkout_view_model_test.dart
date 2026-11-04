import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  late CheckoutTestContext context;

  setUp(() async => context = await CheckoutTestContext.start());
  tearDown(() => context.stop());

  test('guest checkout completes every source step without duplicate totals',
      () async {
    final model = context.checkout()..prepare();
    expect(
      await CheckoutGuard(context.cart).canActivate(const CheckoutRoute()),
      isNull,
    );

    expect(await saveTestAddress(model), isTrue);
    expect(await model.loadDelivery(), isTrue);
    expect(await model.chooseDelivery('ship_standard'), isTrue);
    expect(await model.loadPaymentMethods(), isTrue);
    expect(
      model.state.paymentProviders,
      const [PaymentProviderView(id: 'manual')],
    );
    expect(await model.selectPayment('manual'), isTrue);
    expect(await model.placeOrder(), isTrue);

    final order = model.state.order!;
    expect(model.state.status, CheckoutStatus.complete);
    expect(order.paymentStatus, PaymentStatus.captured);
    expect(order.status, OrderStatus.pending);
    expect(order.payment?.providerId, 'manual');
    expect(order.payment?.amount, order.total);
    expect(context.cart.state.cart, isNull);
    expect(context.cartIds.values, isNot(contains('guest')));
    expect((await context.receipts.read(order.id))?.id, order.id);

    final restored = context.checkout();
    expect(await restored.loadReceipt(order.id), isTrue);
    expect(restored.state.order, order);
  });

  test('capture failure retains input and resumes the same order', () async {
    final model = context.checkout(client: _FailFirstCaptureApi(context.api))
      ..prepare();
    await saveTestAddress(model);
    await model.loadDelivery();
    await model.chooseDelivery('ship_standard');
    expect(await model.loadPaymentMethods(), isTrue);
    expect(await model.selectPayment('manual'), isTrue);

    expect(await model.placeOrder(), isFalse);
    final placedId = model.state.order!.id;
    expect(model.state.status, CheckoutStatus.failed);
    expect(model.state.shipping.line1, '12 Analytical Way');
    expect(await model.loadReceipt(placedId), isFalse);
    expect(model.state.message, 'Order confirmation not found.');

    expect(await model.placeOrder(), isTrue);
    expect(model.state.order!.id, placedId);
    expect(model.state.order!.paymentStatus, PaymentStatus.captured);
  });

  test('reset drops payment state after the selling region changes', () async {
    final model = context.checkout()..prepare();
    await saveTestAddress(model);
    await model.loadDelivery();
    await model.chooseDelivery('ship_standard');
    expect(await model.loadPaymentMethods(), isTrue);
    expect(await model.selectPayment('manual'), isTrue);

    model.reset();

    expect(model.state.status, CheckoutStatus.idle);
    expect(model.state.paymentProviders, isEmpty);
    expect(model.state.paymentProvidersLoaded, isFalse);
    expect(model.state.hasPaymentMethod, isFalse);
  });
}

final class _FailFirstCaptureApi implements CommerceApi {
  _FailFirstCaptureApi(this.delegate);

  final CommerceApi delegate;
  bool failCapture = true;

  @override
  Future<Order> authorizePayment(String id, {String? guestEmail}) =>
      delegate.authorizePayment(id, guestEmail: guestEmail);

  @override
  Future<Order> capturePayment(String id, {String? guestEmail}) {
    if (failCapture) {
      failCapture = false;
      return Future.error(StateError('payment network interrupted'));
    }
    return delegate.capturePayment(id, guestEmail: guestEmail);
  }

  @override
  Future<Order> checkout(CheckoutRequest body) => delegate.checkout(body);

  @override
  Future<Order> order(String id) => delegate.order(id);

  @override
  Future<PaymentProviderListView> paymentProviders(String regionId) =>
      delegate.paymentProviders(regionId);

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('unused API method');
}
