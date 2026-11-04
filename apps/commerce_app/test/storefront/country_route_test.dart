import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/support.dart';

void main() {
  test('country-prefixed Medusa links normalize and select their country', () {
    final location = Uri.parse(
      '/DK/products/t-shirt?v_id=var_tshirt_m_white#details',
    );

    expect(storefrontCountryCode(location), 'dk');
    expect(
      storefrontLocationWithoutCountry(location).toString(),
      '/products/t-shirt?v_id=var_tshirt_m_white#details',
    );

    final router = CommerceRouter(
      initialLocation: location,
      account: testAccount(const _UnusedApi()),
      cart: testCart(const _UnusedApi()),
    );
    final parsed = router.parseRouteInformation(
      RouteInformation(uri: Uri.parse('/')),
    );
    expect(
      parsed.uri.toString(),
      '/products/t-shirt?v_id=var_tshirt_m_white#details',
    );
  });

  test('country-prefixed policy links normalize to their public route', () {
    final router = CommerceRouter(
      initialLocation: Uri.parse('/dk/shipping'),
      account: testAccount(const _UnusedApi()),
      cart: testCart(const _UnusedApi()),
    );

    final parsed = router.parseRouteInformation(
      RouteInformation(uri: Uri.parse('/')),
    );

    expect(parsed.uri.toString(), '/shipping');
    expect(parseCommerceRoute(parsed.uri), isA<ShippingRoute>());
  });

  test('router normalizes Medusa catch-all category links', () {
    final router = CommerceRouter(
      initialLocation: Uri.parse('/categories/clothing/shirts?page=2'),
      account: testAccount(const _UnusedApi()),
      cart: testCart(const _UnusedApi()),
    );

    final restored = router.parseRouteInformation(
      RouteInformation(uri: Uri.parse('/')),
    );

    expect(
      restored.uri.toString(),
      '/categories/clothing%2Fshirts?page=2',
    );
  });

  test('unknown country prefixes remain on the not-found route', () {
    final location = Uri.parse('/ZZ/products/t-shirt');
    final router = CommerceRouter(
      initialLocation: location,
      account: testAccount(const _UnusedApi()),
      cart: testCart(const _UnusedApi()),
    );

    router.setInitialLocation(location);
    final parsed = router.parseRouteInformation(
      RouteInformation(uri: Uri.parse('/')),
    );

    expect(parsed.uri.toString(), '/ZZ/products/t-shirt');
  });

  test('unknown country prefixes do not normalize nested categories', () {
    final location = Uri.parse('/ZZ/categories/clothing/shirts');
    final router = CommerceRouter(
      initialLocation: location,
      account: testAccount(const _UnusedApi()),
      cart: testCart(const _UnusedApi()),
    );

    router.setInitialLocation(location);
    final parsed = router.parseRouteInformation(
      RouteInformation(uri: Uri.parse('/')),
    );

    expect(parsed.uri.toString(), '/ZZ/categories/clothing/shirts');
  });
}

final class _UnusedApi implements CommerceApi {
  const _UnusedApi();

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('No API request expected');
}
