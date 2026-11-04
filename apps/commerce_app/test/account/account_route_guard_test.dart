import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all private account routes use a typed customer guard', () async {
    final account = testAccount(const _UnusedApi());
    final router = CommerceRouter(
      initialLocation: Uri.parse('/account/orders'),
      account: account,
      cart: testCart(const _UnusedApi()),
    );
    for (final route in const <CommerceRoute>[
      AccountAddressesRoute(),
      AccountOrderDetailRoute(id: 'order_1'),
      AccountOrdersRoute(),
      AccountProfileRoute(),
    ]) {
      final guards = commerceRouteGuards(route, router);
      expect(guards.single, isA<CustomerGuard>());
      expect(
        await RouteGuardChain<CommerceRoute>(guards).canActivate(route),
        isA<AccountRoute>(),
      );
    }
  });

  test('the shared sign-in account route remains public', () {
    final router = CommerceRouter(
      initialLocation: Uri.parse('/account'),
      account: testAccount(const _UnusedApi()),
      cart: testCart(const _UnusedApi()),
    );

    expect(commerceRouteGuards(const AccountRoute(), router), isEmpty);
  });

  test('an authenticated guard reuses the server-proven customer', () async {
    final now = DateTime.utc(2100, 1, 1, 12);
    final sessions = MemoryAuthSessionStore()
      ..value = StoredAuthSession(
        token: 'opaque-test-token',
        expiresAt: now.add(const Duration(hours: 1)),
      );
    final api = _CountingAccountApi();
    final account = AccountViewModel(
      AccountViewModelArgs(api: api, sessions: sessions, now: () => now),
    );
    await account.restore();
    final guard = CustomerGuard(CustomerSessionRouterRefresh(account));

    expect(await guard.canActivate(const AccountAddressesRoute()), isNull);
    expect(api.currentCustomerCalls, 1);
    expect(account.state.customer, _customer);
  });

  test('order details preserve the source route and opaque id', () {
    const route = AccountOrderDetailRoute(id: 'order_1');

    expect(route.location, '/account/orders/details/order_1');
    final parsed = parseCommerceRoute(Uri.parse(route.location));
    expect(parsed, isA<AccountOrderDetailRoute>());
    expect((parsed as AccountOrderDetailRoute).id, route.id);
  });

  test('signed-out guarded navigation settles on the account route', () async {
    final router = CommerceRouter(
      initialLocation: Uri.parse('/account/orders'),
      account: testAccount(const _UnusedApi()),
      cart: testCart(const _UnusedApi()),
    );
    final delegate =
        router.config.routerDelegate as GeneratedRouterDelegate<CommerceRoute>;

    await delegate.debugWaitForScheduledRefresh();
    await delegate.setNewRoutePath(const AccountOrdersRoute());

    expect(delegate.currentConfiguration, isA<AccountRoute>());
  });
}

final class _UnusedApi implements CommerceApi {
  const _UnusedApi();

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('No API request expected');
}

final class _CountingAccountApi implements CommerceApi {
  var currentCustomerCalls = 0;

  @override
  Future<Customer> currentCustomer() async {
    currentCustomerCalls++;
    return _customer;
  }

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unexpected API request');
}

const _customer = Customer(
  id: 'cus_ada',
  email: 'ada@example.test',
  firstName: 'Ada',
);
