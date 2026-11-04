import 'package:commerce_app/route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('search route retains its bounded query and page', () {
    final route = parseCommerceRoute(
      Uri.parse('/search?q=black%20shirt&page=2'),
    );

    expect(route, isA<SearchRoute>());
    expect((route as SearchRoute).q, 'black shirt');
    expect(route.page, 2);
    expect(route.requiresAuth, isFalse);
    expect(route.location, '/search?page=2&q=black+shirt');
  });
}
