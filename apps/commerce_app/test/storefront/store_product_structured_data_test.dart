import 'dart:convert';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('one priced variant emits a Product offer', () {
    final product = Product.of(
      id: 'prod_1',
      title: 'T-Shirt',
      handle: 't-shirt',
      status: ProductStatus.published,
      variants: [
        ProductVariant.of(
          id: 'var_1',
          title: 'Default',
          sku: 'SKU-1',
          prices: [Money.of(1299, 'usd')],
          inventoryQuantity: 2,
        ),
      ],
    );

    final json = jsonDecode(
      buildStoreProductStructuredData(
        product: product,
        currencyCode: 'usd',
        productUrl: 'https://shop.test/products/t-shirt',
      ),
    ) as Map<String, Object?>;

    expect(json['@type'], 'Product');
    expect(json['url'], 'https://shop.test/products/t-shirt');
    expect((json['offers']! as Map<String, Object?>)['price'], '12.99');
    expect(
      (json['offers']! as Map<String, Object?>)['availability'],
      'https://schema.org/InStock',
    );
  });

  test('multiple variants emit a ProductGroup with option properties', () {
    final product = Product.of(
      id: 'prod_1',
      title: 'T-Shirt',
      handle: 't-shirt',
      status: ProductStatus.published,
      options: [
        ProductOption.of(id: 'opt_size', title: 'Size', values: ['S', 'M']),
      ],
      variants: [
        ProductVariant.of(
          id: 'var_s',
          title: 'Small',
          prices: [Money.of(999, 'usd')],
          optionValues: const {'opt_size': 'S'},
        ),
        ProductVariant.of(
          id: 'var_m',
          title: 'Medium',
          prices: [Money.of(1099, 'usd')],
          optionValues: const {'opt_size': 'M'},
        ),
      ],
    );

    final json = jsonDecode(
      buildStoreProductStructuredData(
        product: product,
        currencyCode: 'usd',
        productUrl: 'https://shop.test/products/t-shirt',
      ),
    ) as Map<String, Object?>;
    final variants = json['hasVariant']! as List<Object?>;
    final first = variants.first! as Map<String, Object?>;
    final property = (first['additionalProperty']! as List<Object?>).single!
        as Map<String, Object?>;

    expect(json['@type'], 'ProductGroup');
    expect(json['productGroupID'], 'prod_1');
    expect(property['name'], 'Size');
    expect(property['value'], 'S');
    expect(
      (first['offers']! as Map<String, Object?>)['url'],
      'https://shop.test/products/t-shirt?v_id=var_s',
    );
  });

  test('JSON-LD escapes script terminators in merchant text', () {
    final product = Product.of(
      id: 'prod_1',
      title: '</script><script>alert(1)</script>',
      handle: 'unsafe',
      status: ProductStatus.published,
    );

    final encoded = buildStoreProductStructuredData(
      product: product,
      currencyCode: 'usd',
      productUrl: 'https://shop.test/products/unsafe',
    );

    expect(encoded, contains(r'\u003c/script>'));
    expect(encoded, isNot(contains('</script>')));
  });
}
