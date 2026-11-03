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
}

final class _UnusedApi implements CommerceApi {
  const _UnusedApi();

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('No API request expected');
}
