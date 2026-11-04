import 'package:admin_app/src/product/admin_product_option_permutations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes comma-separated values at the form boundary', () {
    expect(
      parseProductOptionValues(' Small, Medium, Small, , Large '),
      ['Small', 'Medium', 'Large'],
    );
  });

  test('builds Medusa-ordered variants across every option axis', () {
    final variants = buildProductOptionPermutations([
      (title: 'Size', values: ['S', 'M']),
      (title: 'Color', values: ['Black', 'White']),
    ]);

    expect(variants, [
      {'Size': 'S', 'Color': 'Black'},
      {'Size': 'S', 'Color': 'White'},
      {'Size': 'M', 'Color': 'Black'},
      {'Size': 'M', 'Color': 'White'},
    ]);
    expect(variants.map(productOptionPermutationTitle), [
      'S / Black',
      'S / White',
      'M / Black',
      'M / White',
    ]);
  });

  test('ignores an incomplete axis while the merchant is editing it', () {
    final variants = buildProductOptionPermutations([
      (title: 'Size', values: ['S', 'M']),
      (title: '', values: const []),
    ]);

    expect(variants, [
      {'Size': 'S'},
      {'Size': 'M'},
    ]);
  });

  test('returns no variants when no complete option exists', () {
    expect(
      buildProductOptionPermutations([
        (title: 'Size', values: const []),
      ]),
      isEmpty,
    );
  });
}
