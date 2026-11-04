import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/support.dart';

void main() {
  test('missing cart reaches the checkout 404 at the same URL', () async {
    const api = _UnusedApi();
    final cart = testCart(api);
    final router = CommerceRouter(
      initialLocation: Uri.parse('/checkout'),
      account: testAccount(api),
      cart: cart,
    );
    const route = CheckoutRoute();
    final guards = commerceRouteGuards(route, router);

    expect(guards.single, isA<CheckoutGuard>());
    expect(await RouteGuardChain<CommerceRoute>(guards).canActivate(route),
        isNull);
    expect(cart.state.status, CartStatus.ready);
  });

  test('valid empty cart still returns to the cart route', () async {
    final storage = MemoryCartIdStore()..values['guest'] = 'cart_empty';
    final cart = testCart(const _EmptyCartApi(), storage: storage);
    final router = CommerceRouter(
      initialLocation: Uri.parse('/checkout'),
      account: testAccount(const _EmptyCartApi()),
      cart: cart,
    );
    const route = CheckoutRoute();
    final guards = commerceRouteGuards(route, router);

    expect(
      await RouteGuardChain<CommerceRoute>(guards).canActivate(route),
      isA<CartRoute>(),
    );
  });
}

final class _UnusedApi implements CommerceApi {
  const _UnusedApi();

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('No API request expected');
}

final class _EmptyCartApi implements CommerceApi {
  const _EmptyCartApi();

  @override
  Future<CartView> cart(String id) async => CartView.of(Cart(
        id: id,
        region: const Region(
          id: 'reg_us',
          name: 'United States',
          currencyCode: 'usd',
          taxRate: 0,
          countries: ['us'],
        ),
        items: const [],
      ));

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('No other API request expected');
}
