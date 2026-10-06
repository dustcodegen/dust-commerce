import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'listing_products.dart';
import 'listing_header.dart';
import 'listing_loading_products.dart';
import 'listing_refinements.dart';

/// Store, collection, and category body translated from Medusa templates.
class ProductListingView extends StatelessWidget {
  /// Creates a source-shaped product listing.
  const ProductListingView({
    required this.state,
    required this.requestKey,
    required this.onRetry,
    required this.onSortChanged,
    this.onSearchChanged,
    required this.onPageChanged,
    required this.onOptionValuesChanged,
    this.onCategoryHandlesChanged,
    this.onLabelValuesChanged,
    this.onPriceRangeChanged,
    this.onSaleChanged,
    this.onClearRefinements,
    required this.onCategorySelected,
    super.key,
  });

  /// Category breadcrumb and child navigation.
  final ValueChanged<String> onCategorySelected;

  /// Changes the stable Store category selections.
  final ValueChanged<List<String>>? onCategoryHandlesChanged;

  /// Changes the stable Store label selections.
  final ValueChanged<List<String>>? onLabelValuesChanged;

  /// Changes the one-based page query.
  final ValueChanged<int> onPageChanged;

  /// Clears all Store-only refinements.
  final VoidCallback? onClearRefinements;

  /// Changes the sale-only Store query.
  final ValueChanged<bool>? onSaleChanged;

  /// Changes the Store price-range query.
  final void Function(int? minPrice, int? maxPrice)? onPriceRangeChanged;

  /// Changes the stable option-value selections.
  final ValueChanged<List<String>> onOptionValuesChanged;

  /// Retries the current route request.
  final VoidCallback onRetry;

  /// Changes the Medusa-compatible sort query.
  final ValueChanged<String> onSortChanged;

  /// Changes the free-text Store search query.
  final ValueChanged<String>? onSearchChanged;

  /// Route/query state this widget expects.
  final String requestKey;

  /// Listing state supplied by its Dust view model.
  final ProductListingState state;

  @override
  Widget build(BuildContext context) {
    final storeSearch = onSearchChanged != null;
    final loading = state.status == ProductListingStatus.loading;
    if (state.requestKey != requestKey ||
        state.status == ProductListingStatus.idle ||
        (loading && !storeSearch)) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == ProductListingStatus.failed) {
      return _ListingFailure(onRetry: onRetry, storeSearch: storeSearch);
    }
    if (state.status == ProductListingStatus.missing) {
      return const StoreMainNotFound();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (storeSearch)
                      ListingHeader(
                        state: state,
                        onCategorySelected: onCategorySelected,
                      ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final desktop = constraints.maxWidth >= 976;
                        final refinements = ListingRefinements(
                          selected: state.sortBy,
                          onChanged: onSortChanged,
                          options: state.optionFilters,
                          selectedOptionValueIds: state.selectedOptionValueIds,
                          onOptionValuesChanged: onOptionValuesChanged,
                          categoryFilters: state.categoryFilters,
                          selectedCategoryHandles:
                              state.selectedCategoryHandles,
                          onCategoryHandlesChanged: onCategoryHandlesChanged,
                          labelFilters: state.labelFilters,
                          selectedLabelValues: state.selectedLabelValues,
                          onLabelValuesChanged: onLabelValuesChanged,
                          onPriceRangeChanged: onPriceRangeChanged,
                          onSaleChanged: onSaleChanged,
                          onClearAll: onClearRefinements,
                          priceBounds: state.priceBounds,
                          canRefineOnSale: state.canRefineOnSale,
                          currencyCode: state.currencyCode,
                          selectedMaxPrice: state.selectedMaxPrice,
                          selectedMinPrice: state.selectedMinPrice,
                          selectedOnSale: state.selectedOnSale,
                        );
                        final products = loading
                            ? ListingLoadingProducts(
                                query: state.searchQuery,
                                onSearchChanged: onSearchChanged!,
                              )
                            : ListingProducts(
                                state: state,
                                onSearchChanged: onSearchChanged,
                                onPageChanged: onPageChanged,
                                onCategorySelected: onCategorySelected,
                                showHeader: !storeSearch,
                              );
                        return desktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 26.8),
                                  SizedBox(width: 250, child: refinements),
                                  Expanded(child: products),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 24),
                                    child: refinements,
                                  ),
                                  const SizedBox(height: 32),
                                  products,
                                ],
                              );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const StoreFooter(),
        ],
      ),
    );
  }
}

class _ListingFailure extends StatelessWidget {
  const _ListingFailure({required this.onRetry, required this.storeSearch});

  final VoidCallback onRetry;
  final bool storeSearch;

  @override
  Widget build(BuildContext context) {
    if (storeSearch) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(
          child: TranslatedText(
            'shop_store_products_failure',
            defaultText: "Couldn't load products.",
            textAlign: TextAlign.center,
            style: TextStyle(color: StoreColors.danger),
          ),
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TranslatedText(
            'shop_products_failure',
            defaultText: 'Could not load products.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: const TranslatedText(
              'shop_retry',
              defaultText: 'Try again',
            ),
          ),
        ],
      ),
    );
  }
}
