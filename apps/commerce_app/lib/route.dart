import 'package:dust_flutter/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter/widgets.dart';

import 'src/features/account/view_model/account_view_model.dart';
import 'src/features/cart/view_model/cart_view_model.dart';
import 'route/routes.g.dart';

export 'package:dust_flutter/route.dart';
export 'route/routes.g.dart';

/// The storefront's router.
///
/// One entrypoint, as Dust requires. Screens declare their own paths with
/// `@AppRoute`; this file only says where the app starts.
@AppRouter(initial: '/', notFound: '/404')
final class CommerceRouter extends $CommerceRouter {
  /// Creates a [CommerceRouter].
  CommerceRouter(
      {required Uri initialLocation,
      required AccountViewModel account,
      required CartViewModel cart})
      : customerSession = CustomerSessionRouterRefresh(account),
        cartSession = cart,
        _initialLocation = storefrontLocationWithoutCountry(initialLocation);

  /// Customer-session access and router refresh boundary.
  final CustomerSessionRouterRefresh customerSession;

  /// Cart capability used by the public checkout route guard.
  final CartViewModel cartSession;
  Uri _initialLocation;
  bool _initialLocationRead = false;

  /// Restores a country prefix when region discovery rejects it.
  void setInitialLocation(Uri location) {
    if (_initialLocationRead) return;
    _initialLocation = location;
  }

  @override
  Listenable get refreshListenable => customerSession;

  @override
  RouteInformation parseRouteInformation(RouteInformation information) {
    if (_initialLocationRead) return information;
    _initialLocationRead = true;
    return RouteInformation(uri: _initialLocation);
  }
}

final _countryCodeSegment = RegExp(r'^[A-Za-z]{2}$');

/// Reads the Medusa country prefix from a storefront deep link, when present.
String? storefrontCountryCode(Uri location) {
  final segments = location.pathSegments;
  if (segments.isEmpty) return null;
  final candidate = segments.first;
  return _countryCodeSegment.hasMatch(candidate)
      ? candidate.toLowerCase()
      : null;
}

/// Converts a country-prefixed Medusa URL to the local typed route shape.
Uri storefrontLocationWithoutCountry(Uri location) {
  if (storefrontCountryCode(location) == null) return location;
  final segments = location.pathSegments.skip(1).toList(growable: false);
  return Uri(
    pathSegments: segments.isEmpty ? const [''] : ['', ...segments],
    query: location.hasQuery ? location.query : null,
    fragment: location.hasFragment ? location.fragment : null,
  );
}

/// Restores checkout and rejects a known empty cart before the route builds.
final class CheckoutGuard implements AsyncRouteGuard<CommerceRoute> {
  /// Creates the cart-level checkout guard.
  const CheckoutGuard(this.cart);

  /// Shared cart state injected from [CommerceRouter].
  final CartViewModel cart;

  @override
  Future<CommerceRoute?> canActivate(CommerceRoute route) async {
    await cart.restore();
    final view = cart.state.cart;
    // A missing capability must reach Checkout's source-owned 404 boundary.
    if (view == null) return null;
    return view.cart.isEmpty ? const CartRoute() : null;
  }
}

/// Verifies a customer session before activating account-only routes.
final class CustomerGuard implements AsyncRouteGuard<CommerceRoute> {
  /// Creates the route-level customer guard.
  const CustomerGuard(this.customerSession);

  /// Customer-session boundary injected from [CommerceRouter].
  final CustomerSessionRouterRefresh customerSession;

  @override
  Future<CommerceRoute?> canActivate(CommerceRoute route) async {
    final account = customerSession.account;
    if (!account.state.isAuthenticated) await account.restore();
    return account.state.isAuthenticated ? null : const AccountRoute();
  }
}

/// Notifies the router only when access to customer routes actually changes.
final class CustomerSessionRouterRefresh implements Listenable {
  /// Creates a filtered customer-session router refresh source.
  CustomerSessionRouterRefresh(this.account);

  /// Customer session owner used by generated route guards.
  final AccountViewModel account;
  final Map<VoidCallback, VoidCallback> _relays = {};

  @override
  void addListener(VoidCallback listener) {
    var wasAuthenticated = account.state.isAuthenticated;
    void relay() {
      final isAuthenticated = account.state.isAuthenticated;
      if (isAuthenticated == wasAuthenticated) return;
      wasAuthenticated = isAuthenticated;
      if (!account.isRestoring) listener();
    }

    _relays[listener] = relay;
    account.addListener(relay);
  }

  @override
  void removeListener(VoidCallback listener) {
    final relay = _relays.remove(listener);
    if (relay != null) account.removeListener(relay);
  }
}

/// Returns the active product URL with only its Medusa `v_id` changed.
Uri productVariantLocation(
  Uri current, {
  required String handle,
  required String? variantId,
}) {
  final query = <String, List<String>>{...current.queryParametersAll};
  if (variantId == null) {
    query.remove('v_id');
  } else {
    query['v_id'] = [variantId];
  }
  return Uri(
    pathSegments: ['', 'products', handle],
    queryParameters: query.isEmpty ? null : query,
  );
}

/// Medusa-compatible product variant URL behavior.
extension CommerceProductRouteContext on BuildContext {
  /// Selected `v_id` preserved on the active product route, if any.
  String? get productVariantId {
    final route = RouterController.of<CommerceRoute>(this).currentRoute;
    if (route is! ProductRoute) return null;
    final values = generatedRouteUriExtrasOf(route)?.queryParameters['v_id'];
    return values == null || values.isEmpty ? null : values.first;
  }

  /// Replaces the product URL with the selected Medusa `v_id`.
  void replaceProductVariant(String handle, String? variantId) {
    final controller = RouterController.of<CommerceRoute>(this);
    final uri = productVariantLocation(
      Uri.parse(controller.currentRoute.location),
      handle: handle,
      variantId: variantId,
    );
    controller.replace(parseCommerceRoute(uri));
  }
}

/// Medusa-compatible checkout step query behavior.
extension CommerceCheckoutRouteContext on BuildContext {
  /// Active `step` value; address is the safe default.
  String get checkoutStep {
    final route = RouterController.of<CommerceRoute>(this).currentRoute;
    if (route is! CheckoutRoute) return 'address';
    final values = generatedRouteUriExtrasOf(route)?.queryParameters['step'];
    final value = values == null || values.isEmpty ? null : values.first;
    return const {'address', 'delivery', 'payment', 'review'}.contains(value)
        ? value!
        : 'address';
  }

  /// Pushes the same checkout route with a source-compatible step query.
  void pushCheckoutStep(String step) {
    final uri = Uri(path: '/checkout', queryParameters: {'step': step});
    RouterController.of<CommerceRoute>(this).push(parseCommerceRoute(uri));
  }

  /// Replaces an inaccessible step without adding a broken history entry.
  void replaceCheckoutStep(String step) {
    final uri = Uri(path: '/checkout', queryParameters: {'step': step});
    RouterController.of<CommerceRoute>(this).replace(parseCommerceRoute(uri));
  }
}
