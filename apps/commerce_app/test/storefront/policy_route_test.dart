import 'package:commerce_app/route.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commerce_app/src/features/policies/view/policy_content.dart';

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

  test('policy formatting keeps rates and day ranges deterministic', () {
    expect(formatPolicyRate('0', 'usd'), 'Free');
    expect(formatPolicyRate('10.50', 'usd'), 'USD 10.50');
    expect(formatPolicyDays(2, 2), '2');
    expect(formatPolicyDays(2, 3), '2-3');
  });
}
