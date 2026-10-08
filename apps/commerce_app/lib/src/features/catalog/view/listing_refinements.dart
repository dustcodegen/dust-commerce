import 'package:commerce_app/src/features/catalog/model/product_listing_state.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

import 'listing_category_filters.dart';
import 'listing_current_refinements.dart';
import 'listing_label_filters.dart';
import 'listing_on_sale_toggle.dart';
import 'listing_option_filters.dart';
import 'listing_price_range.dart';
import 'listing_sort_products.dart';

/// Source-matched Store refinement sidebar.
class ListingRefinements extends StatelessWidget {
  /// Creates the sort refinement list.
  const ListingRefinements({
    required this.selected,
    required this.onChanged,
    required this.options,
    required this.selectedOptionValueIds,
    required this.onOptionValuesChanged,
    required this.categoryFilters,
    required this.selectedCategoryHandles,
    required this.labelFilters,
    required this.selectedLabelValues,
    required this.priceBounds,
    required this.selectedMaxPrice,
    required this.selectedMinPrice,
    required this.selectedOnSale,
    required this.onSaleCount,
    required this.currencyCode,
    this.onCategoryHandlesChanged,
    this.onLabelValuesChanged,
    this.onPriceRangeChanged,
    this.onSaleChanged,
    this.onClearAll,
    super.key,
  });

  /// Store-only category refinements discovered from matching products.
  final List<ProductCategoryFilter> categoryFilters;

  /// Currency used by price-range labels.
  final String currencyCode;

  /// Replaces the repeated category query.
  final ValueChanged<List<String>>? onCategoryHandlesChanged;

  /// Clears every Store refinement in one route update.
  final VoidCallback? onClearAll;

  /// Store-only label refinements discovered from matching products.
  final List<ProductLabelFilter> labelFilters;

  /// Replaces the repeated labels query.
  final ValueChanged<List<String>>? onLabelValuesChanged;

  /// Receives one Medusa sort query value.
  final ValueChanged<String> onChanged;

  /// Replaces the repeated option-value query.
  final ValueChanged<List<String>> onOptionValuesChanged;

  /// Replaces the price range query.
  final void Function(int? minPrice, int? maxPrice)? onPriceRangeChanged;

  /// Replaces the sale-only query toggle.
  final ValueChanged<bool>? onSaleChanged;

  /// Number of currently matching sale-priced products.
  final int onSaleCount;

  /// Store-only option axes discovered from the backend.
  final List<ProductOptionFilterView> options;

  /// Store-only price bounds discovered from matching products.
  final Option<ProductPriceBounds> priceBounds;

  /// Current Medusa sort query value.
  final String selected;

  /// Stable category handles currently selected.
  final List<String> selectedCategoryHandles;

  /// Stable label values currently selected.
  final List<String> selectedLabelValues;

  /// Active upper price bound in minor units.
  final Option<int> selectedMaxPrice;

  /// Active lower price bound in minor units.
  final Option<int> selectedMinPrice;

  /// Whether sale-only filtering is active.
  final bool selectedOnSale;

  /// Stable option-value identifiers currently selected.
  final List<String> selectedOptionValueIds;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SortProducts(
              selected: selected,
              onChanged: onChanged,
              extended: onCategoryHandlesChanged != null,
            ),
            if (onClearAll case final clearAll?)
              ListingCurrentRefinements(
                options: options,
                selectedOptionValueIds: selectedOptionValueIds,
                onOptionValuesChanged: onOptionValuesChanged,
                categoryFilters: categoryFilters,
                selectedCategoryHandles: selectedCategoryHandles,
                onCategoryHandlesChanged: onCategoryHandlesChanged,
                labelFilters: labelFilters,
                selectedLabelValues: selectedLabelValues,
                onLabelValuesChanged: onLabelValuesChanged,
                selectedMaxPrice: selectedMaxPrice,
                selectedMinPrice: selectedMinPrice,
                selectedOnSale: selectedOnSale,
                currencyCode: currencyCode,
                onPriceRangeChanged: onPriceRangeChanged,
                onSaleChanged: onSaleChanged,
                onClearAll: clearAll,
              ),
            if (options.isNotEmpty) ...[
              const SizedBox(height: 48),
              ListingOptionFilters(
                options: options,
                selectedValueIds: selectedOptionValueIds,
                onChanged: onOptionValuesChanged,
              ),
            ],
            if (onPriceRangeChanged case final onChanged?) ...[
              const SizedBox(height: 48),
              ListingPriceRange(
                bounds: priceBounds,
                currencyCode: currencyCode,
                selectedMaxPrice: selectedMaxPrice,
                selectedMinPrice: selectedMinPrice,
                onChanged: onChanged,
              ),
            ],
            if (onSaleChanged case final onChanged?
                when onSaleCount > 0 || selectedOnSale) ...[
              const SizedBox(height: 48),
              ListingOnSaleToggle(
                canRefine: onSaleCount > 0,
                count: onSaleCount,
                selected: selectedOnSale,
                onChanged: onChanged,
              ),
            ],
            if (onCategoryHandlesChanged case final onChanged?
                when categoryFilters.isNotEmpty) ...[
              const SizedBox(height: 48),
              ListingCategoryFilters(
                categories: categoryFilters,
                selectedHandles: selectedCategoryHandles,
                onChanged: onChanged,
              ),
            ],
            if (onLabelValuesChanged case final onChanged?
                when labelFilters.isNotEmpty) ...[
              const SizedBox(height: 48),
              ListingLabelFilters(
                labels: labelFilters,
                selectedValues: selectedLabelValues,
                onChanged: onChanged,
              ),
            ],
          ],
        ),
      );
}
