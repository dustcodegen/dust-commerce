import 'package:commerce_app/src/features/catalog/model/product_listing_state.dart';
import 'package:commerce_app/src/features/catalog/view/listing_current_refinement_models.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds Medusa-style refinement chip labels in sidebar order', () {
    final chips = listingCurrentRefinementModels(
      options: const [
        ProductOptionFilterView(
          id: 'opt_size',
          title: 'Size',
          values: [ProductOptionValueView(id: 'optval_m', value: 'M')],
        ),
      ],
      selectedOptionValueIds: const ['optval_m'],
      categoryFilters: const [
        ProductCategoryFilter(handle: 'shirts', name: 'Shirts', count: 2),
      ],
      selectedCategoryHandles: const ['shirts'],
      labelFilters: const [ProductLabelFilter(value: 'Cotton', count: 2)],
      selectedLabelValues: const ['Cotton'],
      selectedMinPrice: const Some<int>(1000),
      selectedMaxPrice: const Some<int>(2000),
      selectedOnSale: true,
      currencyCode: 'usd',
    );

    expect(
      chips.map((chip) => chip.label),
      [
        'Size: M',
        'From USD 10.00',
        'Up to USD 20.00',
        'On sale',
        'Category: Shirts',
        'Label: Cotton',
      ],
    );
  });
}
