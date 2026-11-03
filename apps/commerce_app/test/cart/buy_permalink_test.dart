import 'package:commerce_app/commerce_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses one or more Medusa checkout items', () {
    final items = parseBuyItems('var_tshirt_m_black:2,var_sweatshirt_s:1');

    expect(items, hasLength(2));
    expect(items![0].variantId, 'var_tshirt_m_black');
    expect(items[0].quantity, 2);
    expect(items[1].variantId, 'var_sweatshirt_s');
  });

  test('decodes base64url variant ids', () {
    final items = parseBuyItems('~dmFyX3RzaGlydF9tX2JsYWNr:1');

    expect(items!.single.variantId, 'var_tshirt_m_black');
  });

  test('rejects malformed, empty, and over-sized item pairs', () {
    expect(parseBuyItems(''), isNull);
    expect(parseBuyItems('variant-only'), isNull);
    expect(parseBuyItems('variant:0'), isNull);
    expect(parseBuyItems('variant:101'), isNull);
  });
}
