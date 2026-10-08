import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

import 'product_listing_route.dart';

part 'store_page_query.dart';

/// All-products page translated from Medusa StoreTemplate.
@AppRoute('/store', name: 'store', guards: [])
class StorePage extends StatelessWidget {
  /// Creates the paged store route.
  const StorePage({
    this.page = 1,
    this.q = '',
    this.sortBy = 'relevance',
    this.optionValueIds = const [],
    this.category = const [],
    this.labels = const [],
    this.maxPrice,
    this.minPrice,
    this.onSale = '',
    super.key,
  });

  /// Stable category handles repeated in the URL query.
  final List<String> category;

  /// Stable product label values repeated in the URL query.
  final List<String> labels;

  /// Upper price bound in minor units.
  final int? maxPrice;

  /// Lower price bound in minor units.
  final int? minPrice;

  /// Medusa-compatible sale-only query toggle.
  final String onSale;

  /// Stable option-value identifiers repeated in the URL query.
  final List<String> optionValueIds;

  /// One-based page query.
  final int page;

  /// Free-text product search query.
  final String q;

  /// Medusa-compatible sort query.
  final String sortBy;

  @override
  Widget build(BuildContext context) {
    final query = _StorePageQuery.of(this, context);
    return ProductListingRoute(
      key: ValueKey(query.requestKey),
      requestKey: query.requestKey,
      load: query.load,
      onSortChanged: (value) => query.go(context, sortBy: value),
      onSearchChanged: (value) =>
          query.go(context, q: normalizedSearchQuery(value)),
      onPageChanged: (value) => query.go(context, page: value),
      onOptionValuesChanged: (values) =>
          query.go(context, optionValueIds: values),
      onCategoryHandlesChanged: (values) => query.go(context, category: values),
      onLabelValuesChanged: (values) => query.go(context, labels: values),
      onPriceRangeChanged: (min, max) => query.goPrice(context, min, max),
      onSaleChanged: (value) => query.go(context, onSale: value),
      onClearRefinements: () => query.clear(context),
      onCategorySelected: (handle) =>
          context.navigator.category(handle: handle).go(),
    );
  }
}
