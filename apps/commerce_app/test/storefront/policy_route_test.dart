import 'package:commerce_app/route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('policy routes are public source-compatible destinations', () {
    final routes = [
      parseCommerceRoute(Uri.parse('/shipping')),
      parseCommerceRoute(Uri.parse('/returns')),
      parseCommerceRoute(Uri.parse('/privacy')),
      parseCommerceRoute(Uri.parse('/terms')),
    ];

    expect(routes, everyElement(isA<CommerceRoute>()));
    expect(routes.map((route) => route.location), [
      '/shipping',
      '/returns',
      '/privacy',
      '/terms',
    ]);
    expect(routes.every((route) => !route.requiresAuth), isTrue);
  });
}
