import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('creates every selection in a two-axis product graph', () async {
    final token = await harness.adminToken();
    final request = harness.client.post('/admin/products')
      ..bearer(token)
      ..json(_body());

    final response = await request.send();

    response.assertOk();
    final product = AdminProductDetail.fromJson(
      response.json! as Map<String, Object?>,
    );
    expect(product.options.map((option) => option.title), ['Size', 'Color']);
    expect(product.variants.map((variant) => variant.title), [
      'S / Black',
      'S / White',
      'M / Black',
      'M / White',
    ]);
    expect(
      product.variants.map((variant) => variant.optionValues.length),
      everyElement(2),
    );
  });
}

Map<String, Object?> _body() => {
      'title': 'Multi-axis Tee',
      'handle': 'multi-axis-tee',
      'discountable': true,
      'status': 'published',
      'media': <Object?>[],
      'options': [
        {
          'title': 'Size',
          'values': ['S', 'M'],
        },
        {
          'title': 'Color',
          'values': ['Black', 'White'],
        },
      ],
      'variants': [
        for (final size in ['S', 'M'])
          for (final color in ['Black', 'White'])
            {
              'title': '$size / $color',
              'sku': 'TEE-$size-${color.toUpperCase()}',
              'inventory_quantity': 5,
              'manage_inventory': true,
              'allow_backorder': false,
              'option_values': {'Size': size, 'Color': color},
              'prices': [
                {'currency_code': 'eur', 'amount': 1800},
                {'currency_code': 'usd', 'amount': 2000},
              ],
            },
      ],
    };
